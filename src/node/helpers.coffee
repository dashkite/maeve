import * as Text from "@dashkite/joy/text"
import * as Sublime from "#sublime"

read = (stream) ->
  data = ""
  new Promise (resolve, reject) ->
    stream.on "data", (block) -> data += block
    stream.on "end", -> resolve data
    stream.on "error", reject

buildHeaders = (headers) ->
  result = new Sublime.Metadata
  for key, value of headers
    result.set key, value
  result

buildRequest = ({ request }) ->
  port = request.socket.address().port
  Sublime.Request.create
    # we know this is HTTP because we're running locally
    # TODO detect dynamically for use in other contexts
    url: Sublime.url
      scheme: "http"
      domain: "localhost"
      port: port
      target: request.url
    method: request.method
    headers: buildHeaders request.headers
    content: if ( Text.parseNumber request.headers["content-length"] ) > 0
      await read request

buildResponse = ({ response }) -> new Sublime.Response

export {
  buildRequest
  buildResponse
}