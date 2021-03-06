::RBNACL_LIBSODIUM_GEM_LIB_PATH = "/libsodium.dll" #libsodium is on the gitignore, just download it and put the dll in your vigbot folder
require 'discordrb'
require 'open-uri'
require 'yaml'
require_relative 'youtubestuff/uptoyoutube'

CONFIG = YAML.load_file('config.yaml')
#TODO: Use built in help command, Add movie generator, add youtube video generator, add random @er (puts bot.users), add !smite @user which pms the user they've been smited.
bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], client_id: 380386261988540426, prefix: '!'
puts "https://discordapp.com/oauth2/authorize?client_id=380386261988540426&scope=bot" #The link to add Viggy bot to servers
ADMINS = [349606256895459330] #Save the ID of users that can preform elevated commands
vigLogEnable = true #used to turn vigLog on and off

bot.message do |event|
  sentmessage = event.message
  if sentmessage.attachments.length != 0
    extensions = ['.mov','.mp4','.mpeg4','.avi','.wmv','.flv','.3gp','.mpegps','.webm']
    name_of_file = sentmessage.attachments[0].filename.downcase
    if name_of_file.end_with?(*extensions)
      vigLog(bot, 'Found video attachment at ' + getTime)
      File.open('vids/' + name_of_file, "wb") do |file|
        file.write open(sentmessage.attachments[0].url).read
      end
      i = 0
      begin
        result = Samples::YouTube.new.upload('vids/' + name_of_file, 'title')
        vigLog(bot, 'https://www.youtube.com/watch?v=' + result.id)
      rescue Errno::ETIMEDOUT, NoMethodError
        if i < 5
          i += 1
          vigLog(bot, 'Failed, trying again.')
          retry
        end
        vigLog(bot, 'Attempted 5 times.')
      end
      File.delete('vids/' + name_of_file)
    end
  end
end

bot.message do |event| #what it does whenever any message is sent, currently detecting fifteen letter words in messages
  sentence = event.message.to_s #get the message and make sure you convert it to a string
  sentence += " " # add space to the end so it detects word on the end
  take = [".", "!", "?", ",", "'", "\"", "/", "\\", ":", ";"] #items to remove from the string for formatting purposes
  take.each do |remove|
    sentence = sentence.tr(remove, "")
  end
  word_hold = ""
  sentence.each_char do |i|
    if i != " "
      word_hold += i
    else
      if word_hold.length == 15
        vigLog(bot, 'Fifteen letter string ' + word_hold + ' detected.')
        event.respond 'Fifteen letter string detected: ' + word_hold
      end
      word_hold = ""
    end
  end
end

bot.command :coinflip do |event| #Flips a coin
  event.respond coinflip
  vigLog(bot, event.user.name + ' flipped a coin at ' + getTime)
end

bot.command :closediscord do |event| #Allows me to close Discord remotely so I get all my notifications
  if not ADMINS.include? event.user.id
    event.respond "User " + event.user.name + " lacks sufficient permissions to close the active Discord session."
    break
  end
  event.respond "Closing Discord."
  `taskkill /f /im discord.exe`
  vigLog(bot, event.user.name + ' closed Discord at ' + getTime)
end

bot.command :exit do |event| #Allows admin to turn the bot off
  if not ADMINS.include? event.user.id
    event.respond 'User ' + event.user.name + ' lacks sufficient permissions to turn off vigbot.'
    break
  end
  event.respond 'Viggy Bot is shutting down.'
  vigLog(bot, event.user.name + ' shut the Viggy Bot down at ' + getTime)
  exit
end

bot.command :joke do |event| #sends a random jokes 
  vigLog(bot, event.user.name + ' generated a joke at ' + getTime)
  event.respond getJoke
end

bot.command :nccclosed? do |event|
  if isNCCClosed
    event.respond "Platte County R3 School District is closed."
  else
    event.respond "Platte County R3 School District is not closed."
  end
  vigLog(bot, event.user.name + ' checked for NCC closing at ' + getTime)
end

bot.command :reading do |event| #Returns the url of something to read. Note: I want to develop the list a bit more before I add it to help or make people aware of it. 
  event.respond somethingToRead
  vigLog(bot, event.user.name + " requested something to read at " + getTime)
end

