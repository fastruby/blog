---
layout: post
title: "Upgrading a Huge Monolith from Rails 4.0 to Rails 5.1"
date: 2018-02-16
categories: ["rails", "upgrades", "case-study"]
author: "emily"
---

We recently collaborated with [Power Home Remodeling](https://powerhrg.com) on a [Rails upgrade](https://fastruby.io) for their self-described “monolith CRM/ERP application” and were able to speak to them about their experience with [Ombu Labs](https://www.ombulabs.com).

<!--more-->

We talked to [Ben Langfeld](https://www.linkedin.com/in/benlangfeld/), Application Solutions Architect at [Power Home Remodeling](https://powerhrg.com), about the work on their app, Nitro. According to Ben, their monolithic CRM/ERP application is continuously built by a team of approximately 50 developers, system administrators, testers and support staff. The application contains *over 500,000 lines of Ruby on Rails and Javascript code*, and by their own definition, is one of the most complex Rails applications out there in terms of scope.

Like many companies, [Power Home Remodeling](https://powerhrg.com) was having **difficulty allocating developer attention to the [Rails upgrade](https://fastruby.io) project** due to the demands of feature work coming from other areas of the business. That is why they decided to come to [Ombu Labs](https://www.ombulabs.com) for help.

Nitro is a [Component-Based Rails Application](http://shageman.github.io/cbra.info/). CBRA is an approach which organizes Rails applications into Ruby Gems and Rails Engines. By using this approach, they're able to parallelize their test suite, therefore making CI faster, and reducing merge conflicts due to the large size of their team. Also, they are able to onboard new developers faster by having the ability to separate them into teams based on gems/engines instead of having them work their way through the entire codebase. For more information about CBRA, check out this video: "[Scaling Your Rails App Codebase with CBRA - Ben Klang](https://www.youtube.com/watch?v=tkL9On9HVHQ)".

We executed a **full upgrade of the application from Rails 4.0 to 5.1** and prepared the company for an eventual [5.2](http://weblog.rubyonrails.org/2017/11/27/Rails-5-2-Active-Storage-Redis-Cache-Store-HTTP2-Early-Hints-Credentials/) upgrade. This necessary upgrade of their application led to a “reduction of risk in terms of repeat bugfix/feature development work compared to what is available in a more modern stack”.

According to Ben, “Ombu augmented our in-house team with a specific capacity for the upgrade project, **enabling our other developers to retain focus on direct business goals**.” [Ombu Labs](https://www.ombulabs.com)' exclusive focus on the Rails upgrade allowed the developers at [Power Home Remodeling](https://powerhrg.com) to continue their work on features and other goals without distractions. In the end, [Power Home Remodeling](https://powerhrg.com) received an application with up-to-date Rails versions and was able to make progress on their other work as well.

For more information about upgrading your Rails application, check out our "[Upgrade Rails Series](https://www.ombulabs.com/blog/tags/upgrades)", a series of do-it-yourself guides to upgrading Rails.
