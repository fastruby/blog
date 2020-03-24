---
layout: post
title: "Our Guide for Unmaintained Open Source Projects"
date: 2020-03-24 9:16:00
categories: ["open-source"]
author: etagwerker
---

There are some really [great guides for starting a new open source projects](https://opensource.guide/starting-a-project/), 
yet when it comes to dealing with a possibly abandoned, unmaintained project, 
there is no definitive guide for users, contributors, or maintainers.

I hope that this can be a useful guide for our community.

## Problem

When do you declare that an open source project has been abandoned? How many 
days have to go by until you start maintaining your own fork? What's the 
standard for communicating with maintainers, contributors, and users? How do 
you avoid `n` competing OSS forks of popular projects? How do you avoid 
duplicated work by people who want to maintain popular, but unmaintained OSS 
projects? What's the best way to find **that one fork** everybody is using?

<!--more-->

### Nights and Weekends 

Too many applications out there are using libraries that depend on people 
having enough time during nights and weekends to work on their side projects. 
Most of the maintainers out there are not paid for their work. They might have 
_some help_ from their employers, [Tidelift](https://tidelift.com), 
[GitHub Sponsorships](https://github.com/sponsors), [Gitcoin](https://gitcoin.co), 
or [OpenCollective](https://opencollective.com), but most projects don't have 
financial support.

No wonder many OSS maintainers burn out after years maintaining their project. 
What happens when a maintainer burns out, starts using a different tech stack, 
or even worse, dies?

As users, we should be entirely grateful for their hard work, but we should also
find a way to continue maintaining their OSS project, by starting a new fork 
or backing an existing one.

## Proposal 

Depending on your role in the project, here are some strategies that could help
users and contributors, or maintainers: 

- Continuing maintenance for an abandoned OSS project
- Finding someone else to maintain your OSS project

### Why

There is no clear way to continuing maintenance of an abandoned OSS project. 
There are definitely great guides that share a few important concepts, but not 
a lot of action steps for the case when an OSS project ends in 
_maintenance limbo_: 

- [https://opensource.guide/best-practices](https://opensource.guide/best-practices)
- [https://www.linuxfoundation.org/resources/open-source-guides/winding-down-an-open-source-project/](https://www.linuxfoundation.org/resources/open-source-guides/winding-down-an-open-source-project/)
- [https://medium.com/the-node-js-collection/healthy-open-source-967fa8be7951](https://medium.com/the-node-js-collection/healthy-open-source-967fa8be7951)

### For OSS Users and Contributors

What can you do as someone who actively uses or contributes to the OSS project? 
For example: What can you do when you **really really** need to have support for 
Rails 6.0 for your application but this library is blocking you?

#### Best Judgement for Assessing Abandonment 

Use your best judgment to determine whether the project is truly abandoned or 
just feature complete. 

> There are many projects out there that are not being actively maintained because 
they do one little thing really well. Think about these projects as the outliers
because they are feature complete and have no bugs.

Here are some things to consider when judging the state of an OSS project:

- When was the last time there was a commit to the `master` branch? 
- When was the last time there was a commit to a non-master branch? 
- When was the last time there was a comment in an issue by a maintainer?
- When was the last time there was a code review from one of the maintainers?
- Is the test suite still passing if you submit one small change to the project?
- When was the last version of the library published? (Example: for a Ruby gem, 
you can check in [https://rubygems.org](https://rubygems.org))
- When was the last time an issue or pull request was closed by a maintainer?

#### Inquire

When it is not clear, it is okay to inquire about the status of the project. If 
someone hasn't done it already, you can submit an issue to the project asking 
about the state of things. 

Before you submit your inquiry, you might want to submit a pull request with a 
small improvement to the project. If the change is small enough and it improves 
things, then it should be easy to review or close. Make sure that the test suite 
passes in CI.

You can start your inquiry by saying that you appreciate their dedication and 
thank them for their hard work over the years, then you can ask if they're 
looking for help maintaining the project.

**Do not** demand an answer from the maintainers. Maintainers don't owe you much,
so you will be lucky if you get a response to a nice request. So, 
**please be nice**.

You don't need to offer yourself as a potential maintainer for the project, 
maybe there are other people out there who are in a better position to 
continue maintaining the project.

If you don't get any response for a month, then you can move on to the next 
section.

#### Start Your Own Fork

You could start your own OSS project based on a fork. Before you do that, make 
sure that you check the [contribution network for the project](https://help.github.com/en/github/visualizing-repository-data-with-graphs/viewing-a-repositorys-network). There 
might be someone else updating a fork that already has all the changes you need.

> Fun fact: [Forking a project used to be considered a "bad word"](https://www.bacula.org/why-forking-is-bad/) 
> but I think the rise of GitHub turned that around. 

This is what [Solidus](https://Solidus.io) did with [Spree](https://spree.com).
A group of contributors got together and decided to start a new open source, 
e-commerce framework which started as a fork of Spree.

The [governance model for Solidus](https://solidus.io/blog/2019/07/10/governance-published.html) 
is actually quite interesting and definitely a step in the right direction based 
on lessons learned from Spree and Solidus' history

Assuming you didn't skip any steps, you may want to post a comment in the issue 
you submitted initially. In there you can say that until the maintainers respond, 
you will be maintaining a fork of this project.

### For OSS Maintainers

What can you do as someone who is maintaining an OSS project to make it easier 
on yourself? What can you do as someone who is done maintaining the project 
and wants to move on? Here are some ideas based on my own experience and advice 
from other maintainers.

#### Look for Co-Maintainers

You don't have to do it alone. It's very likely that many of the users and 
contributors of your project would be happy to step up their commitment to 
co-maintain it. [You can go so much further if you build a team of co-maintainers](https://opensource.guide/best-practices/#share-the-workload).

Nobody wants to spend their holidays answering comments, reviewing pull requests, 
or triaging bugs. The nice thing about finding co-maintainers is that they can 
step up when you can't.

A quick and simple way to do this is to post an issue to your repository. 
Another one is to post a notice at the beginning of the README. You don't have 
to accept all the people who are interested, but maybe some recent contributors 
will be interested.

#### Look for Someone to Continue Maintenance

If you can't actively maintain the project anymore, you can update your README 
sharing this with your users and contributors. You can say that your project 
needs a new maintainer and wait for people to reach out to you.

If nobody reaches out to you, then maybe they are using an alternative solution.
You can update your README to mention that your project is no longer being 
maintained and that there are other alternatives to solve a similar problem.

Finally, if you are using GitHub, you can [archive your repository](https://github.blog/2017-11-08-archiving-repositories/). This will show a bar with a warning for 
anyone landing in your project's page.

#### Vet Potential Maintainers or Co-Maintainers

Of course, as a responsible maintainer you don't want to let some random person 
on the Internet maintain your project. Trust needs to be earned. I think that's 
probably the most concerning part about giving up control.

Do you know this person? Do you know someone who knows them? Have they been 
contributing to your project for years? How can you really trust them?

Before you give a person permission to merge to master and publish new versions 
of your library, you can ask them to submit `n` contributions to your project.
That way you can see if they know what they are doing and you trust them to 
steer the project in the right direction.

## Send Me a Pull Request

Did I miss anything? Do you have any tips that could be useful to the OSS 
community?

This article is open source and you can find it here: [https://github.com/fastruby/blog](https://github.com/fastruby/blog). 
So if you see something that could be improved or correct, please fork our repo and 
send a pull request. Thank you! 