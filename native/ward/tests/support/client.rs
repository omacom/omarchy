//! Shared raw Wayland client harness for the worker-graphics integration tests.
//!
//! The toplevel tests (fractional-scale, viewporter, multi-output) used to each
//! re-implement the same client: connect + bind compositor/shm/xdg/seats,
//! paint a shared-memory buffer, ack the toplevel configure, and pump a
//! roundtrip loop, along with identical `Client`/`Dispatch`/`noop!`
//! boilerplate and identical frame/click/teardown wait loops. That duplicated
//! machinery lives here so each test keeps only its scenario constants and its
//! assertions. The layer-shell wall test reuses the frame/click/teardown
//! helpers (its state stays local because the layer-surface dispatch is
//! specialised).
#![allow(dead_code)] // shared harness: each test crate uses a subset
use super::desktop::Desktop;

use std::{
  fs,
  io::Write,
  os::{
    fd::{AsFd, FromRawFd},
    unix::net::UnixStream,
  },
  path::Path,
  sync::{
    Arc, Mutex,
    atomic::{AtomicBool, Ordering},
  },
  thread,
  time::{Duration, Instant},
};
use wayland_backend::client::ObjectId;
use wayland_client::{
  Connection, Dispatch, Proxy, QueueHandle, WEnum,
  globals::registry_queue_init,
  protocol::{
    wl_buffer::WlBuffer,
    wl_compositor::WlCompositor,
    wl_output::WlOutput,
    wl_pointer::{self, ButtonState, WlPointer},
    wl_registry::{self, WlRegistry},
    wl_seat::WlSeat,
    wl_shm::{Format, WlShm},
    wl_shm_pool::WlShmPool,
    wl_surface::{self, WlSurface},
  },
};
use wayland_protocols::{
  wp::fractional_scale::v1::client::{
    wp_fractional_scale_manager_v1::WpFractionalScaleManagerV1,
    wp_fractional_scale_v1::{self, WpFractionalScaleV1},
  },
  wp::viewporter::client::{wp_viewport::WpViewport, wp_viewporter::WpViewporter},
  xdg::shell::client::{
    xdg_surface::{self, XdgSurface},
    xdg_toplevel::XdgToplevel,
    xdg_wm_base::XdgWmBase,
  },
};

/// Ordered enter(true) / leave(false) events of a surface over wl_output ids.
pub type OutputEvent = (bool, ObjectId);

/// Cross-thread side effects a test observes from its client.
#[derive(Clone)]
pub struct SharedState {
  pub bound: Arc<Mutex<Vec<ObjectId>>>,
  pub outputs: Arc<Mutex<Vec<OutputEvent>>>,
  pub clicked: Arc<AtomicBool>,
  pub entered: Arc<Mutex<Option<(f64, f64)>>>,
  pub preferred: Arc<Mutex<Option<u32>>>,
  pub stop: Arc<AtomicBool>,
}

impl SharedState {
  pub fn new(stop: Arc<AtomicBool>) -> Self {
    SharedState {
      bound: Arc::new(Mutex::new(Vec::new())),
      outputs: Arc::new(Mutex::new(Vec::new())),
      clicked: Arc::new(AtomicBool::new(false)),
      entered: Arc::new(Mutex::new(None)),
      preferred: Arc::new(Mutex::new(None)),
      stop,
    }
  }
}

/// How a toplevel is rendered by the client (data-driven surface setups).
pub enum Surface {
  /// Solid green fractional-scale buffer of `buffer` px mapped onto a
  /// `dest`-sized logical viewport, optionally binding `wp_fractional_scale`
  /// to capture the compositor's advertised preference.
  SolidGreen {
    dest: (i32, i32),
    buffer: (i32, i32),
    fractional: bool,
  },
  /// Viewporter probe: `src` crop (fixed-point) is green inside, red outside,
  /// scaled to a `dest`-sized viewport.
  Cropped {
    src: (f64, f64, f64, f64),
    dest: (i32, i32),
    buffer: (i32, i32),
  },
}

pub struct TestClient {
  pub qh: QueueHandle<TestClient>,
  pub shm: WlShm,
  pub compositor: WlCompositor,
  pub xdg_wm_base: XdgWmBase,
  pub viewporter: WpViewporter,
  pub fractional: WpFractionalScaleManagerV1,
  pub pointer: WlPointer,
  pub xdg_serial: Option<u32>,
  pub state: SharedState,
}

