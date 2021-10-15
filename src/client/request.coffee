class Request

  @create: ({url, method, headers, content}) ->
    self = new Request
    Object.assign self,
      { url, method, headers, content }

  constructor: -> @_ = {}

  Meta.mixin [

    Meta.properties

      url:
        get: -> @_.url.href
        set: (value) -> @_.url = new URL value, @origin

      scheme:
        get: -> @_.url.protocol

      host:
        get: -> @_.url.hostname

      port:
        get: -> @_.url.port

      origin:
        get: -> @_.url.origin

      target:
        get: -> "#{@_.url.pathname}#{@_.url.search}" 
      
      path:
        get: -> @_.url.pathname
      
      query:
        get: -> @_.url.search[1..]

      parameters:
        get: -> @_.url.searchParams

      method:
        get: -> @_.method
        set: (name) -> @_.method = Text.toLowerCase name

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