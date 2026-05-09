# Reference

## Router.run

$Router.run: application \dashrightarrow \emptyset$

Initializes and starts the router. It sets up the navigation pipeline and listens for browser navigation events.

- `application`: An object that can contain `before` and `after` reactors.
  - `before`: An async generator function (reactor function) that processes the navigation context before the page is rendered.
  - `after`: An async generator function (reactor function) that processes the navigation context after the page is rendered.
