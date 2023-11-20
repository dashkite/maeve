import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import * as ALB from "../src/alb"
import * as Edge from "../src/edge"
import * as Sublime from "../src/sublime"

import albRequest from "./data/alb/request"
import albResponse from "./data/alb/response"
import edgeRequestEvent from "./data/edge/request"
import edgeResponseEvent from "./data/edge/response"
import furlRequest from "./data/furl/request"
import furlResponse from "./data/furl/response"

import scenarios from "./scenarios"

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
        assert.equal "/lambda", request.uri
      
      test "getResponse", ->
        request = Edge.getResponse edgeResponseEvent
        assert.equal "200", request.status
      
      test "getRequestURL", ->
        request = Edge.getRequest edgeRequestEvent
        assert.equal "https://account-development.dashkite.io/lambda?query=12345",
          Edge.getRequestURL request

      test "getRequestTarget", ->
        request = Edge.getRequest edgeRequestEvent
        assert.equal "/lambda?query=12345",
          Edge.getRequestTarget request

      test "getRequestMethod", ->
        request = Edge.getRequest edgeRequestEvent
        assert.equal "get", Edge.getRequestMethod request
      
      test "setRequestHeader", ->
        request = Edge.getRequest edgeRequestEvent
        Edge.setRequestHeader request, "x-api-key", "12345"
        assert.equal "12345", request.headers["x-api-key"][0]?.value

      test "getRequestHeader", ->
        request = Edge.getRequest edgeRequestEvent
        value = Edge.getRequestHeader request, "user-agent"
        assert.equal "Amazon CloudFront", value

      test "getRequestHeaders", ->
        request = Edge.getRequest edgeRequestEvent
        headers = Edge.getRequestHeaders request
        assert.equal "Amazon CloudFront",
          headers?[ "user-agent" ]?[0]

      test "setRequestOrigin", ->
        request = Edge.getRequest edgeRequestEvent
        Edge.setRequestOrigin request, "alb-account-development-api.dashkite.com"
        assert.equal "alb-account-development-api.dashkite.com",
          request.origin.custom.domainName

      test "getResponseStatusCode", ->
        response = Edge.getResponse edgeResponseEvent
        assert.equal 200, Edge.getResponseStatusCode response
      
      test "setResponseBody", ->
        response = Edge.getResponse edgeResponseEvent
        Edge.setResponseBody response, content: "hello world"
        assert.equal "hello world", response.body
      
      test "setResponseBodyEncoding", ->
        response = Edge.getResponse edgeResponseEvent
        Edge.setResponseBodyEncoding response, encoding: "base64"
        assert.equal "base64", response.bodyEncoding

      test "setResponseHeader", ->
        response = Edge.getResponse edgeResponseEvent
        Edge.setResponseHeader response, "grants", "12345"
        assert.equal "12345", response.headers["grants"][0]?.value

      test "setResponseStatusCode", ->
        response = Edge.getResponse edgeResponseEvent
        Edge.setResponseStatusCode response, status: 200
        assert.equal "200", response.status


    ]

    test "Sublime", [

      test "request generic", do ->
      
        runner = ( scenario ) -> ->
          request = Sublime.request scenario.argument
          assert.deepEqual scenario.result, request

        for scenario in scenarios.sublime.request
          test scenario.name, runner scenario        

      test "response generic", do ->

        runner = ( scenario ) -> ->
          response = Sublime.response scenario.argument
          assert.deepEqual scenario.result, response

        for scenario in scenarios.sublime.response
          test scenario.name, runner scenario
          
    
    ]

    test "Furl", [

      test "request to Sublime", ->
        assert.deepEqual scenarios.furl.request[0].request,
          Sublime.Request.from "furl", furlRequest

      test "Sublime to response", ->
        assert.deepEqual furlResponse,
          Sublime.Response.to "furl",
            scenarios.furl.response[0].response

    ]

  ]

  process.exit ( if success then 0 else 1 )