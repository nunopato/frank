require "./frank"

get "/" do
  "Hi, from Frank!"
end

get "/scoped" do
  "scoped"
end

Rack::Handler::Thin.run Frank::Application, Port: 9292
