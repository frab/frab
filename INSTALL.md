## Development Setup

Basically, to get started you need git, ruby (>= 2.3) and bundler
and follow these steps:

1) Install nodejs:

frab needs a javascript runtime. You should use
nodejs, as it is easier to install than v8.

    apt-get install nodejs

2) Install Imagemagick:

This is a dependency of the paperclip gem. Imagemagick
tools need to be installed to identify and resize images.

Imagemagick should be easy to install using your OS's
preferred package manager (apt-get, yum, brew etc.).

3) Clone the repository

    git clone git://github.com/frab/frab.git

4) cd into the directory:

    cd frab

5) Modify settings:

Settings are defined via environment variables. frab uses dotenv files to
set these variables. The variables for development mode are set in `.env.development`.
You can also use `.env.local` for local overrides.

6) Run setup

    bin/setup

10) Start the server

To start frab in the development environment simply run

    rails server

Navigate to http://localhost:3000/ and login as
"admin@example.org" with password "test123".

## Vagrant Server

frab can more easily be tested by using vagrant with chef recipes taking care of the installation process.
More information can be found in these github projects:

* [frab/vagrant-frab](https://github.com/frab/vagrant-frab)
* [frab/chef-frab](https://github.com/frab/chef-frab)


## Production Deployment

1) Installing database drivers

Instead of running `bin/setup` you need to run bundle install manually, so
you can choose your database gems. To avoid installing database drivers you don't
want to use, exclude drivers with

    bundle install --without="postgresql mysql"

2) Create (and possibly modify) the database configuration:

    cp config/database.yml.template config/database.yml

3) Configuration

In Production make sure the config variables are set, copy and edit the file
`env.example` to `.env.production`.

4) Precompile assets

    rake assets:precompile

5) Security considerations

If you are running frab in a production environment you have to
take additional steps to build a secure and stable site.

* Change the password of the inital admin account
* Change the initial secret token
* Add a content disposition header, so attachments get downloaded and
are not displayed in the browser. See `./public/system/attachments/.htaccess` for an example.
* Add a gem like `exception_notification` to get emails in case of errors.

6) Start the server

To start frab in the production environment run

    RACK_ENV=production bundle rails s

Note that when seeding the database in production mode, the password for
admin@example.org will be a random one. It will be printed to the console
in when `rake db:seed` is invoked.

