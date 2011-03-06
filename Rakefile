require 'rake'
task :default => [:spec]

SKIP_REGEX="css|templates|modules|404.haml"

task :list_tasks do
  puts "Tasks:"
  puts "rake nometas: list views missing Meta Description blocks"
  puts "rake notitles: list views missing Title tags"
end

task :notitles do
  pages_missing_token( { :slug => "page_title", :name => "page titles"})
end

task :nometas do
  pages_missing_token( { :slug => "meta_desc", :name => "meta descriptions"})
end

task :spec do
  system("bundle exec rspec -c --colour --color --format nested spec/site_spec.rb")
end
  
def ghetto_round(num)
  (num* 100).round.to_i
end
  
def num_pages 
  `find views -type f | egrep -v "#{SKIP_REGEX}" | wc -l`.chomp.lstrip
end 

def pages_missing_token(token)
  pages_without_token = `grep -rL #{token[:slug]} views/* | egrep -v "#{SKIP_REGEX}" | wc -l`.chomp.lstrip
  percent = ghetto_round(pages_without_token.to_f/num_pages.to_f)
  puts "#{percent}% of views (#{pages_without_token} pages) were missing #{token[:name]}:"
  puts `grep -rL #{token[:slug]} views/* | egrep -v "#{SKIP_REGEX}"`
end
