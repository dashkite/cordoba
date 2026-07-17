# Technical Notes

### Navigation API Integration

Cordoba delegates low-level transition details to the modern [Navigation API](https://developer.mozilla.org/en-US/docs/Web/API/Navigation_API). The Navigation API provides a modern, decoupled interface for managing the registration of processes for reacting to page navigation or link clicks in single-page applications. It allows the browser to handle a great many details about the transition process.

While the recommended companion library, Monterey, is focused on the registration of *routes* (built on the URL template technology URL Codex) and presenting a stable ordering that affects route matching, Cordoba is interested in wrapping the Navigation API itself.

### Reactive Navigation Interface

Cordoba establishes a reactor interface to compose with the browser navigation using DashKite's reactive programming style. 

The `Navigate.bridge` function listens for the `navigate` event on `globalThis.navigation`, intercepts valid navigations (such as push, replace, and traverse), and sends them to the internal reactive channel.

Because the `navigate` event is performance-sensitive, we must avoid generators in the immediate event listener. Therefore, the most proximate part of the handler is written imperatively to ensure optimal performance, before bridging the events into the asynchronous pipeline.

### Pipeline Architecture

The router processes navigation events through a pipeline composed of several asynchronous generator functions (reactors). The pipeline is defined using `@dashkite/joy/function`'s `pipe` utility and executed by `@dashkite/river`'s `start` function.

### Presence and Connection State

Cordoba utilizes a global presence topic to track the connection state. By listening to "connect", "disconnect", and "rejected" events on this topic, it maintains a `session` object indicating whether the application is connected or in the process of connecting.
