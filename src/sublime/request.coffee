import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import status from "statuses"
import { convert } from "../convert"

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
    convert from: format, to: "sublime"
  
  to: ( format, request ) ->
    convert from: "sublime", to: format

request = Fn.pipe [
  Request.URL.normalize
]

export {
  Request
  request
}
