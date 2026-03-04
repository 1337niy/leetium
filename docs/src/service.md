# Service Management

Leetium can be installed as an OS service so it starts automatically on boot
and restarts after crashes.

## Install

```bash
leetium service install
```

This creates a service definition and starts it immediately:

| Platform | Service file | Init system |
|----------|-------------|-------------|
| macOS | `~/Library/LaunchAgents/org.leetium.gateway.plist` | launchd (user agent) |
| Linux | `~/.config/systemd/user/leetium.service` | systemd (user unit) |

Both configurations:

- **Start on boot** (`RunAtLoad` / `WantedBy=default.target`)
- **Restart on failure** with a 10-second cooldown
- **Log to** `~/.leetium/leetium.log`

### Options

You can pass `--bind`, `--port`, and `--log-level` to bake them into the
service definition:

```bash
leetium service install --bind 0.0.0.0 --port 8080 --log-level debug
```

These flags are written into the service file. The service reads the rest of
its configuration from `~/.leetium/leetium.toml` as usual.

## Manage

```bash
leetium service status     # Show running/stopped/not-installed and PID
leetium service stop       # Stop the service
leetium service restart    # Restart the service
leetium service logs       # Print the log file path
```

To tail the logs:

```bash
tail -f $(leetium service logs)
```

## Uninstall

```bash
leetium service uninstall
```

This stops the service, removes the service file, and cleans up.

## CLI Reference

| Command | Description |
|---------|-------------|
| `leetium service install` | Install and start the service |
| `leetium service uninstall` | Stop and remove the service |
| `leetium service status` | Show service status and PID |
| `leetium service stop` | Stop the service |
| `leetium service restart` | Restart the service |
| `leetium service logs` | Print log file path |

## How It Differs from `leetium node add`

`leetium service install` manages the **gateway** — the main Leetium server
that hosts the web UI, chat sessions, and API.

`leetium node add` registers a **headless node** — a client process on a
remote machine that connects back to a gateway for command execution. See
[Multi-Node](nodes.md) for details.

| | `leetium service` | `leetium node` |
|---|---|---|
| What it runs | The gateway server | A node client |
| Needs `--host`/`--token` | No | Yes |
| Config source | `~/.leetium/leetium.toml` | `~/.leetium/node.json` |
| launchd label | `org.leetium.gateway` | `org.leetium.node` |
| systemd unit | `leetium.service` | `leetium-node.service` |
