---
layout: post
title:  "Upgrade Rails from 2.3 to 3.0"
date: 2017-08-28 16:06:00
categories: ["rails", "upgrades"]
author: "luciano"
---

This article is the first of our [Upgrade Rails series](https://fastruby.io/blog/tags/upgrades). We will be covering the most important aspects that you need to know to update your [Ruby on Rails](http://rubyonrails.org) application from [version 2.3](http://guides.rubyonrails.org/2_3_release_notes.html) to [3.0](http://guides.rubyonrails.org/3_0_release_notes.html).

<!--more-->

1. [Considerations](#considerations)
2. [Ruby version](#ruby-version)
3. [Tools](#tools)
4. [XSS protection](#xss-protection)
5. [Config files](#config-files)
6. [Gems](#gems)
7. [Deprecations](#deprecations)
  - [Active Record](#active-record)
  - [Action Mailer](#action-mailer)
  - [Metal](#metal)
  - [Railties](#railties)
8. [Next steps](#next-steps)

<h2 id="considerations">1. Considerations</h2>
Before beginning with the upgrade process, we recommend that each version of your Rails app has the latest [patch version](http://semver.org) before moving to the next major/minor version. For example, in order to follow this article, your [Rails version](https://rubygems.org/gems/rails/versions) should be at 2.3.18 before updating to Rails 3.0.20

<h2 id="ruby-version">2. Ruby version</h2>
Rails 3.0 requires Ruby [1.8.7](https://www.ruby-lang.org/en/news/2008/05/31/ruby-1-8-7-has-been-released) or higher, but no more than [1.9.3](https://www.ruby-lang.org/en/news/2011/10/31/ruby-1-9-3-p0-is-released). If you want to use Ruby 1.9.x, we recommend you skip directly to 1.9.3. Also Ruby [1.9.1](https://www.ruby-lang.org/en/news/2009/01/30/ruby-1-9-1-released) is not usable because it has segmentation faults on Rails 3.0. That means that the compatible [Ruby versions](https://www.ruby-lang.org/en/downloads/releases/) for Rails 3.0 are 1.8.7, [1.9.2](https://www.ruby-lang.org/en/news/2010/08/18/ruby-1-9-2-released), or 1.9.3.

<h2 id="tools">3. Tools</h2>
There is an [official plugin](https://github.com/rails/rails_upgrade) that helps the upgrade process. You just need to install the script by doing `script/plugin install git://github.com/rails/rails_upgrade.git` and then run `rake rails:upgrade:check` to see most of the files you need to upgrade in your application. It also provides some other generators to upgrade specific areas in you app like routes or gems.

Sometimes it's also useful to check which files changed between two specifics versions of Rails. Fortunately [Rails Diff](http://railsdiff.org/2.3.18/3.0.0) makes that easy.

<h2 id="xss-protection">4. XSS protection</h2>
In this version, Rails automatically adds [XSS protection](http://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/) in order to escape any content, so you will probably need to update your templates according to this. Luckily there is an [official plugin](https://github.com/rails/rails_xss) for this. We recommend you take a look at this.

<h2 id="config-files">5. Config files</h2>
Rails 3 introduces the concept of an Application object. An application object holds all the specific application configurations and it's similar to the current config/environment.rb from Rails 2.3. The application object is defined in config/application.rb. You should move there most of the configuration that you had in config/environment.rb.

In terms of routes, there are a couple of changes that you need to apply to your routes.rb file. For example:

```
# Rails 2.3 way:
ActionController::Routing::Routes.draw do |map|
  map.resources :products
end

# Rails 3.0 way:
AppName::Application.routes do
  resources :products
end
```
You can go to [this article](https://blog.engineyard.com/2010/the-lowdown-on-routes-in-rails-3) to read an in-depth article about this topic.

<h2 id="gems">6. Gems</h2>
[Bundler](https://bundler.io/) is the default way to manage Gem dependencies in Rails 3 applications. You will need to add a [Gemfile](https://bundler.io/v1.15/gemfile_man.html) in the root of your app, define all you gems there, and then get rid of the config.gem statements.

```
# Before:
config.gem 'aws-sdk',  :version => '1.0.0' # (config/environment.rb)

config.gem 'pry', :version => ['>= 0.6.0', '< 0.7.0'] # (config/development.rb)

# Now:
(Gemfile)

gem 'aws-sdk', '1.0.0'

group :development do
  gem 'pry', '~> 0.6.0'
end

```

Remember that if you installed the plugin mentioned in step 3, you can run `rake rails:upgrade:gems`. This task will extract your config.gem calls and generate code that you can put in your Gemfile.

<h2 id="deprecations">6. Deprecations</h2>
There are a bunch of deprecations that happen during this version:

<h3 id="active-record">Active Record</h3>
- The method to define a named scope is now called `scope` instead of `named_scope`.

- In scope methods, you no longer pass the conditions as a hash:

```
# Before:
named_scope :active, :conditions => ["active = ?", true]

# Now:
scope :active, where("active = ?", true)
```

- `save(false)` is deprecated, so you should use `save(:validate => false)`.

- I18n error messages for Active Record should be changed from `:en.activerecord.errors.template` to `:en.errors.template`.

- `model.errors.on` is deprecated in favor of `model.errors[]`

- There is a new syntax for presence validations:

```
# Before:
validates_presence_of :email

# Now:
validates :email, presence: true
```

- `ActiveRecord::Base.colorize_logging` and `config.active_record.colorize_logging` are deprecated in favor of `Rails::LogSubscriber.colorize_logging` or `config.colorize_logging`.

<h3 id="action-mailer">Action Mailer</h3>
- `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` are all deprecated in favor of `ActionMailer.default :key => value` style declarations.
- Mailer dynamic `create_method_name` and `deliver_method_name` are deprecated, just call `method_name` which now returns a `Mail::Message` object.

```
# Before:
message = UserMailer.create_welcome_email(user)
UserMailer.deliver(message)

or

UserMailer.deliver_welcome_email(user)

# Now:
UserMailer.welcome_email(user).deliver
```
- `template_root` is deprecated, pass options to a render call inside a proc from the `format.mime_type` method inside the mail generation block.
- The body method to define instance variables is deprecated (`body {:ivar => value}`), just declare instance variables in the method directly and they will be available in the view.

```
# Before:
def welcome_email(user)
  ...
  body {:user => user, :url => "https://fastruby.io"}
end

# Now:
def welcome_email(user)
  ...
  @user = user
  @url = "https://fastruby.io"
end
```
- Mailers should now be in app/mailers instead of app/models.

<h3 id="metal">Metal</h3>
Since Rails 3 is closer to [Rack](http://guides.rubyonrails.org/rails_on_rack.html), the [Metal](http://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal/) abstraction is no longer needed.

This is the [official explanation](https://github.com/rails/rails/commit/ed34652d1aca148fea61c5309c1bd5ff3a55abfa) of what you need to do to update your existing Metals:

- If your metal behaves like a middleware, add it to the middleware stack via config.middleware.use. You can use methods on the middleware stack to control exactly where it should go.
- If it behaves like a Rack endpoint, you can link to it in the router. This will result in more optimal routing time, and allows you to remove code in your endpoint that matches specific URLs in favor of the more powerful handling in the router itself.

For the future, you can use ActionController::Metal to get a very fast controller with the ability to opt-in to specific controller features without paying the penalty of the full controller stack.

<h3 id="railties">Railties</h3>
[Railties](http://api.rubyonrails.org/classes/Rails/Railtie.html) deprecates the following constants during this version:

- `RAILS_ROOT` in favor of `Rails.root`
- `RAILS_ENV` in favor of `Rails.env`
- `RAILS_DEFAULT_LOGGER` in favor of `Rails.logger`

Also, `PLUGIN/rails/tasks` and `PLUGIN/tasks` are no longer loaded all tasks, now must be in `lib/tasks`.

```
# Before:
vendor/plugins/ombulabs_patches/tasks/s3_backup.rake

# Now:
lib/tasks/ombulabs_patches/s3_backup.rake
```

<h2 id="next-steps">8. Next steps</h2>
After you get your application properly running in Rails 3.0, you will probably want to keep working on this Rails upgrade journey. So don't forget to check our complete [Rails upgrade series](https://fastruby.io/blog/tags/upgrades) to make that easy.

If you're not on Rails 6.0 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
