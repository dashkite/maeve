import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Sublime from "../sublime"
import * as Lambda from "../lambda"
import { Generic } from "#helpers"

# Create Sublime Request from Lambda Event
Generic.define Sublime.Request.from,
  [
    Type.isType Lambda.Event
  ]
  (event) ->

# Create Sublime Response from Lambda Event
Generic.define Sublime.Response.from,
  [
    Type.isType Lambda.Event
  ]
  (event) ->

Generic.define Lambda.Request.update,
  [
    Type.isType Lambda.Request
    Type.isType Sublime.Request
  ]
  Fn.tee (to, from) ->
    to.uri = from.target
    to.method = from.method
    to.headers = Lamba.Event.Headers.from from.headers
    to.body = if from.content?
      inputTruncated: false
      action: "read-only"
      encoding: "base64"
      data: from.content.to "base64"

Generic.define Lambda.Response.update,
  [
    Type.isType Lambda.Response
    Type.isType Sublime.Response
  ]
  Fn.tee (to, from) ->
    to.status = from.status.toString()
    to.statusDescription = from.description
    to.headers = Lambda.Event.Headers.from from.headers

