//! Deterministic verification of worker-side `wp_viewporter`.
//!
//! A real Wayland client (this test process, speaking the wire protocol) connects
//! to the in-process private compositor, attaches a shared-memory buffer, applies
//! `wp_viewport.set_source` (fixed-point crop) + `set_destination` (integer
//! scale), and verifies that rendering, input hit-testing, and the input mask
//! all honor the transform. Compositor setup, GPU readback, frame
//! acknowledgement, and the Wayland client harness are reused from
//! `tests/support/`.

#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;
use desktop::Desktop;
#[path = "support/client.rs"]
mod client;
use client::{
  SharedState, Surface, assert_no_click, click, join_bounded, run_client, wait_readback,
};

use omarchy_ward::presentation::{Region, Viewport};
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

// Buffer is 64x48 shared memory. We mark the source-crop rectangle green and
// everything outside it red, so a successful crop (via wp_viewport) must leave
// only green visible on screen; any red is proof the crop was ignored.
const BUFFER_W: i32 = 64;
const BUFFER_H: i32 = 48;
const SRC_X: f64 = 16.0;
const SRC_Y: f64 = 8.0;
const SRC_W: f64 = 32.0;
const SRC_H: f64 = 24.0;
// Destination scales the crop up (4x) to a 128x96 on-screen surface - larger
// than the raw 64x48 buffer - so hit-testing must honor the destination rect,
// not the raw buffer size.
const DST_W: i32 = 128;
const DST_H: i32 = 96;
const VIEWPORT_W: u32 = 400;
const VIEWPORT_H: u32 = 300;
const SURFACE_X: usize = (VIEWPORT_W as usize - DST_W as usize) / 2; // 136
const SURFACE_Y: usize = (VIEWPORT_H as usize - DST_H as usize) / 2; // 102
// A point inside the scaled right half of the surface. At the raw 64x48 buffer
// size this x (260 - 136 = 124 > 64) would be missed, so a hit here proves the
// destination rect governs interaction. The client should observe these as
// surface-local coordinates.
const CLICK_X: usize = 260;
const CLICK_Y: usize = 190;
const LOCAL_X: f64 = (CLICK_X - SURFACE_X) as f64; // 124
const LOCAL_Y: f64 = (CLICK_Y - SURFACE_Y) as f64; // 88

/// Evaluate the same per-surface union/clip/subtract mask that Qt consumes.
fn masked(regions: &[Region], x: u32, y: u32) -> bool {
  let (mut result, mut current, mut clip) = (false, false, false);
  for region in regions {
    let contains =
      x >= region.x && y >= region.y && x < region.x + region.width && y < region.y + region.height;
    match region.operation {
      0 => {
        result |= current && clip;
        current = false;
        clip = contains;
      }
      1 => current |= contains,
      2 => current &= !contains,
      _ => panic!("invalid region operation"),
    }
  }
  result || (current && clip)
}

#[test]
fn viewport_crops_scales_and_hit_tests_transformed_surface() {
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
  let mut outer = Desktop::new(root.path(), viewport);

  let stop = Arc::new(AtomicBool::new(false));
  let state = SharedState::new(stop.clone());
  let (sc, st2) = (root.path().join("wayland"), state.clone());
  let client = thread::spawn(move || {
    run_client(
      &sc,
      Surface::Cropped {
        src: (SRC_X, SRC_Y, SRC_W, SRC_H),
        dest: (DST_W, DST_H),
        buffer: (BUFFER_W, BUFFER_H),
      },
      st2,
    )
  });

  let start = Instant::now();
  let (bytes, _size) = wait_readback(&mut outer, &start);
  let (width, height) = (VIEWPORT_W as usize, VIEWPORT_H as usize);

  if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
    let mut file = std::io::BufWriter::new(
      fs::File::create(Path::new(&directory).join("viewport.ppm")).unwrap(),
    );
    write!(file, "P6\n{width} {height}\n255\n").unwrap();
    for pixel in bytes.chunks_exact(4) {
      file.write_all(&pixel[..3]).unwrap();
    }
  }

  let pixel = |x: usize, y: usize| &bytes[(y * width + x) * 4..(y * width + x) * 4 + 3];
  let count = |rgb: [u8; 3]| bytes.chunks_exact(4).filter(|p| p[..3] == rgb).count();
  // Read back is RGB-order regardless of the export fourcc (mirrors surfaces.rs).
  let green = [0x00, 0xff, 0x00];
  let red = [0xff, 0x00, 0x00];

  // Rendering + crop + scale: the colored pixels must exactly fill a 128x96
  // rectangle centered on the viewport (the dst rect), and the red surround from
  // outside the source crop must be completely excluded. GL linear filtering puts
  // a thin anti-aliased border on the outermost 1-2px, so the interior is asserted
  // as pure green and the bounding box / count are exact.
  let (mut min_x, mut min_y, mut max_x, mut max_y, mut colored) =
    (usize::MAX, usize::MAX, 0usize, 0usize, 0usize);
  for y in 0..height {
    for x in 0..width {
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
      SURFACE_X,
      SURFACE_Y,
      SURFACE_X + DST_W as usize - 1,
      SURFACE_Y + DST_H as usize - 1,
    ),
    "colored pixels must be exactly the scaled dst rectangle"
  );
  assert_eq!(
    colored,
    (DST_W * DST_H) as usize,
    "scaled crop should fill dst exactly"
  );
  assert_eq!(
    count(red),
    0,
    "source crop must exclude the surrounding red - wp_viewport set_source ignored?"
  );
  for dy in 2..DST_H as usize - 2 {
    for dx in 2..DST_W as usize - 2 {
      assert_eq!(
        pixel(SURFACE_X + dx, SURFACE_Y + dy),
        green,
        "interior must be solid green"
      );
    }
  }

  // The input mask (what Qt uses for pointer events) must be centered on the
  // transformed destination rect, proving clipping uses view.dst.
  assert!(
    masked(
      outer.mask(),
      (SURFACE_X + 60) as u32,
      (SURFACE_Y + 60) as u32
    ),
    "mask should cover a point inside the scaled surface"
  );
  assert!(
    !masked(outer.mask(), 20, VIEWPORT_H / 2),
    "mask should not cover an unrelated background point"
  );

  // Send a complete press+release at the transformed click point, then confirm
  // the client received it with surface-local coordinates honoring view.dst.
  assert!(
    click(&mut outer, &start, CLICK_X as i32, CLICK_Y as i32, &state),
    "click inside the scaled surface must reach the client"
  );
  assert_eq!(
    *state.entered.lock().unwrap(),
    Some((LOCAL_X, LOCAL_Y)),
    "pointer enter must report surface-local coords from the destination rect"
  );

  // Press+release far outside the window must not reach the client.
  assert_no_click(&mut outer, &start, 20, VIEWPORT_H as i32 / 2, &state);

  state.stop.store(true, Ordering::SeqCst);
  join_bounded(&mut outer, client);
}
