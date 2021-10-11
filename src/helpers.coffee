fromBase64 = (text) ->
  Buffer.from text, "base64"
    .toString "utf8"

toBase64 = (text) ->
  Buffer.from text, "utf8"
    .toString "base64"

fromEventHeaders = (headers) ->
  result = {}
  for key, values of headers
    if values.length > 1
      result[key] = (value for {value} in values)
    else
      result[key] = values[0].value
  result

toEventHeaders = (headers) ->
  result = {}
  for key, value of headers
    (result[key] ?= []).push { key, value }
  result

read = (stream) ->
  data = ""
  new Promise (resolve, reject) ->
    stream.on "data", (block) -> data += block
    stream.on "end", -> resolve data
    stream.on "error", reject

export {
  fromBase64
  toBase64
  fromEventHeaders
  toEventHeaders
  read
}