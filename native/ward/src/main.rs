use base64::{Engine, engine::general_purpose::STANDARD};
use omarchy_ward::operation::Status;
use std::{
  ffi::OsString,
  io::{self, Write},
  os::{
    fd::AsFd,
    unix::process::{CommandExt, ExitStatusExt},
  },
  process::{Command, ExitCode},
};

#[derive(serde::Serialize)]
#[serde(untagged)]
enum Bytes {
  Text(String),
  Binary { base64: String },
}

impl From<Vec<u8>> for Bytes {
  fn from(bytes: Vec<u8>) -> Self {
    match String::from_utf8(bytes) {
      Ok(text) => Self::Text(text),
      Err(error) => Self::Binary {
        base64: STANDARD.encode(error.as_bytes()),
      },
    }
  }
}

#[derive(serde::Serialize)]
#[serde(rename_all = "camelCase")]
struct Outcome {
  version: u32,
  status: Status,
  #[serde(skip_serializing_if = "Option::is_none")]
  exit_code: Option<i32>,
  #[serde(skip_serializing_if = "Option::is_none")]
  signal: Option<i32>,
  #[serde(skip_serializing_if = "Option::is_none")]
  http_status: Option<u16>,
  #[serde(skip_serializing_if = "Option::is_none")]
  headers: Option<std::collections::BTreeMap<String, String>>,
  #[serde(skip_serializing_if = "Option::is_none")]
  stdout: Option<Bytes>,
  #[serde(skip_serializing_if = "Option::is_none")]
  stderr: Option<Bytes>,
  #[serde(skip_serializing_if = "Option::is_none")]
  body: Option<Bytes>,
}

impl Outcome {
  fn status(status: Status) -> Self {
    Self {
      version: 1,
      status,
      exit_code: None,
      signal: None,
      http_status: None,
      headers: None,
      stdout: None,
      stderr: None,
      body: None,
    }
  }

  fn code(&self) -> u8 {
    self.exit_code.unwrap_or_else(|| {
      self.signal.map(|signal| 128 + signal).unwrap_or(i32::from(
        self.http_status.is_some_and(|status| status >= 400),
      ))
    }) as u8
  }
}

fn main() -> io::Result<ExitCode> {
  let args = std::env::args_os().skip(1).collect::<Vec<_>>();
  let (json, args) = match args.as_slice() {
    [flag, rest @ ..] if flag == "--json" => (true, rest),
    args => (false, args),
  };
  let result = run(args, json);
  if json {
    let outcome = result.unwrap_or_else(|error| Outcome::status(Status::from_error(&error)));
    let mut stdout = io::stdout().lock();
    serde_json::to_writer(&mut stdout, &outcome)?;
    stdout.write_all(b"\n")?;
    Ok(ExitCode::from(u8::from(
      outcome.status != Status::Completed,
    )))
  } else {
    result.map(|outcome| ExitCode::from(outcome.code()))
  }
}

fn run(args: &[OsString], json: bool) -> io::Result<Outcome> {
  let mut outcome = Outcome::status(Status::Completed);
  match args {
    [mode, name, argv @ ..] if mode == "--exec" => {
      let text = |value: &std::ffi::OsString| {
        value
          .to_str()
          .map(str::to_owned)
          .ok_or_else(|| Status::Invalid.error())
      };
      let output = omarchy_ward::exec::request(
        text(name)?,
        argv.iter().map(text).collect::<io::Result<_>>()?,
      )?;
      outcome.exit_code = output.status.code();
      outcome.signal = output.status.signal();
      if json {
        outcome.stdout = Some(output.stdout.into());
        outcome.stderr = Some(output.stderr.into());
      } else {
        io::stdout().write_all(&output.stdout)?;
        io::stderr().write_all(&output.stderr)?;
      }
    }
    [mode, rest @ ..] if mode == "--http" && (rest.is_empty() || (!json && rest.len() == 1)) => {
      let (head, body) = omarchy_ward::http::request()?;
      outcome.http_status = Some(head.status);
      if json {
        outcome.headers = Some(head.headers);
        outcome.body = Some(body.into());
      } else {
        if let Some(path) = rest.first() {
          std::fs::write(path, serde_json::to_vec(&head)?)?;
        }
        io::stdout().write_all(&body)?;
        if head.status >= 400 {
          eprintln!("HTTP status {}", head.status);
        }
      }
    }
    // Internal management/worker modes can write arbitrary stdout or replace
    // this process. They are not operations with a JSON result contract.
    [mode, ..]
      if json
        && !matches!(
          mode.to_str(),
          Some("--notify" | "--settings" | "--open-url" | "--panel-state")
        ) =>
    {
      return Err(Status::Invalid.error());
    }
    _ => run_internal(args)?,
  }
  Ok(outcome)
}

