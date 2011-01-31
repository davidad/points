require 'sinatra'
require 'json'

get '/' do
  haml :index
end

__END__

@@ index
%div.title Hello world!
