import "@virtualstate/navigation/polyfill"
import Registry from "@dashkite/registry"
import Channel from "@dashkite/reactive/channel"
import Topic from "@dashkite/reactive/topic"
import { start } from "@dashkite/river"
import { pipe, identity } from "@dashkite/joy/function"

Navigate =

  navigable: ( event ) ->
    event.canIntercept &&
      ( !event.hashChange ) &&
      ( !event.downloadRequest ) &&
      ( !event.formData ) &&
      ( event.navigationType in [ "push", "replace", "traverse" ])

  bridge: ( navigation ) ->
    globalThis.navigation?.addEventListener "navigate", ( event ) ->
      if Navigate.navigable event
        url = new URL event.destination.url
        changed = url.href != window.location.href
        event.intercept handler: ->
          if changed
            navigation.send { name: "navigate", target: url }

valid = ( event ) ->
  ( event.name == "navigate" ) && event.target?

Router =

  defaults:
    before: identity
    after: identity

  run: ( application ) ->

    application = { @defaults..., application... }

    router = await Registry.get "application"
    
    # initialize internal navigation channel and public presence topic
    navigation = Channel.make()
    presence = Registry.set "presence", Topic.make()

    # initialize state
    session = { connected: false, connecting: false }

    Page =

      find: ( source ) ->
        for await event from source when valid event
          if ( page = router.query event.target )?
            # TODO this feels like it should be easier somehow
            # maybe just bundle the URL with the page in Monetery
            { data: { name }, bindings } = page
            url = router.link { name, bindings }
            yield { page..., url }
          else
            console.warn "cordoba: unable to find page", event.target

      go: ( source ) ->
        for await context from source
          yield await context.data.apply context

    Session =

      before: ( source ) ->
        for await context from source
          yield { context..., session... }

      after: ( source ) ->
        for await context from source
          if context.data.name == "connect"
            session.connecting = true
          yield context

    # Manage global disconnect
    do ->
      for await event from presence.subscribe()
        switch event.name
          when "connect"
            session.connected = true
            session.connecting = false
          when "disconnect", "rejected"
            session.connected = false
            session.connecting = false

    # Run the Pipeline
    reactor = pipe [
      Page.find
      Session.before
      application.before
      Page.go
      Session.after
      application.after
    ]

    start reactor navigation.listen()

    # handle browser navigation events
    Navigate.bridge navigation

    # Initial navigation
    navigation.send 
      name: "navigate"
      target: window.location

export default Router
