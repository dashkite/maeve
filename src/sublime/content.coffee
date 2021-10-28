import * as Fn from "@dashkite/joy/function"
import * as Pred from "@dashkite/joy/predicate"
import * as Type from "@dashkite/joy/type"
import * as Meta from "@dashkite/joy/metaclass"
import { convert, Generic } from "#helpers"

isAny = Fn.wrap true

class Content

  @create: (bytes) ->
    self = new Content
    self._ = bytes
    self

  @from: Generic.create "Content.from"

  Meta.mixin @::, [

    Meta.getters
      json: -> @to "json"

  ]

  to: (format) ->
    if @_?
      convert from: "bytes", to: format, @_

Generic.define Content.from,
  [
    Type.isString
    isAny
  ]
  (format, value) ->
      Content.create convert from: format, to: "bytes", value

Generic.define Content.from,
  [
    Type.isString
  ]
  (value) -> Content.from "utf8", value

Generic.define Content.from,
  [
    Type.isObject
  ]
  (value) -> Content.from "json", value

Generic.define Content.from,
  [
    Pred.any [
      Type.isType Content
      Type.isUndefined
    ]
  ]
  Fn.identity

export { Content }