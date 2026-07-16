# Recipes

## Normalizing an ALB Event

Often, developers need to handle Application Load Balancer events inside AWS Lambda functions. The software enables this task by providing straightforward conversion functions to extract the core HTTP properties from the AWS wrapper.

```coffeescript
import * as ALB from "@dashkite/maeve/alb"

# Simulated event payload from AWS ALB
event =
  requestContext:
    elb:
      targetGroupArn: "..."
  httpMethod: "GET"
  path: "/lambda"
  queryStringParameters:
    query: "1234ABCD"
  headers:
    "accept-encoding": "gzip"
  body: ""
  isBase64Encoded: false

request = ALB.getNormalizedRequest event

# Developers can now interact with a simplified request object
console.log request.method
console.log request.target
```

Here, the creator parses the incoming event into a standardized object that remains consistent across different integration points, allowing the core application logic to be environment-agnostic.

## Extracting Specific CloudFront Edge Headers

CloudFront Edge events contain deeply nested arrays of objects for headers. Developers can bypass this complexity by using targeted extraction functions.

```coffeescript
import * as Edge from "@dashkite/maeve/edge"

# Simulated Edge event
edgeEvent = 
  Records: [
    cf:
      request:
        headers:
          "authorization": [ { value: "Bearer token-123" } ]
  ]

request = Edge.getRequest edgeEvent
token = Edge.getRequestHeader request, "authorization"

console.log token # "Bearer token-123"
```

The creator extracts the exact value required for authentication without needing to traverse arrays or validate the existence of the `cf` property chain.

## Creating an Edge Response

When building CloudFront Edge handlers, creators must formulate a response in the specific format required by AWS.

```coffeescript
import * as Edge from "@dashkite/maeve/edge"

response = 
  status: 200
  description: "200 OK"
  headers:
    "content-type": [ "application/json" ]
  content: 
    message: "Hello from the Edge!"
  encoding: "text"

edgeResponseEvent = Edge.getDenormalizedResponse response
```

By using `getDenormalizedResponse`, the creator avoids dealing directly with the nested structure required by CloudFront, relying instead on a flat and standardized response description.

## Mutating an Edge Request in Transit

Creators building Edge proxies often need to dynamically re-route traffic or inject metadata before passing the request to the origin server.

```coffeescript
import * as Edge from "@dashkite/maeve/edge"

request = Edge.getRequest edgeEvent

# Inspect incoming headers
region = Edge.getRequestHeader request, "cf-ipcountry"

# Dynamically route the origin based on the region
if region == "GB"
  Edge.setRequestOrigin request, "eu-west-api.dashkite.com"
else
  Edge.setRequestOrigin request, "us-east-api.dashkite.com"

# Inject a tracking header for the origin server
Edge.setRequestHeader request, "x-edge-trace-id", "trace-abc-123"
```

The software safely mutates the nested CloudFront representation in-place, ensuring that both the `origin.custom.domainName` and the explicit `host` header are kept in sync when `setRequestOrigin` is invoked.

## Converting Formats with Furl and Sublime

When developing lambda functions, it can be useful to construct tests using internal payload shapes like Sublime or Furl, then translate them to the required environment structure.

```coffeescript
import { Request } from "@dashkite/maeve/sublime"

# Simulated generic request
sublimeRequest = 
  url: "https://api.dashkite.com/resource"
  method: "get"
  headers: {}

# Convert to internal sublime representation
internalRequest = Request.from "sublime", sublimeRequest

console.log internalRequest.domain
console.log internalRequest.target
```

Using these utilities, the developer avoids constructing boilerplate lambda events for every unit test.

## Cross-Environment Translation (The Hub-and-Spoke)

For advanced architectural patterns, a developer might need to simulate handling a request from an ALB environment and generating a response meant for a CloudFront Edge cache. The software achieves this by routing through the `Sublime` abstract representation.

```coffeescript
import * as ALB from "@dashkite/maeve/alb"
import * as Edge from "@dashkite/maeve/edge"
import { Request, Response } from "@dashkite/maeve/sublime"

# 1. Parse the incoming localized ALB event
normalizedRequest = ALB.getNormalizedRequest albEvent

# 2. Elevate the request to the abstract Sublime hub
sublimeRequest = Request.from "alb", normalizedRequest

# 3. Process the abstract request in core business logic
sublimeResponse = processRequest sublimeRequest

# 4. Map the abstract Sublime response back into a specific CloudFront Edge spoke
edgeFormatResponse = Response.to "edge", sublimeResponse

# 5. Generate the strict AWS payload
awsEdgeResponse = Edge.getDenormalizedResponse edgeFormatResponse
```

In this arcane scenario, the developer successfully bridges two completely different AWS payload formats without writing a direct ALB-to-Edge translation layer, fully leveraging the hub-and-spoke abstraction model.
