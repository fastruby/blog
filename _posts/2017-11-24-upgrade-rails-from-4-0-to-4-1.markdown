---
layout: post
title: "Upgrade Rails from 4.0 to 4.1"
date: 2017-12-06 16:31:00
categories: ["rails", "upgrades"]
author: "mauro-oto"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to get
your [Ruby on Rails](http://rubyonrails.org/) application from [version 4.0](http://guides.rubyonrails.org/4_0_release_notes.html) to [4.1](http://guides.rubyonrails.org/4_1_release_notes.html).

<!--more-->

1. [Ruby version](#ruby-version)
2. [Gems](#gems)
3. [Config files (config/)](#config-files)
4. [Application code](#application-code)
  1. [Callbacks](#callbacks)
  2. [ActiveRecord](#active-record)
5. [Tests](#tests)
6. [Miscellaneous](#miscellaneous)
7. [Next steps](#next-steps)

<h2 id="ruby-version">1. Ruby version</h2>

Rails 4.1 requires Ruby 1.9.3 or later. Ruby 1.8.7 support was dropped in
Rails 4.0, so you should already be running 1.9.3 or later. For Rails 4.1,
Ruby 2.0 (or newer) is preferred according to the [official upgrade guide](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#ruby-versions).

<h2 id="gems">2. Gems</h2>

If your application relies on [`MultiJSON`](https://github.com/intridea/multi_json),
you will need to add the gem to your `Gemfile` (`gem 'multi_json'`) if it's not
already there, since it was removed from Rails 4.1.

Alternatively, stop using MultiJSON and migrate your application to use
`to_json` and `JSON.parse`.

<h2 id="config-files">3. Config files</h2>

Rails includes the `rails:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).

As an alternative, check out [RailsDiff](http://railsdiff.org/4.0.13/4.1.16),
which provides an overview of the changes in a basic Rails app between 4.0 and
4.1 (or any other source/target versions).

<h2 id="application-code">4. Application code</h2>

<h3 id="callbacks">a. Callbacks</h2>

- Return from callbacks is no longer allowed:

Before:

```
before_save { return false }
```

After:

```
before_save { false }
```

See: [https://github.com/rails/rails/pull/13271](https://github.com/rails/rails/pull/13271)

<h3 id="active-record">b. ActiveRecord</h2>

- Removal of deprecated finders:

`activerecord-deprecated_finders` (https://github.com/rails/activerecord-deprecated_finders)
was removed as a dependency from Rails 4.1. From the gem's README:

```
To migrate dynamic finders to Rails 4.1+:

find_all_by_... should become where(...).
find_last_by_... should become where(...).last.
scoped_by_... should become where(...).
find_or_initialize_by_... should become find_or_initialize_by(...).
find_or_create_by_... should become find_or_create_by(...).
```

If you can't afford to upgrade the finders now, then add the gem back yourself
into the `Gemfile`:

```
gem 'activerecord-deprecated_finders'
```

See our [last upgrade post](https://fastruby.io/blog/rails/upgrades/upgrade-rails-from-3-2-to-4-0.html) for more information.

- Default scopes are now chained to other scopes:

If you thought default scopes on models could be confusing, there's even another
(un?)expected twist to it:

```
class User < ActiveRecord::Base
  default_scope { where active: true }
  scope :inactive, -> { where active: false }

  # ...
end

# Rails < 4.1
> User.all
SELECT "users".* FROM "users" WHERE "users"."active" = 'true'

> User.inactive
SELECT "users".* FROM "users" WHERE "users"."active" = 'false'

# Rails >= 4.1:

> User.all
SELECT "users".* FROM "users" WHERE "users"."active" = 'true'

> User.inactive
SELECT "users".* FROM "users" WHERE "users"."active" = 'true'
AND "users"."active" = 'false'
```

If you depended on this behavior, you will need to work around it using
`unscoped`, `unscope` or the new `rewhere` method ([source](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

(Friendly reminder: beware when using [default_scope](https://www.ombulabs.com/blog/ruby/rails/best-practices/why-using-default-scope-is-a-bad-idea.html))

- No more mutable methods on ActiveRecord relations:

`ActiveRecord::Relation` no longer has access to mutator methods like `#map!`,
`#delete_if` or `#compact!`. If you need to use them, you will need to convert
the `Relation` to an `Array` by calling `#to_a` first.

Before:

```
Project.where(title: 'Rails Upgrade').compact!
```

After:

```
projects = Project.where(name: 'Rails Upgrade').to_a
projects.compact!
```

- Implicit joins are removed:

Before Rails 4.1, if you had this code:

```
Post.includes(:comments).where("comments.title = 'foo'")
```

ActiveRecord 4.0 would know to join `posts` and `comments` in the executed SQL,
and it would work just fine.

However, Rails shouldn't have to be smart and parse your `where` with a regular
expression to figure out what tables you want to join, since it leads to
bugs (for example: [https://github.com/rails/rails/issues/9712](https://github.com/rails/rails/issues/9712)).

To fix this problem, you need to use an explicit join:

```
Post.joins(:comments).where("comments.title = 'foo'")
```

Unless your intention was to actually eager load the post's comments.
In that case, you can use the following syntax:

```
Post.eager_load(:comments).where("comments.title = 'foo'")
```

Or:

```
Post.includes(:comments).where("comments.title = 'foo'").references(:comments)
```

Both are equivalent and produce the same SQL.

For a more in depth explanation of the differences between `joins`, `includes`,
`references`, `eager_load` and even `preload`, [check out this post](http://blog.ifyouseewendy.com/blog/2015/11/11/preload-eager_load-includes-references-joins/).

Finally, if you get this deprecation warning:

```
DEPRECATION WARNING: Implicit join references were removed with Rails 4.1. Make sure to remove this configuration because it does nothing.
```

Just remove `config.active_record.disable_implicit_join_references` from your
config files.

<h2 id="tests">5. Tests</h2>

- [CSRF protection](http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf) now covers GET requests with JS responses:

If your tests hit JS URLs, you'll need to use `xhr` instead of `get`:

Before:

```
post :create, format: :js
```

After:

```
xhr :post, :create, format: :js
```

See: [https://github.com/rails/rails/pull/13345](https://github.com/rails/rails/pull/13345)

<h2 id="miscellaneous">6. Miscellaneous</h2>

- Flash message keys are strings now:

If you were using the `flash` hash or its keys and expected symbols,
you will need to use strings now:

Before:

```
flash.to_hash.except(:notify)
```

After:

```
flash.to_hash.except("notify")
```

<h2 id="next-steps">7. Next steps</h2>

If you successfully followed all of these steps, you should now be running Rails 4.1! Do you have any other tips? Share it with us in the comments section.

If you don't have the time to upgrade your Rails app, check out our [Ruby on Rails
upgrade](https://fastruby.io) service: [FastRuby.io](https://fastruby.io)
