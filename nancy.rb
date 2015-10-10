require "rack"
require "awesome_print"

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

    attr_reader :routes

    def get(path, &handler)
      route("GET", path, &handler)
    end

    # To make Nancy::Base a Rack app
    def call(env)
      # Grab the verb and requested path from the env parameter
      @request = Rack::Request.new(env)
      verb           = @request.request_method
      requested_path = @request.path_info

      # Grab the handler block from @routes
      handler = @routes[verb][requested_path]

      handler.call
    end

    private

      # Store routes as handler blocks
      def route(verb, path, &handler)
        # Create a hash for the verb if it is the first time
        @routes[verb] ||= {}
        @routes[verb][path] = handler
      end
  end
end

#==> TEST
# 1. Run `ruby nancy.rb`
# 2. Visit http://localhost:9292/hello
# 3. Hit Ctrl-c to quit

# Instantiate the Nancy::Base class
nancy = Nancy::Base.new

# Add a GET request route
nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

# Print all the routes
ap nancy.routes

# Run the app using the server WEBrick that is built in to Ruby.
Rack::Handler::WEBrick.run nancy, Port: 9292
