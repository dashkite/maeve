import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Value from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"
import { convert } from "@dashkite/bake"

import {
  getStatusFromDescription
  getDescriptionFromStatus
} from "./common"

getRequest = (event) -> Value.clone event.Records?[0]?.cf?.request

getResponse = (event) -> Value.clone event.Records?[0]?.cf?.response

getRequestURL = (request) ->
  # do ({ scheme, domain, port, target, url } = {}) ->
  do ({ scheme, host, target, url } = {}) ->
    scheme = request.origin.custom.protocol
    # domain = request.origin.custom.domainName
    # port = request.origin.custom.port
    host = getRequestHeader request, "host"
    target = getRequestTarget request
    # if port == ""
    #   url = "#{scheme}://#{domain}#{target}"
    # else
    #   url = "#{scheme}://#{domain}:#{port}#{target}"
    url = "#{scheme}://#{host}#{target}"
    ( new URL url ).href

getRequestTarget = (request) ->
  if request.querystring == ""
    request.uri
  else
    "#{request.uri}?#{request.querystring}"

getRequestMethod = (request) ->
  Text.toLowerCase request.method

getRequestHeader = (request, key) ->
  request.headers[ Text.toLowerCase key ]?[0]?.value

getRequestHeaders = (request) ->
  do ( { result, key, value } = {}) ->
    result = {}
    for key, values of request.headers
      for { value } in values
        (result[ key ] ?= []).push value
    result

getRequestContent = (request) ->
  if request.body?
    if request.body.encoding == "base64"
      # TODO handle non-text content
      convert from: "base64", to: "utf8", request.body.data
    else
      request.body.data

getNormalizedRequest = (event) ->
  request = getRequest event
  url: getRequestURL request
  target: getRequestTarget request
  method: getRequestMethod request
  headers: getRequestHeaders request
  content: getRequestContent request

# TODO set the host header?
setRequestOrigin = Fn.tee (request, value) ->
  request.origin.custom.domainName = value
  setHeader request, "host", value

setHeader = Fn.tee (object, key, value) ->
  object.headers ?= {}
  object.headers[ key ] ?= []
  object.headers[ key ].push { value }

setRequestHeader = setHeader

getResponseStatusCode = (response) ->
  Text.parseNumber response.status

setResponseStatusCode = (response, { status, description }) ->
  response.status = status ? 
    if description? then getStatusFromDescription description

setResponseStatusDescription = (response, { status, description }) ->
  response.statusDescription = description ? 
    if status? then getDescriptionFromStatus status

setResponseHeader = setHeader

setResponseHeaders = (response, { headers }) ->
  for key, value of headers
    setResponseHeader response, key, value[0]
  response

setResponseBody = (response, { content }) ->
  response.body ?= {}
  if Type.isString content
    response.body.data = content
  else
    response.body.data = JSON.stringify content

setResponseBodyEncoding = (response, { encoding }) ->
  response.body ?= {}
  if encoding == "base64"
    response.body.encoding = "base64"
  else
    response.body.encoding = "text"

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
  getResponse

  getRequestURL
  getRequestTarget
  getRequestMethod
  getRequestHeader
  getRequestHeaders
  getRequestContent
  getNormalizedRequest

  setRequestOrigin
  setRequestHeader

  getResponseStatusCode

  setResponseStatusCode
  setResponseStatusDescription
  setResponseHeader
  setResponseHeaders
  setResponseBody
  setResponseBodyEncoding
  getDenormalizedResponse

}