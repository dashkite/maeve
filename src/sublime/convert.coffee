Conversions = {}

register = ( description, handler ) ->
  Conversions[ description.type ] ?= {}
  Conversions[ description.type ][ description.from ] ?= {}
  Conversions[ description.type ][ description.from ][ description.to ] = handler

convert = ( description, value ) ->
  handler = Conversions[ description.type ]?[ description.from ]?[ description.to ]
  if handler?
    handler value
  else
    throw new Error "Sublime.convert: 
      no conversion defined for
      type [ #{ description.type } ]
      from [ #{ description.from } ]
      to [ #{ description.to } ]"

export { register, convert }