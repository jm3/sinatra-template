set :application, "APPNAME"
set :deploy_to,   "/var/www/#{application}"
set :deploy_via,  :export
set :port,        22
set :repository,  "git@github.com:USERNAME/#{application}.git"
set :scm,         :git
set :use_sudo,    false

server "SERVERNAME_dot_com", :app, :web, :db, :primary => true

before "deploy:update", "git:uncommitted"
after "deploy", "deploy:cleanup"

deploy.task :restart, :roles => :app do
  run "touch #{current_path}/tmp/restart.txt"
  run "ln -s #{deploy_to}/shared/media #{current_path}/public/media"
end

namespace :git do
  desc "check for uncommitted files"
  task :uncommitted do
    output = `git status | egrep -i 'delete|modified|Untracked|branch is ahead'`
    set(:deploy_with_uncommitted_changes) { 
      Capistrano::CLI.ui.ask("You have uncommitted changes. Really deploy without your current changes? (Yn) ") 
    }
  end
end

# no code is faster than no code. - old Merb saying.
namespace :bundler do
  desc "Running bundler, installing gems, skipping development gems"
  task :install do
    run("cd #{release_path} && /usr/local/rvm/gems/ruby-1.8.7-p330/bin/bundle install --without=development production")
  end
end
after "deploy:update_code", "bundler:install"
