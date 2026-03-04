# ADR 002: Security Audit array of Node-Host Execution Boundaries

## Status
Accepted

## Context
The `leetium-node-host` crate (`crates/node-host`) allows a remote node to connect to the Leetium Gateway via WebSockets and advertise its capabilities. One of the core commands supported natively is `system.run`.

When a `system.run` command is received, the host spawns a completely arbitrary system shell (`sh -c <command>`) executing the strings specified in the request. This represents an intentional Remote Code Execution (RCE) vector to allow the Leetium Assistant to control the host OS.

As identified in BUG-002, this poses a potential sandbox escape vulnerability:
1. If the node authenticates using an overly-permissive device token, a compromised Gateway can run any command on the physical node.
2. The current implementation does not restrict the command execution to a container, chroot, or restricted user unless explicitly run as such by the admin.

## Audit Findings
- In `crates/node-host/src/runner.rs`, `handle_system_run` passes raw Strings into `tokio::process::Command::new("sh").arg("-c").arg(command)`.
- There are no OS-level sandbox bindings (like Firecracker, AppArmor profiles, or seccomp) in the Node Host.
- The default execution timeout is 300 seconds, and custom environments (`env` object in `args`) are applied entirely verbatim.
- Execution boundaries are effectively equivalent to the execution boundaries of the process running `leetium` on the OS.

## Decision
The purpose of the `leetium-node-host` is explicitly to provide system automation. The "sandbox escape" is by design for a host-control daemon.

However, to address the **Security** aspect:
1. **Documentation update:** Users deploying `node-host` must be explicitly warned to run it under a separate `leetium` user with dropped privileges if full system access is not intended.
2. **Containerization focus:** For untrusted task execution, users should use the Gateway's Docker sandbox capability rather than a raw `node-host` running as their primary user.
3. Node Host is considered a high-privilege agent, and the execution boundary is the OS user boundary. In future iterations, we will explore integrating lightweight virtualization (Firecracker - see IMP-009) to provide multi-tenant isolation.
