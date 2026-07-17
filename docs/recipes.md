# Recipes

## Basic Setup with Monterey

This guide explains how to initialize Cordoba alongside Monterey. Cordoba provides the reactive routing engine, while Monterey serves as the expected companion library for route registration and matching.

### What is the step-by-step algorithm?

First, initialize a Monterey registry to manage the application's routes.
Second, register a page within the registry to define the destination and its behavior.
Third, register the Monterey instance in the global Registry under the name `"application"`.
Finally, execute the router using the `run` method to start listening for navigation events.

```coffeescript
import Registry from "@dashkite/registry"
import Monterey from "@dashkite/monterey"
import Router from "@dashkite/cordoba"

pages = Monterey.make()

pages.add "/", 
  name: "home"
  apply: (context) ->
    # rendering logic goes here
    console.log "Navigated to home"

Registry.set "application", pages

Router.run()
```

## Standalone Setup Without Monterey

This guide explains how to use Cordoba without Monterey by implementing a custom application registry. Cordoba expects a specific interface from the registered `"application"` object, allowing developers to bring their own matching logic.

### What is the step-by-step algorithm?

First, define a custom object that implements the required registry interface: `navigate`, `query`, and `link`.
Second, implement the `query` method to match a target URL and return a page object with `data` and `bindings`.
Third, register the custom object in the global Registry under the name `"application"`.
Finally, initialize the router.

```coffeescript
import Registry from "@dashkite/registry"
import Router from "@dashkite/cordoba"

# implementation of custom routing tree goes here
router = new CustomTree()

customRegistry =
  navigate: ({ name, bindings }) ->
    window.location.assign router.resolve name, bindings
  query: (url) ->
    match = router.match url.pathname
    data: { name: match.name }
    bindings: match.params
  link: ({ name, bindings }) ->
    router.resolve name, bindings

Registry.set "application", customRegistry

Router.run()
```

## Authorizing Access with Middleware

This guide explains how to protect specific routes using the `before` reactor. Cordoba processes navigation events through asynchronous generators, allowing middleware to asynchronously inspect state before proceeding.

### What is the step-by-step algorithm?

First, define an asynchronous generator function for the `before` reactor.
Second, iterate over the incoming navigation contexts using a `for await...from` loop.
Third, inspect the context data to determine if the developer holds the required authorization.
If authorized, yield the context to continue the pipeline; otherwise, invoke the registry to redirect.
Finally, pass the reactor to `Router.run`.

```coffeescript
import Router from "@dashkite/cordoba"
import Registry from "@dashkite/registry"

before = ( source ) ->
  application = await Registry.get "application"
  for await context from source
    
    # implementation of custom authorization check goes here
    authorized = checkAuthorization context.data, context.profile
    
    if authorized
      yield context
    else
      application.navigate name: "connect"

Router.run { before }
```

## Handling Post-Render Side Effects

This guide explains how to execute logic after a page has rendered using the `after` reactor. Because Cordoba's pipeline flows sequentially, the `after` reactor receives contexts only after the destination page's `apply` function completes.

### What is the step-by-step algorithm?

First, define an asynchronous generator function for the `after` reactor.
Second, iterate over the incoming contexts yielded by the rendering step.
Third, perform the desired side effects, such as updating telemetry or manipulating scroll position.
Finally, yield the context so the pipeline completes naturally.

```coffeescript
import Router from "@dashkite/cordoba"

after = ( source ) ->
  for await context from source
    
    # implementation of telemetry dispatch goes here
    recordTelemetry context.url.pathname, context.data.name
    
    yield context

Router.run { after }
```
