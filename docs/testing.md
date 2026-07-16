# Testing

The repository relies on `genie` for task management and `@dashkite/amen` for executing test scenarios. The tests are located in the `test/` directory and validate the conversion accuracy for various event types (ALB, Edge, Sublime, and Furl).

To invoke the tests, run the following command:

```bash
npx genie test
```

The approach tests the individual adapters (ALB, Edge) as well as the format conversion wrappers (Sublime, Furl). It uses a set of static payload fixtures located in the `test/data/` directory and YAML-driven scenarios located in `test/scenarios.yaml`. By asserting that the conversion logic maps standard objects to exact AWS payloads, creators can be confident that the lambda functions will behave correctly when deployed.
