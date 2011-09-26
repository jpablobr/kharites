# encoding: utf-8
require 'uri'
module Kharites
  class Note
    include DataMapper::Resource

    property :id,         Serial
    property :slug,       String
    property :tags,       String
    property :created_at, DateTime
    property :updated_at, DateTime
    property :body,       Text, :required => true
    property :title,      String, :required => true, :length => 32

    def more?
      summary != body
    end

    def slug
      title.downcase.gsub /\W+/, '_'
    end

    def self.make_slug(title)
      title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
    end

    def summary
      if @summary ||= body.match(/(.{200}.*?\n)/m)
        "#{@summary.to_s.strip}...."
      else
        body
      end
    end
  end
end
