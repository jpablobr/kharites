require 'net/http'
require 'yaml'
require 'timeout'

module Kharites
  class Githubber

    def initialize(working_copy_path)
      remotes  = %x[cd #{working_copy_path}; git remote -v 2>&1] rescue nil
      return nil unless $?.success?
      origin = remotes.select { |l| l =~ /^origin.*/ }.first
      @user, @repo = origin.to_s.scan(/\S+[:\/]+?(\S+)?\/(\S+)?\.git$/).first
    end

    def revision(number=nil)
      return nil if number.nil? || @user.nil? || @repo.nil?
      info = execute( "commit/#{number}" )
      return nil unless info
      YAML.load(info)['commit'] rescue nil
    end

    private

    def execute(command)
      begin
        puts "* Executing command '#{command}' for the Github API"
        Timeout.timeout(35) do
          http = Net::HTTP.new("github.com", 80)
          response, content = http.get("/api/v1/yaml/#{@user}/#{@repo}/#{command}")
          content
        end
      rescue Exception => e
        puts "[!] Error when connecting to Github API (Message: #{e.message})"
        nil
      end
    end    
  end #Githubber

  if $0 == __FILE__
    g = Githubber.new({:user => 'jpablobr', :repo => 'Kharites'})
    puts g.revision('12956a3').inspect
  end
end #Kharites
