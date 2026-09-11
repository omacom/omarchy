use crate::{
  channel::Channel,
  controller::{Key, Scroll},
  presentation::{self, Event, Frames, Region, Viewport},
};
use smithay::{
  backend::{
    allocator::{
      Allocator, Buffer as _, Fourcc, Modifier,
      dmabuf::{AsDmabuf, Dmabuf},
      gbm::{GbmAllocator, GbmBufferFlags, GbmDevice},
    },
    egl::{EGLContext, EGLDevice, EGLDisplay},
    input::{Axis, AxisSource, ButtonState, KeyState},
    renderer::{
      Bind, Color32F, Frame, ImportDma, Renderer,
      element::{
        Kind,
        surface::{WaylandSurfaceRenderElement, render_elements_from_surface_tree},
      },
      gles::GlesRenderer,
      utils::{
        RendererSurfaceStateUserData, draw_render_elements, on_commit_buffer_handler,
        with_renderer_surface_state,
      },
    },
  },
  input::{
    Seat, SeatHandler, SeatState,
    keyboard::FilterResult,
    pointer::{AxisFrame, ButtonEvent, CursorImageStatus, MotionEvent},
  },
  output::{Mode, Output, PhysicalProperties, Scale, Subpixel},
  reexports::wayland_protocols_wlr::layer_shell::v1::server::zwlr_layer_surface_v1::ZwlrLayerSurfaceV1,
  reexports::wayland_server::{
    Client, Display, ListeningSocket, Resource, Weak,
    backend::{ClientData, ClientId, DisconnectReason, GlobalId},
    protocol::{wl_buffer::WlBuffer, wl_output::WlOutput, wl_seat::WlSeat, wl_surface::WlSurface},
  },
  utils::{Logical, Rectangle, SERIAL_COUNTER, Serial, Transform},
  wayland::{
    buffer::BufferHandler,
    compositor::{
      CompositorClientState, CompositorHandler, CompositorState, SurfaceAttributes,
      TraversalAction, add_pre_commit_hook, get_parent, send_surface_state, with_states,
      with_surface_tree_downward,
    },
    dmabuf::{DmabufFeedbackBuilder, DmabufGlobal, DmabufHandler, DmabufState, ImportNotifier},
    fractional_scale::{
      FractionalScaleHandler, FractionalScaleManagerState, with_fractional_scale,
    },
    output::{OutputHandler, OutputManagerState},
    shell::{
      wlr_layer::{
        Anchor, KeyboardInteractivity, Layer, LayerSurface, LayerSurfaceCachedState,
        WlrLayerShellHandler, WlrLayerShellState,
      },
      xdg::{
        PopupSurface, PositionerState, SurfaceCachedState, ToplevelSurface, XdgPopupSurfaceData,
        XdgShellHandler, XdgShellState,
      },
    },
    shm::{ShmHandler, ShmState},
    viewporter::ViewporterState,
  },
};
use std::{
  cell::{Cell, RefCell},
  collections::BTreeMap,
  fs::File,
  os::unix::fs::MetadataExt,
  path::{Path, PathBuf},
  sync::Arc,
};

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;
mod streams;

/// One sub-rect of the single composite canvas surfaced as its own
/// `wl_output`/`xdg-output` global (the "monitor wall" model). Coordinates
/// and size are **logical**; `scale_fixed` is the output's fractional scale in
/// units of 1/120 (`scale * 120`). The worker keeps one uniform scale across
/// every output, so a wall decomposes the canvas into side-by-side outputs.
pub struct OutputSpec {
  pub x: i32,
  pub y: i32,
  pub width: u32,
  pub height: u32,
  pub scale_fixed: u32,
}

/// The wire state backing one wall output: its logical sub-rect plus the
/// bound `wl_output` global (owned for enter/leave and global lifetime).
struct OutputFlow {
  id: u32,
  spec: OutputSpec,
  output: Output,
  global: GlobalId,
}

impl OutputFlow {
  fn logical_rect(&self) -> Rectangle<i32, Logical> {
    Rectangle::new(
      (self.spec.x, self.spec.y).into(),
      (self.spec.width as i32, self.spec.height as i32).into(),
    )
  }
}

struct LayerRole(RefCell<Weak<ZwlrLayerSurfaceV1>>);

/// Which wall output a layer surface was created against, stored in the
/// surface's data map so layer geometry is constrained to that output's
/// logical rect rather than the whole canvas.
struct LayerOutput(Cell<u32>);

/// One private compositor in the already resource-limited controller process.
/// Worker buffers are never forwarded to Qt: only completed controller output.
pub struct Graphics {
  streams: Option<streams::Streams>,
  input_output: Option<u32>,
  display: Display<App>,
  socket: ListeningSocket,
  app: App,
  buffers: [Dmabuf; 2],
  allocator: GbmAllocator<File>,
  generation: u64,
  requested: Option<Viewport>,
  clients: Vec<Client>,
  node: PathBuf,
  frames: Frames,
  serial: u64,
  last_mask: Vec<Region>,
  pointer: smithay::input::pointer::PointerHandle<App>,
  keyboard: smithay::input::keyboard::KeyboardHandle<App>,
  keysyms: BTreeMap<u32, u32>,
  // Worker layer requests cannot reactivate keyboard focus withdrawn by the host.
  keyboard_active: bool,
  pending_keyboard_focus: Option<WlSurface>,
  buttons: u8,
}

impl Graphics {
  pub fn new(path: &Path, viewport: Viewport) -> Result<Self> {
    let pixels = viewport.pixels()?;
    let (device, node) = EGLDevice::enumerate()?
      .find_map(|device| device.render_device_path().ok().map(|path| (device, path)))
      .ok_or("no EGL render device")?;
    let egl = unsafe { EGLDisplay::new(device)? };
    let renderer = unsafe { GlesRenderer::new(EGLContext::new(&egl)?)? };
    let display = Display::<App>::new()?;
    let dh = display.handle();
    let mut dmabuf = DmabufState::new();
    let feedback =
      DmabufFeedbackBuilder::new(node.metadata()?.rdev(), renderer.dmabuf_formats()).build()?;
    dmabuf.create_global_with_default_feedback::<App>(&dh, &feedback);
    let mut seats = SeatState::new();
    let mut seat = seats.new_wl_seat(&dh, "plugin");
    let keyboard = seat.add_keyboard(Default::default(), 200, 25)?;
    let pointer = seat.add_pointer();
    let output = Output::new(
      "plugin-0".into(),
      PhysicalProperties {
        size: (0, 0).into(),
        subpixel: Subpixel::Unknown,
        make: "Omarchy".into(),
        model: "Private".into(),
      },
    );
    let global = output.create_global::<App>(&dh);
    let mode = Mode {
      size: (pixels.0 as i32, pixels.1 as i32).into(),
      refresh: 60000,
    };
    output.change_current_state(
      Some(mode),
      Some(Transform::Normal),
      Some(Scale::Fractional(f64::from(viewport.scale_fixed) / 120.0)),
      Some((0, 0).into()),
    );
    output.set_preferred(mode);
    // The degenerate start of a monitor wall: one output covers the whole
    // canvas at the integer start scale (fractional is set later via
    // `configure_scaled`).
    let primary = OutputFlow {
      id: 1,
      spec: OutputSpec {
        x: 0,
        y: 0,
        width: viewport.width,
        height: viewport.height,
        scale_fixed: viewport.scale_fixed,
      },
      output,
      global,
    };
    OutputManagerState::new_with_xdg_output::<App>(&dh);
    let app = App {
      compositor: CompositorState::new_v6::<App>(&dh),
      xdg: XdgShellState::new::<App>(&dh),
      layer: WlrLayerShellState::new::<App>(&dh),
      shm: ShmState::new::<App>(&dh, vec![]),
      _viewporter: ViewporterState::new::<App>(&dh),
      _fractional_scale: FractionalScaleManagerState::new::<App>(&dh),
      dmabuf,
      seats,
      renderer,
      outputs: vec![primary],
      default_output: None,
      live_surfaces: Vec::new(),
      viewport,
      render_scale: f64::from(viewport.scale_fixed) / 120.0,
      layers: Vec::new(),
      popups: Vec::new(),
      surfaces: 0,
      failed: false,
      dirty: true,
    };
    let socket = ListeningSocket::bind_absolute(path.into())?;
    let gbm = GbmDevice::new(File::options().read(true).write(true).open(&node)?)?;
    let mut allocator = GbmAllocator::new(gbm, GbmBufferFlags::RENDERING);
    let buffers = allocate(&mut allocator, pixels)?;
    Ok(Self {
      streams: None,
      input_output: None,
      display,
      socket,
      app,
      buffers,
      allocator,
      generation: 1,
      requested: None,
      clients: Vec::new(),
      node,
      frames: Frames::default(),
      serial: 0,
      last_mask: Vec::new(),
      pointer,
      keyboard,
      keysyms: BTreeMap::new(),
      keyboard_active: false,
      pending_keyboard_focus: None,
      buttons: 0,
    })
  }

