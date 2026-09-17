//! Bounded worker requests share one admission, delivery and cleanup loop.
use crate::{
  channel::{Channel, Listener, Packet},
  context::UiContext,
  controller::Control,
  notification::{Budget, Request as Notification},
  operation::{Status, reply},
};
use serde::{Deserialize, Serialize};
use std::{
  fs::{File, OpenOptions},
  io,
  os::unix::fs::OpenOptionsExt,
  path::{Path, PathBuf},
  process::{Child, Command, Stdio},
  time::{Duration, Instant},
};

#[derive(Clone, Copy)]
pub enum Kind {
  Notification,
  Settings,
  OpenUrl,
  Http,
  Exec,
}

enum Request {
  Notification(Notification),
  Settings(UiContext),
  OpenUrl(OpenUrl),
  Http(crate::http::Request),
  Exec(crate::exec::Request),
  UiMetadata(Control),
}

#[derive(Clone, Copy, Deserialize, Serialize)]
#[serde(rename_all = "lowercase")]
enum BrowserMode {
  Browser,
  Webapp,
}

#[derive(Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OpenUrl {
  version: u32,
  mode: BrowserMode,
  url: String,
}

impl OpenUrl {
  fn validate(&self) -> io::Result<()> {
    let web_address = self.url.split_once("://").is_some_and(|(scheme, rest)| {
      (scheme.eq_ignore_ascii_case("http") || scheme.eq_ignore_ascii_case("https"))
        && !rest.split(['/', '?', '#']).next().unwrap_or("").is_empty()
    });
    if self.version != 1
      || self.url.len() > 2048
      || !web_address
      || self
        .url
        .chars()
        .any(|ch| ch.is_control() || ch.is_whitespace() || ch == '\\')
    {
      return Err(invalid("only bounded HTTP(S) links are allowed"));
    }
    Ok(())
  }
}

impl Request {
  fn decode(packet: Packet) -> io::Result<Self> {
    if packet.bytes == crate::exec::TAG {
      return crate::exec::Request::decode(packet).map(Self::Exec);
    }
    if packet.bytes == crate::http::TAG {
      return crate::http::Request::decode(packet).map(Self::Http);
    }
    if packet.bytes.starts_with(b"OPH\x01") {
      match Control::decode(packet)? {
        Control::Context(context)
          if context.theme.is_none()
            && context.panel.is_none()
            && context.geometry.is_none()
            && context.views.is_none()
            && context.bar.is_none() =>
        {
          Ok(Self::Settings(context))
        }
        state @ (Control::PanelState { .. }
        | Control::WidgetSize { .. }
        | Control::ViewSize { .. }
        | Control::PanelSwitch { .. }) => Ok(Self::UiMetadata(state)),
        _ => Err(invalid("invalid worker UI request")),
      }
    } else {
      if packet.fds.is_empty()
        && packet.bytes.len() <= crate::channel::MAX_BYTES
        && let Ok(request) = serde_json::from_slice::<OpenUrl>(&packet.bytes)
      {
        request.validate()?;
        return Ok(Self::OpenUrl(request));
      }
      Notification::decode(packet).map(Self::Notification)
    }
  }

  fn kind(&self) -> Option<Kind> {
    match self {
      Self::Notification(_) => Some(Kind::Notification),
      Self::Settings(_) => Some(Kind::Settings),
      Self::OpenUrl(_) => Some(Kind::OpenUrl),
      Self::Http(_) => Some(Kind::Http),
      Self::Exec(_) => Some(Kind::Exec),
      Self::UiMetadata(_) => None,
    }
  }

