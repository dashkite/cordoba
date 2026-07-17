# Cordoba

*A reactive client-side router.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Cordoba is a reactive client-side router that leverages the browser-native Navigation API to provide a routing experience. It uses event streams and a pipeline-based approach to navigation, allowing for flexible middleware and page management.

## Features

- Built on the modern Browser Navigation API
- Reactive event pipeline for routing
- Composable middleware using asynchronous generator functions
- Integration with DashKite Registry and River

## Installation

```bash
pnpm install @dashkite/cordoba
```

## Usage

Cordoba expects a compatible page registry to be registered in the Registry under the name `"application"`.

Initialize the router by calling `run` with optional hooks.

```coffeescript
import Router from "@dashkite/cordoba"
import Registry from "@dashkite/registry"

# Optional hook for pre-navigation logic
before = ( source ) ->
  for await context from source
    if isAuthorized context
      yield context
    else
      application = await Registry.get "application"
      application.navigate name: "login"

Router.run { before }
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Testing](docs/testing.md)
- [Technical Notes](docs/technical-notes.md)
