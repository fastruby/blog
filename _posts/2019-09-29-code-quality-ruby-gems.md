---
layout: post
title: "Three Awesome Libraries to Assess Code Quality in Ruby"
date: 2019-09-29 10:56:00
categories: ["ruby", "quality"]
author: etagwerker

---

As part of our [Rails upgrade](https://fastruby.io) business we get to evaluate
a lot of codebases every month. We usually need a quick way to assess the quality
of the code we get. For this we like to use [CodeClimate](https://codeclimate.com)
and [SimpleCov](https://github.com/colszowka/simplecov).

CodeClimate is free for open source projects and paid for private projects. I
know that not everybody can pay for their service, so I thought it was a good
idea to share some free, open source alternatives.

Here is a list of 3 tools that can help you assess the quality of your next
codebase.

<!--more-->

What I like about these tools is that they use other Ruby gems to calculate the
complexity of the codebase.

I went ahead and created a sample report for each of them. As my test project, I
picked [`e-petitions`](https://github.com/alphagov/e-petitions/), an open source
Rails application for the [UK Government's petitions service](https://petition.parliament.uk).

All of them use:

- [Flog](https://github.com/seattlerb/flog)
- [Churn](https://github.com/danmayer/churn)

## RubyCritic

[RubyCritic](https://github.com/whitesmith/rubycritic) is a gem that uses
static analysis gems such as [Reek](https://github.com/troessner/reek),
[Flay](https://github.com/seattlerb/flay),
and [Flog](https://github.com/seattlerb/flog) to provide a quality report of
your Ruby code.

One of the best things about this tool is that it provides a quick overview of
the project you're analyzing:

<img src="/blog/assets/images/quality/ruby-critic-overview.png" alt="RubyCritic Overview for alphagov/e-petitions">

With this you can get a glimpse of the complexity and churn in all files.

In the next section you can find all the files that have an "F" grade:

<img src="/blog/assets/images/quality/ruby-critic-f-files.png" alt="RubyCritic: Files that need attention">

With this you can pick what files you want to refactor next. :)

In the last section you can find all the code smells in the project:

<img src="/blog/assets/images/quality/ruby-critic-smells.png" alt="RubyCritic: Smelly files">

This section could use some improvement. It seems to sort code smells alphabetically.
You might want to use that section if you prefer to focus on one smell at a time.

You can play around with a sample report over here:
[https://fastruby.github.io/quality/#ruby-critic](https://fastruby.github.io/quality/#ruby-critic)

## MetricFu

Just like RubyCritic, [MetricFu](https://github.com/metricfu/metric_fu) uses
other Ruby gems to generate a list of reports for you:

<img src="/blog/assets/images/quality/metric-fu-reports.png" alt="MetricFu: All the reports">

Unlike RubyCritic, MetricFu does not provide a quick overview of the application's
codebase. You need to drill down the reports list to investigate each aspect of
the quality report.

For instance, if you want to find what files have been updated the most, you will
need to review the _Churn_ report:

<img src="/blog/assets/images/quality/metric-fu-churn.png" alt="MetricFu: Churn report">

Indeed: Files that change **a lot** in your codebase may be a bad sign.

Just like RubyCritic, MetricFu generates a report using Reek:

<img src="/blog/assets/images/quality/metric-fu-reek.png" alt="MetricFu: Reek report">

With this report you can get a quick glimpse about the most common code smells
in your project.

If you check out the Flog section, you will find the methods that are hardest to
test, the ones that are most complex:

<img src="/blog/assets/images/quality/metric-fu-flog.png" alt="MetricFu: Flog report">

MetricFu is definitely more ambitious than Attractor and RubyCritic, but it hasn't
been actively maintained in years.

You can play around with a sample report over here:
[https://fastruby.github.io/quality/#metric-fu](https://fastruby.github.io/quality/#metric-fu)

## Attractor

This tool is a new tool created by Julian Rubisch. It is certainly simpler than
MetricFu and RubyCritic, as it only uses churn and complexity to calculate the
most _painful_ files of your project.

This graph is quite similar to the one I showed you in RubyCritic's overview
screenshot:

<img src="/blog/assets/images/quality/attractor-churn-complexity.png" alt="Attractor: Churn vs. Complexity">

It shows file complexity (Y Axis) vs. file churn (X Axis). You can quickly
determine which files have changed the most and are most complex. For example:

1. `spec/models/petition_spec.rb`
2. `spec/models/signature_spec.rb`
3. `spec/controllers/sponsors_controller_spec.rb`

Sometimes that information is not very useful. I prefer to focus my refactoring
efforts in application code, not test code. So, if you want to filter by directory,
you can just run this command:

```bash
attractor report -p app
```

That way you can see what application files need some love:

<img src="/blog/assets/images/quality/attractor-filtered-report.png" alt="Attractor: Filter App Files">

In this case, you know that you should probably improve these files:

1. `app/models/signature.rb`
2. `app/models/petition.rb`
3. `app/models/site.rb`

The next section tells you which files are the best candidates for refactoring:

<img src="/blog/assets/images/quality/attractor-refactoring.png" alt="Attractor: Refactoring">

You can play around with a sample report over here:
[https://fastruby.github.io/quality/#attractor](https://fastruby.github.io/quality/#attractor)

## Final Thoughts

Assessing code quality is a tricky subject. Every time you get the opportunity
to join a project, you should make sure you do the homework to assess whether
you’re joining a stable project or a dumpster fire. I hope that you find these
tools useful and that you avoid getting stuck in the _tar pit_!

If you are looking for Rails-specific suggestions for judging the quality of an
application, check out this article: [Legacy Rails (Silently Judging You)](https://www.fastruby.io/blog/upgrade-rails/legacy-rails-silently-judging-you.html)

What tools do you like to use to assess code quality? Let me know in the
comments below! (I know that I forgot to mention a few!)
