---
layout: post
title: "How to Calculate Tech Debt Using Skunk on GitHub Actions"
date: 2020-02-10 16:16:00
categories: ["tech-debt"]
author: etagwerker
---

In preparation for my talk at [RubyConf Australia](https://www.rubyconf.org.au/) this
month, I've been working on a way to make it easy for anyone to run `skunk` on their
Ruby projects. In order to do that I decided to use GitHub Actions. It's a powerful
service by GitHub and it's quite easy to set up.

This is an article about the process that I followed and how you can use it in your own
application.

<!--more-->

[GitHub Actions have been around for more than a year](https://github.blog/2018-10-17-action-demos/)
and I had been meaning to play around with them to incorporate some automation to
our workflows at [FastRuby.io](https://fastruby.io). The good news is that [GoRails](https://gorails.com)
already published an article about setting up CI in your Rails app:
[Continuous Integration with GitHub Actions](https://gorails.com/episodes/github-actions-continuous-integration-ruby-on-rails)

After following those steps, I ended up with a copy/pasted YAML file that looked like this:

```yaml
# .github/workflows/ci.yml

name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      db:
        image: postgres:11
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis
        ports: ['6379:6379']
        options: --entrypoint redis-server

    steps:
      - uses: actions/checkout@v1
      - name: Setup Ruby
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - uses: borales/actions-yarn@v2.0.0
        with:
          cmd: install
      - name: Build and run tests
        env:
          DATABASE_URL: postgres://postgres:@localhost:5432/test
          REDIS_URL: redis://localhost:6379/0
          RAILS_ENV: test
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
        run: |
          sudo apt-get -yqq install libpq-dev
          gem install bundler
          bundle install --jobs 4 --retry 3
          bundle exec rails db:prepare
          bundle exec rails test
```

Considering that [`skunk`](https://github.com/fastruby/skunk) is a Ruby gem (it
doesn't need Rails, Redis, nor Postgres) and I didn't need all the steps I copied
from the GoRails tutorial, I thought it was best to simplify it to look like this:

```yaml
# .github/workflows/skunk.yml

name: Skunk
on: [push]

jobs:
  skunk:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - name: Setup Ruby
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - name: Run Skunk on Project
        run: |
          gem install skunk
          skunk lib/
```

This tells [GitHub](https://github.com) to run the [`skunk`](https://github.com/fastruby/skunk)
action every time there is any push to GitHub. To see an entire list
of events that you can configure: [Webhook Events](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows#webhook-events)

There are only two steps:

1. Setup my Ruby environment. I'm going to need this because `skunk` is a Ruby gem.
1. Install the `skunk` gem and run it on the `lib/` directory.

I really like that the configuration file is easy to read and understand. The
order of the steps defined in the `steps` section is **important**. It will run
steps synchronously, from top to bottom. If you want to run `skunk` for a Rails
application, you can change the last step to `skunk app/`

The next thing I wanted to do is run `skunk` on a pull request in order to
compare the _Stink Score_ between the pull request and `master`. This will help
us answer this question:

> Are we increasing or decreasing the tech debt average in our project?

In order to do this, I had to tweak the call to `skunk` to use the `--branch`
option:

```yaml
# .github/workflows/skunk.yml

name: Skunk
on: [push]

jobs:
  skunk:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - name: Setup Ruby
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - name: Run Skunk on Project
        run: |
          gem install skunk
          CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
          if [[ "$CURRENT_BRANCH" != "master" ]]; then
            echo "Executing within branch: $CURRENT_BRANCH"
            skunk lib/ -b master
          else
            echo "Executing within master branch"
            skunk lib/
          fi
```

There is some `bash` _magic_ in there. The GitHub Action will do one thing if
you are within the context of a pull request (compare action), and another thing
if it is running a commit pushed to the `master` branch.

One last thing I had to add was a step to generate [SimpleCov](https://github.com/colszowka/simplecov)'s
resultset JSON file. Skunk is most useful when it considers code coverage data.
[The StinkScore is a combination of code smells; complexity; and code coverage data](https://github.com/fastruby/skunk#what-is-the-stinkscore).

I tweaked the steps configuration to look like this:

```yaml
steps:
  - uses: actions/checkout@v1
  - name: Setup Ruby
    uses: actions/setup-ruby@v1
    with:
      ruby-version: 2.6.x
  - name: Run test suite with COVERAGE=true
    run: |
      gem install bundler
      bundle install --jobs 4 --retry 3
      COVERAGE=true bundle exec rake test
  - name: Run Skunk on Project
    run: |
      gem install skunk
      CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
      if [[ "$CURRENT_BRANCH" != "master" ]]; then
        echo "Executing within branch: $CURRENT_BRANCH"
        skunk lib/ -b master
      else
        echo "Executing within master branch"
        skunk lib/
      fi
```

Now you can see the difference in tech debt between `master` and your pull
request:

```
Base branch (master) average stink score: 13.42
Feature branch ((HEAD detached at 0315f34)) average stink score: 13.42
Score: 13.42
```

This particular example shows that there is no difference in my application's
technical debt: [https://github.com/fastruby/skunk/pull/26](https://github.com/fastruby/skunk/pull/26).
That's because I didn't change any Ruby code (just a YAML file).

You can see the GitHub Action run over here:
[https://github.com/fastruby/skunk/runs/437118684](https://github.com/fastruby/skunk/runs/437118684)

## Final Thoughts

GitHub Actions can be very useful when you want to run something really quickly
without setting up your own development environment. It can take a lot of trial
and error to get the final configuration right.

If you wanted to give `skunk` a try, now there are _no more excuses_. You don't
need to install anything in your environment. You can add this GitHub workflow
and that's it:

<script src="https://gist.github.com/etagwerker/52e0add0af4281ed38fdc54a502b653f.js"></script>

I hope you can use this free and open source tool to find out your tech debt
hot spots!

## References

- You can see all the trial and error that went into writing this article:
[https://github.com/fastruby/skunk/actions?query=workflow%3ASkunk](https://github.com/fastruby/skunk/actions?query=workflow%3ASkunk)
- A new update to GitHub Actions adds even more features to it:
[https://github.blog/2020-02-06-manage-secrets-and-more-with-the-github-actions-api/](https://github.blog/2020-02-06-manage-secrets-and-more-with-the-github-actions-api/)
