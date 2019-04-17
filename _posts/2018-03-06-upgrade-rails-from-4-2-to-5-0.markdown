---
layout: post
title: "Upgrade Rails from 4.2 to 5.0"
date: 2018-03-06 10:53:00
categories: ["rails", "upgrades"]
author: "mauro-oto"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to get
your [Ruby on Rails](http://rubyonrails.org/) application from [version 4.2](http://guides.rubyonrails.org/4_2_release_notes.html) to [5.0](http://guides.rubyonrails.org/5_0_release_notes.html).

<!--more-->

1. [Ruby version](#ruby-version)
2. [Gems](#gems)
3. [Config files (config/)](#config-files)
4. [Application code](#application-code)
  1. [ActiveRecord](#active-record)
  2. [Controllers](#controllers)
5. [Testing](#testing)
6. [Next steps](#next-steps)

<h2 id="ruby-version">1. Ruby version</h2>

[Rails 5.0](http://weblog.rubyonrails.org/2016/6/30/Rails-5-0-final/) requires [Ruby 2.2.2](https://www.ruby-lang.org/en/news/2015/04/13/ruby-2-2-2-released/) or later.

This Ruby upgrade shouldn't generate any problems. However, if you run into this
exception in your test suite:

`cannot load such file -- test/unit/assertions (Load Error)`

then you'll need to add:

`gem 'test-unit'`

to your `Gemfile`.

<h2 id="gems">2. Gems</h2>

- It's recommended that you check your `Gemfile` against [Ready4Rails](http://www.ready4rails.net)
to ensure all your gems are compatible with Rails 5.
As of the release of this blog post, there are only a few gems which don't
support Rails 5 yet. This is more of a problem when you're upgrading early on.

If any of the gems are missing on Ready4Rails, you'll need to manually check the
Github page for the project to find out its status. In case you own the gem,
you'll need to make sure it works on Rails 5 or update it.

<h2 id="config-files">3. Config files</h2>

Rails includes the `rails app:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).

As an alternative, check out [RailsDiff](http://railsdiff.org/4.2.10/5.0.6),
which provides an overview of the changes in a basic Rails app between 4.2.x and
5.0.x (or any other source/target versions).

<h2 id="application-code">4. Application code</h2>

<h3 id="active-record">a. ActiveRecord</h2>

- ActiveRecord models will now inherit from ApplicationRecord by default instead
of ActiveRecord::Base. You should create an `application_record.rb` file under
`app/models` with:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

And then update all of your models to inherit from `ApplicationRecord` instead
of `ActiveRecord::Base`. The only class that inherits from `ActiveRecord::Base`
will be `ApplicationRecord`.

- `belongs_to` associations are [now required by default](https://github.com/rails/rails/pull/18937/files).
This means that if the association doesn't exist for a model when saving it, an
error will be triggered. You can turn this feature off for an association by
using `optional: true`:

```ruby
belongs_to :user, optional: true
```

- ActiveRecord migrations now need to be tagged with the Rails version they are
created under. One of the reasons for this is that strings in Rails 4.2 had a
default size of 4 bytes. In Rails 5.0, their default size is now of 8 bytes. See
[this comment](https://stackoverflow.com/a/35930912/2754597) from Rails core
team member Rafael França regarding this change.

To resolve this, you'll need to update your current migrations in your `db/migrate` directory:

```ruby
class CreatePosts < ActiveRecord::Migration
```

```ruby
class CreatePosts < ActiveRecord::Migration[4.2]
```

If you add a new migration after updating to Rails 5.0, you'll also need to tag
them appropriately:

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
```

This will help with potential compatibility issues, so your database can be
correctly reconstructed from the migrations. Strings in your 4.2 migrations
will use the previous default size of 4 bytes instead of the new default.

Note you shouldn't add the patch version to the tag, just the major and minor
version numbers (`4.2`, `5.0`, `5.1`, `5.2`).

(Thanks to Cory McDonald in the comments section for reminding us about this
important change!)

<h3 id="controllers">b. Controllers</h2>

- If you're not already using strong parameters, and still rely on
`protected_attributes`, you should migrate your application to strong
parameters before attempting to upgrade to Rails 5.0.
[`protected_attributes`](https://github.com/rails/protected_attributes) is
no longer supported on Rails 5.0.

A few months ago we worked on a project to attempt to automate the strong
parameters migration process, and this resulted in the gem [RailsUpgrader](https://github.com/fastruby/rails_upgrader).
It's in a beta state, but you can try using it if you have too many models, or
at least as a guide for a WIP branch.

There are still efforts being made to keep `protected_attributes` alive though,
like the [`protected_attributes_continued`](https://github.com/westonganger/protected_attributes_continued)
gem. I would strongly recommend against using it since its support is limited,
and it won't work in future Rails versions.

- Parameters now behave differently, they no longer inherit from
`HashWithIndifferentAccess`. Some methods (e.g.: `fetch`, `slice`, `except`) you
may be now calling on `params` will no longer work. You will need to `permit`
the parameters, call `to_h`, and only then you'll be able to run the `Hash`
methods you need on them.

For more information: [https://github.com/rails/rails/pull/20868](https://github.com/rails/rails/pull/20868)

<h2 id="testing">5. Testing</h2>

- One of the most common methods in controller tests, `assigns`, has been
extracted from Rails and moved to the [`rails-controller-testing`](https://github.com/rails/rails-controller-testing) gem.
If you wish to continue using it (and `assert_template`), you'll need to add it
to your `Gemfile`:

```ruby
gem 'rails-controller-testing'
```

- Instead of using `ActionDispatch::Http::UploadedFile` to test uploads, you'll
need to update those tests to use [`Rack::Test::UploadedFile`](http://www.rubydoc.info/github/brynary/rack-test/Rack/Test/UploadedFile).

<h2 id="next-steps">6. Next steps</h2>

If you successfully followed all of these steps, you should now be running Rails 5.0! Do you have any other useful tips or recommendations? Share them with us in the comments section.

If you don't have the time to upgrade your Rails app, check out our [Ruby on Rails
upgrade](https://fastruby.io) service: [FastRuby.io](https://fastruby.io)
