import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Value from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"

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
  request.content

getRequestJSON = (request) ->
  try
    JSON.parse getRequestContent request

export {
  getRequestMethod
  getRequestHeader
  getRequestHeaders
  getRequestContent
  getRequestJSON
}