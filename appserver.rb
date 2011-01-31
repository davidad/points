require 'sinatra'
require 'json'
set :port, 8080

post '/test_json' do
  { 'key' => 'value' }.to_json
end
