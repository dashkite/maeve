import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Value from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"

import {
  getStatusFromDescription
  getDescriptionFromStatus
} from "./common"

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
  if request.isBase64Encoded == true
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
  response.statusCode = status ? 
    if description? then getStatusFromDescription description

setResponseStatusDescription = (response, { status, description }) ->
  response.statusDescription = description ? 
    if status? then getDescriptionFromStatus status

setResponseHeader = (response, key, value) ->
  response.headers ?= {}
  # see comment above for getRequestHeader
  response.headers[ headerCase key ] = value

setResponseHeaders = (response, { headers }) ->
  for key, value of headers
    setResponseHeader response, key, value[0]
  response

setResponseBody = (response, { content }) ->
  if Type.isString content
    response.body = content
  else
    response.body = JSON.stringify content

setResponseBodyEncoding = (response, { content, encoding }) ->
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
  setResponseBodyEncoding _response, response
  _response

export {
  getStatusFromDescription
  getDescriptionFromStatus
  getRequest
  getRequestTarget
  getRequestMethod
  getRequestHeader
  getRequestHeaders
  getNormalizedRequest
  setResponseStatusCode
  setResponseStatusDescription
  setResponseHeaders
  setResponseBody
  setResponseBodyEncoding
  getDenormalizedResponse
}