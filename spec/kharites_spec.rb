require File.dirname(__FILE__) + '/spec_helper'

describe "Kharites" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end
  
  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
  
  it "should return the correct content-type when viewing the root" do
    get '/'
    last_response.headers["Content-Type"].should == "text/html"
  end
  
  it "should return content when viewing the root" do
    get '/'
    last_response.headers["Content-Length"].to_i.should > 0
  end

  it "should be css in the headers when getting css" do
    get '/styles.css'
    last_response.headers["Content-Type"].should == 'text/css;charset=utf-8'
  end
  
  it "should respond to /style.css" do
    get '/styles.css'
    last_response.should be_ok
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end

end
