import * as Type from "@dashkite/joy/type"
import { Generic } from "#helpers"
import * as Sublime from "../sublime"

isNodeServerRequstContext = (value) ->

isNodeServerResponse = (value) ->

Sublime.Response.send = Generic.create "Sublime.Response.send"

Sublime.Response::send = -> Sublime.Response.send @, arguments...

Generic.define Sublime.Response.send,
  [
    Type.isType Sublime.Response
    isNodeServerResponse
  ]
  (event, response) ->
    response.statusCode = event.response.statusCode
    response.statusMessage = event.response.statusDescription
    response.end (from.content.to "utf8"), "utf8"

