---
layout: post
title:  "Upgrade Rails from 3.0 to 3.1"
date: 2017-10-16 09:30:00
categories: ["rails", "upgrades"]
author: "luciano"
---

This is the second article of our [Upgrade Rails series](https://fastruby.io/blog/tags/upgrades). We will be covering the most important aspects that you need to know to update your [Ruby on Rails](http://rubyonrails.org/) application from [version 3.0](http://guides.rubyonrails.org/3_0_release_notes.html) to [3.1](http://guides.rubyonrails.org/3_1_release_notes.html). If you are in an older version, you can take a look at our [previous article](https://fastruby.io/blog/rails/upgrades/upgrade-to-rails-3.html).

<!--more-->

1. [Considerations](#considerations)
2. [Ruby version](#ruby-version)
3. [Tools](#tools)
4. [Config files](#config-files)
5. [jQuery](#jquery)
6. [Asset Pipeline](#asset_pipeline)
7. [Next steps](#next-steps)


<h2 id="considerations">1. Considerations</h2>
Before beginning with the upgrade process, we recommend that each version of your Rails app has the latest [patch version](http://semver.org) before moving to the next major/minor version. For example, in order to follow this article, your [Rails version](https://rubygems.org/gems/rails/versions) should be at 3.0.20 before updating to Rails 3.1.12

<h2 id="ruby-version">2. Ruby version</h2>
Rails 3.1 requires Ruby [1.8.7](https://www.ruby-lang.org/en/news/2008/05/31/ruby-1-8-7-has-been-released) or higher, but no more than [1.9.3](https://www.ruby-lang.org/en/news/2011/10/31/ruby-1-9-3-p0-is-released). If you want to use Ruby 1.9.x, we recommend you skip directly to 1.9.3. Also Ruby [1.9.1](https://www.ruby-lang.org/en/news/2009/01/30/ruby-1-9-1-released) is not usable because it has segmentation faults on Rails 3.1. That means that the compatible [Ruby versions](https://www.ruby-lang.org/en/downloads/releases/) for Rails 3.1 are 1.8.7, [1.9.2](https://www.ruby-lang.org/en/news/2010/08/18/ruby-1-9-2-released), or 1.9.3. Keep in mind that the next Rails version (3.2) will be the last one that supports Ruby 1.8.7 and 1.9.2.

<h2 id="tools">3. Tools</h2>
Rails 3.1 comes with a generator that helps the upgrade process. You just need to run `rake rails:update` to see a [guide](https://gist.github.com/ryanb/1101906) that details how to upgrade your application.

Sometimes it's also useful to check which files changed between two specific versions of Rails. Fortunately [Rails Diff](http://railsdiff.org/3.0.20/3.1.12) makes that easy.

<h2 id="config-files">4. Config files</h2>
- You should **remove** any references to `ActionView::Base.debug_rjs` in your project.

```
# (config/environments/development.rb)

config.action_view.debug_rjs = true
```

- If you want to wrap parameters into a nested hash add a `config/initializers/wrap_parameters.rb` file with the following contents. This file comes by default in new applications.

```
# Be sure to restart your server when you modify this file.
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters :format => [:json]
end

# Disable root element in JSON by default.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

<h2 id="jquery">5. jQuery</h2>
[jQuery](https://jquery.com/) is the default JavaScript library that comes with Rails 3.1.

To add this you need to include the [jquery-rails](https://github.com/rails/jquery-rails) gem in your [Gemfile](https://bundler.io/gemfile.html)

```
gem 'jquery-rails'
```

And then include the libraries in your `app/assets/javascripts/application.js`

```
//= require jquery
//= require jquery_ujs
```

So now you can get rid of your jQuery assets like `jquery.js` or `jquery.min.js`.

<h2 id="asset_pipeline">6. Asset Pipeline</h2>
[Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html) is an optional feature in Rails 3.1, but we recommend to include it to take advantage of it. In order to do that, you should apply the following changes:

- Add to your `Gemfile`:

```
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end
```

- Update your `config/application.rb`

```
config.assets.enabled = true
config.assets.version = '1.0'

# Defaults to '/assets'
config.assets.prefix = '/asset-files'
```

- Update your `config/environments/development.rb`

```
# Do not compress assets
config.assets.compress = false

# Expands the lines which load the assets
config.assets.debug = true
```

- Update your `config/environments/production.rb`

```
# Compress JavaScripts and CSS
config.assets.compress = true

# Don't fallback to assets pipeline if a precompiled asset is missed
config.assets.compile = false

# Generate digests for assets URLs
config.assets.digest = true

# Defaults to Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
# config.assets.precompile = %w( admin.js admin.css )
```

- Update your `config/environments/test.rb`

```
# Configure static asset server for tests with Cache-Control for performance
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

<h2 id="next-steps">7. Next steps</h2>
After you get your application properly running in Rails 3.1, you will probably want to keep working on this Rails upgrade journey. So don't forget to check our complete [Rails upgrade series](https://fastruby.io/blog/tags/upgrades) to make that easy.

If you're not on Rails 6.0 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
