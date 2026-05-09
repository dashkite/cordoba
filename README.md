# Cordoba

*A reactive client-side router.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Cordoba is a reactive client-side router that leverages the browser-native Navigation API to provide a seamless routing experience. It uses event streams and a pipeline-based approach to navigation, allowing for flexible middleware and page management.

## Installation

Use your favorite package manager:

```bash
npm install @dashkite/cordoba
```

## Usage

Cordoba expects a compatible page registry to be registered in the Registry under the name `"application"`.

Initialize the router by calling `run` with optional hooks.

```coffeescript
import Router from "@dashkite/cordoba"

# Optional hook for pre-navigation logic (e.g., authentication)
before = ( source ) ->
  for await context from source
    if isAuthorized context
      yield context
    else
      # Redirect to login
      application.navigate name: "login"

Router.run { before }
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)

## Status

Not suitable for production use. Please report any issues on the [GitHub repository](https://github.com/dashkite/cordoba).
