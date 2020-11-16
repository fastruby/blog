---
layout: post
title: "Upgrade Rails 101: The Roadmap to Smooth Upgrades"
date: 2019-06-26 10:01
reviewed: 2020-03-05 10:00:00
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
to the next version of Rails. As if that was not enough, I told attendees
that they could use a sample, open source application to practice our steps to
upgrade: [https://github.com/alphagov/e-petitions](https://github.com/alphagov/e-petitions)

I should have used *only* the sample application. As the workshop went on, I found
myself addressing issues regarding random Rails applications **and** the sample
application.

## All Environments Are Different

When starting the set of exercises, there was a slowdown addressing environment
issues. There is always something slightly off about someone's environment that
throws a wrench in the works.

This could have been much simpler providing a `Dockerfile` and requiring attendees
to have [`Docker`](https://www.docker.com) installed. That way, the setup would
have been something like "just run `docker-compose up`" and done.

## More Details

When describing the steps to create the [Rails upgrade roadmap](https://fastruby.io/roadmap),
I should have provided even more detail for every step. For people that were stuck in a step,
I could have had branches on my sample Git repository. For each step, I could
have had a checklist to make sure that the attendees got to a stage that would
not stop them moving forward.

## Results

I'm very happy with the feedback I received after the workshop. It was a great
experience and I plan to keep conducting this workshop in other conferences.
There is certainly room for improvement and I'm sure the next iteration will be
even better than the first one.

I will be conducting a new instance of the workshop in the next
[Southeast Ruby](https://southeastruby.com). I hope attendees will learn from
our experience and avoid typical mistakes.

## Reference

Here are the slides from my workshop:

<script async class="speakerdeck-embed" data-id="98e4c8ff073a49b093f759440726ab8a" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

<br/>Unfortunately this time the workshops were not recorded, so I won't be
able to share a video with my presentation. You can find the companion page for
my workshop over here: [https://fastruby.io/upgrade](https://fastruby.io/upgrade).

Finally, if you are interested in upgrading from Rails 2.3 all the way to Rails 5.2
you can read all of our articles from our [Rails Upgrades series](https://fastruby.io/blog/tags/upgrades).

This workshop is a by-product of our productized service: [The Roadmap](https://fastruby.io/roadmap).
I wouldn't have been able to conduct it without the support by the team at
[OmbuLabs](https://www.ombulabs.com). Thank you all!

If you're not on Rails 6.0 yet, we can help! Download our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/).
