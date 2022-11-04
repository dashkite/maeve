import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import status from "statuses"

Response =

  Status:

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

    set: generic
      name: "Response.Headers.set"
      description: "Set Sublime header"
      [
        [ 
          [ Type.isObject, Type.isString, Type.isString ]
          ( response, key, value ) -> 
            Response.Headers.set response, key, [ value ]
        ]
        [ 
          [ Type.isObject, Type.isString, Type.isInteger ]
          ( response, key, value ) -> 
            Response.Headers.set response, key, value.toString()
        ]
        [ 
          [ Type.isObject, Type.isString, Type.isArray ]
          ( response, key, values ) ->
            Object.assign response.headers, [ key ]: values
        ]
        [ 
          [ Type.isObject, Type.isObject ]
          ( response, headers ) ->
            for key, value of headers
              Response.Headers.set response, key, value
        ]
        [ 
          [ Type.isObject, Type.isFunction ]
          ( response, setter ) -> setter response.headers
        ]
      ]

    append: generic
      name: "Response.Headers.append"
      description: "Append to Sublime header"
      [
        [ 
          [ Type.isObject, Type.isString, Type.isString ]
          ( response, key, value ) ->
            response.headers ?= {}
            response.headers[ key ] ?= []
            response.headers[ key ].push value
        ]
        [ 
          [ Type.isObject, Type.isString, Type.isInteger ]
          ( response, key, value ) -> 
            Response.Headers.append response, key, value.toString()
        ]
        [ 
          [ Type.isObject, Type.isString, Type.isArray ]
          ( response, key, values ) ->
            for value in values
              Response.Headers.append response, key, value
        ]
        [ 
          [ Type.isObject, Type.isObject ]
          ( response, headers ) ->
            for key, value of headers
              Response.Headers.append response, key, value
        ]
      ]

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
    convert from: format, to: "sublime"

  to: ( format, response ) -> 
    convert from: "sublime", to: format

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
