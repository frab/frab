# config valid only for current version of Capistrano
lock '3.4.1'

set :application, 'frab'
set :repo_url, 'https://github.com/frab/frab.git'

# Default branch is :master
set :branch, 'master'
set :user, ENV['CAP_USER']

set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :ssh_options,     forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub)
set :bundle_without, %w(capistrano development test postgresql sqlite3).join(' ')
set :linked_files, %w(config/database.yml .env.production .ruby-version)
set :linked_dirs,  %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)
