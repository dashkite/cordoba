# Testing

This document describes the testing approach for Cordoba.

## How are tests structured?

The tests for Cordoba are written using `@dashkite/amen` and `@dashkite/assert`.
The test suite is defined in the `test/` directory, utilizing Amen's hierarchical test structure and asynchronous capabilities.

## How to execute tests?

ALWAYS execute the test suite by running the following command from the repository root:

```bash
npx genie test
```

This ensures the test environment is correctly prepared and the tests are executed using the DashKite Genie task manager.
