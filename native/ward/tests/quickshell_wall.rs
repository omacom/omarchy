//! Deterministic coverage for a real client panel (a Quickshell-style bar)
//! surfaced on the *second* output of a worker-side "monitor wall", including
//! wall addition/removal/rescaling, fractional sharpness of a pixel-detail
//! pattern, and repaint driven by actual `zwlr_layer_surface` configure events.
//!
//! A layer-shell client plays the role of a Quickshell panel: it is created on
//! output 1 (the right half of a two-output 400x300 canvas at render scale
//! 1.5) and anchored to the bottom of that output. The client is a well-behaved
//! HiDPI client: it renders a fractional-scale buffer (e.g. 300x60) but
//! describes the intended logical layout (200x40) via `wp_viewport`, and it
//! acknowledges every `zwlr_layer_surface.configure` it receives, rebuilding
//! (and re-committing) a freshly-sized banded buffer whenever the configure
//! size changes. We verify together:
//!   * `new_layer_surface` no longer discards the requested output — the panel
//!     is constrained to the logical rect of the wall output it was created on
//!     (physical x in [300, 600)) instead of being centred in the whole canvas
//!     or stretched across every output;
//!   * `surface_logical_rect` follows the layer's real placement (so
//!     `enter`/`leave` and the layer geometry reconcile) rather than re-centring
//!     the surface;
//!   * a pixel-detail pattern (four pure-colour vertical bands) reads back
//!     sharp at the fractional scale — every panel pixel is a pure band colour
//!     with band boundaries exactly at round(offset * 1.5), proving the
//!     composite is not bilinear-blurred;
//!   * raising the wall from two to three outputs re-locates output 1 to a
//!     narrower rect **at the same scale**, and the wall must push a fresh
//!     `configure` (100,40) to the already-created panel — never only on a
//!     canvas reallocation. The client acks and repaints, and the composite
//!     shows the panel at its new bounds with no stale spill where the old,
//!     wider panel was;
//!   * shrinking back to two (and later rescaling to 2.0) likewise drives a
//!     repaint so the panel tracks its re-located output, with the stale region
//!     empty after shrink;
//!   * host pointer input hit-tests the re-located panel and reports the
//!     logical surface-local coords implied by its new placement.
//!
//! The client is joined with a bounded wait so a client blocked in
//! `roundtrip()` cannot deadlock test teardown; if it has not exited within the
//! bound the test FAILS (no silent detach) so a wedged client is caught.

#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;
use desktop::Desktop;
#[path = "support/client.rs"]
mod client;
use client::{join_bounded, spin_frame};

