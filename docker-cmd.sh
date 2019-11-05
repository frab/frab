#!/bin/bash
set -e

echo "> Prepping '${RACK_ENV}' mode"
if [ $RACK_ENV == "production" ]
then
    echo "> assets:precompile"
    bundle exec rake assets:precompile

    if [ ! "$(rails db:version)" == "Current version: 0" ]
    then
        echo "> DB Migrate"
        bundle exec rails db:migrate
    else
        echo "> Setting up new db"
        bundle exec rails db:setup
    fi
elif [ $RACK_ENV == "development" ]
then
    echo "> bin/setup"
    ./bin/setup
fi

echo "> Starting server"
rm -f tmp/pids/server.pid
bundle exec rails server -b 0.0.0.0
