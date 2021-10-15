import * as Text from "@dashkite/joy/text"
import * as Arr from "@dashkite/joy/array"
import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"

class Metadata

  @from: (dictionary) ->
    self = new Metadata
    self.append dictionary

  constructor: -> @_ = {}

  set: -> _set @, arguments...

  append:  -> _append @, arguments...

  get: (name) -> Arr.first @getAll name

  getAll: (name) -> @_[ Text.toLowerCase name ] ?= []

  has: (name) -> ( @get name )?

isMetadata = Type.isType Metadata

_set = generic()

generic _set, isMetadata, Type.isString, Type.isString, Fn.tee (self, name, value) ->
  self._[ Text.toLowerCase name ] = [ value ]

generic _set, isMetadata, Type.isObject, Fn.tee (self, dictionary) ->
  for key, value of dictionary
    self.set key, value

_append = generic()

generic _append, isMetadata, Type.isString, Type.isString, Fn.tee (self, name, value) ->
  Arr.push ( self._[ Text.toLowerCase name ] ?= [] ), value

generic _append, isMetadata, Type.isObject, Fn.tee (self, dictionary) ->
  for key, value of dictionary
    self.append key, value

export { Metadata }
  
