---
layout: post
title: "Our Rails Upgrade Process: How to bundle update rails"
date: 2020-04-08 15:00:00
reviewed: 2020-04-08 15:00:00
categories: ["rails", "upgrades"]
author: "cleiviane"
redirect_from:
  - /rails/upgrade/our-rails-upgrade-process.html
  - /rails/upgrades/our-rails-upgrade-process.html
---

We know that there are many challenges involved in a Rails upgrade project. Depending on how big your application is, how old your Rails version is and how well structured your code is, it can be difficult to perform that job and keep your sanity. If you don't find a reliable and trustable process to guide you from version X to version Y, you can end-up in a nightmare.

The good news is that here at [Ombu Labs](https://www.ombulabs.com/), we have been upgrading Rails applications for over 10 years now and this gave us a know-how to define a process that has proven to be very effective. And today I want to share Our Rails Upgrade Process with you.

<!--more-->

## Step 1: Finding deprecation warnings

The first thing we do is search for deprecation warnings in the application, they are log messages suggesting things that you will need to change when moving to the next version of Rails. That can be because something will either be removed from the source code or the code will work in a different way.

You might find these deprecation warnings by searching in the `production.log` or tracking them down in your Log Management Software, such as [Sentry](https://sentry.io/) or [Splunk](https://www.splunk.com).

You can also search for deprecation warnings in the `test.log`, so you can find them in your CI service as well.

For each different deprecation warning that we find, we create one story in our backlog software (at Ombu Labs we use Pivotal Tracker as we explained [here](https://www.ombulabs.com/blog/agile/pivotal-tracker/how-we-use-pivotal-tracker-at-ombu-labs.html) to help us with that). This will make things easier to code review and to test in QA.

## Step 2: Fixing all deprecation warnings

After creating all the stories for the deprecation warnings, it is time to address them one by one. Deprecation warnings are usually pretty straightforward, the messages are clear about what needs to change. They are also backwards compatible which means that you can fix them and merge directly to the current version of Rails.

Good examples are the deprecation warnings caused by the changes in `ActiveRecord::Dirty` in the Rails 5.2 version. We wrote [this article](https://www.fastruby.io/blog/rails/upgrades/active-record-5-1-api-changes.html) awhile ago showing how to address them.

Ideally, you will have a test suite that exercises the code that you are changing. Then you can be sure that the changes don’t break existing behavior. If you don’t have tests, you will have to manually execute the code that you’re changing. That is when it can become a tedious process.

## Step 3: Add dual boot for the Rails version

To help us switch between the current Rails version and the new one, we usually create a dual boot mechanism. The fastest way is to install the handy gem [next_rails](https://github.com/fastruby/next_rails). Please, [visit this article](https://www.fastruby.io/blog/upgrade-rails/dual-boot/dual-boot-with-rails-6-0-beta.html) where we showed how you can install and setup the gem in your local environment and your CI server.

Dual booting is a helpful strategy that you can use in all environments:

- development: we can quickly switch between one version to the other and debug unexpected behavior.
- test: we can run two versions of the test suite (one with the current version, another with the target version).
- production: we can gradually deploy the changes to production, that way we can deliver a small percentage at a time. It’s not so simple but it is possible (as explained [here](http://recursion.org/incremental-rails-upgrade)).

There are some caveats with the dual boot though. If your test suite takes three hours to run, for example, it will double your test suite run time to 6 hours. So then it is not a great idea to run both versions every time. In those cases, we usually run a nightly build with both versions (master and rails-next-version branches).

## Step 4: Assessing whether we can upgrade a dependency or not

After shipping all deprecation warnings fixes to the master branch and setting up the dual boot, it's time for us to work on the project dependencies.

Sometimes dependencies are backwards compatible with the current version of Rails. Within the libraries, you will find code that looks like this:

```ruby
if Rails::VERSION >= 5.1
  # does X
else
  # does Y
end
```

If that is the case, then you might be able to just upgrade the dependency using `bundle update`.

If the dependency does not have backwards compatible code, then, using the next_rails gem, we add something like this to your application's Gemfile:

```ruby
if next?
  gem "dep", "~> 1.2.3"
else
  gem "dep", "~> 0.9"
end
```

This is the method definition for `next?`

```ruby
def next?
  File.basename(__FILE__) == "Gemfile.next"
end
```

And all it does is to use a symlink called `Gemfile.next` in order to keep a separate lockfile for the new Rails version: `Gemfile.next.lock`

In cases when we can't just update the gem's version, we have four alternatives:

- Find an alternative library
- Write our own code to address the library’s function and remove the library dependency
- Submit a contribution to the library to add support for the version of Rails that we need
- If the contribution is never merged, we consider starting to maintain a fork of the library

You can learn more about that in this other article that we recently released about [Unmaintained Open Source Projects](https://www.fastruby.io/blog/open-source/guide-for-unmaintained-open-source-projects.html).

## Step 5: Create the rails upgrade branch and submit a Pull request

After adjusting all the dependencies in the application for both Rails versions, we create the `rails-next-version` branch with all the dual boot code and open a PR that will target to master. The idea is that from now on, every PR that we create and we can't merge to master directly, will target to this `rails-next-version` branch. As you can imagine, this big PR won't be merged until all necessary changes to the upgrade are done.

This helps us deliver small testable changes during the upgrade and keep a stable branch that we can use as base.

## Step 6: Create new branches for each update that is needed

For every story that we're working on, we create a new pull request. If the change is not backwards compatible the PR will target to the `rails-next-version` branch, if it is, it will target to the `master` branch.

At this point if we run the test suite using the Rails 5.2 changes, it's a probability that a bunch of tests will fail. It's time to address them and open a pull request for each one or for each file or feature, depending of the complexity of the changes.

When addressing these failures, we recommend that you create one story per root cause. There may be 100s of failures for one root cause. So, we recommend that you start with the root causes that fix the most amount of tests.

Sometimes there will be little snippets of code that you can write to make the changes backwards compatible, they are called [rails upgrade shims](https://medium.com/@ujjawal.dixit/what-is-a-shim-72d9ac5d8620)

## Step 7: Making sure that everything works

When updating the application we always hope that we didn't break any behavior, and even with a reliable test suite, we know that normally there are visual issues that only come up when you do a "real integration testing". That's why we always do quality assurance and deploy the code to a QA environment.

That work usually is done with the help of someone from our client's team or by their own QA team.

## Last Step: Merge the rails upgrade branch

If all changes are done and we have everything working in the `rails-next-version` branch, you can finally take a breath!
It's time to merge the rails upgrade PR and celebrate.

<iframe src="https://giphy.com/embed/KYElw07kzDspaBOwf9" width="480" height="234" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/the-office-dunder-mifflin-KYElw07kzDspaBOwf9">via GIPHY</a></p>

## And that is it!

If you want to understand more about our upgrade process, please visit [FastRuby.io](https://www.fastruby.io).
And if you have any question we would love to reply to you here in the comments section!
