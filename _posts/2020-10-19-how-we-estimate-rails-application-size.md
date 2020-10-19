---
layout: post
title: "How We Estimate The Size of a Rails Application"
date: 2020-10-19 10:00:00
categories: ["code-quality"]
author: "etagwerker"
---

When inheriting a project, it is useful to understand how big and complex the
application really is. So, what is a good way to understand whether a Rails
application is tiny, medium, or huge?

The good news is that there are a couple of gems that make this easy for us.

In this article I will explain how you can use these gems to begin to understand
the size and complexity of a Rails application.

<!--more-->

In all my examples, I will use our [open source, Ruby on Rails 6.0, dashboard
application](https://www.ombulabs.com/blog/open-source/introducing-dash.html):
[Dash](https://github.com/fastruby/dash).

## Application Size

When evaluating a Ruby or Rails application, you need to count the codebase
and its dependencies:

- Dependencies: usually, the more dependencies in your application, the harder
it is to maintain it.
- Codebase: usually, the more lines of code (LOC), the harder it is to maintain
it.

### Total Dependencies

In this section it is important to understand the difference between declared
gems and total gems:

- Declared gems: These gems are listed in your `Gemfile`. Many of them depend
on other gems.

- Total gems: These gems are all the gems that are used by your application,
either directly or indirectly.

In order to calculate this information, I will use
[`bundler-stats`](https://github.com/jmmastey/bundler-stats):

```bash
dash git:(main) $ gem install bundler-stats
Successfully installed bundler-stats-2.0.1
dash git:(main) $ bundle-stats stats
+--------------------------|------------|----------------+
|                     Name | Total Deps | 1st Level Deps |
+--------------------------|------------|----------------+
|      ombulabs-styleguide | 52         | 3              |
|                    rails | 42         | 14             |
|               sass-rails | 31         | 5              |
|              rspec-rails | 28         | 7              |
|              web-console | 25         | 4              |
|             dotenv-rails | 24         | 2              |
|        factory_bot_rails | 24         | 2              |
|                webpacker | 24         | 3              |
|              tracker_api | 19         | 9              |
| rails-controller-testing | 19         | 3              |
|          omniauth-github | 10         | 2              |
|                 capybara | 9          | 7              |
|                 jbuilder | 7          | 1              |
|    spring-watcher-listen | 6          | 2              |
|            rspec-sidekiq | 6          | 2              |
|                  webmock | 5          | 3              |
|                  octokit | 5          | 2              |
|               webdrivers | 5          | 3              |
|                  codecov | 4          | 2              |
|                   listen | 4          | 3              |
|                  sidekiq | 3          | 3              |
|                simplecov | 2          | 2              |
|       selenium-webdriver | 2          | 2              |
|                     puma | 1          | 1              |
|               turbolinks | 1          | 1              |
|                 bootsnap | 1          | 1              |
|                      vcr | 0          | 0              |
|                   spring | 0          | 0              |
|         database_cleaner | 0          | 0              |
|                   byebug | 0          | 0              |
|                  lockbox | 0          | 0              |
|                       pg | 0          | 0              |
|              tzinfo-data | 0          | 0              |
+--------------------------|------------|----------------+

      Declared Gems   33
         Total Gems   129
  Unpinned Versions   23
        Github Refs   0
```

Now we know that our application declares 33 gems in its `Gemfile`, but the
total gems is actually 129 gems.

**Total gems** is an important metric because dependencies are constantly
changing which might be an issue if you want to upgrade from Rails 6.0 to
6.1.

### Codebase (Lines of Code)

In order to calculate the lines of code in a codebase, I prefer
[`rails_stats`](https://github.com/bleonard/rails_stats) which enhances Rails's
native `rake stats`.

One of the things I like about it is that `rails_stats` doesn't need to load the
Rails environment in order to calculate all statistics. Sometimes that can be
annoying, especially when you are trying to size up a really, really old
application which requires a very specific set of dependencies (think a very
specific version of Ruby, Rails, Bundler, and Rubygems)

You can install it:

```
gem install rails_stats
```

Then you will need a `Rakefile` in the directory where you call `rake stats` and you
will need to require `rails_stats` within that file:

```ruby
# Rakefile
require "rails_stats"
```

You need to do this because `rails_stats` only provides a rake task and rake
requires a `Rakefile` to find your task definitions.

Then you can call it:

```bash
$ rake stats\[./dash\]

Directory: /Users/etagwerker/Projects/fastruby/dash

+----------------------+-------+-------+---------+---------+-----+-------+
| Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |
+----------------------+-------+-------+---------+---------+-----+-------+
| Mailers              |     4 |     4 |       1 |       0 |   0 |     0 |
| Models               |   257 |   211 |      10 |      27 |   2 |     5 |
| Workers              |   108 |    84 |       3 |      10 |   3 |     6 |
| Javascripts          |  1487 |  1462 |       0 |     188 |   0 |     5 |
| Jobs                 |     7 |     2 |       1 |       0 |   0 |     0 |
| Controllers          |    98 |    85 |       6 |      13 |   2 |     4 |
| Helpers              |    21 |    18 |       0 |       4 |   0 |     2 |
| Services             |    31 |    25 |       1 |       6 |   6 |     2 |
| Channels             |     8 |     8 |       2 |       0 |   0 |     0 |
| Configuration        |   456 |   139 |       1 |       0 |   0 |     0 |
| Spec Support         |   259 |   108 |       0 |       0 |   0 |     0 |
| Feature Tests        |    47 |    40 |       0 |       0 |   0 |     0 |
| Model Tests          |   122 |    97 |       0 |       0 |   0 |     0 |
| Worker Tests         |    77 |    53 |       0 |       0 |   0 |     0 |
| Controller Tests     |   180 |   144 |       0 |       0 |   0 |     0 |
| Other Tests          |    55 |    45 |       0 |       1 |   0 |    43 |
| Service Tests        |    33 |     0 |       0 |       0 |   0 |     0 |
+----------------------+-------+-------+---------+---------+-----+-------+
| Total                |  3250 |  2525 |      25 |     249 |   9 |     8 |
+----------------------+-------+-------+---------+---------+-----+-------+
  Code LOC: 2038     Test LOC: 487     Code to Test Ratio: 1:0.2
```

You now know that this project has **2,038 lines of code** (both Ruby and
JavaScript files) in the application directory and **487 lines of code** in
its test directory.

This is a small application. It is not tiny and it is not medium. It is
somewhere in the middle. You can find the source code over here:
[Dash on GitHub](https://github.com/fastruby/dash)

## Next Steps

This information gives you a glimpse about the project you are inheriting. You
can certainly dig deeper with other tools, but I didn't want to get into that
in this article.

If you want to dig deeper into the complexity of your application, you might
want to use [Skunk](https://github.com/fastruby/skunk) or [RubyCritic](https://github.com/whitesmith/rubycritic)
to assess the complexity within your codebase.

## Resources

If you enjoyed this article, you might like to continue reading these articles:

- [Kill your dependencies](https://www.mikeperham.com/2016/02/09/kill-your-dependencies/)
- [Combine Code Quality and Coverage to Calculate your project's SkunkScore](https://www.fastruby.io/blog/code-quality/intruducing-skunk-stink-score-calculator.html)
- [Legacy Rails: Silently Judging You](https://www.fastruby.io/blog/upgrade-rails/legacy-rails-silently-judging-you.html)