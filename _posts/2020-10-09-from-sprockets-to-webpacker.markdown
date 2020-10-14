---
layout: post
title: "From Sprockets to Webpacker"
date: 2020-10-09 11:00:00
reviewed: 2020-10-09 11:00:00
categories: ["rails", "webpack"]
author: "arielj"
---

Back in 2011, [Rails 3.1 introduced The Assets Pipeline](https://guides.rubyonrails.org/3_1_release_notes.html#assets-pipeline) feature using the [Sprockets gem](https://github.com/rails/sprockets). This made it really easy to handle assets (images, fonts, JavaScript, CSS and more), solving many of the issues that developers had to face everyday.

In 2012, [Webpack](https://webpack.js.org) was released solving the same issues in a different way and in time became the most used solution to handle assets. And since Rails 6, Webpack became the default solution to handle JavaScript assets using the [Webpacker gem](https://github.com/rails/webpacker) on new Rails applications.

In this article I'll explain the steps we took to migrate to Webpack to handle our JavaScript assets, and how we added support as a node module in [our styleguide](https://github.com/fastruby/styleguide).

<!--more-->

## Main Differences

There are a few key differences on how Sprockets and Webpack works:
- Sprockets adds the content of required files into a one big file with all the code running globally and sequentially, Webpack creates a bundle that isolates each module following ES6 modules specs.
- Sprockets uses `app/assets`, `vendor/assets` (also from gems) and `node_modules` folders to look for assets, while Webpacker uses the `app/javascript` and the `node_modules` folder.
- Since the `// require ...` syntax is specific for Sprockets, it's not recognized by linters, while the `import` syntax of Webpack is the ES6 syntax so more tools understand that.

## The Plan

### FastRuby.io Styleguide

We use our styleguide for the base style of our projects, but it works either as a Ruby gem or as static files. In order to use it with Webpack, we need to add support to be used as a node module (we'll use [Yarn](https://yarnpkg.com) since it's the default node modules manager for Rails applications -like bundler for gems management-).

### Webpack Only for JavaScript

While it is possible to use Webpack for all kind of assets (images, styles, fonts, etc). We are only going to use it for JavaScript since it's the current Rails standard. This may change in the future if Webpack gets better and faster for those types [according to DHH](https://discuss.rubyonrails.org/t/sprockets-abandonment/74371/41).

### 3rd Party Assets in Gems

Some assets are added by gems, but, similar to the styleguide, it's easier to integrate them with Webpack if we use an equivalent Yarn package. For example, the `rails-ujs` JavaScript module is provided by the `rails` gem, but it's easier to integrate it with Webpack using the `@rails/ujs` [package](https://yarnpkg.com/package/@rails/ujs) instead.

### Reorganization and Reconfiguration

The Webpacker gem expects files in different locations than Sprockets, and the configuration is different with different concepts and options.

## The Styleguide

For this project to support being used as a node module, we need to add some config files, configure them properly and add entry points.

### Init a Yarn Package

Inside the Styleguide's project folder, we run the command `yarn init`. This starts a wizard to setup the metadata of the project (name, git repository, author, license, and many more). At the end, creates a `package.json` file where we can configure this projects.

```json
{
  "name": "fastruby-io-styleguide",
  "version": "1.0.0",
  "description": "Styleguide used in FastRuby.io",
  "main": "index.js",
  "repository": "git@github.com:fastruby/styleguide.git",
  "author": "Ariel Juodziukynas <arieljuod@gmail.com>",
  "license": "MIT",
  "private": false
}
```

### Adding Dependencies

As a gem, it uses a gemspec file to require other gems:

```ruby
  ...
  spec.add_dependency 'jquery-rails', '>= 4.3.0'
  spec.add_dependency 'bootstrap-sass', '>= 3.4.0'
  spec.add_dependency 'material_design_lite-sass', '>= 1.3.0'
  ...
```

When using this project as a node module, we need the same dependencies but as packages. We can use [yarnpkg.com](https://yarnpkg.com) to find the packages we need. After some research comparing the versions provided by those gems, we added the config to the `dependencies` property:

```json
{
  "name": "fastruby-io-styleguide",
  "version": "1.0.0",
  "description": "Styleguide used in FastRuby.io",
  "main": "index.js",
  "repository": "git@github.com:fastruby/styleguide.git",
  "author": "Ariel Juodziukynas <arieljuod@gmail.com>",
  "license": "MIT",
  "private": false,
  "dependencies": {
    "jquery": "^3.5.1",
    "bootstrap-sass": "^3.4.1",
    "material-design-lite": "^1.3.0"
  }
}
```

### JavaScript Entry Point

We can tell webpack which file will be the entry point of the package, so, when we use `import "fastruby-io-styleguide"` in our project, it knows which files to import. The default entry point is the file specified as the `main` property (`index.js`). We can change this if we want to, in our case we are going to use it as is.

Since we are using `jquery`, `bootstrap` and `material-design`, we need to replicate the same integration but with the modules syntax.

This is the original (`vendor/assets/javascript/fastruby/styleguide.js`) using sprockets required statements:

```js
//= require jquery
//= require popper
//= require bootstrap
//= require material
//= require custom
```

This is our new `index.js` file using `import`:
```js
require("jquery")
import "bootstrap-sass"
import "material-design-lite"
import "./vendor/assets/javascript/fastruby/custom.js"
```

You can see some names changes because gems and packages are not providing the same names.

### CSS Entry Point

Sprockets can find assets inside the node modules folder, so we are going to provide the SASS entry point.

We first have to tell webpack what's the entry point of the SASS style:

```js
{
  ...
  "main": "index.js",
  "style": "index.scss",
  "scss": "index.scss",
  ...
}
```

We were already using SASS imports to add the files provided by the gems. This is the original file (`vendor/assets/stylesheets/fastruby/styleguide.scss`):

```js
@import "material/variables";
@import "material/mixins";
@import "material/resets";
@import "material/typography";
@import "material/textfield";
@import "material/slider";

@import "bootstrap";

@import "styleguide-core";
```

And this is the new `index.scss` file:

```js
@import "material-design-lite/src/variables";
@import "material-design-lite/src/mixins";
@import "material-design-lite/src/resets/resets";
@import "material-design-lite/src/typography/typography";
@import "material-design-lite/src/textfield/textfield";
@import "material-design-lite/src/slider/slider";

@import "bootstrap-sass/assets/stylesheets/bootstrap";

@import "vendor/assets/stylesheets/fastruby/styleguide-core.scss";
```

This is really similar, we just replaced the new packages' names and locations for each file we need.

> For more details of the Styleguide changes, you can check [this Pull Request](https://github.com/fastruby/styleguide/pull/23)

## Installing Webpacker for FastRuby.io

The first step is easy, we have to follow the [official guide](https://github.com/rails/webpacker#installation). We don't need any special config since we are not using JS frameworks like React or Node, so the default install and config works.

1 - Added the gem to the Gemfile `gem 'webpacker', '~> 5.x'`
2 - Run `bundle` to install webpacker and its dependencies
3 - Run `bundle exec rails webpacker:install` to initialize the configuration files

After that, we'll see a new folder `app/javascript` where we'll move all our JavaScript files and a file `app/javascript/packs/application.js` which is the entry point for our code (it's similar to the `app/assets/javascript/application.js` file).

There are a few more new files that we'll use to add more configuration later.

## Linking the JavaScript

`sprocket-rails` gem provides the `javascript_include_tag` helper to add the `<script>` tag in the head. `Webpacker` gem provides a similar helper: `javascript_pack_tag`.

We'll use both files simultaneously while migrating. At the end we will remove the previous one, that way we test incremental changes.

```erb
= javascript_include_tag 'application' 
= javascript_pack_tag 'application'
```

## Moving Files

The original `application.js` includes our styleguide, some third party code and some custom js files. This is an extract:

```js
...
//= require fastruby/styleguide
//= require rails-ujs
//= require contact
//= require form
...
```

### Simple Files

We started by moving custom local files, since it requires less work. Most of the files can be moved from `app/assets/javascript` to `app/javascript/src` and import them as modules with no big changes.

```js
// app/javascript/packs/application.js

import "../src/contact"
import "../src/form"
```

The `form.js` file includes a function that should be global, so we have to fix that (webpack runs code isolated, so functions don't populate the global space by default).

```js
// app/javascript/src/form.js
// before
function renderValue(value) {
...

// after
global.renderValue = function(value) {
...
```

### 3rd Party Code

We use rails-ujs to handle the remote form submission and other Rails event. Instead of moving files, for this case we have to add the `@rails/ujs` package and initialize it inside our `application.js`.

```sh
$ yarn add @rails/ujs
```

```js
// app/javascript/packs/application.js
require('@rails/ujs').start()
```

Each 3rd party package that you use can have its own way to use it with Webpack.

### Moving The Styleguide

Now we need to do the biggest change: replace the `fastruby-styleguide` Ruby gem with the new `fastruby-io-styleguide` node module.

First we removed the gem from our gemfile and added the node module using yarn directly from github running `yarn add "fastruby/styleguide#gh-pages"` (`#...` is the branch name we want).

Now we have to change how we import the assets in both the SCSS and the JS files:

```js
// app/assets/stylesheets/application.js
// before
@import "fastruby/styleguide";

// after
@import "fastruby-io-styleguide";
```

```js
// app/javascript/packs/application.js
// added at the top
import "fastruby-io-styleguide"
```

And we can finally clear the previous `application.js` at `app/assets/javascript/application.js`.

### jQuery Integration

This last change created a few issues related to jQuery: the `jQuery` object was not available globally (so Bootstrap failed), and jQuery's `ready` callback was not triggered properly.

To fix the `undefined jQuery` error, we need to configure Webpack to expose it using this config at `config/webpack/environment.js`:

```js
const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

module.exports = environment
```

To fix the issue with jQuery's `ready` callback not triggered, we fixed it by just replacing all `$(document).on('ready', ...)` calls (and similar ones) to `document.addEventListener('DOMContentLoaded', ...)`.

Now all our tests are green.

### Remove `app/assets/javascript`

Now that our original `application.js` file is empty, we can remove it, but we need to fix Sprockets' config at `app/assets/config/manifest.js`. Remove the line: `//= link_directory ../javascript .js` so it doesn't search for a javascript directory that doesn't exist anymore.

Finally, we can remove the `<script>` tag in the head of our layout by removing the old `javascript_include_tag 'application'` call.

## Configure CircleCI

Since we are using CircleCI as a continuos integration service an we were not using Yarn to handle 3rd party node modules before, we need to fix the configuration so CircleCI installs all Yarn packages before running the tests.

Look for your `bundle install` call in the `.circle/config.yml` config file and add the `yarn install` command after it.

## Conclusion

It takes some time and a bit of a mindset change since Sprockets and Webpack works differently, but now we are using the current Rails standard to handle assets. Thanks to this and Webpack's popularity, we can now use modern JS features, frameworks, and tools more easily.



Do you need help migrating to Webpack? [Contact us](https://www.fastruby.io/#contactus)
