import * as Text from "@dashkite/joy/text"
import * as Sublime from "#sublime"

buildHeaders = (headers) ->
  result = new Sublime.Metadata
  for key, entries of headers
    for entry in entries
      result.append key, entry.value
  result

buildEventHeaders = (headers) ->
  result = {}
  for { key, values } from headers
    result[ key ] = []
    for value in values
      result[ key ].push { key, value }
  result

# build a sublime request from a lambda event request
buildRequest = (request) ->
  Sublime.Request.create
    url: do ->
      scheme = request.origin.custom.protocol
      host = request.origin.custom.domainName
      port = request.origin.custom.port
      base = "#{scheme}://#{host}:#{port}"
      target = if request.querystring? && request.querystring != ""
        "#{request.uri}?#{request.querystring}"
      else
        request.uri
      "#{base}#{target}"
    method: request.method
    headers: buildHeaders request.headers
    content: do ->
      if request.body?.data?
        switch request.body.encoding
          when "base64"
            Sublime.Content.from "base64", request.body.data
          when "text"
            Sublime.Content.from "utf8", request.body.data

buildResponse = (response) ->
  Sublime.Response.create
    status: Text.parseNumber response.status
    headers: buildHeaders response.headers

export {
  buildRequest
  buildResponse
  buildEventHeaders
}