set :application, 'frab'
set :repo_url, 'https://github.com/frab/frab.git'

# Default branch is :main
set :branch, 'main'
set :user, ENV['CAP_USER']

set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :ssh_options,     forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub)
set :bundle_without, %w(capistrano development test postgresql sqlite3).join(' ')
set :linked_files, %w(config/database.yml .env.production .ruby-version)
set :linked_dirs,  %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system app/views/custom)

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute "touch #{current_path}/tmp/restart.txt"
    end
  end

  after :finishing, :restart
end
