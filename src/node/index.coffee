import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import * as Sublime from "#sublime"
import { Generic } from "#helpers"
import { buildRequest, buildResponse, buildEventHeaders } from "./helpers"

class Context

  @create: ({ server, request, response }) ->
    self = new Context
    self._ =  { server, request, response }
    self.request = await buildRequest self._
    self.response = buildResponse self._
    self

export { Context }