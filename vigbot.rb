::RBNACL_LIBSODIUM_GEM_LIB_PATH = "/libsodium.dll" #libsodium is on the gitignore, just download it and put the dll in your vigbot folder
require 'discordrb'
require 'open-uri'
require 'yaml'

CONFIG = YAML.load_file('config.yaml')
#TODO: Add movie generator, add youtube video generator, add random @er (puts bot.users), add !smite @user which pms the user they've been smited.
bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], client_id: 380386261988540426, prefix: '!'
puts "https://discordapp.com/oauth2/authorize?client_id=380386261988540426&scope=bot" #The link to add Viggy bot to servers
ADMINS = [349606256895459330] #Save the ID of users that can preform elevated commands
vigLogEnable = true #used to turn vigLog on and off

bot.message do |event|
  sentmessage = event.message
  if sentmessage.attachments.length != 0
    extensions = ['.mov','.mp4','.mpeg4','.avi','.wmv','.flv','.3gp','.mpegps','.webm']
    nameoffile = sentmessage.attachments[0].filename.downcase
    if nameoffile.end_with?(*extensions)
      vigLog(bot, ' Found video attachment at ' + getTime)
      File.open('vids/' + nameoffile, "wb") do |file|
        file.write open(sentmessage.attachments[0].url).read
      end
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
        vigLog(bot, 'Fifteen letter string ' + word_hold + ' detected')
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
  if isClosed("North Kansas City Schools")
    event.respond "School is closed."
  else
    event.respond "School is not closed."
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

bot.command :help do |event|
  event << 'Availiable commands:'
  event << 'coinflip: flips a coin'
  event << 'exit: turns the bot off*'
  event << 'joke: generates a random joke'
  event << 'relaunch: reboots vigbot*'
  event << 'roll: rolls a six sided die'
  event << 'schoolclosed?: checks if school is closed.'
  event << 'sorority: generates a sorority name'
  event << 'systemdown: shuts down the host computer*'
  event << 'systemofadown: generates a lyric'
  event << 'teamviewer: launches Teamviewer*'
  event << 'vig: generates a name for Viggy'
  vigLog(bot, event.user.name + ' executed help at ' + getTime)
end

def getJoke
  jokes = ["19 and 20 got into a fight. 21", "A man is washing a car with his son.\n\nThe son asks, \"Dad, can't you just use a sponge?\"", "What's the difference between a well dressed man on a unicycle and a poorly dressed man on a bike?\n\nAttire", "Me and my girlfriend watched three DVDs back to back last night.\n\nLuckily I was the one facing the TV.", "Where do sick boats go?\n\nThe Dock", "Two hunters are out in the woods when one of them collapses. He doesn't seem to be breathing and his eyes are glazed. The other guy whips out his phone and calls 911. He gasps, \"My friend is dead! What can I do?\" The operator says \"Calm down. I can help. First, let's make sure he's dead.\" There is a silence; then a gun shot is heard. Back on the phone, the guy says \"OK, now what?\"", "Why do the Norwegian navy put barcodes on the side of their ships?\n\nSo they can Scandinavian", "Which tea is the hardest to swallow?\n\nReality", "Eric Cheung", "What's green, fuzzy, has four legs, and if it falls out of a tree it will kill you?\n\nA pool table.", "Why don't ants get sick?\n\nbecause they have little anty-bodies.", "What sound do a sheep, a drum, and a snake make when they fall off a cliff and hit the bottom?\n\nBa dum tiss.", "A SQL query goes into a bar, walks up to two tables and asks, \"Can I join you?\"", "[\"hip\",\"hip\"]\n\n(hip hip array!)", "http://longestjokeintheworld.com/"]
  return jokes.sample
end

def getSOAD
  soad = ["Banana, banana, banana, terracotta, banana, terracotta, terracotta pie!", "I hope your stepson doesn't eat the fish", "What a splendid pie! Pizza pizza pie!", "Wired were the eyes of a horse on a jet pilot", "My cock is much bigger than yours / My cock can walk right through the door", "Mind delusions acquainted / Bubbles erotica / Plutonium wedding rings / Icicles stretching / Bicycles, shoestrings / One flag, flaggy but one / Painting the paintings of the alive."]
  return soad.sample
end

def vigGen
  return (get_line_from_file("V.txt", Random.rand(1..6816)).strip + " " + get_line_from_file("T.txt", Random.rand(1..25228)).strip).downcase #hardcode the random values because the files won't be changing
end

def getUsers(bot)
  return bot.users
end

def coinflip
  if Random.rand(2) == 1
    return "Heads"
  else
    return "Tails"
  end
end

#Used by viggen to read from a random line
def get_line_from_file(path, line) 
  result = nil
  File.open(path, "r") do |f|
    while line > 0
      line -= 1
      result = f.gets
    end
  end
  return result
end

def getTime
  return Time.new.inspect
end

def isClosed(school) #gets the html from KMBC's closing list as a string and checks to see if the district name is in it anywhere, depends on open-uri
  closings = open('http://www.kmbc.com/weather/closings', &:read)
  if closings.include? school
    return true
  else 
    return false
  end
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
