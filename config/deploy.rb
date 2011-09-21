require 'bundler/capistrano'

set :application, "Dropbox Portfolio"
set :repository, "git@github.com:tonywok/dropbox_portfolio.git"
set :deploy_to, "/var/www/dropbox_portfolio"
set :domain, "echo.agrieser.net"

set :scm, "git"
set :rake, "bundle exec rake"
set :deploy_via, :remote_cache

role :web, domain
role :app, domain
role :db, domain, :primary => true

set :rails_env, "production"
set :bundle_flags, "--deployment"
set :branch, "production"

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
