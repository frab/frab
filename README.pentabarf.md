# frab - pentabarf import

## postgresql installation

install postgresql

## postgresql setup

make it listen on localhost
create a psql user and grant some access on relations
add a pentabarf entry for the postgresql database to your environment

## postgresql copy
Make a copy of your postgresql database, as we need to do some changes

    pg_dump -Fc DBNAME > backup.dump
    createdb NEWNAME
    pg_restore -O -d NEWNAME backup.dump > /dev/null

## postgresql permissions

    psql cccv
    select 'grant all on '||schemaname||'.'||tablename||' to bar;' from pg_tables  
      order by schemaname, tablename;

## data migration

    -- conference acronyms appear in URLs, they may not contain whitespace in frab:
    UPDATE conference SET acronym = replace(acronym, ' ', '');
    UPDATE conference SET acronym = 'mrmcdX' where conference_id=86; -- mrmcdⅩ
