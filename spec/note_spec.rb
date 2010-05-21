require File.dirname(__FILE__) + '/spec_helper'

describe "Kharites" do
  include Rack::Test::Methods

  before do
    @note = Kharites::Note.new
  end

  def app
    @app ||= Sinatra::Application
  end

  it "can save itself (primary key is set up)" do
    @note.title = 'hello'
    @note.body = 'world'
    @note.save
    @note_test = Kharites::Note.last(:conditions => {:title => "hello"})
    @note_test.body.should == 'world'
  end

end
