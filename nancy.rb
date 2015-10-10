require "rack"
require "awesome_print"

# A base Sinatra-like class that other classes can inherit from.
# https://robots.thoughtbot.com/lets-build-a-sinatra

# Store routes (like GET /hello) and actions to take when hitting those routes.
# For each request, it will match the requested route to the stored routes, and
# take action if there’s a match, or return a 404 if nothing matches.

module Nancy
  class Base

    def initialize
      @routes = {}
    end

    attr_reader :routes

    def get(path, &handler)
      route("GET", path, &handler)
    end

    private

      def route(verb, path, &handler)
        @routes[verb] ||= {}
        @routes[verb][path] = handler
      end
  end
end

#==> TEST - Run ruby nancy.rb

# Instantiate the Nancy::Base class
nancy = Nancy::Base.new

# Add a GET request route
nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

# Print the routes
ap nancy.routes
