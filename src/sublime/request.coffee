import * as Type from "@dashkite/joy/type"
import * as Meta from "@dashkite/joy/metaclass"
import * as Text from "@dashkite/joy/text"
import { Generic } from "#helpers"
import { Metadata } from "./metadata"
import { Response } from "./response"
import { Content } from "./content"
import { url as buildURL } from "./url"

class Request

  @create: ({url, method, headers, content, trailers}) ->
    self = new Request
    Object.assign self,
      { url, method, headers, content }

  @from: Generic.create "Sublime.Request.from"

  constructor: -> @_ = {}

  Meta.mixin @::, [

    Meta.properties

      url:
        get: -> @_.url.href
        set: (value) -> @_.url = new URL value, @origin

      base:
        get: -> "#{@scheme}://#{@address}"
        set: (value) -> @_.url = new URL @target, value

      scheme:
        get: -> @_.url.protocol[...-1]
        set: (scheme) ->
          @_.url = buildURL { scheme, @domain, @port, @target }

      address:
        get: -> @_.url.host

      port:
        get: ->
          if @_.url.port == ""
            switch @scheme
              when "https" then 443
              when "http" then 80
              else throw new Error "Unable to infer port number for #{@scheme}"
          else
            Text.parseNumber @_.url.port
        set: (port) ->
          @_.url = buildURL { @scheme, @domain, port, @target }

      origin:
        get: -> @_.url?.origin

      domain:
        get: -> @_.url?.hostname
        set: (domain) ->
          @_.url = buildURL { @scheme, domain, @port, @target }
          @_.url.domain

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
            @url
            @method
            headers: @headers.dictionary
            content: @content.to "utf8"
            trailers: @trailers.dictionary
          }

  ]

  clone: ->
    Request.create { @url, @method, @headers, @content, @trailers }

  fetch: ->
    if @method != "get" && @method != "head"
      # this should be inferred from content-type?
      body = @content.to "utf8"
    response = await fetch @url, { @method, headers: @headers.dictionary, body, mode: "cors" }
    Response.create
      request: @
      status: response.status
      description: response.statusText
      headers: do ->
        headers = new Metadata
        for [ key, values ] from response.headers
          for value in Text.split ",", values
            headers.append key, Text.trim value
        headers
      content: await do ->
        length = Text.parseNumber response.headers.get "content-length"
        if length > 0
          Content.create new Uint8Array await response.arrayBuffer()

export { Request }