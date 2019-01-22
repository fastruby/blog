---
layout: post
title:  "Refactoring with Design Patterns - The Template Pattern"
date: 2018-09-17 16:18:00
categories: ["code-refactor", "design-patterns"]
author: "cleiviane"
---

In our last article of the [refactoring series](https://www.ombulabs.com/blog/tags/code-refactor) we saw how design patterns can be used to make our Ruby code beautiful and clean. Design patterns are a powerful tool for any developer and a familiarity with them will lead to better code by forcing a consideration of SOLID principles.

Now let's talk about other pattern that when properly used can be very helpful: *The Template Method*.

<!--more-->

## The Template Method

The Template Method is described as <strong>_"a behavioral design pattern that lets you define the skeleton of an algorithm and allow subclasses to redefine certain steps of the algorithm without changing its structure."_</strong>

The goal is to separate code that changes from code that doesn't change, keeping the concerns isolated on specialized classes. Those subclasses will then implement all the specific steps.

Check the image below that is illustrating the Template method structure:

<div style="text-align: center; font-size: 12px; margin-bottom: 20px;">
  <img src="/blog/assets/images/design-patterns/template-method.png">
  <center><em>credits: Refactoring Guru (https://refactoring.guru)</em></center>
</div>

## Show me The Code

Lets say that we are still building the employees application from our [last article](https://www.ombulabs.com/blog/code-refactor/refactoring-with-design-patterns.html) and now we need to send an email to the managers with a report containing the amount of hours worked for each employee.

The implementation of the `Report` class is quite simple:

```ruby
class Report
  def generate_report!
    get_employees_worked_time
    format_report
    send_to_stakeholders
  end

  def get_employees_worked_time
    # Retrieve this info from the database
  end

  def format_report
    # Generate the HTML with the Report design
  end

  def send_to_stakeholders
    # Call send email service
  end
end
```

That code works perfectly fine. But what if now we also need to generate the same report in text format? The only part that will vary is exactly the format report step, so that is a scenario when applying the *Template Method* is a good choice.

To apply this pattern we will transform the `Report` class into an abstract class that can be inherited from several concrete classes.

Back to our code, the only change necessary is to leave the implementation of the format_report method for the children class:

```ruby
class ReportTemplate
  def generate_report!
    get_employees_worked_time
    format_report
    send_to_stakeholders
  end

  def get_employees_worked_time
    # Retrieve this info from the database
  end

  def format_report
    raise NotImplementedError
  end

  def send_to_stakeholders
    # Call send email routine
  end
end
```

And for each variation of an report we need to create a concrete subclass:

```ruby
class HTMLReport < ReportTemplate
  def format_report
    # implement the report in HTML format
  end
end
```

```ruby
class TextReport < ReportTemplate
  def format_report
    # implement the report in Text format
  end
end
```

Looks good, right? If we ever need to create a new format, we just need to create a new concrete class, making this a perfect example of the [Open/Closed Principle](https://www.oodesign.com/open-close-principle.html). And by designing our code this way it will be easier and safer to change anything in the future.

## Conclusion
The Template method is a powerful tool that every developer needs to have on hand. If you need to vary just a few methods or make them optional this pattern is a perfect solution. The template class should implement the skeleton, while the subclasses should implement the details in the way that it needs.

I hope that this was useful for you. We will keep talking about principles and patterns here in our blog, so stay tuned!
