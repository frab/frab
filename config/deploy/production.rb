server ENV['CAP_SERVER'], roles: %w(app db web), primary: true, port: '22', user: ENV['CAP_USER']
set :user, ENV['CAP_USER']
set :deploy_to, ENV['CAP_PATH']
set :tmp_dir, ENV['CAP_TMP']
set :rvm_ruby_version, ENV['CAP_RUBY']
set :repo_url, ENV['CAP_REPO']
set :bundle_without, (%w(capistrano development test mysql postgresql sqlite3) - [ENV['CAP_DB']]).join(' ')
set :branch, ENV['CAP_BRANCH']
