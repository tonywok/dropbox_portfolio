source 'http://rubygems.org'

gem 'rails', "~> 3.1.0.rc"
gem 'jquery-rails'
gem 'haml'
gem 'devise'
gem 'dropbox'
gem 'carrierwave'
gem 'friendly_id', '~> 4.0.0.beta8'

group :assets do
  gem 'sass-rails', "~> 3.1.0.rc"
  gem 'coffee-rails', "~> 3.1.0.rc"
  gem 'uglifier'
end

group :development do
  gem 'haml-rails'
  gem 'sqlite3'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'capistrano'
end

group :test, :development do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'factory_girl_rails', :git => 'https://github.com/thoughtbot/factory_girl_rails.git'
end

group :test do
  gem 'dummy_dropbox'
end
