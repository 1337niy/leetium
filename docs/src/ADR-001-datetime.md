# ADR-001: Date and Time Crate Selection

## Status
Accepted

## Context
Historically, Rust has had two competing standard-adjacent date and time libraries: `chrono` and `time`. 
The `chrono` crate is widely adopted and historically standard. However, it pulls in a heavier dependency tree and has had historical maintenance lulls.
The `time` crate is modern, actively maintained, and often compiles faster with fewer dependencies.

The Leetium project has ended up with both dependencies in its workspace (`chrono` and `time`), leading to a conflicting pattern for contributors. Some crates use `chrono`, while others use `time`.

## Decision
For new code in the Leetium project, we will use the `time` crate by default as our primary time library.
- It provides a modern API.
- It reduces the overall dependency footprint for new binaries.

We **will not** ban `chrono` outright. 
- If a crate is already heavily invested in `chrono`, or requires it to interoperate with existing libraries (e.g., `sqlx` typically supports both but existing code might rely on `chrono`), maintaining `chrono` locally within that crate is fine.
- However, do not introduce `chrono` into new crates or crates that do not already depend on it.

## Consequences
- New developers should read this ADR and default to the `time` crate.
- We will slowly migrate away from `chrono` as we refactor older crates, keeping the dependency tree slim.
