require 'discordrb'
require 'open-uri'
#TODO: Convert Admin to an array, Add movie generator, add youtube video generator, add random @er (puts bot.users), add !smite @user which pms the user they've been smited.
bot_token = 'your token goes here'
bot = Discordrb::Commands::CommandBot.new token: bot_token, client_id: 380386261988540426, prefix: '!'
puts "https://discordapp.com/oauth2/authorize?client_id=380386261988540426&scope=bot" #The link to add Viggy bot to servers
admin = 349606256895459330 #save my user id for elevate privilege commands
vigLogEnable = true #used to turn vigLog on and off

bot.message do |event| #what it does whenever any message is sent
end

bot.command :coinflip do |event| #Flips a coin
	event.respond coinflip
	vigLog(bot, event.user.name + " flipped a coin at " + getTime)
end

bot.command :exit do |event| #Allows admin to turn the bot off
	break unless event.user.id == admin # Replace number with your ID
	event.respond "Viggy Bot is shutting down."
	vigLog(bot, event.user.name + " shut the Viggy Bot down at " + getTime)
	exit
end

bot.command :joke do |event| #sends a random jokes 
	vigLog(bot, event.user.name + " generated a joke at " + getTime)
	event.respond getJoke()
end

bot.command :relaunch do |event| #Launches another bot then kills this one so updated code is used. 
	if event.user.id != admin
		event.respond "User " + event.user.name + " lacks sufficient permissions to launch Team Viewer."
		break
	end
	event.respond "Relaunching Vigbot."
	vigLog(bot, event.user.name + " triggered relaunch at " + getTime)
	`start vigbot.rb` #for this to properly run you need a shortcut to Teamviewer in the same directory
	exit
end

bot.command :roll do |event| #Rolls a six sided die
	event.respond (1 + Random.rand(6))
	vigLog(bot, event.user.name + " rolled a die at " + getTime)
end

bot.command :schoolclosed? do |event| #uses the isClosed method to check if school is closed. 
	if isClosed("North Kansas City Schools")
		event.respond "School is closed."
	else
		event.respond "School is not closed."
	end
	vigLog(bot, event.user.name + " checked for school closing at " + getTime)
end

bot.command :sorority do |event| #generates the name of a sorority 
	event.respond sororityGen
	vigLog(bot, event.user.name + " generated a sorority at " + getTime)
end

bot.command :systemdown do |event| #shuts off the host computer using the shutdown command 
	if event.user.id != admin
		event.user.name + " lacks sufficient permissions to shut the system down."
		break
	end
	event.respond "System going offline"
	vigLog(bot, event.user.name + " shut down at " + getTime)
	`shutdown /r /t 0`
end

bot.command :teamviewer do |event| #Launches Team Viewer
	if event.user.id != admin
		event.respond "User " + event.user.name + " lacks sufficient permissions to launch Team Viewer."
		break
	end
	event.respond "TeamViewer is launching."
	vigLog(bot, event.user.name + " launched Team Viewer at " + getTime)
	`start teamviewer.lnk` #for this to properly run you need a shortcut to Teamviewer in the same directory
end

bot.command :vig do |event| #Sends a generated Vig Name
	hold = vigGen()
	event.respond hold
	vigLog(bot, event.user.name + " generated " + hold + " at " + getTime)
end

bot.mention do |event| #sends a pm when mentioned
	event.user.pm("Leave me the fuck alone " + event.user.name + "!")
	vigLog(bot, event.user.name + " mentioned me at " + getTime)
end

if Time.new(2018, 1, 19, 12, 0, 0) = getTime # a slop of code
	bot.send_message(349606256895459330, "send me a music video")
end

if Time.new(2018, 1, 18, 2, 20, 0) = getTime # a test
	bot.send_message(323992097231208450, "haha")
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
	event << 'teamviewer: launches Teamviewer*'
	event << 'vig: generates a name for Viggy'
	vigLog(bot, event.user.name + " executed help at " + getTime)
end

def getJoke()
	jokes = ["19 and 20 got into a fight. 21", "A man is washing a car with his son.\n\nThe son asks, \"Dad, can't you just use a sponge?\"", "What's the difference between a well dressed man on a unicycle and a poorly dressed man on a bike?\n\nAttire", "Me and my girlfriend watched three DVDs back to back last night.\n\nLuckily I was the one facing the TV.", "Where do sick boats go?\n\nThe Dock", "Two hunters are out in the woods when one of them collapses. He doesn't seem to be breathing and his eyes are glazed. The other guy whips out his phone and calls 911. He gasps, \"My friend is dead! What can I do?\" The operator says \"Calm down. I can help. First, let's make sure he's dead.\" There is a silence; then a gun shot is heard. Back on the phone, the guy says \"OK, now what?\"", "Why do the Norwegian navy put barcodes on the side of their ships?\n\nSo they can Scandinavian", "Which tea is the hardest to swallow?\n\nReality", "Eric Cheung", "What's green, fuzzy, has four legs, and if it falls out of a tree it will kill you?\n\nA pool table.", "Why don't ants get sick?\n\nbecause they have little anty-bodies.", "What sound do a sheep, a drum, and a snake make when they fall off a cliff and hit the bottom?\n\nBa dum tiss.", "A SQL query goes into a bar, walks up to two tables and asks, \"Can I join you?\"", "[\"hip\",\"hip\"]\n\n(hip hip array!)", "http://longestjokeintheworld.com/"]
	return jokes[Random.rand((jokes.length()))]
end

def vigGen()
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
	return greek[Random.rand(greek.length())] + " " + greek[Random.rand(greek.length())] + " " + greek[Random.rand(greek.length())]
end

def vigLog(bot, log) #used to log the bots events, it both outputs to console and messages a channel.
	puts log
	bot.send_message(397750668829655041, log)
end

bot.run
