import { register } from "../convert"
import { Headers } from "node-fetch"

# convert Sublime headers to browser fetch headers
Fetch = 
  Headers:
    from: ( headers ) ->
      result = new Headers
      for key, values of headers
        for value in values
          result.append key, value
      result

    # TODO define to sublime headers from fetch headers    
    # to: ( headers ) ->

# TODO define fetch response to sublime response
# register 
#   type: "response"
#   from: "fetch"
#   to: "sublime"
#   ( response ) ->

register
  type: "request"
  from: "sublime"
  to: "fetch"
  ( request ) ->
    result = new Request request.url,
      if response.content?
        method: request.method
        headers: Fetch.Headers.from request.headers
        body: response.content
      else
        method: request.method
        headers: Fetch.Headers.from request.headers