macro_rules! noop {
  ($($t:ty),* $(,)?) => {
    $(
      impl Dispatch<$t, ()> for TestClient {
        fn event(
          _: &mut TestClient,
          _: &$t,
          _: <$t as wayland_client::Proxy>::Event,
          _: &(),
          _: &Connection,
          _: &QueueHandle<TestClient>,
        ) {}
      }
    )*
  };
}

impl Dispatch<WlRegistry, wayland_client::globals::GlobalListContents> for TestClient {
  fn event(
    _: &mut TestClient,
    _: &WlRegistry,
    _: wl_registry::Event,
    _: &wayland_client::globals::GlobalListContents,
    _: &Connection,
    _: &QueueHandle<TestClient>,
  ) {
  }
}

impl Dispatch<XdgSurface, ()> for TestClient {
  fn event(
    state: &mut TestClient,
    _: &XdgSurface,
    event: xdg_surface::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<TestClient>,
  ) {
    if let xdg_surface::Event::Configure { serial } = event {
      state.xdg_serial = Some(serial);
    }
  }
}

impl Dispatch<WlSurface, ()> for TestClient {
  fn event(
    state: &mut TestClient,
    _: &WlSurface,
    event: wl_surface::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<TestClient>,
  ) {
    match event {
      wl_surface::Event::Enter { output, .. } => {
        state
          .state
          .outputs
          .lock()
          .unwrap()
          .push((true, output.id()));
      }
      wl_surface::Event::Leave { output, .. } => {
        state
          .state
          .outputs
          .lock()
          .unwrap()
          .push((false, output.id()));
      }
      _ => {}
    }
  }
}

impl Dispatch<WlPointer, ()> for TestClient {
  fn event(
    state: &mut TestClient,
    _: &WlPointer,
    event: wl_pointer::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<TestClient>,
  ) {
    match event {
      wl_pointer::Event::Enter {
        surface_x,
        surface_y,
        ..
      } => {
        *state.state.entered.lock().unwrap() = Some((surface_x, surface_y));
      }
      wl_pointer::Event::Button { state: s, .. } => {
        if matches!(s, WEnum::Value(ButtonState::Pressed)) {
          state.state.clicked.store(true, Ordering::SeqCst);
        }
      }
      _ => {}
    }
  }
}

impl Dispatch<WpFractionalScaleV1, ()> for TestClient {
  fn event(
    state: &mut TestClient,
    _: &WpFractionalScaleV1,
    event: wp_fractional_scale_v1::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<TestClient>,
  ) {
    if let wp_fractional_scale_v1::Event::PreferredScale { scale } = event {
      *state.state.preferred.lock().unwrap() = Some(scale);
    }
  }
}

noop! {
  WlCompositor,
  WlShm,
  WlShmPool,
  WlBuffer,
  WlSeat,
  WlOutput,
  XdgToplevel,
  XdgWmBase,
  WpViewporter,
  WpViewport,
  WpFractionalScaleManagerV1,
}

impl TestClient {
  fn connect(
    socket: &Path,
    state: SharedState,
  ) -> (TestClient, wayland_client::EventQueue<TestClient>) {
    let stream = UnixStream::connect(socket).unwrap();
    let conn = Connection::from_socket(stream).unwrap();
    let (globals, queue) = registry_queue_init::<TestClient>(&conn).unwrap();
    let qh = queue.handle();
    let compositor: WlCompositor = globals.bind(&qh, 4..=6, ()).unwrap();
    let shm: WlShm = globals.bind(&qh, 1..=1, ()).unwrap();
    let xdg_wm_base: XdgWmBase = globals.bind(&qh, 1..=1, ()).unwrap();
    let seat: WlSeat = globals.bind(&qh, 1..=6, ()).unwrap();
    let viewporter: WpViewporter = globals.bind(&qh, 1..=1, ()).unwrap();
    let fractional: WpFractionalScaleManagerV1 = globals.bind(&qh, 1..=1, ()).unwrap();
    let pointer = seat.get_pointer(&qh, ());
    // Remember every advertised wl_output global's id (creation order).
    let mut bound = Vec::new();
    for g in globals.contents().clone_list() {
      if g.interface == "wl_output" {
        let _out: WlOutput = globals.registry().bind(g.name, g.version, &qh, ());
        bound.push(_out.id());
      }
    }
    *state.bound.lock().unwrap() = bound;
    (
      TestClient {
        qh,
        shm,
        compositor,
        xdg_wm_base,
        viewporter,
        fractional,
        pointer,
        xdg_serial: None,
        state,
      },
      queue,
    )
  }

