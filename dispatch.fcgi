#!/usr/local/bin/ruby

$LOAD_PATH.push File.dirname(__FILE__) + '/vendor/rack/lib'
$LOAD_PATH.push File.dirname(__FILE__) + '/vendor/sinatra/lib'

require 'rack'

module Rack
  class Request
    def path_info
      @env["REDIRECT_URL"].to_s
    end
    def path_info=(s)
      @env["REDIRECT_URL"] = s.to_s
    end
  end
end

class SimpleHelloWorld
  def call(env)
    [ 200, { "Content-Type" => "text/html"}, "Hello World, I'm a Rackable application.\n" + "My env is:\n" + env.map{ |k,v| "#{k}:#{v}" }.join("<br/>")]
  end
end

load 'mini.rb'

builder = Rack::Builder.new do
  use Rack::ShowStatus
  use Rack::ShowExceptions

  map '/' do
    run Mini.new
  end
end

Rack::Handler::FastCGI.run(builder)