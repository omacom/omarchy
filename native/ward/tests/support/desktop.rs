#![allow(dead_code)] // shared fixture: each test crate uses a subset of its API
//! Shared private-display fixture for tests of the trusted Qt host. No fixture
//! connects to the desktop compositor; only its supervised workers use systemd.
use omarchy_ward::{
  channel::Channel,
  graphics::Graphics,
  presentation::{Event, Region, Viewport},
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
  ffi::OsStr,
  fs,
  io::{self, Write},
  os::unix::fs::PermissionsExt,
  path::Path,
  process::{Child, Command},
};

pub struct Host(pub Child);
impl Drop for Host {
  fn drop(&mut self) {
    let _ = self.0.kill();
    let _ = self.0.wait();
  }
}

pub fn runtime() -> tempfile::TempDir {
  let root = tempfile::Builder::new()
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir()
    .unwrap();
  fs::create_dir(root.path().join("systemd")).unwrap();
  std::os::unix::fs::symlink(
    std::path::PathBuf::from(std::env::var_os("XDG_RUNTIME_DIR").unwrap()).join("systemd/private"),
    root.path().join("systemd/private"),
  )
  .unwrap();
  root
}

pub fn command(root: &Path, qml: &Path, module: &OsStr) -> Command {
  let mut command = Command::new("/usr/bin/quickshell");
  command
    .args(["--no-color", "-n", "-p"])
    .arg(qml)
    .env_remove("DISPLAY")
    .env("XDG_RUNTIME_DIR", root)
    .env("XDG_CONFIG_HOME", root.join("config"))
    .env("XDG_CACHE_HOME", root.join("cache"))
    .env("WAYLAND_DISPLAY", "wayland")
    .env("QT_QPA_PLATFORM", "wayland")
    .env("QT_QPA_PLATFORMTHEME", "none")
    .env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
    .env("QSG_RHI_BACKEND", "opengl")
    .env("QSG_RENDER_LOOP", "threaded")
    .env("QML_IMPORT_PATH", module);
  command
}

pub struct Desktop {
  pub graphics: Graphics,
  producer: Channel,
  consumer: Channel,
  renderer: GlesRenderer,
  buffers: [Option<Dmabuf>; 2],
  pixels: (i32, i32),
  last_mask: Vec<Region>,
}

pub struct Frame {
  pixels: Vec<u8>,
  size: (i32, i32),
}
impl Frame {
  pub fn count(&self, rgb: [u8; 3]) -> usize {
    self
      .pixels
      .chunks_exact(4)
      .filter(|pixel| pixel[..3] == rgb)
      .count()
  }
  pub fn pixels(&self) -> &[u8] {
    &self.pixels
  }
  pub fn size(&self) -> (i32, i32) {
    self.size
  }
  pub fn save(&self, path: impl AsRef<Path>) {
    let mut file = io::BufWriter::new(fs::File::create(path).unwrap());
    write!(file, "P6\n{} {}\n255\n", self.size.0, self.size.1).unwrap();
    for pixel in self.pixels.chunks_exact(4) {
      file.write_all(&pixel[..3]).unwrap();
    }
  }
}

impl Desktop {
  pub fn mask(&self) -> &[Region] {
    &self.last_mask
  }

  pub fn new(root: &Path, viewport: Viewport) -> Self {
    let mut graphics = Graphics::new(&root.join("wayland"), viewport).unwrap();
    let (producer, consumer) = Channel::pair().unwrap();
    let (width, height) = viewport.pixels().unwrap();
    graphics.describe(&producer).unwrap();
    let device = EGLDevice::enumerate()
      .unwrap()
      .find(|device| device.render_device_path().is_ok())
      .unwrap();
    let egl = unsafe { EGLDisplay::new(device).unwrap() };
    let renderer = unsafe { GlesRenderer::new(EGLContext::new(&egl).unwrap()).unwrap() };
    Self {
      graphics,
      producer,
      consumer,
      renderer,
      buffers: [None, None],
      pixels: (width as i32, height as i32),
      last_mask: Vec::new(),
    }
  }

