# frab - pentabarf import

These notes may help to import data from a pentabarf postgresql database.

Using postgresql as a database for frab is still somewhat untested. The pentabarf 
import is however likely to fail, as pentabarf uses text fields instead of char(255)

## postgresql installation

install postgresql

## postgresql setup

* Make it listen on localhost
* create a psql user and grant some access on relations
* add a pentabarf entry for the postgresql database to your rails db environment

## postgresql copy

Make a copy of your postgresql database, as we need to do some changes

    pg_dump -Fc DBNAME > backup.dump
    createdb NEWNAME
    pg_restore -O -d NEWNAME backup.dump > /dev/null

## postgresql permissions

Grant all permissions on the database copy to the import user account:

    psql cccv
    select 'grant all on '||schemaname||'.'||tablename||' to bar;' from pg_tables  
      order by schemaname, tablename;

## data migration

I had to delete some images, too.

    -- conference acronyms appear in URLs, they may not contain whitespace in frab:
    UPDATE conference SET acronym = replace(acronym, ' ', '');
    UPDATE conference SET acronym = 'mrmcdX' where conference_id=86; -- mrmcdⅩ

## import 


Delete any old mappings from previous imports. Maybe delete the old filess, too.

    rm tmp/*mappings.yml
    rm -fr public/system
    RAILS_ENV=production rake db:reset
    RAILS_ENV=production rake pentabarf:import:all


