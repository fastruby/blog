---
layout: post
title: "Merging Multiple SimpleCov Coverage Results"
date: 2019-10-29 13:56:00
categories: ["Rails", "Simplecov", "Upgrades"]
author: bronzdoc
---

As part of our [Roadmap](https://www.fastruby.io/roadmap) service at [FastRuby.io](https://fastruby.io), we have to analyze the test suite of the application we are upgrading to give a proper estimate on how long it will take us to upgrade. We use [SimpleCov](https://github.com/colszowka/simplecov) for this.

Most of our clients use parallelization in their continuous integration tools. SimpleCov generates multiple `.resultset.json` files for the same codebase. Our goal was to have a single result for the whole application, so in this blog post we are going to show you how we solved that problem.

<!--more-->

Some of the applications we upgrade are outdated and setting them up can be difficult. Sometimes they have no documentation, missing steps on how to set them up, or outdated installation steps. Even after setup, the test suite of these applications can take several hours to complete and generate a coverage report.

So, we recently decided to take a different approach for this problem. Instead of executing the tests locally and generating the report, we rely on our client's CI configuration to get the coverage data and move on. After all, the coverage report is just a metric to give us an idea on how much effort it will take us to complete the upgrade.

Not everything is rosy, we found a problem with this approach too. Continuous integration services (like Circle CI) allow you to parallelize the execution of any command and a common pattern is to execute different parts of your test suite in different containers. This will make it faster, since now you'll spread the load of your test in different containers. The problem with this is that if you are running [SimpleCov](https://github.com/colszowka/simplecov) it will generate a result for each of your containers. So, to have the full coverage report you'll have to merge all results to generate one final coverage resultset.

We want to share a little script on how to do the merging and generate a complete coverage.

```ruby
class SimpleCovMerger
  def self.report_coverage(base_dir:, ci_project_path:, project_path:)
    new(base_dir: base_dir).merge_results
  end

  attr_reader :base_dir, ci_project_path, project_pathj

  def initialize(base_dir: ci_project_path:, project_path:)
    @base_dir = base_dir
    @ci_project_path = ci_project_path
    @project_path = project_path
  end

  def merge_results
    results = all_results.map do |file|
      hash_result = JSON.parse(clean(File.read(file)))
      SimpleCov::Result.from_hash(hash_result)
    end

    result = SimpleCov::ResultMerger.merge_results(*results)

    result.command_name = "RSpec"
    SimpleCov::ResultMerger.store_result(result)

    result.format!
  end

  private

  def all_results
    Dir["#{base_dir}/.resultset-*.json"]
  end

  def clean(results)
    results.gsub(ci_project_path, project_path)
  end
end
```

To use it you'll have to be aware of a couple of parameters:

* base_dir         - This is the directory where you stored all your `.resultset.json` from your different containers/machines from your CI service
* ci_project_path  - The path where your project is stored in your CI service
* project_path     - The path of the project you are generating a coverage report

```ruby
SimpleCovMerger.report_coverage(base_dir, ci_project_path, project_path)
```

# Conclusion
We hope you'll find this code snippet helpful for your purposes. Please let us know if you have a better way or any ideas for improving it.
