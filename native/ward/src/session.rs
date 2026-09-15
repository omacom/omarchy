//! Host-side connection owner. Manager calls, admission, and cleanup run on a
//! dedicated thread; the GUI only exchanges bounded, non-blocking messages.
use crate::{
  channel::{Channel, Listener},
  context::UiContext,
  controller::Control,
  presentation::{Event, Frames, Viewport},
  store::Store,
};
use std::{
  io,
  os::unix::fs::PermissionsExt,
  path::PathBuf,
  sync::mpsc::{self, Receiver, SyncSender, TryRecvError},
  time::{Duration, Instant},
};
mod streams;

pub enum Update {
  Blocked(crate::security::BlockedAction),
  Observation(bool),
  Ready,
  Presentation(Event),
  Stream(crate::presentation::StreamEvent),
  TopologyReady(u32),
  PanelState { serial: u32, open: bool },
  WidgetSize { width: u32, height: u32 },
  ViewSize { view: u32, width: u32, height: u32 },
  PanelSwitch { forward: bool },
  Failed(String),
}

pub struct Session {
  commands: SyncSender<Control>,
  updates: Receiver<Update>,
}
impl Session {
  /// Inputs come from trusted shell configuration, not the plugin manifest.
  /// This never creates approvals or silently enables a plugin.
  pub fn start(
    root: PathBuf,
    id: String,
    controller: PathBuf,
    viewport: Viewport,
  ) -> io::Result<Self> {
    Self::start_with_context(root, id, controller, viewport, UiContext::default())
  }

  pub fn start_with_context(
    root: PathBuf,
    id: String,
    controller: PathBuf,
    viewport: Viewport,
    context: UiContext,
  ) -> io::Result<Self> {
    Self::start_with_runtime(root, id, controller, viewport, context, None)
  }

  pub fn start_with_runtime(
    root: PathBuf,
    id: String,
    controller: PathBuf,
    viewport: Viewport,
    context: UiContext,
    runtime: Option<PathBuf>,
  ) -> io::Result<Self> {
    Self::start_inner(root, id, controller, viewport, context, None, runtime)
  }

  pub fn start_with_topology(
    root: PathBuf,
    id: String,
    controller: PathBuf,
    topology: crate::topology::Topology,
    context: UiContext,
  ) -> io::Result<Self> {
    Self::start_with_topology_and_runtime(root, id, controller, topology, context, None)
  }

  pub fn start_with_topology_and_runtime(
    root: PathBuf,
    id: String,
    controller: PathBuf,
    topology: crate::topology::Topology,
    context: UiContext,
    runtime: Option<PathBuf>,
  ) -> io::Result<Self> {
    topology.validate()?;
    Self::start_inner(
      root,
      id,
      controller,
      Viewport {
        width: 1,
        height: 1,
        scale_fixed: 120,
      },
      context,
      Some(topology),
      runtime,
    )
  }

  fn start_inner(
    root: PathBuf,
    id: String,
    controller: PathBuf,
    viewport: Viewport,
    context: UiContext,
    topology: Option<crate::topology::Topology>,
    runtime: Option<PathBuf>,
  ) -> io::Result<Self> {
    viewport.pixels()?;
    crate::grants::validate_id(&id)?;
    if !root.is_absolute() || !controller.is_absolute() {
      return Err(io::Error::other("session paths must be absolute"));
    }
    let (commands, receiver) = mpsc::sync_channel(64);
    let (sender, updates) = mpsc::sync_channel(if topology.is_some() { 128 } else { 8 });
    std::thread::Builder::new()
      .name("plugin-session".into())
      .spawn(move || {
        if let Err(error) = launch(
          root, id, controller, viewport, context, topology, runtime, receiver, &sender,
        ) {
          // A full queue or dropped receiver also terminates the session. Never
          // wait for GUI delivery during service cleanup.
          let _ = sender.try_send(Update::Failed(
            error.to_string().chars().take(512).collect(),
          ));
        }
      })?;
    Ok(Self { commands, updates })
  }

