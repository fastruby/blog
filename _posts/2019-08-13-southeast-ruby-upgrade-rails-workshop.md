---
layout: post
title:  "How to Upgrade Any Rails Application Using Docker"
date: 2019-08-13 12:00
categories: ["rails", "upgrades"]
author: "etagwerker"
---

Every time we start a new [Rails upgrade project](https://fastruby.io/roadmap),
we need to setup a whole new environment in our local machines. Sometimes that
leads us down the rabbit hole which ends up breaking our environment for other
client projects.

After years [upgrading Rails applications](https://fastruby.io/blog/tags/upgrades),
we learned that the best way to isolate our client projects' environments is
using [Docker](https://www.docker.com).

That's why we decided to use Docker and [docker-compose](https://docs.docker.com/compose/)
for all of our client projects. This year I had the opportunity to share our
process in a series of workshops:
[Upgrade Rails 101: The Roadmap to Smooth Upgrades](https://speakerdeck.com/etagwerker/upgrade-rails-101-the-roadmap-to-smooth-upgrades-southeast-ruby-19)

<!--more-->

A couple of weeks ago I ran the latest iteration of our workshop at [Southeast Ruby '19](https://2019.southeastruby.com). I showed what it would look like if we were to upgrade
the [e-petitions](https://github.com/alphagov/e-petitions) application.

In order to set up all the services I used this `docker-compose` configuration:

```yaml
version: "2"

services:
  cache:
    image: memcached:1.4-alpine
    ports:
      - "11211:11211"
    restart: always

  db:
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD:
    image: postgres:9.6
    expose:
      - "5432"

  app:
    stdin_open: true
    tty: true
    restart: always
    env_file: .env.test
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
      - cache
    volumes:
      - .:/usr/src/app:consistent
```


This application uses [Memcached](https://memcached.org/);
[Postgres 9.6](https://www.postgresql.org/docs/9.6/index.html);
Ruby 2.3.8; and
Rails 4.2. That's why you will find these services in its [`docker-compose.yml`](https://github.com/fastruby/e-petitions/blob/0-docker/docker-compose.yml):

- `db` (Postgres)
- `cache` (Memcached)
- `app` (Rails 4.2)

In order to setup the app service, I defined a [`Dockerfile`](https://github.com/fastruby/e-petitions/blob/0-docker/Dockerfile) like this:

```Dockerfile
FROM ruby:2.3.8-jessie

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends \
    build-essential \
    postgresql-client-9.6 \
    nodejs \
    vim \
    libpq-dev \
    qt5-default \
    libqt5webkit5-dev \
  && apt-get -q clean
RUN apt-get update

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v=1.17.3

RUN bundle install

COPY . .
```

As every other Rails application, it is not 100% standard. For instance, to
setup the database you need to load the `structure.sql` file. So I decided to
write a quick script (`bin/docker-setup`) to setup the test database:

```
#!/usr/bin/env ruby
require 'pathname'

# path to your application root.
APP_ROOT = Pathname.new File.expand_path('../../',  __FILE__)

Dir.chdir APP_ROOT do
  puts "== Creating databases =="
  system "rake db:create"
  system "psql -q -h db -U postgres -f db/structure.sql epets_test"
end
```

That way, if you want to build the services you can just do this:

```bash
docker-compose up -d
docker-compose exec app ./bin/docker-setup
```

Taking this approach makes everything easier to reproduce. Any developer can
use this configuration to spin up a few virtual machines. It doesn't matter if
their machines are running Windows; Linux; or Mac.

During the workshop, the biggest blocker we had was download speed. It took
between 10 and 20 minutes to get everything set up. The two steps that took
the most time were:

- Downloading and installing Docker
- Building the images for the first time

Once that was done, the process went smoothly. We got to
calculate test coverage;
setup dual booting; run our test suite with two different versions of Rails; and
fix a bunch of problems related to the jump from Rails 4 to 5.

If you are interested in applying these steps to your own application, you can
check out the [companion page for the Upgrade Rails 101 workshop](https://fastruby.io/upgrade).

The slides for my presentation are over here:
[Upgrade Rails 101 Workshop at Southeast Ruby '19](https://speakerdeck.com/etagwerker/upgrade-rails-101-the-roadmap-to-smooth-upgrades-southeast-ruby-19)

<script async class="speakerdeck-embed" data-id="696e4eec23fd4480a30500deaa8c8252" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

<br/>

Are you using Docker to simplify your [Rails upgrades](https://fastruby.io/blog/tags/upgrades)?
If not, what are you using to normalize environments in your team? I hope you
found this article useful and I look forward to reading your comments below!
