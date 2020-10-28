---
layout: post
title: "What's the Best EC2 Instance Type for Rails Apps?"
date: 2020-10-28 10:00:00
categories: ["rails", "performance", "ruby"]
author: "noahgibbs"
---

Do you ever [look at the list of Amazon EC2 instance types?](https://aws.amazon.com/ec2/instance-types). Those are sizes of virtual machine you can rent to run your code on. Well, okay, they're <i>groups of sizes</i>, since each one of those headings has a bunch of different sizes of VM...

So ***what type of EC2 instances should you run your Rails app on***?

The answer is simpler than it looks.

Do you love numbers? I love numbers. Do you hate numbers? Skip to the bottom, there's a nice summary paragraph. Do you ***really really*** love numbers? There are [raw data dumps](https://codefol.io/links/ec2_inst_types_full_data.tar.bz2) including all my intermediate results.

<!--more-->

## Instance Types and How I'm Testing

As you [may already know](https://www.fastruby.io/blog/rails/performance/ruby/hows-the-performance-of-ruby-3.0.0-preview1.html), I frequently run a "big Rails app, see how fast it can process many requests in parallel" benchmark called [Rails Ruby Bench](https://github.com/noahgibbs/rails_ruby_bench) (aka RRB.)

First I'll run through what EC2 types to consider. Then I'll speed test the best choices.

A Rails app is surprisingly [CPU-bound](https://yaoyao.codes/os/2017/03/20/cpu-bound-vs-io-bound). That's part of the reason we've seen a [72% speed increase from Ruby 2.0 to 2.6](https://engineering.appfolio.com/appfolio-engineering/2019/3/7/ruby-speed-roundup-20-through-26). That means that burstable-CPU instances such as t4 can sometimes show fantastic results on short benchmarks but worse results on longer-running benchmarks. If your app has extremely busy and extremely idle times this could be worth considering. But I can't provide reliable numbers for you for your app. It just depends how even the workload is. And the more even the workload is, the worse burstable instances are likely to do.

Discourse and Rails are memory-hungry enough that I did ***not*** benchmark the lower-RAM-per-CPU c5 instances. If you have a low-memory-usage app or you otherwise can reduce the memory usage enough, these could be great choices. With Discourse, and with most similar Rails apps, you'll wind up using up your memory too fast. I don't recommend them currently for a "standard" Rails app. But if you're doing something different in Ruby ([Sinatra](https://sinatrarb.com), [EventMachine](https://github.com/eventmachine/eventmachine), [Falcon/Async](https://github.com/socketry/falcon)) they could absolutely be worth a try. If Rails gets good support for [Ruby Ractors](https://github.com/ruby/ruby/blob/master/doc/ractor.md) with Ruby 3.0+ then c5 instances will also be worth a good look in Rails. For now they don't have the memory that most Rails apps need.

RRB runs an old version of [Discourse](https://github.com/discourse/discourse), a common and popular Rails app to host internet forums. It's one of the biggest available "real" open-source Rails apps, making it a fine choice for "real world" benchmarking. RRB runs a set of simulated pseudorandom user requests against the running Rails app, and times how long they all take to finish. So it's a throughput test. [You can run it yourself if you like](https://engineering.appfolio.com/appfolio-engineering/2019/11/28/how-do-i-use-rails-ruby-bench), though it's a bit complex and finicky. The dark side of using real-world software is hitting real-world complexity and bugs.

Because of the GIL, RRB runs with a balance of multiple processes and multiple threads-per-process. You can only run a single thread of Ruby code at once in a Ruby process, though multiple threads can be waiting on I/O or (usually) running code from a C-based native extension. Usually in Rails the balance comes to around 5 threads per process. I use [6 as a very minor improvement over 5 in RRB's specific case](https://rubykaigi.org/2017/presentations/codefolio.html). Ten Rails processes basically maxes out an EC2 2xlarge instances vCPUs and RAM for the amount of I/O waiting that Discourse is doing. So: ten processes, six threads/process.

RRB is running code that is quite old &mdash; I designed it to benchmark the Ruby 3x3 transition, so compatibility with old code is a priority. On Christmas Day of 2020 Ruby 3 will be released and I can look at upgrading to recent versions of everything. In the mean time I'll keep using these old versions... And not timing EC2's [m6g ARM instances](https://aws.amazon.com/ec2/instance-types/m6/). I can build old Ruby on them, but other old code like ancient NodeJS and libv8 was really hard to get running.

If you want to try m6g, you'll need to put some extra engineering time into it. You will likely have trouble getting and keeping it running since Intel processors are the default for everything. But if you have server bills large enough to make that a good idea, feel free to time it for yourself. My benchmark does ***not*** make that easy.

So: special-case Rails apps may be a good fit for t-series, c-series or m6g-series instances. I'm not recommending them in general for everybody, and I'm not speed-testing them since they're usually the wrong answer for your Rails app.

What does that leave? **Primarily it leaves m4 and m5 instances**. m4 is the older machine and architecture. They're similar in price.

## Spot vs On-Demand Instances

EC2 has [standard-price](https://aws.amazon.com/ec2/pricing/on-demand/) On-Demand Instances. You might or might not be able to get [Spot Instances](https://aws.amazon.com/ec2/spot/pricing/) at cheaper prices, randomly. Think of it as last-minute airline tickets. Sometimes you can get extra unused capacity cheap and sometimes you can't.

So it's useful to know ***how much*** faster the new infrastructure (m5) is and then you can bid on it proportionately at appropriate prices.

Amazon would like you to migrate off of m4. But there might be m4 spot instances available cheaply, depending on when you check. How does the price/performance compare? When would that be a good idea?

## Is it Simple?

I've spent years benchmarking primarily on m4.2xlarge. Using the same instance type makes it easy to compare the numbers over time. I'm checking two different Ruby versions on m4 versus m5 here. Speed is rarely a simple "x times faster" and testing more than one factor can help you tell how simple and stable your measurements are.

For my final measurement I've used four EC2 instances of each type, testing Ruby 2.5.3 versus 2.6.6. I also ran on a number of other instances first to get a feel for the variation in speed. One nice thing about running the same benchmark for over three years: I have a pretty good idea of its "normal" stability and variance! I'm also cheating a bit since I get to look at more numbers behind the scenes. You know what this post doesn't need five-to-a-hundred times as many of? Measurements.

RRB is also nicely-optimised for stable numbers. It performs the same requests generated using the same random seeds over and over. Its requests are reasonably small and quick. And it doesn't use the hardware network at all &mdash; its requests are all localhost. In a virtualised environment like EC2 that's an ***enormous*** source of instability that it simply skips. Of course, not every instance is the same speed. But the variation is a lot smaller than it otherwise would be.

EC2 also permits instances with "dedicated" placement where you can be sure nobody else is sharing the same physical hardware. I've used those and tested with them over the years. While they ***do*** avoid some hour-to-hour variance, there are still faster and slower dedicated instances in my experience. So they wouldn't provide a big advantage for this specific set of measurements.

## The Baseline: m4

So how does that all look on m4 instances?

<table style="text-align: right;">
    <thead>
        <tr>
            <th></th><th>Ruby 2.5 ips</th><th>Ruby 2.6 ips</th><th>Ruby 2.6 speed diff</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>m4 inst 1</th><td>168.9</td><td>175.3</td><td>+3.8%</td>
        </tr>
        <tr>
            <th>m4 inst 2</th><td>156.8</td><td>164.0</td><td>+4.6%</td>
        </tr>
        <tr>
            <th>m4 inst 3</th><td>169.2</td><td>176.8</td><td>+4.5%</td>
        </tr>
        <tr>
            <th>m4 inst 4</th><td>167.4</td><td>175.6</td><td>+4.9%</td>
        </tr>
        <tr>
            <th>m4 overall</th><td>167.4</td><td>175.3</td><td>+4.7%</td>
        </tr>
    </tbody>
</table>

(ips == median iterations/second on 30 runs of 10k HTTP reqs; "m4 overall" means treating all requests as a single long run)

That second instance looks significantly slower. The fastest instance (number 3) is around 7.8% faster. But you'll notice that it's not very random. For Ruby 2.6, that instance is around 7.8% faster. For Ruby 2.5, it's around 7.9% faster. And that's what "stability" looks like in this case. Some instances are a little faster, some are a little slower, but the relative numbers stay similar. Similarly, "Ruby 2.6 is between 3.8% and 4.9% faster than Ruby 2.5 for this task" shows some variation, but it's a pretty normal amount of variation for this benchmark.

I've been looking at these for years, and this is a typical set of results, barring significant statistically mistakes&hellip; which I've made now and then, of course. If you've followed my work on this topic you've presumably noticed the same thing over the years.

If you're saying, ***"wait, some individual instances are faster than others?"*** &mdash; the answer is yes. I know folks who start up big groups on-demand EC2 instances, run a benchmark, and then shut down the slowest 10% of them. It's much more pronounced for network than CPU. That's why I don't include non-localhost networking in my EC2-based metrics.

## Comparing with m5

This is all for m4 instances. How are the numbers for m5 instances? This is the useful part where we can compare cost-effectiveness.

<table style="text-align: right;">
    <thead>
        <tr>
            <th></th><th>Ruby 2.5 ips</th><th>Ruby 2.6 ips</th><th>Ruby 2.6 speed diff</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>m5 inst 1</th><td>206.5</td><td>213.3</td><td>+3.3%</td>
        </tr>
        <tr>
            <th>m5 inst 2</th><td>200.7</td><td>204.7</td><td>+2.0%</td>
        </tr>
        <tr>
            <th>m5 inst 3</th><td>203.7</td><td>213.8</td><td>+5.0%</td>
        </tr>
        <tr>
            <th>m5 inst 4</th><td>214.1</td><td>223.5</td><td>+4.4%</td>
        </tr>
        <tr>
            <th>m5 overall</th><td>206.1</td><td>214.4</td><td>+4.0%</td>
        </tr>
    </tbody>
</table>

(ips == median iterations/second on 30 runs of 10k HTTP reqs; "m5 overall" means treating all requests as a single long run)

These instances are a little closer &mdash; the fastest is about 6.7% faster than the slowest. There's still some variation in the "Ruby 2.5 versus Ruby 2.6" numbers, but the overall is similar - 4.0% on the m5 instances, 4.7% on the m4 instances. This is all normal variation, in other words.

What's with that +2.0% on instance 2? Sometimes one run or another has a bad day, and Ruby 2.5 and 2.6 happened to come out pretty similar on that instance. Looking behind the scenes, it wasn't a huge outlier or sudden slowdown -- that instance's runs had unusually ***low*** variance, not unusually high. It looks like a special case of "slow EC2 instance" of some kind that reduced Ruby 2.6's advantage over Ruby 2.5, perhaps with (very) slightly longer I/O waits or (very) slightly longer CPU times. In other words, whatever it was, it looks like a minor long-term slowdown on the individual EC2 instance, not a temporary hiccup where things slowed down for a few minutes.

## Cost Effectiveness

Okay. An m4 instance gets a median throughput of 175.3 requests/second on Ruby 2.6, which is about the same speed as current Ruby. An m5 instance gets a median throughput of 214.4 with the same configuration. What does it all mean?

For starters, that means m5 instances are about 36% faster. ***If you're pricing spot instances, m4 instances would need to be 36% cheaper than m5 instances to be worth bothering with***.

What do they usually cost?

Here's the kicker: on-demand ***m5 instances actually cost less per hour*** than m4 instances. So if you're going to pay full on-demand price, there is simply no comparison: ***go for m5***. If you haven't upgraded from m4 instances already, that time has come. On-demand m4.2xlarge instances in us-east-1 go for 40 US cents/hour, while m5.2xlarge go for 38.4 US cents/hour (m4 is 4.1% more expensive.)

So m5 isn't a large discount until you figure in how much faster it is. And then it really, really is.

Also, as the linked article and these numbers imply: if you're optimising smallish differences, upgrade to a recent Ruby, at least 2.6 or higher. There's a noticeable improvement over 2.5, and [quite a large difference over earlier Rubies](https://engineering.appfolio.com/appfolio-engineering/2019/3/7/ruby-speed-roundup-20-through-26). We'll see how Ruby 3.0 does, [though months-before-release numbers aren't very different from 2.7](https://www.fastruby.io/blog/rails/performance/ruby/hows-the-performance-of-ruby-3.0.0-preview1.html).

## Conclusions

If you're just here for the conclusion: use the m5 series of EC2 instances. I like m5.2xlarge for number of vCPUs and amount of RAM. But you can scale up or down with your needs and get the same ratio of vCPUs to RAM. There are unusual special cases where you might consider m6g (ARM processors, difficult porting, fast CPUs), c5 (less RAM per CPU) or t4 (CPU-burstable).

But for normal Rails app use cases, m5 is your friend. If you're thinking, "but cheap m4 spot instances," keep in mind that they should be at least 36% cheaper than m5 ***just to break even*** on price-for-performance. Use them carefully if you use them.

## I Don't Believe You

Not convinced? That's fair. Hey, did you know [all my code is public?](https://github.com/noahgibbs/rails_ruby_bench). You can [read the docs to run it yourself](https://engineering.appfolio.com/appfolio-engineering/2019/11/28/how-do-i-use-rails-ruby-bench) and/or [give me a holler](https://twitter.com/codefolio) if you'd like to re-run for yourself, maybe with more instances, and see how well my results replicate for you. I'd happily show you exactly how I did this and all the code is already online. [So is my data](https://codefol.io/links/ec2_inst_types_full_data.tar.bz2), which is cheaper than renting your own EC2 instances.

## By the Way...

Looking for more on performance? The [FastRuby blog has a tag for that](https://www.fastruby.io/blog/tags/performance)...
