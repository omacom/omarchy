//! Per-output presentation, sharing one private display, seat and worker.
use super::*;
use crate::{
  presentation::StreamEvent,
  topology::{self, Input, Targeted, Topology},
};

pub(super) struct Streams {
  lifetime: topology::Lifetime,
  outputs: BTreeMap<u32, Stream>,
}

struct Stream {
  allocation: topology::Output,
  buffers: [Dmabuf; 2],
  frames: Frames,
  serial: u64,
  mask: Vec<Region>,
  dirty: bool,
}

impl Graphics {
  pub fn activate_output(&mut self, output: u32, time: u32) -> Result<()> {
    if self
      .streams
      .as_ref()
      .is_none_or(|streams| !streams.outputs.contains_key(&output))
    {
      return Ok(());
    }
    if self.input_output != Some(output) {
      self.input(5, 0, 0, 0, time)?;
    }
    self.input_output = Some(output);
    self.app.default_output = Some(output);
    self.activate();
    Ok(())
  }

  pub fn new_topology(path: &Path, topology: Topology) -> Result<Self> {
    topology.validate()?;
    // Initialize compositor/renderer infrastructure without allocating an
    // extra screen-sized canvas. Only the output streams hold real storage.
    let mut display = Self::new(
      path,
      Viewport {
        width: 1,
        height: 1,
        scale_fixed: 120,
      },
    )?;
    for output in display.app.outputs.drain(..) {
      display.display.handle().remove_global::<App>(output.global);
    }
    display.streams = Some(Streams {
      lifetime: topology::Lifetime::default(),
      outputs: BTreeMap::new(),
    });
    display.configure_topology(topology, 0)?;
    Ok(display)
  }

  pub fn configure_topology(&mut self, topology: Topology, time: u32) -> Result<()> {
    let streams = self
      .streams
      .as_ref()
      .ok_or("output streams not initialized")?;
    let mut lifetime = streams.lifetime.clone();
    lifetime.admit(topology.clone())?;
    let mut outputs = BTreeMap::new();
    for allocation in &topology.outputs {
      outputs.insert(
        allocation.id,
        Stream {
          allocation: *allocation,
          buffers: allocate(&mut self.allocator, allocation.pixels()?)?,
          frames: Frames::default(),
          serial: 0,
          mask: Vec::new(),
          dirty: true,
        },
      );
    }
    // New epochs always get new storage. Old imports may still be on a Qt
    // render thread; dropping our references never reuses those allocations.
    self.input(5, 0, 0, 0, time)?;
    self.input_output = None;
    if self
      .app
      .default_output
      .is_some_and(|output| topology.output(output).is_none())
    {
      self.app.default_output = None;
    }
    let dh = self.display.handle();
    let mut previous = std::mem::take(&mut self.app.outputs);
    for allocation in &topology.outputs {
      let spec = OutputSpec {
        x: allocation.x,
        y: allocation.y,
        width: allocation.width,
        height: allocation.height,
        scale_fixed: allocation.scale_fixed,
      };
      let flow = if let Some(index) = previous.iter().position(|flow| flow.id == allocation.id) {
        let mut flow = previous.remove(index);
        flow.spec = spec;
        flow
      } else {
        let output = Output::new(
          format!("ward-{}", allocation.id),
          PhysicalProperties {
            size: (0, 0).into(),
            subpixel: Subpixel::Unknown,
            make: "Ward".into(),
            model: "Private".into(),
          },
        );
        let global = output.create_global::<App>(&dh);
        OutputFlow {
          id: allocation.id,
          spec,
          output,
          global,
        }
      };
      self.app.outputs.push(flow);
    }
    for removed in previous {
      for surface in self
        .app
        .live_surfaces
        .iter()
        .filter_map(|surface| surface.upgrade().ok())
      {
        removed.output.leave(&surface);
      }
      for layer in &self.app.layers {
        let owned = with_states(layer.wl_surface(), |states| {
          states
            .data_map
            .get::<LayerOutput>()
            .is_some_and(|owner| owner.0.get() == removed.id)
        });
        if owned {
          layer.send_close();
        }
      }
      dh.remove_global::<App>(removed.global);
    }
    self.streams = Some(Streams { lifetime, outputs });
    if let Some(output) = topology.outputs.first() {
      self.app.viewport = Viewport {
        width: output.width,
        height: output.height,
        scale_fixed: output.scale_fixed,
      };
      self.app.render_scale = f64::from(output.scale_fixed) / 120.0;
    }
    self.app.sync_outputs();
    self.app.refresh_layers();
    self.app.reconcile_all_surfaces();
    self.app.dirty = true;
    Ok(())
  }

  pub(super) fn describe_streams(&mut self, channel: &Channel) -> Result<()> {
    let streams = self
      .streams
      .as_mut()
      .ok_or("output streams not initialized")?;
    let epoch = streams.lifetime.current().unwrap().generation;
    for (output, stream) in &mut streams.outputs {
      stream.frames.configure(1)?;
      let send = |event| {
        StreamEvent {
          output: *output,
          epoch,
          event,
        }
        .send(channel)
      };
      send(Event::Configured {
        generation: 1,
        viewport: Viewport {
          width: stream.allocation.width,
          height: stream.allocation.height,
          scale_fixed: stream.allocation.scale_fixed,
        },
      })?;
      for (slot, buffer) in stream.buffers.iter().enumerate() {
        if buffer.format().modifier != Modifier::Linear
          || buffer.format().code != Fourcc::Argb8888
          || buffer.num_planes() != 1
          || buffer.offsets().next() != Some(0)
        {
          return Err("unsupported compositor output buffer".into());
        }
        send(Event::Buffer(presentation::Buffer {
          generation: 1,
          slot: slot as u32,
          width: buffer.size().w as u32,
          height: buffer.size().h as u32,
          stride: buffer.strides().next().ok_or("missing stride")?,
          fd: buffer
            .handles()
            .next()
            .ok_or("missing output descriptor")?
            .try_clone_to_owned()?,
        }))?;
        stream.frames.describe(1, slot as u32)?;
      }
    }
    crate::controller::Control::TopologyReady(epoch).send(channel)?;
    Ok(())
  }

