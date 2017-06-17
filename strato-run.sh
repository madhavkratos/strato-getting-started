#!/usr/bin/env bash

set -e

registry="registry-aws.blockapps.net:5000"

function wipe {
    echo "Stopping STRATO containers"
    docker-compose -p silo kill
    docker-compose -p silo down -v
}

function stop {
    echo "Stopping STRATO containers"
    docker-compose -p silo kill
    docker-compose -p silo down
}

case $1 in
 "-stop")
     echo "Stopping STRATO containers"
     stop
     exit 0
     ;;
 "-wipe")
     echo "Stopping STRATO containers and wiping out volumes"
     wipe
     exit 0
     ;;
   *)
     ;;
 esac
 
echo "
    ____  __           __   ___
   / __ )/ /___  _____/ /__/   |  ____  ____  _____
  / __  / / __ \/ ___/ //_/ /| | / __ \/ __ \/ ___/
 / /_/ / / /_/ / /__/ ,< / ___ |/ /_/ / /_/ (__  )
/_____/_/\____/\___/_/|_/_/  |_/ .___/ .___/____/
                              /_/   /_/
"

if ! docker ps &> /dev/null
then
    echo 'Error: docker is required to be installed and configured for non-root users: https://www.docker.com/'
    exit 1
fi

if ! docker-compose -v &> /dev/null
then
    echo 'Error: docker-compose is required: https://docs.docker.com/compose/install/'
    exit 2
fi

if grep -q "${registry}" ~/.docker/config.json
then
    export genesisBlock=$(< gb.json)
    export NODE_NAME=localhost
    export BLOC_URL=http://localhost/bloc/v2.1
    export BLOC_DOC_URL=http://localhost/docs/?url=/bloc/v2.1/swagger.json
    export STRATO_URL=http://localhost/strato-api/eth/v1.2
    export STRATO_DOC_URL=http://localhost/docs/?url=/strato-api/eth/v1.2/swagger.json
    export cirrusurl=nginx/cirrus
    export stratoHost=nginx
    export ssl=false
    docker-compose pull && docker-compose -p silo up -d
else
    echo "Please login to BlockApps Public Registry first:
1) Register for access to STRATO Developer Edition trial here: http://developers.blockapps.net/trial
2) Follow the instructions from the registration email to login to BlockApps Public Registry;
3) Run this script again"
    exit 3
fi
