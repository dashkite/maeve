# Maeve

_Implement and test Lambda functions more easily._

> The simulation is elegant, but it's flawed because it was built by your kind. And if there's one thing I know about human nature, it's that your stupidity is only eclipsed by your laziness. Whoever programmed this world cut a few corners, applied the same code inside the simulation as they used to build the simulation itself.
>
> Maeve, _WestWorld_


# Reference

## Event

### from

`from description → event`

Converts a normalized request to an event.

#### Example

```coffeescript
import { Event } from "@dashkite/maeve"

event = Event.from
  request:
    uri: "/"
    method: "get"
    headers: {}
```

### dispatch

`dispatch event, handler → promise`

Dispatches an event to a handler, returning a promise. Useful for testing handlers without having to define a callback.

#### Example

```coffeescript
import { Event } from "@dashkite/maeve"

handler = (event, context, callback) ->
  callback null, Event.Request.from event

event = Event.from
  request:
    uri: "/"
    method: "get"
    headers: {}

request = await Event.dispatch event, handler
```

## Event.Request

### from

`from request → event-request`

Given a normalized request returns an event request.

`from event → event-request`

Given an event, returns the corresponding event request.

### Event.Response

### from

`from response → event-response`

Given a normalized response returns an event response.

`from event → event-response`

Given an event, returns the corresponding event response.

## Request

### from

`from description → normalized-request`

Creates a normalized request object given a description.

`from event → normalized-request`

Given an event, returns a normalized request.

## Response

### from

`from description → normalized-response`

Creates a normalized response object given a description.

`from event → normalized-response`

Given an event, returns a normalized response.
