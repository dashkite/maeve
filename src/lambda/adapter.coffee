import { Sublime, Lambda } from "@dashkite/maeve"
import { debug } from "#helpers"

adapter = (handler) ->

  (event, context, callback) ->

    debug "Event", event
    
    context = await Sublime.Context.from event

    debug "Sublime Context", context

    result = await handler context

    debug "Result", result

    result = Lambda.Event.update event, result
    
    debug "Denormalized result", result

    callback null, result

export { adapter }