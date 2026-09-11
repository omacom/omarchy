//! Deterministic verification of worker-side `wp_fractional_scale`.
//!
//! A real Wayland client (this test process) connects to the in-process private
//! compositor, binds `wp_fractional_scale`, and renders a surface at a
//! fractional resolution buffer (150x150 for a 100x100 logical surface at scale
//! 1.5). We verify together:
//!   * the compositor advertises `preferred_scale` = 1.5 (180 in wl_fixed) to
//!     the client;
//!   * the physical canvas is `round(logical * 1.5)`, i.e. 600x450 for a 400x300
//!     viewport, and the fractional buffer maps 1:1 (crisp) onto it rather than
//!     being upscaled/downscaled as if scale were 1.0;
//!   * input still uses **logical** coordinates: a click inside the logical
//!     surface reaches the client with logical surface-local coords, and a click
//!     outside it does not.
//!
//! Compositor setup, GPU readback, frame ack, and the Wayland client harness are
//! reused from `tests/support/`.

#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;
use desktop::Desktop;
#[path = "support/client.rs"]
mod client;
use client::{
  SharedState, Surface, assert_no_click, click, join_bounded, run_client, wait_readback, wait_until,
};

use omarchy_ward::presentation::Viewport;
use std::{
  fs,
  io::Write,
  os::unix::fs::PermissionsExt,
  path::Path,
  sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
  },
  thread,
  time::Instant,
};

// Logical canvas and render scale. Physical canvas = 600x450.
const VIEWPORT_W: u32 = 400;
const VIEWPORT_H: u32 = 300;
const RENDER_SCALE: f64 = 1.5;
const PREFERRED_WL_FIXED: u32 = 180; // render_scale * 120
// Logical surface size = 100x100; fractional buffer = 150x150 (1:1 crisp).
const LOGICAL_W: i32 = 100;
const LOGICAL_H: i32 = 100;
const BUFFER_W: i32 = (LOGICAL_W as f64 * RENDER_SCALE).round() as i32; // 150
const BUFFER_H: i32 = (LOGICAL_H as f64 * RENDER_SCALE).round() as i32; // 150
// The compositor centers the toplevel; centered logical rect of the surface.
const CENTER_X: i32 = (VIEWPORT_W as i32 - LOGICAL_W) / 2; // 150
const CENTER_Y: i32 = (VIEWPORT_H as i32 - LOGICAL_H) / 2; // 100
// Physical (readback) rect of the surface at 1.5x.
const PHYS_W: i32 = BUFFER_W; // 150
const PHYS_H: i32 = BUFFER_H; // 150
const PHYS_X: i32 = (CENTER_X as f64 * RENDER_SCALE).round() as i32; // 225
const PHYS_Y: i32 = (CENTER_Y as f64 * RENDER_SCALE).round() as i32; // 150
// Logical input points (input space is logical, unchanged by the scale).
const CLICK_X: i32 = CENTER_X + LOGICAL_W / 2; // 200
const CLICK_Y: i32 = CENTER_Y + LOGICAL_H / 2; // 150
const LOCAL_X: f64 = (CLICK_X - CENTER_X) as f64; // 50
const LOCAL_Y: f64 = (CLICK_Y - CENTER_Y) as f64; // 50

#[test]
fn fractional_scale_advertises_preferred_and_renders_crisp_with_logical_input() {
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
  // Drives the worker at render scale 1.5 -> physical canvas 600x450.
  let mut outer = Desktop::new_scaled(root.path(), viewport, RENDER_SCALE);

  let stop = Arc::new(AtomicBool::new(false));
  let state = SharedState::new(stop.clone());
  let (sc, st2) = (root.path().join("wayland"), state.clone());
  let client = thread::spawn(move || {
    run_client(
      &sc,
      Surface::SolidGreen {
        dest: (LOGICAL_W, LOGICAL_H),
        buffer: (BUFFER_W, BUFFER_H),
        fractional: true,
      },
      st2,
    )
  });

  let start = Instant::now();
  let (bytes, (width, height)) = wait_readback(&mut outer, &start);

  // The physical canvas must be round(logical * 1.5) = 600x450, not 400x300.
  assert_eq!(
    (width, height),
    (
      (VIEWPORT_W as f64 * RENDER_SCALE).round() as i32,
      (VIEWPORT_H as f64 * RENDER_SCALE).round() as i32
    ),
    "physical canvas must be the fractional round size"
  );

  if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
    let mut file = std::io::BufWriter::new(
      fs::File::create(Path::new(&directory).join("fractional.ppm")).unwrap(),
    );
    write!(file, "P6\n{width} {height}\n255\n").unwrap();
    for pixel in bytes.chunks_exact(4) {
      file.write_all(&pixel[..3]).unwrap();
    }
  }

  let pixel =
    |x: usize, y: usize| &bytes[(y * width as usize + x) * 4..(y * width as usize + x) * 4 + 3];
  // Read back is RGB-order regardless of the export fourcc (mirrors surfaces.rs).
  // The 1:1 (crisp) fractional buffer must occupy exactly a PHYS_W x PHYS_H
  // rectangle at the scaled center, sized by the fractional scale - not the
  // logical size upscaled, not the logical size downscaled.
  let (mut min_x, mut min_y, mut max_x, mut max_y, mut colored) =
    (usize::MAX, usize::MAX, 0usize, 0usize, 0usize);
  for y in 0..height as usize {
    for x in 0..width as usize {
      if pixel(x, y) != [0, 0, 0] {
        min_x = min_x.min(x);
        min_y = min_y.min(y);
        max_x = max_x.max(x);
        max_y = max_y.max(y);
        colored += 1;
      }
    }
  }
  assert_eq!(
    (min_x, min_y, max_x, max_y),
    (
      PHYS_X as usize,
      PHYS_Y as usize,
      (PHYS_X + PHYS_W - 1) as usize,
      (PHYS_Y + PHYS_H - 1) as usize,
    ),
    "fractional buffer must map to the fractional physical rect (1:1 crisp)"
  );
  assert_eq!(
    colored,
    (PHYS_W * PHYS_H) as usize,
    "the fractional surface must fill exactly its 1:1 physical rect"
  );

  wait_until(&mut outer, &start, |_| {
    state.preferred.lock().unwrap().is_some()
  });
  assert_eq!(
    *state.preferred.lock().unwrap(),
    Some(PREFERRED_WL_FIXED),
    "compositor must advertise preferred_scale = render_scale * 120"
  );

  // Input stays logical: a click at logical (200,150) is inside the 100x100
  // logical surface centered at (150,100) and must reach the client with the
  // logical surface-local coords (50,50).
  assert!(
    click(&mut outer, &start, CLICK_X, CLICK_Y, &state),
    "logical click inside the fractional surface must reach the client"
  );
  assert_eq!(
    *state.entered.lock().unwrap(),
    Some((LOCAL_X, LOCAL_Y)),
    "pointer enter must report logical surface-local coords"
  );

  // A logical click outside the surface must not reach the client.
  assert_no_click(&mut outer, &start, 50, VIEWPORT_H as i32 / 2, &state);

  state.stop.store(true, Ordering::SeqCst);
  join_bounded(&mut outer, client);
}
