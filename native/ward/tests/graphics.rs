#![cfg(feature = "graphics")]
use omarchy_ward::{
  channel::Listener,
  controller::Control,
  grants::Grants,
  presentation::{Event, Frames, Viewport},
  revision::Revision,
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
  io::{self, Write},
  os::unix::fs::PermissionsExt,
  path::Path,
  time::{Duration, Instant},
};

#[test]
fn admitted_quickshell_renders_and_receives_private_input() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    eprintln!(
      "set OMARCHY_TEST_GRAPHICS=1 and OMARCHY_TEST_SYSTEMD=1 for headless GPU integration"
    );
    return;
  }
  let root = tempfile::Builder::new()
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir()
    .unwrap();
  let source = root.path().join("source");
  fs::create_dir(&source).unwrap();
  fs::write(source.join("worker.qml"), r##"
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
ShellRoot {
  PanelWindow {
    anchors { top: true; left: true; right: true }
    implicitHeight: 36; color: "#20bfa5"
    Text { anchors.centerIn: parent; text: "Isolated Quickshell" }
  }
  FloatingWindow {
    implicitWidth: 480; implicitHeight: 280; color: "#304050"
    Rectangle {
      x: 24; y: 24; width: 56; height: 56; radius: 12; color: "#ffb13b"
      layer.enabled: true
      layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1; shadowVerticalOffset: 8 }
      NumberAnimation on rotation { from: 0; to: 360; duration: 1800; loops: Animation.Infinite }
    }
    TextInput { id: input; x: 24; y: 115; width: 200; height: 40; color: "white"; font.pixelSize: 20; text: "INPUT" }
    Rectangle { x: 250; y: 115; width: 32; height: 32; color: input.text.indexOf("e") >= 0 ? "#44ee22" : "#ff3300" }
    Rectangle {
      id: button; x: 24; y: 180; width: 180; height: 48; color: "#607080"
      Text { anchors.centerIn: parent; text: "Open popup"; color: "white" }
      MouseArea { anchors.fill: parent; onClicked: popup.visible = true }
    }
    PopupWindow { id: popup; visible: false; anchor.item: button; anchor.rect.y: button.height
      implicitWidth: 200; implicitHeight: 70; color: "#8a2be2"
      Text { anchors.centerIn: parent; text: "Private popup"; color: "white" }
    }
  }
}
"##).unwrap();
  fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion": 1, "id": "test.graphics", "name": "Graphics", "version": "1", "kinds": ["panel"],
    "entryPoints": {"panel": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {}}
  })).unwrap()).unwrap();
  let store = Store::initialize(&root.path().join("state")).unwrap();
  let revision = Revision::import(&source, &store.revisions()).unwrap();
  store.approve(&revision.digest, Grants::default()).unwrap();
  let socket = root.path().join("host");
  let listener = Listener::bind(&socket).unwrap();
  let (mut unit, _) = store
    .launch(
      "test.graphics",
      Path::new(env!("CARGO_BIN_EXE_omarchy-ward")),
      &socket,
    )
    .unwrap();
  let deadline = Instant::now() + Duration::from_secs(3);
  let channel = loop {
    match listener.accept() {
      Ok(channel) => break channel,
      Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
        std::thread::sleep(Duration::from_millis(10))
      }
      Err(error) => panic!("graphics controller did not connect: {error}"),
    }
  };
  unit.authenticate(&channel).unwrap();
  Control::Configure(Viewport {
    width: 800,
    height: 480,
    scale_fixed: 120,
  })
  .send(&channel)
  .unwrap();
  let device = EGLDevice::enumerate()
    .unwrap()
    .find(|device| device.render_device_path().is_ok())
    .unwrap();
  let egl = unsafe { EGLDisplay::new(device).unwrap() };
  let mut renderer = unsafe { GlesRenderer::new(EGLContext::new(&egl).unwrap()).unwrap() };
  let mut buffers: [Option<Dmabuf>; 2] = [None, None];
  let mut frames = Frames::default();
  let mut count = 0;
  let mut ping = 0;
  let start = Instant::now();
  let mut next_ping = start;
  let mut typed = false;
  let mut clicked = false;
  let mut verified = false;
  while start.elapsed() < Duration::from_secs(7) {
    if Instant::now() >= next_ping {
      ping += 1;
      Control::Ping(ping).send(&channel).unwrap();
      next_ping = Instant::now() + Duration::from_millis(500);
    }
    let packet = match channel.receive() {
      Ok(packet) => packet,
      Err(error) if error.kind() == io::ErrorKind::WouldBlock => {
        std::thread::sleep(Duration::from_millis(5));
        continue;
      }
      Err(error) => panic!("graphics controller disconnected after {count} frames: {error}"),
    };
    if packet.bytes.len() == 16 {
      assert!(matches!(
        Control::decode(packet).unwrap(),
        Control::Hello | Control::Pong(_)
      ));
      continue;
    }
    match Event::decode(packet).unwrap() {
      Event::Configured { generation, .. } => frames.configure(generation).unwrap(),
      Event::Buffer(buffer) => {
        frames.describe(buffer.generation, buffer.slot).unwrap();
        let mut builder = Dmabuf::builder(
          (buffer.width as i32, buffer.height as i32),
          Fourcc::Argb8888,
          Modifier::Linear,
          DmabufFlags::empty(),
        );
        assert!(builder.add_plane(buffer.fd, 0, 0, buffer.stride));
        buffers[buffer.slot as usize] = builder.build();
      }
      Event::Mask { .. } => (),
      Event::Frame {
        generation,
        serial,
        slot,
      } => {
        frames.frame(generation, serial, slot).unwrap();
        count += 1;
        let texture = renderer
          .import_dmabuf(buffers[slot as usize].as_ref().unwrap(), None)
          .unwrap();
        let mapping = renderer
          .copy_texture(
            &texture,
            smithay::utils::Rectangle::from_size((800, 480).into()),
            Fourcc::Abgr8888,
          )
          .unwrap();
        let bytes = renderer.map_texture(&mapping).unwrap();
        let green = bytes
          .chunks_exact(4)
          .filter(|pixel| pixel[..3] == [0x44, 0xee, 0x22])
          .count();
        let purple = bytes
          .chunks_exact(4)
          .filter(|pixel| pixel[..3] == [0x8a, 0x2b, 0xe2])
          .count();
        let ready = bytes
          .chunks_exact(4)
          .filter(|pixel| pixel[..3] == [0xff, 0x33, 0x00])
          .count() > 500;
        if green > 500 && purple > 5000 {
          if let Some(path) = std::env::var_os("OMARCHY_TEST_CAPTURE") {
            let mut file = std::io::BufWriter::new(fs::File::create(path).unwrap());
            write!(file, "P6\n800 480\n255\n").unwrap();
            for pixel in bytes.chunks_exact(4) {
              file.write_all(&pixel[..3]).unwrap();
            }
          }
          verified = true;
        }
        drop(mapping);
        drop(texture);
        renderer.cleanup_texture_cache().unwrap();
        frames.presented(serial).unwrap();
        Control::Presented(serial).send(&channel).unwrap();
        // Startup time is not readiness; wait for the actual target pixels.
        if !typed && ready {
          for kind in [0, 1] {
            Control::Input {
              kind,
              code: 0x110,
              x: 200,
              y: 230,
            }
            .send(&channel)
            .unwrap();
          }
          for kind in [3, 4] {
            Control::Input {
              kind,
              code: 26,
              x: 0,
              y: 0,
            }
            .send(&channel)
            .unwrap();
          }
          typed = true;
        }
        if !clicked && green > 500 {
          for kind in [0, 1] {
            Control::Input {
              kind,
              code: 0x110,
              x: 210,
              y: 300,
            }
            .send(&channel)
            .unwrap();
          }
          clicked = true;
        }
        if verified {
          break;
        }
      }
    }
  }
  store.revoke("test.graphics").unwrap();
  assert!(!unit.running().unwrap());
  unit.stop().unwrap();
  assert!(
    verified,
    "did not observe edited text and open popup after {count} frames"
  );
  println!("verified admitted GPU rendering, keyboard and popup after {count} frames");
}
