require 'sinatra'
require 'json'
require 'digest/sha1'
set :port, 8080

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get_or_post '/newuser' do
  content_type :json
  username = params['username']
  if(!(/\A\w+\Z/=~username)) then #check if username consists entirely of sane characters
    { 'success'=>0,
      'error'=>"Username must consist only of digits, uppercase or lowercase letters, and underscores." }.to_json
  elsif(File.file?(username)) then
    { 'success'=>0,
      'error'=>"User #{username} already exists" }.to_json
  else
    apikey = Digest::SHA1.hexdigest(Time.now.to_s + rand(1000000).to_s)
    userfile = File.new(username,"w+")
    userfile.puts(apikey)
    { 'success'=>1,
      'apikey'=>apikey }.to_json
  end
end
