# read = (stream) ->
#   data = ""
#   new Promise (resolve, reject) ->
#     stream.on "data", (block) -> data += block
#     stream.on "end", -> resolve data
#     stream.on "error", reject
import { generic } from "@dashkite/joy/generic"

Generic =
  create: generic
  define: (g, predicates, f) -> generic g, predicates..., f

export { Generic }