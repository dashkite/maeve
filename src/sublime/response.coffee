import * as Type from "@dashkite/joy/type"
import * as Meta from "@dashkite/joy/metaclass"
import { convert } from "#helpers"
import { Metadata } from "./metadata"
import { Content } from "./content"
import { getReasonPhrase } from "http-status-codes"

class Response

  @create: ({request, status, description, headers, trailers, content}) ->
    self = new Response
    Object.assign self,
      { request, status, description, headers, trailers, content }
    self

  constructor: -> @_ = {}

  Meta.mixin @::, [

    Meta.properties

      request:
        get: -> @_.request
        set: (request) -> @_.request = request
      
      status:
        get: -> @_.status
        set: (status) -> 
          @_.description = getReasonPhrase status.toString()
          @_.status = status

      description:
        get: -> @_.description ?= getReasonPhrase @status
        set: (value) -> @_.description = value

      headers:
        get: -> @_.headers ?= new Metadata
        set: (headers) ->
          if Type.isType Metadata, headers
            @_.headers = headers
          else
            @headers.append headers
      
      trailers:
        get: -> @_.trailers ?= new Metadata
        set: (trailers) -> @_.trailers = trailers

      content:
        get: -> @_.content
        set: (value) -> @_.content = Content.from value
      
      dictionary:
        get: ->
          {
            @status
            @description
            headers: @headers.dictionary
            content: @content.to "utf8"
            trailers: @trailers.dictionary
          }


  ]

  send: (response) ->
    response.statusCode = @status
    response.statusMessage = @description
    response.end (@content.to "utf8"), "utf8"

export { Response }