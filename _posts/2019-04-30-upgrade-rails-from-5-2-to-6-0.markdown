---
layout: post
title: "Upgrade Rails from 5.2 to 6.0"
date: 2019-04-30 15:00:00
categories: ["rails", "upgrades"]
author: "luciano"
---

_This article is part of our Upgrade Rails series. To see more of them, [click here](https://fastruby.io/blog/tags/upgrades)_.

This article will cover the most important aspects that you need to know to get
your [Ruby on Rails](http://rubyonrails.org/) application from [version 5.2](http://guides.rubyonrails.org/5_2_release_notes.html) to [6.0](https://edgeguides.rubyonrails.org/6_0_release_notes.html).

<!--more-->

1. [Considerations](#considerations)
2. [Ruby version](#ruby-version)
3. [Gems](#gems)
4. [Config files](#config-files)
5. [Removals](#removals)
  - [Railties](#railties)
  - [Action Pack](#action-pack)
  - [Action View](#action-view)
  - [Active Record](#active-record)
6. [Webpacker](#webpacker)
7. [Credentials](#credentials)
8. [Next steps](#next-steps)

<h3 id="considerations">1. Considerations</h3>

Before beginning with the upgrade process, we recommend that each version of your Rails app has the latest [patch version](http://semver.org) before moving to the next major/minor version. For example, in order to follow this article, your [Rails version](https://rubygems.org/gems/rails/versions) should be at [5.2.3](https://rubygems.org/gems/rails/versions/5.2.3) before upgrading to Rails 6.0.x

<h3 id="ruby-version">2. Ruby version</h3>

[Rails 6.0](https://weblog.rubyonrails.org/2019/1/18/Rails-6-0-Action-Mailbox-Action-Text-Multiple-DBs-Parallel-Testing/) requires [Ruby 2.5](https://www.ruby-lang.org/en/news/2017/12/25/ruby-2-5-0-released/) or later. Check out [this table](https://fastruby.io/blog/ruby/rails/versions/compatibility-table.html) to see all the required Ruby versions across all Rails versions.

<h3 id="gems">3. Gems</h3>

Make sure you check the Github page of the gems you use for the project to find out its compatibility with Rails 6.0. In case you own the gem, you'll need to make sure it supports Rails 6.0 and if it doesn't, update it.

<h3 id="config-files">4. Config files</h3>

Rails includes the `rails app:update` [task](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task).
You can use this task as a guideline as explained thoroughly in
[this post](http://thomasleecopeland.com/2015/08/06/running-rails-update.html).

As an alternative, check out [RailsDiff](http://railsdiff.org/5.2.3/6.0.0.rc1),
which provides an overview of the changes in a basic Rails app between 5.2.x and
6.0.x (or any other source/target versions).

<h3 id="removals">5. Removals</h3>

<h5 id="railties">Railties</h5>

- [Remove deprecated](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7) `after_bundle` helper inside plugins templates.

- [Remove deprecated](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b) support to `config.ru` that uses the application class as argument of `run`.

- [Remove deprecated](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571) `environment` argument from the rails commands.

- [Remove deprecated](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17) `capify!` method in generators and templates.

- [Remove deprecated](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0) `config.secret_token`.

<h5 id="action-pack">Action Pack</h5>

- [Remove deprecated](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc) `fragment_cache_key` helper in favor of `combined_fragment_cache_key`.

- [Remove deprecated](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1) methods in `ActionDispatch::TestResponse: #success?` in favor of `#successful?`, `#missing?` in favor of `#not_found?`, `#error?` in favor of `#server_error`?

<h5 id="action-view">Action View</h5>

- [Remove deprecated](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f) `image_alt` helper.

- [Remove](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31) an empty `RecordTagHelper` module from which the functionality was already moved to the `record_tag_helper` gem.

<h5 id="active-record">Active Record</h5>

- [Remove deprecated](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983) `#set_stat` from the transaction object.

- [Remove deprecated](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553) `#supports_statement_cache?` from the database adapters.

- [Remove deprecated](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece) `#insert_fixtures` from the database adapters.

- [Remove deprecated](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf) `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`.

- [Remove support](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9) for passing the column name to `sum` when a block is passed.

- [Remove support](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129) for passing the column name to `count` when a block is passed.

- [Remove support](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0) for delegation of missing methods in a relation to arel.

- [Remove support](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d) for delegating missing methods in a relation to private methods of the class.

- [Remove support](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea) for specifying a timestamp name for #cache_key.

- [Remove deprecated](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d) `ActiveRecord::Migrator.migrations_path=`.

- [Remove deprecated](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e) `expand_hash_conditions_for_aggregates`.

<h3 id="webpacker">6. Webpacker</h3>

[Webpacker](https://github.com/rails/webpacker) is [now](https://github.com/rails/rails/pull/33079) the default JavaScript compiler for Rails 6. You can still manage your JavaScript using the [Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html) but it might be a good idea to start migrating to Webpack.

There is a really good screencast that explains everything about it: [How to Use Javascript via Webpacker in Rails 6](https://www.youtube.com/watch?v=Hz8d6zPDSrk)

<h3 id="credentials">7. Credentials</h3>

Rails 6 [adds support](https://github.com/rails/rails/pull/33521) for multi environment credentials. That means that now you can run `rails credentials:edit --environment staging` and it will create a `config/credentials/staging.yml.enc` file where you can store your encrypted credentials for staging (or whatever environment you want).
Rails will know which credential file should use based on the format of the file. Also, if you create an environment credential file, it will take precedence over the default `config/credentials.yml.enc`.

<h3 id="next-steps">8. Next steps</h3>

If you successfully followed all of these steps, you should now be running Rails 6.0! Do you have any other useful tips or recommendations? Did we miss anything important? Share them with us in the comments section.

If you're not on Rails 6.0 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
