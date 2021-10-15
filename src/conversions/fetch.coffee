import * as Sublime from "../sublime"
import * as Lambda from "../lambda"
import { Generic } from "#helpers"

isFetchRequest = (value) ->

Lambda.Request::fetch = ->

              # { target, method, headers, content } = Request.from result
              # fetchResponse = await fetch (new URL target, origin), 
              #   { method, headers, body: content }

Generic.define Sublime.Response.from,
  [ isFetchRequest ]
  (request) ->

