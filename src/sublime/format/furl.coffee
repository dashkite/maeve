import { register } from "#sublime/convert"
import { Request, Response } from "#furl"

register 
  type: "response"
  from: "sublime"
  to: "furl"
  Response.from

register
  type: "request"
  from: "furl"
  to: "sublime"
  Request.to