  pub fn render_node(&self) -> &Path {
    &self.node
  }

  pub fn describe(&mut self, channel: &Channel) -> Result<()> {
    if self.streams.is_some() {
      return self.describe_streams(channel);
    }
    self.frames.configure(self.generation)?;
    Event::Configured {
      generation: self.generation,
      viewport: self.app.viewport,
    }
    .send(channel)?;
    for (slot, buffer) in self.buffers.iter().enumerate() {
      if buffer.format().modifier != Modifier::Linear
        || buffer.format().code != Fourcc::Argb8888
        || buffer.num_planes() != 1
        || buffer.offsets().next() != Some(0)
      {
        return Err("unsupported compositor output buffer".into());
      }
      Event::Buffer(presentation::Buffer {
        generation: self.generation,
        slot: slot as u32,
        width: buffer.size().w as u32,
        height: buffer.size().h as u32,
        stride: buffer.strides().next().ok_or("missing stride")?,
        fd: buffer
          .handles()
          .next()
          .ok_or("missing output descriptor")?
          .try_clone_to_owned()?,
      })
      .send(channel)?;
      self.frames.describe(self.generation, slot as u32)?;
    }
    Ok(())
  }

  pub fn dispatch(&mut self) -> Result<()> {
    self
      .clients
      .retain(|client| client.get_credentials(&self.display.handle()).is_ok());
    while let Some(stream) = self.socket.accept()? {
      if self.clients.len() >= 8 {
        return Err("too many private display clients".into());
      }
      self.clients.push(
        self
          .display
          .handle()
          .insert_client(stream, Arc::new(ClientState::default()))?,
      );
    }
    self.display.dispatch_clients(&mut self.app)?;
    if self.app.failed {
      return Err("private surface limits exceeded".into());
    }
    self.app.layers.retain(LayerSurface::alive);
    self
      .app
      .popups
      .retain(|surface| surface.wl_surface().is_alive());
    self.update_keyboard_focus();
    self.display.flush_clients()?;
    Ok(())
  }

  pub fn presented(&mut self, serial: u64) -> Result<()> {
    Ok(self.frames.presented(serial)?)
  }

  fn update_keyboard_focus(&mut self) {
    if !self.keyboard_active {
      return;
    }
    let current = self.keyboard.current_focus();
    // A clicked layer can enable OnDemand only after receiving that click.
    // Retain its target across that client round trip, never across dismissal.
    let requested = self
      .pending_keyboard_focus
      .as_ref()
      .filter(|surface| surface_mapped(surface) && self.app.accepts_keyboard(surface))
      .cloned();
    let exclusive = self.app.exclusive_keyboard_focus();
    if requested.is_some()
      || exclusive.is_some()
      || self
        .pending_keyboard_focus
        .as_ref()
        .is_some_and(|surface| !surface_mapped(surface))
    {
      self.pending_keyboard_focus = None;
    }
    let next = exclusive.or(requested).or_else(|| {
      current
        .clone()
        .filter(|surface| surface_mapped(surface) && self.app.accepts_keyboard(surface))
    });
    if next != current {
      self
        .keyboard
        .set_focus(&mut self.app, next, SERIAL_COUNTER.next_serial());
    }
  }

  pub fn configure(&mut self, viewport: Viewport, time: u32) -> Result<()> {
    viewport.pixels()?;
    let scale = f64::from(viewport.scale_fixed) / 120.0;
    self.requested = Some(viewport);
    self.app.render_scale = scale;
    // The primary (full-canvas) output's spec tracks the resized canvas so
    // `sync_outputs` derives the correct wl_output mode on the next render.
    if let Some(primary) = self.app.outputs.first_mut() {
      primary.spec.x = 0;
      primary.spec.y = 0;
      primary.spec.width = viewport.width;
      primary.spec.height = viewport.height;
      primary.spec.scale_fixed = (scale * 120.0).round() as u32;
    }
    // Geometry changes cancel private grabs, pressed input, and popup focus.
    // The host must resume input only after the new canvas has been presented.
    self.input(5, 0, 0, 0, time)
  }

  /// Configure with an explicit (possibly fractional) render scale, updating
  /// the advertised `wp_fractional_scale` preference and the physical canvas
  /// size while keeping the logical canvas (input/mask space) fixed.
  ///
  /// `render_scale` is a plain floating-point scale in `[1.0, 4.0]` such as
  /// `1.5` (it is **not** a 120-based integer). The wire's
  /// `wp_fractional_scale.preferred_scale` message carries the same value in
  /// units of 1/120, which Smithay encodes for us. The actual rounded physical
  /// canvas (``round(width * render_scale) x round(height * render_scale)``)
  /// is validated against the pixel budget before any state is mutated, so an
  /// oversized fractional canvas is rejected atomically.
  ///
  /// This is the worker-side entry point for fractional scaling. It is kept
  /// separate from [`Self::configure`] so the shared `Viewport` contract stays
  /// integer until the coordinated IPC change lands; the product path calls
  /// [`Self::configure`] where `render_scale == viewport.scale`.
  pub fn configure_scaled(
    &mut self,
    viewport: Viewport,
    render_scale: f64,
    time: u32,
  ) -> Result<()> {
    if !(1.0..=4.0).contains(&render_scale) {
      return Err("render scale out of range [1.0, 4.0]".into());
    }
    // Validate the actual rounded physical dimensions before mutating state or
    // allocating, so e.g. a 2048x2048 canvas at render_scale 4.0 (an 8192x8192
    // 67M-pixel buffer) is rejected rather than silently exceeding the budget.
    let physical = (
      f64::round(f64::from(viewport.width) * render_scale) as u32,
      f64::round(f64::from(viewport.height) * render_scale) as u32,
    );
    validate_physical(physical.0, physical.1)?;
    self.configure(viewport, time)?;
    self.app.render_scale = render_scale;
    if let Some(primary) = self.app.outputs.first_mut() {
      primary.spec.scale_fixed = (render_scale * 120.0).round() as u32;
    }
    Ok(())
  }

  /// Reconcile the wall of `wl_output`/`xdg-output` globals that surface the
  /// single composite canvas as side-by-side sub-rects (the "monitor wall"
  /// model). Each [`OutputSpec`] is a **logical** sub-rect; all must share one
  /// uniform fractional scale (in wl_fixed units, `scale * 120`), since the
  /// existing render path composites the whole canvas at a single scale.
  ///
  /// Surfaces are entered on exactly the outputs whose rects intersect the
  /// surface's logical bounds and left on the rest; adding, removing, or
  /// reassigning (index-remapping) outputs re-runs that reconciliation. This
  /// is the worker-side entry point for multiple outputs; it is deliberately
  /// not wired into the shared single-canvas `Viewport` IPC until the
  /// coordinated geometry contract lands.
  pub fn configure_outputs(&mut self, specs: &[OutputSpec], time: u32) -> Result<()> {
    if specs.is_empty() || specs.len() > 8 {
      return Err("output wall must have between 1 and 8 outputs".into());
    }
    let scale = f64::from(specs[0].scale_fixed) / 120.0;
    if !(1.0..=4.0).contains(&scale) {
      return Err("output scale out of range [1.0, 4.0]".into());
    }
    // Validate the whole list before mutating any wall state: uniform scale,
    // non-degenerate rects, and (with overflow-safe arithmetic) every rect
    // lying inside the host canvas.
    for spec in specs {
      if spec.width == 0 || spec.height == 0 {
        return Err("output rect must be non-empty".into());
      }
      if f64::from(spec.scale_fixed) / 120.0 != scale {
        return Err("output wall must use a uniform fractional scale".into());
      }
      if spec.x < 0 || spec.y < 0 {
        return Err("output rect is outside the host canvas".into());
      }
      let x_end = i64::from(spec.x) + i64::from(spec.width);
      let y_end = i64::from(spec.y) + i64::from(spec.height);
      if x_end > i64::from(self.app.viewport.width) || y_end > i64::from(self.app.viewport.height) {
        return Err("output rect is outside the host canvas".into());
      }
    }
    // The spanning canvas is round(viewport x requested scale); reject a wall
    // whose physical output would exceed the pixel budget before touching
    // state. This must use the incoming scale, not the current render_scale,
    // so raising the scale (e.g. 1.0 -> 4.0 on a 2048x2048 canvas) cannot
    // validate the old, smaller physical size and slip an 8192x8192 buffer
    // through the budget gate.
    let new_physical = (
      f64::round(f64::from(self.app.viewport.width) * scale) as u32,
      f64::round(f64::from(self.app.viewport.height) * scale) as u32,
    );
    validate_physical(new_physical.0, new_physical.1)?;
    let dh = self.display.handle();
    // Grow (create new globals) or shrink (retire globals) to match specs.
    while self.app.outputs.len() < specs.len() {
      let idx = self.app.outputs.len();
      let output = Output::new(
        format!("plugin-{idx}"),
        PhysicalProperties {
          size: (0, 0).into(),
          subpixel: Subpixel::Unknown,
          make: "Omarchy".into(),
          model: "Private".into(),
        },
      );
      let global = output.create_global::<App>(&dh);
      let spec = &specs[idx];
      self.app.outputs.push(OutputFlow {
        id: idx as u32 + 1,
        spec: OutputSpec {
          x: spec.x,
          y: spec.y,
          width: spec.width,
          height: spec.height,
          scale_fixed: spec.scale_fixed,
        },
        output,
        global,
      });
    }
    while self.app.outputs.len() > specs.len() {
      let flow = self.app.outputs.pop().unwrap();
      dh.remove_global::<App>(flow.global);
    }
    self.app.render_scale = scale;
    for (flow, spec) in self.app.outputs.iter_mut().zip(specs) {
      flow.spec = OutputSpec {
        x: spec.x,
        y: spec.y,
        width: spec.width,
        height: spec.height,
        scale_fixed: spec.scale_fixed,
      };
    }
    self.app.sync_outputs();
    self.app.reconcile_all_surfaces();
    // Re-send layer configures whenever the wall topology or the owning
    // output's logical bounds changed. This must run even when the physical
    // canvas is unchanged (same-scale rect reassignment, which the realloc
    // path below skips): an already-created layer panel has to learn its new
    // width/height so it can repaint, and the client validates it via
    // zwlr_layer_surface configure.
    self.app.refresh_layers();
    // A change in the spanning physical canvas (here: the scale, since the
    // logical canvas is fixed) requires a new generation of exported buffers.
    // Preserve frame ownership by reusing the `requested` handoff, which only
    // reallocates/re-describes on the next render once the previous frame is
    // owned. Same-size reconfigurations (pure rect reassignment) skip it.
    let current = (
      self.buffers[0].size().w as u32,
      self.buffers[0].size().h as u32,
    );
    if self.app.physical() != current {
      self.requested = Some(self.app.viewport);
    }
    self.app.dirty = true;
    // Output reconfiguration is a geometry change: cancel private grabs etc.
    self.input(5, 0, 0, 0, time)
  }

