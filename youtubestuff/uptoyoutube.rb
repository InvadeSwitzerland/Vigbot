#!/usr/bin/ruby

require 'google/apis/youtube_v3'
require_relative 'base_cli'

module Samples
  # Examples for the YouTube APIs
  #
  # Sample usage:
  #
  #     $ ./google-api-samples youtube upload ~/myvideo.mov --title="So funny!"
  #
  class YouTube < BaseCli
    YT = Google::Apis::YoutubeV3

    desc 'upload FILE', 'Upload a video to YouTube'
    method_option :title, type: :string
    def upload(file, title)
      youtube = YT::YouTubeService.new
      youtube.authorization = user_credentials_for(YT::AUTH_YOUTUBE)

      metadata = {
        snippet: {
          title: title
        },
        status: {
          privacy_status: 'unlisted'
        }
      }
      say 'uploading ' + file.to_s
      result = youtube.insert_video('snippet,status', metadata, upload_source: file)
      say 'Upload complete'
      return result
    end
  end
end
