use crate::{
  controller::Control,
  presentation,
  session::{Session, Update},
};
use std::{io, os::fd::AsRawFd, path::PathBuf};

#[cxx::bridge(namespace = "omarchy")]
mod ffi {
  enum EventKind {
    Empty,
    Ready,
    Observation,
    TopologyReady,
    Configured,
    Buffer,
    Frame,
    Mask,
    PanelState,
    WidgetSize,
    PanelSwitch,
    Failed,
    Blocked,
  }
  struct NativeRegion {
    operation: u32,
    x: u32,
    y: u32,
    width: u32,
    height: u32,
  }
  struct BufferInfo {
    fd: i32,
    width: u32,
    height: u32,
    stride: u32,
  }
  struct NativeEvent {
    kind: EventKind,
    output: u32,
    epoch: u32,
    view: u32,
    generation: u64,
    width: u32,
    height: u32,
    scale_fixed: u32,
    serial: u64,
    slot: u32,
    panel_serial: u32,
    panel_open: bool,
    desktop_geometry: bool,
    switch_forward: bool,
    blocked_action: u32,
    buffer: Box<NativeBuffer>,
    regions: Vec<NativeRegion>,
    error: String,
  }
  extern "Rust" {
    type Session;
    type NativeBuffer;
    fn begin(
      root: &str,
      id: &str,
      controller: &str,
      width: u32,
      height: u32,
      scale: u32,
      context: &str,
    ) -> Result<Box<Session>>;
    fn next(session: &Session) -> Result<NativeEvent>;
    fn begin_streams(
      root: &str,
      id: &str,
      controller: &str,
      topology: &str,
      context: &str,
      runtime: &str,
    ) -> Result<Box<Session>>;
    fn configure_streams(session: &Session, topology: &str) -> Result<()>;
    fn target_input(
      session: &Session,
      output: u32,
      epoch: u32,
      kind: u32,
      code: u32,
      x: i32,
      y: i32,
    ) -> Result<()>;
    fn target_key(
      session: &Session,
      output: u32,
      epoch: u32,
      code: u32,
      symbol: u32,
      pressed: bool,
    ) -> Result<()>;
    #[allow(clippy::too_many_arguments)] // Fixed scalar CXX wire fields.
    fn target_scroll(
      session: &Session,
      output: u32,
      epoch: u32,
      source: u32,
      x: i32,
      y: i32,
      horizontal: i32,
      vertical: i32,
    ) -> Result<()>;
    fn target_presented(session: &Session, output: u32, epoch: u32, serial: u64) -> Result<()>;
    fn input(session: &Session, kind: u32, code: u32, x: i32, y: i32) -> Result<()>;
    fn key(session: &Session, code: u32, symbol: u32, pressed: bool) -> Result<()>;
    fn scroll(
      session: &Session,
      source: u32,
      x: i32,
      y: i32,
      horizontal: i32,
      vertical: i32,
    ) -> Result<()>;
    fn presented(session: &Session, serial: u64) -> Result<()>;
    fn configure(session: &Session, width: u32, height: u32, scale: u32) -> Result<()>;
    fn context(session: &Session, json: &str) -> Result<()>;
    fn info(self: &NativeBuffer) -> BufferInfo;
  }
}
pub struct NativeBuffer(Option<presentation::Buffer>);
impl NativeBuffer {
  fn info(&self) -> ffi::BufferInfo {
    self.0.as_ref().map_or(
      ffi::BufferInfo {
        fd: -1,
        width: 0,
        height: 0,
        stride: 0,
      },
      |buffer| ffi::BufferInfo {
        fd: buffer.fd.as_raw_fd(),
        width: buffer.width,
        height: buffer.height,
        stride: buffer.stride,
      },
    )
  }
}
fn begin(
  root: &str,
  id: &str,
  controller: &str,
  width: u32,
  height: u32,
  scale: u32,
  context: &str,
) -> io::Result<Box<Session>> {
  Session::start_with_context(
    PathBuf::from(root),
    id.into(),
    PathBuf::from(controller),
    presentation::Viewport {
      width,
      height,
      scale_fixed: scale
        .checked_mul(120)
        .ok_or_else(|| io::Error::other("invalid scale"))?,
    },
    parse_context(context)?,
  )
  .map(Box::new)
}
fn parse_context(json: &str) -> io::Result<crate::context::UiContext> {
  if json.is_empty() {
    Ok(crate::context::UiContext::default())
  } else {
    crate::context::UiContext::parse(json.as_bytes())
  }
}
fn context(session: &Session, json: &str) -> io::Result<()> {
  session.send(Control::Context(parse_context(json)?))
}
fn next(session: &Session) -> io::Result<ffi::NativeEvent> {
  let mut event = ffi::NativeEvent {
    kind: ffi::EventKind::Empty,
    output: 0,
    epoch: 0,
    view: 0,
    generation: 0,
    width: 0,
    height: 0,
    scale_fixed: 0,
    serial: 0,
    slot: 0,
    panel_serial: 0,
    panel_open: false,
    desktop_geometry: false,
    switch_forward: false,
    blocked_action: 0,
    buffer: Box::new(NativeBuffer(None)),
    regions: Vec::new(),
    error: String::new(),
  };
  let update = match session.poll()? {
    Some(Update::Stream(stream)) => {
      event.output = stream.output;
      event.epoch = stream.epoch;
      Some(Update::Presentation(stream.event))
    }
    update => update,
  };
  match update {
    None => (),
    Some(Update::Ready) => event.kind = ffi::EventKind::Ready,
    Some(Update::Blocked(action)) => {
      event.kind = ffi::EventKind::Blocked;
      event.blocked_action = action as u32;
    }
    Some(Update::Observation(selected)) => {
      event.kind = ffi::EventKind::Observation;
      event.desktop_geometry = selected;
    }
    Some(Update::TopologyReady(epoch)) => {
      event.kind = ffi::EventKind::TopologyReady;
      event.epoch = epoch;
    }
    Some(Update::Stream(_)) => unreachable!(),
    Some(Update::PanelState { serial, open }) => {
      event.kind = ffi::EventKind::PanelState;
      event.panel_serial = serial;
      event.panel_open = open;
    }
    Some(Update::WidgetSize { width, height }) => {
      event.kind = ffi::EventKind::WidgetSize;
      event.width = width;
      event.height = height;
    }
    Some(Update::ViewSize {
      view,
      width,
      height,
    }) => {
      event.kind = ffi::EventKind::WidgetSize;
      event.view = view;
      event.width = width;
      event.height = height;
    }
    Some(Update::PanelSwitch { forward }) => {
      event.kind = ffi::EventKind::PanelSwitch;
      event.switch_forward = forward;
    }
    Some(Update::Presentation(presentation::Event::Configured {
      generation,
      viewport,
    })) => {
      event.kind = ffi::EventKind::Configured;
      event.generation = generation;
      event.width = viewport.width;
      event.height = viewport.height;
      event.scale_fixed = viewport.scale_fixed;
    }
    Some(Update::Failed(error)) => {
      event.kind = ffi::EventKind::Failed;
      event.error = error;
    }
    Some(Update::Presentation(presentation::Event::Buffer(buffer))) => {
      event.kind = ffi::EventKind::Buffer;
      event.slot = buffer.slot;
      event.buffer.0 = Some(buffer);
    }
    Some(Update::Presentation(presentation::Event::Frame { serial, slot, .. })) => {
      event.kind = ffi::EventKind::Frame;
      event.serial = serial;
      event.slot = slot;
    }
    Some(Update::Presentation(presentation::Event::Mask { regions, .. })) => {
      event.kind = ffi::EventKind::Mask;
      event.regions = regions
        .into_iter()
        .map(|r| ffi::NativeRegion {
          operation: r.operation,
          x: r.x,
          y: r.y,
          width: r.width,
          height: r.height,
        })
        .collect();
    }
  }
  Ok(event)
}

