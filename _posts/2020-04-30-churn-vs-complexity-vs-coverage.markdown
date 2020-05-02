---
layout: post
title: "Churn vs. Complexity vs. Code Coverage"
date: 2020-04-30 2:25:00
categories: ["code-quality"]
author: etagwerker
---

Churn vs. Complexity analysis is a great way to find insights about the maintainability of a project. Two of my favorite authors have written great articles written about the Churn vs. Complexity graph:

- [Getting Empirical about Refactoring](https://www.agileconnection.com/article/getting-empirical-about-refactoring) by Michael Feathers
- [Breaking up the Beheamoth](https://www.sandimetz.com/blog/2017/9/13/breaking-up-the-behemoth) by Sandi Metz

This two-dimensional graph can be very useful in finding the files that are the hardest to maintain in your application. 

Churn by itself is a useful metric. It will tell you which files are the ones that are constantly changing. Change takes time, so they are costing you and your team money. It will make you wonder: why are these files changing so much? Are requirements constantly changing? Are we truly understanding business rules? 

As you go about making your changes, you will introduce complexity. There is no way around it. The best way to have no complexity is to have no code. It doesn’t matter whether you are a rockstar object-oriented architect or a novice programmer. You will introduce complexity into a project.

“Complexity” should not be considered a negative term. “Extreme complexity” might be considered an anti-pattern. Good object-oriented programming calls for loose coupling and high cohesion. You want modules that follow [SOLID](http://link to-solid.com) rules (TODO: check. Source: <TODO: insert reference here>). When you feel like your modules are becoming extremely complex, your will want to refactor them into collaborating modules (modules that send and receive messages between each other) which will be increase coupling and reduce? cohesion.

As you go about submitting pull request to ship new features; change existing features; or patch bugs; the maintainability of your project will vary according to the modules you introduce or change. The bigger the project, the harder it will be to maintain it, because there will be more moving pieces, collaborating modules, and potential points of failure.

If you refactor a huge module, into two smaller modules, you will notice that the cognitive complexity (TODO: check if this is the right word) will vary accordingly. You won’t have one huge, complex module anymore, you will have two modules that are easier to understand (hopefully!)

Modules that have one and only one responsibility will be easier to maintain and test. Future changes will be easier because you will be able to quickly understand what the module is doing.

But the truth is that when we start maintaining a module, we don’t just look at its churn and complexity. We mostly look at the complexity of the module and the tests that describe the expected behavior.

So, a module that has basic code coverage will be easier to understand than one without tests. Because it will be “documented” by the tests which will describe what the past programmer expected from that module’s public interface.

> Code coverage metrics don’t tell whether the test suite is good or bad. It tells you how many statements of your application are exercised by your test suite. You should not blindly trust code coverage percentages without doing a quick code review of the tests that are present.

I believe the churn vs. complexity graph could be enhanced by adding a new dimension: Code coverage. When I look at all the modules in the project, I want to know: 

- How many times has this file changed since the beginning of the project? (Churn)
- How complex is this module? (Complexity)
- What’s the code coverage associated with this module? (Code Coverage)

This new dimension will tell us which files are the most changed, the most complicated, and the least covered with tests.

When you inherit a legacy project, you will be asked to do a lot of things: 

- Add features
- Change features
- Fix bugs

The best clients will also ask you to: 

- Pay off tech debt 
- Upgrade dependencies 
- Reduce complexity
- Increase code coverage 

> Of course you don’t want to pay off all of the tech debt in the project. There is some tech debt in the project that is okay: Think about modules that are in the high complexity + low churn quadrant and the low complexity + high churn quadrant. Some people might look at those modules, see tech debt, and assume that they *need to fix it* (that’s a bad idea!)

Even if your client doesn’t ask for these things, you should try to bake in these contributions as you go about your main priorities. 

By adding a third dimension to the churn vs complexity graph, you will be able to gather new insights about your modules. 

Let’s analyze the modules that are in the high complexity + high churn quadrant. You will have a strong urge to refactor these modules. You don’t want to do that without knowing the state of the tests associated with said modules.

> Refactoring modules that lack proper tests can quickly turn into a nightmare. You don’t want your refactoring efforts to blow up in your face when changes hit production. And you probably don’t want to test all your changes manually.

So, there are couple of things you can do to pay off tech debt for modules in this quadrant: 

- Write tests to make sure that modules do what they’re supposed to do. You want to do this for modules that have poor code coverage (< 50%)
- Refactor modules to make them easier to understand and maintain. You want to do this for modules that have decent code coverage (> 80%) 

I believe the churn vs. complexity vs. code coverage graph will show you a better picture of what you can do next: 

[TODO: Insert picture of modified churn vs complexity vs code coverage)

## Nice to have

Maybe: A progression of the CvCvCC graph for a big library? 



 

