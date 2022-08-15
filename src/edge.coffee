import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Value from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"
import { convert } from "@dashkite/bake"
import { MediaType } from "@dashkite/media-type"

import {
  getStatusFromDescription
  getDescriptionFromStatus
} from "./common"

getRequest = (event) -> Value.clone event.Records?[0]?.cf?.request

getResponse = (event) -> Value.clone event.Records?[0]?.cf?.response

getRequestTarget = (request) ->
  if request.querystring == ""
    request.uri
  else
    "#{request.uri}?#{request.querystring}"

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

getRequestBody = (request) ->
  request.body

getRequestContent = (request) ->

  if request.body?

    data = if request.body.encoding == "base64"
      convert from: "base64", to: "utf8", request.body.data
    else
      request.body.data

    # TODO handle more formats
    if ( type = getRequestHeader request, "content-type" )?
      switch MediaType.category type
        when "json" then JSON.parse data
        else data
    else data

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
  response.status = response.status.toString()

setResponseStatusDescription = (response, { status, description }) ->
  response.statusDescription = description ? 
    if status? then getDescriptionFromStatus status

setResponseHeader = setHeader

setResponseHeaders = (response, { headers }) ->
  for key, value of headers
    setResponseHeader response, key, value[0]
  response

setResponseBody = (response, { content, encoding }) ->
  setResponseBodyEncoding response, { encoding }
  response.body = do ->
    if Type.isString content
      content
    else if content?
      switch encoding
        when "text", undefined, null then JSON.stringify content
        when "base64" then convert from: "bytes", to: "base64", content
        else
          console.warn "unsupported encoding: #{ encoding }"
          content.toString()
    else ""
      
setResponseBodyEncoding = (response, { encoding }) ->
  if encoding == "base64"
    response.bodyEncoding = "base64"
  else
    response.bodyEncoding = "text"

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
  getRequestBody
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