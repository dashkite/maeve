import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import * as $ from "../src"

do ->

  print await test "Maeve", [

    test "Event", [

      test "from", ->

        event = $.Event.from
          request:
            url: "https://example.org/"
            method: "get"
            headers: {}
        
        assert $.Event.isType event
        assert event.Records[0].cf.request?
        assert.equal "/", event.Records[0].cf.request.uri
        assert.equal "GET", event.Records[0].cf.request.method

      test "dispatch", ->

        handler = (event, context, callback) ->
          callback null, $.Event.Request.from event

        event = $.Event.from
          request:
            url: "https://example.org/"
            method: "get"
            headers: {}

        result = $.Event.dispatch event, handler
        assert _.isPromise result
        request = await result
        assert request.uri?

      test "Request", [

        test "from", [

          test "normalized request", ->

            request = $.Event.Request.from
              url: "https://example.org/"
              method: "get"
              headers:
                "content-type": "application/json"
              content: foo: "bar"
            
            assert.equal "/", request.uri
            assert.equal "GET", request.method
            assert request.headers["content-type"]?[0]?.value?
            assert.equal "application/json",
              request.headers["content-type"]?[0]?.value
            assert.equal "base64", request.body.encoding
            assert request.body.data?

          test "event", ->

            event = $.Event.from
              request:
                url: "https://example.org/"
                method: "get"
                headers: {}
            
            request = $.Event.Request.from event

            assert.equal "/", request.uri

        ]

      ]

      test "Response", [

        test "from", [

          test "normalized response", ->

            response = $.Event.Response.from
              status: "200"
              headers:
                "content-type": "application/json"
            
            assert.equal "200", response.status
            assert.equal "OK", response.statusDescription
            assert response.headers["content-type"]?[0]?.value?
            assert.equal "application/json",
              response.headers["content-type"]?[0]?.value

          test "event"

        ]

      ]


    ]

    test "Request", [

        test "from", [

          test "description"

          test "event"
        
        ]
   
    ]

    test "Response", [

        test "from", [

          test "description"

          test "event"
        
        ]
    ]

  ]

  process.exit success