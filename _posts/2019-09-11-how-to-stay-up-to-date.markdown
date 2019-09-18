---
layout: post
title: How to Stay Up to Date with Your Rails Application
date: 2019-08-27 13:56:00
categories: ["Rails", "Upgrades"]
author: bronzdoc
---

An outdated Rails application doesn't happen overnight. In Fastruby.io we work with a lot of clients which have outdated Rails applications and we help them upgrade to a newer Rails version. In this article are some things that you could start doing to avoid going into an outdated project that would be difficult to maintain and migrate later on.

<!--more-->

### Stop monkey patching

In our experience having monkey patched gems when doing an upgrade usually is one of the hardest things to deal with since work hours have to be put to make the monkey patched gem compatible with the new Rails version. So Have that in mind before dedicating time to monkey patch rails core libraries or gems that depend on an specific rails versions.

### Start treating Deprecations warnings as errors.

In Rails you can configure this option, so everytime a deprecation warning occurs you can address it as soon as you can.
This will help you to fix the issue immediately and be prepared for the next version jump.

You will need to add the following configuration in your `config/environments/test.rb` and `config/environments/test.rb` files.

```ruby
  # Raise error on deprecation¬
  config.active_support.deprecation = :raise
```

### Dual Boot

One of the first things we do at Fastruby.io when we start a new rails upgrade project is to setup a "Dual Boot" Gemfile.
What this setup will do is to allow you to have two Gemfile.lock's, one for the latest version of Rails and one for your current version of Rails.

With this setup you'll be able to configure your CI to run both versions of Rails and as long as you can "mark" the rails master build job as "optional" and it doesn't block your PR merges, you'll be checking how your test behaves with the latest version of Rails.

We even wrote a [blog post](https://www.fastruby.io/blog/upgrade-rails/dual-boot/dual-boot-with-rails-6-0-beta.html) about this setup, you should check it out.

### Check for outdated gems

You can use bundle outdated to check outdated gems in your current bundle. While `bundle outdated` is quite useful it doesn't give us details relative to our own `Gemfile`. In Ombulabs we like to use  [next_rails](https://rubygems.org/gems/next_rails/versions/1.0.0) because this gem will give us a set of tools to check for outdated gems, check incompatibilities and even bootstrap an upgrade project.

### Automated updates
[Dependabot](https://dependabot.com/) is a bot that will open a PR in your Github repository whenever a dependency is outdated. Dependabot was adquired by github and it's now free of charge.
You can still install Dependabot from the GitHub Marketplace until it's integrated into GitHub

<div style="text-align: center; width: 500px;">
  <img src="/blog/assets/images/dependabot/dependabot.png">
</div>


### Test coverage

Test coverage is really important, with each major gem update you can potentially break your application, so having a test suite in shape can help you catch errors and fix them as soon as possible.
This is really important...with each major gem update you can potentially break your application, so having a test suite in shape can help you catch errors and fix them as soon as they appear.

## Conclusion

These are things that we recommend and are not laws. Different projects need different things but we hope you find this list of recommendations helpful.


