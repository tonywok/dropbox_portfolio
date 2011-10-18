set :rvm_path, "/home/tonywok/.rvm"

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                               # Load RVM's capistrano plugin.

set :rvm_type, :user
set :rvm_ruby_string, '1.9.2'                          # Or whatever env you want it to run in.

require 'bundler/capistrano'

set :application, "Dropbox Portfolio"
set :repository, "git@github.com:tonywok/dropbox_portfolio.git"
set :keep_releases, 7

set :deploy_to, "/var/www/dropbox_portfolio"
set :domain, "echo.agrieser.net"

set :scm, "git"
set :git_enable_submodules, 1
set :rake, "bundle exec rake"
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache

role :web, domain
role :app, domain
role :db, domain, :primary => true

set :rails_env, "production"
set :branch, "production"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :uploads do
  desc "Creates the portfolio folders unless they exist, sets permissions"
  task :setup, :except => { :no_release => true } do
    dirs = uploads_dirs.map { |d| File.join(shared_path, d) }
    puts "*" * 100
    puts dirs
    puts "*" * 100
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
  end

  desc "Creates the symlink to portfolio shared folder for most recent version"
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/public/portfolio"
    run "ln -nfs #{shared_path}/portfolio #{release_path}/public/portfolio"
  end

  desc "Computes uploads directory paths and registers them in Capistrano environment"
  task :register_dirs do
    set :uploads_dirs,    %w(portfolio)
    set :shared_children, fetch(:shared_children) + fetch(:uploads_dirs)
  end

  after       "deploy:finalize_update", "uploads:symlink"
  on :start,  "uploads:register_dirs"
end