  /// Number of `wl_output` globals currently in the wall.
  pub fn output_count(&self) -> usize {
    self.app.outputs.len()
  }

  /// The current logical spec (sub-rect + uniform fractional scale) backing the
  /// `index`-th wall output, if any.
  pub fn output_spec(&self, index: usize) -> Option<&OutputSpec> {
    self.app.outputs.get(index).map(|flow| &flow.spec)
  }

  /// The physical (rounded at the render scale) mode size of the `index`-th
  /// wall output, if any.
  pub fn output_mode(&self, index: usize) -> Option<(i32, i32)> {
    let flow = self.app.outputs.get(index)?;
    let size = flow.output.current_mode()?.size;
    Some((size.w, size.h))
  }

  /// The global handle of the `index`-th wall output, if any.
  pub fn output_global(&self, index: usize) -> Option<GlobalId> {
    self.app.outputs.get(index).map(|flow| flow.global.clone())
  }

  pub fn render(&mut self, channel: &Channel, time: u32) -> Result<()> {
    if self.streams.is_some() {
      return self.render_streams(channel, time);
    }
    let Some(mut slot) = self.frames.writable_slot() else {
      return Ok(());
    };
    if let Some(viewport) = self.requested.take() {
      // A pending old frame prevents entry here. Qt retains its imported old
      // buffers until it switches nodes; none are reused as new output storage.
      self.app.viewport = viewport;
      self.buffers = allocate(&mut self.allocator, self.app.physical())?;
      self.generation = self
        .generation
        .checked_add(1)
        .ok_or("viewport generation exhausted")?;
      self.app.sync_outputs();
      for (surface, _) in self.app.roots() {
        with_surface_tree_downward(
          &surface,
          (),
          |_, _, _| TraversalAction::DoChildren(()),
          |surface, states, _| {
            with_fractional_scale(states, |s| s.set_preferred_scale(self.app.render_scale));
            send_surface_state(surface, states, self.app.surface_scale(), Transform::Normal)
          },
          |_, _, _| true,
        );
      }
      for layer in &self.app.layers {
        let rect = self.app.layer_rect(layer);
        layer.with_pending_state(|state| state.size = Some(rect.size));
        layer.send_pending_configure();
      }
      self.last_mask.clear();
      self.app.dirty = true;
      self.describe(channel)?;
      slot = self
        .frames
        .writable_slot()
        .ok_or("new viewport buffers unavailable")?;
    }
    if !self.app.dirty {
      return Ok(());
    }
    let surfaces = self.app.roots();
    let scale = self.app.render_scale;
    let size = self.app.render_size();
    let elements = surfaces
      .iter()
      .flat_map(|(surface, pos)| {
        render_elements_from_surface_tree(
          &mut self.app.renderer,
          surface,
          (
            (f64::from(pos.0) * scale).round() as i32,
            (f64::from(pos.1) * scale).round() as i32,
          ),
          scale,
          1.0,
          Kind::Unspecified,
        )
      })
      .collect::<Vec<WaylandSurfaceRenderElement<GlesRenderer>>>();
    let mut target = self.app.renderer.bind(&mut self.buffers[slot as usize])?;
    let damage = Rectangle::from_size(size.into());
    let mut frame = self
      .app
      .renderer
      .render(&mut target, size.into(), Transform::Normal)?;
    frame.clear(Color32F::new(0.0, 0.0, 0.0, 0.0), &[damage])?;
    draw_render_elements(&mut frame, scale, &elements, &[damage])?;
    // This wait occurs only in the supervised per-plugin process. A stuck
    // worker fence cannot block the trusted shell's GUI/render thread.
    frame.finish()?.wait()?;
    let mask = self.app.mask(&surfaces)?;
    if mask != self.last_mask {
      Event::Mask {
        generation: self.generation,
        regions: mask.clone(),
      }
      .send(channel)?;
      self.last_mask = mask;
    }
    self.serial = self.serial.checked_add(1).ok_or("frame serial exhausted")?;
    self.frames.frame(self.generation, self.serial, slot)?;
    Event::Frame {
      generation: self.generation,
      serial: self.serial,
      slot,
    }
    .send(channel)?;
    self.app.dirty = false;
    for (surface, _) in surfaces {
      with_surface_tree_downward(
        &surface,
        (),
        |_, _, _| TraversalAction::DoChildren(()),
        |_, states, _| {
          for callback in states
            .cached_state
            .get::<SurfaceAttributes>()
            .current()
            .frame_callbacks
            .drain(..)
          {
            callback.done(time);
          }
        },
        |_, _, _| true,
      );
    }
    self.display.flush_clients()?;
    Ok(())
  }

  pub fn scroll(&mut self, scroll: Scroll, time: u32) -> Result<()> {
    scroll.validate()?;
    self.scroll_global(scroll, time)
  }

  fn scroll_global(&mut self, scroll: Scroll, time: u32) -> Result<()> {
    // Re-hit-test at the event position; scrolling does not acquire keyboard focus.
    self.input(2, 0, scroll.x, scroll.y, time)?;
    let mut frame = AxisFrame::new(time).source(if scroll.source == 0 {
      AxisSource::Wheel
    } else {
      AxisSource::Finger
    });
    for (axis, delta) in [
      (Axis::Horizontal, scroll.horizontal),
      (Axis::Vertical, scroll.vertical),
    ] {
      if scroll.source == 2 {
        frame = frame.stop(axis);
      } else if delta != 0 {
        // Wayland axis direction is opposite to QWheelEvent. Keep sub-detent
        // precision via v120, with 15 logical units per detent for old clients.
        frame = frame.value(
          axis,
          -f64::from(delta) / if scroll.source == 0 { 8.0 } else { 1.0 },
        );
        if scroll.source == 0 {
          frame = frame.v120(axis, -delta);
        }
      }
    }
    self.pointer.axis(&mut self.app, frame);
    self.pointer.frame(&mut self.app);
    Ok(())
  }

  /// Only the trusted host may arm focus for an explicitly summoned panel.
  pub fn activate(&mut self) {
    self.keyboard_active = true;
    self.update_keyboard_focus();
  }

