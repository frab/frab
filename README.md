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
Take a look at the [screenshots](https://github.com/frab/frab/wiki/Screenshots) to get an idea
of what frab does.

## Installing

frab is a pretty standard Ruby on Rails (version 4.2) application.
There should be plenty of tutorials online on how to install,
deploy and setup these.

See [installation](INSTALL.md) for more frab specific information.

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

### Create fake data

For development, it might be helpful to have some fake data around that allows for better testing.
The following command will create a bunch of tracks, persons and events in a random existing
conference. Call it multiple times if you need more records.

    rake frab:add_fake_data

You may also call the following tasks manually.

    rake frab:add_fake_tracks
    rake frab:add_fake_persons

## Ticket Server

frab supports OTRS, RT and Redmine ticket servers. Instead of sending
event acceptance/rejection mails directly to submitters, frab adds
a ticket to a request tracker.

The ticket server type can be configured for every conference.

The iPHoneHandle support needs to be installed in OTRS.


   rake frab:add_fake_events

## Contact

For updates and discussions around frab, please join our mailinglist

    frab (at) librelist.com - to subscribe just send a mail to it

## License

frab is licensed under an MIT-License. It bundles some
third-party libraries and assets that might be licensed
differently. See LICENSE.