bot.command :relaunch do |event| #Launches another bot then kills this one so updated code is used. This now pulls updated code from github.
  if not ADMINS.include? event.user.id
    event.respond "User " + event.user.name + " lacks sufficient permissions to relaunch vigbot."
    break
  end
  event.respond "Pulling code from Github."
  `git pull origin master` #Still unsure if this waits for the pull to finish before relaunching, probably not.
  event.respond "Relaunching Vigbot."
  vigLog(bot, event.user.name + ' triggered relaunch at ' + getTime)
  `start vigbot.rb` #for this to properly run you need a shortcut to Teamviewer in the same directory
  exit
end

bot.command :roll do |event| #Rolls a six sided die
  event.respond (1 + Random.rand(6))
  vigLog(bot, event.user.name + ' rolled a die at ' + getTime)
end

bot.command :schoolclosed? do |event| #uses the isClosed method to check if school is closed. 
  if isClosed
    event.respond "North Kansas City School District is closed."
  else
    event.respond "North Kansas City School District is not closed."
  end
  vigLog(bot, event.user.name + ' checked for school closing at ' + getTime)
end

bot.command :sorority do |event| #generates the name of a sorority 
  event.respond sororityGen
  vigLog(bot, event.user.name + ' generated a sorority at ' + getTime)
end

bot.command :systemdown do |event| #shuts off the host computer using the shutdown command 
  if not ADMINS.include? event.user.id
    event.respond "User " + event.user.name + " lacks sufficient permissions to shut the system down."
    break
  end
  event.respond "System going offline"
  vigLog(bot, event.user.name + ' shut down at ' + getTime)
  `shutdown /r /t 0`
end

bot.command :systemofadown do |event|
  event.respond getSOAD
  vigLog(bot, event.user.name + ' hit a sick beat! at ' + getTime)
end

bot.command :teamviewer do |event| #Launches Team Viewer
  if not ADMINS.include? event.user.id
    event.respond "User " + event.user.name + " lacks sufficient permissions to launch Team Viewer"
    break
  end
  event.respond "TeamViewer is launching."
  vigLog(bot, event.user.name + ' launched Team Viewer at ' + getTime)
  `start teamviewer.lnk` #for this to properly run you need a shortcut to Team Viewer in the same directory
end

bot.command :vig do |event| #Sends a generated Vig Name
  hold = vigGen
  event.respond hold
  vigLog(bot, event.user.name + ' generated ' + hold + ' at ' + getTime)
end

bot.mention do |event| #sends a pm when mentioned
  event.user.pm("Leave me the fuck alone " + event.user.name + "!")
  vigLog(bot, event.user.name + ' mentioned me at ' + getTime)
end

bot.command :help do |event| #Used to display commands that a regular user can preform
  event << 'Availiable commands:'
  event << 'coinflip: flips a coin'
  event << 'joke: generates a random joke'
  event << 'nccclosed?: checks if NCC is closed'
  event << 'roll: rolls a six sided die'
  event << 'schoolclosed?: checks if school is closed.'
  event << 'sorority: generates a sorority name'
  event << 'systemofadown: generates a lyric'
  event << 'vig: generates a name for Viggy'
  vigLog(bot, event.user.name + ' executed help at ' + getTime)
end

bot.command :ahelp do |event| #Used to display commands that only admins can preform.
  event << 'Availiable admin commands:'
  event << 'closediscord: closes the Discord session.'
  event << 'exit: turns the bot off'
  event << 'relaunch: reboots vigbot'
  event << 'systemdown: shuts down the host computer'
  event << 'teamviewer: launches Teamviewer'
  vigLog(bot, event.user.name + ' executed admin help at ' + getTime)
end

def coinflip
  if Random.rand(2) == 1
    return "Heads"
  else
    return "Tails"
  end
end

