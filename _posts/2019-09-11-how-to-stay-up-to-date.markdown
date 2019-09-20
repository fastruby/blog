---
layout: post
title: How to Stay Up to Date with Your Rails Application
date: 2019-08-27 13:56:00
categories: ["Rails", "Upgrades"]
author: bronzdoc
---

An outdated Rails application doesn't happen overnight. In FastRuby.io we work with a lot of clients who have outdated Rails applications and we help them upgrade to a newer Rails version. In this article I share some things that you could start doing to avoid falling out of date.

<!--more-->

### Stop monkey patching

In our experience having monkey-patched gems is usually one of the hardest things to deal with. We have to spend hours updating monkey-patched gems to make them compatible with newer Rails APIs. So please keep that in mind before monkey patching Rails core libraries or gems that depend on specific Rails versions.

### Start treating deprecations warnings as errors

In Rails you can configure this option, so everytime a deprecation warning occurs you can address it as soon as you can.
This will help you to fix the issue immediately and be prepared for the next version jump.

You will need to add the following configuration in your `config/environments/test.rb` and `config/environments/test.rb` files.

```ruby
  # Raise error on deprecation¬
  config.active_support.deprecation = :raise
```

### Dual Boot

One of the first things we do at FastRuby.io when we start a new Rails upgrade project is to setup a "Dual Boot" Gemfile.
What this setup will do is allow you to have two Gemfile.lock files, one for the latest version of Rails and one for your current version of Rails.

With this setup you will be able to configure your CI to run both versions of Rails. As long as you "mark" the Rails master build job as "optional" it won't block your PR merges. You will have the chance to see how your test behaves with the latest version of Rails.

We even wrote a [blog post](https://www.fastruby.io/blog/upgrade-rails/dual-boot/dual-boot-with-rails-6-0-beta.html) about this setup, you should check it out.

### Check for outdated gems

You can use bundle outdated to check outdated gems in your current bundle. While `bundle outdated` is quite useful it doesn't give us details relative to our own `Gemfile`. In Ombu Labs we like to use  [next_rails](https://rubygems.org/gems/next_rails/versions/1.0.0) because this gem will give us a set of tools to check for outdated gems, check incompatibilities, and even bootstrap an upgrade project.

### Automated updates
[Dependabot](https://dependabot.com/) is a bot that will open a PR in your Github repository whenever a dependency is outdated. Dependabot was acquired by Github and it's now free of charge.
You can still install Dependabot from the Github Marketplace until it's integrated into GitHub

<div style="text-align: center; width: 500px;">
  <img src="/blog/assets/images/dependabot/dependabot.png">
</div>

We know not all of you use Github but if it happens that you use it, dependabot would be a really nice adition to your tools to keep you up to date.

### Bundler audit

Your application has dependencies. Those dependencies can have security vulnerabilities(CVE's) and malicious persons can take advantage of this.

A tool that we use to make sure our clients dependencies are free of gems with CVE's is [bundler-audit](https://github.com/rubysec/bundler-audit), bundler-audit will scan your current bundle and will compare it with an internal database of know CVE's. If bundler-leak finds any gem affected by a CVE it will dislplay all the information of the affected gem.

```shell
$ bundle audit

Name: actionpack
Version: 3.2.10
Advisory: OSVDB-91452
Criticality: Medium
URL: http://www.osvdb.org/show/osvdb/91452
Title: XSS vulnerability in sanitize_css in Action Pack
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13

Name: actionpack
Version: 3.2.10
Advisory: OSVDB-91454
Criticality: Medium
URL: http://osvdb.org/show/osvdb/91454
Title: XSS Vulnerability in the `sanitize` helper of Ruby on Rails
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13

Name: actionpack
Version: 3.2.10
Advisory: OSVDB-89026
Criticality: High
URL: http://osvdb.org/show/osvdb/89026
Title: Ruby on Rails params_parser.rb Action Pack Type Casting Parameter Parsing Remote Code Execution
Solution: upgrade to ~> 2.3.15, ~> 3.0.19, ~> 3.1.10, >= 3.2.11

Name: activerecord
Version: 3.2.10
Advisory: OSVDB-91453
Criticality: High
URL: http://osvdb.org/show/osvdb/91453
Title: Symbol DoS vulnerability in Active Record
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13

```

you can integrate bundler audit into your build steps and have it running everytime you run your default task.

For example, this is how it looks if you would integrate it with your default rake task. It will check for CVE's in your bundle first and then will run your test suite.

```ruby
# Rakefile

require 'bundler/audit/task'

task default: %i[
  bundle:audit
  bundle exec rspec
]
```

### Test coverage

Test coverage is really important, with each major gem update you can potentially break your application, so having a test suite in shape can help you catch errors and fix them as soon as possible.

We use [siimplecov](https://github.com/colszowka/simplecov). Simplecov is a neat tool that can help you see your test suite coverage percent.
You could configure simplecov to fail if test coverage don'r met a minimum coverage threshold.

```ruby
# rails_helper.rb

require 'simplecov'

SimpleCov.start do
  minimum_coverage ENV['MIN_COVERAGE']
  add_filter '/spec/'
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  if SimpleCov.result.covered_percent < SimpleCov.minimum_coverage
    puts "Test coverage #{SimpleCov.result.covered_percent} does not met the minimum coverage #{treshold SimpleCov.minimum_coverage}"
    exit(1)
  end
end
```

## Conclusion

These suggestions are what we recommend and are not laws. Different projects need different things but we hope you find this list of recommendations helpful.
