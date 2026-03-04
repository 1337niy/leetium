# Development Guide

Welcome to the Leetium developer guide! This document provides human-readable onboarding instructions for building and running the project. For deeper architectural details, please see `CLAUDE.md`.

## Prerequisites

- **Rust**: Version 1.91+
- **Just**: Command runner (`cargo install just`)
- **Node.js**: Required for compiling the web UI assets
- **pre-commit**: (Optional but recommended) `pip install pre-commit`

## Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/1337niy/leetium.git
   cd leetium
   ```

2. **Install pre-commit hooks:**
   ```bash
   pre-commit install
   ```

3. **Install UI dependencies (for end-to-end testing):**
   ```bash
   just ui-e2e-install
   ```

## Common Workflows

### Running Locally

To build the CSS and start the main gateway:
```bash
just dev-server
```
This runs the gateway with isolated configuration and data directories (`.leetium/` inside the repo).

To build the release binary:
```bash
just build-release
```

### Formatting and Linting

It's highly recommended to run these commands before opening a Pull Request:

```bash
just format       # Formats all Rust code (requires specified nightly toolchain)
just lint         # Runs clippy with required flags
biome check --write   # Formats JS/UI files
taplo fmt         # Formats TOML files
```

You can also run everything at once:
```bash
just release-preflight
```

### Testing

Run all unit tests:
```bash
just test
```

Run E2E UI tests:
```bash
just ui-e2e
```

## Changing Configuration

If you change the config schema inside `crates/config/src/schema.rs`, make sure to also update the validation map in `crates/config/src/validate.rs`.

## Database Migrations

Each crate owns its migrations directory. If adding a new query or table, place it in `crates/<crate-name>/migrations/` in SQL files prefixed exactly as `YYYYMMDDHHMMSS_description.sql`.

## Releasing
Releases are handled automatically by GitHub Actions on tags. 
Please write clear `git` commit descriptions using the Conventional Commits specification (`feat`, `fix`, etc.) as this translates directly to the generated Changelog.
