set :rvm_path, "/home/tonywok/.rvm"

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                               # Load RVM's capistrano plugin.

set :rvm_type, :user
set :rvm_ruby_string, '1.9.2'                          # Or whatever env you want it to run in.

require 'bundler/capistrano'

set :application, "Dropbox Portfolio"
set :repository, "git@github.com:tonywok/dropbox_portfolio.git"
set :deploy_to, "/var/www/dropbox_portfolio"
set :domain, "echo.agrieser.net"

set :scm, "git"
set :rake, "bundle exec rake"
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache

role :web, domain
role :app, domain
role :db, domain, :primary => true

set :rails_env, "production"
set :branch, "production"

before "deploy:restart", "assets:precompile"

namespace :assets do
  task :precompile, :roles => :web do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake assets:precompile"
  end

  task :cleanup, :roles => :web do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake assets:clean"
  end
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
