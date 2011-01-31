require 'sinatra'
require 'json'
require 'digest/sha1'
set :port, 8080

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

def failure(msg)
  { 'success'=>0,
    'error'=>msg }.to_json
end

get_or_post '/newuser' do
  content_type :json
  username = params['username']
  if(!(/\A\w+\Z/=~username)) then #check if username consists entirely of sane characters
    return failure("Username must consist only of digits, uppercase or lowercase letters, and underscores.")
  elsif(File.file?(username)) then
    return failure("User #{username} already exists")
  else
    apikey = Digest::SHA1.hexdigest(Time.now.to_s + rand(1000000).to_s)
    userfile = File.new(username,"w+")
    userdata = {'apikey' => apikey,
                'points_history' =>
                  [{'time' => Time.now_to_s, 'points' => 0}]}
    userfile.puts(userdata.to_json)
    { 'success'=>1,
      'points'=>0,
      'apikey'=>apikey }.to_json
  end
end

get_or_post '/points/now' do
  content_type :json
  username = params['username']
  if(!File.file?(username)) then
    return failure("User does not exist")
  end
  userfile = File.new(username,"r")
  userdata = JSON.load(userfile)
  if(userdata['apikey'] != params['apikey']) then
    return failure("Incorrect API key")
  end
  { 'success'=>1,
    'points'=>userdata['points_history'][-1]['points'] }.to_json
end
