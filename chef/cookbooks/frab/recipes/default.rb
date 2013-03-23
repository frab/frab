case node[:platform]
when "debian", "ubuntu"

  frab_folder = '/srv/frab'

  package "imagemagick"
  package "libsqlite3-dev"
  package "libmysqlclient-dev"
  package "libpq-dev"
  package "libxml2-dev"
  package "libxslt-dev"
  package "nodejs"
  package "git"
  package "ruby1.9.1-dev"
  
  execute "gem-bundler" do
    command "gem install bundler"
    action :run
  end

  execute "bundle-install" do
    command "bundle install"
    cwd frab_folder
    action :run
  end

  execute "db-config" do
    command "cp config/database.yml.template config/database.yml"
    cwd frab_folder
    creates 'config/database.yml'
    action :run
  end

  execute "frab-config" do
    command "cp config/settings.yml.template config/settings.yml"
    cwd frab_folder
    creates 'config/settings.yml'
    action :run
  end

  execute "db-setup" do
    command "rake db:setup"
    cwd frab_folder
    action :run
  end

end
