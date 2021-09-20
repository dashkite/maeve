import HTTP from "http"
import * as _ from "@dashkite/joy"

fromBase64 = (text) ->
  Buffer.from text, "base64"
    .toString "utf8"

toBase64 = (text) ->
  Buffer.from text, "utf8"
    .toString "base64"

fromEventHeaders = (headers) ->
  result = {}
  for key, values of headers
    if values.length > 1
      result[key] = (value for {value} in values)
    else
      result[key] = values[0]
  result

toEventHeaders = (headers) ->
  result = {}
  for key, value of headers
    (result[key] ?= []).push { key, value }
  result

Event =

  isType: (value) -> value.Records?

  # TODO do we need to support response also?
  from: ({ request }) ->

    Records: [
      cf:
        # TODO do we need to mock config?
        config: {}
        request: Event.Request.from request
    ]

  dispatch: (event, handler) ->
    new Promise (resolve, reject) ->
      callback = (error, result) ->
        if error?
          reject error
        else
          resolve result
      # TODO do we need to do anything for the context?
      handler event, {}, callback

Event.Request =

  from: _.generic
    name: "Event.Request"
    description: "Convert an event or normalized request to an AWS event request"
    default: (request) ->
      # normalize
      request = Request.from request
      # sighs in HTTP ...
      [ path, search ] = _.split "?", request.uri

      uri: path
      method: _.toUpperCase request.method
      headers: toEventHeaders request.headers
      querystring: search
      body: if request.content?
        inputTruncated: false
        action: "read-only"
        encoding: "base64"
        data: toBase64 JSON.stringify request.content
        
_.generic Event.Request.from, Event.isType, (event) -> event.Records[0].cf.request

Event.Response =

  from: _.generic
    name: "Event.Response.from"
    description: "Convert an event or normalized response to an AWS event response"
    default: (response) ->
      # normalize
      response = Response.from response
      status: response.status.toString()
      statusDescription: HTTP.STATUS_CODES[ response.status ]
      headers: toEventHeaders response.headers

_.generic Event.Response.from, Event.isType, (event) -> event.Records[0].response

Request =

  from: _.generic
    name: "Request.from"
    description: "Normalize an event request or partial request description"
    default: ({ uri, method, headers, content }) ->
      uri: uri
      method: _.toLowerCase method ? "get"
      headers: headers ? {}
      content: content

_.generic Request.from, Event.isType, (event) ->

    { request } = event.Records[0].cf

    # sighs in HTTP ...
    uri: if request.querystring? && request.querystring != ""
          "#{request.uri}?#{request.querystring}"
        else request.uri
    method: _.toLowerCase request.method
    headers: fromEventHeaders request.headers
    content: JSON.parse fromBase64 request.data

Response =

  from: _.generic
    name: "Response.from"
    description: "Normalize an event response or partial response description"
    default: ({ status, headers }) ->
      status: status ? "200"
      headers: headers ? {}

_.generic Response.from, Event.isType, (event) ->
    { response } = event.Records[0].cf
    status: response.status
    headers: fromEventHeaders response.headers

export { Event, Request, Response }