  fn command(&self, directory: &Path, id: &str) -> io::Result<Command> {
    let (helper, args) = match self {
      Self::UiMetadata(_) => return Err(invalid("UI metadata is not a host effect")),
      Self::Http(_) => return Err(invalid("HTTP uses the fixed native transport helper")),
      Self::Exec(_) => return Err(invalid("exec uses a selected supervised host job")),
      Self::Notification(request) => ("omarchy-notification-send", request.arguments(id)?),
      Self::OpenUrl(request) => {
        request.validate()?;
        (
          "omarchy-plugin-url-open",
          vec![
            id.into(),
            match request.mode {
              BrowserMode::Browser => "browser".into(),
              BrowserMode::Webapp => "webapp".into(),
            },
            request.url.clone(),
          ],
        )
      }
      Self::Settings(context) => {
        let mut settings = context.settings.clone();
        if settings
          .remove("id")
          .is_some_and(|value| value.as_str() != Some(id))
          || ["sandbox", "__proto__", "constructor", "prototype"]
            .iter()
            .any(|key| settings.contains_key(*key))
        {
          return Err(invalid(
            "settings cannot change plugin identity or host structure",
          ));
        }
        (
          "omarchy-plugin-settings-apply",
          vec![id.into(), serde_json::to_string(&settings)?],
        )
      }
    };
    let mut command = Command::new("/usr/bin/timeout");
    command
      .args(["--signal=KILL", "1s"])
      .arg(directory.join(helper))
      .args(args)
      .stdin(Stdio::null())
      .stdout(Stdio::null())
      .stderr(Stdio::null());
    Ok(command)
  }
}

/// Explicit operations, with no worker-selected method, executable or identity.
/// The socket is mounted only for admitted host-request grants. All connected
/// peers must also belong to this controller's kernel-owned unit.
pub struct Broker {
  // Own UI metadata, never admission/readiness or a grant. Dispatch coalesces
  // it within the existing authenticated, rate-limited request boundary.
  pub(crate) panel_state: Option<Control>,
  pub(crate) widget_size: Option<Control>,
  pub(crate) view_sizes: std::collections::BTreeMap<u32, Control>,
  pub(crate) panel_switch: Option<Control>,
  pub(crate) security: crate::security::Events,
  listener: Listener,
  socket: File,
  directory: PathBuf,
  executable: PathBuf,
  clients: Vec<(Channel, Instant)>,
  // Host-chosen resolution directories for `$OMARCHY_PLUGIN_PATH` and
  // `$OMARCHY_PLUGIN_DATA` in exec argv/trees. Only directories that are
  // actually admitted are present (assets when an exec grant exists, data when
  // storage is granted).
  paths: Vec<crate::exec_policy::PluginDir>,
  // Three independent effect slots and twelve bounded HTTP slots. Each slot
  // has the same per-request deadline and response-size ceiling.
  deliveries: [Option<Delivery>; 15],
  budgets: [Budget; 4],
  // Bound executable snapshot memory within the existing controller ceiling.
  // Worker helpers retry only explicit not-started Busy/RateLimited replies.
  jobs: [Option<ExecDelivery>; 2],
  exec_budget: Budget,
  environment: crate::host_job::Environment,
  admission_window: Instant,
  admissions: u32,
}

enum ExecState {
  Preparing(crate::exec::Preparation),
  Running(crate::host_job::Job),
}

struct ExecDelivery {
  state: ExecState,
  channel: Option<Channel>,
}

struct Delivery {
  child: Child,
  channel: Channel,
  started: Instant,
  kind: Kind,
  output: Option<File>,
}

impl Drop for Delivery {
  fn drop(&mut self) {
    let _ = self.child.kill();
    let _ = self.child.try_wait();
  }
}

impl Broker {
  pub fn start(
    root: &Path,
    executable: &Path,
    paths: Vec<crate::exec_policy::PluginDir>,
  ) -> io::Result<Self> {
    if !executable.is_absolute() || !executable.is_file() {
      return Err(invalid(
        "native request helper requires an absolute executable",
      ));
    }
    let directory = PathBuf::from(
      std::env::var_os("OMARCHY_PATH")
        .ok_or_else(|| invalid("OMARCHY_PATH is required for host requests"))?,
    )
    .join("bin");
    if !directory.is_absolute() || !directory.is_dir() {
      return Err(invalid("host helpers unavailable"));
    }
    let path = root.join("notify");
    let listener = Listener::bind(&path)?;
    let socket = OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
      .open(path)?;
    let now = Instant::now();
    Ok(Self {
      panel_state: None,
      widget_size: None,
      view_sizes: std::collections::BTreeMap::new(),
      panel_switch: None,
      security: crate::security::Events::new(now),
      listener,
      socket,
      directory,
      executable: executable.to_path_buf(),
      clients: Vec::new(),
      paths,
      deliveries: std::array::from_fn(|_| None),
      budgets: [
        Budget::new(now, 2, 30),
        Budget::new(now, 8, 1),
        // Navigation is interactive; normal repeated clicks must not incur a
        // notification-style thirty-second cooldown. Keep only a burst bound.
        Budget::new(now, 8, 1),
        Budget::new(now, 128, 1),
      ],
      jobs: std::array::from_fn(|_| None),
      exec_budget: Budget::new(now, 32, 1),
      environment: crate::host_job::Environment::capture()?,
      admission_window: now,
      admissions: 0,
    })
  }

