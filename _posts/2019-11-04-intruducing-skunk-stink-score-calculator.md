---
layout: post
title: "Introducing Skunk: Combine Code Quality and Coverage to Calculate a Stink Score"
date: 2019-11-04 10:00:00
categories: ["code-quality"]
author: etagwerker

---

Two weeks ago I had the opportunity to speak at [Solidus Conf 2019](https://conf.solidus.io).
I presented [Escaping the Tar Pit](https://speakerdeck.com/etagwerker/escaping-the-tar-pit-at-solidus-conf-2019)
for the first time and I got to talk about a few metrics that we can use to
quickly [assess code quality](https://www.fastruby.io/blog/ruby/quality/code-quality-ruby-gems.html)
in any Ruby project.

In this article I'd like to talk about [Skunk: A Stink Score Calculator](https://github.com/fastruby/skunk)!
I'll explain why we need it, how it works, and the roadmap for this new tool.

<!--more-->

Every month we get contacted by leads (potential clients) who want to work with
us on their [Rails upgrade projects](https://fastruby.io/roadmap). Given that we
have some basic requirements for all of our new client projects, we want to
carefully analyze every project before we commit to working on it.

We analyze two very important aspects:

1. Code Coverage
2. Code Quality

For Code Coverage we like to use [SimpleCov](https://www.github.com/colszowka/simplecov).
For Code Quality we like to use [RubyCritic](https://github.com/whitesmith/RubyCritic).
Both tools give us a few _signals_ which tell us a story about the health of a
Rails application. We want to answer these questions:

- Is it a dumpster fire?
- Are we going to get ourselves stuck in the tar pit?
- Is it a project that is easy to maintain?

[Skunk](https://github.com/fastruby/skunk) is a Ruby gem that will combine code
quality metrics from [Reek](https://github.com/troessner/reek);
[Flay](https://github.com/seattlerb/flay);
[Flog](https://github.com/seattlerb/flog); and
[SimpleCov](https://github.com/colszowka/simplecov) to calculate a Stink Score
for a file or set of files.

[Skunk](https://rubygems.org/gems/skunk) is a library built on top of
[RubyCritic](https://github.com/whitesmith/rubycritic). It uses the `cost` value
for each module:

```ruby
module RubyCritic
  class AnalysedModule
    def cost
      @cost ||= smells.map(&:cost).inject(0.0, :+) +
                (complexity / COMPLEXITY_FACTOR)
    end
  end
end
```

The `cost` is a combination of smells and complexity:

- Smells: They come from static code analysis performed by Flog; Flay; and Reek.
- Complexity: It comes from Flog's total [ABC metric](http://wiki.c2.com/?AbcMetric)

After determining that the _cost_, Skunk penalizes modules which lack code coverage
by multiplying their cost by a factor directly related to the lack of coverage:

```ruby
module RubyCritic
  # Monkey-patches RubyCritic::AnalysedModule to add a stink_score method
  class AnalysedModule
    PERFECT_COVERAGE = 100

    # Returns a numeric value that represents the stink_score of a module:
    #
    # If module is perfectly covered, stink score is the same as the
    # `churn_times_cost`
    #
    # If module has no coverage, stink score is a penalized value of
    # `churn_times_cost`
    #
    # For now the stink_score is calculated by multiplying `churn_times_cost`
    # times the lack of coverage.
    #
    # For example:
    #
    # When `churn_times_cost` is 100 and module is perfectly covered:
    # stink_score => 100
    #
    # When `churn_times_cost` is 100 and module is not covered at all:
    # stink_score => 100 * 100 = 10_000
    #
    # When `churn_times_cost` is 100 and module is covered at 75%:
    # stink_score => 100 * 25 (percentage uncovered) = 2_500
    #
    # @return [Float]
    def stink_score
      return churn_times_cost.round(2) if coverage == PERFECT_COVERAGE

      (churn_times_cost * (PERFECT_COVERAGE - coverage.to_i)).round(2)
    end
  end
end
```

After doing all these calculations, we get a Stink Score for the files we are evaluating:

```bash
$ skunk
running flay smells
.............
running flog smells
.............
running reek smells
.............
running complexity
.............
running attributes
.............
running churn
.............
running simple_cov
.............
New critique at file:////skunk/tmp/rubycritic/overview.html
+-----------------------------------------------------+----------------------------+----------------------------+----------------------------+----------------------------+----------------------------+
| file                                                | stink_score                | churn_times_cost           | churn                      | cost                       | coverage                   |
+-----------------------------------------------------+----------------------------+----------------------------+----------------------------+----------------------------+----------------------------+
| lib/skunk/cli/commands/default.rb                   | 166.44                     | 1.6643999999999999         | 3                          | 0.5548                     | 0                          |
| lib/skunk/cli/application.rb                        | 139.2                      | 1.392                      | 3                          | 0.46399999999999997        | 0                          |
| lib/skunk/cli/command_factory.rb                    | 97.6                       | 0.976                      | 2                          | 0.488                      | 0                          |
| test/test_helper.rb                                 | 75.2                       | 0.752                      | 2                          | 0.376                      | 0                          |
| lib/skunk/rubycritic/analysed_module.rb             | 48.12                      | 1.7184                     | 2                          | 0.8592                     | 72.72727272727273          |
| test/lib/skunk/cli/commands/status_reporter_test.rb | 45.6                       | 0.456                      | 1                          | 0.456                      | 0                          |
| lib/skunk/cli/commands/base.rb                      | 29.52                      | 0.2952                     | 3                          | 0.0984                     | 0                          |
| lib/skunk/cli/commands/status_reporter.rb           | 8.0                        | 7.9956                     | 3                          | 2.6652                     | 100.0                      |
| test/lib/skunk/rubycritic/analysed_module_test.rb   | 2.63                       | 2.6312                     | 2                          | 1.3156                     | 100.0                      |
| lib/skunk.rb                                        | 0.0                        | 0.0                        | 2                          | 0.0                        | 0                          |
| lib/skunk/cli/options.rb                            | 0.0                        | 0.0                        | 2                          | 0.0                        | 0                          |
| lib/skunk/version.rb                                | 0.0                        | 0.0                        | 2                          | 0.0                        | 0                          |
| lib/skunk/cli/commands/help.rb                      | 0.0                        | 0.0                        | 2                          | 0.0                        | 0                          |
+-----------------------------------------------------+----------------------------+----------------------------+----------------------------+----------------------------+----------------------------+

Stink Score Total: 612.31
Modules Analysed: 13
Stink Score Average: 0.47100769230769230769230769231e2
Worst Stink Score: 166.44 (lib/skunk/cli/commands/default.rb)
```

The most important _signals_ here are:

- Average Stink Score per module
- Most complex files with little to no code coverage

We now know where we stand. We can clearly see the state of the application in
terms of code coverage and project complexity. We can now answer this question:
**"Which are the most complex files with the least coverage?"**

We can use the Stink Score to guide us in our refactoring efforts:

- How can I pay off technical debt and invest in the future of my application?
- If I were to write tests to decrease the stink score, which files could I
write tests for?
- If I were to refactor some of the most complex files, which files with good
code coverage could I refactor?

## Caveats

Skunk expects you to have a `.resultset.json` file in the coverage directory
within the directory that you are evaluating. It uses the data within that file
to calculate the code coverage percentage for each module.

That means that you will have to run your test suite with SimpleCov enabled
**before you call `skunk`**.

Total Stink Score is not a useful metric within a single project, as the total
will continue to grow as you add more features to your application. It is
certainly a useful metric if you use it to _compare two projects_.

## Known Issues

The calculation of the Stink Score is not 100% accurate. It is comparing a
module's code coverage and a module's complexity. It should be a method-based
calculation: It should calculate the complexity of a method, the code coverage
of the same method, then calculate the Stink Score per method.

Finally, the Stink Score of a module should be the sum of all the Stink Scores
in the module.

## Roadmap

Assessing code quality for an application shouldn't stop at the application
level. The Stink Score of our application is composed by two Stink Scores:

- Stink Score of your application
- Stink Score of your dependencies

Right now Skunk will only calculate Stink Score for your application code. In
the future it should consider your dependencies as well, generating a Stink
Score for each individual dependency.

The best way to assess progress in your project is to keep track of the Stink
Score average over time. Is that number going up? Is it going down? How much
does your pull request change the Stink Score average? Right now Skunk does
not support this, so you will have to do it manually.

## Final Thoughts

I know that "stink" is a negative word to judge an application's technical debt
and it might lead you down a negative path. By all means I don't want the Stink
Score to be used in a witch hunt, to point fingers at code authors, or in a
negative way in your team.

I seriously hope that you can use the Stink Score as the compass to move your
team in the right direction. You should be able to use the Stink Score as a
compass to gradually pay off technical debt:

- Writing tests which increase code coverage will improve the Stink Score
- Refactoring complex files will improve the Stink Score

Skunk will show you your location in _the map of technical debt_. It will also
show you a few paths to take to get to a better place. You will be able to
prioritize the paths and pick one to pay off technical debt.

What do you think about this new metric for technical debt? Would you use it
next time you need to evaluate legacy code?

Please let me know in the comments below or come talk to me at
[RubyConf 2019](https://www.rubyconf.org) (I'll be speaking about
[this topic at the conference](https://www.rubyconf.org/program#session-876))
