[![Build Status](https://travis-ci.org/instedd/mbuilder.svg?branch=master)](https://travis-ci.org/instedd/mbuilder) [![Stories in Ready](https://badge.waffle.io/instedd/mbuilder.svg?label=ready&title=Ready)](http://waffle.io/instedd/mbuilder)

# mBuilder

[mBuilder](http://mbuilder.instedd.org) is an ideal tool if you need to build flexible SMS apps and don’t want to spend lots of time building something custom from scratch.

## Architecture

mBuilder is a Ruby on Rails application. It uses/depends on:

* **ruby** (= 2.0.0-p353) specified in `.ruby-version`
* **rails** (~> 3.2.17)
* **mysql** for storing applications logic
* **delayed_job** for running periodic tasks
* **elasticsearch** (>= 1.1) for storing application data
* **nuntium** for sending/receving sms messages. [more](http://nuntium.instedd.org)
* **guisso** (optional) in order to integrate with InSTEDD's Single Sign-On. [more](http://login.instedd.org)
* **resourcemap** (optional) in order to read/write data to resourcemap collections. [more](http://resourcemap.instedd.org)

## Setup

1. Checkout
2. Setup rails project as usual. `$ bundle && rails db:create db:schema:load`
3. Configure Nuntium (optional).
4. Configure Guisso

### Configure Nuntium (optional for dev)

A `config/nuntium.yml` already exists that uses a development account binding to nuntium.instedd.org . Usually this is enough for developping/testing mBuilder in an isolated scenario.

If you want to use a nuntium gateway **to send/receive real SMS** you will need to setup a nuntium application with a public mbuilder hostname. Or host your own Nuntium server.

### Configure Guisso

#### Guisso, Use InSTEDD Single Sign-On

A `config/guisso.yml` needs to be create. InSTEDD applications aim to work with a Single Sign-On servise at http://login.instedd.org . A `guisso.yml` can be downloaded after an application is configured at the Single Sign-On server.

**The most common scenario for development** is to setup an application with hostname `local.instedd.org:3000` and add the entry `127.0.0.1	local.instedd.org` to your `/etc/hosts`. This will allow cookies at `*.instedd.org` to be shared between login and mBuilder.

Yet mBuilder can be hosted with any hostname.

#### Use local stored users

All InSTEDD application are also able to run isolated from a login server. In this mode users are managed by [devise](https://github.com/plataformatec/devise)

## Development

### Docker development

`docker-compose.yml` file build a development environment mounting the current folder and running rails in development environment.

Run the following commands to have a stable development environment.

```
$ docker-compose run --rm --no-deps web bundle install
$ docker-compose up -d db
$ docker-compose run --rm web rake db:setup
$ docker-compose up
```

To setup and run test, once the web container is running:

```
$ docker-compose exec web bash
root@web_1 $ rake
```

## Deploy

powered by capistrano. `$ HOSTS=<server> cap deploy`.

Configuration files are symlinked in a shared path. check `symlink_configs` task.

## Intercom

mBuilder supports Intercom as its CRM platform. To load the Intercom chat widget, simply start mBuilder with the env variable `INTERCOM_APP_ID` set to your Intercom app id (https://www.intercom.com/help/faqs-and-troubleshooting/getting-set-up/where-can-i-find-my-workspace-id-app-id).

mBuilder will forward any conversation with a logged user identifying them through their email address. Anonymous, unlogged users will also be able to communicate.

If you don't want to use Intercom, you can simply omit `INTERCOM_APP_ID` or set it to `''`.

To test the feature in development, add the `INTERCOM_APP_ID` variable and its value to the `environment` object inside the `web` service in `docker-compose.yml`.