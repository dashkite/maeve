import { Generic } from "#helpers"

class Event

  @from: Generic.create()

  @to: Generic.create()

  to: -> Fn.apply Event.to, [ @, arguments... ]

  dispatch: (handler) ->
    new Promise (resolve, reject) ->
      callback = (error, result) ->
        if error?
          reject error
        else
          resolve result
      # TODO do we need to do anything for the context?
      handler @_, {}, callback

isLambdaEventLike = (value) ->

Generic.define Event.from,
  [
    isLambdaEventLike
  ]
  (event) ->
    self = new Event
    self._ = event

export * from "./headers"
export * from "./request"
export * from "./response"
export { Event }
