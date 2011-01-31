require 'sinatra'
set :port, 4567 #This is the default port, but set it anyway

post '/' do
	system("git pull origin master")
	system("screen -dR -S appserve -X quit")
	system("screen -dm -S appserve ruby appserver.rb")
end
