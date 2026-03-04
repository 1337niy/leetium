//! CalDAV integration crate for leetium.
//!
//! Provides CalDAV client functionality and an `AgentTool` implementation
//! for calendar CRUD operations. Supports Fastmail, iCloud, and generic
//! CalDAV servers.

pub mod client;
pub mod discovery;
pub mod ical;
pub mod tool;
pub mod types;
