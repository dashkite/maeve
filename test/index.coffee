import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import * as $ from "../src"
import "@dashkite/maeve/conversions/fetch"
import "@dashkite/maeve/conversions/lambda"
import "@dashkite/maeve/conversions/node"
import "@dashkite/maeve/lambda/emulator"


do ->

  print await test "Maeve", [

    test "Lambda", [

    ]

    test "Sublime", [
  
    ]

    test "Conversions", [

      test "From Lambda Event to Sublime Request"

      test "Update Lambda Event Request from Sublime Request"

      test "Update Lambda Event Response from Sublime Response"

      test "Create Lambda Event from a Node server request context"

      test "Send Node response based on Event"

      test "Issue Fetch request from a Lambda Event"

    ]

  ]

  process.exit success