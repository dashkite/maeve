import { convert } from "@dashkite/bake"
import { MediaType } from "@dashkite/media-type"
import * as Sublime from "#sublime"

headerCase = (name) ->
  name
    .replace /^[A-Za-z]/, (c) -> R.toUpperCase()
    .replace /\-[A-Za-z]/, (c) -> R.toUpperCase()

setEntry = ( result, [ key, value ]) ->
  result[ key ] = value ; result

getHeaders = ( response ) ->
  Object
    .entries response.headers
    .map ([ key, values ]) ->
      [ ( headerCase key ), values[0] ]
    .reduce setEntry, {}

getBody = ( response ) ->
  switch MediaType.infer response.content
    when "text" then response.content
    when "binary"
      convert from: "bytes", to: "base64", response.content
    when "json"
      JSON.stringify response.content

getIsBase64Encoded = ( response ) ->
  switch MediaType.infer response.content
    when "text", "json" then false
    else true

Response = 
  from: ( response ) ->
    response = Sublime.response response
    statusCode: response.status
    headers: getHeaders response
    body: getBody response
    isBase64Encoded: getIsBase64Encoded response

export { Response }