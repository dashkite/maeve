import { Generic } from "#helpers"

Headers =
  from: Generic.create()

export { Headers }

# fromEventHeaders = (headers) ->
#   result = {}
#   for key, values of headers
#     if values.length > 1
#       result[key] = (value for {value} in values)
#     else
#       result[key] = values[0].value
#   result

# toEventHeaders = (headers) ->
#   result = {}
#   for key, value of headers
#     (result[key] ?= []).push { key, value }
#   result

# export {
#   fromEventHeaders
#   toEventHeaders
# }