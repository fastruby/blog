---
layout: post
title: "Cleaning up: ActiveRecord::Dirty 5.2 API Changes"
date: 2018-02-14 10:20:00
categories: ["rails", "upgrades"]
author: "mauro-oto"
---

With the release of Rails 5.2 just around the corner
([Rails 5.2 RC1](https://rubygems.org/gems/rails/versions/5.2.0.rc1) is already available!),
we will be taking a look at some of the upcoming changes to the `ActiveRecord::Dirty`
module. If you're running Rails 5.1, you may have already seen some of the
deprecation warnings related to the API changes contained in it. Most of them
are behavior changes, and there are some new additions as well.

To better understand these modifications, we'll take a look at sample projects
in Rails 5.1 and Rails 5.2.

<!--more-->

## Previous behavior

Notice the deprecation warnings we get when calling `email_changed?`, `changed?`,
`changes` and `previous_changes` in Rails 5.1 from within an `after_save` callback:

```ruby
2.4.2 :010 > user.email = "mauro@ombulabs.com"
 => "mauro@ombulabs.com"
2.4.2 :011 > user.save

From: /Users/mauro-oto/Projects/rails51test/app/models/user.rb @ line 2 :

    1: class User < ApplicationRecord
 => 2:   after_save { binding.pry }
    3: end

[1] pry(#<User>)> email_changed?
DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_change_to_attribute?` instead.
=> true
[2] pry(#<User>)> changed?
DEPRECATION WARNING: The behavior of `changed?` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_changes?` instead.
DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
=> true
[3] pry(#<User>)> changes
DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
DEPRECATION WARNING: The behavior of `changes` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_changes` instead.
DEPRECATION WARNING: The behavior of `changed` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_changes.keys` instead.
DEPRECATION WARNING: The behavior of `attribute_change` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_change_to_attribute` instead.
DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_change_to_attribute?` instead.
DEPRECATION WARNING: The behavior of `attribute_change` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_change_to_attribute` instead.
DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails. The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now). To maintain the current behavior, use `saved_change_to_attribute?` instead.
=> {"email"=>["john@doe.org", "mauro@ombulabs.com"]}
[4] pry(#<User>)> previous_changes
DEPRECATION WARNING: The behavior of `previous_changes` inside of after callbacks is
deprecated without replacement. In the next release of Rails,
this method inside of `after_save` will return the changes that
were just saved.
=> {}
[5] pry(#<User>)> saved_change_to_email?
=> true
[6] pry(#<User>)> saved_change_to_email
=> ["john@doe.org", "mauro@ombulabs.com"]
[7] pry(#<User>)> email_before_last_save
=> "john@doe.org"
```

The last three methods' behavior remains unchanged between Rails 5.1 and
Rails 5.2, but the first four emit those warning messages, and their behavior
changes between these two versions. These changes are best explained in [this commit](https://github.com/rails/rails/commit/16ae3db5a5c6a08383b974ae6c96faac5b4a3c81),
and the best aspect of it in my opinion is explicitness.

It reduces the ambiguity of simply using `changed?`, which would return `true`
when the object was dirty, not yet saved to the database (within `before_save`),
and `true` after the object was saved to the database (within `after_save`).

The second case will *no longer* be `true`, but rather `false`. To reduce
ambiguity now, you can use the more explicit `saved_changes?` method to ask
whether the object has been changed and if its changes were saved to the database.

## New behavior

A developer's intentions will become more clear with the behavior changes
introduced in Rails 5.2:

```ruby
2.4.2 :003 > user.email = "mauro@ombulabs.com"
 => "mauro@ombulabs.com"
2.4.2 :004 > user.save

From: /Users/mauro-oto/Projects/rails52test/app/models/user.rb @ line 2 :

    1: class User < ApplicationRecord
 => 2:   after_save { binding.pry }
    3: end

[1] pry(#<User>)> email_changed?
=> false
[2] pry(#<User>)> changed?
=> false
[3] pry(#<User>)> changes
=> {}
[4] pry(#<User>)> previous_changes
=> {"email"=>["john@doe.org", "mauro@ombulabs.com"]}
[5] pry(#<User>)> saved_change_to_email?
=> true
[6] pry(#<User>)> saved_change_to_email
=> ["john@doe.org", "mauro@ombulabs.com"]
[7] pry(#<User>)> email_before_last_save
=> "john@doe.org"
```

`attribute_changed?` and `changed?` remain the same when called within a
`before_save` callback. However, the Rails core team has also introduced a set
of methods which can help further reduce the potential ambiguity of `changed?`
before saving to the database: `will_save_change_to_attribute?` and
`has_changes_to_save?`:

```ruby
2.4.2 :016 > user.email = "mauro@ombulabs.com"
 => "mauro@ombulabs.com"
2.4.2 :017 > user.has_changes_to_save?
 => true
2.4.2 :018 > user.will_save_change_to_email?
 => true
2.4.2 :019 > user.save
 => true
2.4.2 :020 > user.will_save_change_to_email?
 => nil
2.4.2 :021 > user.has_changes_to_save?
 => false
```

In conclusion, if you use these methods and are planning to migrate to Rails 5.2
or even 5.1, you should take these changes into account:

### Must do:

After modifying an object and after saving to the database, or within `after_save`:

- `attribute_changed?` should now be `saved_change_to_attribute?`
- `changed?` should now be `saved_changes?`
- `changes` should now be `saved_changes`
- `previous_changes` has no replacement, since the behavior for it changes.

### Optional (less ambiguity, more readable, but longer):

After modifying an object and before saving to the database, or within `before_save`:

- `attribute_changed?` should now be `will_save_change_to_attribute?`
- `changed?` should now be `has_changes_to_save?`
- `changes` should now be `changes_to_save`

If you or your team lack the time to do the upgrade, you can get in touch with
us at [FastRuby.io](https://fastruby.io) and we can help you!
