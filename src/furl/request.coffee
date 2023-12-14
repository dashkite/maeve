import { convert } from "@dashkite/bake"
import { MediaType } from "@dashkite/media-type"

getPath = ( request ) -> request.rawPath

getTarget = ( request ) -> 
  "#{ getPath request }#{ getQueryString request }"

getDomain = ( request ) -> request.headers[ "x-forwarded-host" ]

getOrigin = ( request ) -> "https://#{ getDomain request }"

getURL = ( request ) ->
  target = getTarget request
  origin = getOrigin request
  url = new URL target, origin
  url.href

setEntry = ( result, [ key, value ]) ->
  result[ key ] = value
  result

getQueryString = ( request ) ->
  # rawQueryString is never null
  query = if request.rawQueryString.startsWith "?"
    request.rawQueryString[1..]
  else
    request.rawQueryString
  if query == ""
    query
  else "?#{ query }"

getQuery = ( request ) -> 
  Array
    .from do -> 
      ( new URLSearchParams request.rawQueryString ).entries()
    .reduce setEntry, {}

getMethod = ( request ) ->
  request.requestContext.http.method.toLowerCase()

headerMap =
  "x-forwarded-host": "host"
  "x-authorization": "authorization"

getHeaders = ( request ) ->
  Object
    .entries request.headers
    .map ([ key, value ]) ->
      [ ( headerMap[ key ] ? key ), value ]
    .map ([ key, value ]) -> [ key, [ value ]]
    .reduce setEntry, {}

getContent = ( request ) -> request.body

Request =

  to: ( request ) ->
    url: getURL request
    origin: getOrigin request
    domain: getDomain request
    target: getTarget request
    query: getQuery request
    method: getMethod request
    headers: getHeaders request
    content: getContent request

export { Request }
export default { Request }