# Default recipe (runs when just is called without arguments)
default:
    @just --list

# Keep local formatting/linting toolchain aligned with CI/release workflows.
nightly_toolchain := "nightly-2025-11-30"

# Format Rust code
format:
    cargo +{{nightly_toolchain}} fmt --all

# Check if code is formatted
format-check:
    cargo +{{nightly_toolchain}} fmt --all -- --check

# Verify Cargo.lock is in sync with workspace manifests.
lockfile-check:
    cargo fetch --locked

# Lint Rust code using clippy (nightly required for -Z unstable-options to support specific lints)
lint: lockfile-check
    cargo +{{nightly_toolchain}} clippy -Z unstable-options --workspace --all-features --all-targets --timings -- -D warnings

# Build Tailwind CSS for the web UI.
build-css:
    cd crates/web/ui && ./build.sh

# Build the project
build: build-css
    cargo build

# Build in release mode
build-release:
    cargo build --release

# Build embedded WASM guest tools and pre-compile to .cwasm for AOT loading.
wasm-tools:
    cargo build --target wasm32-wasip2 -p leetium-wasm-calc -p leetium-wasm-web-fetch -p leetium-wasm-web-search --release
    cargo run -p leetium-wasm-precompile --release

# Run local dev server with workspace-local config/data dirs.
dev-server:
    LEETIUM_CONFIG_DIR=.leetium/config LEETIUM_DATA_DIR=.leetium/ cargo run --bin leetium

# Build Debian package for the current architecture
deb: build-release
    cargo deb -p leetium --no-build

# Build Debian package for amd64
deb-amd64:
    cargo build --release --target x86_64-unknown-linux-gnu
    cargo deb -p leetium --no-build --target x86_64-unknown-linux-gnu

# Build Debian package for arm64
deb-arm64:
    cargo build --release --target aarch64-unknown-linux-gnu
    cargo deb -p leetium --no-build --target aarch64-unknown-linux-gnu

# Build Debian packages for all architectures
deb-all: deb-amd64 deb-arm64

# Build Arch package for the current architecture
arch-pkg: build-release
    #!/usr/bin/env bash
    set -euo pipefail
    VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
    ARCH=$(uname -m)
    PKG_DIR="target/arch-pkg"
    rm -rf "$PKG_DIR"
    mkdir -p "$PKG_DIR/usr/bin"
    cp target/release/leetium "$PKG_DIR/usr/bin/leetium"
    chmod 755 "$PKG_DIR/usr/bin/leetium"
    cat > "$PKG_DIR/.PKGINFO" <<PKGINFO
    pkgname = leetium
    pkgver = ${VERSION}-1
    pkgdesc = Personal AI gateway inspired by OpenClaw
    url = https://www.leetnex.ru/
    arch = ${ARCH}
    license = MIT
    PKGINFO
    cd "$PKG_DIR"
    fakeroot -- tar --zstd -cf "../../leetium-${VERSION}-1-${ARCH}.pkg.tar.zst" .PKGINFO usr/
    echo "Built leetium-${VERSION}-1-${ARCH}.pkg.tar.zst"

# Build Arch package for x86_64
arch-pkg-x86_64:
    #!/usr/bin/env bash
    set -euo pipefail
    cargo build --release --target x86_64-unknown-linux-gnu
    VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
    PKG_DIR="target/arch-pkg-x86_64"
    rm -rf "$PKG_DIR"
    mkdir -p "$PKG_DIR/usr/bin"
    cp target/x86_64-unknown-linux-gnu/release/leetium "$PKG_DIR/usr/bin/leetium"
    chmod 755 "$PKG_DIR/usr/bin/leetium"
    cat > "$PKG_DIR/.PKGINFO" <<PKGINFO
    pkgname = leetium
    pkgver = ${VERSION}-1
    pkgdesc = Personal AI gateway inspired by OpenClaw
    url = https://www.leetnex.ru/
    arch = x86_64
    license = MIT
    PKGINFO
    cd "$PKG_DIR"
    fakeroot -- tar --zstd -cf "../../leetium-${VERSION}-1-x86_64.pkg.tar.zst" .PKGINFO usr/
    echo "Built leetium-${VERSION}-1-x86_64.pkg.tar.zst"

# Build Arch package for aarch64
arch-pkg-aarch64:
    #!/usr/bin/env bash
    set -euo pipefail
    cargo build --release --target aarch64-unknown-linux-gnu
    VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
    PKG_DIR="target/arch-pkg-aarch64"
    rm -rf "$PKG_DIR"
    mkdir -p "$PKG_DIR/usr/bin"
    cp target/aarch64-unknown-linux-gnu/release/leetium "$PKG_DIR/usr/bin/leetium"
    chmod 755 "$PKG_DIR/usr/bin/leetium"
    cat > "$PKG_DIR/.PKGINFO" <<PKGINFO
    pkgname = leetium
    pkgver = ${VERSION}-1
    pkgdesc = Personal AI gateway inspired by OpenClaw
    url = https://www.leetnex.ru/
    arch = aarch64
    license = MIT
    PKGINFO
    cd "$PKG_DIR"
    fakeroot -- tar --zstd -cf "../../leetium-${VERSION}-1-aarch64.pkg.tar.zst" .PKGINFO usr/
    echo "Built leetium-${VERSION}-1-aarch64.pkg.tar.zst"

