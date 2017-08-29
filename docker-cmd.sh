#!/bin/bash
set -e

echo "> Prepping '${RACK_ENV}' mode"
if [ $RACK_ENV == "production" ]
then
    echo "> assets:precompile"
    rake assets:precompile

    if [ ! "$(rails db:version)" == "Current version: 0" ]
    then
        echo "> DB Migrate"
        rails db:migrate
    else
        echo "> Setting up new db"
        rails db:setup 
    fi
elif [ $RACK_ENV == "development" ]
then
    echo "> bin/setup"
    ./bin/setup
fi

echo "> Starting server"
rm -f tmp/pids/server.pid
rails server -b 0.0.0.0
