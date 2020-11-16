---
layout: post
title: "Gemifying your style guide to DRY your CSS"
date: 2020-02-05 10:30:00
reviewed: 2020-06-09 16:00:00
categories: ["gems", "dry", "ruby"]
author: "cleiviane"
---

At OmbuLabs we like to follow a style guide to drive our own products. A style guide is a document that provides guidelines for the way your brand should be presented from both a graphic and language perspective. You can see FastRuby.io's style guide at [this link](https://fastruby.github.io/styleguide).

Since we have a few applications in place and it's important to make sure that they all use the same style, we need to ensure that they will all inherit the same CSS files. One way to do this is to copy the above style guide and paste it inside all of our apps, but this would end up causing a lot of duplicated code. If we decided to change the font-style, for example, we would need to change it in all apps individually.

Something else we are super fans of at OmbuLabs is to follow good code and development practices. One of our favorites is the [DRY (Don’t Repeat Yourself)](https://wiki.c2.com/?DontRepeatYourself) principle, which states that duplication in logic should be eliminated via abstraction. So to avoid the duplicated code here, we decided to create a gem to encapsulate our style guide and to be bundled in all of our products.

In this article, I'll show you how we did it!

<!--more-->

## Creating the Gem

The first step is to create the gem. Bundler has a command to create the skeleton of the Gem.

`bundle gem fastruby-styleguide`

Go to the created `.gemspec` file and add the info about the new gem and also a few dependencies:

```ruby
# fastruby-styleguide.gemspec
require_relative 'fastruby/styleguide/version'

Gem::Specification.new do |spec|
  spec.name           = 'fastruby-styleguide'
  spec.version        = Styleguide.gem_version
  spec.authors        = ['OmbuLabs']
  spec.email          = ['hello@ombulabs.com']

  spec.summary        = 'Style Guide for all FastRuby.io products'
  spec.homepage       = 'https://github.com/fastruby/styleguide'

  # Rails
  spec.add_dependency 'rails', '>= 5.2.1'
  spec.add_dependency 'sass-rails', '>= 5.0'
  # Jquery
  spec.add_dependency 'jquery-rails', '>= 4.3.0'
  # Bootstrap
  spec.add_dependency 'bootstrap-sass', '>= 3.4.0'
  # Popper
  spec.add_dependency 'popper_js', '>= 1.14.5'
  spec.add_dependency 'material_design_lite-sass', '>= 1.3.0'
end
```

By default the gem is created as a module but we need to turn it into an engine, because we need to be able to integrate the gem code into any Rails application. In case you want to understand more about the Rails engine, check [this link](https://guides.rubyonrails.org/engines.html).

So, let's change the `lib/fastruby-styleguide.rb`

```ruby
module Fastruby
  module Styleguide
    class Engine < ::Rails::Engine
    end
  end
end
```

Now we need to copy all the assets for the `vendor/assets` folder. The project structure will be like this:

<img src="/blog/assets/images/gemifying-your-styleguide-img-01.png" alt="Folder structure" style="width: 300px; margin: 0;">

Go back to the .gemspec file and make sure that the new files will be loaded adding the following line:

```ruby
spec.files = Dir['vendor/**/*']
```

And this is it! The gem is ready to be used.

## Adding the gem to a project

To use our new created gem we need to bundle it like any other gem. So add this line to your application's Gemfile:

```ruby
gem 'fastruby-styleguide'
```

And then execute:

`$ bundle install`

The next step is to require the new gem assets into the application:

If using SASS, in `application.scss`, add:

```sass
@import "fastruby/styleguide";
```

And in `application.js` add:

```javascript
//= require fastruby/styleguide
```

Now start the application and the gem assets should be available to use.

You can see our style guide code in this GitHub repository: [https://github.com/fastruby/styleguide](https://github.com/fastruby/styleguide).

## Conclusion

As developers, we are always thinking about the best way to organize our code and follow good practices, so here is our solution to share the same assets code amongst our several products. If you're facing the same issue, I hope that this is useful.

## Extra

Want to see our style guide applied? We're proud to present our projects: [Fastruby.io](https://www.fastruby.io) and [Audit Tool](https://audit.fastruby.io).
