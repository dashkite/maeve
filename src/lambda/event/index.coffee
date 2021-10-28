import * as Fn from "@dashkite/joy/function"
import * as Meta from "@dashkite/joy/metaclass"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import * as Sublime from "#sublime"
import { Generic } from "#helpers"
import { buildRequest, buildResponse, buildEventHeaders } from "./helpers"

class Event

  Meta.mixin @::, [

    Meta.getters

      rawRequest: -> @_.Records?[0]?.cf?.request
      request: -> buildRequest @rawRequest

      rawResponse: -> @_.Records?[0]?.cf?.response
      response: -> buildResponse @rawResponse


  ]

  @from: Generic.create "Lambda.Event.from"

  @apply: Generic.create "Lambda.Event.apply"

  apply: -> Fn.apply Event.apply, [ @, arguments... ]

isLambdaEventLike = (value) -> value.Records?[0]?.cf?.config?

Generic.define Event.from,
  [
    isLambdaEventLike
  ]
  (event) ->
    self = new Event
    self._ = event
    self

Generic.define Event.apply,
  [
    Type.isType Event
    Type.isType Sublime.Request
  ]
  (event, request) ->
    event.rawRequest.uri = request.target
    event.rawRequest.method = Text.toUpperCase request.method
    event.rawRequest.headers = buildEventHeaders request.headers
    event.rawRequest.origin.custom.domainName = request.domain
    event.rawRequest.body = if request.content?
      inputTruncated: false
      action: "read-only"
      encoding: "base64"
      data: request.content.to "base64"
    event.rawRequest

Generic.define Event.apply,
  [
    Type.isType Event
    Type.isType Sublime.Response
  ]
  (event, response) ->
    event.rawResponse.status = response.status.toString()
    event.rawResponse.statusDescription = response.description
    event.rawResponse.headers = buildEventHeaders response.headers
    event.rawResponse

export * from "./headers"
export * from "./request"
export * from "./response"
export { Event }
