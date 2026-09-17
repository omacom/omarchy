//! Ward: trusted plugin isolation and supervision primitives. Callers still own
//! revision approval, host-connection admission, and explicit resource grants.
//! These modules do not yet constitute an integrated shell plugin system.

pub mod audio;
mod authority;
pub mod network_proxy;
pub mod channel;
pub mod context;
pub mod controller;
pub mod exec;
mod exec_files;
pub mod exec_policy;
pub mod geometry;
pub mod grants;
#[cfg(feature = "graphics")]
pub mod graphics;
pub mod host_job;
pub mod http;
pub mod management;
pub mod media;
pub mod notification;
pub mod operation;
mod payload;
pub mod presentation;
#[cfg(feature = "qt-bridge")]
mod qt;
pub mod requests;
pub mod revision;
pub mod runtime;
pub mod sandbox;
pub mod security;
pub mod session;
pub mod settings;
pub mod store;
pub mod supervisor;
pub mod topology;
pub mod worker;
