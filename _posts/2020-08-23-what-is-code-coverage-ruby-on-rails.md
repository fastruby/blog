---
layout: post
title: "What are the Code Coverage Metrics for Ruby on Rails?"
date: 2020-08-23 10:00:00
categories: ["rails"]
authors: ["etagwerker"]
---

At FastRuby.io we are constantly looking at code coverage metrics for Ruby on
Rails applications. It's a key indicator for us. We even use that information 
to decide [whether we work on a Rails upgrade project or not](https://www.fastruby.io/blog/rails/upgrades/assessing-rails-upgrades.html).

So, I was interested in seeing code coverage metrics for the [Ruby on Rails framework](https://github.com/rails/rails). 
I couldn't find any information about this online, so I decided to generate a 
few reports for each component.

This is an article about my process and my findings.

<!--more-->

## Process

In order to calculate code coverage, I used [SimpleCov](https://github.com/simplecov-ruby/simplecov) and 
analyzed Rails at [f22dd39](https://github.com/rails/rails/commit/f22dd39cb2adf85d3deeca61f9465206f7bd8df3).

I didn't run the entire test suite from Rails's root directory, I went into 
each component and ran the test suite for that component. I found that this 
was a good idea because each component had its quirks. You can't just run 
`rake test` on each component and expect it to work.

One thing that could be improved in Rails's documentation: It would be nice to 
have clear documentation on running the test suite for each component. For example:
When you run ActionCable you will need to increase your `ulimit` and you will 
need to have Redis running in your environment.

Before running each test suite, I went ahead and added this snippet at the 
beginning of the helper file:

```
require "simplecov"

SimpleCov.command_name "Test: #{rand(1024)}"

SimpleCov.start do
  track_files '{lib}/**/*.rb' 
  add_filter "/test/"
end
```

I had to add the `SimpleCov.command_name` to make sure that all the test rake 
tasks are considered and automatically merged by `SimpleCov`. Without that line 
I was getting unexpected results when running more than one _test_ rake task (e.g. 
running `rake test` and `rake test:system` -- the last process would override
the coverage calculation from the first process)

I used Ruby v2.5.7, Node v12.18.3, Rails master, and SimpleCov v0.19.0 to run 
all my tests.

## ActionCable

This one was a little tricky because I had to change my `ulimit` value. I ran 
into [this issue](https://discuss.rubyonrails.org/t/how-do-i-run-the-test-suite-for-actioncable-im-getting-an-errno-emfile-error/76100) in 
two different MacBooks:

```
Error:
ClientTest#test_many_clients:
Errno::EMFILE: Too many open files - socket(2) for "127.0.0.1" port 3099
    /Users/etagwerker/.rvm/gems/ruby-2.5.7/bundler/gems/websocket-client-simple-e161305f1a46/lib/websocket-client-simple/client.rb:20:in `initialize'
    /Users/etagwerker/.rvm/gems/ruby-2.5.7/bundler/gems/websocket-client-simple-e161305f1a46/lib/websocket-client-simple/client.rb:20:in `new'
    /Users/etagwerker/.rvm/gems/ruby-2.5.7/bundler/gems/websocket-client-simple-e161305f1a46/lib/websocket-client-simple/client.rb:20:in `connect'
    /Users/etagwerker/.rvm/gems/ruby-2.5.7/bundler/gems/websocket-client-simple-e161305f1a46/lib/websocket-client-simple/client.rb:8:in `connect'
    /Users/etagwerker/Projects/fastruby/rails/actioncable/test/client_test.rb:113:in `initialize'
    /Users/etagwerker/Projects/fastruby/rails/actioncable/test/client_test.rb:200:in `new'
    /Users/etagwerker/Projects/fastruby/rails/actioncable/test/client_test.rb:200:in `websocket_client'
    /Users/etagwerker/Projects/fastruby/rails/actioncable/test/client_test.rb:244:in `block (2 levels) in test_many_clients'
    /Users/etagwerker/Projects/fastruby/rails/actioncable/test/client_test.rb:204:in `block (2 levels) in concurrently'
```

By following these steps I managed to solve that problem: 
[https://medium.com/mindful-technology/too-many-open-files-limit-ulimit-on-mac-os-x-add0f1bfddde](https://medium.com/mindful-technology/too-many-open-files-limit-ulimit-on-mac-os-x-add0f1bfddde)

Also, I had to make sure that Redis was running because one of its tests depends
on it.

The average code coverage percentage for ActionCable is 80.85%.

<img src="/blog/assets/images/action-cable-coverage.png" alt="Code Coverage Report for ActionCable" class="half-img">

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActionCable](https://fastruby.github.io/coverage/#action-cable)

## ActionMailbox

The average code coverage percentage for ActionMailbox is 91.94%.

<img src="/blog/assets/images/action-mailbox-coverage.png" alt="Code Coverage Report for ActionMailbox" class="half-img">

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActionMailbox](https://fastruby.github.io/coverage/#action-mailbox)

## ActionMailer

The average code coverage percentage for ActionMailer is 83.05%.

<img src="/blog/assets/images/action-mailer-coverage.png" alt="Code Coverage Report for ActionMailer" class="half-img">

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActionMailer](https://fastruby.github.io/coverage/#action-mailer)

## ActionPack

The average code coverage percentage for ActionPack is 48.67%.

<img src="/blog/assets/images/action-pack-coverage.png" alt="Code Coverage Report for ActionPack" class="half-img">

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActionPack](https://fastruby.github.io/coverage/#action-pack)

## ActionText

This one was a little tricky. I noticed there were two test suites:

```
$ rake -T | grep test
rake test             # Run tests
rake test:system      # Run tests for test:system
```

I managed to run `rake test` successfully, but when trying to run `rake test:system` I 
encountered an issue: [https://gist.github.com/etagwerker/370c4d4f48d777ce22cf704443bd7502](https://gist.github.com/etagwerker/370c4d4f48d777ce22cf704443bd7502)

I tried to fix things inside the `test/dummy` directory by doing this: 

```
cd test/dummy
rake yarn:install
rake assets:precompile
```

Then I ran into [another issue](https://gist.github.com/etagwerker/75f5eb3139e70aa103ddc20ff9c37a83). 
Unfortunately I didn't manage to run `rake test:system` so the coverage report 
was generated with `rake test`.

The average code coverage percentage for ActionText is 81.33%.

<img src="/blog/assets/images/action-text-coverage.png" alt="Code Coverage Report for ActionText" class="half-img">

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActionText](https://fastruby.github.io/coverage/#action-text)

## ActionView

The average code coverage percentage for ActionView is 29.57%. I believe that
average coverage for this component is higher than that, but I had a hard time
running all the tests.

<img src="/blog/assets/images/action-view-coverage.png" alt="Code Coverage Report for ActionView" class="half-img">

This one was a little bit tricky because `rake test` will only run 3 test suites 
for ActionView: [ActionView's rake test output](https://gist.github.com/etagwerker/ee1c9a9e751df6057a4f1a62bb07329d)

So initially it was misreporting the code coverage percentage. It was 
telling me that the coverage percentage for ActionView was 29.57% which is not 
totally accurate.

I took a closer look at all the tests that are present in the component:

```
[etagwerker@luft actionview (master)]$ rake -T
rake assets:compile                  # Compile Action View assets
rake assets:verify                   # Verify compiled Action View assets
rake default                         # Default Task
rake test                            # Run all unit tests
rake test:integration:action_pack    # Run tests for action_pack
rake test:integration:active_record  # Run tests for active_record
rake test:template                   # Run tests for template
rake test:ujs                        # Run tests for rails-ujs
rake ujs:server                      # Starts the test server
```

In order to generate this coverage report, I decided to use `rake test:template`.

ActionView has tests for its JavaScript code. However, this code coverage report 
was generated considering only its Ruby code.

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActionView](https://fastruby.github.io/coverage/#action-view)

## ActiveJob

The average code coverage percentage for ActiveJob is 91.42%.

<img src="/blog/assets/images/active-job-coverage.png" alt="Code Coverage Report for ActiveJob" class="half-img">

It's very interesting that the test suite has to test different _adapters_, so 
you can see that there are many rake tasks available to test each adapter:

```
[etagwerker@luft activejob (master)] $ rake -T
rake test:async                      # Run adapter tests for async
rake test:backburner                 # Run adapter tests for backburner
rake test:default                    # Run all adapter tests
rake test:delayed_job                # Run adapter tests for delayed_job
rake test:inline                     # Run adapter tests for inline
rake test:integration                # Run integration tests for all adapters
rake test:integration:async          # Run integration tests for async
rake test:integration:backburner     # Run integration tests for backburner
rake test:integration:delayed_job    # Run integration tests for delayed_job
rake test:integration:inline         # Run integration tests for inline
rake test:integration:que            # Run integration tests for que
rake test:integration:queue_classic  # Run integration tests for queue_classic
rake test:integration:resque         # Run integration tests for resque
rake test:integration:sidekiq        # Run integration tests for sidekiq
rake test:integration:sneakers       # Run integration tests for sneakers
rake test:integration:sucker_punch   # Run integration tests for sucker_punch
rake test:integration:test           # Run integration tests for test
rake test:isolated                   # Run all adapter tests in isolation
rake test:que                        # Run adapter tests for que
rake test:queue_classic              # Run adapter tests for queue_classic
rake test:resque                     # Run adapter tests for resque
rake test:sidekiq                    # Run adapter tests for sidekiq
rake test:sneakers                   # Run adapter tests for sneakers
rake test:sucker_punch               # Run adapter tests for sucker_punch
rake test:test                       # Run adapter tests for test
```

You can see a test run over here: [https://gist.github.com/etagwerker/888e9128b15da5d8d9574cd453a3418a](https://gist.github.com/etagwerker/888e9128b15da5d8d9574cd453a3418a)

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActiveJob](https://fastruby.github.io/coverage/#active-job)

## ActiveModel

The average code coverage percentage for ActiveModel is 91.69%.

<img src="/blog/assets/images/active-model-coverage.png" alt="Code Coverage Report for ActiveModel" class="half-img">

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActiveModel](https://fastruby.github.io/coverage/#active-model)

## ActiveRecord

I approximate that the average code coverage percentage for ActiveRecord is higher 
than 87.23%. 

<img src="/blog/assets/images/active-record-coverage.png" alt="Code Coverage Report for ActiveRecord" class="half-img">

I didn't get to run all the test rake tasks because I ran into a couple of issues
with MySQL and Oracle, so I ended up running only three rake tasks:

```
bundle exec rake test:postgresql test:sqlite3 test:sqlite3_mem
```

Here is the passing test suite: [https://gist.github.com/etagwerker/f4233a95be711b5bfe37e22a081bfb62](https://gist.github.com/etagwerker/f4233a95be711b5bfe37e22a081bfb62)

You can find SimpleCov's detailed report over here: 
[Code Coverage Report for ActiveRecord](https://fastruby.github.io/coverage/#active-record)

## ActiveStorage

The average code coverage percentage for ActiveStorage is higher than 74.52%.

<img src="/blog/assets/images/active-storage-coverage.png" alt="Code Coverage Report for ActiveStorage" class="half-img">

I had to install `mupdf` in order to run this test suite. Other than that it was quite straightforward.

While I tried to test everything, I didn't get to run the tests associated with cloud providers: [https://gist.github.com/etagwerker/2d855c108ed2acbcdb35dbd59593f296](https://gist.github.com/etagwerker/2d855c108ed2acbcdb35dbd59593f296)

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActiveStorage](https://fastruby.github.io/coverage/#active-storage)

## ActiveSupport

The average code coverage percentage for ActiveSupport is 38.02%.

<img src="/blog/assets/images/active-support-coverage.png" alt="Code Coverage Report for ActiveSupport" class="half-img">

One big caveat: I know for a fact that there is a bug that is misreporting code coverage data for ActiveSupport. I'm still looking into it! 

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActiveSupport](https://fastruby.github.io/coverage/#active-support)

## Summary

Calculating code coverage for a project as big as Ruby on Rails is not trivial. 
Some components are quite tricky to test (e.g. ActiveRecord and ActiveStorage) 
because you need a bunch of external services (an Oracle database or a 
[GCS](https://cloud.google.com) account).

When I started writing this article I set out to run the entire test suite in 
my local environment (Macbook Air), but after hours of trying, I decided to 
run only a few tests for some of Rails's components. Hopefully you will find 
value in knowing how well covered our beloved framework really is.

As you can see, some components have a solid test suite that shows up with 
great code coverage percentages. Only one or two components could use more tests:
Maybe this could be your next OSS contribution? <3

## Resources

If you want to see the changes that would be necessary for Rails to generate 
code coverage reports in Buildkite, you can review this branch: 
[https://github.com/rails/rails/compare/master...fastruby:simplecov](https://github.com/rails/rails/compare/master...fastruby:simplecov)
