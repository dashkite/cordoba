import "@virtualstate/navigation/polyfill"
import Registry from "@dashkite/registry"
import * as It from "@dashkite/joy/iterable"

# TODO provide more complete interface for navigation lifecycle
#      ex: scrollrestoration / focus management / success and failure
#      https://developer.chrome.com/docs/web-platform/navigation-api/#scroll_handling
#      https://developer.chrome.com/docs/web-platform/navigation-api/#focus_handling

# TODO possibly improve error handling (ex: not found)
#      https://developer.chrome.com/docs/web-platform/navigation-api/#success_and_failure_events

# TODO add authorization check?

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
  
    go = ({ url, changed }) ->
      if ( page = application.query url )?
        handler { url, changed, page... }
      else
        console.warn "cordoba: 
          unable to find page for
          [ #{ url } ]"

    # initial nav by def has changed
    go url: window.location, changed: true

    do ->
      ready = undefined
      navigation.addEventListener "navigate", ( event ) ->
        if Navigate.navigable event
          url = new URL event.destination.url
          changed = url.href != window.location.href
          event.intercept handler: -> go { url, changed }

    # do ->
    #   for await event from It.events "navigateerror", navigation
    #     console.log error: event
    #     navigation.navigate "/connect"

export default Router