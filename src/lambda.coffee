import HTTP from "http"
import { Event, Request, Response } from "./event"

Lambda = do ({ server } = {}) ->

  stop: ->
    new Promise (resolve, reject) ->
      try
        server.close -> resolve()
      catch error
        reject error

  start: ( handlers ) ->
    new Promise (resolve, reject) ->
      try
        server = HTTP.createServer (request, response) ->
          try
            normalizedRequest = await Request.from request
            event = Event.from request: normalizedRequest
            result = await Event.dispatch event, handlers.origin.request
            if Event.Request.isType result
              if (result.headers[ "x-api-key" ])?
                { uri, method, headers, content } = Request.from result
                url = "https://#{result.origin.custom.domainName}#{uri}"
                fetchResponse = await fetch url, { method, headers, body: content }
                normalizedResponse = await Response.from fetchResponse
                event = Event.from
                  request: normalizedRequest
                  response: normalizedResponse
                result = await Event.dispatch event, handlers.origin.response
                Event.to response, result
              else
                Event.to response, Request.from status: 502
            else if Event.Response.isType result
              Event.to response, result
            else
              throw new Error "Handler should return a response or request"
          catch error
            console.error error
            Event.to response,
              Request.from status: 503,
              content: error.toString()

        server.listen ->
          { port } = server.address()
          resolve port
      catch error
        reject error

export { Lambda }