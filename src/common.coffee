import resolveStatus from "statuses"
import * as Type from "@dashkite/joy/type"

getStatusFromDescription = (description) ->
  resolveStatus description

getDescriptionFromStatus = (status) ->
  resolveStatus status

setResponseBody = (response, { content }) ->
  if Type.isString content
    response.body = content
  else
    response.body = JSON.stringify content

export {
  getStatusFromDescription
  getDescriptionFromStatus
  setResponseBody
}