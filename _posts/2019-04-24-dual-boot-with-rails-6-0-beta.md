---
layout: post
title:  "Getting Ready for Rails 6.0: How to Dual Boot"
date: 2019-04-24 10:00:00
reviewed: 2020-03-05 10:00:00
categories: ["upgrade-rails", "dual-boot"]
author: "etagwerker"
---

[RailsConf 2019](https://railsconf.com) is right around the corner. That means
[Rails 6.0](https://edgeguides.rubyonrails.org/6_0_release_notes.html) is right
around the corner! [Rails 6.0's beta](https://weblog.rubyonrails.org/2019/1/22/this-week-in-rails-rails-6-0-0-beta1-and-more/) has been available since January 18, 2019. [Rails 6.0.0.rc1
was released today](https://weblog.rubyonrails.org/2019/4/24/Rails-6-0-rc1-released/)! 🎉

In this article I will explain how you can _dual boot_ your application in your
local environment and your CI server. I hope that this will help you get ready
for the next stable release of Rails.

<!--more-->

Even though my example assumes you are running [Rails 5.2](https://fastruby.io/blog/rails/upgrades/upgrade-rails-from-5-1-to-5-2.html) and want to migrate to Rails 6.0, these tips
work for any two versions of Rails.

## Create a Gemfile.next File

At RailsConf 2018, [Jordan Raine](https://twitter.com/jnraine) talked about
Clio's process to upgrade Rails over the years. If you missed his talk, you can
watch it over here: [Ten Years of Rails Upgrades](https://www.youtube.com/watch?v=6aCfc0DkSFo)

In his talk he mentioned quite a handy companion gem: [`ten_years_rails`](https://rubygems.org/gems/ten_years_rails). I'm going to use that gem to get my project ready for dual
booting. First, I need to install it in my local environment.

```
$ gem install ten_years_rails
Successfully installed ten_years_rails-0.2.0
Parsing documentation for ten_years_rails-0.2.0
Installing ri documentation for ten_years_rails-0.2.0
Done installing documentation for ten_years_rails after 0 seconds
1 gem installed
```

**Warning**: `ten_years_rails` requires Ruby 2.3 or higher. You can find a manual
workaround [below](#workaround).

Now that I can use that gem, I will initialize my `Gemfile.next` file like this:

```
$ next --init
Created Gemfile.next (a symlink to your Gemfile). Your Gemfile has been modified
to support dual-booting!

There's just one more step: modify your Gemfile to use a newer version of Rails
using the `next?` helper method.

For example, here's how to go from 5.2.3 to 6.0:

if next?
  gem "rails", "6.0.0"
else
  gem "rails", "5.2.3"
end
```

That command creates a `Gemfile.next` symlink to my `Gemfile` and adds an util
method to my `Gemfile`:

<div id="workaround" />

```ruby
# Gemfile
def next?
  File.basename(__FILE__) == "Gemfile.next"
end

source 'https://rubygems.org'
# ...
```

If you have any problems installing `ten_years_rails`, you can manually add the
`next?` method to your `Gemfile` and create a symlink like this:

```
$ cd path/to/project
$ ln -s Gemfile Gemfile.next
```

## Bump Rails (Gemfile.next)

In this simple example, I only need to upgrade `rails` (from Rails 5.2 to Rails
6.0). It's _very likely_ that you will have to upgrade more dependencies. My
`Gemfile` now looks like this:

```ruby
def next?
  File.basename(__FILE__) == "Gemfile.next"
end

source 'https://rubygems.org'

if next?
  gem 'rails', '~> 6.0.0'
else
  gem 'rails', '~> 5.2.3'
end

# ...
```

Now I can install my current dependencies with `bundle install` and my _future_
dependencies with `next bundle install`. If `next bundle install` doesn't work
for you, you can just run `BUNDLE_GEMFILE=Gemfile.next bundle install`. As a
general rule, if `next <command>` doesn't work in your environment you can
replace it with `BUNDLE_GEMFILE=Gemfile.next <command>`.

## Run Tests

After running `next bundle install`, I have a brand new `Gemfile.next.lock` file.
That means that my dependencies are ready to run my test. So I can run them like
this:

```
$ next bundle exec rake
```

The main advantage of using _dual booting_ your Rails application is that you
can run your tests with two different versions of Rails. Running `bundle exec rake`
still works thanks to the conditionals in your `Gemfile`.

## Setup Continuous Integration

Depending on the type of project, we like to use [Travis CI](https://travis-ci.com)
or [Circle CI](https://circleci.com). So below you will find a couple of sample
configuration files that you could use.

Both samples will require you to commit and push `Gemfile.next` to your repository;
will run a build matrix; and might need some tweaking.

## Circle CI

For all of our client projects we prefer this continuous integration service.
Here is the configuration that you could use for dual booting in Circle CI:

<script src="https://gist.github.com/etagwerker/14c9045788d356cbb797dcb5f678b135.js"></script>

A few notes about this configuration:

- It's using Ruby 2.6 and a Postgres database
- It's using [Circle CI's API version 2.0](https://circleci.com/docs/2.0/)
- It has a lot of duplication (there is probably a way to [DRY](http://wiki.c2.com/?DontRepeatYourself) it)
- The key is to configure a workflow with two jobs (one for Rails 5.2 and
  another one for Rails 6.0) like this:

```yaml
workflows:
  version: 2
  build:
    jobs:
      - "build-rails-5-2"
      - "build-rails-6-0"
```

## Travis CI

For all of our open source projects we prefer this continuous integration service.
Here is the configuration that you could use for dual booting in Travis CI:

<script src="https://gist.github.com/etagwerker/02ee3e3623d3e99b15c20cba31a608cc.js"></script>

A few notes about this configuration:

- It's for an open source application that is using Postgres
- You might not need some of the things in this sample
- It's certainly simpler than the Circle CI configuration. I love how
simple it is to configure a build matrix in Travis CI:

```yaml
rvm:
- 2.2.6
gemfile:
- Gemfile
- Gemfile.next
```

## Start Fixing The Rails 6.0 Test Suite

Now that you have your test suite running in both Rails 5.2 and Rails 6.0, you
can start tweaking your code and dependencies to work with both gemfiles. There
will be two big hurdles:

1. Getting Bundler to bundle your dependencies
2. Getting your test suite to pass

## Final Remarks

This has been quite a useful technique for us at [fastruby.io](https://fastruby.io).
We have used it with client projects, internal projects, and open source
applications.

I hope that you will find it useful in getting ready for the upcoming Rails 6.0
stable release.
