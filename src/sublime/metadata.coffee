import * as Fn from "@dashkite/joy/function"
import * as Meta from "@dashkite/joy/metaclass"
import * as Type from "@dashkite/joy/type"
import * as Arr from "@dashkite/joy/array"
import * as Text from "@dashkite/joy/text"
import { generic } from "@dashkite/joy/generic"

class Metadata

  @from: (dictionary) ->
    self = new Metadata
    self.append dictionary

  constructor: -> @_ = {}

  Meta.mixin @::, [
    Meta.getters
      dictionary: ->
        result = {}
        for { key, values } from @
          result[ key ] = values[0]
        result
  ]

  set: -> _set @, arguments...

  append:  -> _append @, arguments...

  get: (name) -> Arr.first @getAll name

  getAll: (name) -> @_[ Text.toLowerCase name ] ?= []

  has: (name) -> ( @get name )?

  [ Symbol.iterator ]: -> yield { key, values } for key, values of @_

isMetadata = Type.isType Metadata

_set = generic name: "Sublime.Metadata.set"

generic _set, isMetadata, Type.isString, Type.isArray, Fn.tee (self, name, value) ->
  self._[ Text.toLowerCase name ] = value 

generic _set, isMetadata, Type.isString, Type.isString, Fn.tee (self, name, value) ->
  self.set name, [ value ]

generic _set, isMetadata, Type.isObject, Fn.tee (self, dictionary) ->
  for key, value of dictionary
    self.set key, value

_append = generic name: "Sublime.Metadata.append"

generic _append, isMetadata, Type.isString, Type.isString, Fn.tee (self, name, value) ->
  Arr.push ( self._[ Text.toLowerCase name ] ?= [] ), value

generic _append, isMetadata, Type.isObject, Fn.tee (self, dictionary) ->
  for key, value of dictionary
    _append self, key, value

export { Metadata }
  
