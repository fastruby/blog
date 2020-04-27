---
layout: post
title:  "Ruby & Rails Compatibility Table"
date: 2019-04-29 13:00:00
reviewed: 2020-04-24 10:00:00
categories: ["ruby", "rails", "versions"]
author: "etagwerker"
---

This is a short post to show the compatibility between [Ruby on Rails](https://rubyonrails.org)
and [Ruby](https://www.ruby-lang.org/en/) across different versions. In the
process of upgrading really old applications to more modern versions of Ruby and
Rails we have ran into a lot of these combinations.

<!--more-->

<table id="ruby-rails-compatibility">
  <thead>
    <tr>
      <td><a href="https://rubygems.org/gems/rails/versions" style="color: white"> Rails<br/> Version </a></td>
      <td><a href="https://www.ruby-lang.org/en/downloads/releases/" style="color: white"> Required<br/>Ruby<br/>Version</a></td>
      <td>Recommended<br/>Ruby<br/>Version</td>
      <td><a href="https://rubygems.org/gems/rubygems-update/versions" style="color: white"> Required<br/>Rubygems<br/>Version </a></td>
      <td>Status</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>6.1.0</td>
      <td>&gt;= 2.5.0</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td>Alpha</td>
    </tr>
    <tr>
      <td>6.0.x</td>
      <td>&gt;= 2.5.0</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td>Maintained</td>
    </tr>
    <tr>
      <td>5.2.x</td>
      <td>&gt;= 2.2.2</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td>Maintained for Security Issues</td>
    </tr>
    <tr class="eol">
      <td>5.1.x</td>
      <td>&gt;= 2.2.2</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td><a href="https://weblog.rubyonrails.org/2019/8/15/Rails-6-0-final-release/" style="color:white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>5.0.x</td>
      <td>&gt;= 2.2.2</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td><a href="https://weblog.rubyonrails.org/2019/8/15/Rails-6-0-final-release/" style="color:white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>4.2.x</td>
      <td>&gt;= 1.9.3</td>
      <td>2.2</td>
      <td>&gt;= 1.8.11</td>
      <td><a href="https://weblog.rubyonrails.org/2019/8/15/Rails-6-0-final-release/" style="color:white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>4.1.x to 4.2.0</td>
      <td>&gt;= 1.9.3</td>
      <td>2.1</td>
      <td>&gt;= 1.8.11</td>
      <td><a href="https://guides.rubyonrails.org/maintenance_policy.html" style="color: white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>4.0.5 to 4.1.0.rc2</td>
      <td>&gt;= 1.9.3</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td><a href="https://weblog.rubyonrails.org/2016/6/30/Rails-5-0-final/" style="color: white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>4.0.0 to 4.0.x</td>
      <td>&gt;= 1.8.7</td>
      <td></td>
      <td>&gt;= 1.8.11</td>
      <td><a href="https://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/" style="color: white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>3.2.22 to 3.2.22.5</td>
      <td>1.8.7</td>
      <td>2.2</td>
      <td>&gt;= 1.3.6</td>
      <td><a href="https://weblog.rubyonrails.org/2013/2/24/maintenance-policy-for-ruby-on-rails/" style="color: white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>3.2.13 to 3.2.22.4</td>
      <td>1.8.7</td>
      <td>2.0</td>
      <td>&gt;= 1.3.6</td>
      <td><a href="https://weblog.rubyonrails.org/2013/2/24/maintenance-policy-for-ruby-on-rails/" style="color: white">EOL</a></td>
    </tr>
    <tr class="eol">
      <td>0.8.0 to 3.2.13.rc2</td>
      <td>1.8.7</td>
      <td></td>
      <td>&gt;= 1.3.6</td>
      <td><a href="https://weblog.rubyonrails.org/2013/2/24/maintenance-policy-for-ruby-on-rails/" style="color: white">EOL</a></td>
    </tr>
  </tbody>
</table>

## Need to Upgrade Rails?

If you want to upgrade Rails, check out our series of articles that cover from Rails 2.3 to Rails 6.0: [Articles by FastRuby.io about Rails upgrades](https://www.fastruby.io/blog/tags/upgrades)

If you don't have the time to do it yourself and you have a budget to hire our team, send us a message over here: [Contact FastRuby.io](https://www.fastruby.io/#contactus)

## Feedback Wanted: Updates

If you find that this article has fallen out of date, feel free to make a
comment for us to bring it up to speed. We will continue to update this article
as new versions of Ruby and Rails are released.