fn run_internal(args: &[OsString]) -> io::Result<()> {
  match args {
    [mode] if mode == "--network-proxy-execute" => omarchy_ward::network_proxy::execute(),
    [mode] if mode == "--network-proxy-bridge" => omarchy_ward::network_proxy::bridge(),
    [mode] if mode == "--audio-playback" => {
      omarchy_ward::audio::request(omarchy_ward::audio::Mode::Playback)
    }
    [mode] if mode == "--microphone" => {
      omarchy_ward::audio::request(omarchy_ward::audio::Mode::Microphone)
    }
    [mode] if mode == "--audio-capture" => {
      omarchy_ward::audio::request(omarchy_ward::audio::Mode::Capture)
    }
    [mode] if mode == "--http-execute" => omarchy_ward::http::execute(),
    [mode, root] if mode == "--manage" => omarchy_ward::management::run(std::path::Path::new(root)),
    [mode, title, body] if mode == "--notify" => {
      let text = |value: &std::ffi::OsStr| {
        value
          .to_str()
          .map(str::to_owned)
          .ok_or_else(|| Status::Invalid.error())
      };
      omarchy_ward::notification::request(text(title)?, text(body)?)
    }
    [mode, serial, open] if mode == "--panel-state" => omarchy_ward::requests::report_panel_state(
      serial
        .to_str()
        .ok_or_else(|| io::Error::other("invalid panel serial"))?,
      open
        .to_str()
        .ok_or_else(|| io::Error::other("invalid panel state"))?,
    ),
    [mode, width, height] if mode == "--widget-size" => omarchy_ward::requests::report_widget_size(
      width.to_str().ok_or_else(|| Status::Invalid.error())?,
      height.to_str().ok_or_else(|| Status::Invalid.error())?,
    ),
    [mode, view, width, height] if mode == "--widget-size" => {
      omarchy_ward::requests::report_view_size(
        view.to_str().ok_or_else(|| Status::Invalid.error())?,
        width.to_str().ok_or_else(|| Status::Invalid.error())?,
        height.to_str().ok_or_else(|| Status::Invalid.error())?,
      )
    }
    [mode, settings] if mode == "--settings" => omarchy_ward::requests::save_settings(
      settings.to_str().ok_or_else(|| Status::Invalid.error())?,
    ),
    [mode, direction] if mode == "--switch-panel" => omarchy_ward::requests::switch_panel(
      direction.to_str().ok_or_else(|| Status::Invalid.error())?,
    ),
    [mode, browser, url] if mode == "--open-url" => omarchy_ward::requests::open_url(
      browser.to_str().ok_or_else(|| Status::Invalid.error())?,
      url.to_str().ok_or_else(|| Status::Invalid.error())?,
    ),
    [mode, entry] if mode == "--runtime-worker" => {
      omarchy_ward::worker::restrict_bootstrap()?;
      omarchy_ward::network_proxy::start_bridge()?;
      let entry = entry
        .to_str()
        .filter(|entry| omarchy_ward::runtime::valid_entry(entry))
        .ok_or_else(|| io::Error::other("invalid runtime entry point"))?;
      Err(
        Command::new(std::path::Path::new("/runtime").join(entry))
          .stdout(io::stderr().as_fd().try_clone_to_owned()?)
          .exec(),
      )
    }
    [mode] if mode == "--worker" => {
      omarchy_ward::worker::restrict_bootstrap()?;
      omarchy_ward::network_proxy::start_bridge()?;
      Err(
        Command::new("/usr/bin/quickshell")
          .stdout(io::stderr().as_fd().try_clone_to_owned()?)
          .args(["--no-color", "-p"])
          .arg("/plugin")
          .exec(),
      )
    }
    [mode, entry] if mode == "--worker" => {
      omarchy_ward::worker::restrict_bootstrap()?;
      omarchy_ward::network_proxy::start_bridge()?;
      let entry = std::path::Path::new(entry);
      if entry.as_os_str().is_empty()
        || entry
          .components()
          .any(|part| !matches!(part, std::path::Component::Normal(_)))
      {
        return Err(io::Error::other("invalid worker entry point"));
      }
      Err(
        Command::new("/usr/bin/quickshell")
          .stdout(io::stderr().as_fd().try_clone_to_owned()?)
          .arg("--no-color")
          .arg("-p")
          .arg(std::path::Path::new("/plugin").join(entry))
          .exec(),
      )
    }
    [mode, path] if mode == "--controller" => {
      omarchy_ward::controller::run(std::path::Path::new(path), None)
    }
    [mode, path, root, id, epoch] if mode == "--controller" => {
      let id = id
        .to_str()
        .ok_or_else(|| io::Error::other("invalid plugin id"))?;
      let epoch = epoch
        .to_str()
        .and_then(|value| value.parse().ok())
        .ok_or_else(|| io::Error::other("invalid grant epoch"))?;
      let approval =
        omarchy_ward::controller::Approval::open(std::path::Path::new(root), id, epoch)?;
      omarchy_ward::controller::run(std::path::Path::new(path), Some(approval))
    }
    _ => Err(Status::Invalid.error()),
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn json_keeps_text_readable_and_binary_lossless() {
    for text in ["", "hello\n\0\"world", "café 🦀"] {
      assert_eq!(
        serde_json::to_value(Bytes::from(text.as_bytes().to_vec())).unwrap(),
        text
      );
    }
    let bytes: Vec<u8> = (0..=255).collect();
    let encoded = serde_json::to_value(Bytes::from(bytes.clone())).unwrap();
    assert_eq!(
      STANDARD
        .decode(encoded["base64"].as_str().unwrap())
        .unwrap(),
      bytes
    );
    let mut outcome = Outcome::status(Status::Completed);
    outcome.signal = Some(libc::SIGTERM);
    assert_eq!(outcome.code(), 143);
    assert_eq!(
      serde_json::to_value(outcome).unwrap(),
      serde_json::json!({"version":1,"status":"completed","signal":15})
    );
  }
}
