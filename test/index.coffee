import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import * as ALB from "../src/alb"
import * as Edge from "../src/edge"

import albRequest from "./data/alb-request"
import albResponse from "./data/alb-response"
import edgeRequestEvent from "./data/edge-request-event"
import edgeResponseEvent from "./data/edge-response-event"

do ->

  print await test "Maeve", [

    test "ALB adapters", [

      test "getNormalizedRequest", ->

        request = ALB.getNormalizedRequest albRequest
        assert.equal "/lambda?query=1234ABCD", request.target
        assert.equal "get", request.method
        assert.equal "gzip", request.headers["accept-encoding"][0]

      test "getDenormalizedResponse", ->
        response = ALB.getDenormalizedResponse
          status: 200
          description: "200 OK"
          headers:
            "content-type": [ "text/html" ]
          content: "<h1>Hello from Lambda!</h1>"
        assert.deepEqual albResponse, response

    ]

    test "Edge Adapters", [

      test "getRequest", ->
        request = Edge.getRequest edgeRequestEvent
        assert.equal "GET", request.method
        assert.equal "/", request.uri
      
      test "getResponse", ->
        request = Edge.getResponse edgeResponseEvent
        assert.equal "200", request.status
      
      test "getURL", ->
        request = Edge.getRequest edgeRequestEvent
        assert.equal "https://account-development.dashkite.io/",
          Edge.getURL request

      test "getMethod", ->
        request = Edge.getRequest edgeRequestEvent
        assert.equal "get", Edge.getMethod request
      
      test "setHeader", ->
        request = Edge.getRequest edgeRequestEvent
        Edge.setHeader request, "x-api-key", "12345"
        assert.equal "12345", request.headers["x-api-key"][0]?.value

      test "getHeaders", ->
        request = Edge.getRequest edgeRequestEvent
        headers = Edge.getHeaders request
        assert.equal "Amazon CloudFront",
          headers?[ "user-agent" ]?[0]

      test "setOrigin", ->
        request = Edge.getRequest edgeRequestEvent
        Edge.setOrigin request, "alb-account-development-api.dashkite.com"
        assert.equal "alb-account-development-api.dashkite.com",
          request.origin.custom.domainName

      test "createResponse", ->
        response = Edge.createResponse status: 404
        assert.equal "404", response.status

      test "setStatus", ->
        response = Edge.getResponse edgeResponseEvent
        assert.equal 200, Edge.getStatus response
      
      test "setBody", ->
        response = Edge.getResponse edgeResponseEvent
        Edge.setBody response, "hello world"
        assert.equal "hello world", response.body
        assert.equal "text", response.bodyEncoding
      
      test "setHeader", ->
        response = Edge.getResponse edgeResponseEvent
        Edge.setHeader response, "grants", "12345"
        assert.equal "12345", response.headers["grants"][0]?.value

    ]

  ]

  process.exit success