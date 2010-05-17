require 'rubygems'
require 'rake'
require 'ftools'

KHARITES_ROOT = '.'

%w{
  configuration 
  githubber
  article 
  note}.each { |f| require File.join(KHARITES_ROOT, 'lib', f) }

desc "Start application in development"
task :default => 'app:start'

namespace :app do

  desc 'Start application in development'
  task :start do
    exec "ruby kharites.rb"
  end
end

namespace :data do

  desc "Shortcut to sync data with Capistrano `$ cap data:sync`"
  task :sync do
    exec "cap data:sync"
  end
end

namespace :server do

  desc "Start server in production on Thin, port 4500"
  task :start do
    exec "thin --rackup config/config.ru --daemonize --log log/thin.log --pid tmp/pids/thin.pid --environment production --port 4500 start && echo '> Kharites started on http://localhost:4500'"
  end

  desc "Stop server in production"
  task :stop do
    exec "thin --pid tmp/pids/thin.pid stop"
  end

  desc "Restart server in production"
  task :restart do
    exec "thin --pid tmp/pids/thin.pid restart"
  end
end
