# Reference

## ALB

### getNormalizedRequest

$getNormalizedRequest( event ) \to request$

Parses an incoming AWS Application Load Balancer (ALB) event and translates its highly specific wire format into an abstract, normalized request representation. This establishes the foundation for the hub-and-spoke transformation model, freeing the core application logic from the nuances of the ALB interface.

```coffeescript
import * as ALB from "@dashkite/maeve/alb"
request = ALB.getNormalizedRequest event
console.log request.method
```

### getDenormalizedResponse

$getDenormalizedResponse( response ) \to event$

Accepts a normalized response—the abstract, free-floating representation of an HTTP response—and translates it back into the localized, case-sensitive dictionary structure required by the Application Load Balancer.

## Edge

### getRequest

$getRequest( event ) \to request$

Navigates the deeply nested structure of a CloudFront Edge event to extract the underlying request object, keeping it in its raw Edge-specific format.

```coffeescript
import * as Edge from "@dashkite/maeve/edge"
request = Edge.getRequest edgeEvent
```

### getResponse

$getResponse( event ) \to response$

Extracts the raw CloudFront Edge response payload from the enclosing AWS event structure.

### getNormalizedRequest

$getNormalizedRequest( event ) \to request$

Converts a CloudFront Edge event into the abstract, generalized representation of an HTTP request. By normalizing the Edge payload, developers can interact with a standard hub structure rather than a bespoke Edge dictionary.

### getDenormalizedResponse

$getDenormalizedResponse( response ) \to event$

Maps a normalized, abstract response object back into the specific format demanded by a CloudFront Edge function. This involves translating arrays and nested value maps back into the strict Edge specification.

### getRequestURL

$getRequestURL( request ) \to url$

Derives the complete, fully-qualified URL from an Edge request, abstracting away the complexities of the underlying CloudFront `origin` and `headers` structures.

### getRequestTarget

$getRequestTarget( request ) \to target$

Extracts the target path and querystring from an Edge request, canonicalizing the inputs into a unified target string.

### getRequestMethod

$getRequestMethod( request ) \to method$

Retrieves the HTTP method from an Edge request, enforcing lowercase standardization.

### getRequestHeader

$getRequestHeader( request, key ) \to string$

Plucks a specific header value from an Edge request, managing the nested array-of-objects structure inherent to CloudFront payloads.

### getRequestHeaders

$getRequestHeaders( request ) \to object$

Flattens and normalizes all headers from an Edge request into a standard dictionary, making it easier for generalized logic to process HTTP metadata.

### setRequestOrigin

$setRequestOrigin( request, domain ) \to request$

Mutates an Edge request to override the origin domain, updating both the custom origin property and the host header simultaneously.

### setRequestHeader

$setRequestHeader( request, key, value ) \to request$

Injects a new header into an Edge request, wrapping the value in the nested structure expected by CloudFront.

### getResponseStatusCode

$getResponseStatusCode( response ) \to number$

Extracts the numeric HTTP status code from an Edge response.

### setResponseStatusCode

$setResponseStatusCode( response, options ) \to response$

Applies a status code and an optional description to an Edge response, updating the localized string representations required by the Edge environment.

### setResponseHeader

$setResponseHeader( response, key, value ) \to response$

Inserts a header into an Edge response, adhering to the required CloudFront nesting array format.

### setResponseBody

$setResponseBody( response, options ) \to response$

Configures the body and its corresponding encoding (e.g., base64 or text) on an Edge response, ensuring the payload adheres to the strict transport limitations of Edge functions.

```coffeescript
Edge.setResponseBody response,
  content: "Hello from the edge"
  encoding: "text"
```

## Sublime.Request

### from

$from( format, request ) \to request$

Translates an environment-specific request (such as an idiomatic ALB or Furl payload) into the central Sublime representation. As the hub in the hub-and-spoke model, this abstract, free-floating HTTP request eliminates the need for N-to-N transformations across the system.

### to

$to( format, request ) \to request$

Transforms a generalized Sublime request back into a localized format. By converting from the Sublime hub out to a specific spoke, developers minimize conversion complexity while supporting a wide array of environments.

## Sublime.Response

### from

$from( format, response ) \to response$

Ingests an environment-bound response payload and maps it into the abstract Sublime response structure, establishing a generalized model for further manipulation or testing.

### to

$to( format, response ) \to response$

Converts the abstract Sublime response representation into a specified target format, completing the hub-and-spoke transformation cycle to produce a valid payload for the chosen environment.
