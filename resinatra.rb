require 'sinatra'
require 'json'
require 'open-uri'
require 'uri'

set :port, 80

$app_id = 185939958095207
$default_uri = "http://points.xvm.mit.edu/"
$app_secret = "5972a599ecfa901530c4b404f68ad5c7"

get '/' do
  if(!params['code']) then
    dialog_url = "http://www.facebook.com/dialog/oauth?client_id=#{$app_id}&redirect_uri=#{URI.encode($default_uri)}"
    "<script> top.location.href = '#{dialog_url}' </script>"
  else
    token_url = "https://graph.facebook.com/oauth/access_token?client_id=#{$app_id}&redirect_uri=#{URI.encode($default_uri)}&client_secret=#{$app_secret}&code=#{params['code']}"
    URI.parse(URI.encode(token_url)).read
  end
end


