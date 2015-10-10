require "rack"

# A base Sinatra-like class that other classes can inherit from.
# https://robots.thoughtbot.com/lets-build-a-sinatra

# Store routes (like GET /hello) and actions to take when hitting those routes.
# For each request, it will match the requested route to the stored routes, and
# take action if there’s a match, or return a 404 if nothing matches.

# Block handlers must return something that Rack can understand.

module Nancy

  class Base

    def initialize
      @routes = {}
    end

    # Getter methods to access instance variables
    attr_reader :routes
    attr_reader :request

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

    # To make Nancy::Base a Rack app
    def call(env)
      # Grab the verb and requested path from the env parameter
      @request = Rack::Request.new(env)
      verb           = @request.request_method
      requested_path = @request.path_info

      # Grab the handler block from @routes if it exists
      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      if handler
        # Evaluate our route handler block in the context of that instance,
        # to give it access to all of the methods (Compare: handler.call)
        result = instance_eval(&handler)

        if result.class == String
          # For convenience, if a handler returns a string,
          # assume that it is a successful response.
          [200, {}, [result]]
        else
          # Otherwise, return the result of the block as-is.
          result
        end
      else
        # Return a 404 with a custom error message
        # instead of the default Internal Server Error
        [404, {}, ["Oops! No routes for #{verb} #{requested_path}"]]
      end
    end

    private

      # Store routes as handler blocks
      def route(verb, path, &handler)
        # Create a hash for the verb if it is the first time
        @routes[verb] ||= {}
        @routes[verb][path] = handler
      end

      def params
         # The Rack::Request class that wraps the env has a method called params
         # that contains information about all parameters provided to the method
         # (GET, POST, PATCH, etc.)
        @request.params
      end
  end

  # an instance of Nancy::Base that we can reference
  Application = Base.new

  # Make an instance of Nancy::Base class be accessble from anywhere
  module Delegator

    def self.delegate(*methods, to:)
      Array(methods).each do |method_name|
        define_method(method_name) do |*args, &block|
          to.send(method_name, *args, &block)
        end

        private method_name
      end
    end

    delegate :get, :patch, :put, :post, :delete, :head, to: Application
  end
end

# To access a Nancy::Base object from anywhere
include Nancy::Delegator
puts %Q(Nancy::Delegator's self is #{self.inspect})  #=> self is main
