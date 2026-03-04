use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    /// WhatsApp client/protocol error (from wa-rs, which returns `anyhow::Error`).
    #[error("whatsapp: {message}")]
    Whatsapp { message: String },

    /// Persistent store error.
    #[error("store: {message}")]
    Store { message: String },

    /// Channel layer error.
    #[error(transparent)]
    Channel(#[from] leetium_channels::Error),
}

pub type Result<T> = std::result::Result<T, Error>;
