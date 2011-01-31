require 'sinatra'
require 'json'

set :port, 80

get '/' do
  haml :index
end

__END__

@@ index
%div.title Hello world!
