import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Value from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"

getRequest = (event) -> Value.clone event.Records?[0]?.cf?.request

getResponse = (event) -> Value.clone event.Records?[0]?.cf?.response

getURL = (request) ->
  # do ({ scheme, domain, port, target, url } = {}) ->
  do ({ scheme, host, target, url } = {}) ->
    scheme = request.origin.custom.protocol
    # domain = request.origin.custom.domainName
    # port = request.origin.custom.port
    host = getHeader request, "host"
    target = request.uri
    # if port == ""
    #   url = "#{scheme}://#{domain}#{target}"
    # else
    #   url = "#{scheme}://#{domain}:#{port}#{target}"
    url = "#{scheme}://#{host}#{target}"
    ( new URL url ).href

getMethod = (request) ->
  Text.toLowerCase request.method

# TODO set the host header?
setOrigin = Fn.tee (request, value) ->
  request.origin.custom.domainName = value
  setHeader request, "host", value

getHeader = (request, key) ->
  request.headers[ Text.toLowerCase key ]?[0]?.value

setHeader = Fn.tee (request, key, value) ->
  request.headers ?= {}
  request.headers[ key ] ?= []
  request.headers[ key ].push { value }

getHeaders = (request) ->
  do ( { result, key, value } = {}) ->
    result = {}
    for key, values of request.headers
      for { value } in values
        (result[ key ] ?= []).push value
    result

createResponse = ({ status }) ->
  status: status.toString()

getStatus = (response) ->
  Text.parseNumber response.status

setBody = Fn.tee (response, content) ->
  response.body = content
  response.bodyEncoding = "text"


export {
  getRequest
  getResponse
  getURL
  getMethod
  setOrigin
  getHeader
  getHeaders
  setHeader
  createResponse
  getStatus
  setBody
}