require 'rubygems'
require 'sinatra'
require 'sinatra/bundles'
require 'erb'
require 'config/content_for.rb'

# jm3: leave this disabled until we're farther along
# ASSET_PREFIX = :development ? '' : 'http://cache1.sciosecurity.com'
# re-open stylesheet_bundle_link_tag to add CDN support:
# module Sinatra
#   module Bundles
#     module Helpers
#       alias :old_stylesheet_bundle_link_tag :stylesheet_bundle_link_tag 
#       def stylesheet_bundle_link_tag(bundle, media = nil)
#         old_stylesheet_bundle_link_tag(
#           bundle, media = nil
#         ).gsub( /'/, '"' ).gsub( /href="\/stylesheets/, "href=\"#{ASSET_PREFIX}/stylesheets").gsub( /\?[0-9]+/, '' )
#       end
#     end
#   end
# end

stylesheet_bundle(:all, 'main')
# javascript_bundle(:all, 'zoom') # breaks zoom effect

enable(:compress_bundles)  # => false (compress CSS and Javascript using packr and rainpress)
enable(:cache_bundles)     # => false (set caching headers)

get '/' do
  if env['REQUEST_URI'].match( /cache/ )
    'not so much'
  else
    @page_title = 'Scio default page title' # FIXME
    @override_css = true
    erb 'index'.to_sym
  end
end

get '/', :agent => /iPhone/ do
  @page_title = 'Scio default page title' # FIXME
  @override_css = true
  @meta = '<meta name="viewport" content="width = 320" />'
  @iphone = true
  erb 'index'.to_sym
end

get '/iphone/?' do
  @page_title = 'Scio default page title' # FIXME
  @override_css = true
  @meta = '<meta name="viewport" content="width = 320" />'
  @iphone = true
  erb 'index'.to_sym
end

get '/google_sitemap/?' do
  content_type 'text/xml', :charset => 'utf-8'
  erb :google_sitemap, :layout => false
end

error 404 do
  erb :error
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

  def goog_date(file)
    # tag pages with their lastmod time from git for fairness
    if File.exists?(file)
      date = `git log #{file} | head -n3 | tail -n1`
      date = Time.parse( date.gsub( /Date:\s+/, '' ).chomp).utc.strftime("%Y-%m-%dT%H:%M:%S+00:00") if date
    else
      date = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    end
  end
end