fn begin_streams(
  root: &str,
  id: &str,
  controller: &str,
  topology: &str,
  context: &str,
  runtime: &str,
) -> io::Result<Box<Session>> {
  Session::start_with_topology_and_runtime(
    PathBuf::from(root),
    id.into(),
    PathBuf::from(controller),
    crate::topology::Topology::parse(topology.as_bytes())?,
    parse_context(context)?,
    (!runtime.is_empty()).then(|| PathBuf::from(runtime)),
  )
  .map(Box::new)
}

fn configure_streams(session: &Session, topology: &str) -> io::Result<()> {
  session.send(Control::Topology(crate::topology::Topology::parse(
    topology.as_bytes(),
  )?))
}

fn targeted(
  session: &Session,
  output: u32,
  epoch: u32,
  event: crate::topology::Input,
) -> io::Result<()> {
  session.send(Control::Targeted(crate::topology::Targeted {
    output,
    epoch,
    event,
  }))
}
fn target_input(
  session: &Session,
  output: u32,
  epoch: u32,
  kind: u32,
  code: u32,
  x: i32,
  y: i32,
) -> io::Result<()> {
  targeted(
    session,
    output,
    epoch,
    crate::topology::Input::Pointer { kind, code, x, y },
  )
}
fn target_key(
  session: &Session,
  output: u32,
  epoch: u32,
  code: u32,
  symbol: u32,
  pressed: bool,
) -> io::Result<()> {
  targeted(
    session,
    output,
    epoch,
    crate::topology::Input::Key(crate::controller::Key {
      code,
      symbol,
      pressed,
    }),
  )
}
#[allow(clippy::too_many_arguments)] // Mirrors the fixed scalar CXX wire fields.
fn target_scroll(
  session: &Session,
  output: u32,
  epoch: u32,
  source: u32,
  x: i32,
  y: i32,
  horizontal: i32,
  vertical: i32,
) -> io::Result<()> {
  targeted(
    session,
    output,
    epoch,
    crate::topology::Input::Scroll(crate::controller::Scroll {
      source,
      x,
      y,
      horizontal,
      vertical,
    }),
  )
}
fn target_presented(session: &Session, output: u32, epoch: u32, serial: u64) -> io::Result<()> {
  targeted(
    session,
    output,
    epoch,
    crate::topology::Input::Presented(serial),
  )
}
fn input(session: &Session, kind: u32, code: u32, x: i32, y: i32) -> io::Result<()> {
  if kind > 6 {
    return Err(io::Error::other("invalid input kind"));
  }
  session.send(Control::Input { kind, code, x, y })
}
fn presented(session: &Session, serial: u64) -> io::Result<()> {
  session.send(Control::Presented(serial))
}
fn key(session: &Session, code: u32, symbol: u32, pressed: bool) -> io::Result<()> {
  session.send(Control::Key(crate::controller::Key {
    code,
    symbol,
    pressed,
  }))
}
fn scroll(
  session: &Session,
  source: u32,
  x: i32,
  y: i32,
  horizontal: i32,
  vertical: i32,
) -> io::Result<()> {
  session.send(Control::Scroll(crate::controller::Scroll {
    source,
    x,
    y,
    horizontal,
    vertical,
  }))
}
fn configure(session: &Session, width: u32, height: u32, scale: u32) -> io::Result<()> {
  session.send(Control::Configure(presentation::Viewport {
    width,
    height,
    scale_fixed: scale
      .checked_mul(120)
      .ok_or_else(|| io::Error::other("invalid scale"))?,
  }))
}
