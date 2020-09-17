---
layout: post
title: "Upgrade Rails from 5.0 to 5.1"
date: 2018-07-18 10:05:00
reviewed: 2020-09-17 10:00:00
categories: ["rails", "upgrades"]
authors: ["etagwerker", "mauro-oto"]
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to get
your [Ruby on Rails](http://rubyonrails.org/) application from [version 5.0](http://guides.rubyonrails.org/5_0_release_notes.html) to [5.1](http://guides.rubyonrails.org/5_1_release_notes.html).

<!--more-->

1. [Ruby version](#ruby-version)
2. [Gems](#gems)
3. [Config files](#config-files)
4. [Application code](#application-code)
  1. [ActiveRecord](#active-record)
  2. [Controllers](#controllers)
5. [Testing](#testing)
6. [Next steps](#next-steps)

<h2 id="ruby-version">1. Ruby version</h2>

Like Rails 5.0, [Rails 5.1](https://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/) requires [Ruby 2.2.2](https://www.ruby-lang.org/en/news/2015/04/13/ruby-2-2-2-released/) or later.

If you want to know more about the Ruby versions that you could use, check out our
[Ruby & Rails Compatibility Table](https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html).

<h2 id="gems">2. Gems</h2>

- Make sure the gems you use are compatible with Rails 5.1, you can check this
using [RailsBump](https://www.railsbump.org). If a gem is missing on
RailsBump, you'll need to manually check the Github page for the project to
find out its status. In case you own the gem, you'll need to make sure it
supports Rails 5.1 and if it doesn't, update it.

<h2 id="config-files">3. Config files</h2>

Rails includes the `rails app:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).

You might run into an error trying to run that command:

```
$ bundle exec rails app:update
rails aborted!
LoadError: cannot load such file -- rails/commands/server
/Users/etagwerker/.rvm/gems/ruby-2.4.9@ombu/gems/bootsnap-1.4.8/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:34:in `require'
/Users/etagwerker/.rvm/gems/ruby-2.4.9@ombu/gems/activesupport-5.1.7/lib/active_support/dependencies.rb:292:in `block in require'
/Users/etagwerker/.rvm/gems/ruby-2.4.9@ombu/gems/activesupport-5.1.7/lib/active_support/dependencies.rb:258:in `load_dependency'
/Users/etagwerker/.rvm/gems/ruby-2.4.9@ombu/gems/activesupport-5.1.7/lib/active_support/dependencies.rb:292:in `require'
/Users/etagwerker/Projects/ombulabs/ombushop/config/application.rb:5:in `<main>'
```

If that is the case, you will need to change this require statement:

```ruby
require 'rails/commands/server'
```

To:

```ruby
require 'rails/commands/server/server_command'
```

As an alternative, check out [RailsDiff](http://railsdiff.org/5.0.7.2/5.1.7),
which provides an overview of the changes in a basic Rails app between 5.0.x and
5.1.x (or any other source/target versions). Always target your upgrade to the
latest patch version (e.g: 5.1.6 instead of 5.1.0).

Some assets configuration changes you'll have to do on your
`config/environments/{development, test, production}.rb` files are:

Before:

```ruby
config.serve_static_files = false
config.static_cache_control = "public, max-age=3600"
```

After:

```ruby
config.public_file_server.enabled = false
config.public_file_server.headers = "public, max-age=3600"
```

<h2 id="application-code">4. Application code</h2>

<h3 id="active-record">4.1. ActiveRecord</h2>

- The `raise_in_transactional_callbacks` option is now removed. It was
already deprecated and covered in a [previous upgrade](https://fastruby.io/blog/rails/upgrades/upgrade-rails-from-4-1-to-4-2.html).

- Also removed was `use_transactional_fixtures`, which was [replaced by](https://github.com/rails/rails/pull/19282)
`use_transactional_tests`.

- `ActiveRecord::Base#uniq` was removed, it was deprecated in Rails 5.0 and has
been replaced by `#distinct`. Check out https://github.com/rails/rails/pull/20198
for the discussion.

<h3 id="controllers">4.2. Controllers</h2>

- Before Rails 5.1, conditions in filters could be invoked using strings. They
now have to be symbols:

 Before

```ruby
  before_action :authenticate_user!, unless: 'has_project_guest_id'
```

After:

```ruby
  before_action :authenticate_user!, unless: :has_project_guest_id
```

- All `*_filter` methods are now called `*_action`:

These methods were actually already deprecated in Rails 5.0, and Rails 5.1
removes support for `*_filter` usage, so you should be using `*_action`.

Before:

```ruby
skip_before_filter :authenticate_user!
before_filter :authenticate_user!
after_filter :do_something
```

After:

```ruby
skip_before_action :authenticate_user!
before_action :authenticate_user!
after_action :do_something
```

<h2 id="testing">5. Testing</h2>

- Parameters in controller tests now need a `params` key:

Rails 5.0 had already deprecated this behavior, and Rails 5.1 drops support for
passing parameters without using keyword arguments. This change is necessary
even if you're using RSpec:

Before:

```ruby
expect { post :create, params }.to change(Project, :count).by(1)
```

After:

```ruby
expect { post :create, params: params }.to change(Project, :count).by(1)
```

<h2 id="next-steps">6. Next steps</h2>

If you successfully followed all of these steps, you should now be running Rails 5.1! Do you have any other useful tips or recommendations? Share them with us in the comments section.

If you're not on Rails 5.1 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
