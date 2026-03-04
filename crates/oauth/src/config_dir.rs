use std::path::PathBuf;

/// Returns the configured Leetium config directory.
///
/// Resolution order comes from `leetium_config::config_dir()`:
/// 1. programmatic override (`set_config_dir`)
/// 2. `LEETIUM_CONFIG_DIR`
/// 3. `~/.config/leetium`
pub fn leetium_config_dir() -> PathBuf {
    leetium_config::config_dir().unwrap_or_else(|| PathBuf::from(".config/leetium"))
}
