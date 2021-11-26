import resolveStatus from "statuses"
import * as Type from "@dashkite/joy/type"

getStatusFromDescription = (description) ->
  resolveStatus description

getDescriptionFromStatus = (status) ->
  resolveStatus status

export {
  getStatusFromDescription
  getDescriptionFromStatus
}