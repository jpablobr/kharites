# encoding: utf-8

%w{note article}.each { |f| require_relative 'lib/' + f }

set :authorization_realm, "Protected zone"

CONFIG = YAML.load_file('config/config.yml')
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://kharites.db")
DataMapper.auto_upgrade!

require 'yaml'

helpers do
  include Rack::Utils

  def markdown(text) Maruku.new(text).to_html end
  alias_method :md, :markdown

  def feed_url
    Kharites::Configuration.feedburner || '/feed'
  end

  def not_found
    File.read(File.join(Sinatra::Application.public, '404.html'))
  end

  def error
    File.read(File.join(Sinatra::Application.public, '500.html'))
  end

  def config
    Kharites::Configuration
  end

  def revision
    Kharites::Configuration.revision || nil
  end

  def authorize(login, password)
    login == Kharites::Configuration.admin.login &&
      password == Kharites::Configuration.admin.password
  end

  def url_for(obj)
    case obj
      when Kharites::Note then "#{obj.slug}"
    end
  end

  def reset_view
    set :views  => File.join(File.dirname(__FILE__), 'views')
    set :public => File.join(File.dirname(__FILE__), 'public')
  end
end

get '/' do
  reset_view
  @articles = Kharites::Article.all
  @notes = Kharites::Note.all
  @title = "#{Kharites::Configuration.kharites.title}"
  haml :index
end

get '/:article_slug' do
  @article = Kharites::Article.find_one(params[:article_slug])
  throw :halt, [404, not_found ] unless @article
  @title = @article.title +  ' ' + Kharites::Configuration.kharites.name
  set :views  => Kharites::Configuration.data_directory + "/" + @article.slug + "/views"
  set :public => Kharites::Configuration.data_directory + "/" + @article.slug + "/public"
  haml :index, :locals => {:article => @article}
end

get '/notes/archive' do
  reset_view
  @notes = Kharites::Note.all
  @title = Kharites::Configuration.kharites.title + ' ' +  "Archive"
  haml :archive, :locals => {:notes => @notes}
end

get '/past/:slug' do
  reset_view
  @note = Kharites::Note.last(:conditions => {:slug => params[:slug]})
  halt [ 404, "Page not found" ] unless @note
  @title = @note.title
  haml :note, :locals => {:note => @note}
end

get '/past/tags/:tags' do
  @tag = params[:tags]
  @notes = Kharites::Note.find(:all, :conditions => {:tags => /#{@tag}/i})
  @title = "Posts tagged #{@tag}"
  haml :tagged
end

get '/kharites/feeds' do
  @notes = Kharites::Note.all.order_by([[:updated_at, :desc]])
  content_type 'application/atom+xml', :charset => 'utf-8'
  builder :feed
end

### Notes Admin

get '/notes/login' do
  reset_view
  login_required
  redirect '/'
end

get '/notes/new' do
  reset_view
  login_required
  @note = Kharites::Note.new
  haml :edit,  :locals => {:note => @note, :url => '/notes'}
end

post '/notes' do
  login_required
  note = Kharites::Note.new(:title => params[:title],
                           :body => params[:body],
                           :created_at => Time.now,
                           :slug => Kharites::Note.make_slug(params[:title]),
                           :tags => params[:tags]
                           )
  note.save
  redirect "/past/#{url_for(note)}"
end

get '/past/:slug/delete' do
  reset_view
  login_required
  @note = Kharites::Note.last(:conditions => {:slug => params[:slug]})
  halt [ 404, "Page not found" ] unless @note
  haml :delete
end

post '/past/:slug/delete' do
  login_required
  @note = Kharites::Note.last(:conditions => {:slug => params[:slug]})
  halt [ 404, "Page not found" ] unless @note
  Kharites::Note.delete_all(:conditions => { :slug =>  params[:slug]})
  redirect '/'
end

get '/past/:slug/edit' do
  reset_view
  login_required
  @note = Kharites::Note.last(:conditions => {:slug => params[:slug]})
  halt [ 404, "Page not found" ] unless @note
  haml :edit, :locals => {:note => @note, :url => "/past/#{url_for(@note)}"}
end

post '/past/:slug' do
  login_required
  note = Kharites::Note.last(:conditions => {:slug => params[:slug]})
  halt [ 404, "Page not found" ] unless note
  note.title = params[:title]
  note.body = params[:body]
  note.slug = Kharites::Note.make_slug(params[:title])
  note.tags = params[:tags]
  note.save
  redirect "/past/#{url_for(note)}"
end

module Kharites
  class Configuration
    class << self
      def load
        raw_config = YAML.load_file('config/config.yml')
        @@config   = nested_hash_to_openstruct(raw_config)
      end

      def data_directory_path
        Pathname.new(data_directory)
      end

      def method_missing(method_name, *attributes)
        if @@config.respond_to?(method_name.to_sym)
          return @@config.send(method_name.to_sym)
        else
          super
        end
      end
    end

    private

    def self.nested_hash_to_openstruct(obj)
      if obj.is_a? Hash
        obj.each { |key, value| obj[key] = nested_hash_to_openstruct(value) }
        OpenStruct.new(obj)
      else
        return obj
      end
    end
  end
  Kharites::Configuration.load
end
