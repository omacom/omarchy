//! Deterministic verification of worker-side multi-output over a single
//! composite canvas (the "monitor wall" model).
//!
//! A real Wayland client connects to the in-process private compositor and
//! binds every `wl_output` global. The compositor surfaces one 600x450 (at
//! render scale 1.5) canvas as overlapping outputs; the first output covers
//! the canvas so owner-output centering stays fixed while the second output
//! moves across the client's 100x100 logical toplevel. We verify together:
//!   * the wall advertises the expected number of `wl_output` globals, each
//!     with the physical size rounded from its logical sub-rect at the scale;
//!   * `wl_surface.enter` is delivered for exactly the outputs whose logical
//!     rects intersect the surface, and a later reassignment that moves the
//!     boundary out from under the surface delivers `wl_surface.leave`;
//!   * shrinking the wall removes the retired global while the surface stays
//!     entered on the surviving output;
//!   * the composite is still crisp and input is still logical regardless of
//!     which output(s) the surface lands on.
//!
//! Compositor setup, GPU readback, frame ack, and the Wayland client harness
//! are reused from `tests/support/`.

#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;
use desktop::Desktop;
#[path = "support/client.rs"]
mod client;
use client::{SharedState, Surface, click, join_bounded, run_client};

use omarchy_ward::{graphics::OutputSpec, presentation::Viewport};
use std::{
  fs,
  os::unix::fs::PermissionsExt,
  sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
  },
  thread,
  time::{Duration, Instant},
};
use wayland_backend::client::ObjectId;

// Logical canvas and render scale. Physical canvas = 600x450.
const VIEWPORT_W: u32 = 400;
const VIEWPORT_H: u32 = 300;
const RENDER_SCALE: f64 = 1.5;
const SCALE_FIXED: u32 = 180; // render_scale * 120
// Logical surface size = 100x100; fractional buffer = 150x150 (1:1 crisp).
const LOGICAL_W: i32 = 100;
const LOGICAL_H: i32 = 100;
const BUFFER_W: i32 = (LOGICAL_W as f64 * RENDER_SCALE).round() as i32; // 150
const BUFFER_H: i32 = (LOGICAL_H as f64 * RENDER_SCALE).round() as i32; // 150
// Centered logical rect of the toplevel: x in [150, 250), y in [100, 200).
const CENTER_X: i32 = (VIEWPORT_W as i32 - LOGICAL_W) / 2; // 150
const CENTER_Y: i32 = (VIEWPORT_H as i32 - LOGICAL_H) / 2; // 100
// Physical (readback) rect at 1.5x.
const PHYS_W: i32 = BUFFER_W; // 150
const PHYS_H: i32 = BUFFER_H; // 150
const PHYS_X: i32 = (CENTER_X as f64 * RENDER_SCALE).round() as i32; // 225
const PHYS_Y: i32 = (CENTER_Y as f64 * RENDER_SCALE).round() as i32; // 150
// Input is logical (independent of scale / which output the surface is on).
const CLICK_X: i32 = CENTER_X + LOGICAL_W / 2; // 200
const CLICK_Y: i32 = CENTER_Y + LOGICAL_H / 2; // 150
const LOCAL_X: f64 = 50.0;
const LOCAL_Y: f64 = 50.0;

/// The set of output object ids a surface is currently entered on, folded from
/// the ordered enter/leave event log. The returned set is not sorted (ObjectId
/// has no Ord); use [`set_is`] for equality checks.
fn entered_ids(events: &[client::OutputEvent]) -> Vec<ObjectId> {
  let mut set = Vec::new();
  for (is_enter, id) in events {
    if *is_enter {
      if !set.contains(id) {
        set.push(id.clone());
      }
    } else {
      set.retain(|x| x != id);
    }
  }
  set
}

/// Assert the entered set equals `expected` regardless of order.
fn set_is(events: &[client::OutputEvent], expected: &[ObjectId]) -> bool {
  let ids = entered_ids(events);
  ids.len() == expected.len() && expected.iter().all(|e| ids.contains(e))
}

