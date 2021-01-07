# frab - conference management system

frab is a web-based conference planning and management system.
It helps to collect submissions, to manage talks and speakers
and to create a schedule.

[![Build Status](https://travis-ci.org/frab/frab.svg?branch=master)](https://travis-ci.org/frab/frab)
[![Code Climate](https://codeclimate.com/github/frab/frab.png)](https://codeclimate.com/github/frab/frab)
[![Docker Build Status](https://img.shields.io/docker/build/frab/frab.svg)](https://hub.docker.com/r/frab/frab/)

## Current Status

frab is not under heavy development anymore.
[Releases](https://github.com/frab/frab/releases) merely mark huge updates and
add a changelog.  There are no separate release branches, fixes and development
happen in master.  We want the master branch to be usable at all times.

frab has been used to organize [FrOSCon](https://froscon.de) since 2011, a
conference with more than 100 talks (and as many speakers) in more
than 5 parallel tracks (plus devrooms) over 2 days.
frab is also used by the [Chaos Communication Congress](https://events.ccc.de).

The frab wiki hosts a [list of conferences using frab](https://github.com/frab/frab/wiki).
*Feel free to add your conference to the wiki*.

Take a look at the [screenshots](https://github.com/frab/frab/wiki/Screenshots)
to get an idea of what frab does. The [full
manual](https://github.com/frab/frab/wiki/Manual) can be found in the wiki.

## Installing

frab is a pretty standard Ruby on Rails application.
There should be plenty of tutorials online on how to install,
deploy and setup these.

See [installation](INSTALL.md) for more frab specific information.

It's possible to run frab via [docker](https://github.com/frab/frab/blob/master/README.docker.md), or on a [PaaS](https://github.com/frab/frab/blob/master/README.PaaS.md) like heroku or dokku.

## Rake Tasks

These are executed from the command line to export conferences and static
schedules, send emails or help with development.  The manual has a chapter on
[rake tasks for production](https://github.com/frab/frab/wiki/Manual#managing-frab-in-production).

More documentation on available [rake tasks](https://github.com/frab/frab/wiki/Rake%20Tasks) can be found in the wiki
or by running `rails -D`.

## Ticket Server

frab supports OTRS, RT and Redmine ticket servers. Instead of sending
event acceptance/rejection mails directly to submitters, frab adds
a ticket to a request tracker.

The ticket server type can be configured for every conference.

Install the iPHoneHandle support if you're using OTRS.

## History

frab was originally created for the organization of [FrOSCon 2011](http://www.froscon.de).
FrOSCon has previously used pentabarf (http://pentabarf.org), and although
frab is a completely new implementation, it borrows heavily from pentabarf.

Both FrOSCon and frab owe a lot to pentabarf. But sadly, pentabarf seems to
be abandoned. And several problems make it hard to maintain. Thus we decided
to create a new system.

## License

frab is licensed under an MIT-License. It bundles some
third-party libraries and assets that might be licensed
differently. See LICENSE.