# Build Arch packages for all architectures
arch-pkg-all: arch-pkg-x86_64 arch-pkg-aarch64

# Build RPM package for the current architecture
rpm: build-release
    cargo generate-rpm -p crates/cli

# Build RPM package for x86_64
rpm-x86_64:
    cargo build --release --target x86_64-unknown-linux-gnu
    cargo generate-rpm -p crates/cli --target x86_64-unknown-linux-gnu

# Build RPM package for aarch64
rpm-aarch64:
    cargo build --release --target aarch64-unknown-linux-gnu
    cargo generate-rpm -p crates/cli --target aarch64-unknown-linux-gnu

# Build RPM packages for all architectures
rpm-all: rpm-x86_64 rpm-aarch64

# Build AppImage for the current architecture
appimage: build-release
    #!/usr/bin/env bash
    set -euo pipefail
    VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
    ARCH=$(uname -m)
    APP_DIR="target/leetium.AppDir"
    rm -rf "$APP_DIR"
    mkdir -p "$APP_DIR/usr/bin"
    cp target/release/leetium "$APP_DIR/usr/bin/leetium"
    chmod 755 "$APP_DIR/usr/bin/leetium"
    cat > "$APP_DIR/leetium.desktop" <<DESKTOP
    [Desktop Entry]
    Type=Application
    Name=Leetium
    Exec=leetium
    Icon=leetium
    Categories=Network;
    Terminal=true
    DESKTOP
    cat > "$APP_DIR/leetium.svg" <<SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="256" height="256"><rect width="256" height="256" fill="#333"/><text x="128" y="140" font-size="120" text-anchor="middle" fill="white">M</text></svg>
    SVG
    ln -sf leetium.svg "$APP_DIR/.DirIcon"
    cat > "$APP_DIR/AppRun" <<'APPRUN'
    #!/bin/sh
    SELF=$(readlink -f "$0")
    HERE=${SELF%/*}
    exec "$HERE/usr/bin/leetium" "$@"
    APPRUN
    chmod +x "$APP_DIR/AppRun"
    if [ ! -f target/appimagetool ]; then
        wget -q "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${ARCH}.AppImage" -O target/appimagetool
        chmod +x target/appimagetool
    fi
    ARCH=${ARCH} target/appimagetool --appimage-extract-and-run "$APP_DIR" "leetium-${VERSION}-${ARCH}.AppImage"
    echo "Built leetium-${VERSION}-${ARCH}.AppImage"

# Build Snap package
snap:
    snapcraft

# Build Flatpak
flatpak:
    cd flatpak && flatpak-builder --repo=repo --force-clean builddir org.moltbot.Leetium.yml

# Run all CI checks (format, lint, build, test)
ci: format-check lint i18n-check build-css build test

# Compile once, then run Rust tests and E2E tests in parallel.
# Uses the same nightly toolchain as clippy/local-validate so the build cache
# is shared — no double-compilation.
build-test: build-css
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Building all workspace targets (bins + tests)..."
    cargo +{{nightly_toolchain}} build --workspace --all-features --all-targets
    echo "==> Build complete. Running Rust tests and E2E tests in parallel..."

    RUST_LOG="$(mktemp)"
    E2E_LOG="$(mktemp)"
    trap 'rm -f "${RUST_LOG}" "${E2E_LOG}"' EXIT

    cargo +{{nightly_toolchain}} nextest run --all-features > "${RUST_LOG}" 2>&1 &
    TEST_PID=$!

    (cd crates/web/ui && npm run e2e) > "${E2E_LOG}" 2>&1 &
    E2E_PID=$!

    TEST_EXIT=0; E2E_EXIT=0
    wait "${TEST_PID}" || TEST_EXIT=$?
    wait "${E2E_PID}" || E2E_EXIT=$?

    if [ "${TEST_EXIT}" -ne 0 ]; then
        echo "==> Rust tests FAILED (exit ${TEST_EXIT}):"
        cat "${RUST_LOG}"
    else
        echo "==> Rust tests PASSED"
    fi

    if [ "${E2E_EXIT}" -ne 0 ]; then
        echo "==> E2E tests FAILED (exit ${E2E_EXIT}):"
        cat "${E2E_LOG}"
    else
        echo "==> E2E tests PASSED"
    fi

    exit $(( TEST_EXIT > 0 ? TEST_EXIT : E2E_EXIT ))

# Run the same Rust preflight gates used before release packaging.
release-preflight: lockfile-check
    cargo +{{nightly_toolchain}} fmt --all -- --check
    cargo +{{nightly_toolchain}} clippy -Z unstable-options --workspace --all-features --all-targets --timings -- -D warnings

# Sync repo-root install.sh into website/install.sh for Cloudflare deployment.
sync-website-install:
    ./scripts/sync-website-install.sh

# Ensure repo-root install.sh and website/install.sh are identical.
check-website-install-sync:
    ./scripts/check-website-install-sync.sh

# Dispatch release workflow from GitHub Actions (normal mode).
release-workflow ref='main':
    gh workflow run release.yml --ref {{ref}} -f dry_run=false

# Dispatch release workflow from GitHub Actions (dry-run mode).
release-workflow-dry ref='main':
    gh workflow run release.yml --ref {{ref}} -f dry_run=true

# Dispatch both release workflow modes for the same ref (dry-run then normal).
release-workflow-both ref='main':
    gh workflow run release.yml --ref {{ref}} -f dry_run=true
    gh workflow run release.yml --ref {{ref}} -f dry_run=false

# Regenerate CHANGELOG.md from git history and tags.
changelog:
    git-cliff --config cliff.toml --output CHANGELOG.md

# Preview unreleased changelog entries from commits since the last tag.
changelog-unreleased:
    git-cliff --config cliff.toml --unreleased

# Generate release entries for unreleased commits under the provided version.
changelog-release version:
    git-cliff --config cliff.toml --unreleased --tag "v{{version}}" --strip all

# Commit all changes, push branch, create/update PR, and run local validation.
# All args are optional; defaults are auto-generated from branch + changed files.
ship commit_message='' pr_title='' pr_body='':
    ./scripts/ship-pr.sh {{ quote(commit_message) }} {{ quote(pr_title) }} {{ quote(pr_body) }}

# Run all tests (nightly to share build cache with clippy/lint)
test:
    cargo +{{nightly_toolchain}} nextest run --all-features

# Run contract test suites (channel, provider, memory, tools)
contract-tests:
    cargo test -p leetium-channels contract
    cargo test -p leetium-providers contract
    cargo test -p leetium-memory contract
    cargo test -p leetium-tools contract

# Verify locale key parity across frontend i18n bundles.
i18n-check:
    ./scripts/i18n-check.sh

# Install browser tooling for gateway web UI e2e tests.
ui-e2e-install:
    cd crates/web/ui && npm install && npm run e2e:install

# Run gateway web UI e2e tests (Playwright).
ui-e2e:
    cargo +{{nightly_toolchain}} build --bin leetium
    cd crates/web/ui && npm run e2e

# Run gateway web UI e2e tests with headed browser.
ui-e2e-headed:
    cargo +{{nightly_toolchain}} build --bin leetium
    cd crates/web/ui && npm run e2e:headed

# Build all Linux packages (deb + rpm + arch + appimage) for all architectures
packages-all: deb-all rpm-all arch-pkg-all

# Build Rust static library and generated C header for the macOS app.
swift-build-rust:
    ./scripts/build-swift-bridge.sh

# Generate Xcode project from YAML spec in apps/macos.
swift-generate:
    ./scripts/generate-swift-project.sh

# Lint macOS app sources with SwiftLint.
swift-lint:
    ./scripts/lint-swift.sh

# Build Swift macOS app.
swift-build: swift-build-rust swift-generate
    ./scripts/build-swift.sh

# Run Swift app unit tests.
swift-test: swift-build-rust swift-generate
    ./scripts/test-swift.sh

# Build and launch the Swift macOS app locally.
swift-run: swift-build-rust swift-generate
    ./scripts/run-swift.sh

# Open generated project in Xcode.
swift-open: swift-build-rust swift-generate
    open apps/macos/Leetium.xcodeproj

# Generate iOS app Xcode project.
ios-generate:
    ./scripts/generate-ios-project.sh

# Generate Apollo GraphQL types for iOS.
ios-graphql:
    cargo run -p leetium-schema-export -- apps/ios/GraphQL/Schema/schema.graphqls
    ./scripts/generate-ios-graphql.sh

# Build iOS app (generic iOS destination, no signing).
ios-build: ios-graphql ios-generate
    xcodebuild -project apps/ios/Leetium.xcodeproj -scheme Leetium -configuration Debug -destination "generic/platform=iOS" CODE_SIGNING_ALLOWED=NO build

# Lint iOS app sources with SwiftLint.
ios-lint:
    cd apps/ios && swiftlint

# Open iOS project in Xcode (regenerates GraphQL types and project first).
ios-open: ios-graphql ios-generate
    open apps/ios/Leetium.xcodeproj

# Build the APNS push relay.
courier-build:
    cargo build -p leetium-courier --release

# Cross-compile courier for linux/x86_64.
courier-cross:
    cargo build -p leetium-courier --release --target x86_64-unknown-linux-gnu

# Deploy courier to remote server(s) via Ansible.
courier-deploy:
    cd apps/courier/deploy && ansible-playbook playbook.yml

# Run the APNS push relay (dev).
courier-run *ARGS:
    cargo run -p leetium-courier -- {{ARGS}}
