---
layout: post
title:  "Tips for Writing Fast Rails: Part 2"
date: 2018-11-13 09:10:00
categories: ["rails", "performance"]
author: "luciano"
---

Some time ago we wrote a couple of [Tips for Writing Fast Rails](https://www.ombulabs.com/blog/performance/rails/writing-fast-rails.html). It was about time we wrote part two so here it is!

<!--more-->

In this article we will focus on the use of [ActiveRecord::Calculations](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html). To show the difference in execution time between doing the math in the database vs. in Ruby we will use [benchmark-ips](https://github.com/evanphx/benchmark-ips). Keep in mind that the table used in these examples has thousands of records, so the difference should be quite noticeable.

## Prefer [ActiveRecord::Calculations#sum](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-sum) instead of [Enumerable#sum](https://apidock.com/rails/Enumerable/sum)

Usually in [Rails](https://rubyonrails.org/) applications we find many references to `Enumerable::sum` for summing values. This is a common mistake because `ActiveRecord::Calculations` provides a way to do this without loading a bunch of `ActiveRecord` objects in memory. If you want to perform mathematical operations for a set of records following the Rails way, `ActiveRecord::Calculations` is the best way to do them in the database.

```ruby
Benchmark.ips do |x|
  x.report("SQL sum") do
    Loan.sum(:balance)
  end

  x.report("Ruby sum") do
    Loan.sum(&:balance)
    # Same as: Loan.all.map { |loan| loan.balance }.sum
  end

  x.compare!
end

# Comparison:
#            SQL sum:        7.89 i/s
#           Ruby sum:        0.03 i/s - 209.85x  slower
```

## Prefer [ActiveRecord::Calculations#maximum](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-maximum) instead of [Enumerable#max](https://apidock.com/ruby/Enumerable/max)

As we explained above, to perform better with calculations you should use `ActiveRecord::Calculations` methods whenever is possible.

```ruby
Benchmark.ips do |x|
  x.report("SQL max") do
    Loan.maximum(:amount)
  end

  x.report("Ruby max") do
    Loan.pluck(:amount).max
  end

  x.compare!
end

# Comparison:
#              SQL max:      541.9 i/s
#             Ruby max:        0.5 i/s - 1113.47x  slower
```

## Prefer [ActiveRecord::Calculations#minimum](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-minimum) instead of [Enumerable#min](https://apidock.com/ruby/Enumerable/min)

```ruby
Benchmark.ips do |x|
  x.report("SQL min") do
    Loan.minimum(:amount)
  end

  x.report("Ruby min") do
    Loan.pluck(:amount).min
  end

  x.compare!
end

# Comparison:
#              SQL min:      533.3 i/s
#             Ruby min:        0.5 i/s - 1017.21x  slower
```

## Conclusion

As you can see, changing the way that you solve the problem can have significant performance improvements. Don't forget to take a look at the `ActiveRecord::Calculations` [documentation](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html) to see all the available methods.
