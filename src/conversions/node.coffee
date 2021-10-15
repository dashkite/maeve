import * as Type from "@dashkite/joy/type"
import { Generic } from "#helpers"
import * as Lambda from "../lambda"

isNodeServerRequstContext = (value) ->
isNodeServerResponse = (value) ->

Generic.define Lambda.Event.from,
  [
    isNodeServerRequstContext
  ]
  ({server, request}) ->
    event = new Lambda.Event
    event._ = Records: [
      cf:
        # TODO do we need to mock config?
        config: {}
        request: do ->
          scheme = "http"
          port = server.address().port
          host = "localhost"
          headers = Lambda.Event.Headers.from request.headers
          headers.host = [ key: "host", value: host ]
          url = new URL request.url, "#{scheme}://#{host}:#{port}"

          clientIp: "127.0.0.1"
          uri: url.pathname
          querystring: url.search[1..]
          method: Text.toUpperCase request.method
          headers: headers
          origin:
            custom:
              customHeaders: {}
              domainName: request.host,
              keepaliveTimeout: 60,
              path: request.target,
              port: request.port
              protocol: request.scheme
              readTimeout: 60,
              sslProtocols: []
          ]

Generic.define Lambda.Event.to,
  [
    Type.isType Lambda.Event
    isNodeServerResponse
  ]
  (event, response) ->
    response.statusCode = event.response.statusCode
    response.statusMessage = event.response.statusDescription
    response.end (from.content.to "utf8"), "utf8"

