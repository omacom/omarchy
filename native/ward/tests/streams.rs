//! Independent mixed-DPI presentation streams from one admitted worker.
#![cfg(feature = "graphics")]
use omarchy_ward::{
  context::UiContext,
  controller::Control,
  grants::Grants,
  presentation::{Event, Frames},
  revision::Revision,
  session::{Session, Update},
  store::Store,
  topology::{Input, Output, Targeted, Topology},
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
  collections::BTreeMap,
  fs,
  path::PathBuf,
  time::{Duration, Instant},
};

struct Stream {
  frames: Frames,
  buffers: [Option<Dmabuf>; 2],
  size: (i32, i32),
  pixels: Vec<u8>,
}
struct Probe {
  session: Session,
  renderer: GlesRenderer,
  topology: Topology,
  streams: BTreeMap<u32, Stream>,
  ready_epoch: u32,
}
impl Probe {
  fn step(&mut self) {
    for _ in 0..64 {
      let Some(update) = self.session.poll().unwrap() else {
        break;
      };
      match update {
        Update::Failed(error) => panic!("stream worker failed: {error}"),
        Update::TopologyReady(epoch) => self.ready_epoch = epoch,
        Update::Stream(event) => {
          if event.epoch < self.topology.generation {
            continue;
          }
          assert_eq!(event.epoch, self.topology.generation);
          let allocation = self
            .topology
            .output(event.output)
            .expect("unallocated stream");
          match event.event {
            Event::Configured {
              generation,
              viewport,
            } => {
              assert_eq!(
                (viewport.width, viewport.height, viewport.scale_fixed),
                (allocation.width, allocation.height, allocation.scale_fixed)
              );
              let mut frames = Frames::default();
              frames.configure(generation).unwrap();
              let size = allocation.pixels().unwrap();
              self.streams.insert(
                event.output,
                Stream {
                  frames,
                  buffers: [None, None],
                  size: (size.0 as i32, size.1 as i32),
                  pixels: vec![],
                },
              );
            }
            Event::Buffer(buffer) => {
              let stream = self.streams.get_mut(&event.output).unwrap();
              stream
                .frames
                .describe(buffer.generation, buffer.slot)
                .unwrap();
              assert_eq!((buffer.width as i32, buffer.height as i32), stream.size);
              let mut builder = Dmabuf::builder(
                stream.size,
                Fourcc::Argb8888,
                Modifier::Linear,
                DmabufFlags::empty(),
              );
              assert!(builder.add_plane(buffer.fd, 0, 0, buffer.stride));
              stream.buffers[buffer.slot as usize] = builder.build();
            }
            Event::Frame {
              generation,
              serial,
              slot,
            } => {
              let stream = self.streams.get_mut(&event.output).unwrap();
              stream.frames.frame(generation, serial, slot).unwrap();
              let texture = self
                .renderer
                .import_dmabuf(stream.buffers[slot as usize].as_ref().unwrap(), None)
                .unwrap();
              let mapping = self
                .renderer
                .copy_texture(
                  &texture,
                  smithay::utils::Rectangle::from_size(stream.size.into()),
                  Fourcc::Abgr8888,
                )
                .unwrap();
              stream.pixels = self.renderer.map_texture(&mapping).unwrap().to_vec();
              drop(mapping);
              drop(texture);
              self.renderer.cleanup_texture_cache().unwrap();
              stream.frames.presented(serial).unwrap();
              self
                .session
                .send(Control::Targeted(Targeted {
                  output: event.output,
                  epoch: event.epoch,
                  event: Input::Presented(serial),
                }))
                .unwrap();
            }
            Event::Mask { regions, .. } => assert!(
              regions
                .iter()
                .all(|region| region.x + region.width <= allocation.width
                  && region.y + region.height <= allocation.height)
            ),
          }
        }
        Update::Ready => (),
        Update::Observation(selected) => assert!(!selected),
        _ => panic!("unexpected stream metadata"),
      }
    }
  }
  fn wait(&mut self, name: &str, color: [u8; 3]) {
    let deadline = Instant::now() + Duration::from_secs(8);
    loop {
      self.step();
      if self.ready_epoch == self.topology.generation
        && self.topology.outputs.iter().all(|output| {
          self.streams.get(&output.id).is_some_and(|stream| {
            let scale = f64::from(output.scale_fixed) / 120.;
            let expected = (80. * scale).round() as usize * (40. * scale).round() as usize;
            stream
              .pixels
              .chunks_exact(4)
              .filter(|pixel| pixel[..3] == color)
              .count()
              == expected
          })
        })
      {
        return;
      }
      assert!(
        Instant::now() < deadline,
        "did not reach {name}, epoch {}, ready {}, streams {:?}",
        self.topology.generation,
        self.ready_epoch,
        self.streams.keys()
      );
      std::thread::sleep(Duration::from_millis(5));
    }
  }
  fn configure(&mut self, outputs: Vec<Output>) {
    self.topology.generation += 1;
    self.topology.outputs = outputs;
    self.streams.clear();
    self
      .session
      .send(Control::Topology(self.topology.clone()))
      .unwrap();
  }
  fn click(&self, epoch: u32, output: u32) {
    for kind in [2, 0, 1] {
      self
        .session
        .send(Control::Targeted(Targeted {
          output,
          epoch,
          event: Input::Pointer {
            kind,
            code: if kind == 2 { 0 } else { 0x110 },
            x: 50,
            y: 40,
          },
        }))
        .unwrap();
    }
  }
}

#[test]
fn mixed_dpi_output_streams_share_state_and_survive_hotplug_and_zero_outputs() {
  exercise_streams(false);
}

