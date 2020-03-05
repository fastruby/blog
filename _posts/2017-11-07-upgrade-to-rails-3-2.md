---
layout: post
title:  "Upgrade Rails from 3.1 to 3.2"
date: 2017-11-07 09:30:00
reviewed: 2020-03-05 10:00:00
categories: ["rails", "upgrades"]
author: "luciano"
---

This is the third article of our [Upgrade Rails series](https://fastruby.io/blog/tags/upgrades). We will be covering the most important aspects that you need to know to update your [Ruby on Rails](http://rubyonrails.org/) application from [version 3.1](http://guides.rubyonrails.org/3_1_release_notes.html) to [3.2](http://guides.rubyonrails.org/3_2_release_notes.html).

<!--more-->

1. [Considerations](#considerations)
2. [Ruby version](#ruby-version)
3. [Tools](#tools)
4. [Config files](#config-files)
5. [Gemfile](#gemfile)
6. [Deprecations](#deprecations)
7. [Next steps](#next-steps)


<h2 id="considerations">1. Considerations</h2>
Before beginning with the upgrade process, we recommend that each version of your Rails app has the latest [patch version](http://semver.org) before moving to the next major/minor version. For example, in order to follow this article, your [Rails version](https://rubygems.org/gems/rails/versions) should be at 3.1.12 before updating to Rails 3.2.22

<h2 id="ruby-version">2. Ruby version</h2>
Depending on which patch version of Rails 3.2 you are using, the [Ruby versions](https://www.ruby-lang.org/en/downloads/releases/) that you can use will change. Since we recommend you to always use the latest patch version, we will focus this article on [Rails 3.2.22](http://weblog.rubyonrails.org/2015/6/16/Rails-3-2-22-4-1-11-and-4-2-2-have-been-released-and-more/). The minor Ruby version that you can use is [1.8.7](https://www.ruby-lang.org/en/news/2008/05/31/ruby-1-8-7-has-been-released), and the latest one is [2.2](https://www.ruby-lang.org/en/news/2014/12/25/ruby-2-2-0-released/). As always, we recommend you to use the latest version to avoid any bugs or vulnerabilities.

<h2 id="tools">3. Tools</h2>
Rails 3.2 comes with a [generator](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task) that helps you to update the configuration files. The `rake rails:update` generator will identify every configuration file in your application that differs from a new Rails application. When it detects a conflict, it will offer to overwrite your file. Keep in mind that many of your files will be different because you’ve made changes from a default new Rails application. When the generator offers to overwrite a file, enter a `d` in order to review the differences.

Sometimes it's also useful to check which files changed between two specific versions of Rails. Fortunately [Rails Diff](http://railsdiff.org/3.1.12/3.2.22.5) makes that easy.

<h2 id="config-files">4. Config files</h2>
There are a few settings that you need to add to your environment filters

- Add to `config/environments/development.rb`

```
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict

# Log the query plan for queries taking more than this (works
# with SQLite, MySQL, and PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

- Add to `config/environments/test.rb`

```
# Raise exception on mass assignment protection for Active Record models
config.active_record.mass_assignment_sanitizer = :strict
```

<h2 id="gemfile">5. Gemfile</h2>

- You should update a couple of gems inside your assets group

```
gem "rails", "~> 3.2.0"

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

<h2 id="deprecations">6. Deprecations</h2>

Rails 3.2 deprecates `vendor/plugins`, and it's the last Rails version that support it. If your plan is to migrate to Rails 4 in the future, you can start replacing any plugins by extracting them to gems and adding them to your `Gemfile`, or you can move them into `lib/my_plugin/*`. We cover this topic in depth in our Rails 4.0 upgrade guide.

<h2 id="next-steps">7. Next steps</h2>
After you get your application properly running in Rails 3.2, you will probably want to keep working on this Rails upgrade journey. So don't forget to check our complete [Rails upgrade series](https://fastruby.io/blog/tags/upgrades) to make that easy.

If you're not on Rails 3.2 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
