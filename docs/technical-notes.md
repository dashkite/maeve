# Technical Notes

### Request Normalization

Maeve maps disparate incoming request shapes (like those from Application Load Balancers and CloudFront Edge functions) into a unified internal model. The internal model normalizes headers to lowercase and aggregates multiple values for the same header into an array, providing consistent access patterns. This relates to the general computer science concept of [canonicalization](https://en.wikipedia.org/wiki/Canonicalization), ensuring that varying input formats conform to a standard, expected structure.

Furthermore, Maeve ensures that URLs and querystrings are appropriately decoded, relying on established specifications such as those maintained by the [W3C](https://www.w3.org/Addressing/URL/uri-spec.html) and [MDN Web Docs on URLSearchParams](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams).

### Response Denormalization

When returning a response to AWS, Maeve converts the normalized response object back into the specific format required by the executing environment, such as [Edge Computing architectures](https://en.wikipedia.org/wiki/Edge_computing) used by CloudFront. For instance, ALB requires specific case-sensitive or case-insensitive headers depending on the payload structure, whereas CloudFront Edge requires nested objects containing arrays of `{ value }` pairs.

### The Sublime Representation

The `Sublime` module introduces a higher-order concept that expands upon resource space and locator patterns. Rather than managing point-to-point translations between numerous distinct interfaces, Sublime establishes an abstract, general representation of a free-floating HTTP request and response. 

When dealing with data that holds a serialized format for transfer over the wire, or an idiomatic format tightly coupled to a specific case (such as an AWS service interface), modeling it through this generalized form provides significant architectural benefits. It enables a [hub-and-spoke model](https://en.wikipedia.org/wiki/Spoke%E2%80%93hub_distribution_paradigm) for data transformation. By converting incoming formats into the central Sublime representation, and then converting from Sublime into the target format, the system dramatically reduces the number of direct conversions needed, thereby easing overall complexity. While not strictly mandatory for every library integration, this concept remains a vital design pattern within the codebase.