def getJoke
  jokes = ["19 and 20 got into a fight. 21", "A man is washing a car with his son.\n\nThe son asks, \"Dad, can't you just use a sponge?\"", "What's the difference between a well dressed man on a unicycle and a poorly dressed man on a bike?\n\nAttire", "Me and my girlfriend watched three DVDs back to back last night.\n\nLuckily I was the one facing the TV.", "Where do sick boats go?\n\nThe Dock", "Two hunters are out in the woods when one of them collapses. He doesn't seem to be breathing and his eyes are glazed. The other guy whips out his phone and calls 911. He gasps, \"My friend is dead! What can I do?\" The operator says \"Calm down. I can help. First, let's make sure he's dead.\" There is a silence; then a gun shot is heard. Back on the phone, the guy says \"OK, now what?\"", "Why do the Norwegian navy put barcodes on the side of their ships?\n\nSo they can Scandinavian", "Which tea is the hardest to swallow?\n\nReality", "Eric Cheung", "What's green, fuzzy, has four legs, and if it falls out of a tree it will kill you?\n\nA pool table.", "Why don't ants get sick?\n\nbecause they have little anty-bodies.", "What sound do a sheep, a drum, and a snake make when they fall off a cliff and hit the bottom?\n\nBa dum tiss.", "A SQL query goes into a bar, walks up to two tables and asks, \"Can I join you?\"", "[\"hip\",\"hip\"]\n\n(hip hip array!)", "http://longestjokeintheworld.com/"]
  return jokes.sample
end

def getSOAD
  soad = ["Banana, banana, banana, terracotta, banana, terracotta, terracotta pie!", "I hope your stepson doesn't eat the fish", "What a splendid pie! Pizza pizza pie!", "Wired were the eyes of a horse on a jet pilot", "My cock is much bigger than yours / My cock can walk right through the door", "Mind delusions acquainted / Bubbles erotica / Plutonium wedding rings / Icicles stretching / Bicycles, shoestrings / One flag, flaggy but one / Painting the paintings of the alive."]
  return soad.sample
end

def getTime
  return Time.new.inspect
end

def getUsers(bot)
  return bot.users
end

def vigGen
  return (get_line_from_file("V.txt", Random.rand(1..6816)).strip + " " + get_line_from_file("T.txt", Random.rand(1..25228)).strip).downcase #hardcode the random values because the files won't be changing
end

def get_line_from_file(path, line) #Used by viggen to read from a random line
  result = nil
  File.open(path, "r") do |f|
    while line > 0
      line -= 1
      result = f.gets
    end
  end
  return result
end

def isClosed #Checks the district news page for the string "There will be no school on {weekday name}, {month name} {day}"
  t = Time.new
  week = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
  message = ("there will be no school on " + week[t.wday] + ", " + Date::MONTHNAMES[t.month] + " " + t.day.to_s).downcase
  closings = open('https://www.nkcschools.org/page.cfm?p=2500', &:read).downcase
  if closings.include? message
    return true
  else 
    return false
  end
end

def isNCCClosed #Checks the district website for the school closed gif
  closings = open('https://www.plattecountyschooldistrict.com/', &:read)
  if closings.include? "/cms/lib/MO01909184/Centricity/Domain/4/SWSchoolClosed.gif"
    return true
  else 
    return false
  end
end

def somethingToRead #Just returns urls from an array
  readingList = ["Never buy a Steinway: https://www.reddit.com/r/AskReddit/comments/7vwkqg/hey_reddit_what_products_are_identical_to_a_brand/dtvtkzd/", "Should you leave your car running in the winter?: https://jalopnik.com/exactly-why-you-need-to-warm-up-your-car-when-its-cold-1821737173", "Eight reasons to visit Kansas City: https://www.visitkc.com/visitors/things-do/attractions/top-reasons-visit-kansas-city", "East Coast-West Coast hip hop rivalry https://en.wikipedia.org/wiki/East_Coast%E2%80%93West_Coast_hip_hop_rivalry", "Ankole-Watusi: http://www.ansi.okstate.edu/breeds/cattle/ankolewatusi/", "Legal analysis of Jay-Z's 99 Problems: http://pdf.textfiles.com/academics/lj56-2_mason_article.pdf", "Can I own a pet fox?: https://www.popsci.com/g00/science/article/2012-10/fyi-domesticated-foxes"]
  return readingList.sample
end

def sororityGen
  greek = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"]
  if Random.rand(2) == 1
    return greek.sample + " " + greek.sample
  else
    return greek.sample + " " + greek.sample + " " + greek.sample
  end
end

def vigLog(bot, log) #used to log the bots events, it both outputs to console and messages a channel.
  puts log
  bot.send_message(397750668829655041, log)
end

bot.run
