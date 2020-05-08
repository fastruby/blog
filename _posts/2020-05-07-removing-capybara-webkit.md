---
layout: post
title: "Removing capybara-webkit"
date: 2020-04-15 12:00:00
categories: ["rails", "upgrades"]
author: arielj
---

We all know testing is important. We have our unit tests and integration tests to make sure everything is working.

At OmbuLabs, we use [capybara](https://github.com/teamcapybara/capybara) for our integration tests so that we can interact with the app as a real user would.

Capybara by default uses `rack-test` as the driver, but `rack-test` does not support Javascript so to test some things we need a web browser with Javascript capabilities. Having the browser show up while the tests are running is not that practical, now we can use the headless feature on browsers like Chrome or Firefox (even Edge), but a few years ago the available options were mainly PhantomJS or capybara-webkit (through QtWebKit). Those options were deprecated in favor of the major browsers' headless mode.

This is the process we used to replace the `capybara-webkit` gem in a legacy project with the more modern approach of the `webdrivers` gem and headless browser.

<!--more-->

## Issues With Capybara-webkit

- Development was officially suspended in March. [commit](https://github.com/thoughtbot/capybara-webkit/commit/f429d668568ff7349f5e23a085df7fcf1c431fa7#diff-04c6e90faac2675aa89e2176d2eec7d8)
- Depends on QT so it requires the developer to install extra libraries on the system adding an extra step to make a project run locally, inside docker, or in our CI system.
- It's difficult to update the webkit engine that's run in the background so you can't have all the new features you would have on the actual browsers

## Process

We will divide this change into 4 different steps:
1. Replace `capybara-webkit`
1. Make sure specs passes locally
2. Make sure specs passes inside the Docker container
3. Make sure specs passes in CircleCI

## Replacing

The first thing we did was to remove the gem from the Gemfile and then add the `webdrivers` gem (which is already included in any new Rails project).

```diff
- gem "capybara-webkit"
+ gem 'webdrivers'
```

This project was old so it also had an old capybara version that won't automatically register the browser drivers that we want so we had to register the headless browsers' drivers on our capybara config:

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

And now we tell capybara to use one of those drivers for all the tests that require javascript:

```ruby
Capybara.javascript_driver = :headless_chrome # or :headless_firefox
```

We had an extra step here because a lot of specs had the drivers specified on the actual test `describe` block like this: `describe "Do something", js: true, driver: :webkit do`. Instead of replacing the driver there, we just removed that option on all the tests so it uses the base config we set above.

And lastly, before you run your test, make you you have no references to capybara-webkit in your code (search for `capybara-webkit`, `Capybara::Webkit` and `:webkit` strings).

# Fixing Specs

We first make sure tests are working locally so we are sure we don't have errors due to a misconfigured container.

This application uses an old version of [Chosen](https://harvesthq.github.io/chosen/) to customize the `select` tags. The test suite includes a helper method so the driver can select options from that custom select and that helper method started failing.

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

So we not only updated the gem, we also improved the test suite by not doing obscure Javascript calls.

# Updating Docker Container

Now that our tests are passing we can update the `Dockerfile` removing the commands that installed QT's libraries `qt5-default` and `libqt5webkit5-dev` (that will depend on the OS your are using, we have a Debian image so we just removed those packes from the `apt-get` command).

Then we make sure we have Mozilla Firefox or Google Chrome installed. It was easier to install Firefox since the `firefox-esr` package was already available on the Debian Buster image we were using. You can use a Docker image which includes other browsers or install Google Chrome if you want to.

So we changed the default driver to use Firefox:

```ruby
Capybara.javascript_driver = :headless_firefox
```

Now our tests can be run inside Docker and we are all green.

# Updating CircleCI Config

The last part of the process was to make sure the tests pass on the CI system. We only needed to make sure Firefox was available when running the test, so the easiest solution for this was to use a CircleCI Ruby image and use the correct [variant](https://circleci.com/docs/2.0/circleci-images/#language-image-variants) so it also includes most used browsers:

```diff
- - image: circleci/ruby:2.4.10-buster-node
+ - image: circleci/ruby:2.4.10-buster-node-browsers
```

> We did have some problems related to caching, so you may want to try to retry your CI job without caching just to make sure if you see something failing

## Conclusion

We finally got an old dependency removed (QT) replacing `capybara-webkit` with a more modern solution.

It makes it easier for new developers to join the project now that it has less extra requirements. It will also help when updating the Rails version, since newer Rails versions adds `webdrivers` gem when creating new apps by default.

Another advantage of replacing QtWebKit with a major browser like Chrome and Firefox is that it helped us to find a bug in our current test suite. We had not been properly testing the interactions of the user in those tests related to Chose, but now we fixed that.

And finally, we can run the complete test suite using different browsers (`webdrivers` support Firefox, Chrome, IE and Edge) just changing one configuration if we need to.