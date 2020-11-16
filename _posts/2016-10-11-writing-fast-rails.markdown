---
layout: post
title:  "Tips for Writing Fast Rails: Part 1"
date: 2016-10-11 08:37:00
reviewed: 2020-03-05 10:00:00
categories: ["performance", "rails"]
author: "etagwerker"
---

[Rails](http://rubyonrails.org/) is a powerful framework. You can write a lot of features in a short period of time. In the process you can easily write code that **performs poorly**.

At [OmbuLabs](https://www.ombulabs.com) we like to [maintain Ruby on Rails
applications](https://www.ombulabs.com/blog/tags/maintenance). In the process
of maintaining them, adding features and fixing bugs, we like to improve
the code and its performance (because we are [good *boy scouts*](http://programmer.97things.oreilly.com/wiki/index.php/The_Boy_Scout_Rule)!)

Here are some tips based on our experience.

## Prefer `where` instead of `select`

When you are performing a lot of calculations, you should load as little as
possible into memory. **Always** prefer a SQL query vs. an object's method call.

<!--more-->

With [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html), it's
easy to forget which methods load
[ActiveRecord::Base](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/base.rb)
objects into memory and which perform a simple query instead.

**The bigger the table, the slower the object load**. If you have a table with 80
columns (**sigh!**), loading each record will take a lot longer than a table
with 3 columns. So, you must  avoid object loads as much as possible. Only load
objects into memory when you **really need them**.

For example:

```ruby
shop_ids.map do |shop_id|
  products.select { |p| p.shop_id == shop_id }.first
end
```

`select` will load all the `products` into memory and then compare the ids.
This will be slower than just using `where`.

This will be much faster:

```ruby
shop_ids.map do |shop_id|
  products.where(shop_id: shop_id).first
end
```

Because it will perform the query and **only after the query returns** it will
load the objects into memory.

## Prefer `pluck` instead of `map`

If you are interested in only a few values per row, you should use `pluck`
instead of `map`.

For example:

```ruby
Order.where(number: 'R545612547').map &:id
# Order Load (5.0ms)  SELECT `orders`.* FROM `orders` WHERE `orders`.`number` = 'R545612547' ORDER BY orders.created_at DESC
=> [1]
```

As with `select`, `map` will load the `order` into memory and it will get the
`id` attribute.

Using `pluck` will be faster, because it doesn't need to load an entire object
into memory.

So this will be much faster:

```ruby
Order.where(number: 'R545612547').pluck :id
# SQL (0.8ms)  SELECT `orders`.`id` FROM `orders` WHERE `orders`.`number` = 'R545612547' ORDER BY orders.created_at DESC
=> [1]
```

For this particular case, `pluck` is six times faster than `map`.

## Avoid N+1 Queries

There are some rare cases where you want an **N+1 query** in your application.
For  instance, when you are using a
[Russian Doll Caching](http://edgeguides.rubyonrails.org/caching_with_rails.html#russian-doll-caching)
strategy, it's a good idea. (full explanation in this interview with [DHH](https://twitter.com/dhh):
  [https://youtu.be/ktZLpjCanvg?t=4m27s](https://youtu.be/ktZLpjCanvg?t=4m27s))

If you are **not** using this caching strategy, you should get rid of all your
[N+1 query problems](http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations)
by including the tables that you need before running the query.

For example:

```ruby
Order.where("created_at > ?", 1.hour.ago)
     .find_each do |order|
  puts order.ship_address.try(:firstname)
end
  Order Load (7866.0ms)  SELECT `orders`.* FROM `orders` WHERE (created_at > '2016-10-05 18:05:48') ORDER BY `orders`.`id` ASC LIMIT 1000
  Address::ShipAddress Load (0.5ms)  SELECT `addresses`.* FROM `addresses` WHERE `addresses`.`type` IN ('Address::ShipAddress') AND `addresses`.`order_id` = 2619178 LIMIT 1
  Address::ShipAddress Load (0.5ms)  SELECT `addresses`.* FROM `addresses` WHERE `addresses`.`type` IN ('Address::ShipAddress') AND `addresses`.`order_id` = 2619179 LIMIT 1
  Address::ShipAddress Load (0.5ms)  SELECT `addresses`.* FROM `addresses` WHERE `addresses`.`type` IN ('Address::ShipAddress') AND `addresses`.`order_id` = 2619180 LIMIT 1
  Address::ShipAddress Load (0.5ms)  SELECT `addresses`.* FROM `addresses` WHERE `addresses`.`type` IN ('Address::ShipAddress') AND `addresses`.`order_id` = 2619181 LIMIT 1
  Address::ShipAddress Load (0.5ms)  SELECT `addresses`.* FROM `addresses` WHERE `addresses`.`type` IN ('Address::ShipAddress') AND `addresses`.`order_id` = 2619182 LIMIT 1
  # ... to N
```

This code will perform **one** query on the `orders` table and **N** queries on
the `addresses` table.

This will be faster:

```ruby
Order.eager_load(:ship_address)
     .where("orders.created_at > ?", 1.hour.ago)
     .find_each do |order|
  puts order.ship_address.try(:firstname)
end
```

This code will perform **only one query**. `eager_load` will [perform a query
with a LEFT OUTER JOIN](http://apidock.com/rails/ActiveRecord/QueryMethods/eager_load)
with the associated table (`addresses`).

If you use `Order.includes(:ship_address)` it will perform two
queries one for the `orders` table and another one for the `addresses` table.
To understand the difference between `includes` and `eager_load`, read
this article about [Rails 4 preloading](http://blog.arkency.com/2013/12/rails4-preloading/).

A good way to find **N+1** queries is using
[bullet](https://rubygems.org/gems/bullet) to get warnings as you develop your
application.

## Conclusion

Sometimes it takes only a few lines of code to improve the performance of your
[Rails](http://rubyonrails.org/) application. Before you start refactoring your
code to perform faster, you should make sure that you have coverage for the
methods that you're improving.

If you found this article interesting, check out
Erik Michaels-Ober's talk
about [Writing Fast Ruby](https://speakerdeck.com/sferik/writing-fast-ruby): [https://www.youtube.com/watch?v=fGFM_UrSp70](https://www.youtube.com/watch?v=fGFM_UrSp70). It has
great tips for improving performance in your Ruby application or library.

And, if you need help improving the
[performance](https://fastruby.io/blog/tags/performance) of your Rails
application, [get in touch](https://fastruby.io/#contact-us)! We are constantly
looking for new projects and opportunities to improve your
[Rails](https://fastruby.io/blog/tags/rails) performance.
