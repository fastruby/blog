---
layout: post
title:  "Announcing Gemfile.lock Audit Tool"
date: 2018-06-22 11:10:00
reviewed: 2020-02-06 9:37:00
categories: ["rails", "ruby", "rubygems"]
author: "emily"
---

Today we are happy to announce the launch of our new microsite: [Gemfile.lock Audit Tool](https://audit.fastruby.io) - a tool created to allow users to check their Gemfile.lock for vulnerabilities in a quick and secure manner.

<!--more-->

The tool uses the [bundler-audit gem](https://github.com/rubysec/bundler-audit) to check for vulnerable versions of gems and insecure gem sources. The tool updates automatically with new warnings as the bundler-audit gem database of vulnerabilities is updated.

Thanks to this tool, users can now easily audit their Gemfile.lock without installing any gems or editing their code. Check it out at [https://audit.fastruby.io](https://audit.fastruby.io), and let us know what you think!
