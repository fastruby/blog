---
layout: post
title: "Shims that you might encounter during a Rails Upgrade"
date: 2020-10-27 10:00:00
categories: ["rails", "upgrades"]
author: "luciano"
---

When upgrading a Rails application, you might find that sometimes functionality is extracted from Rails and moved into a new gem. These gems are called [shims](https://medium.com/@ujjawal.dixit/what-is-a-shim-72d9ac5d8620), and basically allow you to keep using an old functionality, once the core API takes that out.

In this article I will list most of the shims that happened to in the past versions of Rails.

<!--more-->

## Rails 5.0

### [`record_tag_helper`](https://github.com/rails/record_tag_helper) ([See changes](https://github.com/rails/rails/pull/18411))

`content_tag_for` and `div_for` were removed in favor of just using `content_tag`. To continue using the older methods, add the `record_tag_helper` gem to your Gemfile.

### [`rails-controller-testing`](https://github.com/rails/rails-controller-testing) ([See changes](https://github.com/rails/rails/pull/20138))

`assigns` and `assert_template` were extracted to the `rails-controller-testing` gem.

### [`activemodel-serializers-xml`](https://github.com/rails/activemodel-serializers-xml) ([See changes](https://github.com/rails/rails/pull/21161))

`ActiveModel::Serializers::Xml` was extracted from Rails to the `activemodel-serializers-xml` gem. To continue using XML serialization, add gem `activemodel-serializers-xml` to your Gemfile.

## Rails 4.2

### [`responders`](https://github.com/heartcombo/responders) ([See changes](https://github.com/rails/rails/pull/16526))

`respond_with` and `respond_to` methods were extracted to the `responders` gem.

### [`rails-deprecated_sanitizer`](https://github.com/kaspth/rails-deprecated_sanitizer) ([See changes](http://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/))

The HTML Sanitizer logic was reimplemented, but to keep using the old behavior you can use the `rails-deprecated_sanitizer` gem.

`rails-deprecated_sanitizer` is supported only for Rails 4.2.

### [`rails-dom-testing`](https://github.com/rails/rails-dom-testing)

The `TagAssertions` module (containing methods such as `assert_tag`), was deprecated in favor of the `assert_select` methods from the `SelectorAssertions` module, which was extracted into the `rails-dom-testing` gem.

## Rails 4.1

### [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder)

Removed support for the `encode_json` hook used for encoding custom objects into JSON. This feature was extracted into the `activesupport-json_encoder` gem.

Deprecated `ActiveSupport.encode_big_decimal_as_string` and `ActiveSupport::JSON::Encoding::CircularReferenceError`. These features were extracted into the `activesupport-json_encoder` gem.

Changes:

- [https://github.com/rails/rails/pull/12183](https://github.com/rails/rails/pull/12183)
- [https://github.com/rails/rails/pull/12785](https://github.com/rails/rails/pull/12785)
- [https://github.com/rails/rails/pull/13060](https://github.com/rails/rails/pull/13060)

## Rails 4.0

### [`protected_attributes`](https://github.com/rails/protected_attributes) ([See changes](https://github.com/rails/rails/pull/7251))

### [`activeresource`](https://github.com/rails/activeresource) ([See changes](https://github.com/rails/rails/pull/572))

### [`rails-observers`](https://github.com/rails/rails-observers) ([See changes](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))

### [`actionpack-action_caching`](https://github.com/rails/actionpack-action_caching) ([See changes](https://github.com/rails/rails/pull/7833))

### [`actionpack-page_caching`](https://github.com/rails/actionpack-page_caching) ([See changes](https://github.com/rails/rails/pull/7833))

### [`sprockets-rails`](https://github.com/rails/sprockets-rails) ([See changes](https://github.com/rails/rails/pull/8876))

### [`activerecord-session_store`](https://github.com/rails/activerecord-session_store) ([See changes](https://github.com/rails/rails/pull/7436))

### [`activerecord-deprecated_finders`](https://github.com/rails/activerecord-deprecated_finders)

### [`rails-perftest`](https://github.com/rails/rails-perftest)

### [`actionpack-xml_parser`](https://github.com/rails/actionpack-xml_parser)

## Rails 3.1

### [`rails_autolink`](https://github.com/tenderlove/rails_autolink)

`auto_link` was removed from Rails and extracted into the `rails_autolink` gem.

## Rails 3.0

### [`mail`](https://github.com/mikel/mail)

All delivery methods from Action Mailer were abstracted out to the `mail` gem.

# Resources

Official Rails Guides: [https://guides.rubyonrails.org](https://guides.rubyonrails.org)

# Conclusion

I hope this list of gems comes in handy when upgrading your Rails application. Let me know if I missed any important ones.

Finally, if you want more details on how to upgrade each version of Rails, you can download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
