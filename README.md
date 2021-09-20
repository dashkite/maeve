# Maeve

_For implementing and testing Edge Lambdas_

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

## Response

### from

`from description → normalized-response`

Creates a normalized response object given a description.

