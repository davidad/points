require 'sinatra'
set :port, 8080

get '/' do
  'Hello, I am the app server.'
end
