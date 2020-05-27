---
layout: post
title: "Two Commonly Used Rails Upgrade Strategies"
date: 2020-05-27 12:00:00
categories: ["rails", "upgrades"]
author: luciano
---

Rails upgrades can be done in many different ways. Depending on the application that you want to upgrade, some ways make more sense than others. There are factors that determine which Rails upgrade strategy is the best for your case, like how big your application is, or how frequently changes are pushed to the master branch. In this article I'll be covering two common Rails Upgrade strategies so you can decide which one is the best for your application.

<!--more-->

One important note before starting: We highly recommend not skipping any Rails version while upgrading. If your goal is to get to Rails 6.0, and you are in 5.0, make sure to first upgrade to 5.1 and then to 5.2. Each minor version of Rails provides deprecation warnings for the next version. If you skip versions you'll find unexpected errors in your app that will be hard to debug.
Some people have used a strategy that does many version jumps at once. This radical approach makes sense only when your Rails application is very small.

## Long-running Branch

This strategy consists of having a dedicated branch (e.g. `rails-next`) that runs the version of Rails that you want to upgrade to. This branch will contain all the necessary changes for the upgrade. Once the upgrade is ready, you deploy the branch to staging to manually test everything.

This approach makes sense only if the application is relatively small. Otherwise the final Pull Request will end up being too large and hard to review. Also, the application shouldn't have a lot of activity in the master branch. Otherwise it will be hard to maintain because you would have to rebase the `rails-next` branch really frequently to avoid git conflicts.

Pros of this strategy:

- It doesn't require any setup or configuration.

Cons of this strategy:

- If the application is big and has developers constantly working on new features, this approach is not the best idea.
- Once the `rails-next` branch is merged and deployed to staging/production, it can be hard to debug unexpected issues since the branch contains many different kinds of changes.

## Dual Boot + Small Pull Requests

This strategy involves running your application with two different versions of Rails, the one your application is currently running (e.g. Rails 5.0), and the one you want to upgrade to (e.g. Rails 5.1). Once that configuration is implemented, the idea is to submit small Pull Requests that fix specific things for the next version of Rails, and then gradually deploy those Pull Requests to staging and production.

This approach is what we recommend for most Rails upgrades.

Pros of this strategy:

- It allows you to regularly deploy small changes to staging/production and gradually upgrade your application.
- It allows you to easily switch versions in development to debug any discrepancy between your current version of Rails and the next one.
- It allows you to run two versions of Rails in your CI service. This is really important so you make sure that you don't break anything in the current test suite while working on the upgrade.

Cons of this strategy:

- It takes more work to setup.
- Since you're creating Pull Requests for every set of changes, the process can be slower.

Examples of successful Rails upgrades using this approach:

- [Upgrading Shopify to Rails 5](https://engineering.shopify.com/blogs/engineering/upgrading-shopify-to-rails-5-0)
- [Upgrading GitHub from Rails 3.2 to 5.2](https://github.blog/2018-09-28-upgrading-github-from-rails-3-2-to-5-2/)

For more details about dual booting, check out our article about it: [How to Dual Boot your Rails Application](https://www.fastruby.io/blog/upgrade-rails/dual-boot/dual-boot-with-rails-6-0-beta.html).

## Conclusion

Hopefully by now you understand when it's more appropriate to use one strategy or the other. Let us know in the comments if you have any other strategy that you think it worth mentioning.
