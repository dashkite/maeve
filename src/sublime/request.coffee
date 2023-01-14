import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import { convert } from "./convert"

Request =

  URL:

    normalize: Fn.tee ( request ) ->
      url = new URL request.url
      { origin, hostname, pathname, search } = url
      Object.assign request,
        { origin, domain: hostname, target: pathname + search }
  
  Headers:
    
    get: ( request, name ) ->
      request.headers?[ name ]?.join ", "

  from: ( format, request ) ->
    convert type: "request", from: format, to: "sublime", request
  
  to: ( format, request ) ->
    convert type: "request", from: "sublime", to: format, request

request = Fn.pipe [
  Request.URL.normalize
]

export {
  Request
  request
}
