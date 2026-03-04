# Installation

Leetium is distributed as a single self-contained binary. Choose the installation method that works best for your setup.

## Quick Install (Recommended)

The fastest way to get started on macOS or Linux:

```bash
curl -fsSL https://www.leetnex.ru/install.sh | sh
```

This downloads the latest release for your platform and installs it to `~/.local/bin`.

## Package Managers

### Homebrew (macOS / Linux)

```bash
brew install 1337niy/tap/leetium
```

## Linux Packages

### Debian / Ubuntu (.deb)

```bash
# Download the latest .deb package
curl -LO https://github.com/1337niy/leetium/releases/latest/download/leetium_amd64.deb

# Install
sudo dpkg -i leetium_amd64.deb
```

### Fedora / RHEL (.rpm)

```bash
# Download the latest .rpm package
curl -LO https://github.com/1337niy/leetium/releases/latest/download/leetium.x86_64.rpm

# Install
sudo rpm -i leetium.x86_64.rpm
```

### Arch Linux (.pkg.tar.zst)

```bash
# Download the latest package
curl -LO https://github.com/1337niy/leetium/releases/latest/download/leetium.pkg.tar.zst

# Install
sudo pacman -U leetium.pkg.tar.zst
```

### Snap

```bash
sudo snap install leetium
```

### AppImage

```bash
# Download
curl -LO https://github.com/1337niy/leetium/releases/latest/download/leetium.AppImage
chmod +x leetium.AppImage

# Run
./leetium.AppImage
```

## Docker

Multi-architecture images (amd64/arm64) are published to GitHub Container Registry:

```bash
docker pull ghcr.io/1337niy/leetium:latest
```

See [Docker Deployment](docker.md) for full instructions on running Leetium in a container.

## Build from Source

### Prerequisites

- Rust 1.91 or later
- A C compiler (for some dependencies)

### Clone and Build

```bash
git clone https://github.com/1337niy/leetium.git
cd leetium
cargo build --release
```

The binary will be at `target/release/leetium`.

### Install via Cargo

```bash
cargo install leetium --git https://github.com/1337niy/leetium
```

## First Run

After installation, start Leetium:

```bash
leetium
```

On first launch:

1. Open `http://localhost:<port>` in your browser (the port is shown in the terminal output)
2. Configure your LLM provider (API key)
3. Start chatting!

```admonish tip
Leetium picks a random available port on first install to avoid conflicts. The port is saved in your config and reused on subsequent runs.
```

```admonish note
Authentication is only required when accessing Leetium from a non-localhost address (e.g., over the network). When this happens, a one-time setup code is printed to the terminal for initial authentication setup.
```

## Verify Installation

```bash
leetium --version
```

## Updating

### Homebrew

```bash
brew upgrade leetium
```

### From Source

```bash
cd leetium
git pull
cargo build --release
```

## Uninstalling

### Homebrew

```bash
brew uninstall leetium
```

### Remove Data

Leetium stores data in two directories:

```bash
# Configuration
rm -rf ~/.config/leetium

# Data (sessions, databases, memory)
rm -rf ~/.leetium
```

```admonish warning
Removing these directories deletes all your conversations, memory, and settings permanently.
```