  pub fn key(&mut self, key: Key, time: u32) -> Result<()> {
    key.validate()?;
    if key.pressed && self.keysyms.get(&key.code) != Some(&key.symbol) {
      self.keysyms.insert(key.code, key.symbol);
      // Only symbols delivered to this focused host item are projected. The
      // key range bounds this map to 760 entries; no compositor socket or full
      // host keymap enters the worker. ONE_LEVEL avoids applying Shift twice.
      let mut codes = String::from("minimum=8; maximum=767;");
      let mut symbols = String::new();
      for (code, symbol) in &self.keysyms {
        codes.push_str(&format!("<W{code}>={code};"));
        symbols.push_str(&format!(
          "key <W{code}> {{type=\"ONE_LEVEL\",[0x{symbol:x}]}};"
        ));
        let modifier = match symbol {
          0xffe1 | 0xffe2 => Some("Shift"),
          0xffe3 | 0xffe4 => Some("Control"),
          0xffe5 => Some("Lock"),
          0xffe7..=0xffea => Some("Mod1"),
          0xff7f => Some("Mod2"),
          0xffeb | 0xffec => Some("Mod4"),
          0xfe03 | 0xff7e => Some("Mod5"),
          _ => None,
        };
        if let Some(modifier) = modifier {
          symbols.push_str(&format!("modifier_map {modifier} {{<W{code}>}};"));
        }
      }
      self.keyboard.set_keymap_from_string(&mut self.app, format!(
        "xkb_keymap {{xkb_keycodes {{{codes}}}; xkb_types {{include \"complete\"}}; xkb_compatibility {{include \"complete\"}}; xkb_symbols {{{symbols}}};}};"
      ))?;
    }
    self.input(if key.pressed { 3 } else { 4 }, key.code, 0, 0, time)
  }

  pub fn input(&mut self, kind: u32, code: u32, x: i32, y: i32, time: u32) -> Result<()> {
    if kind <= 2 {
      let in_output = if self.streams.is_some() {
        self
          .app
          .outputs
          .iter()
          .any(|flow| flow.logical_rect().contains((x, y)))
      } else {
        x >= 0
          && y >= 0
          && x < self.app.viewport.width as i32
          && y < self.app.viewport.height as i32
      };
      if !in_output || (kind < 2 && !(0x110..=0x117).contains(&code)) || (kind == 2 && code != 0) {
        return Err("invalid host pointer input".into());
      }
      let point = (x as f64, y as f64).into();
      let focus = self
        .app
        .roots()
        .iter()
        .find_map(|(surface, pos)| {
          smithay::desktop::utils::under_from_surface_tree(
            surface,
            point,
            *pos,
            smithay::desktop::WindowSurfaceType::ALL,
          )
        })
        .map(|(surface, pos)| (surface, pos.to_f64()));
      self.pointer.motion(
        &mut self.app,
        focus.clone(),
        &MotionEvent {
          location: point,
          serial: SERIAL_COUNTER.next_serial(),
          time,
        },
      );
      if kind < 2 {
        if kind == 0 {
          self.buttons |= 1 << (code - 0x110);
          self.keyboard_active = true;
          self.pending_keyboard_focus = focus.as_ref().map(|(surface, _)| surface.clone());
        } else {
          self.buttons &= !(1 << (code - 0x110));
        }
        if kind == 0 {
          let exclusive = self.app.exclusive_keyboard_focus();
          if exclusive.is_some()
            || focus
              .as_ref()
              .is_none_or(|(surface, _)| self.app.accepts_keyboard(surface))
          {
            self.keyboard.set_focus(
              &mut self.app,
              exclusive.or_else(|| focus.map(|(surface, _)| surface)),
              SERIAL_COUNTER.next_serial(),
            );
          }
        }
        self.pointer.button(
          &mut self.app,
          &ButtonEvent {
            serial: SERIAL_COUNTER.next_serial(),
            time,
            button: code,
            state: if kind == 0 {
              ButtonState::Pressed
            } else {
              ButtonState::Released
            },
          },
        );
        self.update_keyboard_focus();
      }
      self.pointer.frame(&mut self.app);
    } else if kind <= 4 && (8..=767).contains(&code) && x == 0 && y == 0 {
      self.keyboard.input::<(), _>(
        &mut self.app,
        code.into(),
        if kind == 3 {
          KeyState::Pressed
        } else {
          KeyState::Released
        },
        SERIAL_COUNTER.next_serial(),
        time,
        |_, _, _| FilterResult::Forward,
      );
    } else if kind == 6 && code == 0 && x == 0 && y == 0 {
      // Leaving the host's input region ends hover, not keyboard focus or an
      // in-progress drag. Full dismissal remains the separate kind 5 action.
      if self.buttons == 0 {
        let location = self.pointer.current_location();
        self.pointer.motion(
          &mut self.app,
          None,
          &MotionEvent {
            location,
            serial: SERIAL_COUNTER.next_serial(),
            time,
          },
        );
        self.pointer.frame(&mut self.app);
      }
    } else if kind == 5 && code == 0 && x == 0 && y == 0 {
      self.keyboard_active = false;
      self.pending_keyboard_focus = None;
      self
        .keyboard
        .set_focus(&mut self.app, None, SERIAL_COUNTER.next_serial());
      self.keyboard.unset_grab(&mut self.app);
      for key in self.keyboard.pressed_keys() {
        self.keyboard.input::<(), _>(
          &mut self.app,
          key,
          KeyState::Released,
          SERIAL_COUNTER.next_serial(),
          time,
          |_, _, _| FilterResult::Forward,
        );
      }
      self
        .pointer
        .unset_grab(&mut self.app, SERIAL_COUNTER.next_serial(), time);
      let location = self.pointer.current_location();
      self.pointer.motion(
        &mut self.app,
        None,
        &MotionEvent {
          location,
          serial: SERIAL_COUNTER.next_serial(),
          time,
        },
      );
      for button in 0..8 {
        if self.buttons & (1 << button) != 0 {
          self.pointer.button(
            &mut self.app,
            &ButtonEvent {
              serial: SERIAL_COUNTER.next_serial(),
              time,
              button: 0x110 + button,
              state: ButtonState::Released,
            },
          );
        }
      }
      self.buttons = 0;
      self.pointer.frame(&mut self.app);
      for popup in &self.app.popups {
        popup.send_popup_done();
      }
    } else {
      return Err("invalid host keyboard input".into());
    }
    Ok(())
  }
}

fn validate_physical(width: u32, height: u32) -> Result<()> {
  if width == 0
    || height == 0
    || width > 8192
    || height > 8192
    || u64::from(width) * u64::from(height) > 8_388_608
  {
    return Err("presentation dimensions exceed limits".into());
  }
  Ok(())
}

fn allocate(allocator: &mut GbmAllocator<File>, pixels: (u32, u32)) -> Result<[Dmabuf; 2]> {
  let mut buffer = || -> Result<Dmabuf> {
    Ok(
      allocator
        .create_buffer(pixels.0, pixels.1, Fourcc::Argb8888, &[Modifier::Linear])?
        .export()?,
    )
  };
  Ok([buffer()?, buffer()?])
}

struct App {
  compositor: CompositorState,
  xdg: XdgShellState,
  layer: WlrLayerShellState,
  shm: ShmState,
  // Held only to keep the wp_viewporter global registration alive; requests
  // are served by the delegate_viewporter! bindings below.
  _viewporter: ViewporterState,
  _fractional_scale: FractionalScaleManagerState,
  dmabuf: DmabufState,
  seats: SeatState<Self>,
  renderer: GlesRenderer,
  // The composite canvas is surfaced as one or more `wl_output` globals
  // (monitor wall). `outputs[0]` is the primary/degenerate full-canvas output;
  // `configure_outputs` reconciles the list over the same single buffer.
  outputs: Vec<OutputFlow>,
  default_output: Option<u32>,
  live_surfaces: Vec<Weak<WlSurface>>,
  viewport: Viewport,
  render_scale: f64,
  layers: Vec<LayerSurface>,
  popups: Vec<PopupSurface>,
  surfaces: usize,
  failed: bool,
  dirty: bool,
}
impl App {
  fn exclusive_keyboard_focus(&self) -> Option<WlSurface> {
    self.roots().into_iter().find_map(|(surface, _)| {
      self.layers.iter().find_map(|layer| {
        let state = layer_state(layer);
        (layer.wl_surface() == &surface
          && matches!(state.layer, Layer::Top | Layer::Overlay)
          && state.keyboard_interactivity == KeyboardInteractivity::Exclusive
          && surface_mapped(&surface))
        .then(|| surface.clone())
      })
    })
  }

  fn physical(&self) -> (u32, u32) {
    (
      f64::round(f64::from(self.viewport.width) * self.render_scale) as u32,
      f64::round(f64::from(self.viewport.height) * self.render_scale) as u32,
    )
  }
  fn render_size(&self) -> (i32, i32) {
    (self.physical().0 as i32, self.physical().1 as i32)
  }
  /// Integer scale advertised on the wire (`wl_surface` / `wl_output`); the
  /// fractional precision is carried separately via `wp_fractional_scale`.
  fn surface_scale(&self) -> i32 {
    (self.render_scale.floor() as i32).max(1)
  }

  fn default_rect(&self) -> Rectangle<i32, Logical> {
    self
      .outputs
      .iter()
      .find(|output| Some(output.id) == self.default_output)
      .or_else(|| self.outputs.first())
      .map(OutputFlow::logical_rect)
      .unwrap_or_else(|| {
        Rectangle::from_size((self.viewport.width as i32, self.viewport.height as i32).into())
      })
  }

