require "rack"

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

nancy = Nancy::Base.new

nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

puts nancy.routes

# run ruby nancy.rb
