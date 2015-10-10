# simple_rack_app

- For me to understand how Rack applications work by building a simple Sinatra-like Rack app.
- All is based on the article ["Let's Build a Sinatra"](https://robots.thoughtbot.com/lets-build-a-sinatra) by Gabe Berke-Williams. Thank you so much.

## Rack
- specifies a standard interface for Ruby webservers
- [Advanced Rack](http://gabebw.com/blog/2015/08/10/advanced-rack) by Gabe Berke-Williams

## Sinatra
- a layer on top of Rack
- DSL for specifying what a Rack app responds to, and what it sends back
- Enable us to quickly create web applications in Ruby 
- [source](https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb)

## cURL
- http://curl.haxx.se/docs/httpscripting.html

## Some Ruby techniques
### Hash#fetch
-[Hash#fetch vs.Hash#[]](http://stackoverflow.com/questions/16569409/fetch-vs-when-working-with-hashes)

### BasicObject#instance_eval
- Evaluates a string containing Ruby source code, or the given block, within the context of the receiver (obj). 
- [BasicObject#instance_eval](http://ruby-doc.org/core-2.2.0/BasicObject.html#method-i-instance_eval)
- [Writing a Domain-Specific Language in Ruby](https://robots.thoughtbot.com/writing-a-domain-specific-language-in-ruby)