  fn surface_output(&self, surface: &WlSurface) -> Option<&OutputFlow> {
    let mut root = surface.clone();
    for _ in 0..64 {
      let owner = with_states(&root, |states| {
        states
          .data_map
          .get::<LayerOutput>()
          .map(|owner| owner.0.get())
      });
      if let Some(owner) = owner {
        return self.outputs.iter().find(|flow| flow.id == owner);
      }
      let parent = get_parent(&root).or_else(|| {
        self
          .popups
          .iter()
          .find(|popup| popup.wl_surface() == &root)
          .and_then(PopupSurface::get_parent_surface)
      });
      match parent {
        Some(parent) => root = parent,
        None => break,
      }
    }
    let rect = self.surface_logical_rect(surface);
    self
      .outputs
      .iter()
      .filter(|flow| flow.logical_rect().intersection(rect).is_some())
      .max_by_key(|flow| flow.spec.scale_fixed)
      .or_else(|| self.outputs.first())
  }

  fn preferred_scale(&self, surface: &WlSurface) -> f64 {
    self
      .surface_output(surface)
      .map_or(self.render_scale, |flow| {
        f64::from(flow.spec.scale_fixed) / 120.0
      })
  }

  fn send_preferred_scale(&self, surface: &WlSurface) {
    let scale = self.preferred_scale(surface);
    with_states(surface, |states| {
      with_fractional_scale(states, |state| state.set_preferred_scale(scale));
      send_surface_state(
        surface,
        states,
        (scale.floor() as i32).max(1),
        Transform::Normal,
      );
    });
  }

  /// Reconcile every `wl_output` global's mode/scale/location to its spec's
  /// physical size (rounded from the uniform render scale) and logical origin.
  fn sync_outputs(&mut self) {
    for flow in &self.outputs {
      let scale = f64::from(flow.spec.scale_fixed) / 120.0;
      let (w, h) = (
        f64::round(f64::from(flow.spec.width) * scale) as i32,
        f64::round(f64::from(flow.spec.height) * scale) as i32,
      );
      let mode = Mode {
        size: (w, h).into(),
        refresh: 60000,
      };
      if let Some(old) = flow.output.current_mode() {
        flow.output.delete_mode(old);
      }
      flow.output.set_preferred(mode);
      // Advertise the integer scale on the wire (wl_output.scale) while keeping
      // the fractional value internally so Smithay derives the correct
      // xdg-output logical dimensions (physical / fractional) — a plain
      // Scale::Integer would report physical dimensions as logical at 1.5x.
      flow.output.change_current_state(
        Some(mode),
        Some(Transform::Normal),
        Some(Scale::Custom {
          advertised_integer: (scale.floor() as i32).max(1),
          fractional: scale,
        }),
        Some((flow.spec.x, flow.spec.y).into()),
      );
    }
  }

  /// A surface's logical bounds on the canvas, mirroring how [`Self::roots`]
  /// actually places it (following layer/popup/subsurface placement rather
  /// than centering it), so `enter`/`leave` reflect real geometry.
  fn surface_logical_rect(&self, surface: &WlSurface) -> Rectangle<i32, Logical> {
    let bbox = smithay::desktop::utils::bbox_from_surface_tree(surface, (0, 0));
    // Locate this surface (or its nearest root ancestor) in the placement list
    // and use that root's on-canvas position, offset by the surface's own
    // bounding-box origin, instead of always centering in the viewport.
    let mut node = surface.clone();
    let position = loop {
      if let Some((_, pos)) = self.roots().iter().find(|(root, _)| root == &node) {
        break Some(*pos);
      }
      match get_parent(&node) {
        Some(parent) => node = parent,
        None => break None,
      }
    };
    let Some(pos) = position else {
      // Not yet placed; fall back to centering in the logical canvas.
      let pos = (
        ((self.default_rect().size.w - bbox.size.w) / 2)
          .max(0)
          .saturating_sub(bbox.loc.x)
          .saturating_add(self.default_rect().loc.x),
        ((self.default_rect().size.h - bbox.size.h) / 2)
          .max(0)
          .saturating_sub(bbox.loc.y)
          .saturating_add(self.default_rect().loc.y),
      );
      return Rectangle::new(pos.into(), bbox.size);
    };
    let loc = (
      pos.0.saturating_add(bbox.loc.x),
      pos.1.saturating_add(bbox.loc.y),
    );
    Rectangle::new(loc.into(), bbox.size)
  }

  /// Enter this surface on every output whose rect intersects its logical
  /// bounds, and leave it on the rest.
  fn reconcile_outputs_for(&mut self, surface: &WlSurface) {
    let rect = self.surface_logical_rect(surface);
    for flow in &self.outputs {
      if rect.intersection(flow.logical_rect()).is_some() {
        flow.output.enter(surface);
      } else {
        flow.output.leave(surface);
      }
    }
    self.send_preferred_scale(surface);
  }

  /// Re-run per-output enter/leave for every live surface (after the wall is
  /// added to, removed from, or reassigned).
  fn reconcile_all_surfaces(&mut self) {
    self
      .live_surfaces
      .retain(|surface| surface.upgrade().is_ok());
    let surfaces = self
      .live_surfaces
      .iter()
      .filter_map(|surface| surface.upgrade().ok())
      .collect::<Vec<WlSurface>>();
    for surface in surfaces {
      self.reconcile_outputs_for(&surface);
    }
  }
  fn accepts_keyboard(&self, surface: &WlSurface) -> bool {
    let mut root = surface.clone();
    while let Some(parent) = get_parent(&root) {
      root = parent;
    }
    self
      .layers
      .iter()
      .find(|layer| layer.wl_surface() == &root)
      .is_none_or(|layer| layer_state(layer).keyboard_interactivity != KeyboardInteractivity::None)
  }

  fn layer_rect(&self, surface: &LayerSurface) -> Rectangle<i32, smithay::utils::Logical> {
    // Anchor the layer within the logical rect of the wall output it was
    // created against (falling back to the full canvas for a legacy client).
    let output = with_states(surface.wl_surface(), |states| {
      states
        .data_map
        .get::<LayerOutput>()
        .map(|LayerOutput(id)| id.get())
    });
    let output_rect = self
      .outputs
      .iter()
      .find(|flow| Some(flow.id) == output)
      .map(|flow| flow.logical_rect())
      .unwrap_or_else(|| {
        Rectangle::from_size((self.viewport.width as i32, self.viewport.height as i32).into())
      });
    layer_geometry(output_rect, layer_state(surface))
  }
  fn refresh_layers(&mut self) {
    // Re-derive each layer's committed size from its (possibly re-located or
    // re-sized) owner output and send a fresh configure, so a live layer panel
    // repaints its new bounds even when the wall changes at the same scale.
    // The render realloc path also calls this, but a pure output-rect change
    // never reallocates, so it must run directly from configure_outputs too.
    for layer in &self.layers {
      let rect = self.layer_rect(layer);
      layer.with_pending_state(|state| state.size = Some(rect.size));
      layer.send_pending_configure();
    }
  }
  fn roots(&self) -> Vec<(WlSurface, (i32, i32))> {
    let mut roots = Vec::new();
    // Back-to-front: private background/bottom, windows, top/overlay. A layer
    // choice never changes the trusted host window's actual desktop layer.
    for layer in [Layer::Background, Layer::Bottom] {
      self.layer_roots(&mut roots, layer);
    }
    for top in self.xdg.toplevel_surfaces() {
      let bbox = smithay::desktop::utils::bbox_from_surface_tree(top.wl_surface(), (0, 0));
      self.append_root(
        &mut roots,
        top.wl_surface(),
        (
          ((self.default_rect().size.w - bbox.size.w) / 2)
            .max(0)
            .saturating_sub(bbox.loc.x)
            .saturating_add(self.default_rect().loc.x),
          ((self.default_rect().size.h - bbox.size.h) / 2)
            .max(0)
            .saturating_sub(bbox.loc.y)
            .saturating_add(self.default_rect().loc.y),
        ),
      );
    }
    for layer in [Layer::Top, Layer::Overlay] {
      self.layer_roots(&mut roots, layer);
    }
    roots.reverse();
    roots
  }
  fn layer_roots(&self, roots: &mut Vec<(WlSurface, (i32, i32))>, level: Layer) {
    for layer in self
      .layers
      .iter()
      .filter(|layer| layer_state(layer).layer == level)
    {
      let owner = with_states(layer.wl_surface(), |states| {
        states
          .data_map
          .get::<LayerOutput>()
          .map(|owner| owner.0.get())
      });
      if owner.is_some_and(|id| !self.outputs.iter().any(|flow| flow.id == id)) {
        continue;
      }
      let rect = self.layer_rect(layer);
      self.append_root(roots, layer.wl_surface(), (rect.loc.x, rect.loc.y));
    }
  }
  fn append_root(
    &self,
    roots: &mut Vec<(WlSurface, (i32, i32))>,
    surface: &WlSurface,
    pos: (i32, i32),
  ) {
    // Single-parent popup trees are bounded by the surface limits. Also avoid
    // revisiting an object, even if malformed protocol state reaches this path.
    if roots.iter().any(|(seen, _)| seen == surface) {
      return;
    }
    let pos = (pos.0.clamp(-65536, 65536), pos.1.clamp(-65536, 65536));
    roots.push((surface.clone(), pos));
    let origin = window_origin(surface);
    for popup in &self.popups {
      if popup.get_parent_surface().as_ref() == Some(surface) {
        let location = with_states(popup.wl_surface(), |states| {
          states
            .data_map
            .get::<XdgPopupSurfaceData>()
            .unwrap()
            .lock()
            .unwrap()
            .current
            .geometry
            .loc
        });
        let offset = window_origin(popup.wl_surface());
        self.append_root(
          roots,
          popup.wl_surface(),
          (
            pos
              .0
              .saturating_add(origin.0)
              .saturating_add(location.x)
              .saturating_sub(offset.0),
            pos
              .1
              .saturating_add(origin.1)
              .saturating_add(location.y)
              .saturating_sub(offset.1),
          ),
        );
      }
    }
  }
  fn configure_popup(
    &mut self,
    popup: &PopupSurface,
    positioner: PositionerState,
    token: Option<u32>,
  ) {
    let Some(parent) = popup.get_parent_surface() else {
      return;
    };
    let Some((_, pos)) = self
      .roots()
      .into_iter()
      .find(|(surface, _)| *surface == parent)
    else {
      self.failed = true;
      return;
    };
    let origin = window_origin(&parent);
    let output = self
      .surface_output(&parent)
      .map(OutputFlow::logical_rect)
      .unwrap_or_else(|| self.default_rect());
    let target = Rectangle::new(
      (
        output.loc.x - pos.0 - origin.0,
        output.loc.y - pos.1 - origin.1,
      )
        .into(),
      output.size,
    );
    let Some(geometry) = popup_geometry(positioner, target) else {
      self.failed = true;
      return;
    };
    popup.with_pending_state(|state| {
      state.geometry = geometry;
      state.positioner = positioner;
    });
    if let Some(token) = token {
      popup.send_repositioned(token);
    } else if popup.send_configure().is_err() {
      self.failed = true;
    }
  }
  fn mask(&self, roots: &[(WlSurface, (i32, i32))]) -> Result<Vec<Region>> {
    self.mask_in(roots, self.viewport.width, self.viewport.height)
  }

