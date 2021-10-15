import { Generic } from "#helpers"

class Response

  @from: Generic.create()

  @update: Generic.create()

  update: -> Fn.apply Response.update, [ @, arguments... ]

export { Response }