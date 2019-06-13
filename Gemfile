source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.1"

gem 'dotenv-rails'
gem "rack"
gem "loofah"
gem 'rails', '5.2.2.1'

gem 'sass-rails'
gem 'sassc-rails'
gem 'bootstrap-sass'
gem 'uglifier'
gem 'jquery-rails'
gem 'webpacker'
gem 'webpacker-react'
gem 'jbuilder'
gem 'sdoc', group: :doc

gem 'bcrypt'

gem 'foreman'
gem 'passenger'
gem 'kaminari'
gem "groupdate", "3.2.1"
gem 'calculate-all'
gem "pg"
gem "pg_histogram"
gem 'postgres_ext', github: 'cerebris/postgres_ext', branch: "rails-5"
gem "font-awesome-rails"
gem 'sinatra', :require => nil
gem "sidekiq"
gem "redis-namespace"
gem "activerecord-import"
gem "app_perf_rpm"
gem "app_perf_agent"
gem 'faker'
gem "msgpack"
gem "haml"
gem "devise"
gem "devise_invitable"
gem 'oj'
gem 'roda'
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'sqlite3'
  gem 'pry'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov', :require => false
end
