//! Notification text policy and worker-side helper; transport is shared with
//! other explicitly granted operations in requests.rs.
use crate::channel::Packet;
use serde::{Deserialize, Serialize};
use std::{io, time::Instant};

#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Request {
  version: u32,
  title: String,
  body: String,
}

impl Request {
  pub fn new(title: String, body: String) -> io::Result<Self> {
    let request = Self {
      version: 1,
      title,
      body,
    };
    request.validate()?;
    Ok(request)
  }

  pub fn decode(packet: Packet) -> io::Result<Self> {
    if !packet.fds.is_empty() || packet.bytes.len() > crate::channel::MAX_BYTES {
      return Err(invalid(
        "notification packet exceeds limits or carries descriptors",
      ));
    }
    let request: Self =
      serde_json::from_slice(&packet.bytes).map_err(|_| invalid("invalid notification request"))?;
    request.validate()?;
    Ok(request)
  }

  fn validate(&self) -> io::Result<()> {
    if self.version != 1
      || self.title.is_empty()
      || self.title.len() > 160
      || self.body.len() > 2048
      || self.title.chars().any(|ch| forbidden(ch, false))
      || self.body.chars().any(|ch| forbidden(ch, true))
    {
      return Err(invalid("notification text exceeds its allowed format"));
    }
    Ok(())
  }

  /// Arguments for the existing helper; no shell re-parsing. Both positionals
  /// have trusted prefixes because that helper recognizes options in either slot.
  pub(crate) fn arguments(&self, id: &str) -> io::Result<Vec<String>> {
    crate::grants::validate_id(id)?;
    self.validate()?;
    Ok(vec![
      "--app-name".into(),
      format!("omarchy-ward-{id}"),
      "--urgency".into(),
      "low".into(),
      "--expire-time".into(),
      "5000".into(),
      format!("Plugin {id}: {}", self.title),
      format!("Message: {}", escape_body(&self.body)),
    ])
  }
}

/// Worker-side helper. Its own wait is bounded; the controller and GUI never
/// wait synchronously for the requester or notification delivery.
pub fn request(title: String, body: String) -> io::Result<()> {
  let request = Request::new(title, body).map_err(|_| crate::operation::Status::Invalid.error())?;
  let channel = crate::operation::connect(crate::requests::Kind::Notification)?;
  channel.send(&serde_json::to_vec(&request)?, &[])?;
  crate::operation::await_reply(&channel)
}

pub(crate) struct Budget {
  tokens: u8,
  capacity: u8,
  seconds: u64,
  refilled: Instant,
}
impl Budget {
  pub fn new(now: Instant, capacity: u8, seconds: u64) -> Self {
    Self {
      tokens: capacity,
      capacity,
      seconds,
      refilled: now,
    }
  }
  pub fn take(&mut self, now: Instant) -> bool {
    let refill = now.saturating_duration_since(self.refilled).as_secs() / self.seconds;
    if refill > 0 {
      self.tokens = self
        .tokens
        .saturating_add(refill.min(self.capacity as u64) as u8)
        .min(self.capacity);
      self.refilled = now;
    }
    if self.tokens == 0 {
      false
    } else {
      self.tokens -= 1;
      true
    }
  }
}

fn forbidden(ch: char, body: bool) -> bool {
  (ch.is_control() && !(body && ch == '\n'))
    || matches!(ch, '\u{061c}' | '\u{200e}' | '\u{200f}' | '\u{202a}'..='\u{202e}' | '\u{2066}'..='\u{2069}')
}
fn escape_body(body: &str) -> String {
  body
    .replace('&', "&amp;")
    .replace('<', "&lt;")
    .replace('>', "&gt;")
}
fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::{path::Path, process::Command, time::Duration};
  #[test]
  fn request_cannot_select_authority_or_smuggle_actions() {
    let packet = |bytes: &[u8]| Packet {
      bytes: bytes.to_vec(),
      fds: Vec::new(),
    };
    for bytes in [
      br#"{"version":1,"title":"ok","body":"","id":"other"}"#.as_slice(),
      br#"{"version":1,"title":"ok","body":"","exec":"sh"}"#,
      br#"{"version":2,"title":"ok","body":""}"#,
      br#"{"version":1,"title":"a","title":"b","body":""}"#,
    ] {
      assert!(Request::decode(packet(bytes)).is_err());
    }
    for text in ["\0", "\n", "\u{202e}", "\u{2066}"] {
      assert!(Request::new(text.into(), String::new()).is_err());
    }
    assert!(Request::new("x".repeat(161), String::new()).is_err());
    assert!(Request::new("x".into(), "x".repeat(2049)).is_err());
    let request = Request::new(
      "--image=/secret".into(),
      "--exec <img src='/secret'/> & body".into(),
    )
    .unwrap();
    let args = request.arguments("test.widget").unwrap();
    assert_eq!(args.len(), 8);
    assert_eq!(args[6], "Plugin test.widget: --image=/secret");
    assert_eq!(
      args[7],
      "Message: --exec &lt;img src='/secret'/&gt; &amp; body"
    );
    assert!(
      !args
        .iter()
        .any(|arg| arg == "--exec" || arg == "--image" || arg == "--replace-id")
    );
  }

  #[test]
  fn notification_budget_is_small_and_replenishes_without_sleeping() {
    let start = Instant::now();
    let mut budget = Budget::new(start, 2, 30);
    assert!(budget.take(start));
    assert!(budget.take(start));
    assert!(!budget.take(start));
    assert!(!budget.take(start + Duration::from_secs(29)));
    assert!(budget.take(start + Duration::from_secs(30)));
    assert!(!budget.take(start + Duration::from_secs(30)));
    let later = start + Duration::from_secs(300);
    assert!(budget.take(later));
    assert!(budget.take(later));
    assert!(!budget.take(later));
  }

  #[test]
  fn existing_helper_emits_only_fixed_notification_fields() {
    use std::{fs, os::unix::fs::PermissionsExt};
    let root = tempfile::tempdir().unwrap();
    // Exercise the real helper's option parser without connecting to any bus.
    let busctl = root.path().join("busctl");
    fs::write(
      &busctl,
      "#!/bin/bash\nprintf '%s\\0' \"$@\" > \"$OMARCHY_NOTIFICATION_CAPTURE\"\n",
    )
    .unwrap();
    fs::set_permissions(&busctl, fs::Permissions::from_mode(0o700)).unwrap();
    let capture = root.path().join("record");
    let request = Request::new(
      "--image=/secret".into(),
      "--exec <img src='/secret'/> & body".into(),
    )
    .unwrap();
    let status = Command::new(
      Path::new(env!("CARGO_MANIFEST_DIR")).join("../../bin/omarchy-notification-send"),
    )
    .args(request.arguments("test.widget").unwrap())
    .env_clear()
    .env("PATH", root.path())
    .env("OMARCHY_NOTIFICATION_CAPTURE", &capture)
    .status()
    .unwrap();
    assert!(status.success());
    let bytes = fs::read(capture).unwrap();
    let args = bytes
      .split(|byte| *byte == 0)
      .map(|arg| std::str::from_utf8(arg).unwrap())
      .collect::<Vec<_>>();
    assert_eq!(
      args,
      [
        "--user",
        "--",
        "call",
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        "Notify",
        "susssasa{sv}i",
        "omarchy-ward-test.widget",
        "0",
        "",
        "Plugin test.widget: --image=/secret",
        "Message: --exec &lt;img src='/secret'/&gt; &amp; body",
        "0",
        "1",
        "urgency",
        "y",
        "0",
        "5000",
        "",
      ]
    );
  }
}
