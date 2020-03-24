---
layout: post
title: "Our Rails Upgrade Process: How to bundle update rails"
date: 2020-03-17 10:30:00
reviewed: 2020-03-19 10:00:00
categories: ["rails", "upgrade"]
author: "cleiviane"
---

We know that there are many challenges involving a Rails upgrade project. Depending on how big is your application, how old is your Rails version and how well structured your code is, it can be difficult to perform that job and keep your sanity. If you don't find a reliable and trustable process to guide you from version X to version Y, you can end-up in a nightmare.

The good news is that here at [Ombu Labs](https://www.ombulabs.com/), we have been upgrading Rails applications for over 10 years now and this gave us a know-how to define a process that has proven to be very effective. And today I want to share Our Rails Upgrade Process with you.

<!--more-->

## Step 1: Finding deprecation warnings

The first thing that we do is to search for deprecation warnings in the application, which are log messages suggesting things that you will need to change when moving for the next version of Rails. That can be because something will either be removed from the source code or the code will work in a different way.

You might find these deprecation warnings by searching at the `production.log` or tracking then down in your Log Management Software, such as [Sentry](https://sentry.io/) or [Splunk](https://www.splunk.com).

For each different deprecation warning that we find, we create one story in our backlog software (at Ombu Labs we use [Pivotal Tracker](pivotaltracker.com) to help us with that). This will make things easier to code review and to test in QA.

## Step 2: Fixing all deprecation warnings

After create all stories for the deprecation warnings, is time to address them one by one. Deprecation warnings are usually pretty straightforward, the messages are clear about what needs to change. They are also backwards compatible which means that you can fix them and merge directly to the current version of Rails.

A good examples is the deprecation warnings caused by the changes in `ActiveRecord::Dirty` in the Rails 5.2 version. We wrote [this article](https://www.fastruby.io/blog/rails/upgrades/active-record-5-1-api-changes.html) while ago showing how to address them.

## Step 3: Add dual boot for the Rails version

To help us switch between the current Rails version and the new one, we usually create a dual boot mechanism. The fastest way is to install the handful gem [next_rails](https://github.com/fastruby/next_rails). Please, [visit this article](https://www.fastruby.io/blog/upgrade-rails/dual-boot/dual-boot-with-rails-6-0-beta.html) where we showed how you can install and setup the gem in your local environment and your CI server.


## Step 4: Assessing whether we can upgrade a dependency or not

After shipping all deprecation warnings fixes to the master branch and setup the dual boot, it's time for us to handle with the project dependencies.

Sometimes dependencies are backwards compatible with the current version of Rails. Within the libraries, you will find code that looks like this:

```
if Rails::VERSION >= 5.1
  # does X
else
  # does Y
end
```

If that is the case, then you might be able to just upgrade the dependency using `bundle update`.

If the dependency does not have backwards compatible code, then, using the next_rails gem, you can add something like this to your application's Gemfile:

```
if next?
  gem "dep", "~> 1.2.3"
else
  gem "dep", "~> 0.9"
end
```

## Step 5: Create the rails upgrade branch and submit a Pull request

After adjust all the dependencies in the application for the both Rails versions, we create the `rails-next-version` branch with all the dual boot code and open a PR that will target to master. The idea is that from now one, every PR that we create and we can't merged to master directly, will target to this `rails-next-version` branch. As you can imagine, this big PR won't be merged until all necessary changes to the upgrade are done.

This help us to deliver small testable changes during the upgrade and keep a stable branch that we can use as base.

## Step 6: Create new branches for each update that is needed

For every story that we're working on, we create a new pull request. If the change is not backwards compatible the PR will target to the `rails-next-version` branch, if it is, it will target to the `master` branch.

At this point if we run the test suite using the Rails 5.2 changes, it's probably that a bunch of tests will fail. It's time to address them and open a pull request to each one or for each file or feature, depending of the complexity of the changes.

## Last Step:  Merge the rails upgrade branch

If all changes are done and we have everything working in the `rails-next-version` branch, you can finally take a breath!
It's time to merge the rails upgrade PR and celebrate.

<iframe src="https://giphy.com/embed/KYElw07kzDspaBOwf9" width="480" height="234" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/the-office-dunder-mifflin-KYElw07kzDspaBOwf9">via GIPHY</a></p>

## And this is it!

If you want to understand more about our upgrade process, please visit [our FastRuby page](https://www.fastruby.io).
And if you have any question we would love to reply to you here in the comments section!
