require 'uri' #heroku
require 'bundler'
Bundler.require(:default)
Bundler.setup(:default)

module Kharites
  class Note

    # TODO: move Mongo connections to config dir
    # Heroku http://docs.heroku.com/mongohq
    if ENV['MONGOHQ_URL']
      uri = URI.parse(ENV['MONGOHQ_URL'])
      Mongoid.database = Mongo::Connection.from_uri(ENV['MONGOHQ_URL']).db(uri.path.gsub(/^\//, ''))

    elsif ENV['DATABASE_HOST']
      Mongoid.database  = Mongo::Connection.new(ENV['DATABASE_HOST'] || 'localhost', ENV['DATABASE_PORT'] || 27017).db(ENV['DATABASE_DB'] || 'kharites')
      if ENV['DATABASE_USER'] && ENV['DATABASE_PASSWORD']
        auth = DB.authenticate(ENV['DATABASE_USER'], ENV['DATABASE_PASSWORD'])
      end

    else      
      Mongoid.database = Mongo::Connection.new(Configuration.mongodb.host,  Configuration.mongodb.port).db(Configuration.mongodb.db)
      Mongoid.database.authenticate(Configuration.mongodb.user, Configuration.mongodb.password)
    end

    include Mongoid::Document
    include Mongoid::Timestamps
    field :title, :type => String
    field :body, :type => String
    field :slug, :type => String
    field :tags, :type => String
    field :created_at
    field :updated_at

    def more?; summary != body end

    def slug; title.downcase.gsub /\W+/, '_' end

    def self.make_slug(title); title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_') end

    def summary
      if @summary ||= body.match(/(.{200}.*?\n)/m)
        "#{@summary.to_s.strip}....\"
      else
        body
      end
    end 
  end #Note
end #kharites
