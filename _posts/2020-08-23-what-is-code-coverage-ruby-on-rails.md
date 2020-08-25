---
layout: post
title: "What are the Code Coverage Metrics for Ruby on Rails?"
date: 2020-08-23 10:00:00
categories: ["rails"]
authors: ["etagwerker"]
---

At FastRuby.io we are constantly looking at code coverage metrics for Ruby on Rails applications. It's a key indicator for us. We even use that information to decide [whether we work on a Rails upgrade project or not](https://www.fastruby.io/blog/rails/upgrades/assessing-rails-upgrades.html).

So, I was interested in seeing code coverage metrics for the [Ruby on Rails framework](https://github.com/rails/rails). I couldn't find any information about this online, so I decided to generate a few reports for each component.

<!--more-->

## Process

In order to calculate code coverage, I used [SimpleCov](https://github.com/simplecov-ruby/simplecov) and analyzed Rails at [f22dd39](https://github.com/rails/rails/commit/f22dd39cb2adf85d3deeca61f9465206f7bd8df3).

I didn't run the entire test suite from Rails's root directory, I went into each component and I run the test suite for it.

Before running it, I went ahead and added this snippet at the beginning of their helper files:

```
require "simplecov"

SimpleCov.command_name "Test: #{rand(1024)}"

SimpleCov.start do
  track_files '{lib}/**/*.rb' 
  add_filter "/test/"
end
```

I had to add the `SimpleCov.command_name` to make sure that all the test rake tasks are considered and automatically merged by `SimpleCov`.

## ActionCable

The average code coverage percentage for ActionCable is 93.86%.

<img src="/blog/assets/images/action-cable-coverage.png" alt="Code Coverage Report for ActionCable" class="half-img">

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActionCable](https://fastruby.github.io/coverage/#action-cable)

## ActionMailbox

The average code coverage percentage for ActionMailbox is 97.1%.

<img src="/blog/assets/images/action-mailbox-coverage.png" alt="Code Coverage Report for ActionMailbox" class="half-img">

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActionMailbox](https://fastruby.github.io/coverage/#action-mailbox)

## ActionMailer

The average code coverage percentage for ActionMailer is 95.07%.

<img src="/blog/assets/images/action-mailer-coverage.png" alt="Code Coverage Report for ActionMailer" class="half-img">

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActionMailer](https://fastruby.github.io/coverage/#action-mailer)

## ActionPack

The average code coverage percentage for ActionPack is 53.86%.

<img src="/blog/assets/images/action-pack-coverage.png" alt="Code Coverage Report for ActionPack" class="half-img">

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActionPack](https://fastruby.github.io/coverage/#action-pack)

## ActionText

The average code coverage percentage for ActionText is 95.64%.

<img src="/blog/assets/images/action-text-coverage.png" alt="Code Coverage Report for ActionText" class="half-img">

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActionText](https://fastruby.github.io/coverage/#action-text)

## ActionView

The average code coverage percentage for ActionView is 40.63%.

<img src="/blog/assets/images/action-view-coverage.png" alt="Code Coverage Report for ActionView" class="half-img">

This one was a little bit tricky because `rake test` will run the test suite for ActionView plus the integrations with ActionPack and ActiveRecord.

So initially it was misreporting the code coverage percentage:

```
[etagwerker@luft actionview (master)]$ bundle exec rake
/Users/etagwerker/.rvm/rubies/ruby-2.5.7/bin/ruby -w -I"lib:test" -I"/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/rake-13.0.1/lib" "/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/rake-13.0.1/lib/rake/rake_test_loader.rb" "test/template/active_model_helper_test.rb" "test/template/asset_tag_helper_test.rb" "test/template/atom_feed_helper_test.rb" "test/template/capture_helper_test.rb" "test/template/compiled_templates_test.rb" "test/template/controller_helper_test.rb" "test/template/csp_helper_test.rb" "test/template/csrf_helper_test.rb" "test/template/date_helper_i18n_test.rb" "test/template/date_helper_test.rb" "test/template/dependency_tracker_test.rb" "test/template/digestor_test.rb" "test/template/erb/erbubi_test.rb" "test/template/erb/form_for_test.rb" "test/template/erb/tag_helper_test.rb" "test/template/erb_util_test.rb" "test/template/fallback_file_system_resolver_test.rb" "test/template/file_system_resolver_test.rb" "test/template/form_collections_helper_test.rb" "test/template/form_helper/form_with_test.rb" "test/template/form_helper_test.rb" "test/template/form_options_helper_i18n_test.rb" "test/template/form_options_helper_test.rb" "test/template/form_tag_helper_test.rb" "test/template/html_test.rb" "test/template/javascript_helper_test.rb" "test/template/log_subscriber_test.rb" "test/template/lookup_context_test.rb" "test/template/number_helper_test.rb" "test/template/optimized_file_system_resolver_test.rb" "test/template/output_safety_helper_test.rb" "test/template/partial_iteration_test.rb" "test/template/record_identifier_test.rb" "test/template/render_test.rb" "test/template/resolver_cache_test.rb" "test/template/resolver_patterns_test.rb" "test/template/sanitize_helper_test.rb" "test/template/streaming_render_test.rb" "test/template/tag_helper_test.rb" "test/template/template_error_test.rb" "test/template/template_test.rb" "test/template/test_case_test.rb" "test/template/test_test.rb" "test/template/testing/fixture_resolver_test.rb" "test/template/testing/null_resolver_test.rb" "test/template/text_helper_test.rb" "test/template/text_test.rb" "test/template/translation_helper_test.rb" "test/template/url_helper_test.rb"
/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/simplecov-0.19.0/lib/simplecov/configuration.rb:203: warning: instance variable @enable_for_subprocesses not initialized
Run options: --seed 9896

# Running:

.............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................

Finished in 11.675124s, 183.3813 runs/s, 432.3723 assertions/s.
2141 runs, 5048 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for Unit Tests to /Users/etagwerker/Projects/fastruby/rails/actionview/coverage. 1578 / 3884 LOC (40.63%) covered.
/Users/etagwerker/.rvm/rubies/ruby-2.5.7/bin/ruby -w -I"lib:test" -I"/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/rake-13.0.1/lib" "/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/rake-13.0.1/lib/rake/rake_test_loader.rb" "test/actionpack/abstract/abstract_controller_test.rb" "test/actionpack/abstract/helper_test.rb" "test/actionpack/abstract/layouts_test.rb" "test/actionpack/abstract/render_test.rb" "test/actionpack/controller/capture_test.rb" "test/actionpack/controller/layout_test.rb" "test/actionpack/controller/render_test.rb" "test/actionpack/controller/view_paths_test.rb"
/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/simplecov-0.19.0/lib/simplecov/configuration.rb:203: warning: instance variable @enable_for_subprocesses not initialized
Run options: --seed 26645

# Running:

.............................................................................................................................................................................................................................................

Finished in 0.833418s, 284.3711 runs/s, 397.1596 assertions/s.
237 runs, 331 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for Unit Tests to /Users/etagwerker/Projects/fastruby/rails/actionview/coverage. 1113 / 2843 LOC (39.15%) covered.
/Users/etagwerker/.rvm/rubies/ruby-2.5.7/bin/ruby -w -I"lib:test" -I"/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/rake-13.0.1/lib" "/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/rake-13.0.1/lib/rake/rake_test_loader.rb" "test/activerecord/controller_runtime_test.rb" "test/activerecord/debug_helper_test.rb" "test/activerecord/form_helper_activerecord_test.rb" "test/activerecord/multifetch_cache_test.rb" "test/activerecord/polymorphic_routes_test.rb" "test/activerecord/relation_cache_test.rb" "test/activerecord/render_partial_with_record_identification_test.rb"
/Users/etagwerker/.rvm/gems/ruby-2.5.7/gems/simplecov-0.19.0/lib/simplecov/configuration.rb:203: warning: instance variable @enable_for_subprocesses not initialized
Run options: --seed 7235

# Running:

..........................................................................................................................................................................

Finished in 2.969481s, 57.2491 runs/s, 101.7013 assertions/s.
170 runs, 302 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for Unit Tests to /Users/etagwerker/Projects/fastruby/rails/actionview/coverage. 1163 / 2993 LOC (38.86%) covered.
```

It was telling me that the coverage percentage for ActionView was 38.86% which is not totally accurate.

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

ActionView has tests for its JavaScript code. However, this code coverage report was generated considering only its Ruby code.

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActionView](https://fastruby.github.io/coverage/#action-view)

## ActiveJob

The average code coverage percentage for ActiveJob is 75.04%.

<img src="/blog/assets/images/active-job-coverage.png" alt="Code Coverage Report for ActiveJob" class="half-img">

It's very interesting that the test suite has to test different _adapters_, so you can see that there are many rake tasks available to test each adapter:

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

<img src="/blog/assets/images/active-record-coverage.png" alt="Code Coverage Report for ActiveRecord" class="half-img">than 87.23%.

I didn't get to run all the test rake tasks because I ran into a couple of issues with MySQL and Oracle, so I ended up running only three rake tasks:

```
bundle exec rake test:postgresql test:sqlite3 test:sqlite3_mem
```

Here is the passing test suite: [https://gist.github.com/etagwerker/f4233a95be711b5bfe37e22a081bfb62](https://gist.github.com/etagwerker/f4233a95be711b5bfe37e22a081bfb62)

You can find SimpleCov's detailed report over here: [Code Coverage Report for ActiveRecord](https://fastruby.github.io/coverage/#active-record)

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

Calculating code coverage for a project as big as Ruby on Rails is not trivial. Some components are quite tricky to test (e.g. ActiveRecord and ActiveStorage) because you need a bunch of external services (an Oracle database or a GCS account).

When I started writing this article I set out to run the entire test suite in my local environment (Macbook Air), but after hours of trying, I decided to run only a few tests for some of Rails's components. Hopefully you will find value in knowing how well covered our beloved framework really is.

As you can see, some components have a solid test suite that shows up with great code coverage percentages. Only one or two components could use more tests.