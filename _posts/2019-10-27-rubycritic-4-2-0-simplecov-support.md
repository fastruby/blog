---
layout: post
title: "RubyCritic v4.2.0: Now with SimpleCov Support"
date: 2019-10-27 18:56:00
categories: ["code-quality", "code-coverage"]
author: etagwerker

---

Every time we evaluate a new project we follow a well-defined process to decide
whether we take it or not. We analyze its dependencies; its code coverage; and
its code quality to determine the amount of tech debt in a project. We have been
using [CodeClimate](https://codeclimate.com) to assess code quality
and [SimpleCov](https://github.com/colszowka/simplecov) to assess code coverage.

In my previous article I wrote about free and open source [Ruby gems we can use to assess code quality](https://www.fastruby.io/blog/ruby/quality/code-quality-ruby-gems.html) for any Ruby or
Rails project. After writing that article, I found that [RubyCritic](https://github.com/whitesmith/rubycritic)
was really interesting and its community quite active, so I thought it was a good
idea to add `SimpleCov` support to it: [https://github.com/whitesmith/rubycritic/pull/319](https://github.com/whitesmith/rubycritic/pull/319)

<!-—more-—>

In case you are new to RubyCritic, it is a project that helps you assess code
quality in a Ruby application by using static code analysis tools such as
[flog](https://github.com/seattlerb/flog); [reek](https://github.com/troessner/reek);
[flay](https://github.com/seattlerb/flay); and _code activity tools_ like `git`.

Before I started working on my pull request, I made sure that RubyCritic's
maintainers were open to that feature. I found these two resources which were
a positive sign:

- [RubyCritic's ROADMAP.md](https://github.com/whitesmith/rubycritic/blob/master/ROADMAP.md)
talked about adding support for `SimpleCov`
- Feature request issue: [https://github.com/whitesmith/rubycritic/issues/245](https://github.com/whitesmith/rubycritic/issues/245)

My pull request adds a new section (called Coverage) to RubyCritic's HTML report.
This section is generated if RubyCritic finds a `.resultset.json` in the Ruby
project. It assumes that all the code coverage results are merged in that file.

<img src="/blog/assets/images/rubycritic-simplecov-sample.png" alt="RubyCritic: New SimpleCov Section">

`.resultset.json` is the file that SimpleCov generates every time you load it
before running your test suite. It has all the details you need to know about
which lines are covered in which files.

In the PR you will find that I had to add a new "Analyser" to the mix.
`RubyCritic::Analyser::Coverage` will use the list of `analysed_modules` and
it will try to find coverage data for that particular file:

```ruby
# RubyCritic::Analyser::Coverage
def find_coverage_percentage(analysed_module)
  source_file = find_source_file(analysed_module)

  return 0 unless source_file

  source_file.covered_percent
end

def find_source_file(analysed_module)
  return unless @result

  needle = File.join(SimpleCov.root, analysed_module.path)

  @result.source_files.detect { |file| file.filename == needle }
end
```

Based on the module's coverage, it will calculate the "grade" for it. Right now
it only works at a file level. So it will calculate the grade only based in the
total number of covered lines.

```ruby
# RubyCritic::AnalysedModule
def coverage_rating
  @coverage_rating ||= Rating.from_cost(100 - coverage)
end
```

The Coverage section will sort the modules from least covered to most covered.
I believe that is the best way to find which files are the ones that will need
the most help.

## Limitations

Unfortunately there is no support for parallelization yet. If you are running
your tests in Circle CI or some other CI tool that supports parallelization,
you will need to manually merge all the results into one big `.resultset.json`,
then you can run `rubycritic` to generate the HTML report.

## Next Steps

I'd like to combine code coverage data with code quality data so that you can
quickly get a glimpse of the "total quality" of a module. This will probably not
make it to RubyCritic's core, but it will be a tool that uses `rubycritic` to
generate a combined score of a project's overall quality.

## Final Thoughts

You can now use [RubyCritic](https://rubygems.org/gems/rubycritic) to get an
idea of the technical debt in your project.

What are some tools that you like to use to assess code quality? How important
is it for you to have code coverage in your applications? Please let me know
in the comments below.