  pub fn poll(&self) -> io::Result<Option<Update>> {
    match self.updates.try_recv() {
      Ok(update) => Ok(Some(update)),
      Err(TryRecvError::Empty) => Ok(None),
      Err(TryRecvError::Disconnected) => Err(io::Error::other("plugin session ended")),
    }
  }

  pub fn send(&self, command: Control) -> io::Result<()> {
    if !matches!(
      command,
      Control::Input { .. }
        | Control::Scroll(_)
        | Control::Key(_)
        | Control::Presented(_)
        | Control::Configure(_)
        | Control::Topology(_)
        | Control::Targeted(_)
        | Control::Context(_)
        | Control::Stop
    ) {
      return Err(io::Error::other("invalid host session command"));
    }
    if let Control::Configure(viewport) = command {
      viewport.pixels()?;
    }
    if let Control::Topology(ref topology) = command {
      topology.validate()?;
    }
    if let Control::Targeted(target) = command {
      target.words()?;
    }
    if let Control::Scroll(scroll) = command {
      scroll.validate()?;
    }
    if let Control::Key(key) = command {
      key.validate()?;
    }
    self
      .commands
      .try_send(command)
      .map_err(|_| io::Error::other("plugin input queue unavailable"))
  }
}

fn accept_candidate(
  listener: &Listener,
  authenticate: impl FnOnce(&Channel) -> io::Result<()>,
) -> io::Result<Option<Channel>> {
  match listener.accept() {
    Ok(channel) => Ok(authenticate(&channel).is_ok().then_some(channel)),
    Err(error) if error.kind() == io::ErrorKind::WouldBlock => Ok(None),
    Err(error) => Err(error),
  }
}

#[allow(clippy::too_many_arguments)] // Initial presentation/context and the two bounded channels.
fn launch(
  root: PathBuf,
  id: String,
  controller: PathBuf,
  mut viewport: Viewport,
  mut context: UiContext,
  mut topology: Option<crate::topology::Topology>,
  worker_runtime: Option<PathBuf>,
  commands: Receiver<Control>,
  updates: &SyncSender<Update>,
) -> io::Result<()> {
  // Filesystem work stays off the GUI thread. Open before launching a service;
  // selection is explicit host configuration, never a plugin/session command.
  let worker_runtime = worker_runtime
    .as_deref()
    .map(crate::runtime::Runtime::open)
    .transpose()?;
  let runtime = tempfile::Builder::new()
    .prefix("omarchy-host-")
    .permissions(std::fs::Permissions::from_mode(0o700))
    .tempdir()?;
  let path = runtime.path().join("host");
  let listener = Listener::bind(&path)?;
  let store = Store::open(&root)?;
  let (mut unit, record) = store.launch(&id, &controller, &path)?;
  let result = (|| {
    emit(updates, Update::Observation(record.grants.desktop_geometry))?;
    let deadline = Instant::now() + Duration::from_secs(3);
    let channel = loop {
      if Instant::now() >= deadline {
        return Err(io::Error::new(
          io::ErrorKind::TimedOut,
          "controller admission timed out",
        ));
      }
      match commands.try_recv() {
        Err(TryRecvError::Empty) => (),
        Ok(Control::Configure(next)) => {
          next.pixels()?;
          viewport = next;
        }
        Ok(Control::Topology(next)) if topology.is_some() => {
          next.validate()?;
          topology = Some(next);
        }
        Ok(Control::Context(next)) => context = next,
        _ => return Err(io::Error::other("session cancelled before admission")),
      }
      if let Some(channel) = accept_candidate(&listener, |channel| unit.authenticate(channel))? {
        break channel;
      }
      // A rejected peer is not the selected controller; the original deadline
      // and pacing bound retries without aborting the legitimate admission.
      std::thread::sleep(Duration::from_millis(5));
    };
    if let Some(runtime) = worker_runtime {
      runtime.send(&channel)?;
    }
    if let Some(topology) = topology {
      streams::dispatch(channel, topology, context, commands, updates)
    } else {
      dispatch(channel, viewport, context, commands, updates)
    }
  })();
  // Unit::Drop also retries cleanup on failure. No manager work runs on GUI Drop.
  let stopped = unit.stop().and_then(|()| store.finish_session(&id, record.epoch, unit.name()));
  match (result, stopped) {
    (Err(error), Err(cleanup)) => Err(io::Error::other(format!("{error}; could not retire session: {cleanup}"))),
    (result, stopped) => result.and(stopped),
  }
}

