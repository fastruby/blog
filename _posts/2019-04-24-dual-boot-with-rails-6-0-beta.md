---
layout: post
title:  "Getting Ready for Rails 6.0: How to Dual Boot"
date: 2019-04-24 10:00:00
reviewed: 2020-05-02 10:00:00
categories: ["upgrade-rails", "dual-boot"]
author: "etagwerker"
---

In this article I will explain how you can _dual boot_ your application in your
local environment and your continuous integration (CI) service. I hope that this 
will help you get ready for the next stable release of Rails.

<!--more-->

Even though my example assumes you are running [Rails 5.2](https://fastruby.io/blog/rails/upgrades/upgrade-rails-from-5-1-to-5-2.html) and want to 
[migrate to Rails 6.0](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-5-2-to-6-0.html), these tips work for any two versions of Rails.

<h2 id="Gemfile.next">Create a Gemfile.next File</h2>

At RailsConf 2018, [Jordan Raine](https://twitter.com/jnraine) talked about
Clio's process to upgrade Rails over the years. If you missed his talk, you can
watch it over here: [Ten Years of Rails Upgrades](https://www.youtube.com/watch?v=6aCfc0DkSFo)

In his talk he mentioned quite a handy companion gem: [`ten_years_rails`](https://rubygems.org/gems/ten_years_rails). At [FastRuby.io](https://www.fastruby.io) we decided to fork 
it and call it [`next_rails`](https://rubygems.org/gems/next_rails). I'm going 
to use that gem to get my project ready for dual booting. First, I need to 
install it in my local environment.

```
$ gem install next_rails
Successfully installed next_rails-1.0.2
Parsing documentation for next_rails-1.0.2
Installing ri documentation for next_rails-1.0.2
Done installing documentation for next_rails after 0 seconds
1 gem installed
```

**Warning**: `next_rails` requires Ruby 2.3 or higher. You can find a manual
workaround [below](#workaround).

Assuming I can use that gem, I will initialize my `Gemfile.next` file like this:

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

That command creates a `Gemfile.next` [symlink](https://wiki.c2.com/?SymbolicLink) 
to my `Gemfile` and adds a handy method called `next?` to my `Gemfile`:

<h3 id="why-gemfile-next">Why to use a symlink</h3>

I see three main benefits to using a symlink: 

1. The way Bundler works it will generate one `.lock` file per Gemfile. If you 
manage all your dependencies logic in your Gemfile (without `Gemfile.next`) and
your `Gemfile.lock` is checked in to your Git repository, then you will have to
constantly resolve conflicts between your long running upgrade branch and 
`master`. This will become tedious if you have a really active `master` branch
and your upgrade project lasts months (not weeks)

1. By making it a symlink to `Gemfile`, you can keep all your logic inside one
file. That means that you can quickly see what are the main difference between
your current version of Rails and the next version.

1. You can use Bundler's `BUNDLE_GEMFILE` environment variable. Because a
symlink is transparent to Bundler, it assumes that you have two physical files.
You can later switch between one version of Rails or the other by just adding
one environment variable to your command line.

<div id="workaround" />

```ruby
# Gemfile
def next?
  File.basename(__FILE__) == "Gemfile.next"
end

source 'https://rubygems.org'
# ...
```

If you have any problems installing `next_rails`, you can manually add the
`next?` method to your `Gemfile` and create a symlink like this:

```
$ cd path/to/project
$ ln -s Gemfile Gemfile.next
```

<h2 id="bump-rails-version">Bump Rails (Gemfile.next)</h2>

In this simple example, I only need to upgrade `rails` (from Rails 5.2 to Rails
6.0). It's _very likely_ that you will have to upgrade more dependencies. The
first step is to get my `Gemfile` to look like this:

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
dependencies with `next bundle update`. If `next bundle update` doesn't work
for you, you can just run `BUNDLE_GEMFILE=Gemfile.next bundle install`. As a
general rule, if `next <command>` doesn't work in your environment you can
replace it with `BUNDLE_GEMFILE=Gemfile.next <command>`.

`next bundle <command>` might not work because you are using an old version of 
[Bundler](https://bundler.io). So, you should try using Bundler 2.0 or higher.

<h2 id="run-test-suite">Run Tests</h2>

After running `next bundle update`, I have a brand new `Gemfile.next.lock` file.
That means that my dependencies are ready to run my test suite. So I can run 
them like this:

```
$ next bundle exec rake
```

There are many advantages to using _dual booting_ in your Rails application. In
no particular order: 

- You can run your test suite with two different versions of Rails. Running `bundle exec rake`
still works thanks to the conditionals in your `Gemfile`.
- You can run your application in development with two different versions of 
Rails. Simply prepend `next` to `bundle exec rails server`.
- You can even run your application in staging using the next version of Rails.
Simply make sure that you set this environment variable: `BUNDLE_GEMFILE`
- You can quickly debug issues between your current version of Rails and the 
next one. Dual booting plus `debugger` is a powerful combo for finding bugs
between versions.

<h2 id="continuous-integration">Setup Continuous Integration</h2>

Depending on the type of project, we like to use [Travis CI](https://travis-ci.com)
for open source projects and [Circle CI](https://circleci.com) for client projects. 
Below you will find a couple of sample configuration files that you could use.

Both samples will require you to commit and push `Gemfile.next` to your repository;
will run a build matrix; and might need some tweaking.

<h2 id="circle-ci">Circle CI</h2>

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

<h2 id="travis-ci">Travis CI</h2>

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

<h2 id="fix-tests">Start Fixing The Rails 6.0 Test Suite</h2>

Now that you have your test suite running in both Rails 5.2 and Rails 6.0, you
can start tweaking your code and dependencies to work with both gemfiles. There
will be two big hurdles:

1. Getting Bundler to bundle your dependencies
2. Getting your test suite to pass

<h2 id="summary">Summary</h2>

This has been quite a useful technique for us at [FastRuby.io](https://fastruby.io).
We have used it with client projects, internal projects, and open source
applications.

I hope that you will find it useful in getting ready for the next version of Rails!
