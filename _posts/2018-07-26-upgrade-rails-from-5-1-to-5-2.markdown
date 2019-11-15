---
layout: post
title: "Upgrade Rails from 5.1 to 5.2"
date: 2018-08-14 12:42:00
categories: ["rails", "upgrades"]
author: "mauro-oto"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to get
your [Ruby on Rails](http://rubyonrails.org/) application from [version 5.1](http://guides.rubyonrails.org/5_1_release_notes.html) to [5.2](http://guides.rubyonrails.org/5_2_release_notes.html).

<!--more-->

1. [Ruby version](#ruby-version)
2. [Gems](#gems)
3. [Config files](#config-files)
4. [Application code](#application-code)
  1. [Active Storage](#active-storage)
  2. [Credentials](#credentials)
5. [Next steps](#next-steps)

<h2 id="ruby-version">1. Ruby version</h2>

Like Rails 5.0 and 5.1, [Rails 5.2](https://weblog.rubyonrails.org/2018/4/9/Rails-5-2-0-final/) requires at least [Ruby 2.2.2](https://www.ruby-lang.org/en/news/2015/04/13/ruby-2-2-2-released/).

<h2 id="gems">2. Gems</h2>

At the time of writing, the Rails 5.2 release is relatively recent, which
means that some gems may still not be fully compatible, or contain deprecation
warnings if you're not using their latest version. [Ready4Rails](http://www.ready4rails.net)
can help you check if the gem is compatible with Rails 5.0, but it may have
annoying bugs/deprecation warnings on 5.2. Some (popular) gem examples are:

- [friendly_id](https://rubygems.org/gems/friendly_id) supports Rails 5.2 without deprecation warnings on the latest release, 5.2.4. [\[PR\]](https://github.com/norman/friendly_id/pull/849)
- [activeadmin](https://rubygems.org/gems/activeadmin) supports Rails 5.2 without deprecation warnings on the latest release, 1.3.0. [\[PR\]](https://github.com/activeadmin/activeadmin/pull/5343)
- [acts-as-taggable-on](https://rubygems.org/gems/acts-as-taggable-on) added deprecation-free Rails 5.2 without warnings on the latest release, 6.0.0. [\[PR\]](https://github.com/mbleigh/acts-as-taggable-on/pull/887)
- [awesome\_nested\_set](https://rubygems.org/gems/awesome_nested_set) supports Rails 5.2 without deprecation warnings on the latest release, 3.1.4. [\[PR\]](https://github.com/collectiveidea/awesome_nested_set/pull/383)
- [jbuilder](https://rubygems.org/gems/jbuilder/) supports Rails 5.2 _with_ deprecation warnings on the latest release, 2.7.0. [\[PR\] (not yet in a release)](https://github.com/rails/jbuilder/pull/430)

<h2 id="config-files">3. Config files</h2>

Rails includes the `rails app:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).

As an alternative, check out [RailsDiff](http://railsdiff.org/5.1.6/5.2.0),
which provides an overview of the changes in a basic Rails app between 5.1.x and
5.2.x (or any other source/target versions).

<h2 id="application-code">4. Application code</h2>

There were not too many deprecations between 5.1 and 5.2 compared to past
releases ([see the full changelog here](https://guides.rubyonrails.org/5_2_release_notes.html#upgrading-to-rails-5-2)).

However, one major feature is the introduction of [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html).

<h3 id="active-storage">a. Active Storage</h2>

Active Storage is a replacement for [Paperclip](https://rubygems.org/gems/paperclip/)
and other gems, like [Shrine](https://github.com/shrinerb/shrine). Paperclip in
particular [has been deprecated](https://github.com/thoughtbot/paperclip#deprecated).
If you're using Paperclip, the maintainers wrote an in-depth migration guide
which you can [follow here](https://github.com/thoughtbot/paperclip/blob/master/MIGRATING.md).

<h3 id="credentials">b. Credentials</h2>

Another major feature is the introduction of Credentials. It will eventually
replace the current `config/secrets.yml`. Since there are also encrypted
secrets (`config/secrets.yml.enc`), its intention is to clear up the confusion.

Your private credentials will reside in `config/credentials.yml.enc`, a file
that can be safely committed into your repository (its contents are encrypted).
To un-encrypt them, there's a master key (`config/master.key`) which should
*NOT* be in your repository (it's git-ignored by default if you start a new
Rails 5.2 app). To edit the credentials, you don't directly access
`credentials.yml.enc`, instead, there's a `bin/rails credentials:edit` task
which opens an unencrypted version of the file (as long as you have the master
key).

One controversial aspect of it is the [cross-environment credential sharing](https://github.com/rails/rails/issues/31349),
the credentials file will keep all of your development, test and production keys.
For more information on Credentials and a work-around to this last issue, check
out [this post](https://blog.eq8.eu/til/rails-52-credentials-tricks.html), where
they use `Hash#dig` to configure per-environment credentials.

<h2 id="next-steps">5. Next steps</h2>

If you successfully followed all of these steps, you should now be running Rails 5.2! Do you have any other useful tips or recommendations? Did we miss anything? Share them with us in the comments section.

If you're not on Rails 6.0 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
