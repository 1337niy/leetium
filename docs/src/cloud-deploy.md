# Cloud Deploy

Leetium publishes a multi-arch Docker image (`linux/amd64` and `linux/arm64`)
to `ghcr.io/1337leetium/leetium`. You can deploy it to any cloud provider that
supports container images.

## Common configuration

All cloud providers terminate TLS at the edge, so Leetium must run in plain
HTTP mode. The key settings are:

| Setting | Value | Purpose |
|---------|-------|---------|
| `--no-tls` or `LEETIUM_NO_TLS=true` | Disable TLS | Provider handles HTTPS |
| `--bind 0.0.0.0` | Bind all interfaces | Required for container networking |
| `--port <PORT>` | Listen port | Must match provider's expected internal port |
| `LEETIUM_CONFIG_DIR=/data/config` | Config directory | Persist leetium.toml, credentials |
| `LEETIUM_DATA_DIR=/data` | Data directory | Persist databases, sessions, memory |
| `LEETIUM_DEPLOY_PLATFORM` | Deploy platform | Hides local-only providers (see below) |
| `LEETIUM_PASSWORD` | Initial password | Set auth password via environment variable |

```admonish tip
If requests to your domain are redirected to `:13131`, Leetium TLS is still
enabled behind a TLS-terminating proxy. Use `--no-tls` (or
`LEETIUM_NO_TLS=true`).

Only keep Leetium TLS enabled when your proxy talks HTTPS to Leetium (or uses
TCP TLS passthrough). In that case, set `LEETIUM_ALLOW_TLS_BEHIND_PROXY=true`.
```

```admonish warning
**Sandbox limitation**: Most cloud providers do not support Docker-in-Docker.
The sandboxed command execution feature (where the LLM runs shell commands
inside isolated containers) will not work on these platforms. The agent will
still function for chat, tool calls that don't require shell execution, and
MCP server connections.
```

### `LEETIUM_DEPLOY_PLATFORM`

Set this to the name of your cloud provider (e.g. `flyio`, `digitalocean`,
`render`). When set, Leetium hides local-only LLM providers
(local-llm and Ollama) from the provider setup page since they cannot run
on cloud VMs. The included deploy templates for Fly.io, DigitalOcean, and
Render already set this variable.

## Coolify (self-hosted, e.g. Hetzner)

Coolify deployments can run Leetium with sandboxed exec tools, as long as the
service mounts the host Docker socket.

- Use [`examples/docker-compose.coolify.yml`](../examples/docker-compose.coolify.yml)
  as a starting point.
- Run Leetium with `--no-tls` (Coolify terminates HTTPS at the proxy).
- Set `LEETIUM_BEHIND_PROXY=true` so client IP/auth behavior is correct behind
  reverse proxying.
- Mount `/var/run/docker.sock:/var/run/docker.sock` to enable container-backed
  sandbox execution.

## Fly.io

The repository includes a `fly.toml` ready to use.

### Quick start

```bash
# Install the Fly CLI if you haven't already
curl -L https://fly.io/install.sh | sh

# Launch from the repo (uses fly.toml)
fly launch --image ghcr.io/1337leetium/leetium:latest

# Set your password
fly secrets set LEETIUM_PASSWORD="your-password"

# Create persistent storage
fly volumes create leetium_data --region iad --size 1
```

### How it works

- **Image**: pulled from `ghcr.io/1337leetium/leetium:latest`
- **Port**: internal 8080, Fly terminates TLS and routes HTTPS traffic
- **Storage**: a Fly Volume mounted at `/data` persists the database, sessions,
  and memory files
- **Auto-scaling**: machines stop when idle and start on incoming requests

### Custom domain

```bash
fly certs add your-domain.com
```

Then point a CNAME to `your-app.fly.dev`.

## DigitalOcean App Platform

[![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/1337leetium/leetium/tree/main)

Click the button above or create an app manually:

1. Go to **Apps** > **Create App**
2. Choose **Container Image** as source
3. Set image to `ghcr.io/1337leetium/leetium:latest`
4. Set the run command: `leetium --bind 0.0.0.0 --port 8080 --no-tls`
5. Set environment variables:
   - `LEETIUM_DATA_DIR` = `/data`
   - `LEETIUM_PASSWORD` = your password
6. Set the HTTP port to `8080`

```admonish info title="No persistent disk"
DigitalOcean App Platform does not support persistent disks for image-based
services in the deploy template. Data will be lost on redeployment. For
persistent storage, consider using a DigitalOcean Droplet with Docker instead.
```

## Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/1337leetium/leetium)

The repository includes a `render.yaml` blueprint. Click the button above or:

1. Go to **Dashboard** > **New** > **Blueprint**
2. Connect your fork of the Leetium repository
3. Render will detect `render.yaml` and configure the service

### Configuration details

- **Port**: Render uses port 10000 by default
- **Persistent disk**: 1 GB mounted at `/data` (included in the blueprint)
- **Environment**: set `LEETIUM_PASSWORD` in the Render dashboard under
  **Environment** > **Secret Files** or **Environment Variables**

<!-- TODO: Railway deploy does not work yet
## Railway

The repository includes a `railway.json` configuration that sets the required
environment variables (`LEETIUM_CONFIG_DIR`, `LEETIUM_DATA_DIR`,
`LEETIUM_DEPLOY_PLATFORM`) automatically.

1. Create a new project on [Railway](https://railway.com)
2. Add a service from **Docker Image**: `ghcr.io/1337leetium/leetium:latest`
3. Railway injects the `$PORT` variable automatically; the `railway.json` start
   command handles the rest
4. Set additional environment variables in the Railway dashboard:
   - `LEETIUM_PASSWORD` = your password

### Persistent storage

Railway supports persistent volumes. Add one in the service settings and mount
it at `/data`.
-->

## OAuth Providers (OpenAI Codex, GitHub Copilot)

OAuth providers that redirect to `localhost` (like OpenAI Codex) cannot
complete the browser flow when Leetium runs on a remote server — `localhost`
on the user's browser points to their own machine, not the cloud instance.

**Use the CLI to authenticate instead:**

```bash
# Fly.io
fly ssh console -C "leetium auth login --provider openai-codex"

# DigitalOcean (Droplet with Docker)
docker exec -it leetium leetium auth login --provider openai-codex

# Generic container
docker exec -it <container> leetium auth login --provider openai-codex
```

The CLI opens a browser on the machine where you run the command. After you
log in, tokens are saved to the config volume and the running gateway picks
them up automatically — no restart needed.

```admonish tip
GitHub Copilot uses device-flow authentication (a code you enter on
github.com), so it works from the web UI without this workaround.
```

## Authentication

On first launch, Leetium requires a password or passkey to be set. In cloud
deployments the easiest approach is to set the `LEETIUM_PASSWORD` environment
variable (or secret) before deploying. This pre-configures the password so the
setup code flow is skipped.

```bash
# Fly.io
fly secrets set LEETIUM_PASSWORD="your-secure-password"

```

For Render and DigitalOcean, set the variable in the dashboard's environment
settings.

## Health checks

All provider configs use the `/health` endpoint which returns HTTP 200 when
the gateway is ready. Configure your provider's health check to use:

- **Path**: `/health`
- **Method**: `GET`
- **Expected status**: `200`
