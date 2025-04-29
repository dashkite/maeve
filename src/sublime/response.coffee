import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import status from "statuses"
import { convert } from "./convert"

Response =

  Status:

    ok: ( response ) ->
      Response.Status.resolve response
      200 <= response.status < 300

    resolve: Fn.tee ( response ) ->
      if response.status?
        response.description = Text.toLowerCase status response.status
      else if response.description?
        response.status = status response.description
      else if response.content?
        Object.assign response,
          status: 200
          description: "ok"
      else
        Object.assign response,
          status: 204
          description: "no content"

  Headers:

    initialize: Fn.tee ( response ) ->
      response.headers ?= {}

    get: ( response, name ) ->
      response.headers?[ name ]?.join ", "

    remove: ( response, name ) ->
      delete response.headers[ name ]

    set: generic
      name: "Response.Headers.set"
      description: "Set Sublime header"

    append: generic
      name: "Response.Headers.append"
      description: "Append to Sublime header"

  Content:

    normalize: Fn.tee ( response ) ->
      if response.status == 204
        Response.Content.remove response
      else if response.content? 
        if Type.isString response.content
          Response.Headers.set response,
            "content-length", response.content.length
          Response.Headers.set response, ( headers ) ->
            headers[ "content-type" ] ?= [ "text/plain" ]
        else
          Response.Headers.set response, ( headers ) ->
            headers[ "content-type" ] ?= [ "application/json" ]

    remove: Fn.tee ( response ) ->
      delete response.content
      for key, value of response.headers
        if key.startsWith "content-"
          delete response.headers[ key ]
      response.description = "no content"
      response.status = 204

  from: ( format, request ) ->
    convert type: "response", from: format, to: "sublime", request

  to: ( format, response ) -> 
    convert type: "response", from: "sublime", to: format, response

# set header

generic Response.Headers.set,
  Type.isObject, Type.isString, Type.isUndefined, ->

generic Response.Headers.set,
  Type.isObject, Type.isString, Type.isString,
  ( response, key, value ) -> 
    Response.Headers.set response, key, [ value ]

generic Response.Headers.set,
  Type.isObject, Type.isString, Type.isInteger,
  ( response, key, value ) -> 
    Response.Headers.set response, key, value.toString()

generic Response.Headers.set,
  Type.isObject, Type.isString, Type.isArray,
  ( response, key, values ) ->
    response.headers ?= {}
    Object.assign response.headers, [ key ]: values

generic Response.Headers.set,
  Type.isObject, Type.isObject,
  ( response, headers ) ->
    for key, value of headers
      Response.Headers.set response, key, value

generic Response.Headers.set,
  Type.isObject, Type.isFunction,
  ( response, setter ) -> 
    response.headers ?= {}
    setter response.headers


# append header

generic Response.Headers.append,
  Type.isObject, Type.isString, Type.isUndefined, ->

generic Response.Headers.append,
  Type.isObject, Type.isString, Type.isString,
  ( response, key, value ) ->
    response.headers ?= {}
    response.headers[ key ] ?= []
    response.headers[ key ].push value

generic Response.Headers.append,
  Type.isObject, Type.isString, Type.isInteger,
  ( response, key, value ) -> 
    Response.Headers.append response, key, value.toString()

generic Response.Headers.append,
  Type.isObject, Type.isString, Type.isArray,
  ( response, key, values ) ->
    for value in values
      Response.Headers.append response, key, value

generic Response.Headers.append,
  Type.isObject, Type.isObject,
  ( response, headers ) ->
    for key, value of headers
      Response.Headers.append response, key, value

response = generic
  name: "response"
  description: "Construct a Sublime response object"

generic response, Type.isDefined, Fn.pipe [
  Response.Status.resolve
  Response.Headers.initialize
  Response.Content.normalize
]

generic response, Type.isInteger, ( status ) ->
  response { status }

generic response, Type.isString, ( description ) ->
  response { description }

export {
  Response
  response
}
