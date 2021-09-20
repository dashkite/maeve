import getStatus from "statuses"

fromBase64 = (text) ->
  Buffer.from text, "base64"
    .toString "utf8"

toBase64 = (text) ->
  Buffer.from text, "utf8"
    .toString "base64"

fromEventHeaders = (headers) ->
  headers = {}
  for key, values of request.headers
    if values.length > 1
      headers[key] = (value for {value} in values)
    else
      headers[key] = values[0]
  headers

toEventHeaers = (headers) ->
  headers = {}
  for key, value in request.headers
    (headers[key] ?= []).push { key, value }
  headers

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
    description: "Convert an event or normalized request to AWS event request"
    default: (request) ->
      # sighs in HTTP ...
      [ path, search ] = _.split "?", request.uri
  
      uri: path
      method: request.method
      headers: toEventHeaders request.headers
      querystring: search
      body: if request.content?
        inputTruncated: false
        action: "read-only"
        encoding: "base64"
        body: toBase64 JSON.stringify content
        
_.generic Event.Request.from, Event.isType, (event) -> event.Records[0].request

Event.Response =

  from: (response) ->
    status: response.status
    statusDescription: getStatus response.status
    headers: toEventHeaders response.headers

_.generic Event.Response.from, Event.isType, (event) -> event.Records[0].response

Request =

  from: _.generic
    name: "Request.from"
    description: "Normalize an event request or partial request description"
    default: ({ uri, method, headers, content }) ->
      uri: uri
      method: method ? "get"
      headers: headers ? {}
      content: content

_.generic Request.from, Event.isType, (event) ->

    { request } = event.Records[0].cf

    # sighs in HTTP ...
    uri: if request.querystring? && request.querystring != ""
          "#{request.uri}?#{request.querystring}"
        else request.uri
    method: request.method
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