fn emit(updates: &SyncSender<Update>, update: Update) -> io::Result<()> {
  updates
    .try_send(update)
    .map_err(|_| io::Error::other("plugin presentation queue unavailable"))
}

fn dispatch(
  channel: Channel,
  mut viewport: Viewport,
  mut context: UiContext,
  commands: Receiver<Control>,
  updates: &SyncSender<Update>,
) -> io::Result<()> {
  viewport.pixels()?;
  let mut desired = viewport;
  let mut resize_requested = false;
  let mut requested = None;
  let mut generation = 0;
  let mut settled = false;
  let mut frames = Frames::default();
  let mut described = 0u8;
  let mut ready = false;
  let mut context_changed = false;
  let mut ping = 0;
  let mut pong = 0;
  let mut next_ping = Instant::now();
  let mut deadline = Instant::now() + Duration::from_secs(3);
  let mut rate_window = Instant::now();
  let mut records = 0;
  loop {
    let now = Instant::now();
    if now >= deadline {
      return Err(io::Error::other("plugin controller lease expired"));
    }
    if now >= next_ping {
      ping += 1;
      Control::Ping(ping).send(&channel)?;
      next_ping = now + Duration::from_millis(500);
    }
    if now.duration_since(rate_window) >= Duration::from_secs(1) {
      rate_window = now;
      records = 0;
    }
    for _ in 0..32 {
      match commands.try_recv() {
        Ok(Control::Stop) | Err(TryRecvError::Disconnected) => return Ok(()),
        Ok(Control::Configure(next)) => {
          next.pixels()?;
          desired = next;
          resize_requested = true;
        }
        Ok(Control::Context(next)) => {
          context = next;
          context_changed = true;
        }
        Ok(command) => {
          if !ready {
            return Err(io::Error::other("input before session ready"));
          }
          if let Control::Presented(serial) = command {
            frames.presented(serial)?;
            settled = true;
          }
          command.send(&channel)?;
        }
        Err(TryRecvError::Empty) => break,
      }
    }
    if ready && context_changed {
      Control::Context(context.clone()).send(&channel)?;
      context_changed = false;
    }
    for _ in 0..32 {
      let packet = match channel.receive() {
        Ok(packet) => packet,
        Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
        Err(error) => return Err(error),
      };
      records += 1;
      if records > 2048 {
        return Err(io::Error::other("controller presentation rate exceeded"));
      }
      if packet.bytes.len() == 16 {
        match Control::decode(packet)? {
          Control::Hello if !ready => {
            Control::Context(context.clone()).send(&channel)?;
            context_changed = false;
            Control::Configure(desired).send(&channel)?;
            requested = Some(desired);
            resize_requested = false;
            ready = true;
            emit(updates, Update::Ready)?;
          }
          Control::Pong(serial) if ready && serial > pong && serial <= ping => {
            pong = serial;
            deadline = now + Duration::from_secs(3);
          }
          Control::PanelState { serial, open } if ready => {
            emit(updates, Update::PanelState { serial, open })?;
          }
          Control::WidgetSize { width, height } if ready => {
            emit(updates, Update::WidgetSize { width, height })?;
          }
          Control::PanelSwitch { forward } if ready => {
            emit(updates, Update::PanelSwitch { forward })?;
          }
          Control::Blocked(action) if ready => emit(updates, Update::Blocked(action))?,
          _ => return Err(io::Error::other("unexpected controller control record")),
        }
      } else {
        if !ready {
          return Err(io::Error::other("presentation before hello"));
        }
        let event = Event::decode(packet)?;
        match &event {
          Event::Configured {
            generation: next,
            viewport: next_viewport,
          } => {
            if requested != Some(*next_viewport) {
              return Err(io::Error::other("unsolicited presentation viewport"));
            }
            frames.configure(*next)?;
            generation = *next;
            viewport = *next_viewport;
            described = 0;
            requested = None;
            settled = false;
          }
          Event::Buffer(buffer) => {
            if buffer.generation != generation
              || (buffer.width, buffer.height) != viewport.pixels()?
            {
              return Err(io::Error::other("unexpected presentation buffer geometry"));
            }
            frames.describe(buffer.generation, buffer.slot)?;
            described |= 1 << buffer.slot;
          }
          Event::Frame {
            generation,
            serial,
            slot,
          } => frames.frame(*generation, *serial, *slot)?,
          Event::Mask {
            generation: mask_generation,
            regions,
          } => {
            if *mask_generation != generation
              || described != 3
              || regions.iter().any(|region| {
                region.x + region.width > viewport.width
                  || region.y + region.height > viewport.height
              })
            {
              return Err(io::Error::other("unexpected presentation mask"));
            }
          }
        }
        emit(updates, Update::Presentation(event))?;
      }
    }
    // One configured generation must reach the GUI before another is requested.
    // Repeated geometry changes replace `desired`; no resize-effect queue grows.
    if ready && settled && requested.is_none() && resize_requested {
      Control::Configure(desired).send(&channel)?;
      requested = Some(desired);
      resize_requested = false;
    }
    std::thread::sleep(Duration::from_millis(5));
  }
}