  /// Allocate an ARGB8888 shared-memory buffer `w`x`h` filled by `fill(px, py)`
  /// (an RGB triple in read-back order; stored BGR for wl_shm), attach it to
  /// `surface` and commit.
  fn attach_buffer(
    &mut self,
    surface: &WlSurface,
    w: i32,
    h: i32,
    mut fill: impl FnMut(u32, u32) -> [u8; 3],
  ) {
    let mut data = vec![0u8; (w * h * 4) as usize];
    for y in 0..h as u32 {
      for x in 0..w as u32 {
        let [r, g, b] = fill(x, y);
        let base = (y as usize * w as usize + x as usize) * 4;
        data[base..base + 4].copy_from_slice(&[b, g, r, 0xff]);
      }
    }
    let fd = unsafe { libc::memfd_create(c"client-test".as_ptr(), libc::MFD_CLOEXEC) };
    assert!(fd >= 0, "memfd_create failed");
    let mut file = unsafe { fs::File::from_raw_fd(fd) };
    file.write_all(&data).unwrap();
    let pool = self.shm.create_pool(file.as_fd(), w * h * 4, &self.qh, ());
    let buffer = pool.create_buffer(0, w, h, w * 4, Format::Argb8888, &self.qh, ());
    surface.attach(Some(&buffer), 0, 0);
    surface.commit();
  }
}

/// A resolved toplevel surface setup (decoded from [`Surface`] for the client
/// thread).
struct Setup {
  dest: (i32, i32),
  buffer: (i32, i32),
  fill: Box<dyn Fn(u32, u32) -> [u8; 3]>,
  crop: Option<(f64, f64, f64, f64)>,
  fractional: bool,
}

impl Setup {
  fn from(surface: Surface) -> Setup {
    match surface {
      Surface::SolidGreen {
        dest,
        buffer,
        fractional,
      } => Setup {
        dest,
        buffer,
        fill: Box::new(|_, _| [0x00, 0xff, 0x00]),
        crop: None,
        fractional,
      },
      Surface::Cropped { src, dest, buffer } => Setup {
        dest,
        buffer,
        fill: Box::new(move |x, y| {
          let inside = x >= src.0 as u32
            && y >= src.1 as u32
            && x < (src.0 + src.2) as u32
            && y < (src.1 + src.3) as u32;
          if inside {
            [0x00, 0xff, 0x00]
          } else {
            [0xff, 0x00, 0x00]
          }
        }),
        crop: Some(src),
        fractional: false,
      },
    }
  }
}

/// Driver for the toplevel client thread. Renders `surface` onto an xdg
/// toplevel, acks the configure, and pumps roundtrips until `stop` is set
/// (observed side effects land in `state`).
pub fn run_client(socket: &Path, surface: Surface, state: SharedState) {
  let (mut client, mut queue) = TestClient::connect(socket, state);
  let wl_surface = client.compositor.create_surface(&client.qh, ());
  let xdg_surface = client
    .xdg_wm_base
    .get_xdg_surface(&wl_surface, &client.qh, ());
  let _toplevel = xdg_surface.get_toplevel(&client.qh, ());
  let viewport = client.viewporter.get_viewport(&wl_surface, &client.qh, ());

  let setup = Setup::from(surface);
  if let Some((sx, sy, sw, sh)) = setup.crop {
    viewport.set_source(sx, sy, sw, sh);
  }
  // Fractional-scale clients render at scale*logical and pin the logical size
  // via wp_viewport (the same contract the wall test uses).
  viewport.set_destination(setup.dest.0, setup.dest.1);
  if setup.fractional {
    let _frac = client
      .fractional
      .get_fractional_scale(&wl_surface, &client.qh, ());
  }

  // Settle the toplevel configure, then paint, attach and commit once.
  queue.roundtrip(&mut client).unwrap();
  let serial = client.xdg_serial.take().expect("no toplevel configure");
  xdg_surface.ack_configure(serial);
  client.attach_buffer(&wl_surface, setup.buffer.0, setup.buffer.1, setup.fill);
  queue.roundtrip(&mut client).unwrap();

  while !client.state.stop.load(Ordering::SeqCst) {
    if let Err(error) = queue.roundtrip(&mut client) {
      eprintln!("[client] dispatch error: {error:?}");
      break;
    }
    thread::sleep(Duration::from_millis(1));
  }
}

