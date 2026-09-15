use super::*;
use crate::{
  presentation::StreamEvent,
  topology::{Input, Lifetime, Topology},
};
use std::collections::BTreeMap;

struct Stream {
  allocation: crate::topology::Output,
  frames: Frames,
  configured: bool,
  described: u8,
  settled: bool,
}

pub(super) fn dispatch(
  channel: Channel,
  mut desired: Topology,
  mut context: UiContext,
  commands: Receiver<Control>,
  updates: &SyncSender<Update>,
) -> io::Result<()> {
  desired.validate()?;
  let mut lifetime = Lifetime::default();
  let mut streams = BTreeMap::<u32, Stream>::new();
  let mut pending = false;
  let mut ready = false;
  let mut context_changed = false;
  let mut ping = 0;
  let mut pong = 0;
  let mut next_ping = Instant::now();
  let mut deadline = Instant::now() + Duration::from_secs(3);
  let mut rate_window = Instant::now();
  let mut records = 0;
  loop {
    let now = Instant::now();
    if now >= deadline {
      return Err(io::Error::other("plugin controller lease expired"));
    }
    if now >= next_ping {
      ping += 1;
      Control::Ping(ping).send(&channel)?;
      next_ping = now + Duration::from_millis(500);
    }
    if now.duration_since(rate_window) >= Duration::from_secs(1) {
      rate_window = now;
      records = 0;
    }
    for _ in 0..32 {
      match commands.try_recv() {
        Ok(Control::Stop) | Err(TryRecvError::Disconnected) => return Ok(()),
        Ok(Control::Topology(next)) => {
          next.validate()?;
          if next.generation <= desired.generation {
            return Err(io::Error::other("stale host topology"));
          }
          desired = next;
        }
        Ok(Control::Context(next)) => {
          context = next;
          context_changed = true;
        }
        Ok(Control::Targeted(target)) => {
          target.words()?;
          let Some(topology) = lifetime.current() else {
            return Err(io::Error::other("input before session ready"));
          };
          if target.epoch < topology.generation {
            continue;
          }
          if target.epoch != topology.generation {
            return Err(io::Error::other("input for unknown topology"));
          }
          let stream = streams
            .get_mut(&target.output)
            .ok_or_else(|| io::Error::other("input for unknown output"))?;
          if let Input::Presented(serial) = target.event {
            stream.frames.presented(serial)?;
            stream.settled = true;
          } else if !stream.settled {
            continue;
          }
          Control::Targeted(target).send(&channel)?;
        }
        Ok(_) => return Err(io::Error::other("untargeted command in output session")),
        Err(TryRecvError::Empty) => break,
      }
    }
    if ready && context_changed {
      Control::Context(context.clone()).send(&channel)?;
      context_changed = false;
    }
    for _ in 0..64 {
      let packet = match channel.receive() {
        Ok(packet) => packet,
        Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
        Err(error) => return Err(error),
      };
      records += 1;
      if records > 2048 {
        return Err(io::Error::other("controller presentation rate exceeded"));
      }
      if packet.bytes.starts_with(b"OPS\x01") {
        let event = StreamEvent::decode(packet)?;
        let topology = lifetime
          .current()
          .ok_or_else(|| io::Error::other("presentation before configuration"))?;
        if event.epoch < topology.generation {
          continue;
        }
        if event.epoch != topology.generation {
          return Err(io::Error::other("unsolicited presentation epoch"));
        }
        let stream = streams
          .get_mut(&event.output)
          .ok_or_else(|| io::Error::other("unsolicited presentation output"))?;
        match &event.event {
          Event::Configured {
            generation,
            viewport,
          } => {
            if stream.configured
              || *generation != 1
              || viewport.width != stream.allocation.width
              || viewport.height != stream.allocation.height
              || viewport.scale_fixed != stream.allocation.scale_fixed
            {
              return Err(io::Error::other("unsolicited output viewport"));
            }
            stream.frames.configure(*generation)?;
            stream.configured = true;
          }
          Event::Buffer(buffer) => {
            if !stream.configured || (buffer.width, buffer.height) != stream.allocation.pixels()? {
              return Err(io::Error::other("unexpected output buffer geometry"));
            }
            stream.frames.describe(buffer.generation, buffer.slot)?;
            stream.described |= 1 << buffer.slot;
          }
          Event::Frame {
            generation,
            serial,
            slot,
          } => stream.frames.frame(*generation, *serial, *slot)?,
          Event::Mask {
            generation,
            regions,
          } => {
            if *generation != 1
              || stream.described != 3
              || regions.iter().any(|region| {
                region.x + region.width > stream.allocation.width
                  || region.y + region.height > stream.allocation.height
              })
            {
              return Err(io::Error::other("unexpected output mask"));
            }
          }
        }
        emit(updates, Update::Stream(event))?;
      } else {
        match Control::decode(packet)? {
          Control::Hello if !ready => {
            ready = true;
            context_changed = true;
            emit(updates, Update::Ready)?;
          }
          Control::Pong(serial) if ready && serial > pong && serial <= ping => {
            pong = serial;
            deadline = now + Duration::from_secs(3);
          }
          Control::TopologyReady(epoch)
            if pending
              && lifetime
                .current()
                .is_some_and(|topology| topology.generation == epoch)
              && streams.values().all(|stream| stream.described == 3) =>
          {
            pending = false;
            emit(updates, Update::TopologyReady(epoch))?;
          }
          Control::PanelState { serial, open } if ready => {
            emit(updates, Update::PanelState { serial, open })?
          }
          Control::WidgetSize { width, height } if ready => {
            emit(updates, Update::WidgetSize { width, height })?
          }
          Control::ViewSize {
            view,
            width,
            height,
          } if ready => {
            if context
              .views
              .as_ref()
              .is_some_and(|views| views.iter().any(|allocation| allocation.id == view))
            {
              emit(
                updates,
                Update::ViewSize {
                  view,
                  width,
                  height,
                },
              )?;
            }
          }
          Control::PanelSwitch { forward } if ready => {
            emit(updates, Update::PanelSwitch { forward })?
          }
          Control::Blocked(action) if ready => emit(updates, Update::Blocked(action))?,
          _ => return Err(io::Error::other("unexpected controller control record")),
        }
      }
    }
    let changed = lifetime
      .current()
      .is_none_or(|topology| topology.generation != desired.generation);
    let settled = streams
      .iter()
      .all(|(id, stream)| stream.settled || desired.output(*id).is_none());
    if ready && !pending && changed && settled {
      lifetime.admit(desired.clone())?;
      if context_changed {
        Control::Context(context.clone()).send(&channel)?;
        context_changed = false;
      }
      streams = desired
        .outputs
        .iter()
        .map(|allocation| {
          (
            allocation.id,
            Stream {
              allocation: *allocation,
              frames: Frames::default(),
              configured: false,
              described: 0,
              settled: false,
            },
          )
        })
        .collect();
      Control::Topology(desired.clone()).send(&channel)?;
      pending = true;
    }
    std::thread::sleep(Duration::from_millis(5));
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::{
    presentation::{Buffer, Region},
    topology::{Output, Targeted},
  };
  use std::{fs::File, thread::JoinHandle};

  struct Fixture {
    controller: Channel,
    commands: SyncSender<Control>,
    updates: Receiver<Update>,
    task: JoinHandle<io::Result<()>>,
  }

  fn topology(epoch: u32, ids: &[u32]) -> Topology {
    Topology {
      version: 1,
      generation: epoch,
      outputs: ids
        .iter()
        .map(|id| Output {
          id: *id,
          x: (*id as i32 - 2) * 100,
          y: -20,
          width: 80,
          height: 48,
          scale_fixed: 150,
        })
        .collect(),
    }
  }

  impl Fixture {
    fn new() -> Self {
      let (host, controller) = Channel::pair().unwrap();
      let (commands, receiver) = mpsc::sync_channel(64);
      let (sender, updates) = mpsc::sync_channel(8);
      let task = std::thread::spawn(move || {
        dispatch(
          host,
          topology(1, &[1, 2]),
          UiContext::default(),
          receiver,
          &sender,
        )
      });
      let fixture = Self {
        controller,
        commands,
        updates,
        task,
      };
      Control::Hello.send(&fixture.controller).unwrap();
      assert!(matches!(fixture.update(), Update::Ready));
      assert!(matches!(fixture.control(), Control::Context(_)));
      assert_eq!(fixture.control(), Control::Topology(topology(1, &[1, 2])));
      fixture
    }

    fn update(&self) -> Update {
      self.updates.recv_timeout(Duration::from_secs(1)).unwrap()
    }

    fn control(&self) -> Control {
      let deadline = Instant::now() + Duration::from_secs(1);
      loop {
        match self.controller.receive() {
          Ok(packet) => match Control::decode(packet).unwrap() {
            Control::Ping(serial) => Control::Pong(serial).send(&self.controller).unwrap(),
            control => return control,
          },
          Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
            std::thread::sleep(Duration::from_millis(5))
          }
          Err(error) => panic!("missing control: {error}"),
        }
      }
    }

    fn send(&self, output: u32, epoch: u32, event: Event) {
      StreamEvent {
        output,
        epoch,
        event,
      }
      .send(&self.controller)
      .unwrap();
    }

    fn buffers(&self, epoch: u32, output: u32) {
      self.send(
        output,
        epoch,
        Event::Configured {
          generation: 1,
          viewport: Viewport {
            width: 80,
            height: 48,
            scale_fixed: 150,
          },
        },
      );
      assert!(matches!(self.update(), Update::Stream(_)));
      for slot in 0..2 {
        self.send(
          output,
          epoch,
          Event::Buffer(Buffer {
            generation: 1,
            slot,
            width: 100,
            height: 60,
            stride: 400,
            fd: File::open("/dev/null").unwrap().into(),
          }),
        );
        assert!(matches!(self.update(), Update::Stream(_)));
      }
    }

    fn frame(&self, epoch: u32, output: u32) {
      self.send(
        output,
        epoch,
        Event::Frame {
          generation: 1,
          serial: 1,
          slot: 0,
        },
      );
      assert!(matches!(self.update(), Update::Stream(_)));
    }

    fn ready(&self, epoch: u32) {
      Control::TopologyReady(epoch)
        .send(&self.controller)
        .unwrap();
      assert!(matches!(self.update(), Update::TopologyReady(value) if value == epoch));
    }

    fn acknowledge(&self, epoch: u32, output: u32) {
      let target = Targeted {
        epoch,
        output,
        event: Input::Presented(1),
      };
      self.commands.send(Control::Targeted(target)).unwrap();
      assert_eq!(self.control(), Control::Targeted(target));
    }
  }

  #[test]
  fn rejects_unsolicited_epochs_outputs_buffers_masks_frames_and_ready() {
    for mode in 0..9 {
      let fixture = Fixture::new();
      match mode {
        0 => fixture.send(
          1,
          2,
          Event::Frame {
            generation: 1,
            serial: 1,
            slot: 0,
          },
        ),
        1 => fixture.send(
          3,
          1,
          Event::Frame {
            generation: 1,
            serial: 1,
            slot: 0,
          },
        ),
        2 => fixture.send(
          1,
          1,
          Event::Configured {
            generation: 2,
            viewport: Viewport {
              width: 80,
              height: 48,
              scale_fixed: 150,
            },
          },
        ),
        3 => fixture.send(
          1,
          1,
          Event::Configured {
            generation: 1,
            viewport: Viewport {
              width: 80,
              height: 48,
              scale_fixed: 120,
            },
          },
        ),
        4 => fixture.send(
          1,
          1,
          Event::Buffer(Buffer {
            generation: 1,
            slot: 0,
            width: 100,
            height: 60,
            stride: 400,
            fd: File::open("/dev/null").unwrap().into(),
          }),
        ),
        5 => {
          fixture.buffers(1, 1);
          fixture.send(
            1,
            1,
            Event::Mask {
              generation: 1,
              regions: vec![Region {
                operation: 0,
                x: 79,
                y: 0,
                width: 2,
                height: 1,
              }],
            },
          );
        }
        6 => {
          fixture.buffers(1, 1);
          fixture.frame(1, 1);
          fixture.send(
            1,
            1,
            Event::Frame {
              generation: 1,
              serial: 2,
              slot: 1,
            },
          );
        }
        7 => Control::TopologyReady(1).send(&fixture.controller).unwrap(),
        _ => {
          fixture.send(
            1,
            1,
            Event::Configured {
              generation: 1,
              viewport: Viewport {
                width: 80,
                height: 48,
                scale_fixed: 150,
              },
            },
          );
          assert!(matches!(fixture.update(), Update::Stream(_)));
          fixture.send(
            1,
            1,
            Event::Buffer(Buffer {
              generation: 1,
              slot: 0,
              width: 80,
              height: 48,
              stride: 320,
              fd: File::open("/dev/null").unwrap().into(),
            }),
          );
        }
      }
      assert!(fixture.task.join().unwrap().is_err(), "mode {mode}");
    }
  }

  #[test]
  fn output_removal_does_not_wait_for_retired_importer_and_stale_events_cannot_revive_it() {
    let fixture = Fixture::new();
    for output in [1, 2] {
      fixture.buffers(1, output);
      fixture.frame(1, output);
    }
    fixture.ready(1);
    // Output 1 disappears with an unacknowledged GPU frame. Output 2 survives.
    fixture
      .commands
      .send(Control::Topology(topology(2, &[2])))
      .unwrap();
    fixture
      .commands
      .send(Control::Topology(topology(3, &[2])))
      .unwrap();
    fixture.acknowledge(1, 2);
    assert_eq!(fixture.control(), Control::Topology(topology(3, &[2])));
    fixture.send(
      1,
      1,
      Event::Frame {
        generation: 1,
        serial: 2,
        slot: 1,
      },
    );
    fixture
      .commands
      .send(Control::Targeted(Targeted {
        epoch: 1,
        output: 1,
        event: Input::Presented(1),
      }))
      .unwrap();
    fixture.buffers(3, 2);
    fixture.frame(3, 2);
    fixture.ready(3);
    fixture.acknowledge(3, 2);
    // No displays is an admitted topology, not a service shutdown.
    fixture
      .commands
      .send(Control::Topology(topology(4, &[])))
      .unwrap();
    assert_eq!(fixture.control(), Control::Topology(topology(4, &[])));
    fixture.ready(4);
    fixture.commands.send(Control::Stop).unwrap();
    assert!(fixture.task.join().unwrap().is_ok());
  }

  #[test]
  fn acknowledgements_cannot_cross_outputs_or_replay() {
    for replay in [false, true] {
      let fixture = Fixture::new();
      fixture.buffers(1, 1);
      fixture.frame(1, 1);
      if replay {
        fixture.acknowledge(1, 1);
      }
      fixture
        .commands
        .send(Control::Targeted(Targeted {
          epoch: 1,
          output: if replay { 1 } else { 2 },
          event: Input::Presented(1),
        }))
        .unwrap();
      assert!(fixture.task.join().unwrap().is_err());
    }
  }
}
