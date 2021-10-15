import { Generic } from "#helpers"

class Request

  @from: Generic.create()

  @update: Generic.create()

  update: -> Fn.apply Request.update, [ @, arguments... ]

export { Request }