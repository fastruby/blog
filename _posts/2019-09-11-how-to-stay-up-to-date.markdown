---
layout: post
title: How to stay up to date with your Rails application
date: 2019-08-27 13:56:00
categories: ["Rails", "Upgrade"]
author: bronzdoc
---

How to stay up to date with your rails application

<!--more-->

In Fastruby.io we work with alot of clients which have outdated Rails applications, we help them upgrade to a newer Rails version.

An outdated Rals application doesn't happen over night, and there are things that you could start doing to avoid going into an outdated project, that will be difficult to maintain and migrate later on.

### Stop monkey patching

In our experience having monkey patched gems when doing an upgrade usually is one of the hardest things to deal with since work hours would have to be put to make the monkey patched gem compatible with the new Rails version. So Have that in mind before dedicating time to monkey patch rails core libraries or gems that depend on an specific rails versions.

### Start treating Deprecations warnings as errors.

In Rails you can configure this option, so everytime a deprecation warning occurs you can address it as soon as you can.
This will help you to fix the issue rigth a away and be prepared for the next version jump.

```ruby
  # Raise error on deprecation¬
  config.active_support.deprecation = :raise
```

### Check for outdated gems

You can use bundle outdated to check outdated gems in your current bundle. While `bundle outdated` is quite useful it doesn't give us details relative to our own `Gemfile`. In Ombulabs we like to use  [next_rails](https://rubygems.org/gems/next_rails/versions/1.0.0) this gem will give us a set of tools to check for outdated gems, check incompatibilities and even bootstrap an upgrade project.

### Automated updates
[Dependabot](https://dependabot.com/) is a bot that will open a PR in your Github repository whenever a dependency is outdated. Dependabot was adquired by github and it's now free of charge.
You can still install Dependabot from the GitHub Marketplace whilst it's integrated it completely into GitHub

<div style="text-align: center; width: 500px;">
  <img src="/blog/assets/images/dependabot/dependabot.png">
</div>


### Test coverage

This is really important, with each major gem update you can potentially break your application, having a test suite in shape can help you catch errors and fix them as soon as they appear.

## Conclusion

This are things that we recomend and are not laws, different pojects need different things but we hope you find this list of recommendations helpful it helpful!


