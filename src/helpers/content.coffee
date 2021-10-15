class Content

  @create: (bytes) ->
    self = new Content
    self._ = bytes

  @from: (format, value) ->
    Content.create convert from: format, to: "bytes", value

  to: (format) ->
    convert from: "bytes", to: format, @_

export { Content }