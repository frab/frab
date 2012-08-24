# frab - conference management system

frab is a web-based conference planning and management system. 
It helps to collect submissions, to manage talks and speakers 
and to create a schedule.

## Background

frab was created for the organization of FrOSCon 2011 (http://www.froscon.de).
FrOSCon has previously used pentabarf (http://pentabarf.org), and although
frab is a completely new implementation, it borrows heavily from pentabarf.

Both FrOSCon and frab owe a lot to pentabarf. But sadly, pentabarf seems to
be abandoned. And several problems make it hard to maintain. Thus we decided
to create a new system.

## Current status

frab is under heavy development. There is no stable release yet.
You may want to try to use frab regardless, but be warned, that it may
be a rocky ride.

That being said, frab has been used to organize several conferences,
including hundreds of talks, speakers etc. 

## Installing

frab is a Ruby on Rails (version 3.1) engine. Installation
requires Ruby (>= 1.9.2) and rails (~> 3.1.8).

Roughly, the following steps are necessary:

1) Create a new rails application:

    rails new <app_name> --skip-bundle

As a default, rails will pick sqlite3 as database. This can be
overriden with the -d parameter.

frab should work with all three built-in rails database drivers. 
But it is best tested with MySQL and SQLite3 (for development). 

2) Change into your app directory:

    cd <app_name>

3) Add this to your Gemfile:

    gem 'frab', :git => "git://github.com/oneiros/frab.git", :branch => 'engine'

4) Install all necessary gems:

    bundle install

5) Install Imagemagick:

This is a dependency of the paperclip gem. Imagemagick
tools need to be installed to identify and resize images.

Imagemagick should be easy to install using your OS's
preferred package manager (apt-get, yum, brew etc.).
 
6) Create and modify settings config/settings.yml.

See file config/settings.yml.template in the frab repository
for an example configuration.

7) Copy migrations to you applications:

    rake frab:install:migrations

8) Add seed data. Edit the file db/seeds.rb and add the following line:

    Frab::Engine.load_seed

9) Create and setup the database

    rake db:setup

10) Precompile assets (only needed for production)

    rake assets:precompile

11) Start the server

To start frab in the development environment simply run

    rails server

To start frab in the production environment make sure you
did not skip step 8 and run:

    rails server -e production

(Note that for a "real" production environment you
probably do not want to use this script, but rather something
like unicorn or passenger.)

Navigate to http://localhost:3000/ and login as 
"admin@example.org" with password "test123".

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

frab is licensed under an MIT-License. It bundles some
third-party libraries and assets that might be licensed
differently. See LICENSE.
