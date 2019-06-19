---
layout: post
title: "Upgrade Rails 101: The Roadmap to Smooth Upgrades"
date: 2019-06-19 10:00:00
categories: ["RailsConf"]
authors: ["etagwerker"]
---

This year's [RailsConf](https://railsconf.com) was a special conference for me.
It was my third time attending and my first time speaking at the conference. I
conducted a 2-hour workshop for anyone interested in upgrading their Rails
application: [Upgrade Rails 101: The Roadmap to Smooth Upgrades](https://railsconf.com/program/workshops#session-776)

Here are a few lessons learned from running such an ambitious workshop.

<!--more-->

## Scope

I believe the scope was way too ambitious. I pitched the workshop as an opportunity
to bring *any* Rails application and leave with a [roadmap to upgrade](https://fastruby.io/roadmap)
to the next version of Rails. As if that had not been enough, I also told attendees
that they could use a sample, open source application to practice our steps to
upgrade.

I should have stuck to the sample application. As the workshop went on, I found
myself addressing issues regarding random applications **and** the sample
application.

## All Environments Are Different

When starting the set of exercises, there was a slowdown addressing environment
issues. There is always something slightly off about someone's environment that
throws a wrench in the works.

This could have been much simpler providing a `Dockerfile` and requiring attendees
to have [`Docker`](https://www.docker.com) installed. That way, the setup would
have been something like "just run `docker-compose up`" and done.

## More Details

When describing the steps to create the Rails upgrade roadmap, I should have
provided even more detail for every step. For people that were stuck in a step,
I could have had branches on my sample Git repository. For each step, I could
have had a checklist to make sure that the attendees got to a stage that would
not block them moving forward.

## Reference

You can find the slides to my workshop over here: [https://speakerdeck.com/etagwerker/railsconf-2019-upgrade-rails-101-workshop](https://speakerdeck.com/etagwerker/railsconf-2019-upgrade-rails-101-workshop). Unfortunately this time the workshops were not recorded, so I won't be
able to share a video with my presentation. You can find the companion page for
my workshop over here: [https://fastruby.io/upgrade](https://fastruby.io/upgrade).

Finally, if you are interested in upgrading from Rails 2.3 all the way to Rails 5.2
you can read all of our articles from our [Rails Upgrades series](https://fastruby.io/blog/tags/upgrades).

This workshop is a by-product of our commercial offering: [The Roadmap](https://fastruby.io/roadmap).
I wouldn't have been able to conduct it without the support by the team at
[Ombu Labs](https://www.ombulabs.com). Thank you all! 
