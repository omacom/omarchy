//! Bounded host-observable policy decisions. No desktop names, notification
//! commands, plugin-supplied prose, paths or arguments cross this contract.
use crate::{notification::Budget, operation::Status, requests::Kind};
use std::{io, time::Instant};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u32)]
pub enum BlockedAction {
  Notification = 1,
  Settings = 2,
  OpenUrl = 3,
  Http = 4,
  Exec = 5,
}

impl BlockedAction {
  pub(crate) fn decode(value: u64) -> io::Result<Self> {
    match value {
      1 => Ok(Self::Notification),
      2 => Ok(Self::Settings),
      3 => Ok(Self::OpenUrl),
      4 => Ok(Self::Http),
      5 => Ok(Self::Exec),
      _ => Err(io::Error::other("unknown blocked action")),
    }
  }
}

pub(crate) struct Events {
  pending: Option<BlockedAction>,
  budget: Budget,
}

impl Events {
  pub(crate) fn new(now: Instant) -> Self {
    Self {
      pending: None,
      budget: Budget::new(now, 2, 30),
    }
  }
  pub(crate) fn rejected(&mut self, kind: Kind, error: &io::Error, now: Instant) {
    if Status::from_error(error) != Status::Denied || !self.budget.take(now) {
      return;
    }
    self.pending = Some(match kind {
      Kind::Notification => BlockedAction::Notification,
      Kind::Settings => BlockedAction::Settings,
      Kind::OpenUrl => BlockedAction::OpenUrl,
      Kind::Http => BlockedAction::Http,
      Kind::Exec => BlockedAction::Exec,
    });
  }
  pub(crate) fn take(&mut self) -> Option<BlockedAction> {
    self.pending.take()
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::time::Duration;
  #[test]
  fn only_known_policy_denials_emit_bounded_events() {
    let now = Instant::now();
    let mut events = Events::new(now);
    for status in [
      Status::Failed,
      Status::Unavailable,
      Status::Invalid,
      Status::Busy,
      Status::RateLimited,
      Status::TimedOut,
    ] {
      events.rejected(Kind::Exec, &status.error(), now);
      assert_eq!(events.take(), None);
    }
    for _ in 0..2 {
      events.rejected(Kind::Exec, &Status::Denied.error(), now);
      assert_eq!(events.take(), Some(BlockedAction::Exec));
    }
    events.rejected(Kind::Http, &Status::Denied.error(), now);
    assert_eq!(events.take(), None);
    events.rejected(
      Kind::Http,
      &Status::Denied.error(),
      now + Duration::from_secs(30),
    );
    assert_eq!(events.take(), Some(BlockedAction::Http));
    for invalid in [0, 6, u64::MAX] {
      assert!(BlockedAction::decode(invalid).is_err());
    }
  }
}
