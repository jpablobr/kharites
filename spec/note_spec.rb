require File.dirname(__FILE__) + '/spec_helper'

describe "Kharites" do
  include Rack::Test::Methods

  before do
    @note = KHARITES::Note.new
  end

  def app
    @app ||= Sinatra::Application
  end

  it "produces html from the markdown body" do
    @note.body = "* Bullet"
    @note.body_html.should == "<ul>\n<li>Bullet</li>\n</ul>"
  end

  it "can save itself (primary key is set up)" do
    @note.title = 'hello'
    @note.body = 'world'
    @note.save
    @note_test = KHARITES::Note.last(:conditions => {:title => "hello"})
    @note_test.body.should == 'world'
  end

end
