---
layout: post
title: "Upgrade Rails from 4.1 to 4.2"
date: 2018-02-02 11:32:00
categories: ["rails", "upgrades"]
author: "mauro-oto"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://www.ombulabs.com/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to get
your [Ruby on Rails](http://rubyonrails.org/) application from [version 4.1](http://guides.rubyonrails.org/4_1_release_notes.html) to [4.2](http://guides.rubyonrails.org/4_2_release_notes.html).

<!--more-->

1. [Ruby version](#ruby-version)
2. [Gems](#gems)
3. [Config files (config/)](#config-files)
4. [Application code](#application-code)
  1. [ActiveRecord](#active-record)
  2. [ActionMailer](#action-mailer)
5. [Miscellaneous](#miscellaneous)
6. [Next steps](#next-steps)

<h2 id="ruby-version">1. Ruby version</h2>

Rails 4.2 requires Ruby 1.9.3 or later, and Ruby 2.0 (or newer) is preferred
according to the [official upgrade guide](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#ruby-versions).

<h2 id="gems">2. Gems</h2>

If you're using [RSpec 2](https://relishapp.com/rspec/rspec-core/v/2-14/docs/),
you'll need to migrate to [RSpec 3](https://relishapp.com/rspec/rspec-core/v/3-7/docs),
since RSpec 2 doesn't officially support Rails 4.2. To make this process easier,
you can update to [RSpec 2.99](https://rubygems.org/gems/rspec/versions/2.99.0),
which will print a bunch of deprecation warnings at the end of the test run,
and you'll need to fix these before updating to RSpec 3. For more information,
check out their [official upgrade guide](http://rspec.info/upgrading-from-rspec-2/).

You can also use the awesome [Transpec](http://yujinakayama.me/transpec/) to
automate the RSpec 2 to 3 upgrade process.

Once you're on Rails 4.2, you will be able to remove the [`Timecop`](https://github.com/travisjeffery/timecop)
gem if you're using it, and replace it with new test helper methods `travel`,
`travel_to` and `travel_back`. See: [TimeHelpers](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html)

<h2 id="config-files">3. Config files</h2>

Rails includes the `rails:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).

As an alternative, check out [RailsDiff](http://railsdiff.org/4.1.16/4.2.10),
which provides an overview of the changes in a basic Rails app between 4.1.x and
4.2.x (or any other source/target versions).

After upgrading to [Rails 4.2](https://rubygems.org/gems/rails/versions/4.2.9) for
an application that needs to run in development on port 80, I came across an
unexpected problem due to [a change in Rack](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc).
Rails now listens on `localhost` instead of `0.0.0.0`. You will run into the
same problem in case you need to access your Rails server from a different
machine. To work around it, you need to start your server by binding to
`0.0.0.0` by using:

`rails server -b 0.0.0.0 -p 80`

Alternatively, you can try the [solution here](https://stackoverflow.com/a/33249657/2754597)
to avoid providing `-b 0.0.0.0` when you start the server. If you're using
[Foreman](https://github.com/ddollar/foreman) and run into this problem, you can
edit your `Procfile`'s `web` entry so that it reads:

`web: bundle exec rails s -b 0.0.0.0`

<h2 id="application-code">4. Application code</h2>

<h3 id="active-record">a. ActiveRecord</h2>

- ActiveRecord <= 4.2 suppresses exceptions raised in the `after_commit` and
`after_rollback` callbacks by default. They are rescued and printed on the log,
and they don't propagate. You can opt into raising these exceptions now by
adding the following configuration:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Starting from ActiveRecord 5.0, these exceptions are always raised regardless
of this setting, so you *should* opt into it and update your code accordingly.

See: [https://github.com/rails/rails/pull/16537](https://github.com/rails/rails/pull/16537)

- If you pass an object to `#find`, you will now run into the following
deprecation warning:

```
DEPRECATION WARNING: You are passing an instance of ActiveRecord::Base to `find`.
Please pass the id of the object by calling `.id`.
```

You will need to change your `.find` calls to pass an id instead of an object.

Before:

```ruby
Comment.find(comment)
```

After:

```ruby
Comment.find(comment.id)
```

The same goes for `#exists?` calls, if you pass an object as a parameter for it,
you will need to provide an id instead.

<h3 id="action-mailer">b. ActionMailer</h2>

- `deliver` and `deliver!` are deprecated, in favor of `deliver_now` and
`deliver_now!`.

Before:

```ruby
NotificationMailer.daily_summary(user).deliver
```

After:

```ruby
NotificationMailer.daily_summary(user).deliver_now
```

<h2 id="miscellaneous">5. Miscellaneous</h2>

- `respond_with` and the class-level `respond_to` were removed from Rails 4.2
and moved to the [`responders`](https://rubygems.org/gems/responders) gem.

If you're using these in your controllers, you will need to add:

```ruby
gem 'responders', '~> 2.0'
```

to your `Gemfile`.

- Rails' HTML sanitizer was rewritten to use the more secure [Loofah](https://rubygems.org/gems/loofah)
gem. As a result, your expected sanitized output might be slightly different for
some inputs. If you experience problems with it, you can restore the behavior by
adding:

```ruby
gem 'rails-deprecated_sanitizer'
```

to your `Gemfile`. It will only be supported for Rails 4.2, so it's
recommended that you *do not* do this and stick with the new default HTML
sanitizer.

<h2 id="next-steps">6. Next steps</h2>

If you successfully followed all of these steps, you should now be running Rails 4.2! Do you have any other useful tips or recommendations? Share them with us in the comments section.

If you don't have the time to upgrade your Rails app, check out our [Ruby on Rails
upgrade](https://fastruby.io) service: [FastRuby.io](https://fastruby.io)
