---
layout: post
title: "How to Debug Non-Deterministic Test Failures with RSpec"
date: 2019-09-17 15:56:00
categories: ["rspec", "debug"]
author: etagwerker

---

I recently wrote a spec for [`metric_fu`](https://rubygems.org/gems/metric_fu) which
accidentally introduced a [non-deterministic spec](https://martinfowler.com/articles/nonDeterminism.html)
(a flaky spec!). I had **no idea** why it was randomly failing. This is an
article to explain the process I followed to debug this issue.

<!-- more -->

The test that I wrote was testing the integration between `metric_fu` and
[`reek`](https://rubygems.org/gems/reek). When I started I wasn't familiar with
neither of those projects' codebases, so bear with me.

This is the code that randomly worked/failed:

```ruby
context "with real output, not mocked nor doubled" do
  let(:result) do
    {
      file_path: "spec/support/samples/alfa.rb",
      code_smells: [
        {
          lines: [1],
          message: "has unused parameter 'echo'",
          method: "bravo",
          type: "UnusedParameters"
        }
      ]
    }
  end

  before do
    @generator = MetricFu::ReekGenerator.new(dirs_to_reek: ["spec/support/samples"])
    @generator.emit
  end

  it "returns real data" do
    @matches = @generator.analyze

    expect(@matches.first).to eq(result)
  end
end
```

Source: [`https://github.com/fastruby/metric_fu/blob/reek-dep/spec/metric_fu/metrics/reek/generator_spec.rb#L162-L187`](https://github.com/fastruby/metric_fu/blob/reek-dep/spec/metric_fu/metrics/reek/generator_spec.rb#L162-L187)

Why did I write that spec? I'm glad you asked.

After bumping the dependency for
`reek` I noticed that `generator_spec.rb` was working just fine, which was a
little suspicious. This lead me to believe that there was no real "integration
spec" for a very simple scenario.

If you don't have a [CI failure](https://travis-ci.org/metricfu/metric_fu/jobs/584773780)
to refer to, a quick and basic way to test a flaky spec is by using this bash line:

```bash
while bundle exec rspec spec; do :; done
```

That line will run `bundle exec rspec spec` until RSpec fails and returns a non-zero
exit code.

```bash
Failures:
355
356  1) MetricFu::ReekGenerator analyze method with real output, not mocked nor doubled returns real data
357     Failure/Error: expect(@matches.first).to eq(result)
358     
359       expected: {:code_smells=>[{:lines=>[2, 3, 4], :message=>"takes parameters ['echo', 'foxtrot', 'golf'] to 3 meth...f'", :method=>"Alfa#delta", :type=>"UnusedParameters"}], :file_path=>"spec/support/samples/alfa.rb"}
360            got: nil
361     
362       (compared using ==)
363     # ./spec/metric_fu/metrics/reek/generator_spec.rb:174:in `block (4 levels) in <top (required)>'
364     # ./spec/support/timeout.rb:6:in `block in <top (required)>'
```

Sometimes the result returned by `reek` is an empty result set!

Non-deterministic results have always been hard to debug for me. Fortunately
`metric_fu` is using RSpec and it had the right setup for me to start digging
into it.

This is what its RSpec's configuration looks like:

```ruby
RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  # Skip specs tagged `:slow` unless SLOW_SPECS is set
  config.filter_run_excluding :slow unless ENV["SLOW_SPECS"]
  # End specs on first failure if FAIL_FAST is set
  config.fail_fast = ENV.include?("FAIL_FAST")
  config.order = :rand
  # ...

```

The important part there is the line where it randomizes the execution of test
scenarios. If you don't do this in your specs, you are at risk. The risk is that
your scenarios **will only run in a very specifically defined order**.

The problem with this is that some scenarios might be _leaking state_ into another
scenario without you knowing it. This is a ticking time bomb. In the near future
you might write a scenario which alters the execution order and starts causing
_random looking_ problems.

I strongly recommend you always run your [RSpec](http://rspec.info) tests in
random order.

Moving on, when you specify random ordering in your RSpec configuration, its
output will show the _seed_ number at the end. For example:

```bash
...
Failed examples:

rspec ./spec/metric_fu/metrics/reek/generator_spec.rb:181 # MetricFu::ReekGenerator analyze method with real output, not mocked nor doubled returns real data

Randomized with seed 39100
```

Then you can use that [seed number](https://relishapp.com/rspec/rspec-core/v/3-7/docs/command-line/order)
to replicate the execution order that RSpec used to run each test scenario:

```
rspec spec --seed 39100
```

If you combine that with `byebug` (or `pry`!), you can start debugging the
flakiness with the right state.

```ruby
[180, 189] in /fastruby/metric_fu/spec/metric_fu/metrics/reek/generator_spec.rb
   180:
   181:       it "returns real data" do
   182:         @matches = @generator.analyze
   183:
   184:         byebug
=> 185:         expect(@matches.first).to eq(result)
   186:       end
   187:     end
   188:
   189:     context "without reek warnings" do
(byebug) dirs_to_reek = @generator.options[:dirs_to_reek]
["spec/support/samples"]
(byebug) Dir[File.join(dir, "**", "*.rb")]
[]
(byebug) dir
"spec/support/samples"
(byebug) Dir.pwd
"/Users/etagwerker/Projects/fastruby/metric_fu/spec/dummy"
```

At this point, RSpec executed all my test scenarios in a particular order that
will cause that flaky spec to fail. That is good news! (Reproducing a flaky spec
is always great!)

As you can see, there is something fishy going on. I added my support file to
`spec/support` but RSpec's working directory is `path/to/metric_fu/spec/dummy`.
The weird part is that sometimes `Dir.pwd` is `path/to/metric_fu` and other
times it's `path/to/metric_fu/spec/dummy`.

Within the configuration file (`spec/spec_helper.rb`) I find these lines:

```ruby
def run_dir
  File.expand_path("dummy", File.dirname(__FILE__))
end

config.before(:suite) do
  MetricFu.run_dir = run_dir
end
```

My working hypothesis now is that `run_dir` sometimes is one thing and other
times it is another, depending on the load order of RSpec's test scenarios. I
find that `MetricFu` already defines a _namespaced_ method called `run_dir`:

```ruby
module MetricFu
  # ...

  def run_dir
    @run_dir ||= Dir.pwd
  end

```

So now my solution hypothesis is that changing the method name might fix the
flakiness. I go ahead and change the method name in `spec_helper.rb`:

```ruby
  def dummy_dir
    File.expand_path("dummy", File.dirname(__FILE__))
  end

  config.before(:suite) do
    MetricFu.run_dir = dummy_dir
  end
```

I run my test suite:

```
rspec spec --seed 39100
```

Unfortunately that did not solve the problem. The flakiness remained:

```
Failures:
355
356  1) MetricFu::ReekGenerator analyze method with real output, not mocked nor doubled returns real data
357     Failure/Error: expect(@matches.first).to eq(result)
358     
359       expected: {:code_smells=>[{:lines=>[2, 3, 4], :message=>"takes parameters ['echo', 'foxtrot', 'golf'] to 3 meth...f'", :method=>"Alfa#delta", :type=>"UnusedParameters"}], :file_path=>"spec/support/samples/alfa.rb"}
360            got: nil
361     
362       (compared using ==)
363     # ./spec/metric_fu/metrics/reek/generator_spec.rb:174:in `block (4 levels) in <top (required)>'
364     # ./spec/support/timeout.rb:6:in `block in <top (required)>'
```

I check once again and `Dir.pwd` is sometimes one thing and other times another.

So, as usual, flakiness seems to be related to "leaky state". After some digging
I'm 80% sure that leaky state is coming from `MetricFu.run_dir`.

Any sort of modification to that "global" variable in one scenario will leak
into other scenarios if you are not careful.

So I decide to address this problem in two different ways:

- Provide a _native_ way to run `MetricFu` within a directory
- Stop switching directories between scenarios

## `MetricFu.with_run_dir`

I add this utility method:

```ruby
module MetricFu
  def with_run_dir(dir, &block)
    old_dir = run_dir
    self.run_dir = dir

    block.call

    self.run_dir = old_dir
  end
```

This allows me to run `MetricFu` report generation code within a specific
directory and not leak state.

## Stop Switching Directories

I get rid of the problematic `before(:suite)` block.

<img src="/blog/assets/images/metric-fu-spec-helper-change.png" alt="before(:suite) which caused flaky specs" class="half-img">

This generates a couple of failures in the test suite, which I decide to solve
by calling the `MetricFu.with_run_dir` method when needed and moving files from
`spec/dummy` to `spec/support`.

## Final Thoughts

These are some tips you can use next time you run into a non-deterministic
failure. I know that "leaky state" is not the only root cause of flaky specs,
but it's probably the most common root cause.

I can now confidently say that I know a little more than nothing about `reek` and
`metric_fu`'s source code. Here is the pull request with all the changes:
[https://github.com/metricfu/metric_fu/pull/306](https://github.com/metricfu/metric_fu/pull/306)

Check out the next section if you want to learn more!

## Resources

Others have written about this topic extensively, so if you are interested in
knowing more about flaky tests, I recommend you read further:

- https://building.buildkite.com/5-ways-weve-improved-flakey-test-debugging-4b3cfb9f27c8
- https://samsaffron.com/archive/2019/05/15/tests-that-sometimes-fail
- https://www.codewithjason.com/common-causes-flickering-flapping-flaky-tests/
