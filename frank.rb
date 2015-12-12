require "rack"

module Frank
  class Base
    attr_reader :routes

    def initialize
      @routes = {}
    end

    def call(env)
      @request = Rack::Request.new(env)

      verb = @request.request_method
      requested_path = @request.path_info

      @routes[verb][requested_path].call
    end

    def get(path, &handler)
      route("GET", path, &handler)
    end

    def post(path, &handler)
      route("POST", path, &handler)
    end

    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end
  end
end

frank = Frank::Base.new

frank.get "/hello" do
  [200, {}, ["Hello from frank sinatra!"]]
end

Rack::Handler::Thin.run frank, Port: 9292
