---
layout: post
title: "OmbuCast Episode 1 - Performance improvements using derailed_benchmarks"
date: 2018-07-23 11:48:00
categories: ["rails", "performance", "benchmark"]
author: "mauro-oto"
---

{% include youtube.html id="iwNWCizFlPM" %}

**Transcript:**

Hello and welcome to the first OmbuCast by Ombu Labs. In this screencast we'll
be taking a look at the
[`derailed_benchmarks`](https://github.com/schneems/derailed_benchmarks) gem,
and how you can use it to benchmark your Rails application and find, and
hopefully fix bottlenecks in your code.

<!--more-->

There are two ways you can benchmark your application, one is statically, which
uses your `Gemfile` to check for any gems which might be too big - which take
too much memory - and the other one is dynamically. To be able to run these,
you'll need to be able to boot your Rails application in production mode
locally. To be able to run the benchmarks I'll be showing, you'll need both the
`derailed_benchmarks` gem and also the
[`stackprof`](https://github.com/tmm1/stackprof) gem.

To show how the gem works, I created a test application, which just returns an
array - a JSON - which has many users, and it's a Rails 5.2 app. So it probably
won't be similar to results you may get from your own applications, but it's
good enough for, just showing how to apply these techniques.

So the first thing that you should do is finding out which one of your endpoints
is slow, be it in production or in development (usually you'll want to optimize
your production endpoints). And when you do that, you will need to measure how
many iterations per second the endpoint can do. This is to get a baseline, an
idea of how many, or, how fast, your endpoint initially is, and then when you
optimize, you can measure if the optimization was good or not. So our first step
then would be to run the IPS task that `derailed_benchmarks` provides and
specify that our path to hit will be `/users.json`.

`PATH_TO_HIT=/users.json bundle exec derailed exec perf:ips`

So we run this task and it will give us a number, which is the
IPS, the iterations per second, in this case it's 263. And this is the starting
point, so any modifications that we do to the code should not make it fall under
263 iterations per second for this endpoint in particular. So to start
optimizing, one thing we can do is to run the `stackprof` task that
`derailed_benchmarks` provides, to find where there are any potential
bottlenecks.

`PATH_TO_HIT=/users.json bundle exec derailed exec perf:stackprof`

Like before, we specify the `/users.json` endpoint, and run the
`stackprof` task. And we get this output from `stackprof`. The methods on top
are the ones that took the most CPU time: the logger, garbage collection. And
then there's one that probably jumps out, which is `Time.parse`, which we're
using in our controller here, and it's not exactly a very time consuming task to
parse the time, but since it's hard-coded, we can use `Time.at`, which is
slightly more performant than `Time.parse`, and it will accomplish the same
result. So what we can do here is to check in a Rails console.

```ruby
2.4.2 :001 > Time.parse("2018-02-12 12:00:00 UTC").to_i
 => 1518436800
```

We can cast to integer, and we get the time that we can use for passing to
`Time.at`, and then we should do the same for the second one.

If you apply this kind of refactor in a real application, note that these should
probably be constants and not just magic numbers. So now we can run the
`stackprof` task again, and, yeah, `Time.parse` should now be gone. This doesn't
necessarily mean that your iterations per second will be better, it's a good
indicator, but you still need to double check. So we can check our IPS again,
and, they're roughly the same as before, which makes sense since it's a very
small modification, and also a very small app. What we can try and do is make
other changes to our app, and one such change can be the optimization of this
code here.

```ruby
users = User.where("send_reminder_at > ?", hour_12).map do |user|
  { id: user.id, email: user.email, full_name: user.full_name }
end
```

This is actually instantiating one user per iteration, so for each user, we have
to instantiate one object - one user object. So to save memory, we can introduce
a gem, it's called `pluck_to_hash`. It acts like ActiveRecord's `pluck`, but it
produces a hash like the JSON we're trying to produce. So let's try to install
it, and see how our iterations per second change, if they change.

```ruby
users_scope = User.where("send_reminder_at > ?", hour_12)
                  .where("created_at < ?", cut_off_date)
users = users_scope.pluck_to_hash(:id, :email, :full_name)
```

And now we can run our IPS task again, and measure the change. And yeah,
that's a noticeable difference, there's about 60 more iterations per second.
Like I mentioned before though, this is a small scale application, so you may
have similar results, or you may not, it depends on your application. Since our
Rails application is serving a JSON, another gem we can use is called
[`OJ`](https://github.com/ohler55/oj). It stands for "optimized JSON", and it's
a faster JSON parser than the default that Rails uses. We'll install it in our
app by adding it to the `Gemfile`. And then we need to create an initializer,
and we can check our updated IPS.

```ruby
# config/initializers/oj.rb

Oj.optimize_rails
```

And that's another performance improvement there, it almost - 400 iterations per
second from 320 and 270 before that, that's almost 100%, you should keep in mind
though that all of these improvements should be done with a good test suite,
since you should make sure that these changes don't break compatibility with
your current application. And again, these modifications probably don't make
much sense in an application this small, but hopefully you can apply them to
your larger Rails applications.

And on a final note, you should benchmark, improve, rinse and repeat. I hope you
found these techniques useful, let me know in the comments if you have doubts
about any of them, and I will see you on the next episode.
