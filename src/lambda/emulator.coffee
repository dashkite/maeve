import HTTP from "http"
import { Event } from "./event"
import { Sublime } from "../sublime"

Lambda = do ({ server } = {}) ->

  stop: ->
    new Promise (resolve, reject) ->
      try
        server.close -> resolve()
      catch error
        reject error

  start: ( handlers, origin ) ->
    new Promise (resolve, reject) ->
      try
        server = HTTP.createServer (request, response) ->
          try
            event = Event.from { server, request }
            result = await event.dispatch handlers.origin.request
            if Type.isType Event.Request, result
              await result.fetch()
              await event.dispatch handlers.origin.response
              event.to response
            else if Type.isType Event.Response, result
              event.to result
            else
              throw new Error "Handler should return a response or request"
          catch error
            console.error error
            response.status = 503
            response.write error.toString(), "utf8"

        server.listen ->
          { port } = server.address()
          resolve port
      catch error
        reject error

export { Lambda }