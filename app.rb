require "./nancy"

# Reference to a Nancy::Base object
app = Nancy::Application

#==> HOW TO RUN

# 1. Run `ruby nancy.rb`
# 2. Visit http://localhost:9292/hello                   => existent GET route
# 3. Visit http://localhost:9292/hola                    => non-existent GET route
# 4. Visit http://localhost:9292/?foo=bar&hello=goodbye  => show params
# 5. $ curl --data "body is hello" localhost:9292/       => POST route
# 6. Hit Ctrl-c to quit

#==> ROUTES

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
puts "Routes:"
ap app.routes

#==> SERVER

# Run the app using the server WEBrick that is built in to Ruby
Rack::Handler::WEBrick.run app, Port: 9292
