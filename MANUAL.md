- [Introduction](#introduction)
  - [Background](#background)
  - [Opinionated Software](#opinionated-software)
  - [Wording](#wording)
- [Overview](#overview)
  - [Installation](#installation)
  - [Contributing](#contributing)
  - [Managing frab in Production](#managing-frab-in-production)
  - [Integration](#integration)
    - [Ticket Servers](#ticket-servers)
    - [Public Schedule API](#public-schedule-api)
    - [Private API](#private-api)
    - [User authentication](#user-authentication)
      - [Authenticate with Google](#authenticate-with-google)
      - [Authenticate with LDAP server](#authenticate-with-ldap-server)
      - [Granting administration rights to users from third-party services](#granting-administration-rights-to-users-from-third-party-services)
      - [Disabling frab's own username/password form](#disabling-frabs-own-usernamepassword-form)
      - [Importing profile image](#importing-profile-image)
- [Conference Crew / Admin](#conference-crew--admin)
  - [Organizer](#organizer)
    - [Setting Up a New Conference](#setting-up-a-new-conference)
      - [Timezone](#timezone)
      - [Timeslots](#timeslots)
      - [Event State Visible](#event-state-visible)
      - [File attachments](#file-attachments)
      - [Recording License](#recording-license)
      - [Reviewing](#reviewing)
      - [Misc. Features](#misc-features)
      - [Mails](#mails)
    - [Adding Crew Members](#adding-crew-members)
    - [Publishing Call for Participation](#publishing-call-for-participation)
    - [Reports](#reports)
    - [Feedback](#feedback)
    - [After the Conference](#after-the-conference)
  - [Coordinator](#coordinator)
    - [Accepting Talks](#accepting-talks)
    - [Event Details and Speaker Requirements](#event-details-and-speaker-requirements)
    - [Schedule](#schedule)
      - [Dynamic or Export](#dynamic-or-export)
    - [Track Speaker Attendance](#track-speaker-attendance)
  - [Reviewer](#reviewer)
- [Submitter](#submitter)
  - [Signing Up and Proposing an Event](#signing-up-and-proposing-an-event)
  - [Multiple submitters, speakers and assistants](#multiple-submitters-speakers-and-assistants)
- [Checklists](#checklists)
  - [Conference Setup](#conference-setup)
  - [Schedule Talks](#schedule-talks)
  - [Publish Schedule](#publish-schedule)

# Introduction

_frab_ is a web-based conference planning and management system. It helps to collect submissions, manage talks and speakers and create a schedule.


Amongst other features, _frab_ does:

* Manage multiple conferences
* Manage all the people involved in your conference
    * This includes (but is not limited to) speakers, moderators, staff etc.
    * You can reuse a person's details across all conferences
* Manage the individual events your conference is composed of (talks, workshops etc.)
    * Track an event's state from inception to final confirmation
    * Assign people to an event (speakers, moderators, etc.)
    * Print paper cards of your events for "offline" planning
* Conduct a call for participation
    * Collect submissions from prospective speakers
    * Let speakers enter their data themselves into a central database
    * Review and rate submissions
    * Select submissions and let speakers reconfirm their attendance with a single click
* Schedule events
    * Drag&drop events onto your schedule
    * _frab_ automatically checks for conflicts and gives you instant feedback
    * Export your schedule to different formats (HTML, PDF, iCalendar, xCal, pentabarf XML)
    * Use the online schedule or make a static export
    * Create custom PDF exports

## Background

_frab_ was originally created for the organization of FrOSCon 2011. FrOSCon has previously used pentabarf (http://pentabarf.org), and although _frab_ is a completely new implementation, it borrows heavily from pentabarf.

Both FrOSCon and _frab_ owe a lot to pentabarf. But sadly, pentabarf seems to be abandoned  and several issues make it hard to maintain. Thus FrOSCon decided to replace it and create a new system.

_frab_ was built with community conferences in mind. FrOSCon, as well as the CCC congress, are possible because of the huge numbers of volunteers. There is not a single person organizing the event, most tasks are handled by teams. That is why using a single spreadsheet did not work well in the past. Nowadays shared spreadsheets in the cloud are popular and are a helpful tool for organizing conferences. Still, for some conferences there are privacy concerns regarding shared spreadsheets as a service. Also _frab_ adds a lot of useful features over these all-purpose applications:

* Admin users or organizers create a new conference and publish a call for participation
* The crew optionally signs up and is assigned conference roles by organizers
* Speakers sign up and submit their presentations
* Groups of reviewers rate these submissions
* Organizers accept talks after the call for participation has ended
* Coordinators can optionally be assigned to events, which will handle all the interaction with the speakers
* Speakers confirm they are giving the talk
* Speakers can change their availability for the conference, upload slides, etc.
* Coordinators update event details and speaker requirements together with the speaker
* A public schedule is put together and published by the organizers
* Speaker attendance to the conference is being tracked by the speaker support team on site
* Anonymous feedback from visitors is collected for each talk

While _frab_ supports these tasks, it does not fully automate a conference. A lot of conversation is still necessary. This can be done from within _frab_, some conferences, however, integrate _frab_ with a ticket system.

[[images/Conference Scheduling.png|alt=Conference Sequence Diagram]]

## Opinionated Software

Historically _frab_ has been used by conferences which do not have a lot of funding and value privacy. They were not organized by event managers or individuals, but rather by teams of volunteers. It is the kind of conference where guest don't get a free T-Shirt, but rather buy one to support the event. There is no free catering, but there are also no keynotes by premium gold partners. Volunteers are available because entrance fees are low and a lot of the visitors use their vacation time to get there.

This is not to judge other kinds of conferences, but knowing the origins of _frab_ might give you a better understanding as to why some features can be easily done with _frab_, while other, seemingly obvious features are missing.

For example, access to software developers was not a huge problem for these conferences. That's why _frab_ exists within a rich software eco system.  There is no registration of visitors or payment system included. You cannot use _frab_ to hand out T-Shirts. Volunteers are not managed in _frab_. There is no mobile application included, etc.

But, here is a list of well known projects integrating with _frab_:

* Mobile fahrplan apps, display the program schedule in an app, some support personalized schedules
* [Typo3 public schedule](https://github.com/Starkmann/_frab__integration) replacement
* [halfnarp](https://github.com/erdgeist/halfnarp), a public survey tool to help with assigning time slots and rooms to events
* Conference ticket and T-Shirt sales software like [pretix](https://github.com/pretix/pretix)
* [engelsystem](https://github.com/engelsystem/engelsystem), used to manage helpers and assign shifts
* [VOC tracker](https://c3voc.de/wiki/c3tracker), which manages the actual recording, cut, encode and publishing of videos for the talk
* [voctoweb](https://github.com/voc/voctoweb), website for presentation of video recodings e.g. at https://media.ccc.de

Integration is mostly done via schedule exports to XML and JSON. However, some systems use xCal (engelsystem) or log into _frab_ directly and use the JSON output of the admin controllers (e.g. halfnarp).

## Wording

A `conference` consists of `events`. These `events` might be presentations, workshops or panels. Even if an event is really a mix of several methods, like a presentation with a question and answers session afterwards, it's only possible to select one event type. _frab_ does not handle event types differently. These `events` are held by `speakers`, which submitted their talk to a `call for participation` and got accepted by the organizing team of the conference.

It is a known problem that a conference is somehow also an event. A _frab_ event is more like a session. Historically, _frab_ inherited this naming scheme from pentabarf and session is a reserved word in Rails and is thus better avoided.

In the past the `call for participation` (CfP) was called "call for papers", but the broader term is now used consistently across _frab_.

A speaker's submission to a conference is like a proposal.

# Overview

_frab's_ web interface is split into four areas:

* Public conference overview page, where you sign up and look at call for participations
* Admin Interface for the crew
* Call for participation interface for submitting talks
* Visitors schedule view for a conference, if enabled

_frab_ can manage several conferences at once. The largest known _frab_ installation has over 80 conferences, however there are seldom more than three active at the same time.

Accounts are shared across the conferences inside one _frab_ installation. This allows conferences' crews to make decisions, for example about the acceptance of a submitted talk, based on previous experiences with a speaker. The collected data can also be used to contact speakers, i.e. to invite them to a follow up conference. However, mass-mailing operations always honor the speakers' setting for `email_public` and `include_in_mailings`.

While admin users have access to everything, crew users can only modify conferences they have been assigned to.
A crew user has a role for every conference, being either organizer, coordinator or reviewer. Without a role no access is possible.
However, access to speaker profiles is still possible for organizers of any conference. Only conference settings, reviews and events are access controlled. That is because an organizer needs to be able to add people to the conference, i.e. for events with multiple speakers, and could therefore easily circumvent any protection.

## Installation

_frab_ is quite a standard Ruby on Rails application. Running a Rails application server in production is a complex task, but there should be plenty of tutorials online for support.

_frab_ supports sqlite, MySQL and PostgreSQL databases. In production MySQL and PostgreSQL are recommended. Installing and configuring them works the same for all Rails applications.

Linux distributions might not offer the required Ruby version, as such it might be necessary to install it manually via `rvm` or similar Ruby managers. It is sufficient to install it only for the user running _frab_.

Most configuration is done via environment variables, which can be put in [env files](https://github.com/frab/frab/blob/master/.env.development).

_frab_ needs access to a mail server to send emails.

_frab_ can be deployed using Capistrano. Capistrano takes care of versioning releases, potentially handles rollbacks, compiles static assets, migrates the database on deployment and reloads the application server if the deployment was successful.

Rails is normally accessed through a web server like Apache or nginx. These provide SSL, caching and serve static assets without involving Rails. _frab_ is known to work well with passenger and puma. It is also possible to run _frab_ in the cloud via buildpacks on services like Heroku, Cloudfoundry, or self-hosted via `dokku`.

After you decided on a Rails stack and finished the deployment you can log in with `admin@example.org`.
The password for that will be a random one. It will be printed to the console, when `rake db:seed` is invoked.

For more specific instructions see the [installation document](https://github.com/frab/frab/blob/master/INSTALL.md) on the Github page.

## Contributing

Setting up a development environment is described on Github. _frab_ is a small project, so it might take a while for pull requests to get reviewed.
_frab_ is an opinionated software and features might not get merged, even if they are perfectly fine for other conferences. See Background for more information on the decisions leading to _frab_. If in doubt, open an issue first and start a discussion.

## Managing frab in Production

There are several `rake` tasks available which can assist you managing _frab_. They are executed from a command line on the server. For the Rails default `rake` tasks, like migrating the database and cleaning up temporary files, take a look at the upstream documentation.

* `frab:bulk_mailer` sends bulk mails. This action takes two arguments. A file name of a file containing one mail addresses per line and another file with mail content.
* `frab:conference_export` exports a _frab_ conference to `tmp/_frab__export`. It can then be imported on another server.
* `frab:conference_import` imports a previously exported conference. The import will merge the conference with existing data.
* `frab:scrub_conference` removes personal details for selected conference. This removes reviewer data and people not involved in any conference for some time, but a full schedule export is still possible afterwards.
frab `frab:scrub_conferences` scrubs personal details from all conferences which are older than three months.
* `frab:static_program_export` exports files for the public schedule to tmp/ directory. This includes all HTML, XML, CSS and event attachments and logos. The exported schedule can be copied to another web server.
* `frab:conference_export_attachments` exports all attachments from a _frab_ conference. By default, the conference data is written to `/tmp/attachments/<conference_acronym>/` as a bunch of archive files, partitioned by track and attachment type. It can be used to carry all the files to the conference location on removable media, as backup.
* `frab:video_import` imports video URLs for a conference from an URL. This is useful to display video players in the public schedule after a conference is over.
* `paperclip_migration:migrate` migrates paperclip storage to 3.x layout for old _frab_ installations.
* `rake pentabarf:import:all` imports data from existing pentabarf installations into _frab_.
* `frab:delete_removed_files` delete from disks any file attachments which were removed from the events <n> or more days ago. See "file attachments" below.


## Integration

### Ticket Servers

For some conferences _frab's_ integrated ticket system is not enough. It does not offer a message history, support for notes and it cannot escalate tickets.

Therefore _frab_ supports OTRS, RT and Redmine ticket servers. These can be configured separately for each conference under the conference settings.
Afterwards, accepting a talk will create a ticket, instead of sending a mail to the speaker. A link to the ticket is saved and the team can handle all the communication and email templating from the ticket system.

### Public Schedule API

Applications like mobile schedule viewers or schedulers for video recordings, mostly use the data formats provided by the public schedule export to interact with _frab_.

The public schedules contain these machine readable data files:

* `schedule.ics`: iCal for the whole conference
* `schedule.xcal`: xCal for the whole conference
* `schedule.xml`: based on pentabarf `schedule.xml`
* `schedule.json`: like the XML, grouped by day and room
* `events.json`: all the events
* `speakers.json`: all the speakers
* `events/*ics`: speparate ics for every event

There is an [experimental XML schema definition for the `schedule.xml`](https://github.com/frab/frab/wiki/images/schedule.xsd) in the wiki.
However, the source code might be easier [to read](https://github.com/frab/frab/blob/master/app/views/public/schedule/index.xml.haml).

### Private API

There are also applications like halfnarp who interface with the _frab_ endpoints directly, by logging in with username and password.

* GET /conferences
* GET /conferences/1
* GET /events
* GET /events/export_accepted
* GET /events/export_confirmed
* GET /events/1
* PUT /events/1
* GET /people
* GET /people/1
* GET /recent_changes/
* GET /statistics/language_breakdown
* GET /statistics/gender_breakdown
* GET /statistics/events_by_state

Most endpoints use the JSON format.
Take a look at the [source code](https://github.com/frab/frab/tree/master/app/controllers) for more information.

### User authentication

By default, _frab_ lets individuals register to the _frab_ website by providing a username and a password. Administrator can change that to support authentication via one or more third party services as well. A user which signed-up/logged in with any of the options enabled, can log in with any other authentication providers, providing the e-mail address used for log-in is the same. It is therefore the administrator's repsonsibility to only link to trustworthy providers.

If a user initially signed-up directly in with frab, then the same password will be available after logging in with other authatcation service. If she first logs in with a third-party service, then a new password is assigned (for log-in via the _frab_ form) but this password is never communicated to the user so it's effectively blocked. 

#### Authenticate with Google

You'll need to get from Google a Client ID and a Client Secret. The process is something like this:

1. Go to https://console.developers.google.com
2. Select your project.
3. Go to Credentials, then select the "OAuth consent screen" tab on top, and provide an 'EMAIL ADDRESS' and a 'PRODUCT NAME'

Then update the environment variables  `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.

#### Authenticate with LDAP server

LDAP integration is helpful when deploying _frab_ in an enterprise, where you don't want new users to remember another password. To enable Sign in with an LDAP server, populate the following environment variables:
* `NAME_FOR_LDAP=`  This name will appear in the _frab_ login screen, following  "Sign in". This overrides the language-dependent value defined in the locale. This is usually the enterprise name or the name of the organization managing the access.
* `LDAP_PROMPT_TITLE=` (optional) - This name will appear as the title in the LDAP credentials entry form. (i.e. `Enter your NASA username and password:`).
* `LDAP_HOST=`
* `LDAP_PORT=`
* `LDAP_METHOD=` One of: `plain`, `ssl`, `tls`.
* `LDAP_BASE_DN=`
* `LDAP_UID=` or `LDAP_FILTER=` - `LDAP_UID` indicates which LDAP field is used to search users.
    - Common values for enterprises are: `LDAP_UID=sAMAccountName` or `LDAP_UID=UserPrincipalName`
    - Commonly `LDAP_UID=uid` for OpenLDAP
    - You can also use LDAP_FILTER for more complex scenartios. Example: `LDAP_FILTER='(&(uid=%{username})(memberOf=cn=myapp-users,ou=groups,dc=example,dc=com))'`
* `LDAP_BIND_DN=` not needed if server allows anonymous access. This is the Distinguished Name of the user which will be used for binding and user lookup
* `LDAP_BIND_PASSWORD=` not needed if server allows anonymous access.

See https://github.com/omniauth/omniauth-ldap documentation for more details.

#### Granting administration rights to users from third-party services

After logging on once, the user account is created in _frab's_ database and then permissions and authorizations can be modified as usual, by an administration via the web UI. If _frab's_ username/password form is enabled, you can login with the `admin@example.com` account to gain admin rights; but this account is not available if the form is disabled. The initial admin users in this case should be provided via an environment variable. For example

`FRAB_EMAILS_OF_ADMINS=admin@mycompany.com,picard@enterprise.gov`

You should keep this list to a minimum, and log in immediately after setting up the system in production so that the accounts are not misused.

#### Disabling frab's own username/password form

You can disable _frab's_ own username/password form by specifying this environment variable:
`DISABLE_FRAB_DIRECT_LOGIN=1`

Note that once done, logging into _frab_ is only possible through a third-party service, so you should have an admin user which can be authenticated via third party service

#### Importing profile image

For some third party authentication providers, _frab_ can grab the user's profile image (avatar) too.

The environment variable `OVERRIDE_PROFILE_PHOTO` is used to configure priorities. If set, then the Google (or LDAP) image overrides _frab_ image on every login. If the environment variable is not set, then image is copied only if there's no avatar defined for the user.

# Conference Crew / Admin

If only one conference is managed in _frab_ or crews are not needed for another reason, just using the admin account will work the same.

Coordinators can also do anything that reviewers are allowed to do and organizers include all the rights of coordinators. Admins can do everything, ideally you have one admin account, a few organizers for every conference, a bunch of coordinators to handle speakers and a lot of reviewers to select the best talks.

But you can really run _frab_ with just one admin account if you like, you might even want to enter all the talks manually for small conference or when your speakers are hesitant to use web applications.

## Organizer

### Setting Up a New Conference

To create the conference only the acronym and the title are needed.
The acronym will be used as a slug in the URL and be used frequently to identify the conference.

Most fields are explained in the conference edit form or are self-explanatory.
The conference can be edited all the time, there is no locking. Eventually rooms and days will need to be added: Rooms can be added at a later stage, before scheduling accepted talks for example. The days, however, are necessary, without them speakers cannot input their availability.

After changing these settings, create a CfP to make the conference public and have speakers submit events.

[[images/Conference Settings.png|alt=Conference Settings]]

#### Timezone

The timezone setting will be used throughout _frab_ to display times, which means _frab_ will not use the browser's locale to display times in the visitor's time zone.

#### Timeslots

Events are scheduled at fixed times throughout the day.
The timeslot duration defines the minimal duration for an event. In the schedule's day view, timeslots are rows.
The default timeslots number will be used for all new events, but speakers can select a different duration, if enabled (or "allowed") in the conference settings page.

Timeslot duration is tricky and cannot be easily changed once you scheduled accepted talks, so give this some thought. In general, larger timeslots make things a lot simpler, but smaller ones make you more flexible. For example: If all you need is to schedule 30 minute talks that perfectly align with full and half hours, choose 30 minutes as slot size. If you have talks that last for one hour and have 15 minute breaks between them, then 15 minutes is the perfect slot size. Note that you can make the slot size smaller later on, as long as the old slot size is a multiple of the new one. So going from 15 minutes down to 5 is fine, while going down to 10 minutes will not work.

As a coordinator you may want to discuss with the speaker if the talk's duration is adequate for the topic.

#### Event State Visible

Once a talk has been accepted, speakers can see it in the CfP interface and confirm that they will give the talk. However, some conferences do not want speakers to know before the initial announcement of the schedule, which makes sense when you are discussing talks for two days and need to revisit some decisions from day one. Since accepting is instant, this causes confusion amongst speakers, if they are watching.

You can safely toggle this one back to 'visible', after announcing to make the confirm button re-appear in the CfP interface.

#### File attachments

Submitters (and crew) can attach files to their event submissions. When uploading, each attachment can be described with a "title". By default, this title can be anything. However, if you turn off "Attachment title is freeform" option, then attachment types are reduced to a drop-down list. This can be used to enforce uniformity and clear communications with event owners. Crew can also inspect attachments vertically (by selecting Events --> Attachments from the top navigational bar) to make sure all events have relevant material in a timely manner - or contact event owners if attachments are missing.

If the environment variable `FRAB_PRESERVE_FILE_ATTACHMENTS` is set to `1`, _frab_ will not delete a file attachment when it is removed from an event by a submitter or crew. The former attachment will still be accessible to admins via the history views. To delete all such files from disk (to reclaim disk space and respect submitters' expectation of privacy), admin can use rake `frab:delete_removed_files` which will remove all files which were deleted more than a specified number of days ago.


#### Recording License

This field is only important if you are recording the events. It is currently only used in the public XML/JSON exports.

#### Reviewing

By default, each reviewer is asked to provide a rating for each submission, ranging from 1/2 a star to 5 stars; plus a text comment. Organizer can ask reviewers to grade also specific aspects of each submission while reviewing, such as: applicability to specific audiences. Organizer do that by adding "review metrics" through the Conference Settings' Reviewing tab.

#### Misc. Features

* The feedback interface allows visitors to rate a talk after attending it. The rating and feedback is visible to the speaker. Enable this one once the conference has started.

* Expenses enabled: If you enable this, _frab_ will allow you to track expenses of people. Otherwise the crew will have to discuss expenses individually with speakers.


#### Mails

If you selected the integrated mailer or enabled "bulk notifications", the conference settings will have an additional tab to edit 'notifications'.

These notifications can be used to inform speakers about acceptance/rejectance/scheduling of their events.

The templates support variable substitution, for example to address speakers by name. To fill in the default texts, first click on `Add Notification`, select your locale and click the `default text` button on the right.

With bulk email enabled, these mails will be sent automatically when the event changes.

If you want to send a mail to a certain group of speakers, like speakers from all scheduled talks, use the `Mail Templates`, which are found in the top navigation. Please note the template system works different from the one in `conference`/`notifications`.

Crew can assign a "BCC address" for each conference. If assigned, a "Blind Carbon Copy" of each e-mail generated by _frab_ will be sent to that address too. This can be used as a log or an index for the e-mails sent by the system.

### Adding Crew Members

[[images/Edit Account.png|alt=Edit Account]]

To add crew members create a person with email and name, then on the person page enter a password on the "User account" tab. Set the "role" radio button to "crew". After saving you can edit the user again to change the specific role for the conference.

It is easier to have users sign up through the main page themselves and edit their user accounts crew and conference role afterwards. Then the user can pick their own password and fill out the profile, you will need the email address used for signing up to find the account and add it to the conferences' crews.

### Publishing Call for Participation

Publishing a call for participation (CfP) makes the conference publicly visible on the start page.
While users can sign up any time, submitting talks is only possible after the configured start date has been reached.
The configured end date is displayed, but submissions are possible until the hidden `hard deadline` is reached.

The link displayed on the admins CfP page can be used for announcements, i.e. by mail. It leads directly to the conferences CfP page.
If the CfP has a welcome text, a link to the CfP page will also be on _frab's_ main page.

While the CfP is running, logged-in users can use the 'participate' button to get involved in the conference. The button will still appear after the CfP ends for users actually involved in the conference.

Since speakers will start to submit talks now, make sure the conference settings are in order:

* **Days** as intended, as they'll be used as a base for speaker availability
* **Timeslots**, speakers will enter their preference
* **Timezone** of the conference
* **Additional features** which influence the submission forms, like expenses are toggled
* If event state is **visible** under conference settings, every change you do to the state of the event will be visible to the speaker
* Emails might get sent if you enabled the **bulk mailer**

While waiting for the submissions to come in, you can watch the graphs on the CfP page. Since speakers tend to submit their talks close to the end date, the graph often increases dramatically in the last days of the CfP.
So don't worry if the graph looks like this:

[[images/events_cum.png|alt=Cumulative number of conference events]]

### Reports

There are several reports which can help with finding outstanding work.

[[images/Available Reports.png|alt=Available Reports]]

### Feedback

After the first events have started, you can enable 'feedback' in the conference settings. The new schedule will have feedback links included.

The collected feedback is anonymous. The speaker can see the feedback, including the texts.

### After the Conference

Once the speakers submitted all their slides, publish the schedule one last time.

## Coordinator

Coordinators can optionally be assigned to events. Since there are usually a lot of speakers, a special role was necessary to handle all interaction with the speakers. However, this involves several privileged operations, giving the coordinator access to nearly all the data in stored _frab_.

### Accepting Talks

The coordinator can accept talks. After agreeing on the talks for the conference, for example during a in person content meeting, coordinators are assigned to talks. Thereafter coordinators start clicking the accept and reject buttons, which may result in emails to the submitters.

The content of the these mails can be configured in the conference settings below `notifications` by the conference orga.

If a ticket server has been configured instead, coordinators might have to log in to that application to send individual mails to speakers. This usually involves filling out templates and adding a conference footer to the mail. If the accept and reject buttons are used, the ticket will be created empty and linked from _frab_.

Other conference just subscribe all their accepted speakers on a mailing list and use that for communication. In that case, do not configure any mail and use the 'no email' buttons.

### Event Details and Speaker Requirements

Once speakers confirm that they give the talks, coordinators should start to look at the submission content:

* Have the speakers entered their availabilities?
* Is the talk in the right track? Organizers' and speakers' ideas about what a track is about often differ.
* Is the title of the talk good and suitable? For example it is a good idea to have the title in the same language as the actual talk.
* Are all speakers of the talk present in the submission of the event?
* Agree on a duration for the talk with the speakers. How much of it is presentation, how much discussion?
* Does the speaker need reimbursement, i.e. for travel or accommodations?
* Does the speaker need transportation, i.e. if you have a shuttle bus to the conference?
* Is a laptop, adapter or video camera necessary for the talk, or are extra microphones required? You can write related information in the `tech_rider` field in the event page.
* Each event has room for `submission_notes`, which are visible to the submitter and to the organizing crew; and room for admin `notes`, which are only visible to the organizing crew. The latter can be useful to log decisions in the selection process, for example.

If the `event_state_private` conference setting is enabled, the speaker will not get any clue from the CfP interface about the acceptance/rejectance of the talk. Coordinators are even more important then.

Basically the data on the submission should be in a state in which the schedule can be presented publicly.


### Schedule

[[images/Build Schedule.png|alt=Scheduling Talks]]

After clicking on a time slot the list of accepted talks opens. After picking a talk it can be moved around by drag and drop.

Talks are colored according to their state:

* A green talk will be in the public schedule.
* A yellow talk is not ready yet, maybe a speaker is not available or did not commucate her availablity or is already talking at the same time in another room. You can right click the event name and select "open in a new tab" to see details of the warning cause. Yellow talks will be missing from the public schedule.
* A talk is indicated in red in case it conflicts with another talk in the same room

Sometimes it is helpful to reload the drag'n'drop interface if it behaves out of order.

The current state of the schedule, as it would look like in the public version, can be visited by clicking on the 'preview schedule' button. If the public schedule is enabled in the conference settings, this is already the live version.

#### Dynamic or Export

For security and performance reasons it is recommended to keep the dynamic schedule private and instead export static files by clicking "publish HTML export". The HTML export can be put on any web server.

If _frab_ renders the public schedule, dynamically it is recommended to activate caching, i.e. by using an nginx in front of _frab_. Besides caching the public schedule, nginx should also be configured to serve the public assets from _frab_. Like that the application server does not block if visitors download presentation slides and images.

Security-wise, serving user content like slides and example files from presentations below the application domain imposes a security risk. For example, if a browser would ignore the content disposition header, a malicious javascript attachment uploaded by a speaker, could read _frab's_ cookies and act on behalf of the, potentially, logged-in user.

To make use of the static export, the _frab_ admin needs to fill out the fields below "conference/settings/schedule".
The full URL of the site serving the static export is required for feedback QR codes to work.
The custom CSS will be applied after the default schedule CSS.

### Track Speaker Attendance

It is important to know if a speaker is really at the conference. To track that, for example by a speaker support team at the conference, there is an 'attendance' button on the speakers details page.

There is also a report of all "missing" speakers.

## Reviewer

Conferences often get twice as many submissions as they have slots in their schedule.
By rating submissions and commenting on them, reviewers help the crew to pick the right talks for the conference.

The review is visible to the conference crew, but not to the submitter of a talk.

Reviewers don't have many privileges, but they are allowed to see person details and event submissions, so they can come up with a well-founded review.

By default, the review includes a star rating and an optional text message. Optionally, the conference organizers can add specific review metrics which would be rated on a 1 to 5 scale too.

# Submitter

Submitters sign up to enter a proposal for a talk or event. They can submit to every open call for participation. They find the call for participation by following a provided link or from the main page of _frab_. If the deadline has been reached, the CfP will no longer be linked from the main page.

## Signing Up and Proposing an Event

_frab_ accounts are identified by their email address. After creating the user account through sign up, log in is possible. The speaker will be directed to the personal details form first.

The information from this form will be used for the speaker page in the public schedule.

Submitted events go through review and can be accepted or rejected by the conference organizers.

Once the talk is accepted, the speaker can change the availability for the conference, upload slides, etc.

If the talk has been accepted, the interface can be used to confirm that the talk will be given.

Changing data in _frab_ does not alert the organizers of the conference. Speakers will still have to contact the crew, to notify them of last minute changes and the like.

## Multiple submitters, speakers and assistants

During the call for participation period, the event submitter can invite others to join as speakers to the event. The submitter would open the event details page, scroll to the bottom of the page and find an "invitation token" URL link, which she or he can send to prospective co-speakers. The co-speaker would open that URL link, sign-up to frab, and be added to the event. In the same way, submitters can invite others to join as "assistants". An assistant is notified by e-mail whenever the event is changed, and they have the same permissions as submitter and speaker. However, the availability of assistants is not taken into account when scheduling.

Coordinators can do the same; and they can also manually add and remove speakers from the event's "Edit People" page, even after the call for participation window is over.

# Checklists

## Conference Setup

What is required to start receiving submissions?

* Timezone
* Timeslots and duration
* Days
* Accepted event types
* Tracks (optionally)
* Recording license (optionally)
* Launch CfP and publish URL

## Schedule Talks

What is needed for talk to be schedulable?

* Confirmed talk
* Speakers entered availabilities
* Speakers confirmed
* No conflicts

## Publish Schedule

* Conference has days and rooms
* Event is public
* Schedule export needs base URL