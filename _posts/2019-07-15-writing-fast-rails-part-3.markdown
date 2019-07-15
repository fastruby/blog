---
layout: post
title:  "Tips for Writing Fast Rails: Part 3"
date: 2019-07-15 08:00
categories: ["rails", "performance"]
author: "luciano"
---

Here we continue with the [series](https://fastruby.io/blog/tags/performance) of articles where we talk how minor adjustments in the code can lead to major performance improvements.

In this article we'll focus on the use of [ActiveRecord::Batches#find_each](https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each) when it comes to iterations across a large number of records.

<!--more-->

## Prefer `Model.find_each` instead of `Model.all.each`

A very common mistake (often seen in background jobs) is to use [ActiveRecord::Scoping::Named::ClassMethods#all](https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all) + [ActiveRecord::Result#each](https://api.rubyonrails.org/classes/ActiveRecord/Result.html#method-i-each) (`Model.all.each`) to iterate a table with several thousands of records on it.

```
Product.all.each do |product|
  product.update_column(:stock, 50)
end
```

The problem with that code is that `Product.all` initialize all the records at once and loads them into memory. This can lead to major memory usage issues in your app.

To be clear, the problem there is not the `.all` but the amount of records that it loads. If you try to iterate a scope like `Product.where(status: :active)` that still loads a huge amount of records, it will lead to the same issues.

To solve this issue we should instead load the records in batches (1000 by default) using [find_each](https://github.com/rails/rails/blob/2a7cf24cb7aab28f483a6772b608e2868a9030ba/activerecord/lib/active_record/relation/batches.rb#L48). This will significantly reduce memory consumption.

```
Product.find_each do |product|
  product.update_column(:stock, 50)
end
```

To set a custom batch size you can use the `batch_size` flag:

```
Product.find_each(batch_size: 200) do |product|
  product.update_column(:stock, 50)
end
```

You can even specify the starting point for the batch, which is especially useful if you want multiple workers dealing with the same processing queue. You can make one worker handle all the records between ID 1 and 5000 and another handle from ID 5000 and beyond.

```
Product.find_each(batch_size: 200, start: 5000) do |product|
  product.update_column(:stock, 50)
end
```

## Conclusion

It is a good practice to always use `find_each`, even though there are not many records on the table. That way if the table grow significantly, you don't have to worry about this issue.

Finally, if you need help improving the performance of your Rails
application, [get in touch with us!](https://fastruby.io/#contact-us) We are constantly looking for new projects and opportunities to help you improve the performance of your Rails app.