#[cfg(test)]
mod tests {
  #[test]
  fn rejected_admission_peer_does_not_abort_the_next_candidate() {
    let root = tempfile::Builder::new()
      .permissions(std::fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let path = root.path().join("listener");
    let listener = super::Listener::bind(&path).unwrap();
    let _rejected = super::Channel::connect(&path).unwrap();
    assert!(
      super::accept_candidate(&listener, |_| Err(std::io::Error::from(
        std::io::ErrorKind::PermissionDenied
      )))
      .unwrap()
      .is_none()
    );
    let _accepted = super::Channel::connect(&path).unwrap();
    assert!(
      super::accept_candidate(&listener, |_| Ok(()))
        .unwrap()
        .is_some()
    );
    assert!(
      super::accept_candidate(&listener, |_| panic!("no peer available"))
        .unwrap()
        .is_none()
    );
  }
  use super::*;
  use crate::presentation::Buffer;
  use std::{fs::File, thread::JoinHandle};

  fn connection() -> (
    Channel,
    SyncSender<Control>,
    Receiver<Update>,
    JoinHandle<io::Result<()>>,
  ) {
    let (host, controller) = Channel::pair().unwrap();
    let (commands, receiver) = mpsc::sync_channel(64);
    let (sender, updates) = mpsc::sync_channel(8);
    let task = std::thread::spawn(move || {
      dispatch(
        host,
        Viewport {
          width: 80,
          height: 48,
          scale_fixed: 120,
        },
        UiContext::default(),
        receiver,
        &sender,
      )
    });
    (controller, commands, updates, task)
  }

  fn hello(controller: &Channel, updates: &Receiver<Update>) {
    Control::Hello.send(controller).unwrap();
    assert!(matches!(
      updates.recv_timeout(Duration::from_secs(1)).unwrap(),
      Update::Ready
    ));
  }

  #[test]
  fn context_precedes_startup_and_updates_without_worker_authority() {
    let (controller, commands, updates, task) = connection();
    let mut context = UiContext::default();
    context.settings.insert("width".into(), 40.into());
    commands.send(Control::Context(context.clone())).unwrap();
    hello(&controller, &updates);
    let next_context = || {
      let deadline = Instant::now() + Duration::from_secs(1);
      loop {
        match controller.receive() {
          Ok(packet) => match Control::decode(packet).unwrap() {
            Control::Context(context) => return context,
            Control::Ping(_) => (),
            other => panic!("context must precede configuration: {other:?}"),
          },
          Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
            std::thread::sleep(Duration::from_millis(5))
          }
          Err(error) => panic!("context not delivered: {error}"),
        }
      }
    };
    assert_eq!(next_context(), context);
    next_configure(&controller);
    context.settings.insert("width".into(), 60.into());
    commands.send(Control::Context(context.clone())).unwrap();
    assert_eq!(next_context(), context);
    // The worker/controller cannot reverse this one-way contract to mutate
    // shell settings. A context sent back is an invalid controller reply.
    Control::Context(context).send(&controller).unwrap();
    assert!(task.join().unwrap().is_err());
  }

