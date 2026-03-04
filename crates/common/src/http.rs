use std::sync::OnceLock;

static SHARED_CLIENT: OnceLock<reqwest::Client> = OnceLock::new();

/// Initialize the shared HTTP client with optional proxy.
/// Call once at gateway startup; subsequent calls are no-ops.
pub fn init_shared_http_client(proxy_url: Option<&str>) {
    let _ = SHARED_CLIENT.set(build_http_client(proxy_url));
}

/// Shared HTTP client for tools that don't need custom configuration.
///
/// Reusing a single `reqwest::Client` avoids per-request connection pool,
/// DNS resolver, and TLS session cache overhead — significant on
/// memory-constrained devices.
///
/// Falls back to a plain client if [`init_shared_http_client`] was never
/// called (e.g. in tests).
pub fn shared_http_client() -> &'static reqwest::Client {
    SHARED_CLIENT.get_or_init(reqwest::Client::new)
}

/// Build a `reqwest::Client` with optional proxy configuration.
pub fn build_http_client(proxy_url: Option<&str>) -> reqwest::Client {
    let mut builder = reqwest::Client::builder();
    if let Some(url) = proxy_url {
        if let Ok(proxy) = reqwest::Proxy::all(url) {
            let proxy = proxy.no_proxy(reqwest::NoProxy::from_string("localhost,127.0.0.1,::1"));
            builder = builder.proxy(proxy);
        }
    }
    builder.build().unwrap_or_else(|_| reqwest::Client::new())
}
