---
layout: post
title: "How Fast are Ractors?"
date: 2020-11-04 09:00:00
categories: ["ruby", "performance"]
author: "noahgibbs"
---

Ruby 3x3 is coming in about a month. One of its new concurrency primitives is [Ractors](https://github.com/ruby/ruby/blob/master/doc/ractor.md), which used to be called "Guilds." (The other new concurrency primitive is [Autofibers](https://bugs.ruby-lang.org/issues/13618).)

Ruby has a [Global VM Lock (GVL)](https://www.speedshop.co/2020/05/11/the-ruby-gvl-and-scaling.html), also called the Global Interpreter Lock (GIL), that prevents running Ruby code in more than one thread at once. So Ruby threads are great for I/O like waiting on files or databases. And they're great for cases where a C extension can keep calculating in a background thread while a foreground thread runs Ruby. But you can't do calculations ***in Ruby*** in more than one thread at once within the same process.

At least not until Ruby 3 and not without Ractors.

Great! Now how fast is the current implementation of Ractors?

<!--more-->

## How Do Ractors Work?

The idea goes like this: every Ractor in your process gets its own lock. And every Ractor can potentially hold multiple threads. So now threads hold their Ractor lock, not a single global lock. If you don't ever call `Ractor.new` then you'll still have one Global VM Lock just like as you always did. Or if you have six Ractors, you'll have six locks to share and you can fully use up to six cores of Ruby code all at once.

Ractors have a clear idea of which Ractor holds what chunk of memory. They're almost like sub-VMs in your VM. You can pass objects between Ractors but it's fairly slow. There are objects that can be shared between Ractors, such as anything [frozen](https://www.rubyguides.com/2016/01/ruby-mutability/).

[Here's example code for a multi-Ractor web server in Ruby](https://kirshatrov.com/2020/09/08/ruby-ractor-web-server/) by Kir Shatrov, if you'd like to see Ractors in action. But the code mostly looks a lot like Ruby processes or threads. The big difference is passing objects into and out of each Ractor.

When and why might Ractors be better than existing Ruby threads? The lack of GVL allows them to fully use more cores. So in cases where Ruby can't easily use all your cores, Ractors can be better than threads.

When and why might Ractors be better than multiprocess ("fork") concurrency in Ruby? They save more memory and have cheaper communication than multiple processes. So in a case with a lot of calculation and not a lot of ([working set](https://en.wikipedia.org/wiki/Working_set)) memory per worker, a Ractor can share memory efficiently and communicate quickly between workers. If this sounds a lot like threads in most languages (including JRuby) that's because it's essentially the same thing. CRuby's GVL kept it from efficiently threading Java-style. Ractors attempt to provide Java-style threading in Ruby, but with inter-thread communication more like Go or Erlang.

Note that Ractors aren't going to be a silver bullet for Rails performance any time soon. The memory model that they use doesn't allow easy sharing of global mutable state. That's kind of the point. And so to take advantage of them, Rails is going to need to do a lot less touching global mutable state from its various workers for each request. I don't know if Rails is looking at Ractors yet, but there will be a lot to fix when they do. This happened with threads and they ***did*** eventually fix it. But Ractors will need a lot of changes just like threads did.

## Benchmarking Ractors

Awhile back I [wrote some code](https://github.com/noahgibbs/fiber_basic_benchmarks/) and [some](https://appfolio-engineering.squarespace.com/appfolio-engineering/2019/9/4/benchmark-results-threads-processes-and-fibers) [articles](https://engineering.appfolio.com/appfolio-engineering/2019/10/15/more-fiber-benchmarking) on benchmarking fibers, threads and processes against each other in Ruby. The same basic approach works for Ractors - but we'll want more calculation instead of all I/O. Ractors' entire benefit is when they have to do work ***in Ruby*** rather than just C extensions or waiting for I/O.

So I [wrote a benchmark](https://github.com/noahgibbs/ractor_basic_benchmarks) with some CPU time to it. Specifically, I wrote three benchmarks &mdash; one with threads, one multiprocess and one with ractors &mdash; that each calculate whether each number in a 100-number chunk is prime. Then the 100 prime-ness calculations are turned into a bit vector with the first numbers as the highest-order bits. Here's the code:

```
bools = (item..(item+99)).map { |nn| nn.prime? }
p_int = bools.inject(0) { |total, b| total * 2 + (b ? 1 : 0) }
# return [item, p_int]
```

The prime calculation uses Ruby's Prime library, which is very simple and written in Ruby. You can [read the source](https://github.com/ruby/ruby/tree/master/lib/prime.rb) if you like. It doesn't do anything fancy, it doesn't release the GVL, and it calculates heavily in Ruby.

All three benchmark types (fork, threads, Ractors) calculate the same things in the same way.

The "fork" benchmark runs as a supervisor process, spawns N worker processes and talks to them over interprocess pipes. The "thread" benchmark uses a Mutex and a Ruby array as a queue. And the "ractor" benchmark uses [send/recv and yield/take](https://github.com/ruby/ruby/blob/master/doc/ractor.md) to pass results in the appropriate Ractor style.

All results are sent back, sorted and checksummed to make sure all three benchmarks agree. The benchmark gets to time itself to see how long just the actual processing takes, and the [benchmark coordinator](https://github.com/noahgibbs/ractor_basic_benchmarks/tree/main/comparison_collector.rb) also times each process to see how long it takes with full setup and shutdown. The benchmarks are also run in a randomised order to keep varying load on the host-system load from turning into bias.

And I originally timed this ***on my MacBook. Here's a tip: don't***. The performance and stability are substantially worse on Mac. I was getting around a 20% crash-and-error rate for medium-size benchmarks and some ***weird*** unexpected results. While things will probably be better by the release date, right now the Mac is ***not*** good for benchmarking Ractors.

I'm still checking this on an itty bitty two-core instance, a Linode 4GB. This is a very prerelease feature. And based on the results I'm seeing, it's not ready for larger-scale benchmarking yet. That's okay, let's have a look anyway.

There's some setup time for these benchmarks. If I run just 5 workers with 10 messages/worker plus startup and shutdown, here are the median times in seconds it takes for each benchmark: 

### Initial Setup Overhead with Only 50 Total Reqs/Process

<table>
    <thead>
        <tr>
            <th></th><th>Messages-Only</th><th>Whole-Process</th>
        </tr>
    </thead>
    <tbody>
        <tr> <th>fork_test</th><td>0.012</td><td>0.123</td> </tr>
        <tr> <th>thread_test</th><td>0.051</td><td>0.159</td> </tr>
        <tr> <th>ractor_test</th><td>0.009</td><td>0.114</td> </tr>
        <tr> <th>pipeless_ractor_test</th><td>0.009</td><td>0.109</td> </tr>
    </tbody>
</table>

This is just the basic setup time. But if you wonder, "isn't there some fixed overhead before you're really timing anything?" &mdash; yes, yes there is. This table gives you an idea how much overhead.

What's "pipeless?" In these tests, threads are coordinating directly with a queue. But there's an added bounce through the "pipe" for Ractors to allow them to finish at different speeds &mdash; that's how [Koichi's example code](https://github.com/ruby/ruby/blob/master/doc/ractor.md#worker-pool) did it. But I thought, maybe it's faster without it?

I removed the pipe and it ***was*** faster. So: ["ractor_test" is similar to Koichi's design](https://github.com/noahgibbs/ractor_basic_benchmarks/blob/main/benchmarks/ractor_test.rb), while ["pipeless" doesn't use an extra coordinator Ractor](https://github.com/noahgibbs/ractor_basic_benchmarks/blob/main/benchmarks/pipeless_ractor_test.rb).

## Hypotheses and Results

We would expect Ractors, at best, to be faster than existing Ruby threads because they can use all the cores available. And they would be (at best) about the same speed as multiple processes, up until all memory on the machine is used. Multiprocess concurrency in Ruby does very well, as you've [probably seen on previous benchmarks](https://appfolio-engineering.squarespace.com/appfolio-engineering/2019/9/4/benchmark-results-threads-processes-and-fibers).

I originally benchmarked this on a Mac and everything else beat Ractors by a mile, plus they crashed a lot. Then I switched over to Linux and got much saner results, much more like I expected. I got literally ***one*** crash in all the Linux testing for this article rather than a literally 20% crash rate. Quick reminder: Don't use Mac yet.

(And the Ractor folks admit there are warts. Every time you run the Ractor benchmark you get a disclaimer: "warning: Ractor is experimental, and the behavior may change in future versions of Ruby! Also there are many implementation issues." I'm just agreeing with the disclaimer.)

I'm not trying to badmouth Ruby nor Ractors. This is a complicated performance-based feature in a not-yet-released Ruby version. And Mac often lags a bit, especially on performance. But to be clear, I do ***not*** feel like Ractors are fully ready yet. And I'm benchmarking them, which is usually a bad idea with a feature that's not yet stable. So: value these results by what you paid for them.

***Yeah, yeah, disclaimers, disclaimers. What are the numbers?***

Here are the numbers I got on 30 trials of 5 Ractors/batch and 20,000 messages/Ractor on a small Linux VM (Linode 4GB):

<table>
    <thead>
        <tr>
            <th></th><th>Messages-Only</th><th>Std. Dev</th><th>Whole-Process</th><th>Std Dev</th>
        </tr>
    </thead>
    <tbody>
        <tr> <th>fork_test</th><td>16.44</td><td>0.175</td><td>16.84</td><td>0.181</td> </tr>
        <tr> <th>thread_test</th><td>30.32</td><td>0.225</td><td>30.74</td><td>0.227</td> </tr>
        <tr> <th>ractor_test</th><td>29.86</td><td>0.625</td><td>30.31</td><td>0.624</td> </tr>
        <tr> <th>pipeless_ractor_test</th><td>24.48</td><td>0.278</td><td>24.98</td><td>0.277</td> </tr>
    </tbody>
</table>

So: Ractors can be a bit ticklish. The plain (with-pipe) Ractor test never really got faster than threads. But the pipeless Ractor test ***does*** come out faster than threads and slower than fork, roughly as you'd expect.

Still, even in this best case I measured: 16% faster than threads, but 33% slower than multiprocess. So: the dream of Ruby with full-speed native threads hasn't quite arrived yet.

## Does More Work Per Chunk Help?

I did a quick and dirty test with 10x as many numbers for each chunk of work for both threads and the pipeless Ractor test. After all, this is where Ractors should beat threads &mdash; lots of work that can be done on 4 CPUs for Ractors, but only one for threads. How did that do?

Worse, actually. For whatever reason that version took 24.5 seconds for Ractors, but 22.1 seconds for threads (this is with 5 workers and 2,000 messages/worker.) I know Ractors have some odd interactions with the Ruby VM &mdash; Ruby isn't designed for separate per-thread garbage collection, for instance, as the JVM is. But running more calculation per message doesn't seem to be a clear win for Ractors as you'd expect it to be.

Or maybe using exactly as many Ractors as CPUs? Nope, the quick-and-dirty test there came out at 9.3 seconds for Ractors vs 7.7 seconds for threads (2 workers, 2000 msgs/worker.)

These additional tests show that the good result above was a bit of an anomaly. Not every setup benefits from Ractors yet, not even the ones you'd reasonably expect to. Again, we'll see how that changes as we near Ruby 3's release date.

## So What's It All Mean?

Ractors are quite new. Ruby 3 isn't due to be released (as I write this) for another month. I'm sure there will be both performance and stability work on Ractors before their final release.

But initially, my recommendation would be that Ractors are finicky, but can give you performance more like native threads &mdash; like threads without the GVL. They're going to need some tuning, and I do ***not*** recommend them on Mac currently. But they look promising, and they seem to do what we've heard they will.

My ***best test case gave Ractors a 16% advantage on two cores over regular Ruby threads***. So right now, the overhead is still high. Ruby still likes multiprocess (fork) concurrency, and Ractors aren't going to change that overnight.

But Ractors do what they say they do, at least in prerelease Ruby. Keep in mind that they're only in Ruby 3. So you'll either need to use a prerelease Ruby, or wait until Christmas of 2020.

If you're enjoying this post about benchmarking, you can find a [lot of performance posts on FastRuby.io](https://www.fastruby.io/blog/tags/performance) - maybe read a few more?
