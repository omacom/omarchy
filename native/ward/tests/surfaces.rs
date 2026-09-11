#![cfg(feature = "graphics")]
use omarchy_ward::{
  controller::Control,
  grants::Grants,
  presentation::{Event, Region, Viewport},
  revision::Revision,
  session::{Session, Update},
  store::Store,
};
use smithay::backend::{
  allocator::{
    Fourcc, Modifier,
    dmabuf::{Dmabuf, DmabufFlags},
  },
  egl::{EGLContext, EGLDevice, EGLDisplay},
  renderer::{ExportMem, ImportDma, Renderer, gles::GlesRenderer},
};
use std::{
  fs,
  io::Write,
  os::unix::fs::PermissionsExt,
  path::Path,
  time::{Duration, Instant},
};

#[test]
fn private_layers_preserve_focus_and_constrain_committed_popups() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
  {
    return;
  }
  let root = tempfile::Builder::new()
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir()
    .unwrap();
  let source = root.path().join("source");
  fs::create_dir(&source).unwrap();
  fs::write(
    source.join("worker.qml"),
    include_str!("support/surfaces.qml"),
  )
  .unwrap();
  fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion": 1, "id": "test.surfaces", "name": "Surfaces", "version": "1", "kinds": ["panel"],
    "entryPoints": {"panel": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {}}
  })).unwrap()).unwrap();
  let state = root.path().join("state");
  let store = Store::initialize(&state).unwrap();
  let revision = Revision::import(&source, &store.revisions()).unwrap();
  store.approve(&revision.digest, Grants::default()).unwrap();
  let session = Session::start(
    state,
    "test.surfaces".into(),
    env!("CARGO_BIN_EXE_omarchy-ward").into(),
    Viewport {
      width: 400,
      height: 300,
      scale_fixed: 120,
    },
  )
  .unwrap();
  let device = EGLDevice::enumerate()
    .unwrap()
    .find(|device| device.render_device_path().is_ok())
    .unwrap();
  let egl = unsafe { EGLDisplay::new(device).unwrap() };
  let mut renderer = unsafe { GlesRenderer::new(EGLContext::new(&egl).unwrap()).unwrap() };
  let mut buffers: [Option<Dmabuf>; 2] = [None, None];
  let input = |kind, code, x, y| session.send(Control::Input { kind, code, x, y }).unwrap();
  let click = |x, y| {
    input(0, 0x110, x, y);
    input(1, 0x110, x, y);
  };
  let key = |code| {
    input(3, code, 0, 0);
    input(4, code, 0, 0);
  };
  let start = Instant::now();
  let mut phase = 0;
  let mut failure = String::new();
  let mut marker_first = None;
  let mut marker_x = 0;
  let mut frame_number = 0;
  let mut mask = Vec::new();
  while start.elapsed() < Duration::from_secs(10) && phase < 8 {
    match session
      .poll()
      .unwrap_or_else(|error| Some(Update::Failed(error.to_string())))
    {
      Some(Update::Failed(error)) => {
        failure = error;
        break;
      }
      Some(Update::Presentation(Event::Buffer(buffer))) => {
        let mut builder = Dmabuf::builder(
          (buffer.width as i32, buffer.height as i32),
          Fourcc::Argb8888,
          Modifier::Linear,
          DmabufFlags::empty(),
        );
        assert!(builder.add_plane(buffer.fd, 0, 0, buffer.stride));
        buffers[buffer.slot as usize] = builder.build();
      }
      Some(Update::Presentation(Event::Mask { regions, .. })) => mask = regions,
      Some(Update::Presentation(Event::Frame { serial, slot, .. })) => {
        frame_number += 1;
        let texture = renderer
          .import_dmabuf(buffers[slot as usize].as_ref().unwrap(), None)
          .unwrap();
        let mapping = renderer
          .copy_texture(
            &texture,
            smithay::utils::Rectangle::from_size((400, 300).into()),
            Fourcc::Abgr8888,
          )
          .unwrap();
        let bytes = renderer.map_texture(&mapping).unwrap();
        let pixel = |x: usize, y: usize| &bytes[(y * 400 + x) * 4..(y * 400 + x) * 4 + 3];
        let count = |rgb: [u8; 3]| bytes.chunks_exact(4).filter(|p| p[..3] == rgb).count();
        let orange = (0..400).find(|x| pixel(*x, 35) == [0xff, 0x77, 0x44]);
        if phase == 0
          && pixel(10, 10) == [0x22, 0x33, 0x44]
          && count([0xff, 0x77, 0x44]) > 1000
          && pixel(200, 190) == [0x30, 0x40, 0x50]
        {
          assert_eq!(pixel(16, 8), [0x20, 0xbf, 0xa5]);
          assert_eq!(pixel(375, 43), [0x20, 0xbf, 0xa5]);
          for (x, y) in [(15, 8), (376, 43), (100, 44)] {
            assert_eq!(pixel(x, y), [0x22, 0x33, 0x44]);
          }
          let x = orange.unwrap();
          if marker_first.is_some_and(|first: usize| first.abs_diff(x) >= 8) {
            assert!(!masked(&mask, 10, 10));
            assert!(!masked(&mask, 399, 299));
            assert!(masked(&mask, 100, 24));
            assert!(masked(&mask, 180, 130));
            assert!(masked(&mask, x as u32 + 16, 52));
            click(180, 130);
            key(26);
            phase = 1;
          } else if marker_first.is_none() {
            marker_first = Some(x);
          }
        } else if phase == 1 && count([0xff, 0xee, 0x44]) == 400 {
          marker_x = orange.unwrap() + 16;
          click(marker_x as i32, 35);
          key(27);
          phase = 2;
        } else if phase == 2 && count([0xee, 0x55, 0x99]) > 300 && count([0xee, 0xee, 0xff]) == 400
        {
          assert_eq!(
            count([0x88, 0xff, 0xdd]),
            400,
            "keyboard-none layer stole text focus"
          );
          assert_eq!(
            pixel(marker_x, 35),
            [0x20, 0xbf, 0xa5],
            "demoted marker still above top bar"
          );
          click(marker_x as i32, 35);
          phase = 3;
        } else if phase == 3 && pixel(marker_x, 35) == [0x44, 0xee, 0x22] {
          click(358, 24);
          phase = 4;
        } else if phase == 4 && count([0x8a, 0x2b, 0xe2]) > 5000 {
          assert_eq!(pixel(399, 60), [0x8a, 0x2b, 0xe2]);
          assert_eq!(pixel(300, 60), [0x8a, 0x2b, 0xe2]);
          click(350, 70);
          phase = 5;
        } else if phase == 5
          && count([0xbb, 0x66, 0x33]) > 5000
          && pixel(0, 60) == [0xbb, 0x66, 0x33]
        {
          assert_eq!(pixel(0, 60), [0xbb, 0x66, 0x33]);
          assert_eq!(pixel(99, 60), [0xbb, 0x66, 0x33]);
          click(50, 70);
          phase = 6;
        } else if phase == 6 && count([0x22, 0xcc, 0xdd]) > 5000 {
          input(5, 0, 0, 0);
          phase = 7;
        } else if phase == 7 && count([0x22, 0xcc, 0xdd]) == 0 {
          assert!(!masked(&mask, 50, 70));
          phase = 8;
        }
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          let mut file = std::io::BufWriter::new(
            fs::File::create(Path::new(&directory).join(format!("{frame_number:04}.ppm"))).unwrap(),
          );
          write!(file, "P6\n400 300\n255\n").unwrap();
          for pixel in bytes.chunks_exact(4) {
            file.write_all(&pixel[..3]).unwrap();
          }
        }
        drop(mapping);
        drop(texture);
        renderer.cleanup_texture_cache().unwrap();
        session.send(Control::Presented(serial)).unwrap();
      }
      _ => (),
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  let cleanup = store.revoke("test.surfaces");
  assert_eq!(phase, 8, "surface test stopped in phase {phase}: {failure}");
  cleanup.unwrap();
}

// Evaluate the same per-surface union/clip/subtract mask that Qt consumes.
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
