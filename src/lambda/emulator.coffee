import HTTP from "http"
import * as Type from "@dashkite/joy/type"
import * as Sublime from "../sublime"
import * as Node from "../node"

Emulator = do ({ server } = {}) ->

  stop: ->
    new Promise (resolve, reject) ->
      try
        server.close -> resolve()
      catch error
        reject error

  start: ( handlers, configuration ) ->
    new Promise (resolve, reject) ->
      try
        server = HTTP.createServer (request, response) ->
          try
            context = await Node.Context.create { server, request, response }
            domain = context.request.domain
            result = await handlers.origin.request context
            if Type.isType Sublime.Request, result
              if ( domain == result.domain )
                _request = result.clone()
                _request.domain = configuration.domain
                _request.headers.set "host", configuration.domain
                _request.scheme = "https"
                _request.port = 443
              result = await _request.fetch()
              if 200 <= result.status < 300
                context.response = result
                result = await handlers.origin.response context
                result.send response
              else
                result.send response
            else if Type.isType Sublime.Response, result
              result.send response
            else
              result = Sublime.Response.create result
              result.send response
          catch error
            console.error error
            response.status = 503
            response.write error.toString(), "utf8"

        server.listen configuration.port, ->
          { port } = server.address()
          resolve port
      catch error
        reject error

export { Emulator }