  pub(super) fn render_streams(&mut self, channel: &Channel, time: u32) -> Result<()> {
    let surfaces = self.app.roots();
    if self.app.dirty {
      for stream in self.streams.as_mut().unwrap().outputs.values_mut() {
        stream.dirty = true;
      }
      self.app.dirty = false;
    }
    let mut rendered = false;
    let epoch = self
      .streams
      .as_ref()
      .unwrap()
      .lifetime
      .current()
      .unwrap()
      .generation;
    let ids: Vec<_> = self
      .streams
      .as_ref()
      .unwrap()
      .outputs
      .keys()
      .copied()
      .collect();
    for output in ids {
      let stream = &self.streams.as_ref().unwrap().outputs[&output];
      let Some(slot) = stream.frames.writable_slot().filter(|_| stream.dirty) else {
        continue;
      };
      let allocation = stream.allocation;
      let local: Vec<_> = surfaces
        .iter()
        .map(|(surface, pos)| {
          (
            surface.clone(),
            (pos.0 - allocation.x, pos.1 - allocation.y),
          )
        })
        .collect();
      let mask = self
        .app
        .mask_in(&local, allocation.width, allocation.height)?;
      let scale = f64::from(allocation.scale_fixed) / 120.0;
      let size = allocation.pixels()?;
      let size = (size.0 as i32, size.1 as i32);
      let elements = local
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
      let stream = self
        .streams
        .as_mut()
        .unwrap()
        .outputs
        .get_mut(&output)
        .unwrap();
      let mut target = self.app.renderer.bind(&mut stream.buffers[slot as usize])?;
      let damage = Rectangle::from_size(size.into());
      let mut frame = self
        .app
        .renderer
        .render(&mut target, size.into(), Transform::Normal)?;
      frame.clear(Color32F::new(0.0, 0.0, 0.0, 0.0), &[damage])?;
      draw_render_elements(&mut frame, scale, &elements, &[damage])?;
      // Only the supervised controller waits for worker GPU completion.
      frame.finish()?.wait()?;
      let send = |event| {
        StreamEvent {
          output,
          epoch,
          event,
        }
        .send(channel)
      };
      if mask != stream.mask {
        send(Event::Mask {
          generation: 1,
          regions: mask.clone(),
        })?;
        stream.mask = mask;
      }
      stream.serial = stream
        .serial
        .checked_add(1)
        .ok_or("frame serial exhausted")?;
      stream.frames.frame(1, stream.serial, slot)?;
      send(Event::Frame {
        generation: 1,
        serial: stream.serial,
        slot,
      })?;
      stream.dirty = false;
      rendered = true;
    }
    if rendered {
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
    }
    Ok(())
  }

  pub fn targeted(&mut self, target: Targeted, time: u32) -> Result<()> {
    target.words()?;
    let topology = self
      .streams
      .as_ref()
      .ok_or("input before topology")?
      .lifetime
      .current()
      .unwrap();
    // A GUI/render-thread acknowledgement can race output removal. Ignore an
    // older epoch; it cannot release any current buffer or regain input focus.
    if target.epoch < topology.generation {
      return Ok(());
    }
    if target.epoch != topology.generation || topology.output(target.output).is_none() {
      return Err("input targets an unallocated output".into());
    }
    match target.event {
      Input::Presented(serial) => {
        self
          .streams
          .as_mut()
          .unwrap()
          .outputs
          .get_mut(&target.output)
          .unwrap()
          .frames
          .presented(serial)?;
      }
      Input::Pointer { kind, code, x, y } => {
        if kind == 0 {
          self.app.default_output = Some(target.output);
        }
        let (x, y) = if kind <= 2 {
          topology
            .map_input(target.epoch, target.output, x, y)
            .ok_or("pointer outside allocation")?
        } else {
          (x, y)
        };
        if kind <= 2 {
          if self
            .input_output
            .is_some_and(|owner| owner != target.output)
          {
            self.input(5, 0, 0, 0, time)?;
          }
          self.input_output = Some(target.output);
        } else if self.input_output != Some(target.output) {
          return Ok(());
        }
        self.input(kind, code, x, y, time)?;
      }
      Input::Scroll(mut scroll) => {
        let (x, y) = topology
          .map_input(target.epoch, target.output, scroll.x, scroll.y)
          .ok_or("scroll outside allocation")?;
        scroll.x = x;
        scroll.y = y;
        if self
          .input_output
          .is_some_and(|owner| owner != target.output)
        {
          self.input(5, 0, 0, 0, time)?;
        }
        self.input_output = Some(target.output);
        self.scroll_global(scroll, time)?;
      }
      Input::Key(key) if self.input_output == Some(target.output) => self.key(key, time)?,
      Input::Key(_) => (),
    }
    Ok(())
  }
}