  fn mask_in(
    &self,
    roots: &[(WlSurface, (i32, i32))],
    width: u32,
    height: u32,
  ) -> Result<Vec<Region>> {
    let mut result = Ok(Vec::new());
    let viewport = Rectangle::from_size((width as i32, height as i32).into());
    for (surface, pos) in roots {
      // Match Smithay's hit testing: each mapped subsurface has its own local
      // input region, clipped to its own view, not the whole tree's bounding box.
      with_surface_tree_downward(
        surface,
        smithay::utils::Point::from(*pos),
        |_, states, parent: &smithay::utils::Point<i32, smithay::utils::Logical>| {
          let Ok(rows) = &mut result else {
            return TraversalAction::SkipChildren;
          };
          let view = states
            .data_map
            .get::<RendererSurfaceStateUserData>()
            .and_then(|data| data.lock().unwrap().view());
          let Some(view) = view else {
            return TraversalAction::SkipChildren;
          };
          let location = (
            parent.x.saturating_add(view.offset.x),
            parent.y.saturating_add(view.offset.y),
          )
            .into();
          let mut attributes = states.cached_state.get::<SurfaceAttributes>();
          let attributes = attributes.current();
          if let Err(error) = append_mask(
            rows,
            viewport,
            Rectangle::new(location, view.dst),
            attributes.input_region.as_ref(),
          ) {
            result = Err(error);
            TraversalAction::SkipChildren
          } else {
            TraversalAction::DoChildren(location)
          }
        },
        |_, _, _| {},
        |_, _, _| true,
      );
    }
    result
  }
}

fn layer_state(surface: &LayerSurface) -> LayerSurfaceCachedState {
  with_states(surface.wl_surface(), |states| {
    *states
      .cached_state
      .get::<LayerSurfaceCachedState>()
      .current()
  })
}

fn surface_mapped(surface: &WlSurface) -> bool {
  surface.is_alive()
    && with_renderer_surface_state(surface, |state| state.buffer().is_some()).unwrap_or(false)
}

fn window_origin(surface: &WlSurface) -> (i32, i32) {
  with_states(surface, |states| {
    states
      .cached_state
      .get::<SurfaceCachedState>()
      .current()
      .geometry
      .map(|rect| (rect.loc.x.clamp(-8192, 8192), rect.loc.y.clamp(-8192, 8192)))
      .unwrap_or((0, 0))
  })
}

fn layer_geometry(
  output: Rectangle<i32, smithay::utils::Logical>,
  state: LayerSurfaceCachedState,
) -> Rectangle<i32, smithay::utils::Logical> {
  fn axis(
    length: i32,
    requested: i32,
    start: bool,
    end: bool,
    before: i32,
    after: i32,
  ) -> (i32, i32) {
    let length = i64::from(length);
    let before = if start {
      i64::from(before).clamp(-length, length)
    } else {
      0
    };
    let after = if end {
      i64::from(after).clamp(-length, length)
    } else {
      0
    };
    let available = (length - before - after).clamp(1, length);
    let size = if requested == 0 {
      available
    } else {
      i64::from(requested).clamp(1, available)
    };
    let position = match (start, end) {
      (true, false) => before,
      (false, true) => length - after - size,
      _ => (length + before - after - size) / 2,
    }
    .clamp(-length, length);
    (position as i32, size as i32)
  }
  let (rel_x, width) = axis(
    output.size.w,
    state.size.w,
    state.anchor.contains(Anchor::LEFT),
    state.anchor.contains(Anchor::RIGHT),
    state.margin.left,
    state.margin.right,
  );
  let (rel_y, height) = axis(
    output.size.h,
    state.size.h,
    state.anchor.contains(Anchor::TOP),
    state.anchor.contains(Anchor::BOTTOM),
    state.margin.top,
    state.margin.bottom,
  );
  Rectangle::new(
    (
      output.loc.x.saturating_add(rel_x),
      output.loc.y.saturating_add(rel_y),
    )
      .into(),
    (width, height).into(),
  )
}

fn popup_geometry(
  positioner: PositionerState,
  target: Rectangle<i32, smithay::utils::Logical>,
) -> Option<Rectangle<i32, smithay::utils::Logical>> {
  // Bound arithmetic before calling the stock positioner implementation. Buffer
  // admission independently enforces physical dimensions and the pixel budget.
  if [
    positioner.rect_size.w,
    positioner.rect_size.h,
    positioner.anchor_rect.size.w,
    positioner.anchor_rect.size.h,
  ]
  .iter()
  .any(|value| !(1..=4096).contains(value))
    || [
      positioner.anchor_rect.loc.x,
      positioner.anchor_rect.loc.y,
      positioner.offset.x,
      positioner.offset.y,
    ]
    .iter()
    .any(|value| !(-8192..=8192).contains(value))
  {
    return None;
  }
  Some(positioner.get_unconstrained_geometry(target))
}

fn append_mask(
  result: &mut Vec<Region>,
  viewport: Rectangle<i32, smithay::utils::Logical>,
  view: Rectangle<i32, smithay::utils::Logical>,
  input: Option<&smithay::wayland::compositor::RegionAttributes>,
) -> Result<()> {
  let Some(clip) = view.intersection(viewport) else {
    return Ok(());
  };
  let mut add = |operation, rect: Rectangle<i32, smithay::utils::Logical>| -> Result<()> {
    if let Some(rect) = rect.intersection(clip) {
      if result.len() == presentation::MAX_REGIONS {
        return Err("too many input regions".into());
      }
      result.push(Region {
        operation,
        x: rect.loc.x as u32,
        y: rect.loc.y as u32,
        width: rect.size.w as u32,
        height: rect.size.h as u32,
      });
    }
    Ok(())
  };
  add(0, clip)?;
  if let Some(input) = input {
    if input.rects.len() > presentation::MAX_REGIONS {
      return Err("too many surface input regions".into());
    }
    for (kind, rect) in &input.rects {
      let mut rect = *rect;
      rect.loc.x = rect.loc.x.saturating_add(view.loc.x);
      rect.loc.y = rect.loc.y.saturating_add(view.loc.y);
      add(
        if matches!(kind, smithay::wayland::compositor::RectangleKind::Add) {
          1
        } else {
          2
        },
        rect,
      )?;
    }
  } else {
    add(1, clip)?;
  }
  Ok(())
}

#[cfg(test)]
mod tests {
  use super::*;
  use smithay::wayland::compositor::{RectangleKind, RegionAttributes};

