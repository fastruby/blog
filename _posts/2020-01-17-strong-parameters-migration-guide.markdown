---
layout: post
title: "The Complete Guide to Migrate to Strong Parameters"
date: 2020-01-21 13:00:00
reviewed: 2020-03-05 10:00:00
categories: ["rails", "upgrades"]
author: luciano
published: false
---

Migrating from `Protected Attributes` to `Strong Parameters` in a [Rails](https://rubyonrails.org/) project can be a huge step of the upgrade process. Especially when we are [upgrading a large application](https://www.fastruby.io/blog/rails/upgrades/case-study/upgrading-a-large-rails-application-from-4.2-to-5.2.html). This guide is meant to help you tackle that step faster and with a lot less pain.

<!--more-->

### Protected Attributes & Strong Parameters

To give you a bit of context, let's recap what `Protected Attributes` and [Strong Parameters](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters) actually are. They are two different Rails implementations for protecting attributes from end-user injection (a.k.a. [Mass Assignment](https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html))

To understand what the benefits are of `Strong Parameters` over `Protected Attributes`, I recommend checking [this RailsCasts episode](http://railscasts.com/episodes/371-strong-parameters?autoplay=true).

`Protected Attributes` was part of the Rails core since the beginning of it until Rails 3.2. In Rails 4.0 they introduced `Strong Parameters` as a replacement of it, and it has been part of the core since then. Before that it was possible to use it through the [strong_parameters](https://github.com/rails/strong_parameters) gem.

After Rails 4.0 came out with the implementation of `Strong Parameters`, we were able to have backwards compatibility with `Protected Attributes` by using the [protected_attributes](https://github.com/rails/protected_attributes) gem. That way you could have the latest version of Rails without migrating to `Strong Parameters`.

That gem was supported by the Rails team until the release of Rails 5.0. After that we were forced to migrate to `Strong Parameters`. Once that happened we started to get unofficial forks of `protected_attributes` that support the latest version of Rails, like [`protected_attributes_continued`](https://github.com/westonganger/protected_attributes_continued).

At this point we strongly recommend fully migrating to `Strong Parameters`, since the available options to keep `Protected Attributes` alive have very limited support and can encounter security issues.

### Migration

The migration consists of moving the Mass Assignment restrictions from the models to the controllers. That means removing the `attr_accessible` and `attr_protected` calls from your models and adding a new method to your models' controllers to handle the parameters.

In a simple example, this is how a model and controller look using `Protected Attributes`:

```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email

  # ...
end
```

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def create
    User.create(params[:user])
  end

  # ...
end
```

This is how it should look after migrating to `Strong Parameters`:

```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  # ...
end
```

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def create
    User.create(user_params)
  end

  # ...

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
end
```

Sometimes you'll find that the logic is more complex than that; but most of the time moving the parameters is straightforward. The main issue is that it takes a lot of time when you have a large number of models. That's why we created [rails_upgrader](https://github.com/fastruby/rails_upgrader). This gem will help you speed up the migration process by automating some of it.

Once you install the gem in your project you can run any of these commands in the console:

- `rails_upgrader go` (attempt to upgrade your models and controllers in place)
- `rails_upgrader dry-run` (write strong parameter migrations in the terminal)
- `rails_upgrader dry-run --file` (write strong parameter migrations to `all_strong_params.rb` file)

Another useful gem is [moderate_parameters](https://github.com/hintmedia/moderate_parameters). This gem can be handy to determine what data is originating from within the app and what is coming from the internet. I recommend taking a look at it as well.

### Conclusion

Migrating to `Strong Parameters` can be a tedious process but with the tools and resources that we presented here, it can be a lot easier.

If you need some more guidance on upgrading your Rails application check out our free eBook: [The Complete Guide to Upgrade Rails](https://www.fastruby.io/)
