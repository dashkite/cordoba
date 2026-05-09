# Recipes

## Basic Setup with Monterey

Cordoba works with any compatible page registry, such as Monterey.

```coffeescript
import Registry from "@dashkite/registry"
import Monterey from "@dashkite/monterey"
import Router from "@dashkite/cordoba"

# Initialize Monterey
pages = Monterey.make()

# Register a page
pages.add "/", 
  name: "home"
  apply: (context) ->
    console.log "Welcome home!"

# Register Monterey as the application registry
Registry.set "application", pages

# Start the router
Router.run()
```

## Authentication Middleware

In Cordoba, `before` and `after` are not conventional hooks, but **reactors**. They take an event stream (`source`) and must yield the context if the pipeline should proceed. This allows for complex, asynchronous logic including redirects and state transformations.

```coffeescript
import Router from "@dashkite/cordoba"
import Registry from "@dashkite/registry"

# before is a reactor that processes the navigation stream
before = ( source ) ->
  application = await Registry.get "application"
  for await context from source
    { data, profile } = context
    # Check if page is public or if user is logged in
    if data.public or profile?
      yield context
    else
      # Redirect to connect page
      application.navigate name: "connect"

Router.run { before }
```
