#!/bin/sh
docker-compose pull
docker-compose build
docker-compose up -d db
docker-compose run --rm --no-deps web bundle install
docker-compose run --rm web bash -c 'rake db:setup db:seed'