  /// Like [`Self::new`] but drives the worker at an explicit (possibly
  /// fractional) render scale, reallocating the physical canvas to
  /// `round(width*scale) x round(height*scale)` up front so the readback
  /// geometry and the advertised `wp_fractional_scale` preference are set
  /// before the client connects.
  pub fn new_scaled(root: &Path, viewport: Viewport, render_scale: f64) -> Self {
    let mut graphics = Graphics::new(&root.join("wayland"), viewport).unwrap();
    let (producer, consumer) = Channel::pair().unwrap();
    // Arm the ping-pong frame slots with the integer describe, then drive a
    // render that reallocates to the fractional canvas and re-describes it
    // internally. `render()` re-describes after a realloc, so no second
    // explicit describe is needed.
    graphics.describe(&producer).unwrap();
    graphics
      .configure_scaled(viewport, render_scale, 0)
      .unwrap();
    graphics.render(&producer, 0).unwrap();
    // Drain the setup stream: keep the final (fractional) buffer table and
    // readback size, and ack the blank realloc frame so `FrameState` is clean.
    let mut buffers = [None, None];
    let mut last_size = (0i32, 0i32);
    while let Ok(packet) = consumer.receive() {
      match Event::decode(packet).unwrap() {
        Event::Buffer(buffer) => {
          let size = (buffer.width as i32, buffer.height as i32);
          let mut builder = Dmabuf::builder(
            size,
            Fourcc::Argb8888,
            Modifier::Linear,
            DmabufFlags::empty(),
          );
          assert!(builder.add_plane(buffer.fd, 0, 0, buffer.stride));
          buffers[buffer.slot as usize] = builder.build();
          last_size = size;
        }
        Event::Frame { serial, .. } => graphics.presented(serial).unwrap(),
        _ => {}
      }
    }
    let pixels = last_size;
    let device = EGLDevice::enumerate()
      .unwrap()
      .find(|device| device.render_device_path().is_ok())
      .unwrap();
    let egl = unsafe { EGLDisplay::new(device).unwrap() };
    let renderer = unsafe { GlesRenderer::new(EGLContext::new(&egl).unwrap()).unwrap() };
    Self {
      graphics,
      producer,
      consumer,
      renderer,
      buffers,
      pixels,
      last_mask: Vec::new(),
    }
  }

  pub fn step(&mut self, time: u32) -> Vec<Frame> {
    self.graphics.dispatch().unwrap();
    self.graphics.render(&self.producer, time).unwrap();
    let mut frames = Vec::new();
    for _ in 0..8 {
      let packet = match self.consumer.receive() {
        Ok(packet) => packet,
        Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
        Err(error) => panic!("private host presentation failed: {error}"),
      };
      match Event::decode(packet).unwrap() {
        Event::Buffer(buffer) => {
          // A rescale re-describes a new generation at a different physical
          // size; track the current generation so later Frame readbacks use
          // the right dimensions. Frame ownership is preserved: the worker
          // only reallocates after the previous frame is presented.
          self.pixels = (buffer.width as i32, buffer.height as i32);
          let mut builder = Dmabuf::builder(
            self.pixels,
            Fourcc::Argb8888,
            Modifier::Linear,
            DmabufFlags::empty(),
          );
          assert!(builder.add_plane(buffer.fd, 0, 0, buffer.stride));
          self.buffers[buffer.slot as usize] = builder.build();
        }
        Event::Frame { serial, slot, .. } => {
          let texture = self
            .renderer
            .import_dmabuf(self.buffers[slot as usize].as_ref().unwrap(), None)
            .unwrap();
          let mapping = self
            .renderer
            .copy_texture(
              &texture,
              smithay::utils::Rectangle::from_size(self.pixels.into()),
              Fourcc::Abgr8888,
            )
            .unwrap();
          frames.push(Frame {
            pixels: self.renderer.map_texture(&mapping).unwrap().to_vec(),
            size: self.pixels,
          });
          // Smithay defers GPU deletion until renderer cleanup. This renderer
          // only reads back textures, so no render/finish call drains it for us.
          drop(mapping);
          drop(texture);
          self.renderer.cleanup_texture_cache().unwrap();
          self.graphics.presented(serial).unwrap();
        }
        Event::Mask { regions, .. } => self.last_mask = regions,
        _ => (),
      }
    }
    frames
  }
}
