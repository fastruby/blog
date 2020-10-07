---
layout: post
title: "How's the Performance of Ruby 3.0.0-preview1?"
date: 2020-10-07 10:00:00
categories: ["rails", "performance", "ruby"]
author: "noahgibbs"
---

The [new Ruby 3.0 preview](https://www.ruby-lang.org/en/news/2020/09/25/ruby-3-0-0-preview1-released/) is out! Woo-hoo!

If you've heard of me, you know [performance is kinda my thing](https://engineering.appfolio.com/?author=5751bf4722482e6c3dbfc424), especially [Rails performance on large apps](https://github.com/noahgibbs/rails_ruby_bench). I do other stuff too, but I got paid to do that for years (thanks, AppFolio!), so I've written a lot about it.

How does the new preview's performance stack up on Rails? And how reliable are these numbers?

<!--more-->

## Pitfalls

First off, not every gem is ready for Ruby 3. For instance, the latest version of ruby_dep (1.5.0) has a "\~>2.2" dependency on Ruby. I'm not trying to pick on it! [Tilde-dependencies are usually a really good idea](https://guides.rubygems.org/patterns/#pessimistic-version-constraint)! And now a bunch of them are going to need to change.

I'm also using ancient code for this benchmark, frankly. I consider myself a pragmatist on this point, and I tried what a pragmatist would do. &lt;whispering&gt;I commented out the check for Ruby version in the local copy of Bundler 1.1.17&lt;/whispering&gt;. Um, I mean we're all respectable Rubyists here who never cut corners to get speed ratings of prerelease software.

It didn't work, though. It turns out there are **_several_** changes in Ruby 3.0 that are going to require gems to upgrade a bit. But if the main problem is just the version number&hellip;

I put together [a Ruby branch which started out exactly identical to the Git SHA for Ruby 3.0.0-preview1, plus a commit that rolled the reported version back to 2.8](https://github.com/noahgibbs/ruby/tree/fake_2_8). That's not as good an idea as updating all the gems to support 3.0, but it requires a lot fewer updates to ancient software that I can't do for myself. Though I still have to revert a few deprecations so that old code warns instead of crashing...

<img src="/blog/assets/images/ruby_30_deprec.png" alt="A Variety of Ruby 3.0.0 Deprecations-Turned-Errors I Reverted" />

And now, using version 3.0 with the serial numbers filed off, off we go!

Nearly. In fact, it looks like my (badly-patched) version has an incompatibility between (un-reverted) Ruby 3.0 changes and a monkeypatch claiming to be for ActionModel::Serializer 0.8/0.9 (!). So after removing a (very small) bit of functionality in favor of returning a static string, and turning down the number of load threads a bit to avoid an occasional segfault... **Now** off we go.

## Software for Testing

My existing test stack seemed like the way to go: I've built this very specifically to time Ruby 3.0 against Ruby 2.0, for many years. Now that Ruby 3 exists, I can finally use it for that! It's about time!

[Rails Ruby Bench](https://github.com/noahgibbs/rails_ruby_bench) runs a copy of [Discourse](https://github.com/discourse/discourse), a common and popular Rails app to host internet forums. It's one of the biggest available "real" open-source Rails apps, making it a fine choice for "real world" benchmarking. RRB runs a set of simulated pseudorandom user requests against the running Rails app, and times how long they all take to finish. So it's a throughput test. [You can run it yourself if you like](https://engineering.appfolio.com/appfolio-engineering/2019/11/28/how-do-i-use-rails-ruby-bench), though it's a bit complex and finicky. You may be gathering that from the "Pitfalls" section above. The dark side of using real-world software is hitting real-world complexity and bugs.

RRB has run against AWS m4.2xlarge instances for nearly its whole existence. That's what I'm doing again. For now: m4.2xlarge instances, 10 processes, 6 threads/process, the same as I've been [using for over 3 years](https://rubykaigi.org/2017/presentations/codefolio.html) for this purpose. Once Ruby 3 comes out, it'll be time to look at upgrading RRB. After that, it will have fulfilled its purpose: to measure the total speedup from 2.0 to 3.0 of a typical real-world Ruby on Rails application.

And I can finally stop supporting some hideous old hacks to make that possible.

These results are running minimum 30 batches per Ruby version of 10,000 requests each. That's enough to get pretty solid results, but not to detect tiny differences.

(Due to randomization and a restart after fixing a rare bug, we got 38 batches for Ruby 2.7 and 36 batches for Ruby 3.0.0-preview1.)

## Results

How are results? Not dramatic, I'm afraid.

<table style="text-align: right">
    <thead>
        <tr><td></td><th>Ruby 2.7</th><th>Ruby 3.0.0-preview1</th><th>Speedup/Slowdown</th></tr>
    </thead>
    <tbody>
        <tr>
            <th>Median Throughput</th><td>165.7</td><td>160.7</td><td style="color:red">-3.0%</td>
        </tr>
        <tr>
            <th>Fastest Run of 30</th><td>168.7</td><td>164.0</td><td style="color:red">-2.8%</td>
        </tr>
        <tr>
            <th>Slowest Run of 30</th><td>163.0</td><td>158.2</td><td style="color:red">-2.9%</td>
        </tr>
    </tbody>
</table>

(I also have [the raw data](http://codefol.io/links/ruby_3.0.0-preview1_rrb_results.json.gz), if that's of use to you. And technically there's an even more raw, larger set of results. [Hit me up on Twitter](https://twitter.com/codefolio) if you want them.)

To summarize simply: they're nearly the same speed, and a bit a pre-release Ruby polish and/or fixes to my testing will probably get them back to exactly equal.

## Other Issues...

Keep in mind that preview1 isn't final. I'm going to investigate this and see what I can see. My code branch is certainly not perfect. We're seeing **_ugly_** interactions between the now-ancient Discourse code I'm using and Ruby 3.0's deprecations. And I may find some improvements along the way.

Still, what I'm seeing suggests that these results aren't far off. A severe bug wouldn't cost a few percent of performance - it would kill it, or boost it to utterly unreasonable levels. That's not what we're seeing here. (I'm going to see if I can find where Rails and/or my hackery slows things down, of course.)

This is also a very limited test. I could check Ruby versions (again) much farther back, [though you can see the previous results of that](https://engineering.appfolio.com/appfolio-engineering/2019/3/7/ruby-speed-roundup-20-through-26), and they shouldn't change. [Ruby 2.6 and 2.7 are functionally the same speed to within 1%-2%](https://engineering.appfolio.com/appfolio-engineering/2019/12/27/ruby-270s-rails-ruby-bench-speed-is-unchanged-from-260). It looks like 2.7 and the 3.0 preview aren't showing a significant speed boost for Rails.

Is that shocking? It shouldn't be. I was, frankly, very surprised to see the 72%-ish speed boost from 2.0 to 2.6. Rails spends a lot of its time I/O-bound, waiting on databases, files and the network. The current Ruby JIT champions, JRuby and TruffleRuby can't easily squeeze more performance out of Rails than CRuby in most cases. The garbage collector, a source of slowdown back in Ruby 2.0 and 2.1, runs extremely solidly for these use cases.

I think this is about the speed that Rails is going to be, for Ruby 3.0 and for some time afterward.

With that said, I think a combination of polishing Ruby 3.0 for release and me making sure my test is in order will return the few percentage points of speed that (my tests claim) Ruby 3.0 has lost versus 2.6 and 2.7.

Hey, you read all the way to the bottom! I'm impressed. If you're still on a Rails performance kick and you want to stick with it a bit, you could check out [more performance articles on this site!](https://www.fastruby.io/blog/tags/performance)
