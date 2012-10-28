# Quick Start
This is intended to be a minimal guide to get you started with Reaction. Refer
to the [Todos][todos] app for an example.

## Background
Suppose you are building an app that allows users to interact with a collection
of todo objects. In Rails, this means that you have defined a `Todo` model and
a `TodosController`. These may look like the following:

```ruby
# app/models/todo.rb
class Todo < ActiveRecord::Base
  attr_accessible :title, :completed
end

# app/controllers/todos_controller.rb
class TodoController < ApplicationController

  def index
    @todos = Todo.all
    # render ...
  end

  def create
    @todo = Todo.new(params[:todo])
    # redirect ...
  end

  def update
    @todo = Todo.find(params[:id])
    # filter ...
    @todo.update_attributes(filtered)
    # render ...
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    # render ...
  end

end
```

Traditionally, you would have also have a view for the TodosController.
However, because you are cool, you really want to build a one-page app using
Backbone.

This framework helps you to synchronize the todo objects on the server with the
todo objects in Backbone. Furthermore, changes made by other users are
broadcast across the app, allowing users to see live updates.

## Installing
In your Gemfile, add the reaction gem:

```ruby
gem 'reaction'
```

Then run `bundle install`.

## Routing
There are two ways to start Reaction. The first way is easier.

### In-Process
To start the reaction server in the same server as the Rails application, in
`config/routes.rb`, add the following:

```ruby
X::Application.routes.draw do
  mount_reaction
  # your other routes ...
end
```

And that's it. Refer to the [documentation][mount_reaction] for more options.
Most of the time, the defaults should be all you need.

### External
For performance and scalability reasons, you might want to separate the
reaction server from the Rails server.

1. Make sure you have the reaction gem installed on your machine.

  ```bash
  $> gem install reaction
  ```
1. Start the reaction server

  ```bash
$> reaction --port 9292 --key super_secret_key
  ```
1. Add the following to `config/routes.rb`

  ```ruby
  X::Application.routes.draw do
      use_reaction at: 'http://localhost:9292', key: 'super_secret_key'
      # your other routes ...
  end
  ```

## Prepare the View
Since you are writing a one-page app, one view is all you need. Refer to the
the [todos view][todos-view] for a detailed example. Here, it's just the usual
Backbone stuff, using the templating provided by Underscore.

Note, however, that `erb` requires you to escape `<%` as `<%%`.

```erb
<script type='text/template' id='item-template'>
  <div class="view" data-id="<%%- id %>">
    <input class="toggle" type="checkbox"<%%= completed ? ' checked' : '' %>>
    <label><%%- title %></label>
    <button class="destroy"></button>
  </div>
  <input class="edit" value="<%%- title %>">
</script>
```

## Write the JavaScript
Write the javascript behavior for your app in a javascript file (say,
`init.js`). If you are not familiar with using Backbone, they have some great
examples [here][backbone]. The only difference is that instead of `new
Backbone.Collection`, we use `new Reaction.Collection`.

Wrap your code with an `init` function, like this:

```js
init = function() {
  // your code here
};
```

In `application.js`, import the following scripts:

```js
//= require reaction/underscore
//= require reaction/backbone
//= require reaction/amplify
//= require reaction
```

If you already have Underscore, Backbone, or Amplify, then you don't have to
import them. Finally, launch the app with:

```ruby
Reaction.on('ready', init);
```

A complete example is available [here][todos-init]. If you are using an
external reaction server, specify the host and port at the top of your script.

```ruby
Reaction.config.paths.reaction = 'http://localhost:9292'
```

## Launch the App
Start the application!

```sh
$> bundle exec rails server
```

Open up two browsers and point them to the app. Changes made in one window are
broadcast and updated in the other window.

  [todos]: https://github.com/jimjh/reaction-todos
  [todos-view]: http://jimjh.github.com/reaction-todos/app/views/home/index.html.html
  [todos-init]: http://jimjh.github.com/reaction-todos/app/assets/javascripts/init.html
  [mount_reaction]: http://rubydoc.info/gems/reaction/ActionDispatch/Routing/Mapper:mount_reaction
  [backbone]: http://backbonejs.org/