  pub(crate) fn socket(&self) -> &File {
    &self.socket
  }

  pub fn dispatch(&mut self, approval: &crate::controller::Approval) -> io::Result<()> {
    let now = Instant::now();
    for slot in &mut self.jobs {
      // One invocation per connection; a canceled forwarder also cancels its job.
      if slot.as_ref().and_then(|job| job.channel.as_ref()).is_some_and(|channel| {
        !matches!(channel.receive(), Err(error) if error.kind() == io::ErrorKind::WouldBlock)
      }) {
        if let Some(ExecDelivery { state: ExecState::Preparing(_), channel }) = slot {
          *channel = None;
        } else {
          *slot = None;
          continue;
        }
      }
      if let Some(ExecDelivery {
        state: ExecState::Preparing(preparation),
        channel,
      }) = slot
      {
        if preparation.started.elapsed() >= crate::host_job::PREPARATION_TIMEOUT
          && let Some(channel) = channel.take()
        {
          let _ = reply(&channel, Status::TimedOut);
        }
        if !preparation.is_finished() {
          continue;
        }
        let ExecDelivery {
          state: ExecState::Preparing(preparation),
          channel,
        } = slot.take().unwrap()
        else {
          unreachable!()
        };
        if let Some(channel) = channel {
          // Discard observed cancellations and recheck live authority under
          // its lock immediately before executing the sealed bytes.
          let result = approval.with_request(Kind::Exec, |_, grants| {
            preparation.start(&grants.exec, &self.environment, &self.paths)
          });
          match result {
            Ok(job) => {
              *slot = Some(ExecDelivery {
                state: ExecState::Running(job),
                channel: Some(channel),
              })
            }
            Err(error) => {
              self.security.rejected(Kind::Exec, &error, now);
              let _ = reply(&channel, Status::from_error(&error));
            }
          }
        }
        continue;
      }
      if let Some(ExecDelivery {
        state: ExecState::Running(job),
        ..
      }) = slot
      {
        let result = job.poll();
        if !matches!(result, Ok(None)) {
          let channel = slot.take().unwrap().channel.unwrap();
          approval.with_request(Kind::Exec, |_, _| {
            use std::os::fd::AsFd;
            match result.and_then(|output| crate::exec::response(output.unwrap())) {
              Ok(output) => {
                let _ = channel.send(crate::exec::TAG, &[output.as_fd()]);
              }
              Err(error) => {
                let _ = reply(&channel, Status::from_error(&error));
              }
            }
            Ok(())
          })?;
        }
      }
    }
    for slot in &mut self.deliveries {
      if let Some(delivery) = slot {
        let status = delivery.child.try_wait()?;
        let timeout = if matches!(delivery.kind, Kind::Http) {
          crate::http::TIMEOUT
        } else {
          Duration::from_secs(2)
        };
        if status.is_some() || now.duration_since(delivery.started) >= timeout {
          let delivery = slot.take().unwrap();
          approval.with_request(delivery.kind, |_, _| {
            if status.is_some_and(|status| status.success())
              && let Some(output) = &delivery.output
              && crate::payload::finish(output, crate::http::MAX_RESPONSE).is_ok()
            {
              use std::os::fd::AsFd;
              let _ = delivery.channel.send(crate::http::TAG, &[output.as_fd()]);
              return Ok(());
            }
            let status =
              if delivery.output.is_none() && status.is_some_and(|status| status.success()) {
                Status::Completed
              } else if status.is_none() {
                Status::TimedOut
              } else {
                Status::Failed
              };
            let _ = reply(&delivery.channel, status);
            Ok(())
          })?;
        }
      }
    }
    if now.duration_since(self.admission_window) >= Duration::from_secs(1) {
      self.admission_window = now;
      self.admissions = 0;
    }
    for _ in 0..4 {
      // Stop accepting until the next window; even failed authentication is
      // charged, before doing procfs/pidfd work. The kernel backlog is bounded.
      if self.admissions >= 32 || self.clients.len() >= 4 {
        break;
      }
      let client = match self.listener.accept() {
        Ok(client) => client,
        Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
        Err(error) => return Err(error),
      };
      self.admissions += 1;
      if crate::supervisor::authenticate_member(&client).is_ok() {
        self.clients.push((client, now));
      }
    }
    let mut index = 0;
    while index < self.clients.len() {
      let packet = match self.clients[index].0.receive() {
        Ok(packet) => Some(packet),
        Err(error)
          if error.kind() == io::ErrorKind::WouldBlock
            && now.duration_since(self.clients[index].1) < Duration::from_secs(1) =>
        {
          index += 1;
          continue;
        }
        Err(_) => None,
      };
      let (client, _) = self.clients.swap_remove(index);
      let request = packet.and_then(|packet| Request::decode(packet).ok());
      let Some(request) = request else {
        let _ = reply(&client, Status::Invalid);
        continue;
      };
      let Some(kind) = request.kind() else {
        if let Request::UiMetadata(state) = request {
          approval.check()?;
          if let Control::ViewSize { view, .. } = state {
            if self.view_sizes.len() < 32 || self.view_sizes.contains_key(&view) {
              self.view_sizes.insert(view, state);
            } else {
              let _ = reply(&client, Status::Busy);
              continue;
            }
          } else if matches!(state, Control::WidgetSize { .. }) {
            self.widget_size = Some(state);
          } else if matches!(state, Control::PanelSwitch { .. }) {
            self.panel_switch = Some(state);
          } else {
            self.panel_state = Some(state);
          }
          let _ = reply(&client, Status::Completed);
        }
        continue;
      };
      if let Request::Exec(request) = request {
        let Some(slot) = self.jobs.iter_mut().find(|slot| slot.is_none()) else {
          let _ = reply(&client, Status::Busy);
          continue;
        };
        if !self.exec_budget.take(now) {
          let _ = reply(&client, Status::RateLimited);
          continue;
        }
        match approval.with_request(kind, |_, grants| request.prepare(&grants.exec, &self.paths)) {
          Ok(preparation) => {
            *slot = Some(ExecDelivery {
              state: ExecState::Preparing(preparation),
              channel: Some(client),
            })
          }
          Err(error) => {
            self.security.rejected(kind, &error, now);
            let _ = reply(&client, Status::from_error(&error));
          }
        }
        // Keep admission work bounded; verification proceeds independently of
        // the compositor/input loop within the existing two job slots.
        return Ok(());
      }
      let budget = kind as usize;
      let slot = if matches!(kind, Kind::Http) {
        (3..self.deliveries.len()).find(|index| self.deliveries[*index].is_none())
      } else if self.deliveries[budget].is_none() {
        Some(budget)
      } else {
        None
      };
      let Some(slot) = slot else {
        let _ = reply(&client, Status::Busy);
        continue;
      };
      if !self.budgets[budget].take(now) {
        let _ = reply(&client, Status::RateLimited);
        continue;
      }
      let result = approval.with_request(kind, |id, grants| {
        if let Request::Http(request) = &request {
          return request
            .spawn(&self.executable, &grants.http)
            .map(|(child, output)| (child, Some(output)));
        }
        if let Request::Settings(context) = &request {
          let mut settings = context.settings.clone();
          settings.remove("id"); // The command validates the optional own-id echo.
          if grants.settings.check_write(&settings).is_err() {
            return Err(Status::Denied.error());
          }
        }
        request
          .command(&self.directory, id)
          .map_err(|_| Status::Denied.error())?
          .spawn()
          .map(|child| (child, None))
      });
      match result {
        Ok((child, output)) => {
          self.deliveries[slot] = Some(Delivery {
            child,
            channel: client,
            started: now,
            kind,
            output,
          })
        }
        Err(error) => {
          self.security.rejected(kind, &error, now);
          let _ = reply(&client, Status::from_error(&error));
        }
      }
    }
    Ok(())
  }
}