#[test]
fn trusted_runtime_is_host_selected_read_only_and_independent_of_omarchy() {
  exercise_streams(true);
}

fn exercise_streams(host_runtime: bool) {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  let root = tempfile::tempdir().unwrap();
  let source = root.path().join("source");
  fs::create_dir(&source).unwrap();
  let manifest = if host_runtime {
    serde_json::json!({
      "schemaVersion": 1, "id": "test.streams", "name": "Streams", "version": "1", "kinds": ["bar-widget"],
      "entryPoints": {"barWidget": "worker.qml"}, "sandbox": {"version": 1, "requests": {}}
    })
  } else {
    serde_json::json!({
      "schemaVersion": 1, "id": "test.streams", "name": "Streams", "version": "1", "kinds": ["panel"],
      "entryPoints": {"panel": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {}}
    })
  };
  fs::write(
    source.join("manifest.json"),
    serde_json::to_vec(&manifest).unwrap(),
  )
  .unwrap();
  // A bundle can ship these names as ordinary assets, but cannot select them
  // as trusted runtime code. The actual selection is outside the revision.
  fs::write(
    source.join("runtime.json"),
    r#"{"version":1,"entryPoint":"untrusted"}"#,
  )
  .unwrap();
  fs::write(source.join("untrusted"), "#!/bin/bash\nexit 99\n").unwrap();
  let runtime = host_runtime.then(|| {
    use std::os::unix::fs::PermissionsExt;
    let path = root.path().join("host-runtime");
    fs::create_dir(&path).unwrap();
    fs::write(
      path.join("runtime.json"),
      r#"{"version":1,"entryPoint":"start"}"#,
    )
    .unwrap();
    fs::write(
      path.join("start"),
      format!(
        r#"#!/bin/bash
set -eu
[[ -z ${{OMARCHY_PATH:-}} ]]
[[ ! -e '{}' ]]
[[ ! -e /runtime/shell/Commons ]]
if touch /runtime/worker-write-probe 2>/dev/null; then exit 90; fi
exec /usr/bin/quickshell --no-color -p /plugin/worker.qml
"#,
        path.display()
      ),
    )
    .unwrap();
    fs::set_permissions(path.join("start"), fs::Permissions::from_mode(0o755)).unwrap();
    path
  });
  fs::write(
    source.join("worker.qml"),
    r##"
import QtQuick
import Quickshell
import Quickshell.Wayland
ShellRoot {
  id: root
  property int presses: 0
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      Rectangle {
        x: 20; y: 24; width: 80; height: 40
        color: root.presses === 0 ? "#22ee44" : root.presses === 1 ? "#2288ee" : "#cc44dd"
        MouseArea { anchors.fill: parent; onClicked: root.presses++ }
      }
    }
  }
}
"##,
  )
  .unwrap();
  let store = Store::initialize(&root.path().join("store")).unwrap();
  let revision = Revision::import(&source, &store.revisions()).unwrap();
  store.approve(&revision.digest, Grants::default()).unwrap();
  let outputs = vec![
    Output {
      id: 1,
      x: -900,
      y: -300,
      width: 320,
      height: 200,
      scale_fixed: 150,
    },
    Output {
      id: 2,
      x: 1000,
      y: -600,
      width: 200,
      height: 320,
      scale_fixed: 180,
    },
    Output {
      id: 3,
      x: 50,
      y: 2000,
      width: 300,
      height: 200,
      scale_fixed: 240,
    },
  ];
  let topology = Topology {
    version: 1,
    generation: 1,
    outputs: outputs.clone(),
  };
  let session = Session::start_with_topology_and_runtime(
    root.path().join("store"),
    "test.streams".into(),
    PathBuf::from(env!("CARGO_BIN_EXE_omarchy-ward")),
    topology.clone(),
    UiContext::default(),
    runtime,
  )
  .unwrap();
  let device = EGLDevice::enumerate()
    .unwrap()
    .find(|device| device.render_device_path().is_ok())
    .unwrap();
  let egl = unsafe { EGLDisplay::new(device).unwrap() };
  let renderer = unsafe { GlesRenderer::new(EGLContext::new(&egl).unwrap()).unwrap() };
  let mut probe = Probe {
    session,
    renderer,
    topology,
    streams: BTreeMap::new(),
    ready_epoch: 0,
  };
  probe.wait("three independent fractional outputs", [0x22, 0xee, 0x44]);
  probe.click(1, 2);
  probe.wait(
    "one worker state changed on all outputs",
    [0x22, 0x88, 0xee],
  );
  probe.configure(vec![
    outputs[2],
    Output {
      x: -2000,
      height: 240,
      scale_fixed: 180,
      ..outputs[0]
    },
  ]);
  probe.wait("reorder, remove, resize, move, rescale", [0x22, 0x88, 0xee]);
  probe.configure(vec![]);
  probe.wait("zero output service remains alive", [0x22, 0x88, 0xee]);
  probe.configure(vec![Output {
    id: 4,
    x: -9000,
    y: 7000,
    ..outputs[0]
  }]);
  probe.wait(
    "new output retains original service state",
    [0x22, 0x88, 0xee],
  );
  probe.click(2, 1); // Retired epoch and identity must not regain input ownership.
  let deadline = Instant::now() + Duration::from_millis(150);
  while Instant::now() < deadline {
    probe.step();
    std::thread::sleep(Duration::from_millis(5));
  }
  probe.wait("stale input ignored", [0x22, 0x88, 0xee]);
  probe.click(4, 4);
  probe.wait("new epoch accepts output-local input", [0xcc, 0x44, 0xdd]);
  store.revoke("test.streams").unwrap();
}
