import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import { Lambda, Sublime } from "../src"
import * as Node from "@dashkite/maeve/node"
import "@dashkite/maeve/lambda/emulator"

import requestEvent from "./data/events/origin/request"
import responseEvent from "./data/events/origin/response"

import fetch from "node-fetch"

globalThis.fetch ?= fetch
globalThis.Headers ?= fetch.Headers

do ->

  print await test "Maeve", [

    test "Lambda", [

      test "Adapter", [

        test "Conversions", [

          test "From Lambda Event...", [

            test "...Request to Sublime Request", ->

              { request  } = Lambda.Event.from requestEvent
              assert request?
              assert.equal "https://example.org/", request.url
              assert.equal "example.org", request.domain
              assert.equal "/", request.target
              assert.equal "get", request.method
              assert.equal "Amazon CloudFront", request.headers.get "user-agent"

            test "...Response to Sublime Response", ->

              { response  } = Lambda.Event.from responseEvent
              assert response?
              assert.equal 200, response.status
              assert.equal "text/html; charset=utf-8",
                response.headers.get "content-type"

          ]


          test "Update Lambda Event...", [
            
            test "...Request from Sublime Request", ->
              
              event = Lambda.Event.from requestEvent
              { request } = event
              request.headers.set "x-api-key", "12345"
              request.domain = "proxy.example.org"
              result = event.apply request
              assert.equal "12345", result.headers[ "x-api-key" ][0].value
              assert.equal "proxy.example.org", result.origin.custom.domainName

            test "...Response from Sublime Response", ->
      
              event = Lambda.Event.from responseEvent
              { response } = event
              response.status = 401
              result = event.apply response
              assert.equal "401", result.status
              assert.equal "Unauthorized", result.statusDescription

          ]

        ]

      ]

      test "Emulator", [

        test "Conversions", [

          test "From Node Server request context to Sublime Context"

          test "Sublime Request to Fetch", ->

            request = Sublime.Request.create
              url: "https://httpbin.org/get?greeting=hello%20world"
              method: "get"
              headers:
                accept: "application/json"
            
            response = await request.fetch()
            assert.equal 200, response.status
            assert.equal "hello world", response.content.json.args.greeting
            assert.equal "application/json", response.headers.dictionary["content-type"]

          test "Sublime Response to Node ServerResponse"

        ]

      ]

    ]

    test "Sublime", [
  
    ]

  ]

  process.exit success