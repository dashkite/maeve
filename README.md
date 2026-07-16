# Maeve

_Implement and test Lambda functions more easily._

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Maeve allows developers to easily implement and test AWS Lambda functions. It translates normalized request and response formats into the corresponding event formats required by AWS services, including Application Load Balancers (ALB) and CloudFront Edge functions.

## Features

- Provides an easy-to-use translation layer for AWS Lambda events.
- Supports Application Load Balancer and CloudFront Edge events.
- Allows for streamlined testing of handlers without complex setup through format conversions (Sublime, Furl).

## Installation

Use pnpm to install the package:

```bash
pnpm install @dashkite/maeve
```

## Usage

Convert an AWS Lambda event into a normalized request, then process it in your handler.

```coffeescript
import * as ALB from "@dashkite/maeve/alb"

handler = (event, context, callback) ->
  request = ALB.getNormalizedRequest event
  
  # core handler logic here
  
  response = 
    status: 200
    description: "200 OK"
    headers:
      "content-type": [ "text/html" ]
    content: "<h1>Hello from Lambda!</h1>"
  
  callback null, ALB.getDenormalizedResponse response
```

## Other Resources

- [Recipes](docs/recipes.md)
- [Reference](docs/reference.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
