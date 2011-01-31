require 'sinatra'
require 'json'
require 'digest/sha1'
set :port, 8080

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

app_secret = fbf03b0a9c5175ddecc1ab01bbe5a370
app_id = 196454990366058
api_key = 590cdce4e47bccec1f78b5ff2729f7de

get '/facebooklogin' do
  halt 302, 'https://www.facebook.com/dialog/oauth?client_id=YOUR_APP_ID&redirect_uri=points.xvm.mit.edu/authenticate'
end

get '/authenticate' do
  #there is a variable passed here called caode that can be used to get more stuff.
  'not yet implemented'
end

def failure(msg)
  { 'success'=>0,
    'error'=>msg }.to_json
end

get_or_post '/newuser' do
  content_type :json
  username = params['username']
  if(!(/\A\w+\Z/=~username)) then #check if username consists entirely of sane characters
    return failure("Username must consist only of digits, uppercase or lowercase letters, and underscores")
  elsif(File.file?(username)) then
    return failure("User #{username} already exists")
  else
    apikey = Digest::SHA1.hexdigest(Time.now.to_s + rand(1000000).to_s)
    userfile = File.new(username,"w+")
    data = {'apikey' => apikey,
            'points_history' =>
              [{'time' => Time.now.to_s, 'points' => 0}]}
    userfile.puts(data.to_json)
    userfile.close
    { 'success'=>1,
      'points'=>0,
      'apikey'=>apikey }.to_json
  end
end

def read_user(params)
  if(!File.file?(params['username'])) then
    halt failure("User does not exist")
  end
  userfile = File.new(params['username'],"r")
  data = JSON.load(userfile)
  if(data['apikey'] != params['apikey']) then
    halt failure("Incorrect API key")
  end
  return data
end

def write_user(params,data)
  userfile = File.new(params['username'],"w")
  JSON.dump(data,userfile)
  userfile.close
end

get_or_post '/getpoints' do
  content_type :json
  data = read_user(params)
  { 'success'=>1,
    'points'=>data['points_history'][-1]['points'] }.to_json
end

get_or_post '/setpoints' do
  content_type :json
  data = read_user(params)
  if(!params['delta']) then
    halt failure("No delta specified")
  elsif(!(/\A-?\d+\Z/=~params['delta'])) then
    halt failure("Delta must be an integer")
  end
  current_points=data['points_history'][-1]['points']
  new_points=current_points.to_i+params['delta'].to_i
  data['points_history'].push({'points' => new_points,
                               'time' => Time.now.to_s})
  write_user(params,data)
  { 'success'=>1,
    'points' => new_points }.to_json
end

get_or_post '/getpoints/history' do
  content_type :json
  data = read_user(params)
  if(!params['length']) then
    length=50
  else
    length=params['length']
  end
  { 'success'=>1,
    'points_history'=>data['points_history'].pop(length.to_i) }.to_json
end
