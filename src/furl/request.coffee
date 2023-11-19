import { convert } from "@dashkite/bake"
import { MediaType } from "@dashkite/media-type"

getTarget = ( request ) -> request.rawPath
getDomain = ( request ) -> request.headers[ "x-forwarded-host" ]
getOrigin = ( request ) -> "https://#{ getDomain request }"

getURL = ( request ) ->
  target = getTarget request
  query = request.rawQueryString
  origin = getOrigin request
  "#{ origin }#{ target }#{ query }"

setEntry = ( result, [ key, value ]) ->
  result[ key ] = value
  result

getQuery = ( request ) -> 
  Array
    .from do -> 
      ( new URLSearchParams request.rawQueryString ).entries()
    .reduce setEntry, {}

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

getRequestBody = (request) ->
  if request.body?.encoding == "base64"
    convert from: "base64", to: "utf8", request.body.data
  else
    request.body?.data

isJSON = ( request ) ->
  ( type = request.headers["content-type"])? &&
      ( "json" == MediaType.category type )

getRequestContent = (request) ->
  if request.body?
    if request.isBase64Encoded
      convert from: "base64", to: "utf8", request.body
    else
      if isJSON request
        JSON.parse request.body
      else request.body

Request =

  convert: ( request ) ->
    url: getURL request
    origin: getOrigin request
    domain: getDomain request
    target: getTarget request
    query: getQuery request
    headers: getHeaders request
    content: getContent request

export { Request }
export default { Request }