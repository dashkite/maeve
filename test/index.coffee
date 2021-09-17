import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import fetch from "node-fetch" 
import * as $ from "../src"
import handlers from "./handlers"

# start server with config
$.start { handlers }, ( server ) ->

  { port } = server.address()

  print await test "Edge Lambda Simulator", [

    test "origin request", ->
      fetch "http://localhost:#{port}/"

  ]

  process.exit success