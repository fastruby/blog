---
layout: post
title: "How to Migrate from Capybara Webkit to Webdrivers"
date: 2020-04-15 12:00:00
categories: ["rails", "upgrades"]
author: arielj
---

We all know testing is important. We have our unit tests and integration tests to make sure everything is working as expected. At [OmbuLabs](https://www.ombulabs.com), we use [Capybara](https://github.com/teamcapybara/capybara) for our integration tests so that we can interact with the app as a real user would.

This is the process we used to replace the `capybara-webkit` gem in a legacy project with a more modern approach that uses the [`webdrivers`](https://github.com/titusfortner/webdrivers) gem and a headless browser.

<!--more-->

## Why Capybara Webkit

By default, Capybara uses [`rack-test`](https://github.com/rack/rack-test) as the driver. Unfortunately `rack-test` does not support JavaScript. If we want to test things that rely on JavaScript, we need a driver with JS capabilities. Some of these drivers open up a web browser and show us all the activity.

Having the browser show up while the tests are running is not that practical and usually quite slow. The good news is that we can use headless features on browsers like Chrome or Firefox (even Edge). A few years ago the available options were mainly [PhantomJS](https://phantomjs.org) or `capybara-webkit` (which uses [QtWebKit](https://wiki.qt.io/Qt_WebKit)), but these options had its development suspended.

## Issues with Capybara Webkit

- Development was officially suspended in March. [commit](https://github.com/thoughtbot/capybara-webkit/commit/f429d668568ff7349f5e23a085df7fcf1c431fa7#diff-04c6e90faac2675aa89e2176d2eec7d8)
- Depends on QT so it requires the developer to install extra libraries on the system, adding an extra step to make a project run locally, inside docker, or in our CI system.
- It's difficult to update the webkit engine that runs in the background so you can't have all the new features you would have on the actual browsers.

## Process

We will divide this change into 4 different steps:
1. Replace `capybara-webkit`
1. Make sure specs pass locally
1. Make sure specs pass inside the Docker container
1. Make sure specs pass in CircleCI

## Replacing

First of all we remove `capybara-webkit` from the Gemfile and then replace it with the `webdrivers` gem (which is already included in any new Rails project).

```diff
- gem "capybara-webkit"
+ gem 'webdrivers'
```

This project was old so it also had an old capybara version that won't automatically register the browser drivers that we want so we had to register the headless browsers' drivers in our capybara config:

```ruby
# from https://github.com/teamcapybara/capybara/blob/c7c22789b7aaf6c1515bf6e68f00bfe074cf8fc1/lib/capybara/registrations/drivers.rb

Capybara.register_driver :headless_firefox do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Firefox::Options.new
  browser_options.args << '-headless'
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: browser_options)
end

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu' if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
```
> You'll need Chrome or Firefox versions that supports headless mode

Then we can tell Capybara to use one of those drivers for all the tests that require JavaScript:

```ruby
Capybara.javascript_driver = :headless_chrome # or :headless_firefox
```

We had an extra step here because a lot of specs had the drivers specified on the actual test `describe` block like this:

```ruby
describe "Do something", js: true, driver: :webkit do
```

Instead of replacing the driver there, we just removed that option on all the tests so it uses the base config we set above.

Finally, before you run your test suite, make sure you have no references to capybara-webkit in your code (search for `capybara-webkit`, `Capybara::Webkit` and `:webkit` strings).

# Fixing Specs

We first make sure tests are working locally so we don't have errors due to a misconfigured container.

This application uses an old version of [Chosen](https://harvesthq.github.io/chosen/) to customize the `select` tags. The test suite includes a helper method so the driver can select options from that custom `select` and that helper method started failing.

We were using a helper method from this [gist](https://gist.github.com/thijsc/1391107/699d65defed793eed0f04ead33c35737c641be53) that relied too much on `page.execute_script` and `page.evaluate_script`. The solution for this was to use a different method calling only capybara methods to actually mimic the user interactions.

```diff
  def select_from_chosen(item_text, options)
-    field = find('#' + options[:from], visible: false)
-    option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{item_text}')\").val()")
-    page.execute_script("value = ['#{option_value}']\; if ($('##{field[:id]}').val()) {$.merge(value, $('##{field[:id]}').val())}")
-    option_value = page.evaluate_script("value")
-    page.execute_script("$('##{field[:id]}').val(#{option_value})")
-    page.execute_script("$('##{field[:id]}').trigger('liszt:updated').trigger('change')")

+    field = find_field(options[:from], visible: false)
+    find("##{field[:id]}_chzn").click
+    find("##{field[:id]}_chzn ul.chzn-results li", text: item_text).click
  end
```

On top of updating the gem, we improved the test suite by avoiding obscure JavaScript calls.

# Updating Docker Container

Now that our tests are passing we can update the `Dockerfile` removing the commands that installed QT's libraries `qt5-default` and `libqt5webkit5-dev` (that will depend on the OS your are using, we have a Debian image so we just removed those packes from the `apt-get` command).

Then we make sure we have Mozilla Firefox or Google Chrome installed. It was easier to install Firefox since the `firefox-esr` package was already available on the Debian Buster image we were using. You can use a Docker image which includes other browsers or install Google Chrome if you want to.

So we changed the default driver to use Firefox:

```ruby
Capybara.javascript_driver = :headless_firefox
```

Now our tests can be run inside Docker and we are all green.

# Updating CircleCI Config

The last part of the process was to make sure the tests pass on the CI system. We only needed to make sure Firefox was available when running the test, so the easiest solution for this was to use a CircleCI's Ruby image and use the correct [variant](https://circleci.com/docs/2.0/circleci-images/#language-image-variants) so it also includes the most used browsers:

```diff
- - image: circleci/ruby:2.4.10-buster-node
+ - image: circleci/ruby:2.4.10-buster-node-browsers
```

> We did have some problems related to caching, so you may want to try to retry your CI job without caching just to make sure if you see something failing

## Conclusion

To sum up we got rid of an outdated dependency (`capybara-webkit`) which depended on QT and replaced it with `webdrivers` which depends on modern web browsers (e.g. Firefox). And we highly recommend you do it in your legacy Rails applications!

It makes it easier for new developers to join the project, installing QT is quite complicated on some OSs (https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit) and Firefox (or Chrome) are usually already installed in any web developer's environment.

It also makes it easier to maintain our Rails application and it gets us closer to "the Rails way". It will help us when upgrading Rails because more recent versions of Rails use the `webdrivers` gem by default.

Another advantage of replacing QtWebKit with a major browser like Chrome and Firefox is that it helped us to find a bug in our current test suite. We had not been properly testing the interactions of the user in those tests related to Chosen, but now we fixed that.

And finally, we can run the complete test suite using different browsers (`webdrivers` support Firefox, Chrome, IE and Edge) just by changing one configuration if we need to.