import HTTP from "http"

# assumes a UTF8 stream
read = (stream) ->
  new Promise (resolve, reject) ->
    result = undefined
    stream.on "data", (data) ->
      result ?= ""
      result += result
    stream.on "end", ->
      resolve result
    stream.on "error", (error) ->
      reject error

base64 = (text) -> ( Buffer.from text ).toString "base64"

id = 0
event = (type, request) ->

  url = new URL request.url, "http://#{request.headers.host}"

  headers = {}
  for key, value in request.headers
    (headers[key] ?= []).push { key, value }
  
  if ( _body = await read request )?
    body = 
      inputTruncated: false
      action: "read-only"
      encoding: "base64"
      body: base64 _body

  Records:
    cf:
      config:
        distributionDomainName: "test distribution"
        distributionId: "test-distribution-id"
        eventType: type
        requestId: id++
      request:
        clientIp: "127.0.0.1"
        headers: headers
        method: request.method
        querystring: url.search # url.search[1..]
        uri: url.pathname
        body: body

start = (options, f) ->

  server = HTTP.createServer ( request, response ) ->
    event = await event "origin-request", request
    # provide a faux context
    context = {}
    callback = (error, result) ->
      # fake this out for now, should reference result
      response.writeHead 200
      response.end()
    options.handlers.origin.request event, context, callback

  server.listen ( options.port ? 0 ), ( error ) ->
    unless error?
      await f server
      server.close()
    else
      throw error

export { start }