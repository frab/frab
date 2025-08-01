source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

install_if -> { RbConfig::CONFIG['target_os'] =~ /(?i-mx:bsd|dragonfly)/ } do
  gem 'rb-kqueue', ">= 0.2", platforms: :ruby
end


if ENV['CUSTOM_RUBY_VERSION']
  ruby ENV['CUSTOM_RUBY_VERSION'] # i.e.: '2.3'
end

gem 'rails', '~> 7.1.0'

# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'

gem 'mysql2', group: :mysql
gem 'pg', group: :postgresql
gem 'sqlite3', group: :sqlite3

# Use Puma as the app server
gem 'puma'

# Capistrano for deployment
group :capistrano, optional: true do
  gem 'capistrano', '3.16.0', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano3-puma',   require: false
end

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-migrate-rails'
gem 'jquery-ui-rails'
gem 'rangesliderjs-rails', '~> 2.3'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'activemodel-serializers-xml'
gem 'activeresource'
gem 'bcrypt'
gem 'bootsnap'
gem 'cocoon'
gem 'devise'
gem 'dotenv-rails'
gem 'haml'
gem 'http_accept_language'
gem 'invisible_captcha'
gem 'localized_language_select', github: 'frab/localized_language_select', branch: 'master'
gem 'mobility', '~> 1.2.2'
gem 'nokogiri'
gem 'omniauth-google-oauth2'
gem 'gitlab_omniauth-ldap'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'
gem 'kt-paperclip'
gem 'paper_trail'
gem 'prawn', '< 1.0'
gem 'prawn_rails'
gem 'pundit'
gem 'ransack'
gem 'redcarpet'
gem 'repost', '~> 0.4.1'
gem 'ri_cal'
gem 'roust', github: 'frab/roust', branch: 'disallowed-ticket-1-fix'
gem 'rqrcode'
gem 'scanf'
gem 'simple_form'
gem 'sucker_punch'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'will_paginate'
gem 'yard'

group :production do
  gem 'exception_notification'
end

group :productionplus, optional: true do
  gem 'activerecord-session_store'
  gem 'dalli'
end

group :development, :test do
  gem 'listen'
  gem 'bullet'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'letter_opener'
  gem 'faker'
  gem 'i18n-tasks'
  gem 'easy_translate'
end

group :test do
  gem 'rexml'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'

  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
end

group :doc, optional: true do
  # gem 'rails-erd'      # graph
  # gem 'ruby-graphviz', require: 'graphviz' # Optional: only required for graphing
end