/// Worker helper: only data travels to the controller. A plugin id in the
/// original inline settings is checked against the admitted id, never selected.
pub fn report_panel_state(serial: &str, open: &str) -> io::Result<()> {
  let state = Control::PanelState {
    serial: serial.parse().map_err(|_| Status::Invalid.error())?,
    open: open.parse().map_err(|_| Status::Invalid.error())?,
  };
  let channel = Channel::connect(Path::new("/run/plugin/ui"))?;
  state.send(&channel)?;
  crate::operation::await_reply(&channel)
}

pub fn report_widget_size(width: &str, height: &str) -> io::Result<()> {
  let size = Control::WidgetSize {
    width: width.parse().map_err(|_| Status::Invalid.error())?,
    height: height.parse().map_err(|_| Status::Invalid.error())?,
  };
  let channel = Channel::connect(Path::new("/run/plugin/ui"))?;
  size.send(&channel)?;
  crate::operation::await_reply(&channel)
}

pub fn report_view_size(view: &str, width: &str, height: &str) -> io::Result<()> {
  let size = Control::ViewSize {
    view: view.parse().map_err(|_| Status::Invalid.error())?,
    width: width.parse().map_err(|_| Status::Invalid.error())?,
    height: height.parse().map_err(|_| Status::Invalid.error())?,
  };
  let channel = Channel::connect(Path::new("/run/plugin/ui"))?;
  size.send(&channel)?;
  crate::operation::await_reply(&channel)
}

