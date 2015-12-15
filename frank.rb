require "rack"
require 'pry'

module Frank
  class Base
    attr_reader :routes, :request

    def initialize
      @routes = {}
    end

    def call(env)
      @request = Rack::Request.new(env)

      verb = @request.request_method
      requested_path = @request.path_info

      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      handler ? [200, {}, instance_eval(&handler)] : invalid_path_response
    end

    def get(path, &handler)
      route("GET", path, &handler)
    end

    def post(path, &handler)
      route("POST", path, &handler)
    end

    def put(path, &handler)
      route("PUT", path, &handler)
    end

    def patch(path, &handler)
      route("PATCH", path, &handler)
    end

    def delete(path, &handler)
      route("DELETE", path, &handler)
    end

    def head(path, &handler)
      route("HEAD", path, &handler)
    end

    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end

    def invalid_path_response
      [404, {}, ["Sorry, but the requested path is not valid"]]
    end

    def params
      @request.params
    end
  end

  Application = Base.new

  module Delegator
    def self.delegate(*methods, to:)
      Array(methods).each do |method|
        define_method(method) do |*args, &block|
          to.send(method, *args, &block)
        end

        private method
      end
    end

    delegate :get, :patch, :put, :post, :delete, :head, to: Application
  end
end

include Frank::Delegator
