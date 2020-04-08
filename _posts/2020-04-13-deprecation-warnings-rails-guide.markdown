---
layout: post
title: "The Complete Guide for Deprecation Warnings in Rails"
date: 2020-04-13 12:00:00
categories: ["rails", "upgrades"]
author: luciano
---

Deprecation warnings are a common thing in our industry. They are warnings that notify us that a specific feature (e.g. a method) will be removed soon (usually in the next [minor or major](https://semver.org/) version) and should be replaced with something else.
Features are deprecated rather than immediately removed, in order to provide backward compatibility (a solution that works in both the current and the future version), and to give programmers time to implement the code in a way that follows the new standard.

In this guide we'll show you what's the workflow that we use at [FastRuby.io](https://www.fastruby.io) to address deprecation warnings when we [upgrade Rails applications](https://www.fastruby.io/blog/tags/upgrades).

<!--more-->

## Finding

There are a few different ways to find deprecation warnings in your application.

If you have good test coverage, you can run the whole test suite and look at the logs that were generated. If you are using a CI service (like [CircleCI](https://circleci.com/) or [Travis CI](https://travis-ci.org/)) you can easily see the logs once the build finished running. Otherwise, if you run the tests locally, you can look at the output on the console or in the `log/test.log` file.

In Rails, all deprecation warnings start with `DEPRECATION WARNING:`, so you can search for that string in your logs.

When it comes to production, the easier way to collect deprecation warnings is by using a monitoring tool (like [Honeybadger](https://www.honeybadger.io/) or [Airbrake](https://airbrake.io/)).

This is not standard behavior, but it is quite useful. In order to send deprecation warnings to one of these tools, you would have to do something like this:

```ruby
# config/environments/production.rb

config.active_support.deprecation = :notify
```

```ruby
# config/initializers/deprecation_warnings.rb

ActiveSupport::Notifications.subscribe('deprecation.rails') do |name, start, finish, id, payload|
  # Example if you use Honeybadger:
  Honeybadger.notify(
    error_class:   "deprecation_warning",
    error_message: payload[:message],
    backtrace:     payload[:callstack]
  )
end
```

See [this link](https://guides.rubyonrails.org/active_support_instrumentation.html#subscribing-to-an-event) for more details about `ActiveSupport::Notifications.subscribe`.

You can also set `config.active_support.deprecation` to `:log` and look at the `log/production.log` file, but it won't be as straightforward as the first option. Depending on the traffic your application gets, your `production.log` might have a lot of noise.

## Tracking

Once you have all the deprecation warnings (or most of them) from your application, it is a good a idea to track them as if they were issues.
You can use the project management tool of your preference (we use [Pivotal Tracker](https://www.ombulabs.com/blog/agile/pivotal-tracker/how-we-use-pivotal-tracker-at-ombu-labs.html)) and create a story in the backlog for each root cause of the deprecation warnings. That way it makes things a lot easier when it comes to code review and organization in general.

<img src="/assets/images/deprecation-warning-story.png" alt="Deprecation Warning Story for Rails Upgrade" />

Also, it is a good idea to prioritize the deprecation warnings based on the frequency that they occur.
That way, you make sure you first work on the ones that fix the largest amount of errors for the next Rails version. You will clearly see that if you are using [dual booting](https://www.fastruby.io/blog/upgrade-rails/dual-boot/dual-boot-with-rails-6-0-beta.html) in your app.

## Fixing

At this point you can grab a story from the top of the backlog and work on it. Most of the deprecation warnings are very clear on what needs to be updated. If that's not the case, a quick google search will provide more answers. Usually you will have to apply the same fix across many files, so make sure you search for all occurrences in the project folder.

Once the changes are done, run the appropriate specs or manually test the parts that were modified to make sure that everything works normal.

After that, you can create a new [pull request](https://www.ombulabs.com/blog/agile/learning/pull-requests/submitting-prs.html) and move on to the next deprecation warning on your backlog.

## Best Practices

In order to not accumulate deprecation warnings in your application, it is a good practice to treat them as errors.
You can easily configure that in your in your `config/environments/test.rb` and `config/environments/development.rb` files:

```ruby
config.active_support.deprecation = :raise
```

### Avoiding Regressions

After you fix a deprecation warning in the project, you want to make sure that nobody introduces that deprecated code again.

#### Rubocop

If you are using [Rubocop](https://github.com/rubocop-hq/rubocop), you can write a cop to check for deprecated code. Take a look at [Lint/DeprecatedClassMethods](https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/cop/lint/deprecated_class_methods.rb) for some reference on that.

#### Disallowed deprecations in ActiveSupport

Rails 6.1 will come with a new feature to disallow deprecations. You'll be able to configure the deprecation warnings that you fixed as disallowed. If a disallowed deprecation is introduced, it will be treated as a failure and raise an exception in development and test. In production it will log the deprecation as an error.

```ruby
# config/environments/test.rb

ActiveSupport::Deprecation.disallowed_behavior = [:raise]
ActiveSupport::Deprecation.disallowed_warnings = [
  "uniq",
   :uniq,
  /(uniq)!?/,
]
```

Check out at [this PR](https://github.com/rails/rails/pull/37940) for more details about this new feature.

## Conclusion

Depending of the size of your application, addressing all deprecation warnings can take quite some time. But hopefully this guide will help you to do it faster.

If you need some more guidance on upgrading your Rails application check out our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/)
