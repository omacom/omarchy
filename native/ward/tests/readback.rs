#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;

use omarchy_ward::{graphics::OutputSpec, presentation::Viewport};
use std::{
  collections::BTreeSet,
  fs,
  time::{Duration, Instant},
};

// Measure allocations, not RSS: mapped GPU readback buffers can exhaust RAM
// while the test process's ordinary resident-set accounting stays small.
fn gpu_bytes() -> u64 {
  let mut clients = BTreeSet::new();
  let mut total = 0;
  let mut measured = false;
  for entry in fs::read_dir("/proc/self/fdinfo").unwrap() {
    let Ok(info) = fs::read_to_string(entry.unwrap().path()) else {
      continue; // the read_dir descriptor may have closed
    };
    let field = |key| {
      info
        .lines()
        .find_map(|line| line.strip_prefix(key))
        .map(str::trim)
    };
    let Some(client) = field("drm-client-id:") else {
      continue;
    };
    let device = field("drm-pdev:").unwrap_or("");
    if !clients.insert((device.to_owned(), client.to_owned())) {
      continue;
    }
    for line in info.lines() {
      let Some((key, value)) = line.split_once(':') else {
        continue;
      };
      // drm-total-cycles-* are counters, not memory. Modern DRM accounting
      // reports memory regions as drm-total-<region>, in KiB (or bare zero).
      if key.starts_with("drm-total-") && !key.starts_with("drm-total-cycles-") {
        let words: Vec<_> = value.split_whitespace().collect();
        match words.as_slice() {
          [number, "KiB"] => total += number.parse::<u64>().unwrap() * 1024,
          ["0"] => (),
          _ => panic!("unsupported DRM memory accounting: {line}"),
        }
        measured = true;
      }
    }
  }
  assert!(
    measured,
    "GPU readback regression requires DRM memory accounting"
  );
  total
}

#[test]
fn repeated_readbacks_release_gpu_allocations() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
    return;
  }
  let started = Instant::now();
  let root = tempfile::tempdir().unwrap();
  let viewport = Viewport {
    width: 256,
    height: 256,
    scale_fixed: 120,
  };
  let mut desktop = desktop::Desktop::new(root.path(), viewport);
  let outputs = [OutputSpec {
    x: 0,
    y: 0,
    width: viewport.width,
    height: viewport.height,
    scale_fixed: 120,
  }];
  let mut baseline = 0;
  let mut peak = 0;
  // Exactly 512 small readbacks; no QML, child processes, desktop connection or
  // unbounded capture loop. Even a broken cleanup is checked every 256 KiB.
  for frame in 0..512 {
    assert!(
      started.elapsed() < Duration::from_secs(20),
      "readback deadline"
    );
    // Mark the canvas dirty without reallocating the two presentation slots.
    desktop.graphics.configure_outputs(&outputs, frame).unwrap();
    let frames = desktop.step(frame);
    assert_eq!(frames.len(), 1);
    assert_eq!(frames[0].pixels().len(), 256 * 256 * 4);
    drop(frames);
    let bytes = gpu_bytes();
    assert!(bytes <= 256 * 1024 * 1024, "GPU fixture exceeded 256 MiB");
    if frame == 31 {
      baseline = bytes;
    }
    if frame >= 32 {
      peak = peak.max(bytes);
      assert!(
        bytes <= baseline + 16 * 1024 * 1024,
        "GPU allocations grew after warmup at frame {frame}: {baseline} -> {bytes} bytes"
      );
    }
  }
  println!(
    "512 readbacks: baseline={baseline} peak={peak} GPU bytes; {:?}",
    started.elapsed()
  );
}
