require 'rubygems'
require 'sinatra'
require 'bundler'
Bundler.require(:default)
Bundler.setup(:default)

set :authorization_realm, "Protected zone"

def load_or_require(file)
  (Sinatra::Application.environment == :development) ? load(file) : require(file)
end

%w{
  configuration 
  note
  githubber 
  article}.each { |f| load_or_require File.join(File.dirname(__FILE__), 'lib', "#{f}.rb") }

helpers do
  include Rack::Utils

  def markdown(text) Maruku.new(text).to_html end
  alias_method :md, :markdown

  def feed_url; Kharites::Configuration.feedburner || '/feed' end

  def not_found; File.read( File.join( Sinatra::Application.public, '404.html') ) end

  def error; File.read( File.join( Sinatra::Application.public, '500.html') ) end

  def config; Kharites::Configuration end

  def revision; Kharites::Configuration.revision || nil  end

  def authorize(login, password)
    login == Kharites::Configuration.admin.login && password == Kharites::Configuration.admin.password 
  end

  def hostname
    (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST'] 
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
end #helpers

### index

get '/' do
  reset_view
  @articles = Kharites::Article.all
  @notes = Kharites::Note.all
  @title = "#{Kharites::Configuration.kharites.title}"
  haml :index
end

### Articles

get '/:article_slug' do
  @article = Kharites::Article.find_one(params[:article_slug])
  throw :halt, [404, not_found ] unless @article
  @title = @article.title +  ' ' + Kharites::Configuration.kharites.name
  set :views  => Kharites::Configuration.data_directory + "/" + @article.slug + "/views"
  set :public => Kharites::Configuration.data_directory + "/" + @article.slug + "/public"
  haml :index, :locals => {:article => @article}
end

post '/github/sync' do
  throw :halt, 404 and return if not Kharites::Configuration.github_token or Kharites::Configuration.github_token.nil?
  unless params[:token] && params[:token] == Kharites::Configuration.github_token
    throw :halt, [500, "You did wrong.\n"] and return
  else
    # Synchronize articles in data directory to Github repo
    system "cd #{Kharites::Configuration.data_directory}; git pull origin master"
  end
end

### Notes

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

### SASS
use Hassle