#[test]
fn output_wall_enter_leave_reassign_remove_and_logical_input() {
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

  // The window is centered on its owner output, not the composite canvas.
  // Keep that output canvas-sized and overlap a second output at x=200 to
  // exercise enter/leave independently of owner-driven window repositioning.
  outer
    .graphics
    .configure_outputs(
      &[
        OutputSpec {
          x: 0,
          y: 0,
          width: VIEWPORT_W,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
        OutputSpec {
          x: 200,
          y: 0,
          width: 200,
          height: 300,
          scale_fixed: SCALE_FIXED,
        },
      ],
      0,
    )
    .unwrap();
  assert_eq!(
    outer.graphics.output_count(),
    2,
    "wall must advertise two wl_output globals"
  );
  for index in 0..2 {
    assert_eq!(
      outer.graphics.output_mode(index),
      Some((
        ((if index == 0 { VIEWPORT_W } else { 200 }) as f64 * RENDER_SCALE).round() as i32,
        (300.0f64 * RENDER_SCALE).round() as i32,
      )),
      "each output mode must be its logical rect rounded at the render scale"
    );
  }
  assert_ne!(
    outer.graphics.output_global(0),
    outer.graphics.output_global(1),
    "the two outputs must be distinct globals"
  );

  let stop = Arc::new(AtomicBool::new(false));
  let state = SharedState::new(stop.clone());
  let (sc, st2) = (root.path().join("wayland"), state.clone());
  let client = thread::spawn(move || {
    run_client(
      &sc,
      Surface::SolidGreen {
        dest: (LOGICAL_W, LOGICAL_H),
        buffer: (BUFFER_W, BUFFER_H),
        fractional: false,
      },
      st2,
    )
  });

  let start = Instant::now();
  // Drive until the surface is entered on both outputs and a non-black frame
  // has been captured in the same pass (the readback consumer drains on every
  // step, so the first informative frame is caught the moment it is produced).
  let mut readback: Option<(Vec<u8>, (i32, i32))> = None;
  let (a, b_id) = loop {
    let step_frames = outer.step(start.elapsed().as_millis() as u32);
    if readback.is_none()
      && let Some(frame) = step_frames
        .iter()
        .find(|frame| frame.pixels().chunks_exact(4).any(|p| p[..3] != [0, 0, 0]))
    {
      readback = Some((frame.pixels().to_vec(), frame.size()));
    }
    let entered = entered_ids(&state.outputs.lock().unwrap());
    if readback.is_some() && state.bound.lock().unwrap().len() >= 2 && entered.len() >= 2 {
      let g = state.bound.lock().unwrap();
      break (g[0].clone(), g[1].clone());
    }
    assert!(
      start.elapsed() < Duration::from_secs(15),
      "compositor setup timed out: surface not entered on both outputs or no frame"
    );
    thread::sleep(Duration::from_millis(2));
  };
  let (bytes, (width, height)) = readback.expect("no composited frame produced");
  assert_ne!(a, b_id, "the two outputs must be distinct object ids");
  assert!(
    set_is(&state.outputs.lock().unwrap(), &[a.clone(), b_id.clone()]),
    "surface straddling the seam must be entered on both outputs"
  );
  assert_eq!(
    (width, height),
    (
      (VIEWPORT_W as f64 * RENDER_SCALE).round() as i32,
      (VIEWPORT_H as f64 * RENDER_SCALE).round() as i32
    ),
    "wall still composites one crisp physical canvas"
  );
  let pixel =
    |x: usize, y: usize| &bytes[(y * width as usize + x) * 4..(y * width as usize + x) * 4 + 3];
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
    "the surface must still map 1:1 crisp across the seam"
  );
  assert_eq!(colored, (PHYS_W * PHYS_H) as usize);

  // Input stays logical and reaches the client regardless of output assignment.
  assert!(
    click(&mut outer, &start, CLICK_X, CLICK_Y, &state),
    "click must reach the client"
  );
  assert_eq!(
    *state.entered.lock().unwrap(),
    Some((LOCAL_X, LOCAL_Y)),
    "pointer enter must report logical surface-local coords"
  );

  // Reassign the seam repeatedly and require the enter/leave log to track it
  // exactly. Each transition must land within a single bounded wait or the test
  // FAILS - there is no silent burn.
  //   seam 360: surface (x in [150, 250)) is inside output 0   -> leave output 1
  //   seam 200: surface straddles both                         -> re-enter output 1
  //   seam 360: surface is inside output 0 again               -> leave output 1 again
  for (phase, (seam, expected)) in [
    (1u32, (360i32, vec![a.clone()])),
    (2u32, (200i32, vec![a.clone(), b_id.clone()])),
    (3u32, (360i32, vec![a.clone()])),
  ] {
    let baseline = state.outputs.lock().unwrap().len();
    outer
      .graphics
      .configure_outputs(
        &[
          OutputSpec {
            x: 0,
            y: 0,
            width: VIEWPORT_W,
            height: 300,
            scale_fixed: SCALE_FIXED,
          },
          OutputSpec {
            x: seam,
            y: 0,
            width: VIEWPORT_W - seam as u32,
            height: 300,
            scale_fixed: SCALE_FIXED,
          },
        ],
        phase,
      )
      .unwrap();
    let deadline = Instant::now() + Duration::from_secs(10);
    loop {
      let events = state.outputs.lock().unwrap();
      let changed = events.len() > baseline;
      let matches = set_is(&events, &expected);
      drop(events);
      if changed && matches {
        break;
      }
      assert!(
        Instant::now() < deadline,
        "seam transition to {seam} did not settle to the expected output set within the bound"
      );
      outer.step(start.elapsed().as_millis() as u32);
      thread::sleep(Duration::from_millis(2));
    }
    assert!(
      set_is(&state.outputs.lock().unwrap(), &expected),
      "after reassign to seam {seam} the surface must be entered exactly on the expected outputs"
    );
  }

  // Shrink to a single output: the retired global disappears and the surface —
  // already back on the surviving output after the last seam reassignment — stays
  // entered there (no new leave is expected).
  outer
    .graphics
    .configure_outputs(
      &[OutputSpec {
        x: 0,
        y: 0,
        width: VIEWPORT_W,
        height: VIEWPORT_H,
        scale_fixed: SCALE_FIXED,
      }],
      4,
    )
    .unwrap();
  outer.step(start.elapsed().as_millis() as u32);
  assert_eq!(
    outer.graphics.output_count(),
    1,
    "shrinking the wall must retire the extra global"
  );
  assert!(
    set_is(&state.outputs.lock().unwrap(), std::slice::from_ref(&a)),
    "surface must stay entered on the surviving output"
  );

  // Bounded teardown: stop the client and join with a bounded wait so a client
  // blocked in roundtrip() cannot deadlock teardown (fails rather than silently
  // detaching).
  state.stop.store(true, Ordering::SeqCst);
  join_bounded(&mut outer, client);
}
