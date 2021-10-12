import HTTP from "http"
import * as _ from "@dashkite/joy"
import {
  fromBase64
  toBase64
  fromEventHeaders
  toEventHeaders
  read
} from "./helpers"

Event =

  isType: (value) -> value?.Records?

  to: _.generic
    name: "Event.to"
    description: "Convert an event into a given result"

  from: ({ request, response }) ->
    Records: [
      cf:
        # TODO do we need to mock config?
        config: {}
        request: Event.Request.from request
        response: ( Event.Response.from response ) if response?
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

_.generic Event.to, ( _.isType HTTP.ServerResponse ), _.isObject,
  (serverResponse, response) ->
    Event.Response.to serverResponse, response

Event.Request =

  isType: (value) -> value?.clientIp?

  from: _.generic
    name: "Event.Request"
    description: "Convert an event or normalized request to an AWS event request"

_.generic Event.Request.from, _.isObject, (request) ->
    # normalize
    request = Request.from request
    headers = toEventHeaders request.headers
    headers.host = [ key: "host", value: request.host ]
    clientIp: request.clientIp ? "127.0.0.1"
    uri: request.path # sighs in HTTP
    querystring: request.query
    method: _.toUpperCase request.method
    headers: headers
    body: if request.content?
      inputTruncated: false
      action: "read-only"
      encoding: "base64"
      data: toBase64 JSON.stringify request.content
    origin: request.origin

_.generic Event.Request.from, (_.isType HTTP.IncomingMessage), (request) ->
  Event.Request.from Request.from request

_.generic Event.Request.from, Event.isType, (event) -> event.Records[0].cf.request

_.generic Event.Request.from, Event.isType, _.isObject,
  (event, request) ->
    original = Event.Request.from event
    for key, value of Event.Request.from request
      if value?
        original[key] = value
    original

Event.Response =

  isType: (value) -> value?.statusDescription?

  to: _.generic
    name: "Event.Response.to"
    description: "Convert an event or normalized response to a given result"

  from: _.generic
    name: "Event.Response.from"
    description: "Convert an event or normalized response to an AWS event response"

_.generic Event.Response.from, _.isObject, (response) ->
    # normalize
    response = Response.from response
    status: response.status.toString()
    statusDescription: HTTP.STATUS_CODES[ response.status.toString() ]
    headers: toEventHeaders response.headers
    body: if response.body? then response.body
    bodyEncoding: if response.encoding? then response.encoding

_.generic Event.Response.to, ( _.isType HTTP.ServerResponse ), _.isObject,
  (serverResponse, response) ->
    normalizedResponse = Response.from response
    serverResponse.statusCode = normalizedResponse.status
    for key, value of normalizedResponse.headers
      serverResponse.setHeader key, value
    if normalizedResponse.body?
      serverResponse.end normalizedResponse.body
      # TODO set content-encoding?
    else
      serverResponse.end()


_.generic Event.Response.from, Event.isType, (event) -> event.Records[0].response

_.generic Event.Response.from, Event.isType, _.isObject,
  (event, response) ->
    # just ignore event for now
    Event.Response.from response

Request =
  isType: (value) -> value? && value.target? && value.method? && value.headers?
  from: _.generic
    name: "Request.from"
    description: "Normalize an event request or partial request description"

_.generic Request.from, _.isObject, 
  ({ url, method, headers, content, origin }) ->
      { pathname, search, hostname } = new URL url
      url: url
      target: "#{pathname}#{search}"
      path: pathname
      query: search
      host: hostname
      method: _.toLowerCase method ? "get"
      headers: headers ? {}
      content: content
      origin: origin ?
        custom:
          customHeaders: {}
          domainName: 'localhost',
          keepaliveTimeout: 60,
          path: '',
          port: 8000,
          protocol: 'http',
          readTimeout: 60,
          sslProtocols: [ "TLSv1.2" ]

_.generic Request.from, (_.isType HTTP.IncomingMessage), (request) ->
  Request.from
    url: request.url
    method: request.method
    headers: request.headers
    content: if ( _.parseNumber request.headers["content-length"] ) > 0
      await read request

_.generic Request.from, Event.Request.isType, (request) ->
    target = if request.querystring? && request.querystring != ""
      "#{request.uri}?#{request.querystring}"
    else
      request.uri
    headers = fromEventHeaders request.headers
    url: "#{headers.host}#{target}"
    target: target
    path: request.uri # sighs in HTTP
    query: request.queryString
    method: _.toLowerCase request.method
    headers: headers
    content: if request.body?.data? then JSON.parse fromBase64 request.body.data
    origin: request.origin

_.generic Request.from, Event.isType, (event) ->
    { request } = event.Records[0].cf
    Request.from request

Response =
  isType: (value) -> value? && value.status?
  from: _.generic
    name: "Response.from"
    description: "Normalize an event response or partial response description"

_.generic Response.from, _.isObject,
  ({ status, headers, body, encoding }) ->
      status: status ? "200"
      headers: headers ? {}
      body: body
      encoding: encoding

_.generic Response.from, Event.Response.isType, (response) ->
    status: _.parseNumber response.status
    headers: fromEventHeaders response.headers
    body: if response.body?
      switch response.bodyEncoding
        when "base64" then fromBase64 response.body
        else response.body
    encoding: response.bodyEncoding

_.generic Response.from, Event.isType, (event) ->
    { response } = event.Records[0].cf
    Response.from response

isFetchResponse = (value) -> value?.json?

_.generic Response.from, isFetchResponse, (response) ->
  Event.Response.from
    status: response.status
    headers: do ->
      result = {}
      for [ key, value ] from response.headers
        result[ key ] = value
      result
    body: await response.text()

export { Event, Request, Response }