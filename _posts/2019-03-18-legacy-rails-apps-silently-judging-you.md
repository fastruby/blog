---
layout: post
title:  "Legacy Rails: Silently Judging You"
date: 2019-03-18 10:00:00
categories: ["rails", "upgrades"]
author: "etagwerker"
---

I had to come up with a clever title because this article is about legacy
[Rails](https://rubyonrails.org/) applications and I know that you might fall
asleep by the third paragraph. **Boooooring...** You probably want to read about
that new JavaScript framework that came out (_I love that this sentence will always be true, it doesn't matter when you read this_)

If you have been working with Rails for a few years, you have seen your
fair share of shiny new applications, well-maintained and poorly-maintained
legacy applications. This post is about **Legacy Rails applications**

So let's start judging them! _Are they in good shape? Should we upgrade them to
a more recent version of Rails? Should we re-write them?_

<img src="/blog/assets/images/judging.gif" alt="Judging You" class="half-img">

<!--more-->

How can you judge the quality of a Rails application? Here is a process that
works for us.

## Dependency Archeology

A good way to get started is to find out _how_ outdated an application really is.
You can easily do this with [Bunder](https://bundler.io/)'s `bundle outdated`:

```
$ bundle outdated
Fetching gem metadata from https://rubygems.org/..........
Resolving dependencies.......................................................................................................................................................

Outdated gems included in the bundle:
  * actionmailer (newest 5.2.2, installed 3.2.22.5)
  * actionpack (newest 5.2.2, installed 3.2.22.5)
  * activemerchant (newest 1.90.0, installed 1.53.0) in groups "default"
  * activemodel (newest 5.2.2, installed 3.2.22.5)
  ...
  * tilt (newest 2.0.9, installed 1.4.1)
  * todonotes (newest 0.2.2, installed 0.1.0)
  * treetop (newest 1.6.10, installed 1.4.15)
  * tzinfo (newest 2.0.0, installed 0.3.52)
  * uglifier (newest 4.1.20, installed 1.2.4) in groups "assets"
  * unicorn (newest 5.4.1, installed 4.8.3) in groups "default"
  * uniform_notifier (newest 1.12.1, installed 1.4.0)
  * whenever (newest 0.10.0, installed 0.8.2) in groups "default"
  * wicked_pdf (newest 1.1.0, installed 0.9.10) in groups "default"
```

Using this information, you can review the `Gemfile` and improve it. If you find
dependencies that are declared like this:

```ruby
gem 'rails', '4.2.7'
```

You could improve them like this:

```ruby
gem 'rails', '~> 4.2.7'
```

Next time you run `bundler update` it will jump to the latest patch version.
Your application doesn't have to be tied to Rails version 4.2.7, it is safe to
assume that it would work fine using version 4.2.11.1. This way you make sure
that you get the latest security patches and deprecation warnings.

You can try this with all dependencies that are tied to a specific version. Sure,
there might be a _very good reason_ for that dependency to be _that concrete_,
but probably not.

Another handy tool for analyzing your `Gemfile.lock` is `bundler-audit`. You can
quickly install and run it to find known vulnerabilities associated with the
gems you are running in production.

If you want to do a quick assessment, you can use our free Bundler Audit tool:
[https://audit.fastruby.io](https://audit.fastruby.io)

## Models Judgment

How many tables are in your `db/schema.rb`? How many models are in your
`app/models` directory? Does it have 10 tables? 200 tables? This is a quick
indicator that could tell you a little bit about the complexity of the system.

You could take a few minutes to draw the ERD associated with the database. If
the application has more than 20 tables, you could use something like
[`rails-erd`](https://github.com/voormedia/rails-erd) to quickly generate an
Entity Relationship Diagram.

## Static Code Analysis/Judgment

You can use tools like `flay`, `flog`, and `heckle` to do static code analysis
and get a sense of what parts of the application will cause most of
the maintenance pain. More info over here: [Ruby Sadist](http://ruby.sadi.st/Ruby_Sadist.html) (NSFW)

We prefer [CodeClimate](https://codeclimate.com) for this. You can get a quick
sense of the maintainability level of your application:

<img src="/blog/assets/images/code-climate-report.png" alt="Sample Code Climate Report">

You can filter all the existing issues to get a sense of the most critical
issues:

<img src="/blog/assets/images/code-climate-report.png" alt="Sample Code Climate Report">

Code Climate will give you an idea of the complexity of the application.

There are certainly many free, open source alternatives, which you can find over
here: [https://github.com/metricfu/metric_fu/wiki/Code-Tools](https://github.com/metricfu/metric_fu/wiki/Code-Tools)

## Developer Onboarding Judgment

Does the application provide a well-maintained `Dockerfile`? Does it provide a
`./bin/setup` script? Do they run?

Setting up a new development environment should be as simple as:

```
./bin/setup`
```

Or:

```
docker-compose up
```

Or:

```
vagrant up
```

You **get** the point. It is a **red flag** when you need to pair with someone to get
your development environment set up. You should count the times you run into
unexpected issues. This will give you a good idea of the complexity of *all*
environments.

## Build Judgment

Is there a set of spec files? Does the build work in your environment? After you
have set up your local environment, you should be able to run:

```
rake
```

I'm used to projects and gems using `test` or `spec` as the default Rake task,
which has been the default task for Rails for a while: [https://github.com/rails/rails/blob/5-2-stable/Rakefile#L21-L22](https://github.com/rails/rails/blob/5-2-stable/Rakefile#L21-L22)

```ruby
# Rakefile
desc "Run all tests by default"
task default: %w(test test:isolated)
```

It is a **red flag** when you run into unexpected issues when running the build.
If some tests failed, why did they fail? How many random failures did you get? If
you found many issues, why didn't `./bin/setup` take care of it for you beforehand?

## Coverage Judgment

Let's say your application is so well maintained that all previous steps worked
flawlessly. `bundle outdated` returned no outdated dependencies; static code
analysis reported an A+; you run `./bin/setup` to install everything you needed;
and the `rake` showed you a passing build. That is great!

How well covered is it? Does it cover more than 80% of your code? Does it cover
100% of the [critical path]()?

You can quickly find out with `SimpleCov`. Simply add this to your `Gemfile`:

```ruby
# Gemfile
gem 'simplecov', require: false, group: :test
```

Then add this to your test helper file:

```ruby
if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start 'rails'
end
```

Then `bundle install` and run the build. You should get a report like this one:

<img src="/blog/assets/images/simple-cov-report.png" alt="SimpleCov Report">

## 12 Factor Judgment

Yes, yes, we all know we **should be** following the [twelve-factor methodology](https://fastruby.io/twelve-factor) but some people _missed the memo_.

How many values are hardcoded in the configuration files? Are there more than 3
environments? How are environment variables managed? Are they using a
[`config/secrets.yml`](https://guides.rubyonrails.org/4_1_release_notes.html#config-secrets-yml) file? Is `config/database.yml` checked in to the repository? If so,
is it using environment variables? Are all dependencies clearly declared? How
are they tracking exceptions in production? What does the time between deployments
gap look like?

## MVC Judgment

One of the best selling points of Rails is convention over configuration. You
know where to find code for models, views, and controllers.

There are some applications out there that didn't follow this pattern. They
may include queries in your views, business logic in your controllers, and fat
controllers.

It is a **red flag** if you do a quick code analysis that shows that there is
spaghetti code in your views, controllers, or models which breaks the Rails'
conventions.

## Quick Performance Judgment

Do they use [Skylight](https://www.skylight.io)? [NewRelic](https://newrelic.com)?
[Scout](https://scoutapp.com)? What are the slowest and busiest requests? What
are the main performance problems? Are the slowest requests related to the most
complex files in the app?

## Final Remarks

At this point you should have a good idea about your legacy Rails application:

**Is it in good or bad shape?**

You can quickly assign a score to each of the steps I mentioned and add them up.
From 1 to 100, **how maintainable is your app?**

<img src="/blog/assets/images/judges.gif" alt="Time to judge with scores!">