  #[test]
  fn private_layer_geometry_respects_anchors_and_bounds_extreme_margins() {
    use smithay::wayland::shell::wlr_layer::Margins;
    let viewport = Viewport {
      width: 400,
      height: 300,
      scale_fixed: 120,
    };
    let full_canvas = Rectangle::from_size((viewport.width as i32, viewport.height as i32).into());
    let mut state = LayerSurfaceCachedState {
      anchor: Anchor::TOP | Anchor::LEFT | Anchor::RIGHT,
      size: (0, 36).into(),
      margin: Margins {
        top: 8,
        left: 16,
        right: 24,
        bottom: 0,
      },
      ..Default::default()
    };
    assert_eq!(
      layer_geometry(full_canvas, state),
      Rectangle::new((16, 8).into(), (360, 36).into())
    );
    state.size.w = 100;
    assert_eq!(layer_geometry(full_canvas, state).loc.x, 146);
    state.anchor = Anchor::RIGHT | Anchor::BOTTOM;
    state.size = (80, 40).into();
    state.margin.right = 20;
    state.margin.bottom = 30;
    assert_eq!(
      layer_geometry(full_canvas, state),
      Rectangle::new((300, 230).into(), (80, 40).into())
    );
    state.anchor = Anchor::empty();
    assert_eq!(layer_geometry(full_canvas, state).loc, (160, 130).into());
    state.anchor = Anchor::LEFT;
    state.margin.left = -10;
    assert_eq!(layer_geometry(full_canvas, state).loc.x, -10);
    // A wall output anchored into the right-hand half of the canvas offsets the
    // layer and constrains its extent to that output's rect.
    let right_output = Rectangle::new((200, 0).into(), (200, 300).into());
    state.anchor = Anchor::TOP | Anchor::LEFT | Anchor::RIGHT;
    state.size = (0, 36).into();
    state.margin = Margins {
      top: 8,
      left: 16,
      right: 24,
      bottom: 0,
    };
    assert_eq!(
      layer_geometry(right_output, state),
      Rectangle::new((216, 8).into(), (160, 36).into())
    );
    for length in [1, 4096] {
      for value in [i32::MIN, -1, 0, 1, i32::MAX] {
        state.anchor = Anchor::all();
        state.margin = Margins {
          top: value,
          bottom: value,
          left: value,
          right: value,
        };
        state.size.w = value;
        state.size.h = value;
        let rect = layer_geometry(Rectangle::from_size((length, length).into()), state);
        assert!((1..=length).contains(&rect.size.w));
        assert!((1..=length).contains(&rect.size.h));
        assert!((-i64::from(length)..=i64::from(length)).contains(&i64::from(rect.loc.x)));
        assert!((-i64::from(length)..=i64::from(length)).contains(&i64::from(rect.loc.y)));
      }
    }
  }

  #[test]
  fn private_popup_constraints_use_parent_coordinates_and_bounded_inputs() {
    use smithay::reexports::wayland_protocols::xdg::shell::server::xdg_positioner::{
      Anchor as PopupAnchor, ConstraintAdjustment, Gravity,
    };
    let mut positioner = PositionerState {
      rect_size: (120, 80).into(),
      anchor_rect: Rectangle::new((390, 290).into(), (10, 10).into()),
      anchor_edges: PopupAnchor::BottomRight,
      gravity: Gravity::BottomRight,
      constraint_adjustment: ConstraintAdjustment::SlideX | ConstraintAdjustment::SlideY,
      ..Default::default()
    };
    let target = Rectangle::from_size((400, 300).into());
    assert_eq!(
      popup_geometry(positioner, target).unwrap().loc,
      (280, 220).into()
    );
    assert_eq!(
      popup_geometry(positioner, Rectangle::new((-100, -50).into(), target.size))
        .unwrap()
        .loc,
      (180, 170).into()
    );
    positioner.constraint_adjustment = ConstraintAdjustment::empty();
    assert_eq!(
      popup_geometry(positioner, target).unwrap().loc,
      (400, 300).into()
    );
    positioner.offset.x = i32::MAX;
    assert!(popup_geometry(positioner, target).is_none());
    positioner.offset.x = 0;
    positioner.rect_size.w = 0;
    assert!(popup_geometry(positioner, target).is_none());
  }

