---
layout: post
title: "How to Prepare Your Rails App for an Upgrade"
date: 2020-12-03 09:00:00
categories: ["rails", "upgrade"]
author: "zach"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to prepare
your [Ruby on Rails](http://rubyonrails.org/) application for working on an upgrade.

<!--more-->

1. [Code Coverage](#codecoverage)
2. [Staging and Production](#stageingandproduction)
3. [Patch Version](#patchversion)
4. [Incompatabilities](#incompatabilities)
5. [Dual Boot](#dualboot)

<h3 id="codecoverage">1. Code Coverage</h3>

Not all applications are good candidates for a Rails upgrade project. We strongly advise against upgrading big applications which are running in production with minimal test coverage.

Make sure that you have at least 80% test coverage before starting the upgrade project. If you don't have a solid test suite (or a dedicated QA team), you will likely find many problems which will force you to roll back the upgrades as soon as they hit production.

You can easily calculate it by using [simplecov](https://github.com/colszowka/simplecov). Here is a [tutorial](https://www.fastruby.io/blog/upgrade-rails/legacy-rails-silently-judging-you.html) about how to use it.

<h3 id="stageingandproduction">2. Staging and Production</h3>

We advise all of our clients to follow a [Git flow](https://nvie.com/posts/a-successful-git-branching-model/) workflow and to actively manage at least two environments: staging and production.

Every change should be code reviewed using pull requests and it should run the entire test suite. Once all checks have passed, changes should get
deployed to staging. After your QA team has tested your critical flow in staging, you should deploy the changes to production.

<h3 id="patchversion">3. Patch Version</h3>

Before working on an upgrade you should make sure that you are running the application with the latest patch version. That way, you make sure that the latest security patches have been installed. On top of that, with more recent versions, you will get a series of deprecation warnings that will be useful in finding out what needs to be done.

<h3 id="incompatabilities">4. Incompatabilities</h3>

Have you ever got tangled in dependencies? You need to upgrade dependency A, but that's incompatible with Rails 5.0 because dependency B (which is a dependency of A) is not compatible with that version of ActiveRecord).

Before you start going down the rabbit hole, make sure to check your `Gemfile.lock` for incompatibilities. For that, you can use this website: https://railsbump.org/

That will give you an idea of how many dependencies are not compatible with Rails 4,
5, or 6.

<h3 id="dualboot">5. Dual Boot</h3>

To help you switch between your current Rails version and the new one, you can create a dual boot mechanism. The fastest way is to install the handy gem [next_rails](https://github.com/fastruby/next_rails). You can initialize it doing

```
$ gem install next_rails
$ next --init
```

You can then set up two Rails versions in your Gemfile like this:

```ruby
if next?
  gem 'rails', '~> 6.0.0'
else
  gem 'rails', '~> 5.2.3'
end
```

Sometimes dependencies are backwards compatible with the current version of
Rails. Within the libraries, you will find code that looks like this:

```ruby
if Rails::VERSION >= 5.1
  # does X
else
  # does Y
end
```

If that is the case, then you might be able to just upgrade the dependency
using `bundle update`.

## Next Steps
Now that you have laid the groundwork for you upgrade, it is time to start the work itself. For details on what you specific version upgrade will require, check out the corresponding guide:

- [2.3 to 3.0](https://www.fastruby.io/blog/rails/upgrades/upgrade-to-rails-3.html)
- [3.0 to 3.1](https://www.fastruby.io/blog/rails/upgrades/upgrade-to-rails-3-1.html)
- [3.1 to 3.2](https://www.fastruby.io/blog/rails/upgrades/upgrade-to-rails-3-2.html)
- [3.2 to 4.0](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-3-2-to-4-0.html)
- [4.0 to 4.1](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-4-0-to-4-1.html)
- [4.1 to 4.2](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-4-1-to-4-2.html)
- [4.2 to 5.0](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-4-2-to-5-0.html)
- [5.0 to 5.1](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-5-0-to-5-1.html)
- [5.1 to 5.2](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-5-1-to-5-2.html)
- [5.2 to 6.0](https://www.fastruby.io/blog/rails/upgrades/upgrade-rails-from-5-2-to-6-0.html)
