require File.dirname(__FILE__) + "/spec_helper"

describe "Sales Site" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it "should respond to /" do
    get "/"
    last_response.should be_ok
  end

  it "should have an HTML homepage" do
    get "/"
    last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
  end

  it "should use the HTML5 doctype" do
    get "/"
    last_response.body.should match( %r{<!DOCTYPE html>} )
  end

  it "should have a favicon" do
    get "/"
    favicon = "public/favicon.ico"

    File.readable?(favicon).should be_true

    /#{favicon}: (.*)/ =~ `file #{favicon}`
    Regexp.last_match(1).should == "MS Windows icon resource - 1 icon"

    r = Nokogiri::HTML(last_response.body)
    r.xpath("html/head/link[@rel='shortcut icon']/@href").to_s.should == "/favicon.ico"
  end

  it "should be measured with the correct Google Analytics account" do
    get "/"
    last_response.body.should match( %r{google-analytics.com/ga.js} )
    last_response.body.should match( %r{UA-10596696-11} )
  end

  it "should return 404 for missing pages" do
    get "/this-page-does-not-exist"
    last_response.should_not be_ok
  end

end
