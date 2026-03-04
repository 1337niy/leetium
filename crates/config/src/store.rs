use async_trait::async_trait;
use sqlx::{AnyPool, Row};
use std::path::PathBuf;

use crate::schema::LeetiumConfig;

/// Trait for the configuration store backing the LeetiumConfig struct.
#[async_trait]
pub trait ConfigStore: Send + Sync {
    /// Load the resolved configuration.
    async fn load(&self) -> anyhow::Result<LeetiumConfig>;

    /// Save the raw configuration.
    async fn save(&self, config: &LeetiumConfig) -> anyhow::Result<()>;

    /// Check if the configuration exists in the store.
    async fn exists(&self) -> anyhow::Result<bool>;
}

/// A File-backed ConfigStore wrapping the existing `loader` logic.
pub struct FileConfigStore {
    path: PathBuf,
}

impl FileConfigStore {
    pub fn new(path: PathBuf) -> Self {
        Self { path }
    }
}

#[async_trait]
impl ConfigStore for FileConfigStore {
    async fn load(&self) -> anyhow::Result<LeetiumConfig> {
        let path_clone = self.path.clone();
        tokio::task::spawn_blocking(move || crate::loader::load_config(&path_clone))
            .await
            .map_err(|e| anyhow::anyhow!("Task failed: {}", e))?
            .map_err(|e| anyhow::anyhow!("Config load failed: {}", e))
    }

    async fn save(&self, config: &LeetiumConfig) -> anyhow::Result<()> {
        let path_clone = self.path.clone();
        let config_clone = config.clone();
        tokio::task::spawn_blocking(move || {
            crate::loader::save_config_to_path(&path_clone, &config_clone)
        })
        .await
        .map_err(|e| anyhow::anyhow!("Task failed: {}", e))?
        .map_err(|e| anyhow::anyhow!("Config save failed: {}", e))?;
        Ok(())
    }

    async fn exists(&self) -> anyhow::Result<bool> {
        Ok(self.path.exists())
    }
}

/// A SQLite-backed ConfigStore mapping key to JSON payload.
pub struct SqliteConfigStore {
    pool: AnyPool,
    id: String,
}

impl SqliteConfigStore {
    pub fn new(pool: AnyPool, id: impl Into<String>) -> Self {
        Self {
            pool,
            id: id.into(),
        }
    }

    pub async fn run_migrations(pool: &AnyPool) -> anyhow::Result<()> {
        let _conn = pool.acquire().await?;
        sqlx::query(
            r#"
            CREATE TABLE IF NOT EXISTS config_documents (
                id TEXT PRIMARY KEY,
                format_version INTEGER NOT NULL DEFAULT 1,
                payload_json TEXT NOT NULL,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
            "#,
        )
        .execute(pool)
        .await?;
        Ok(())
    }
}

#[async_trait]
impl ConfigStore for SqliteConfigStore {
    async fn load(&self) -> anyhow::Result<LeetiumConfig> {
        let row = sqlx::query("SELECT payload_json FROM config_documents WHERE id = $1")
            .bind(&self.id)
            .fetch_optional(&self.pool)
            .await?;

        if let Some(row) = row {
            let json_str: String = row.try_get("payload_json")?;
            // Pass through substitute_env so that env vars work out of the db JSON
            let raw = crate::env_subst::substitute_env(&json_str);
            let config: LeetiumConfig = serde_json::from_str(&raw)?;
            // Apply environment overrides for compatibility
            let config = crate::loader::apply_env_overrides(config);
            Ok(config)
        } else {
            anyhow::bail!("Config '{}' not found in store", self.id)
        }
    }

    async fn save(&self, config: &LeetiumConfig) -> anyhow::Result<()> {
        let serialized = serde_json::to_string(config)?;
        sqlx::query(
            r#"
            INSERT INTO config_documents (id, payload_json, updated_at)
            VALUES ($1, $2, CURRENT_TIMESTAMP)
            ON CONFLICT(id) DO UPDATE SET 
                payload_json = excluded.payload_json,
                updated_at = CURRENT_TIMESTAMP
            "#,
        )
        .bind(&self.id)
        .bind(&serialized)
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn exists(&self) -> anyhow::Result<bool> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM config_documents WHERE id = $1")
            .bind(&self.id)
            .fetch_one(&self.pool)
            .await?;
        Ok(count.0 > 0)
    }
}