// This is a navigation intent, not authority. The trusted host consumes at most
// one matching request after a real Tab gesture in the focused plugin panel.
pub fn switch_panel(direction: &str) -> io::Result<()> {
  let forward = match direction {
    "1" => true,
    "-1" => false,
    _ => return Err(Status::Invalid.error()),
  };
  let channel = Channel::connect(Path::new("/run/plugin/ui"))?;
  Control::PanelSwitch { forward }.send(&channel)?;
  crate::operation::await_reply(&channel)
}

pub fn save_settings(json: &str) -> io::Result<()> {
  if json.len() > 65_000 {
    return Err(Status::Invalid.error());
  }
  let context = UiContext {
    settings: serde_json::from_str(json).map_err(|_| Status::Invalid.error())?,
    theme: None,
    ..UiContext::default()
  };
  let channel = crate::operation::connect(Kind::Settings)?;
  Control::Context(context).send(&channel)?;
  crate::operation::await_reply(&channel)
}

/// A web navigation intent, never a host executable or additional arguments.
pub fn open_url(mode: &str, url: &str) -> io::Result<()> {
  let mode = match mode {
    "browser" => BrowserMode::Browser,
    "webapp" => BrowserMode::Webapp,
    _ => return Err(Status::Invalid.error()),
  };
  let request = OpenUrl {
    version: 1,
    mode,
    url: url.into(),
  };
  request.validate().map_err(|_| Status::Invalid.error())?;
  let channel = crate::operation::connect(Kind::OpenUrl)?;
  channel.send(&serde_json::to_vec(&request)?, &[])?;
  crate::operation::await_reply(&channel)
}

fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::os::fd::AsFd;

  #[test]
  fn worker_cannot_forge_host_blocked_action_events() {
    let (sender, receiver) = Channel::pair().unwrap();
    Control::Blocked(crate::security::BlockedAction::Exec).send(&sender).unwrap();
    assert!(Request::decode(receiver.receive().unwrap()).is_err());
  }

  #[test]
  fn panel_metadata_cannot_select_a_host_effect() {
    let (sender, receiver) = Channel::pair().unwrap();
    Control::PanelState {
      serial: 12,
      open: true,
    }
    .send(&sender)
    .unwrap();
    let request = Request::decode(receiver.receive().unwrap()).unwrap();
    assert!(request.kind().is_none());
    assert!(
      request
        .command(Path::new("/trusted/bin"), "test.widget")
        .is_err()
    );
    Control::WidgetSize {
      width: 64,
      height: 32,
    }
    .send(&sender)
    .unwrap();
    let request = Request::decode(receiver.receive().unwrap()).unwrap();
    assert!(request.kind().is_none());
    assert!(
      request
        .command(Path::new("/trusted/bin"), "test.widget")
        .is_err()
    );
    let forged = UiContext::parse(br#"{"settings":{},"bar":{"x":1,"y":1,"width":40,"height":30,"size":30,"position":"top","visible":true}}"#).unwrap();
    Control::Context(forged).send(&sender).unwrap();
    assert!(Request::decode(receiver.receive().unwrap()).is_err());
    Control::Hello.send(&sender).unwrap();
    assert!(Request::decode(receiver.receive().unwrap()).is_err());
    Control::PanelSwitch { forward: true }
      .send(&sender)
      .unwrap();
    let request = Request::decode(receiver.receive().unwrap()).unwrap();
    assert!(request.kind().is_none());
    assert!(
      request
        .command(Path::new("/trusted/bin"), "test.widget")
        .is_err()
    );
  }

  #[test]
  fn web_links_select_only_fixed_helpers_and_preserve_literal_arguments() {
    let url = "https://example.test/--private?literal=$(touch%20/secret)&quoted='value'";
    for mode in ["browser", "webapp"] {
      let bytes = serde_json::to_vec(&serde_json::json!({
        "version": 1, "mode": mode, "url": url
      }))
      .unwrap();
      let request = Request::decode(Packet { bytes, fds: vec![] }).unwrap();
      let command = request
        .command(Path::new("/trusted/bin"), "test.widget")
        .unwrap();
      assert_eq!(command.get_program(), "/usr/bin/timeout");
      assert_eq!(
        command.get_args().skip(2).collect::<Vec<_>>(),
        [
          "/trusted/bin/omarchy-plugin-url-open",
          "test.widget",
          mode,
          url
        ]
      );
    }
    for url in [
      "--private",
      "file:///secret",
      "javascript:alert(1)",
      "https://",
      "https:///path",
      "https://example.test/\n",
      "https://example.test/ a",
      "https://example.test/\\a",
      &format!("https://example.test/{}", "x".repeat(2048)),
    ] {
      let request = OpenUrl {
        version: 1,
        mode: BrowserMode::Browser,
        url: url.into(),
      };
      assert!(request.validate().is_err(), "accepted {url:?}");
    }
    for value in [
      serde_json::json!({"version": 2, "mode": "browser", "url": url}),
      serde_json::json!({"version": 1, "mode": "shell", "url": url}),
      serde_json::json!({"version": 1, "mode": "browser", "url": url, "exec": "sh"}),
    ] {
      assert!(
        Request::decode(Packet {
          bytes: serde_json::to_vec(&value).unwrap(),
          fds: vec![]
        })
        .is_err()
      );
    }
  }

  #[test]
  fn settings_reuse_sealed_transport_without_selecting_host_authority() {
    let (sender, receiver) = Channel::pair().unwrap();
    let context = UiContext {
      settings: serde_json::from_value(serde_json::json!({
        "id": "test.widget", "text": "$(touch /secret)", "nested": {"value": "x".repeat(8192)}
      }))
      .unwrap(),
      theme: None,
      ..UiContext::default()
    };
    Control::Context(context.clone()).send(&sender).unwrap();
    let request = Request::decode(receiver.receive().unwrap()).unwrap();
    let command = request
      .command(Path::new("/trusted/bin"), "test.widget")
      .unwrap();
    let args = command.get_args().collect::<Vec<_>>();
    assert_eq!(command.get_program(), "/usr/bin/timeout");
    assert_eq!(args.len(), 5);
    assert_eq!(args[2], "/trusted/bin/omarchy-plugin-settings-apply");
    assert_eq!(args[3], "test.widget");
    let settings: serde_json::Value = serde_json::from_str(args[4].to_str().unwrap()).unwrap();
    assert!(settings.get("id").is_none());
    assert_eq!(settings["text"], "$(touch /secret)");
    assert!(
      request
        .command(Path::new("/trusted/bin"), "other.widget")
        .is_err()
    );
    for key in ["sandbox", "__proto__", "constructor", "prototype"] {
      let mut forged = context.clone();
      forged.settings.insert(key.into(), true.into());
      assert!(
        Request::Settings(forged)
          .command(Path::new("/trusted/bin"), "test.widget")
          .is_err()
      );
    }
    Control::Ping(1).send(&sender).unwrap();
    assert!(Request::decode(receiver.receive().unwrap()).is_err());
    // Replacing the required sealed descriptor with an ordinary file fails.
    Control::Context(context).send(&sender).unwrap();
    let packet = receiver.receive().unwrap();
    sender
      .send(&packet.bytes, &[File::open("/dev/null").unwrap().as_fd()])
      .unwrap();
    assert!(Request::decode(receiver.receive().unwrap()).is_err());
  }
}