/// Step the desktop until it produces a non-black composited frame; return it.
pub fn wait_readback(outer: &mut Desktop, start: &Instant) -> (Vec<u8>, (i32, i32)) {
  spin_frame(outer, start, |pix, _| {
    pix.chunks_exact(4).any(|p| p[..3] != [0, 0, 0])
  })
}

/// Step the desktop until a frame satisfies `pred` (sampled across every frame
/// in a step batch); return that frame. Used when a readback must match a
/// condition beyond "non-black" (e.g. a repainted panel).
pub fn spin_frame(
  outer: &mut Desktop,
  start: &Instant,
  mut pred: impl FnMut(&[u8], (i32, i32)) -> bool,
) -> (Vec<u8>, (i32, i32)) {
  loop {
    let frames = outer.step(start.elapsed().as_millis() as u32);
    for frame in frames {
      if pred(frame.pixels(), frame.size()) {
        return (frame.pixels().to_vec(), frame.size());
      }
    }
    assert!(
      start.elapsed() < Duration::from_secs(15),
      "compositor timed out waiting for a qualifying frame"
    );
    thread::sleep(Duration::from_millis(2));
  }
}

/// Pump the desktop until `pred` holds or the bound expires (fails the test).
pub fn wait_until(outer: &mut Desktop, start: &Instant, mut pred: impl FnMut(&Desktop) -> bool) {
  loop {
    outer.step(start.elapsed().as_millis() as u32);
    if pred(outer) {
      return;
    }
    assert!(
      start.elapsed() < Duration::from_secs(15),
      "wait timed out before the condition held"
    );
    thread::sleep(Duration::from_millis(2));
  }
}

/// Send a press+release click at logical `(x, y)` and wait up to ~6s for the
/// client to register it. Clears `clicked`/`entered` first. Returns whether the
/// client saw the press, so callers can also assert the negative case.
pub fn click(outer: &mut Desktop, start: &Instant, x: i32, y: i32, state: &SharedState) -> bool {
  state.clicked.store(false, Ordering::SeqCst);
  *state.entered.lock().unwrap() = None;
  for kind in [0u32, 1] {
    outer.graphics.input(kind, 0x110, x, y, 1).unwrap();
  }
  let deadline = Instant::now() + Duration::from_secs(6);
  while Instant::now() < deadline && !state.clicked.load(Ordering::SeqCst) {
    outer.step(start.elapsed().as_millis() as u32);
    thread::sleep(Duration::from_millis(2));
  }
  state.clicked.load(Ordering::SeqCst)
}

/// Assert the client did NOT receive a press after sending a click outside the
/// surface (waits briefly so a stray delivery would have been dispatched).
pub fn assert_no_click(outer: &mut Desktop, start: &Instant, x: i32, y: i32, state: &SharedState) {
  state.clicked.store(false, Ordering::SeqCst);
  *state.entered.lock().unwrap() = None;
  for kind in [0u32, 1] {
    outer.graphics.input(kind, 0x110, x, y, 1).unwrap();
  }
  let deadline = Instant::now() + Duration::from_millis(300);
  while Instant::now() < deadline {
    outer.step(start.elapsed().as_millis() as u32);
    thread::sleep(Duration::from_millis(2));
  }
  assert!(
    !state.clicked.load(Ordering::SeqCst),
    "click outside the surface must not reach the client"
  );
}

/// Stop the client and join with a bounded window, pumping the compositor so a
/// client blocked in `roundtrip()` can complete rather than deadlock. FAILS the
/// test (rather than silently detaching) if the thread has not exited in time.
pub fn join_bounded<T>(outer: &mut Desktop, handle: thread::JoinHandle<T>) {
  let deadline = Instant::now() + Duration::from_secs(5);
  while !handle.is_finished() && Instant::now() < deadline {
    outer.graphics.dispatch().unwrap();
    thread::sleep(Duration::from_millis(2));
  }
  assert!(
    handle.is_finished(),
    "client must exit within the teardown bound (was it wedged in roundtrip?)"
  );
  handle.join().unwrap();
}
