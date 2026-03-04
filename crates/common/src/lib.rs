//! Shared types, error definitions, and utilities used across all leetium crates.

pub mod error;
pub mod hooks;
pub mod http;
pub mod types;

pub use error::{Error, FromMessage, LeetiumError, Result};
