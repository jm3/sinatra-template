#!/usr/bin/env ruby

require 'bundler/setup'
require 'erb'
require 'haml'
require 'json'
require 'pony'
require 'rubygems'
require 'sinatra'
require 'sinatra/bundles'
require 'sinatra/content_for2'

stylesheet_bundle(:all, 'main')
enable(:compress_bundles)  # => false (compress CSS and Javascript using packr and rainpress)
enable(:cache_bundles)     # => false (set caching headers)

get '/' do
  @page_title = 'Some Cool Site'
  @override_css = true
  erb 'index'.to_sym
end

get '/', :agent => /iPhone/ do
  @page_title = 'Some Cool Site - iPhone version'
  @override_css = true
  @meta = '<meta name="viewport" content="width = 320" />'
  @iphone = true
  erb 'index'.to_sym
end

error 404 do
  haml :error, :layout => false
end

helpers do
  GIT_REVISION = %x[git reflog -n1 | awk \'{print $1}\'].gsub( /\.\.\./, '' )

  def cache_server
    rand(2) + 1
  end

  def stylesheet_tag( path )
    return "" unless path
    path = path.match('^/stylesheets/') ? path : '/stylesheets/' + path
    path = path.match('\.css$') ? path : path + '.css'
    uri = :development ? path : "http://cache#{cache_server}.jm3.net#{path}"
    "<link type=\"text/css\" href=\"#{uri}?#{GIT_REVISION.chomp}\" rel=\"stylesheet\" media=\"all\" />"
  end

  def img( uri )
    return "" unless uri
    "<img src=\"#{img_path(uri)}\" />"
  end

  def img_path( uri )
    return "" unless uri
    uri = uri.match('^/images/') ? uri : '/images/' + uri
    :development ? uri : "http://cache#{cache_server}.jm3.net#{uri}"
  end
end
