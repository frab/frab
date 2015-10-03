# frab - conference management system

frab is a web-based conference planning and management system.
It helps to collect submissions, to manage talks and speakers
and to create a schedule.

[![Build Status](https://travis-ci.org/frab/frab.svg?branch=master)](https://travis-ci.org/frab/frab)
[![Code Climate](https://codeclimate.com/github/frab/frab.png)](https://codeclimate.com/github/frab/frab)

## Background

frab was originally created for the organization of [FrOSCon 2011](http://www.froscon.de).
FrOSCon has previously used pentabarf (http://pentabarf.org), and although
frab is a completely new implementation, it borrows heavily from pentabarf.

Both FrOSCon and frab owe a lot to pentabarf. But sadly, pentabarf seems to
be abandoned. And several problems make it hard to maintain. Thus we decided
to create a new system.

## Current Status

frab is under heavy development. There is no stable release yet.
You may want to try to use frab regardless, but be warned, that it may
be a rocky ride.

That being said, frab has been used to organize FrOSCon since 2011, a
conference with more than 100 talks (and as many speakers) in more
than 5 parallel tracks (plus devrooms) over 2 days.

The [frab wiki](https://github.com/frab/frab/wiki) hosts a list of conferences using frab.

## Installing

frab is a pretty standard Ruby on Rails (version 4.2) application.
There should be plenty of tutorials online on how to install,
deploy and setup these.

Basically, to get started you need git, ruby (>= 2.2) and bundler
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

### Production Environments

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

## Ticket Server

frab supports OTRS and RT ticket servers. Instead of sending
event acceptance/rejection mails directly to submitters, frab adds
a ticket to a request tracker.

The ticket server type can be configured for every conference.

The iPHoneHandle support needs to be installed in OTRS.

## Rake Tasks

### Export / Import conferences

Creates a folder under tmp/frab\_export containing serialized data and
all attachments:

    RAILS_ENV=production CONFERENCE=acronym rake frab:conference_export

Import a conference into another frab:

    RAILS_ENV=production rake frab:conference_import

### Sending Mails

    RAILS_ENV=production rake frab:bulk_mailer subject="Conference Invite" from=conference@example.org emails=emails.lst body=body.txt.erb

### Migrating from pentabarf

frab comes with a script that offers limited capabilities of
migrating data from pentabarf. For it to work, you need access
to pentabarf's database and configure it in config/database.yml
under the key "pentabarf".

Then simply run

    rake pentabarf:import:all

Please note, that the script has not been tested with HEAD
and will most probably not work. If you still want to try it
out, checkout the code at the revision the script was last
changed at and upgrade the code and migrate the database
from there.


## Vagrant Server

frab can more easily be tested by using vagrant with chef recipes taking care of the installation process.
More information can be found in these github projects:

* [frab/vagrant-frab](https://github.com/frab/vagrant-frab)
* [frab/chef-frab](https://github.com/frab/chef-frab)

## Contact

For updates and discussions around frab, please join our mailinglist

    frab (at) librelist.com - to subscribe just send a mail to it

## License

frab is licensed under an MIT-License. It bundles some
third-party libraries and assets that might be licensed
differently. See LICENSE.
