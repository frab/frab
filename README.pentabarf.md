# frab - pentabarf import

These notes may help to import data from a pentabarf postgresql database.

Using postgresql as a database for frab is still somewhat untested. The pentabarf 
import is however likely to fail, as pentabarf uses text fields instead of char(255)

Imagemagick needs to be installed as we will convert pjpeg and tiff to png.

## postgresql installation

Install postgresql

## postgresql setup

* make it listen on localhost
* create a psql user and grant some access on relations
* add a pentabarf entry for the postgresql database to your rails db environment

## postgresql copy

Make a copy of your postgresql database, as we need to do some changes

    pg_dump -Fc DBNAME > backup.dump
    createdb NEWNAME
    pg_restore -O -d NEWNAME backup.dump > /dev/null

## postgresql permissions

Grant all permissions on the database copy to the import user account:

    psql NEWNAME
    -- generate the grant statements
    select 'grant all on '||schemaname||'.'||tablename||' to frab;' from pg_tables  
      order by schemaname, tablename;
    -- copy&paste the generated statements into psql

    -- in case you re-created the NEWNAME copy, re-grant permissions to the user
    REVOKE ALL ON SCHEMA public FROM frab;
    GRANT ALL ON SCHEMA public TO frab;
    REVOKE ALL ON SCHEMA auth FROM frab;
    GRANT ALL ON SCHEMA auth TO frab;

## data migration

Conference acronyms need to be within /^[a-zA-Z0-9_-]*$/
Whitespaces are removed automatically, but you need to replace unicode characters manually.

    -- conference acronyms appear in URLs, they may not contain whitespace in frab:
    UPDATE conference SET acronym = replace(acronym, ' ', '');
    UPDATE conference SET acronym = 'mrmcdX' where conference_id=86; -- mrmcdⅩ

## import 

Delete any old mappings from previous imports. Maybe delete the old filess, too.

    rm tmp/*mappings.yml
    rm -fr public/system
    RAILS_ENV=production rake db:reset
    RAILS_ENV=production rake pentabarf:import:all

## testing

You can check on the barf data like this:

    RAILS_ENV="development" rails console
    @p = PentabarfImportHelper.new
    @barf = @p.instance_variable_get('@barf')
    @barf.select_all("SELECT * FROM conference")

## privileges

You maybe want to drop all users to the coordinator role, to start fresh.

User.all.select { |u| u.role == "admin" or u.role == "orga" }.each { |u| puts "dropping ${u.email}"; u.role = "coordinator"; u.save }


