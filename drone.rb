#This is the drone, it is used to run commands while vigbot is closed. 
require 'discordrb'
require 'yaml'

puts "Drone"
`start vigbot.rb`
CONFIG = YAML.load_file('config.yaml')
bot = Discordrb::Commands::CommandBot.new token: CONFIG['dronetoken'], client_id: 407569229810761728, prefix: '!'

bot.command :launch do |event| #Launches Vigbot TODO: Check if vigbot is already running.
  event.respond "Launching Vigbot"
  `start vigbot.rb`
end

bot.run






