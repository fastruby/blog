---
layout: post
title: Introducing bundler leak
date: 2019-08-20 12:53:28
categories: ["bundler"]
author: bronzdoc

---
In this blog post I will introduce bundler leak - A bundler plugin to check gems affected by memory leaks in your Gemfile.

<!--more-->

The [bundler leak](https://github.com/rubymem/bundler-leak) plugin is a fork of the famous [bundler audit](https://github.com/rubysec/bundler-audit) plugin.

As bundler audit, bundler leak works in conjuction of a couple of projects. The first one is what we called the [ruby-mem-advisory-db](https://github.com/rubymem/ruby-mem-advisory-db) a text based database
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

Here is a sample project where you can toy with bundler leak

The last project is called [rubymem.com](https://github.com/ombulabs/rubymem.com) - A web application that will allow you to submit new `leaky gems` to the `ruby-mem-advisory-db`

<div style="text-align: center; width: 500px;">
  <img src="/blog/assets/images/rubymem/rubymem-form.png">
</div>

## Conclusion
We want to thank you to all who made and contributed to bundler audit, the project on which this plugin is based.
If you want to learn more or contribute to bundler leak check the repository and fill and issue or PR.
