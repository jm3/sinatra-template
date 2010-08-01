set :application, "scio.jm3.net"
set :repository,  "git@github.com:jm3/unnamed-mkting-site.git"
set :scm,         :git
set :deploy_to,   "/var/www/#{application}"
set :port,        9210
set :use_sudo,    false

server "jm3.net", :app, :web, :db, :primary => true

#before "deploy:update", "git:uncommitted"

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

