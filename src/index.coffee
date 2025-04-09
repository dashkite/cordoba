import "@virtualstate/navigation/polyfill"
import Registry from "@dashkite/registry"
import * as It from "@dashkite/joy/iterable"

Navigate =

  navigable: ( event ) ->
    event.canIntercept &&
      ( !event.hashChange ) &&
      ( !event.downloadRequest ) &&
      ( !event.formData ) &&
      ( event.navigationType in [ "push", "replace", "traverse" ])

Router =

  run: ( handler ) ->

    application = await Registry.get "application"
  
    go = ( url ) ->
      if ( page = application.query url )?
        handler page
      else
        console.warn "cordoba: 
          unable to find page for
          [ #{ url } ]"

    go window.location

    do ->
      for await event from It.events "navigate", navigation
        if Navigate.navigable event
          event.intercept 
            handler: -> go event.destination.url
      return

export default Router