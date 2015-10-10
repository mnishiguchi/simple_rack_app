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

#==> TEST

# 1. Run `ruby nancy.rb`
# 2. Visit http://localhost:9292/hello                   => existent GET route
# 3. Visit http://localhost:9292/hola                    => non-existent GET route
# 4. Visit http://localhost:9292/?foo=bar&hello=goodbye  => show params
# 5. $ curl --data "body is hello" localhost:9292/       => POST route
# 6. Hit Ctrl-c to quit

# a reference to a Nancy::Base object
app = Nancy::Application

include Nancy::Delegator


# Add a GET request route
get "/hello" do
  [200, {}, ["Hello world"]]
end

# Add a GET request route with a string content
get "/string" do
  <<-EOS.gsub(/^\s*/, "")  # Strip leading whitespace from each line of the string
    <html>
      <head>
        <style>
          body {
            background: #CDE;
          }
          h1 {
            color: #0000FF;
            font-family: "Arial Black", Gadget, sans-serif;
          }
        </style>
      </head>
      <body>
        <h1>This is a string directly passed in to the block</h1>
        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Soluta, veritatis deserunt veniam optio minus natus quisquam, iusto dolor repellendus. Officia exercitationem vel, nisi mollitia eos maxime et est aspernatur quaerat!</p>

        <script>alert('Awesome!!!');</script>
      </body>
    </html>
  EOS
end

# Add the root route that displays params
get "/" do
  [200, {}, ["Your params are #{params}"]]
end

# Add a POST request route
post "/" do
  [200, {}, request.body]
end

# Print all the routes
ap app.routes

# Run the app using the server WEBrick that is built in to Ruby
Rack::Handler::WEBrick.run app, Port: 9292
