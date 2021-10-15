import * as Meta from "@dashkite/joy/metaclass"
import { Generic } from "#helpers"

class Response

  @create: ({request, status, headers, content}) ->
    self = new Response
    Object.assign self,
      { request, status, headers, content }

  @from: Generic.create()

  constructor: -> @_ = {}

  Meta.mixin [

    Meta.properties

      request:
        get: -> @_.request
        set: (request) -> @_.request = request
      
      status:
        get: -> @_.status
        set: (status) -> @_.status = request

      description:
        get: -> @_.description ?= getReasonPhrase @status
        set: (value) -> @_.description = value

      headers:
        get: -> @_.headers
        set: (dictionary = {}) ->
          @_.headers ?= new Metadata
          @_.headers.set dictionary
      
      trailers:
        get: -> @_.trailers
        set: (dictionary = {}) ->
          @_.trailers ?= new Metadata
          @_.trailers.set dictionary
      
  ]

export { Response }