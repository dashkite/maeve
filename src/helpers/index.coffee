import { generic } from "@dashkite/joy/generic"

Generic =
  create: (name) -> generic { name }
  define: (g, predicates, f) -> generic g, predicates..., f

export * from "./convert"
export { Generic }