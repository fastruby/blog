---
layout: post
title: Introducing `bundler-leak`: A simple way to find known memory leaks in your dependencies
date: 2019-08-27 13:56:00
categories: ["bundler", "memory-leaks"]
author: bronzdoc

---
In this blog post I will introduce `bundler-leak` -- A bundler plugin to find known memory leaks in your dependencies.

<!--more-->

The [`bundler-leak`](https://github.com/rubymem/bundler-leak) plugin is a fork of the famous [`bundler-audit`](https://github.com/rubysec/bundler-audit) plugin.

Just like `bundler-audit`, `bundler-leak` works thanks to a couple of community-driven, open source projects. The first one is called [ruby-mem-advisory-db](https://github.com/rubymem/ruby-mem-advisory-db): a text-based database
consisting of gems with known memory leak issues. Bundler leak will compare gems stored in this database against your Gemfile i.e

```
Audit a project's Gemfile.lock:

    $ bundle leak

    Name: therubyracer
    Version: 0.12.1
    URL: https://github.com/cowboyd/therubyracer/pull/336
    Title: Memory leak in WeakValueMap
    Solution: upgrade to ~> 0.12.3

    Unpatched versions found!
```

Here is a [sample project](https://github.com/rubymem/bundler-leak-sample) where you can toy with bundler leak

The second project is called [rubymem.com](https://github.com/rubymem/rubymem.com): A web application that will allow you to submit new _leaky gems_ to the `ruby-mem-advisory-db`

<div style="text-align: center; width: 500px;">
  <img src="/blog/assets/images/rubymem/rubymem-form.png">
</div>

## Conclusion
We want to say thanks to all the contributors who contributed to bundler audit, it was a great inspiration for this plugin!
If you want to learn more or contribute to bundler leak check the repository and submit an issue or PR.

Also thanks to https://github.com/ASoftCo/leaky-gems the project that inspired the `ruby-mem-advisory-db` and all their [contributors](https://github.com/ASoftCo/leaky-gems#contributors)
