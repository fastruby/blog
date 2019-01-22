---
layout: post
title: "Refactoring: Clean your ruby code with design patterns"
date: 2018-06-28 12:00:00
categories: ["code-refactor"]
author: "cleiviane"
---

Code refactoring can be defined as <strong>_“the process of introducing small and incremental changes to leave the code in a better state than it was.”_</strong>. When refactoring your code you have to consider two things: no new functionality should be added and the external behavior should not be affected.

One of the biggest challenges as a Ruby on Rails Developer is to keep your code clean, simple and easy to maintain and that is why we are always refactoring our code.

There are several techniques that a developer can follow to improve their code by code refactoring, such as extract method, move method, move field, switch statements, etc. If you are not familiarized with them, please visit the [Refactoring Guru site](https://refactoring.guru/).

Another technique developers try to follow is to apply good design patterns to their code. In this post we'll try to go over some of the documented design patterns and how you can apply them to your Ruby code.

<!--more-->

<h2 id="design-patterns">Design Patterns</h2>

A design pattern can be described as <strong>_“typical solutions to commonly occurring problems in software design. They are blueprints, that can be taken and customized to solve a particular design problem in your code”_</strong>. So design patterns are not rules but guides that can help you to find the best solution given a particular situation. That is why, as pragmatic developers, we have always a good design pattern on the hand.

Explaining each pattern in detail is out of this article’s scope, so if you are not familiar with the presented design patterns, a good reference is the book [Design Patterns: Elements of Reusable Object-Oriented
Software](https://www.amazon.com/Design-Patterns-Object-Oriented-Addison-Wesley-Professional-ebook/dp/B000SEIBB8), written by the famous Gang of Four (GoF).

Since there are 23 design patterns cataloged in the book, our intention here is to cover the most used of them and how they can be useful to clean our Ruby code.

<h2 id="factory-method">Factory Method</h2>

When we think about a factory, what comes to mind is a place that builds different products that share common characteristics: cars, electronics, toys, medicines, cakes and several others. You expect that all car factories will build cars and these cars will have different colors, sizes, shapes, etc, right?

Now, let’s say that we have to build an application and one of the functionalities is to create employees. The employees can be one of three different types: full-time, part-time and contractor and each type of employee will have a different hourly rate. So the requirement is to send a hash with the employee information and based on the type, we need to create the correct employee object.

Let’s create the `Employee` class:

```ruby
#lib/factory/employee.rb
class Employee
  def self.create(params)
    employee = Employee.new

    type = params[:type]

    case type
    when "fulltime"
      employee.type = :full_time
      employee.hourly_rate = 60.00
    when "parttime"
      employee.type = :part_time
      employee.hourly_rate = 50.00
    when "contractor"
      employee.type = :contractor
      employee.hourly_rate = 20.00
    end

    employee
  end
end
```

This code works. It creates an employee and fills its information based on the given type. But the code is not beautiful and imagine the trouble if we need to change an existing employee type or even add a new one.

To improve this code we could apply a refactor to extract the business logic of create employees to another class, then the Employee class will have only the responsibility to call the correct employee constructor. The process of extracting the creation business logic to specific classes and methods is the goal of the Factory Method.

The basic principle of this pattern is to have factories creating products, a metaphor to a real factory. With the Factory Method we will change our code to:

```ruby
# lib/factory/employee.rb
class Employee
  def self.create(params)
    EmployeeFactory.create_employee(params)
  end
end

# lib/factory/employee_factory.rb
class EmployeeFactory
  def self.create_employee(params)
    case params[:type]
    when "fulltime"
      FullTimeEmployee.new
    when "parttime"
      PartTimeEmployee.new
    when "contractor"
      FullTimeEmployee.new
  end
end
```

This way the `EmployeeFactory` doesn’t need to know how to create each type of employee, they are all created the same way. The logic to create employees is defined on the `EmployeeFactory` class, that will call specialized constructors for each employee type. The responsibility of these constructors is to know only its own necessary information, like the hourly_rate, for example. That way if we ever need to add a new employee type it will be much easier.

<h2 id="strategy">Strategy</h2>

Now let's say that our next functionality is to calculate the net salary of the employees. The net salary is the salary that they will receive once all the taxes are applied.

Since different countries have different taxes rules our code needs to handle this when perform the calculation.

Let's implement the `EmployeeSalary` class:

```ruby
# lib/strategy_sample/employee_salary.rb
class EmployeeSalary
  ARG_TAX = 0.5
  USA_TAX = 1.3
  BRA_TAX = 0.8

  def self.calculate_net_salary(country, amount)
    country_taxes = case country
      when "Argentina"
        (amount * ARG_TAX)
        # Argentina tax calculation
      when "USA"
        (amount * USA_TAX) + 200
        # USA tax calculation
      when "Brazil"
        (amount + 500) / BRA_TAX
        # Brazil tax calculation

    amount - taxes
  end
end
```

We can easily see that the `calculate_net_salary` will massively grow each time that we need to add a new country. This situation breaks the [open/closed principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle) that says: _"software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification"_. This means that to make a class do new things you shouldn’t need to change the class itself.

If we can not extend the `calculate_net_salary` method to make a new country calculation without a lot of modification we are not following this principle. To solve this situation we can apply the Strategy Pattern to refactor our code.

The <strong>Strategy</strong> is a behavioral design pattern that suggests to take a class that does something important in a lot of different ways and extract all these algorithms into separate classes called strategies. The original class, called _context_, will receive a field that references to one of the strategies.

With that concept in mind we can refactor the context class:

```ruby
# lib/strategy_sample/employee_salary.rb
class EmployeeSalary

  def initialize(strategy)
    @strategy = strategy
  end

  def initialize
    @strategies = {
      'USA': UsaTaxes,
      'ARG': ArgentinaTaxes,
      'BRA': BrazilTaxes
    }
  end

  def self.calculate_net_salary(amount, country)
    strategy = @strategies[country]

    strategy ? amount - strategy.taxes(amount) : amount
  end
end
```

Then we will create one strategy for each one of the necessary country calculations.

```ruby
# lib/strategy_sample/strategies/usa_taxes.rb
class UsaTaxes
  def self.taxes(amount)
    # USA tax calculation here
  end
end
```

```ruby
# lib/strategy_sample/strategies/argentina_taxes.rb
class ArgentinaTaxes
  def self.taxes(amount)
    # Argentina tax calculation here
  end
end
```

```ruby
# lib/strategy_sample/strategies/argentina_taxes.rb
class BrazilTaxes
  def self.taxes(amount)
    # Argentina tax calculation here
  end
end
```

That way the single responsibility of the `EmployeeSalary` class is to delegate the calculation work to a linked strategy instead of executing it on its own.

Wherever we need to get the net salary we should call the `EmployeeSalary` class like this:

```ruby
Taxes.new.net_salary(1000, "BRA")
```

Now if we need to add a new country we just need to create a new strategy and add to the context class. With this refactor we can keep all the concerns separated and the code is cleaner and easier to maintain.

<h2 id="next-steps">Next steps</h2>
In this post we talked about two very useful design patterns and how we can use them to improve code quality. We hope this was helpful for you. Keep following our blog, we will talk more about this subject soon.
