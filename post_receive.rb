require 'sinatra'
post '/' do
	system("git pull origin master")
	system("screen -dR -S appserve -X quit")
	system("screen -dm -S appserve ruby appserver.rb")
end