  fn buffers(controller: &Channel) {
    configure_buffers(
      controller,
      1,
      Viewport {
        width: 80,
        height: 48,
        scale_fixed: 120,
      },
    );
  }

  fn configure_buffers(controller: &Channel, generation: u64, viewport: Viewport) {
    Event::Configured {
      generation,
      viewport,
    }
    .send(controller)
    .unwrap();
    let (width, height) = viewport.pixels().unwrap();
    for slot in 0..2 {
      Event::Buffer(Buffer {
        generation,
        slot,
        width,
        height,
        stride: width * 4,
        fd: File::open("/dev/null").unwrap().into(),
      })
      .send(controller)
      .unwrap();
    }
  }

  fn next_configure(controller: &Channel) -> Viewport {
    let deadline = Instant::now() + Duration::from_secs(1);
    loop {
      match controller.receive() {
        Ok(packet) => {
          if let Control::Configure(viewport) = Control::decode(packet).unwrap() {
            return viewport;
          }
        }
        Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
          std::thread::sleep(Duration::from_millis(5))
        }
        Err(error) => panic!("missing resize request: {error}"),
      }
    }
  }

  #[test]
  fn resize_coalesces_waits_for_presented_frames_and_accepts_same_size_roundtrips() {
    let (controller, commands, updates, task) = connection();
    hello(&controller, &updates);
    assert_eq!(next_configure(&controller).width, 80);
    let drain_frame = || {
      for _ in 0..4 {
        assert!(matches!(
          updates.recv_timeout(Duration::from_secs(1)).unwrap(),
          Update::Presentation(_)
        ));
      }
    };
    buffers(&controller);
    Event::Frame {
      generation: 1,
      serial: 1,
      slot: 0,
    }
    .send(&controller)
    .unwrap();
    drain_frame();
    let target = Viewport {
      width: 140,
      height: 90,
      scale_fixed: 240,
    };
    commands
      .send(Control::Configure(Viewport {
        width: 120,
        ..target
      }))
      .unwrap();
    commands.send(Control::Configure(target)).unwrap();
    std::thread::sleep(Duration::from_millis(30));
    while let Ok(packet) = controller.receive() {
      assert!(
        !matches!(Control::decode(packet).unwrap(), Control::Configure(_)),
        "resize overtook the displayed frame"
      );
    }
    commands.send(Control::Presented(1)).unwrap();
    assert_eq!(next_configure(&controller), target);
    // Old-generation work may already be on the wire when a resize is sent.
    Event::Frame {
      generation: 1,
      serial: 2,
      slot: 1,
    }
    .send(&controller)
    .unwrap();
    assert!(matches!(
      updates.recv_timeout(Duration::from_secs(1)).unwrap(),
      Update::Presentation(Event::Frame { serial: 2, .. })
    ));
    commands.send(Control::Presented(2)).unwrap();
    let deadline = Instant::now() + Duration::from_secs(1);
    loop {
      match controller.receive() {
        Ok(packet) => {
          if Control::decode(packet).unwrap() == Control::Presented(2) {
            break;
          }
        }
        Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
          std::thread::sleep(Duration::from_millis(5))
        }
        Err(error) => panic!("old frame not acknowledged: {error}"),
      }
    }
    configure_buffers(&controller, 2, target);
    Event::Frame {
      generation: 2,
      serial: 3,
      slot: 0,
    }
    .send(&controller)
    .unwrap();
    drain_frame();
    commands
      .send(Control::Configure(Viewport {
        width: 100,
        ..target
      }))
      .unwrap();
    commands.send(Control::Configure(target)).unwrap();
    commands.send(Control::Presented(3)).unwrap();
    assert_eq!(
      next_configure(&controller),
      target,
      "returning to the current geometry still needs an acknowledgement"
    );
    configure_buffers(&controller, 3, target);
    Event::Frame {
      generation: 3,
      serial: 4,
      slot: 0,
    }
    .send(&controller)
    .unwrap();
    drain_frame();
    commands.send(Control::Presented(4)).unwrap();
    commands.send(Control::Stop).unwrap();
    assert!(task.join().unwrap().is_ok());
  }

  #[test]
  fn unsolicited_generations_and_inconsistent_geometry_fail_closed() {
    for mode in 0..4 {
      let (controller, _commands, updates, task) = connection();
      hello(&controller, &updates);
      let viewport = Viewport {
        width: 80,
        height: 48,
        scale_fixed: 120,
      };
      match mode {
        0 => Event::Configured {
          generation: 2,
          viewport,
        }
        .send(&controller)
        .unwrap(),
        1 => Event::Configured {
          generation: 1,
          viewport: Viewport {
            width: 81,
            ..viewport
          },
        }
        .send(&controller)
        .unwrap(),
        2 => {
          buffers(&controller);
          Event::Mask {
            generation: 2,
            regions: Vec::new(),
          }
          .send(&controller)
          .unwrap();
        }
        _ => {
          Event::Configured {
            generation: 1,
            viewport,
          }
          .send(&controller)
          .unwrap();
          Event::Buffer(Buffer {
            generation: 1,
            slot: 0,
            width: 160,
            height: 96,
            stride: 640,
            fd: File::open("/dev/null").unwrap().into(),
          })
          .send(&controller)
          .unwrap();
        }
      }
      assert!(task.join().unwrap().is_err());
    }
  }

  #[test]
  fn session_validates_frame_ownership_and_gui_disconnect() {
    let (controller, commands, updates, task) = connection();
    hello(&controller, &updates);
    buffers(&controller);
    Event::Frame {
      generation: 1,
      serial: 1,
      slot: 0,
    }
    .send(&controller)
    .unwrap();
    for _ in 0..4 {
      assert!(matches!(
        updates.recv_timeout(Duration::from_secs(1)).unwrap(),
        Update::Presentation(_)
      ));
    }
    commands.send(Control::Presented(1)).unwrap();
    let deadline = Instant::now() + Duration::from_secs(1);
    loop {
      match controller.receive() {
        Ok(packet) => {
          if Control::decode(packet).unwrap() == Control::Presented(1) {
            break;
          }
        }
        Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
          std::thread::sleep(Duration::from_millis(5))
        }
        Err(error) => panic!("missing acknowledgement: {error}"),
      }
    }
    Event::Frame {
      generation: 1,
      serial: 2,
      slot: 1,
    }
    .send(&controller)
    .unwrap();
    assert!(matches!(
      updates.recv_timeout(Duration::from_secs(1)).unwrap(),
      Update::Presentation(Event::Frame { serial: 2, .. })
    ));
    drop(commands);
    assert!(task.join().unwrap().is_ok());
  }

  #[test]
  fn session_rejects_replays_unconfigured_frames_and_stale_acknowledgements() {
    for mode in 0..4 {
      let (controller, commands, updates, task) = connection();
      hello(&controller, &updates);
      match mode {
        0 => Control::Hello.send(&controller).unwrap(),
        1 => Event::Frame {
          generation: 1,
          serial: 1,
          slot: 0,
        }
        .send(&controller)
        .unwrap(),
        2 => commands.send(Control::Presented(1)).unwrap(),
        _ => {
          buffers(&controller);
          Event::Frame {
            generation: 1,
            serial: 1,
            slot: 0,
          }
          .send(&controller)
          .unwrap();
          Event::Frame {
            generation: 1,
            serial: 2,
            slot: 1,
          }
          .send(&controller)
          .unwrap();
        }
      }
      assert!(task.join().unwrap().is_err());
    }
  }

  #[test]
  fn stalled_gui_cannot_create_an_unbounded_presentation_queue() {
    let (controller, _commands, updates, task) = connection();
    hello(&controller, &updates);
    buffers(&controller);
    for _ in 0..16 {
      if (Event::Mask {
        generation: 1,
        regions: Vec::new(),
      })
      .send(&controller)
      .is_err()
      {
        break;
      }
    }
    assert!(
      task
        .join()
        .unwrap()
        .unwrap_err()
        .to_string()
        .contains("queue")
    );
    assert!(updates.try_iter().count() <= 8);
  }
}