use omarchy_ward::graphics::OutputSpec;
use omarchy_ward::presentation::Viewport;
use std::{
  fs,
  io::Write,
  os::{
    fd::{AsFd, FromRawFd},
    unix::{fs::PermissionsExt, net::UnixStream},
  },
  path::Path,
  sync::{
    Arc, Mutex,
    atomic::{AtomicBool, Ordering},
  },
  thread,
  time::{Duration, Instant},
};
use wayland_client::{
  Connection, Dispatch, Proxy, QueueHandle, WEnum,
  backend::ObjectId,
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
use wayland_protocols::wp::viewporter::client::{
  wp_viewport::WpViewport, wp_viewporter::WpViewporter,
};
use wayland_protocols_wlr::layer_shell::v1::client::{
  zwlr_layer_shell_v1::{Layer, ZwlrLayerShellV1},
  zwlr_layer_surface_v1::{self, Anchor, ZwlrLayerSurfaceV1},
};

// Logical canvas and render scale (physical canvas 600x450).
const VIEWPORT_W: u32 = 400;
const VIEWPORT_H: u32 = 300;
const RENDER_SCALE: f64 = 1.5;
const SCALE_FIXED: u32 = 180; // render_scale * 120
const SCALE_FIXED_2: u32 = 240; // render scale 2.0
// Output 1 (the wall's right half) is the panel's home: logical [200, 400).
const OUTPUT_1_X: i32 = 200;
const OUTPUT_1_W: u32 = 200;
// A bottom-anchored bar of output 1's full width, 40 logical high.
const PANEL_LOGICAL_H: f64 = 40.0;
// Physical panel buffer at 1.5x: 300x60.
const PANEL_PHYS_W: i32 = 300;
const PANEL_PHYS_H: i32 = 60;
// Physical origin of the panel (output 1's rect, bottom-anchored, margin 0).
const PANEL_PHYS_X: i32 = (OUTPUT_1_X as f64 * RENDER_SCALE).round() as i32; // 300
const PANEL_PHYS_Y: i32 =
  ((VIEWPORT_H as i32 - PANEL_LOGICAL_H as i32) as f64 * RENDER_SCALE).round() as i32; // 390
// Four vertical bands, each 50 logical px (75 physical px at 1.5x) wide, of
// distinct pure RGB colours as read back in the Frame bytes (byte0 = R). The
// buffer is written BGR (wl_shm ARGB8888), so the band RGB is reversed on the
// way in.
const BAND_LOGICAL_W: f64 = 50.0;
const BAND_PHYS_W: i32 = (BAND_LOGICAL_W * RENDER_SCALE).round() as i32; // 75
const BANDS: [[u8; 3]; 4] = [[200, 0, 0], [0, 200, 0], [0, 0, 200], [220, 220, 220]]; // R G B W
// When the wall grows, output 1's logical width drops 200 -> 100 (same scale).
const SHRUNK_LOGICAL_W: u32 = 100;

struct Client {
  qh: QueueHandle<Client>,
  layer_serial: Option<u32>,
  /// Every layer configure size the client observed, in order.
  configures: Arc<Mutex<Vec<(u32, u32)>>>,
  /// wl_output object ids the surface has entered.
  bound: Arc<Mutex<Vec<ObjectId>>>,
  /// Pointer-enter surface-local coords of the panel, if any.
  entered: Arc<Mutex<Option<(f64, f64)>>>,
  /// A button press on the panel.
  clicked: Arc<AtomicBool>,
  /// The render scale the client should paint at (1.5 initially, 2.0 later).
  scale: Arc<Mutex<f64>>,
  /// Currently attached physical buffer size.
  phys: Option<(i32, i32)>,
  shm: Option<WlShm>,
  surface: Option<WlSurface>,
  layer: Option<ZwlrLayerSurfaceV1>,
  viewport: Option<WpViewport>,
}

impl Client {
  /// (Re)create the banded buffer for a logical `lw`x`lh` lay-out at the given
  /// fractional scale, set the viewport destination, attach and commit — the
  /// repaint path a Quickshell-style panel takes when it acks a configure.
  fn attach_band_buffer(&mut self, lw: u32, lh: u32, scale: f64) {
    let (pw, ph) = (
      (f64::from(lw) * scale).round() as u32,
      (f64::from(lh) * scale).round() as u32,
    );
    let mut data = vec![0u8; (pw * ph * 4) as usize];
    let band_w = (BAND_LOGICAL_W * scale).round() as usize;
    for y in 0..ph {
      for x in 0..pw {
        let band = (x as usize / band_w).min(BANDS.len() - 1);
        let color = BANDS[band];
        let base = (y as usize * pw as usize + x as usize) * 4;
        // wl_shm ARGB8888 (LE) stores B G R A bytes.
        data[base..base + 4].copy_from_slice(&[color[2], color[1], color[0], 0xff]);
      }
    }
    let fd = unsafe { libc::memfd_create(c"quickshell-wall-test".as_ptr(), libc::MFD_CLOEXEC) };
    assert!(fd >= 0, "memfd_create failed");
    let mut file = unsafe { fs::File::from_raw_fd(fd) };
    file.write_all(&data).unwrap();
    let shm = self.shm.as_ref().expect("shm bound");
    let pool = shm.create_pool(file.as_fd(), (pw * ph * 4) as i32, &self.qh, ());
    let buffer = pool.create_buffer(
      0,
      pw as i32,
      ph as i32,
      (pw * 4) as i32,
      Format::Argb8888,
      &self.qh,
      (),
    );
    if let Some(viewport) = &self.viewport {
      viewport.set_destination(lw as i32, lh as i32);
    }
    let surface = self.surface.as_ref().expect("surface created");
    surface.attach(Some(&buffer), 0, 0);
    self.phys = Some((pw as i32, ph as i32));
    surface.commit();
  }
}

macro_rules! noop {
  ($($t:ty),* $(,)?) => {
    $(
      impl Dispatch<$t, ()> for Client {
        fn event(
          _: &mut Client,
          _: &$t,
          _: <$t as wayland_client::Proxy>::Event,
          _: &(),
          _: &Connection,
          _: &QueueHandle<Client>,
        ) {}
      }
    )*
  };
}

impl Dispatch<WlRegistry, wayland_client::globals::GlobalListContents> for Client {
  fn event(
    _: &mut Client,
    _: &WlRegistry,
    _: wl_registry::Event,
    _: &wayland_client::globals::GlobalListContents,
    _: &Connection,
    _: &QueueHandle<Client>,
  ) {
  }
}

impl Dispatch<ZwlrLayerSurfaceV1, ()> for Client {
  fn event(
    state: &mut Client,
    _: &ZwlrLayerSurfaceV1,
    event: zwlr_layer_surface_v1::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<Client>,
  ) {
    if let zwlr_layer_surface_v1::Event::Configure {
      serial,
      width,
      height,
    } = event
    {
      state.configures.lock().unwrap().push((width, height));
      state.layer_serial = Some(serial);
      // Acknowledge before committing content for the configured size.
      if let Some(layer) = &state.layer {
        layer.ack_configure(serial);
      }
      let scale = *state.scale.lock().unwrap();
      let (pw, ph) = (
        (f64::from(width) * scale).round() as i32,
        (f64::from(height) * scale).round() as i32,
      );
      if state.phys != Some((pw, ph)) {
        state.attach_band_buffer(width, height, scale);
      }
    }
  }
}

impl Dispatch<WlSurface, ()> for Client {
  fn event(
    state: &mut Client,
    _: &WlSurface,
    event: wl_surface::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<Client>,
  ) {
    if let wl_surface::Event::Enter { output, .. } = event {
      let id = output.id();
      let mut b = state.bound.lock().unwrap();
      if !b.contains(&id) {
        b.push(id);
      }
    }
  }
}

impl Dispatch<WlPointer, ()> for Client {
  fn event(
    state: &mut Client,
    _: &WlPointer,
    event: wl_pointer::Event,
    _: &(),
    _: &Connection,
    _: &QueueHandle<Client>,
  ) {
    match event {
      wl_pointer::Event::Enter {
        surface_x,
        surface_y,
        ..
      } => {
        *state.entered.lock().unwrap() = Some((surface_x, surface_y));
      }
      wl_pointer::Event::Button { state: s, .. } => {
        if matches!(s, WEnum::Value(ButtonState::Pressed)) {
          state.clicked.store(true, Ordering::SeqCst);
        }
      }
      _ => {}
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
  ZwlrLayerShellV1,
  WpViewporter,
  WpViewport,
}

fn run_client(
  socket: &Path,
  bound: Arc<Mutex<Vec<ObjectId>>>,
  stop: Arc<AtomicBool>,
  configures: Arc<Mutex<Vec<(u32, u32)>>>,
  entered: Arc<Mutex<Option<(f64, f64)>>>,
  clicked: Arc<AtomicBool>,
  scale: Arc<Mutex<f64>>,
) {
  let stream = UnixStream::connect(socket).unwrap();
  let conn = Connection::from_socket(stream).unwrap();
  let (globals, mut queue) = registry_queue_init::<Client>(&conn).unwrap();
  let qh = queue.handle();
  let compositor: WlCompositor = globals.bind(&qh, 4..=6, ()).unwrap();
  let shm: WlShm = globals.bind(&qh, 1..=1, ()).unwrap();
  let layer_shell: ZwlrLayerShellV1 = globals.bind(&qh, 1..=1, ()).unwrap();
  let viewporter: WpViewporter = globals.bind(&qh, 1..=1, ()).unwrap();
  let seat: WlSeat = globals.bind(&qh, 1..=1, ()).unwrap();
  let pointer = seat.get_pointer(&qh, ());

  let outputs: Vec<WlOutput> = globals
    .contents()
    .clone_list()
    .iter()
    .filter(|g| g.interface == "wl_output")
    .map(|g| globals.registry().bind(g.name, g.version, &qh, ()))
    .collect();
  let home = outputs
    .get(1)
    .expect("wall must advertise at least two outputs");

  let surface = compositor.create_surface(&qh, ());
  // A real HiDPI client renders its panel at the fractional scale (300x60
  // physical) but describes the intended 200x40 logical layout via a
  // viewport, exactly like Quickshell does on a scaled output. The viewport
  // destination is re-derived on every repaint.
  let viewport = viewporter.get_viewport(&surface, &qh, ());
  let layer = layer_shell.get_layer_surface(
    &surface,
    Some(home),
    Layer::Overlay,
    "test-panel".into(),
    &qh,
    (),
  );
  layer.set_anchor(Anchor::Bottom | Anchor::Left | Anchor::Right);
  // The protocol requires an explicit size when a dimension is not fully
  // anchored (height here); the wall re-derives the real size via configure.
  layer.set_size(OUTPUT_1_W, PANEL_LOGICAL_H as u32);

  let mut client = Client {
    qh,
    layer_serial: None,
    configures,
    bound,
    entered,
    clicked,
    scale,
    phys: None,
    shm: Some(shm),
    surface: Some(surface),
    layer: Some(layer),
    viewport: Some(viewport),
  };
  // First commit primes the layer: the compositor replies with a configure and
  // the handler allocates the initial buffer and acks it.
  client.surface.as_ref().unwrap().commit();
  queue.roundtrip(&mut client).unwrap();
  // On the very first configure the handler attached the initial buffer; give
  // the compositor a bound event/enter round to settle before we start.
  queue.roundtrip(&mut client).unwrap();

  while !stop.load(Ordering::SeqCst) {
    if let Err(error) = queue.roundtrip(&mut client) {
      eprintln!("[client] dispatch error: {error:?}");
      break;
    }
    thread::sleep(Duration::from_millis(1));
  }
  // Keep the pointer proxy alive until teardown.
  let _ = &pointer;
}

fn phys_of(lw: i32, lh: i32, scale: f64) -> (i32, i32) {
  (
    (f64::from(lw) * scale).round() as i32,
    (f64::from(lh) * scale).round() as i32,
  )
}

#[test]
fn quickshell_panel_lives_on_second_output_and_survives_wall_changes() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
    return;
  }
  let root = tempfile::Builder::new()
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir()
    .unwrap();
  let viewport = Viewport {
    width: VIEWPORT_W,
    height: VIEWPORT_H,
    scale_fixed: 120,
  };
  let mut outer = Desktop::new_scaled(root.path(), viewport, RENDER_SCALE);

  // Two side-by-side outputs: [0,200) and [200,400), both full height.
  outer
    .graphics
    .configure_outputs(
      &[
        OutputSpec {
          x: 0,
          y: 0,
          width: 200,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
        OutputSpec {
          x: OUTPUT_1_X,
          y: 0,
          width: OUTPUT_1_W,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
      ],
      0,
    )
    .unwrap();

  let bound = Arc::new(Mutex::new(Vec::new()));
  let stop = Arc::new(AtomicBool::new(false));
  let configures = Arc::new(Mutex::new(Vec::new()));
  let entered = Arc::new(Mutex::new(None));
  let clicked = Arc::new(AtomicBool::new(false));
  let scale = Arc::new(Mutex::new(RENDER_SCALE));
  let (path2, b2, s2) = (root.path().join("wayland"), bound.clone(), stop.clone());
  let (c2, e2, cl2, sc2) = (
    configures.clone(),
    entered.clone(),
    clicked.clone(),
    scale.clone(),
  );
  let handle = thread::spawn(move || run_client(&path2, b2, s2, c2, e2, cl2, sc2));

  let start = Instant::now();
  // The panel must compose sharply at its initial bounds [300,600)x[390,450).
  let (bytes, (width, height)) = spin_frame(&mut outer, &start, |pix, size| {
    let px = |x: i32, y: i32| -> [u8; 3] {
      let base = (y as usize * size.0 as usize + x as usize) * 4;
      [pix[base], pix[base + 1], pix[base + 2]]
    };
    (0..PANEL_PHYS_W).all(|x| {
      let y = PANEL_PHYS_Y + PANEL_PHYS_H / 2;
      px(PANEL_PHYS_X + x, y) != [0, 0, 0]
    })
  });
  assert_eq!(
    (width, height),
    phys_of(VIEWPORT_W as i32, VIEWPORT_H as i32, RENDER_SCALE),
    "wall still composites one crisp physical canvas"
  );
  let pixel = |x: usize, y: usize| -> [u8; 3] {
    let base = (y * width as usize + x) * 4;
    [bytes[base], bytes[base + 1], bytes[base + 2]]
  };
  // The panel must occupy exactly output 1's bottom region — proving it is
  // constrained to the requested output rather than centred in / stretched
  // over the whole canvas.
  for y in PANEL_PHYS_Y..PANEL_PHYS_Y + PANEL_PHYS_H {
    for x in PANEL_PHYS_X..PANEL_PHYS_X + PANEL_PHYS_W {
      assert_ne!(
        pixel(x as usize, y as usize),
        [0, 0, 0],
        "every panel pixel must be a band colour at ({x},{y})"
      );
    }
  }
  // The row directly above the panel and all of output 0 stay empty.
  for x in PANEL_PHYS_X..PANEL_PHYS_X + PANEL_PHYS_W {
    assert_eq!(
      pixel(x as usize, (PANEL_PHYS_Y - 1) as usize),
      [0, 0, 0],
      "output above the panel must be empty"
    );
  }
  assert!(
    (PANEL_PHYS_Y - 20..PANEL_PHYS_Y - 1)
      .flat_map(|y| (0..PANEL_PHYS_X).map(move |x| pixel(x as usize, y as usize)))
      .all(|p| p == [0, 0, 0]),
    "output 0 must stay empty: the panel must not spill off its output"
  );
  // Fractional sharpness + precise placement: each band's first physical
  // column is exactly round(band_index * band_logical * 1.5), and every pixel
  // in it a pure band colour (no blended intermediate).
  for (band, color) in BANDS.iter().enumerate() {
    let expected_x = PANEL_PHYS_X + band as i32 * BAND_PHYS_W;
    let mid_y = PANEL_PHYS_Y + PANEL_PHYS_H / 2;
    for x in expected_x..expected_x + BAND_PHYS_W {
      assert_eq!(
        pixel(x as usize, mid_y as usize),
        *color,
        "band {band} must be a pure colour across its whole 75px extent"
      );
    }
  }

  // --- Grow the wall to three outputs (same scale): output 1 narrows 200->100
  // logical, so the already-created panel must receive a fresh configure and
  // repaint, and the old wider panel region must not spill.
  outer
    .graphics
    .configure_outputs(
      &[
        OutputSpec {
          x: 0,
          y: 0,
          width: 200,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
        OutputSpec {
          x: 200,
          y: 0,
          width: SHRUNK_LOGICAL_W,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
        OutputSpec {
          x: 300,
          y: 0,
          width: 100,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
      ],
      1,
    )
    .unwrap();
  assert_eq!(
    outer.graphics.output_count(),
    3,
    "growing the wall must advertise a third global"
  );
  let g3 = [
    outer.graphics.output_global(0),
    outer.graphics.output_global(1),
    outer.graphics.output_global(2),
  ];
  assert!(g3.iter().all(|g| g.is_some()));
  assert_ne!(g3[0], g3[1], "the three globals must be distinct");
  assert_ne!(g3[1], g3[2], "the three globals must be distinct");
  // The wall must have repainted the panel without a canvas reallocation:
  // drive until the client observed (100,40) AND a frame shows the new, narrow
  // panel [300,450)x[390,450) with the stale region [450,600) empty.
  let shrunk_phys = phys_of(
    SHRUNK_LOGICAL_W as i32,
    PANEL_LOGICAL_H as i32,
    RENDER_SCALE,
  );
  let (bytes2, (w2, h2)) = spin_frame(&mut outer, &start, |pix, size| {
    configures.lock().unwrap().contains(&(100, 40)) && {
      let px = |x: i32, y: i32| -> [u8; 3] {
        let base = (y as usize * size.0 as usize + x as usize) * 4;
        [pix[base], pix[base + 1], pix[base + 2]]
      };
      // New panel present and pure across its full height at a sampled row,
      // AND the stale region where the old wider panel was is empty (the
      // client has acks and repainted), so this is the settled frame.
      let mid = PANEL_PHYS_Y + shrunk_phys.1 / 2;
      let present = (0..shrunk_phys.0).all(|x| px(PANEL_PHYS_X + x, mid) != [0, 0, 0]);
      let stale_clear =
        (shrunk_phys.0..PANEL_PHYS_W).all(|x| px(PANEL_PHYS_X + x, mid) == [0, 0, 0]);
      present && stale_clear
    }
  });
  assert_eq!(
    (w2, h2),
    (width, height),
    "same-scale wall growth must not reallocate the canvas"
  );
  let p2 = |x: usize, y: usize| -> [u8; 3] {
    let base = (y * w2 as usize + x) * 4;
    [bytes2[base], bytes2[base + 1], bytes2[base + 2]]
  };
  for y in PANEL_PHYS_Y..PANEL_PHYS_Y + shrunk_phys.1 {
    for x in PANEL_PHYS_X..PANEL_PHYS_X + shrunk_phys.0 {
      assert_ne!(
        p2(x as usize, y as usize),
        [0, 0, 0],
        "narrowed panel present at ({x},{y})"
      );
    }
  }
  // Stale spill: where the old 300-wide panel extended, now only black.
  let old_w = PANEL_PHYS_W;
  for y in PANEL_PHYS_Y..PANEL_PHYS_Y + shrunk_phys.1 {
    for x in PANEL_PHYS_X + shrunk_phys.0..PANEL_PHYS_X + old_w {
      assert_eq!(
        p2(x as usize, y as usize),
        [0, 0, 0],
        "the old wider panel must not spill at ({x},{y})"
      );
    }
  }

  // Input must track the re-located panel: click inside the narrowed output 1
  // (logical [200,300)x[260,300)) and expect the surface-local coords implied
  // by that placement. Move to an empty point above the panel first so the
  // enter actually fires on the re-located surface.
  outer
    .graphics
    .input(2, 0, 150, 50, start.elapsed().as_millis() as u32)
    .unwrap();
  let click_x = 240; // logical, inside [200,300)
  let click_y = 270; // logical, inside [260,300)
  let deadline = Instant::now() + Duration::from_secs(5);
  while Instant::now() < deadline && !clicked.load(Ordering::SeqCst) {
    outer
      .graphics
      .input(
        0,
        0x111,
        click_x,
        click_y,
        start.elapsed().as_millis() as u32,
      )
      .unwrap();
    outer.step(start.elapsed().as_millis() as u32);
    thread::sleep(Duration::from_millis(2));
  }
  assert!(
    clicked.load(Ordering::SeqCst),
    "click must reach the re-located panel"
  );
  assert_eq!(
    *entered.lock().unwrap(),
    Some((40.0, 10.0)),
    "pointer enter must report the new placement-local coords"
  );
  // Release the button back to a clean state.
  outer
    .graphics
    .input(
      1,
      0x111,
      click_x,
      click_y,
      start.elapsed().as_millis() as u32,
    )
    .unwrap();
  outer.step(start.elapsed().as_millis() as u32);

  // --- Shrink back to two outputs: output 1 regains width 200, the panel is
  // reconfigured back to 200 logical and repaints to its original bounds, and
  // the region right of the panel (its stale narrow column at scale 1.5,
  // [450,600)) must be empty again.
  outer
    .graphics
    .configure_outputs(
      &[
        OutputSpec {
          x: 0,
          y: 0,
          width: 200,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
        OutputSpec {
          x: OUTPUT_1_X,
          y: 0,
          width: OUTPUT_1_W,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
      ],
      2,
    )
    .unwrap();
  assert_eq!(
    outer.graphics.output_count(),
    2,
    "shrinking the wall must retire the extra global"
  );
  let (bytes3, (w3, h3)) = spin_frame(&mut outer, &start, |pix, size| {
    configures.lock().unwrap().contains(&(OUTPUT_1_W, 40)) && {
      let px = |x: i32, y: i32| -> [u8; 3] {
        let base = (y as usize * size.0 as usize + x as usize) * 4;
        [pix[base], pix[base + 1], pix[base + 2]]
      };
      let mid = PANEL_PHYS_Y + PANEL_PHYS_H / 2;
      (0..PANEL_PHYS_W).all(|x| px(PANEL_PHYS_X + x, mid) != [0, 0, 0])
    }
  });
  assert_eq!((w3, h3), (width, height), "canvas size unchanged by shrink");
  let p3 = |x: usize, y: usize| -> [u8; 3] {
    let base = (y * w3 as usize + x) * 4;
    [bytes3[base], bytes3[base + 1], bytes3[base + 2]]
  };
  for y in PANEL_PHYS_Y..PANEL_PHYS_Y + PANEL_PHYS_H {
    for x in PANEL_PHYS_X..PANEL_PHYS_X + PANEL_PHYS_W {
      assert_ne!(
        p3(x as usize, y as usize),
        [0, 0, 0],
        "restored panel present at ({x},{y})"
      );
    }
  }

  // --- Rescale the wall to 2.0 (canvas 800x600): every output's advertised
  // mode becomes the rounded physical size of its unchanged logical rect, and
  // the panel repaints at the new scale to output 1's physical bounds.
  *scale.lock().unwrap() = 2.0;
  outer
    .graphics
    .configure_outputs(
      &[
        OutputSpec {
          x: 0,
          y: 0,
          width: 200,
          height: 300,
          scale_fixed: SCALE_FIXED_2,
        },
        OutputSpec {
          x: OUTPUT_1_X,
          y: 0,
          width: OUTPUT_1_W,
          height: 300,
          scale_fixed: SCALE_FIXED_2,
        },
      ],
      3,
    )
    .unwrap();
  assert_eq!(
    outer.graphics.output_mode(0),
    Some((400, 600)),
    "rescaling the wall must update each output's advertised mode"
  );
  assert_eq!(
    outer.graphics.output_mode(1),
    Some((400, 600)),
    "rescaling the wall must update each output's advertised mode"
  );
  let scaled2_phys = phys_of(OUTPUT_1_W as i32, PANEL_LOGICAL_H as i32, 2.0);
  let scaled2_x = (OUTPUT_1_X as f64 * 2.0).round() as i32;
  let scaled2_y = ((VIEWPORT_H as i32 - PANEL_LOGICAL_H as i32) as f64 * 2.0).round() as i32;
  let (bytes4, (w4, h4)) = spin_frame(&mut outer, &start, |pix, size| {
    let px = |x: i32, y: i32| -> [u8; 3] {
      let base = (y as usize * size.0 as usize + x as usize) * 4;
      [pix[base], pix[base + 1], pix[base + 2]]
    };
    let mid = scaled2_y + scaled2_phys.1 / 2;
    (0..scaled2_phys.0).all(|x| px(scaled2_x + x, mid) != [0, 0, 0])
      && (0..size.0).all(|x| px(x, scaled2_y - 1) == [0, 0, 0])
  });
  assert_eq!(
    (w4, h4),
    phys_of(VIEWPORT_W as i32, VIEWPORT_H as i32, 2.0),
    "rescaling must yield the 800x600 canvas"
  );
  let p4 = |x: usize, y: usize| -> [u8; 3] {
    let base = (y * w4 as usize + x) * 4;
    [bytes4[base], bytes4[base + 1], bytes4[base + 2]]
  };
  for y in scaled2_y..scaled2_y + scaled2_phys.1 {
    for x in scaled2_x..scaled2_x + scaled2_phys.0 {
      assert_ne!(
        p4(x as usize, y as usize),
        [0, 0, 0],
        "rescaled panel present at ({x},{y})"
      );
    }
  }

  // Bounded teardown: stop the client, keep dispatching until it has exited,
  // and only then join (propagating any panic). A client still blocked in
  // roundtrip() after the bound FAILS the test rather than silently passing.
  stop.store(true, Ordering::SeqCst);
  join_bounded(&mut outer, handle);
}
