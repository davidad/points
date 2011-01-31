require 'sinatra'
require 'json'
require 'open-uri'
require 'uri'
require 'digest/sha1'
require 'time'
set :port, 8080

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

$app_id = 185939958095207
$default_uri = "http://points.xvm.mit.edu:8080/"
$app_secret = "5972a599ecfa901530c4b404f68ad5c7"
$app_token = nil
# (unimplemented and unused) # $app_exp = nil

get '/' do
  if(!params['code']) then
    dialog_url = "http://www.facebook.com/dialog/oauth?client_id=#{$app_id}&redirect_uri=#{URI.encode($default_uri)}"
    "<script> top.location.href = '#{dialog_url}' </script>"
  else
    token_url = "https://graph.facebook.com/oauth/access_token?client_id=#{$app_id}&redirect_uri=#{URI.encode($default_uri)}&client_secret=#{$app_secret}&code=#{params['code']}"
    $app_token = URI.parse(URI.encode(token_url)).read
    $app_token.split('&')[0].split('=')[1]
  end
#  halt 302, {'Location':'http://points.xvm.mit.edu:8080/static_app.html'}
  
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
    userfile = File.new(username,"w+")
    data = {'points_history' =>
              [{'time' => Time.now.to_s, 'points' => 0}]}
    userfile.puts(data.to_json)
    userfile.close
    { 'success'=>1,
      'points'=>0,
      'apikey'=>apikey }.to_json
  end
end

def validToken
  if $app_token == nil then
    return false
  end
  return true#should eventually check for expiredness.
end

def read_user
  if(not validToken) then
    halt 302, {'Location'=>'http://points.xvm.mit.edu:8080/'}, ""
  end
  database_query = "https://graph.facebook.com/me?" + $app_token;
  facebook_data = JSON.load(URI.parse(URI.encode(database_query)).read)
  
  if(!File.file?(facebook_data['id'])) then
    #make a new user
  end
  userfile = File.new(facebook_data['id'],"r")
  data = JSON.load(userfile)
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
