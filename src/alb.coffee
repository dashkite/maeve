import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Value from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"

headerCase = (name) ->
  name
    .replace /^[A-Za-z]/, (c) -> c.toUpperCase()
    .replace /\-[A-Za-z]/, (c) -> c.toUpperCase()

getRequest = (event) -> Value.clone event

getRequestTarget = (request) ->
  do ({ target, url } = {}) ->
    target = request.path
    query = (new URLSearchParams request.queryStringParameters).toString()
    if query != ""
      target += "?#{query}"
    target

getRequestMethod = (request) ->
  Text.toLowerCase request.httpMethod

getRequestHeader = (request, key) ->
  # IMPORTANT The request headers are lowercase, unlike the response headers
  # TODO Figure out why and/or whether this matters, can we just use lowercase?
  request.headers[ Text.toLowerCase key ]

getRequestHeaders = (request) ->
  result = {}
  for key, value of request.headers
    _key = Text.toLowerCase key
    result[ _key ] ?= []
    result[ _key ].push value
  result

getRequestContent = (request) ->
  if request.isBase64Encoded
    throw new Error "Maeve does not yet support base64 encoded body content"
  else
    request.body

getNormalizedRequest = (event) ->
  request = getRequest event
  target: getRequestTarget request
  method: getRequestMethod request
  headers: getRequestHeaders request
  content: getRequestContent request

setResponseStatusCode = (response, { status, description }) ->
  # TODO possibly infer status from description
  response.statusCode = status

setResponseStatusDescription = (response, { status, description }) ->
  # TODO possibly infer description from status
  response.statusDescription = description

setResponseHeader = (response, key, value) ->
  response.headers ?= {}
  # see comment above for getRequestHeader
  response.headers[ headerCase key ] = value

setResponseHeaders = (response, { headers }) ->
  for key, value of headers
    setResponseHeader response, key, value[0]
  response

setResponseBody = (response, { content }) ->
  response.body = content

setResponseBodyIsBase64Encoded = (response, { content, encoding }) ->
  if encoding == "base64"
    response.isBase64Encoded = true
  else
    response.isBase64Encoded = false

getDenormalizedResponse = (response) ->
  _response = {}
  setResponseStatusCode _response, response
  setResponseStatusDescription _response, response
  setResponseHeaders _response, response
  setResponseBody _response, response
  setResponseBodyIsBase64Encoded _response, response
  _response

export {
  getRequest
  getRequestTarget
  getRequestMethod
  getRequestHeader
  getRequestHeaders
  getNormalizedRequest
  setResponseStatusCode
  setResponseStatusDescription
  setResponseHeader
  setResponseHeaders
  setResponseBody
  setResponseBodyIsBase64Encoded
  getDenormalizedResponse
}