  #[test]
  fn resize_waits_for_old_frame_and_cancels_pressed_input() {
    if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
      return;
    }
    let root = tempfile::tempdir().unwrap();
    let initial = Viewport {
      width: 64,
      height: 48,
      scale_fixed: 120,
    };
    let mut graphics = Graphics::new(&root.path().join("display"), initial).unwrap();
    let (producer, consumer) = Channel::pair().unwrap();
    graphics.describe(&producer).unwrap();
    graphics.render(&producer, 0).unwrap();
    graphics.input(3, 50, 0, 0, 1).unwrap();
    graphics.input(0, 0x110, 10, 10, 1).unwrap();
    assert!(!graphics.keyboard.pressed_keys().is_empty());
    assert_ne!(graphics.buttons, 0);
    graphics.input(6, 0, 0, 0, 2).unwrap();
    assert!(
      graphics.keyboard_active,
      "hover departure must not dismiss keyboard focus"
    );
    assert!(!graphics.keyboard.pressed_keys().is_empty());
    assert_ne!(
      graphics.buttons, 0,
      "hover departure must not interrupt a drag"
    );
    for (kind, code, x, y) in [(6, 1, 0, 0), (6, 0, 1, 0), (6, 0, 0, 1), (7, 0, 0, 0)] {
      assert!(graphics.input(kind, code, x, y, 2).is_err());
    }
    let next = Viewport {
      width: 80,
      height: 60,
      scale_fixed: 240,
    };
    graphics.configure(next, 2).unwrap();
    assert!(graphics.keyboard.pressed_keys().is_empty());
    assert_eq!(graphics.buttons, 0);
    graphics.render(&producer, 2).unwrap();
    assert_eq!(graphics.generation, 1, "resize overtook a pending frame");
    assert_eq!(graphics.app.viewport, initial);
    graphics.presented(1).unwrap();
    graphics.render(&producer, 3).unwrap();
    assert_eq!(graphics.generation, 2);
    assert_eq!(graphics.app.viewport, next);
    assert_eq!(graphics.buffers[0].size(), (160, 120).into());
    assert_eq!(graphics.app.outputs[0].output.modes().len(), 1);
    while let Ok(packet) = consumer.receive() {
      Event::decode(packet).unwrap();
    }
    graphics.presented(2).unwrap();
    graphics.configure(initial, 4).unwrap();
    graphics.render(&producer, 4).unwrap();
    assert_eq!(graphics.generation, 3);
    assert_eq!(graphics.buffers[0].size(), (64, 48).into());
    assert_eq!(graphics.app.outputs[0].output.modes().len(), 1);
  }

  #[test]
  fn independent_surface_regions_preserve_holes_and_clip_to_each_view() {
    let viewport = Rectangle::from_size((64, 64).into());
    let parent = Rectangle::new((10, 10).into(), (40, 40).into());
    let child = Rectangle::new((20, 20).into(), (8, 8).into());
    let input = RegionAttributes {
      rects: vec![
        (
          RectangleKind::Add,
          Rectangle::new((-10, -10).into(), (80, 80).into()),
        ),
        (
          RectangleKind::Subtract,
          Rectangle::new((5, 5).into(), (30, 30).into()),
        ),
      ],
    };
    let mut mask = Vec::new();
    append_mask(&mut mask, viewport, parent, Some(&input)).unwrap();
    append_mask(&mut mask, viewport, child, None).unwrap();
    for y in 0..64 {
      for x in 0..64 {
        let point = smithay::utils::Point::from((x, y));
        let expected =
          (parent.contains(point) && input.contains(point - parent.loc)) || child.contains(point);
        let (mut result, mut current, mut clipped) = (false, false, false);
        for region in &mask {
          let inside = Rectangle::new(
            (region.x as i32, region.y as i32).into(),
            (region.width as i32, region.height as i32).into(),
          )
          .contains(point);
          match region.operation {
            0 => {
              result |= current && clipped;
              current = false;
              clipped = inside;
            }
            1 if inside => current = true,
            2 if inside => current = false,
            _ => (),
          }
        }
        assert_eq!(
          result || (current && clipped),
          expected,
          "mask mismatch at {x},{y}"
        );
      }
    }
    let too_many = RegionAttributes {
      rects: vec![(RectangleKind::Add, viewport); presentation::MAX_REGIONS + 1],
    };
    assert!(append_mask(&mut Vec::new(), viewport, parent, Some(&too_many)).is_err());
  }

  #[test]
  fn configure_outputs_validates_the_requested_scales_physical_budget() {
    if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
      return;
    }
    let root = tempfile::tempdir().unwrap();
    let viewport = Viewport {
      width: 2048,
      height: 2048,
      scale_fixed: 120,
    };
    let mut graphics = Graphics::new(&root.path().join("display"), viewport).unwrap();
    // Scale 1.0 leaves the canvas at 2048x2048 (within budget). Raising the
    // wall to 4.0 would allocate a round(2048*4) x round(2048*4) = 8192x8192
    // buffer, which exceeds both the 8192 edge limit and the 8,388,608 pixel
    // budget. The validation must use the incoming scale's physical size, not
    // the wall's current (still 1.0) render_scale, and reject atomically.
    let bad = [OutputSpec {
      x: 0,
      y: 0,
      width: 2048,
      height: 2048,
      scale_fixed: 480, // 4.0
    }];
    assert!(
      graphics.configure_outputs(&bad, 0).is_err(),
      "wall scale 4.0 must reject the new 8192x8192 canvas, not validate the old 2048x2048 size"
    );
    assert_eq!(
      graphics.output_mode(0),
      Some((2048, 2048)),
      "a rejected output update must preserve the existing mode"
    );
    // The same logical rect at its original scale stays legal so the wall can
    // still be reconfigured outward after a rejected scale bump.
    let ok = [OutputSpec {
      x: 0,
      y: 0,
      width: 2048,
      height: 2048,
      scale_fixed: 120, // 1.0
    }];
    graphics.configure_outputs(&ok, 0).unwrap();
  }
}
impl BufferHandler for App {
  fn buffer_destroyed(&mut self, _: &WlBuffer) {}
}
impl ShmHandler for App {
  fn shm_state(&self) -> &ShmState {
    &self.shm
  }
}
impl OutputHandler for App {}
impl FractionalScaleHandler for App {
  fn new_fractional_scale(&mut self, surface: WlSurface) {
    // Tell the surface the current preferred scale as soon as it binds the
    // fractional-scale protocol, so a fractional-aware client (Quickshell)
    // renders at the precise resolution without waiting for a commit.
    self.send_preferred_scale(&surface);
  }
}
impl CompositorHandler for App {
  fn compositor_state(&mut self) -> &mut CompositorState {
    &mut self.compositor
  }
  fn client_compositor_state<'a>(&self, client: &'a Client) -> &'a CompositorClientState {
    &client
      .get_data::<ClientState>()
      .expect("controller-created private client")
      .0
  }
  fn new_surface(&mut self, surface: &WlSurface) {
    // Smithay 0.7 keeps its size-validation hook after role destruction:
    // https://github.com/Smithay/smithay/pull/2071. Register before that hook
    // and give ONLY a destroyed role inert dimensions. The wl_surface may
    // legally commit a null buffer after destroying its layer role (Qt does).
    // A replacement role resets these dimensions below, before client requests;
    // validation of every live role remains unchanged. Remove with upstream fix.
    add_pre_commit_hook::<Self, _>(surface, |_, _, surface| {
      with_states(surface, |states| {
        if states
          .data_map
          .get::<LayerRole>()
          .is_some_and(|role| role.0.borrow().upgrade().is_err())
        {
          states
            .cached_state
            .get::<LayerSurfaceCachedState>()
            .pending()
            .size = (1, 1).into();
        }
      });
    });
    self.surfaces += 1;
    // Up to 32 bar placements plus bounded panel, tooltip and roaming views.
    if self.surfaces > 128 {
      self.failed = true;
    }
    self.live_surfaces.push(surface.downgrade());
    self.send_preferred_scale(surface);
  }
  fn destroyed(&mut self, surface: &WlSurface) {
    self.surfaces = self.surfaces.saturating_sub(1);
    self
      .live_surfaces
      .retain(|live| live.upgrade().ok().as_ref() != Some(surface));
    self.dirty = true;
  }
  fn commit(&mut self, surface: &WlSurface) {
    self.send_preferred_scale(surface);
    on_commit_buffer_handler::<Self>(surface);
    self.reconcile_outputs_for(surface);
    self.dirty = true;
    let too_large = with_renderer_surface_state(surface, |state| {
      state
        .buffer()
        .and_then(|buffer| smithay::backend::renderer::buffer_dimensions(buffer))
        .is_some_and(|size| {
          size.w <= 0
            || size.h <= 0
            || size.w > 8192
            || size.h > 8192
            || i64::from(size.w) * i64::from(size.h) > 8_388_608
        })
    })
    .unwrap_or(false);
    if too_large {
      self.failed = true;
    }
    for layer in &self.layers {
      if layer.wl_surface() == surface {
        let rect = self.layer_rect(layer);
        layer.with_pending_state(|state| state.size = Some(rect.size));
        layer.send_pending_configure();
      }
    }
  }
}
impl SeatHandler for App {
  type KeyboardFocus = WlSurface;
  type PointerFocus = WlSurface;
  type TouchFocus = WlSurface;
  fn seat_state(&mut self) -> &mut SeatState<Self> {
    &mut self.seats
  }
  fn focus_changed(&mut self, _: &Seat<Self>, _: Option<&WlSurface>) {}
  fn cursor_image(&mut self, _: &Seat<Self>, _: CursorImageStatus) {}
}
impl XdgShellHandler for App {
  fn xdg_shell_state(&mut self) -> &mut XdgShellState {
    &mut self.xdg
  }
  fn new_toplevel(&mut self, surface: ToplevelSurface) {
    surface.send_configure();
  }
  fn new_popup(&mut self, surface: PopupSurface, positioner: PositionerState) {
    if self.popups.len() >= 16 {
      self.failed = true;
      return;
    }
    surface.with_pending_state(|state| state.positioner = positioner);
    self.configure_popup(&surface, positioner, None);
    self.popups.push(surface);
  }
  fn grab(&mut self, _: PopupSurface, _: WlSeat, _: Serial) {}
  fn reposition_request(&mut self, surface: PopupSurface, positioner: PositionerState, token: u32) {
    self.configure_popup(&surface, positioner, Some(token));
  }
}
impl WlrLayerShellHandler for App {
  fn shell_state(&mut self) -> &mut WlrLayerShellState {
    &mut self.layer
  }
  fn new_layer_surface(
    &mut self,
    surface: LayerSurface,
    output: Option<WlOutput>,
    _: Layer,
    _: String,
  ) {
    // Keep the layer pinned to the wall output it was created against so its
    // geometry is constrained to that output's rect, not the whole canvas.
    let output_id = output
      .as_ref()
      .and_then(Output::from_resource)
      .and_then(|out| {
        self
          .outputs
          .iter()
          .find(|flow| flow.output == out)
          .map(|flow| flow.id)
      })
      .or(self.default_output)
      .or_else(|| self.outputs.first().map(|flow| flow.id))
      .unwrap_or(0);
    with_states(surface.wl_surface(), |states| {
      states
        .data_map
        .insert_if_missing(|| LayerOutput(Cell::new(output_id)));
      states
        .data_map
        .get::<LayerOutput>()
        .unwrap()
        .0
        .set(output_id);
    });
    with_states(surface.wl_surface(), |states| {
      if let Some(role) = states.data_map.get::<LayerRole>() {
        states
          .cached_state
          .get::<LayerSurfaceCachedState>()
          .pending()
          .size = (0, 0).into();
        *role.0.borrow_mut() = surface.shell_surface().downgrade();
      } else {
        states
          .data_map
          .insert_if_missing(|| LayerRole(RefCell::new(surface.shell_surface().downgrade())));
      }
    });
    if self.layers.len() >= 64 {
      self.failed = true;
      return;
    }
    self.layers.push(surface);
  }
  fn new_popup(&mut self, _: LayerSurface, popup: PopupSurface) {
    let positioner = popup.with_pending_state(|state| state.positioner);
    self.configure_popup(&popup, positioner, None);
  }
  fn layer_destroyed(&mut self, _: LayerSurface) {
    self.layers.retain(LayerSurface::alive);
    self.dirty = true;
  }
}
impl DmabufHandler for App {
  fn dmabuf_state(&mut self) -> &mut DmabufState {
    &mut self.dmabuf
  }
  fn dmabuf_imported(&mut self, _: &DmabufGlobal, buffer: Dmabuf, notifier: ImportNotifier) {
    let size = buffer.size();
    if size.w > 0
      && size.h > 0
      && size.w <= 8192
      && size.h <= 8192
      && i64::from(size.w) * i64::from(size.h) <= 8_388_608
      && self.renderer.import_dmabuf(&buffer, None).is_ok()
    {
      let _ = notifier.successful::<Self>();
    } else {
      notifier.failed();
    }
  }
}
#[derive(Default)]
struct ClientState(CompositorClientState);
impl ClientData for ClientState {
  fn initialized(&self, _: ClientId) {}
  fn disconnected(&self, _: ClientId, _: DisconnectReason) {}
}
smithay::delegate_compositor!(App);
smithay::delegate_xdg_shell!(App);
smithay::delegate_layer_shell!(App);
smithay::delegate_shm!(App);
smithay::delegate_viewporter!(App);
smithay::delegate_fractional_scale!(App);
smithay::delegate_dmabuf!(App);
smithay::delegate_seat!(App);
smithay::delegate_output!(App);
