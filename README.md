<div align="center">

<a href="https://leetnex.ru"><img src="https://raw.githubusercontent.com/1337niy/leetium/main/website/favicon.svg" alt="Leetium" width="64"></a>

# Leetium — A Rust-native claw you can trust

One binary — sandboxed, secure, yours.

[![CI](https://github.com/1337niy/leetium/actions/workflows/ci.yml/badge.svg)](https://github.com/1337niy/leetium/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/1337niy/leetium/graph/badge.svg)](https://codecov.io/gh/1337niy/leetium)
[![CodSpeed](https://img.shields.io/endpoint?url=https://codspeed.io/badge.json&style=flat&label=CodSpeed)](https://codspeed.io/1337niy/leetium)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/Rust-1.91%2B-orange.svg)](https://www.rust-lang.org)
[![Discord](https://img.shields.io/discord/1469505370169933837?color=5865F2&label=Discord&logo=discord&logoColor=white)](https://discord.gg/XnmrepsXp5)

[Installation](#installation) • [Comparison](#comparison) • [Architecture](#architecture--crate-map) • [Security](#security) • [Features](#features) • [How It Works](#how-it-works) • [Contributing](CONTRIBUTING.md)

</div>

---

Please [open an issue](https://github.com/1337niy/leetium/issues) for any friction at all. I'm focused on making Leetium excellent.

**Secure by design** — Your keys never leave your machine. Every command runs in a sandboxed container, never on your host.

**Your hardware** — Runs on a Mac Mini, a Raspberry Pi, or any server you own. One Rust binary, no Node.js, no npm, no runtime.

**Full-featured** — Voice, memory, scheduling, Telegram, Discord, browser automation, MCP servers — all built-in. No plugin marketplace to get supply-chain attacked through.

**Auditable** — The agent loop + provider model fits in ~5K lines. The core (excluding the optional web UI) is ~224K lines across 46 modular crates you can audit independently, with 2,500+ tests and zero `unsafe` code\*.

## Installation

```bash
# One-liner install script (macOS / Linux)
curl -fsSL https://www.leetnex.ru/install.sh | sh

# macOS / Linux via Homebrew
brew install 1337niy/tap/leetium

# Docker (multi-arch: amd64/arm64)
docker pull ghcr.io/1337niy/leetium:latest

# Or build from source
cargo install leetium --git https://github.com/1337niy/leetium
```

## Comparison

| | OpenClaw | PicoClaw | NanoClaw | ZeroClaw | **Leetium** |
|---|---|---|---|---|---|
| Language | TypeScript | Go | TypeScript | Rust | **Rust** |
| Agent loop | ~430K LoC | Small | ~500 LoC | ~3.4K LoC | **~5K LoC** (`runner.rs` + `model.rs`) |
| Full codebase | — | — | — | 1,000+ tests | **~224K LoC** (2,500+ tests) |
| Runtime | Node.js + npm | Single binary | Node.js | Single binary (3.4 MB) | **Single binary (44 MB)** |
| Sandbox | App-level | — | Docker | Docker | **Docker + Apple Container** |
| Memory safety | GC | GC | GC | Ownership | **Ownership, zero `unsafe`\*** |
| Auth | Basic | API keys | None | Token + OAuth | **Password + Passkey + API keys + Vault** |
| Voice I/O | Plugin | — | — | — | **Built-in (15+ providers)** |
| MCP | Yes | — | — | — | **Yes (stdio + HTTP/SSE)** |
| Hooks | Yes (limited) | — | — | — | **15 event types** |
| Skills | Yes (store) | Yes | Yes | Yes | **Yes (+ OpenClaw Store)** |
| Memory/RAG | Plugin | — | Per-group | SQLite + FTS | **SQLite + FTS + vector** |

\* `unsafe` is denied workspace-wide. The only exceptions are opt-in FFI wrappers behind the `local-embeddings` feature flag, not part of the core.

> [Full comparison with benchmarks →](https://docs.leetnex.ru/comparison.html)

## Architecture — Crate Map

**Core** (always compiled):

| Crate | LoC | Role |
|-------|-----|------|
| `leetium` (cli) | 4.0K | Entry point, CLI commands |
| `leetium-agents` | 9.6K | Agent loop, streaming, prompt assembly |
| `leetium-providers` | 17.6K | LLM provider implementations |
| `leetium-gateway` | 36.1K | HTTP/WS server, RPC, auth |
| `leetium-chat` | 11.5K | Chat engine, agent orchestration |
| `leetium-tools` | 21.9K | Tool execution, sandbox |
| `leetium-config` | 7.0K | Configuration, validation |
| `leetium-sessions` | 3.8K | Session persistence |
| `leetium-plugins` | 1.9K | Hook dispatch, plugin formats |
| `leetium-service-traits` | 1.3K | Shared service interfaces |
| `leetium-common` | 1.1K | Shared utilities |
| `leetium-protocol` | 0.8K | Wire protocol types |

**Optional** (feature-gated or additive):

| Category | Crates | Combined LoC |
|----------|--------|-------------|
| Web UI | `leetium-web` | 4.5K |
| GraphQL | `leetium-graphql` | 4.8K |
| Voice | `leetium-voice` | 6.0K |
| Memory | `leetium-memory`, `leetium-qmd` | 5.9K |
| Channels | `leetium-telegram`, `leetium-whatsapp`, `leetium-discord`, `leetium-msteams`, `leetium-channels` | 14.9K |
| Browser | `leetium-browser` | 5.1K |
| Scheduling | `leetium-cron`, `leetium-caldav` | 5.2K |
| Extensibility | `leetium-mcp`, `leetium-skills`, `leetium-wasm-tools` | 9.1K |
| Auth & Security | `leetium-auth`, `leetium-oauth`, `leetium-onboarding`, `leetium-vault` | 6.6K |
| Networking | `leetium-network-filter`, `leetium-tls`, `leetium-tailscale` | 3.5K |
| Provider setup | `leetium-provider-setup` | 4.3K |
| Import | `leetium-openclaw-import` | 7.6K |
| Apple native | `leetium-swift-bridge` | 2.1K |
| Metrics | `leetium-metrics` | 1.7K |
| Other | `leetium-projects`, `leetium-media`, `leetium-routing`, `leetium-canvas`, `leetium-auto-reply`, `leetium-schema-export`, `leetium-benchmarks` | 2.5K |

Use `--no-default-features --features lightweight` for constrained devices (Raspberry Pi, etc.).

## Security

- **Zero `unsafe` code\*** — denied workspace-wide; only opt-in FFI behind `local-embeddings` flag
- **Sandboxed execution** — Docker + Apple Container, per-session isolation
- **Secret handling** — `secrecy::Secret`, zeroed on drop, redacted from tool output
- **Authentication** — password + passkey (WebAuthn), rate-limited, per-IP throttle
- **SSRF protection** — DNS-resolved, blocks loopback/private/link-local
- **Origin validation** — rejects cross-origin WebSocket upgrades
- **Hook gating** — `BeforeToolCall` hooks can inspect/block any tool invocation

See [Security Architecture](https://docs.leetnex.ru/security.html) for details.

## Features

- **AI Gateway** — Multi-provider LLM support (OpenAI Codex, GitHub Copilot, Local), streaming responses, agent loop with sub-agent delegation, parallel tool execution
- **Communication** — Web UI, Telegram, Microsoft Teams, Discord, API access, voice I/O (8 TTS + 7 STT providers), mobile PWA with push notifications
- **Memory & Context** — Per-agent memory workspaces, embeddings-powered long-term memory, hybrid vector + full-text search, session persistence with auto-compaction, project context
- **Extensibility** — MCP servers (stdio + HTTP/SSE), skill system, 15 lifecycle hook events with circuit breaker, destructive command guard
- **Security** — Encryption-at-rest vault (XChaCha20-Poly1305 + Argon2id), password + passkey + API key auth, sandbox isolation, SSRF/CSWSH protection
- **Operations** — Cron scheduling, OpenTelemetry tracing, Prometheus metrics, cloud deploy (Fly.io, DigitalOcean), Tailscale integration

## How It Works

Leetium is a **local-first AI gateway** — a single Rust binary that sits
between you and multiple LLM providers. Everything runs on your machine; no
cloud relay required.

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Web UI    │  │  Telegram   │  │  Discord    │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └────────┬───────┴────────┬───────┘
                │   WebSocket    │
                ▼                ▼
        ┌─────────────────────────────────┐
        │          Gateway Server         │
        │   (Axum · HTTP · WS · Auth)     │
        ├─────────────────────────────────┤
        │        Chat Service             │
        │  ┌───────────┐ ┌─────────────┐  │
        │  │   Agent   │ │    Tool     │  │
        │  │   Runner  │◄┤   Registry  │  │
        │  └─────┬─────┘ └─────────────┘  │
        │        │                        │
        │  ┌─────▼─────────────────────┐  │
        │  │    Provider Registry      │  │
        │  │  Multiple providers       │  │
        │  │  (Codex · Copilot · Local)│  │
        │  └───────────────────────────┘  │
        ├─────────────────────────────────┤
        │  Sessions  │ Memory  │  Hooks   │
        │  (JSONL)   │ (SQLite)│ (events) │
        └─────────────────────────────────┘
                       │
               ┌───────▼───────┐
               │    Sandbox    │
               │ Docker/Apple  │
               │  Container    │
               └───────────────┘
```

See [Quickstart](https://docs.leetnex.ru/quickstart.html) for gateway startup, message flow, sessions, and memory details.

## Getting Started

### Build & Run

```bash
git clone https://github.com/1337niy/leetium.git
cd leetium
just build-release
just dev-server
```

Open `https://leetium.localhost:3000`. On first run, a setup code is printed to
the terminal — enter it in the web UI to set your password or register a passkey.

Optional flags: `--config-dir /path/to/config --data-dir /path/to/data`

### Docker

```bash
# Docker / OrbStack
docker run -d \
  --name leetium \
  -p 13131:13131 \
  -p 13132:13132 \
  -p 1455:1455 \
  -v leetium-config:/home/leetium/.config/leetium \
  -v leetium-data:/home/leetium/.leetium \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/1337niy/leetium:latest
```

Open `https://localhost:13131` and complete the setup. See [Docker docs](https://docs.leetnex.ru/docker.html) for Podman, OrbStack, TLS trust, and persistence details.

### Cloud Deployment

| Provider | Deploy |
|----------|--------|
| DigitalOcean | [![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/1337niy/leetium/tree/main) |

**Fly.io** (CLI):

```bash
fly launch --image ghcr.io/1337niy/leetium:latest
fly secrets set LEETIUM_PASSWORD="your-password"
```

All cloud configs use `--no-tls` because the provider handles TLS termination.
See [Cloud Deploy docs](https://docs.leetnex.ru/cloud-deploy.html) for details.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=1337niy/leetium&type=date&legend=top-left)](https://www.star-history.com/#1337niy/leetium&type=date&legend=top-left)

## License

MIT
