require 'sinatra'
require 'json'
set :port, 8080

get '/test_json' do
  content_type :json
  params.to_json
end
