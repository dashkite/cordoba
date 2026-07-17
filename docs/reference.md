# Reference

## Concepts and Interfaces

Cordoba's routing architecture relies on a pipeline of asynchronous generator functions called *reactors*. The router integrates with a global `Registry` and expects a companion library like Monterey to handle the registration and indexing of application routes. 

### The Application Registry

Cordoba expects a page registry to be registered globally under the name `"application"`. This registry must provide key methods required for routing logic:
- `query`: A function to match a URL against registered routes and return the matched page object.
- `link`: A function to generate a URL from a route name and bindings.
- `navigate`: A function to programmatically trigger navigation to a named route.

### The Pipeline Context

As the router processes navigation events, it constructs a context object that flows through the reactor pipeline. The context contains details about the target page and the current connection state.

- `url`: The target URL for the navigation event.
- `data`: Custom metadata associated with the target page (such as `name`, `public`, or rendering functions).
- `bindings`: Extracted parameters from the URL matching the route template.
- `connected`: A boolean indicating if the application is currently connected to backend services.
- `connecting`: A boolean indicating if a connection is currently being established.

## Router

The `Router` object provides the core pipeline management for client-side navigation. It intercepts browser navigation events and routes them through the registered middleware reactors.

### Router.run

$Router.run: application \dashrightarrow \emptyset$

Initializes and starts the client-side routing pipeline. It establishes the internal reactive channel, sets up a global presence topic, and binds to the modern Browser Navigation API to capture `navigate` events.

The `application` argument is an object specifying the middleware for the pipeline. It accepts two properties:

- `before`: An asynchronous generator function that receives the incoming stream of context objects and yields them forward. This reactor runs *before* the destination page's primary execution function. It is the ideal place for authorization logic or preemptive redirects.
- `after`: An asynchronous generator function that receives the stream of context objects *after* the page has been applied. It can be used for telemetry, scroll restoration, or post-render side effects.

By default, if `before` or `after` are omitted, Cordoba uses an identity function that simply yields the context forward without modification.

#### Example

This illustrates initializing the router and asserting its return type.

```coffeescript
import Router from "@dashkite/cordoba"
import Registry from "@dashkite/registry"
import assert from "@dashkite/assert"

# Mock the application registry for the test
Registry.set "application", 
  navigate: -> 
  query: -> { data: { name: "home" }, bindings: {} }
  link: -> "/"

# Define a custom reactor
before = ( source ) ->
  for await context from source
    yield context

# Router.run returns a promise that resolves when the pipeline is initialized
promise = Router.run { before }
assert.ok promise instanceof Promise
```
