---
layout: post
title: "Upgrade Rails from 3.2 to 4.0"
date: 2017-11-08 12:42:00
categories: ["rails", "upgrades"]
author: "mauro-oto"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

A [previous post](https://fastruby.io/blog/rails/tips-for-upgrading-rails-3-2-to-4.html)
covered some general tips to take into account for this migration. This article
will try to go a bit more in depth. We will first go from 3.2 to 4.0, then to
4.1 and finally to 4.2. Depending on the complexity of your app, a Rails upgrade
can take anywhere from one week for a single developer, to a few months for two
developers.

<!--more-->

1. [Ruby version](#ruby-version)
2. [Gems](#gems)
3. [Config files (config/)](#config-files)
4. [Application code](#application-code)
  1. [Models (app/models/)](#models)
  2. [Controllers (app/controllers/)](#controllers)
5. [Tests](#tests)
6. [Miscellaneous](#miscellaneous)
7. [Next steps](#next-steps)

<h2 id="ruby-version">1. Ruby version</h2>

Rails 3.2.x is the last version to support Ruby 1.8.7. If you're using Ruby 1.8.7,
you'll need to upgrade to Ruby 1.9.3 or newer. The Ruby upgrade is not covered
in this guide, but check out [this guide](http://www.darkridge.com/~jpr5/2012/10/03/ruby-1.8.7-1.9.3-migration) for more details on that.

<h2 id="gems">2. Gems</h2>

You can add the aptly named [rails4_upgrade gem](https://github.com/alindeman/rails4_upgrade)
to your Rails 3 project's Gemfile and find gems which you'll need to update:

```
➜  myproject git:(develop) ✗ bundle exec rake rails4:check

** GEM COMPATIBILITY CHECK **
+------------------------------------------+----------------------------+
| Dependency Path                          | Rails Requirement          |
+------------------------------------------+----------------------------+
| devise 2.1.4                             | railties ~> 3.1            |
| devise-encryptable 0.2.0 -> devise 2.1.4 | railties ~> 3.1            |
| friendly_id 4.0.10.1                     | activerecord < 4.0, >= 3.0 |
| strong_parameters 0.2.3                  | actionpack ~> 3.0          |
| strong_parameters 0.2.3                  | activemodel ~> 3.0         |
| strong_parameters 0.2.3                  | activesupport ~> 3.0       |
| strong_parameters 0.2.3                  | railties ~> 3.0            |
+------------------------------------------+----------------------------+
```

Instead of going through your currently bundled gems or `Gemfile.lock` manually,
you get a report of the gems you need to upgrade.

<h2 id="config-files">3. Config files</h2>

Rails includes the `rails:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).
It will help you get rid of unnecessary code or monkey-patches in your config
files and initializers, specially if your Rails 3 app was running on Rails 2.

As an alternative, check out [RailsDiff](http://railsdiff.org/3.2.22.5/4.0.13),
which provides an overview of the changes in a basic Rails app between 3.2 and
4.0 (or any other source/target versions).

If you're feeling adventurous, you
can give [this script](https://github.com/bsodmike/upgrade_rails_3.2.12_to_4.0.0.beta1)
a try. It attempts to apply [this git patch](https://github.com/bsodmike/upgrade_rails_3.2.12_to_4.0.0.beta1/blob/master/upgrade/upgrade.patch)
(similar to the patch shown on RailsDiff) to your Rails app to migrate from 3.2
to 4.0. However, I don't recommend this for complex or mature apps, as there
will be plenty of conflicts.

<h2 id="application-code">4. Application code</h2>

<h2 id="models">a. Models</h2>

- All dynamic finder methods except for `.find_by_...` are deprecated:

```ruby
# before:
Authentication.find_all_by_provider_and_uid(provider, uid)

# after:
Authentication.where(provider: provider, uid: uid)
```

You can regain usage of these finders by adding the gem
[activerecord-deprecated_finders](https://github.com/rails/activerecord-deprecated_finders)

- ActiveRecord scopes now need a lambda:

```ruby
# before:
default_scope where(deleted_at: nil)

# after:
default_scope { where(deleted_at: nil) }

# before:
has_many :posts, order: 'position'

# after:
has_many :posts, -> { order('position') }
```

(Friendly reminder: beware when using [default_scope](https://www.ombulabs.com/blog/ruby/rails/best-practices/why-using-default-scope-is-a-bad-idea.html))

- Protected attributes is deprecated, but you can still add the [protected_attributes](https://github.com/rails/protected_attributes) gem.
However, since the Rails core team dropped its support since Rails 5.0, you
should begin migrating your models to [Strong Parameters](http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters) anyway.

To do so, you will need to remove calls to `attr_accessible` from your models,
and add a new method to your model's controller with a name like `user_params`
or `your_model_params`:

```ruby
class UsersController < ApplicationController
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
```

Finally, change (most) references to `params[:user]` to `user_params` in your
controller's actions. If the reference is for an update or a creation, like
`user.update_attributes(params[:user])`, change it to `user.update_attributes(user_params)`.
This new method permits using the `name` and `email` attributes of the user
model and disallows writing any other attribute the user model may have (like `id`).

- ActiveRecord Observers were removed from the Rails 4.0 codebase and extracted
into a gem. You can regain usage by adding the gem to your Gemfile:

```ruby
gem 'rails-observers' # https://github.com/rails/rails-observers
```

As an alternative, you can take a look at the [wisper gem](https://github.com/krisleech/wisper),
or Rails' Concerns (which were added in Rails 4.0) for a slightly different
approach.

- ActiveResource was removed and extracted into its own gem:

```ruby
gem 'active_resource' # https://github.com/rails/activeresource
```

<h2 id="controllers">b. Controllers</h2>

- ActionController Sweeper was extracted into the `rails-observers` gem, you can
regain usage by adding the gem to your Gemfile:

```ruby
gem 'rails-observers' # https://github.com/rails/rails-observers
```

- Action caching was extracted into its own gem, so if you're using this feature
through either:

```ruby
caches_page   :public
```

or:

```ruby
caches_action :index, :show
```

You will need to add the gem:

```ruby
gem 'actionpack-action_caching' # https://github.com/rails/actionpack-action_caching
```

<h2 id="tests">5. Tests</h2>

From Ruby 1.9.x onwards, you have to include the [`test-unit` gem](https://rubygems.org/gems/test-unit)
in your Gemfile as it was removed from the standard lib. As an alternative,
migrate to `Minitest`, `RSpec` or your favorite test framework.

<h2 id="miscellaneous">6. Miscellaneous</h2>

- Routes now require you to specify the request method, so you no longer can
rely on the catch-all default.

```ruby
# change:
match '/home' => 'home#index'

# to:
match '/home' => 'home#index', via: :get

# or:
get '/home' => 'home#index'
```

- Rails 4.0 dropped support for plugins, so you'll need to replace them with gems,
either by searching for the project on [RubyGems](https://rubygems.org)/[Github](https://github.com),
or by moving the plugin to your `lib` directory and require it from somewhere
within your Rails app.

<h2 id="next-steps">7. Next steps</h2>

If you successfully followed all of these steps, by now you should be running Rails 4.0!

To fine-tune your app, check out [FastRuby.io](https://fastruby.io), and feel
free to tell us how your upgrade went.

If you're not on Rails 6.0 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
