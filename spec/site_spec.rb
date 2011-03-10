require File.dirname(__FILE__) + "/spec_helper"

describe "Web Site" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it "should have a working HTML homepage" do
    get "/"
    last_response.should be_ok
    last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
  end

  it "should be in sexy HTML5" do
    get "/"
    last_response.body.should match( %r{<!DOCTYPE html>}i )
  end

  it "should have a favicon" do
    get "/"
    favicon = "public/favicon.ico"

    File.readable?(favicon).should be_true

    /#{favicon}: (.*)/ =~ `file #{favicon}`
    Regexp.last_match(1).should == "MS Windows icon resource - 1 icon"

    r = Nokogiri::HTML(last_response.body)
    r.xpath("html/head/link[@rel='shortcut icon']/@href").to_s.should match( %r{/images/favicon.png|/favicon.ico} )
  end

  it "should be measured with the correct Google Analytics account" do
    get "/"
    last_response.body.should match( %r{google-analytics.com/ga.js} )
    last_response.body.should match( /#{GA_ACCOUNT_ID}/ )
  end

  it "should return an error page when a missing page is requested" do
    get "/this-page-does-not-exist"
    last_response.should_not be_ok
    last_response.body.should match( %r{sorry|not found|missing}i )
  end

  it "should have a google sitemap with at least one page in it" do
    get "/google/sitemap.xml"
    last_response.should be_ok
    last_response.body.should match( %r{urlset}i )
    r = Nokogiri::HTML(last_response.body)
    r.xpath("//urlset/url/loc/text()").to_s.should match( %r{^http} )
  end

end
