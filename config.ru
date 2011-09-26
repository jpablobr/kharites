# encoding: utf-8
require 'rubygems'
require 'bundler'

begin
  require 'bundler/setup'
  Bundler.require(:default)
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems."
end

require File.join(File.dirname(__FILE__), 'kharites')

set :environment, :production
disable :run

run Sinatra::Application
