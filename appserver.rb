require 'sinatra'
set :port, 8080

get '/' do
  'Hello, I\'m the app server.'
end
