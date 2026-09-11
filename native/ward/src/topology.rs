//! Host-owned presentation allocations, independent of desktop observation grants.
//! Output IDs are never reused within a session. Geometry is logical; each
//! output has its own physical buffers, so desktop gaps consume no GPU memory.
use serde::{Deserialize, Serialize};
use std::{collections::BTreeSet, io};

pub const MAX_OUTPUTS: usize = 8;
pub const MAX_OUTPUT_PIXELS: u64 = 8_388_608;
// Two ARGB buffers per stream: at most 256 MiB across all admitted outputs.
pub const MAX_TOTAL_PIXELS: u64 = 33_554_432;
pub const MAX_BYTES: usize = 16_384;

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "camelCase")]
pub struct Topology {
  pub version: u32,
  pub generation: u32,
  pub outputs: Vec<Output>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "camelCase")]
pub struct Output {
  pub id: u32,
  pub x: i32,
  pub y: i32,
  pub width: u32,
  pub height: u32,
  /// Fractional scale in units of 1/120, matching Wayland preferred scale.
  pub scale_fixed: u32,
}

impl Output {
  pub fn pixels(self) -> io::Result<(u32, u32)> {
    if self.id == 0
      || !(-32768..=32768).contains(&self.x)
      || !(-32768..=32768).contains(&self.y)
      || !(1..=4096).contains(&self.width)
      || !(1..=4096).contains(&self.height)
      || !(120..=480).contains(&self.scale_fixed)
    {
      return Err(invalid("invalid output allocation"));
    }
    // Round once at the output boundary, without floating-point ambiguity.
    let width = (u64::from(self.width) * u64::from(self.scale_fixed) + 60) / 120;
    let height = (u64::from(self.height) * u64::from(self.scale_fixed) + 60) / 120;
    if width > 8192 || height > 8192 || width * height > MAX_OUTPUT_PIXELS {
      return Err(invalid("output allocation exceeds physical pixel budget"));
    }
    Ok((width as u32, height as u32))
  }

  pub fn contains(self, x: i32, y: i32) -> bool {
    x >= 0 && y >= 0 && (x as u32) < self.width && (y as u32) < self.height
  }
}

impl Topology {
  pub(crate) fn seal(&self) -> io::Result<std::fs::File> {
    self.validate()?;
    crate::payload::seal(&serde_json::to_vec(self)?, MAX_BYTES)
  }

  pub(crate) fn unseal(fd: std::os::fd::OwnedFd) -> io::Result<Self> {
    Self::parse(&crate::payload::read(fd, MAX_BYTES)?)
  }

  pub fn single(viewport: crate::presentation::Viewport) -> Self {
    Self {
      version: 1,
      generation: 1,
      outputs: vec![Output {
        id: 1,
        x: 0,
        y: 0,
        width: viewport.width,
        height: viewport.height,
        scale_fixed: viewport.scale_fixed,
      }],
    }
  }

  pub fn parse(bytes: &[u8]) -> io::Result<Self> {
    if bytes.len() > MAX_BYTES {
      return Err(invalid("presentation topology exceeds 16 KiB"));
    }
    let topology: Self = serde_json::from_slice(bytes)?;
    topology.validate()?;
    Ok(topology)
  }

  pub fn validate(&self) -> io::Result<()> {
    if self.version != 1 || self.generation == 0 || self.outputs.len() > MAX_OUTPUTS {
      return Err(invalid("invalid presentation topology"));
    }
    // Zero outputs is intentional: unplugging the last output keeps the
    // logical service alive while removing all presentation/input authority.
    let mut ids = BTreeSet::new();
    let mut pixels = 0;
    for output in &self.outputs {
      if !ids.insert(output.id) {
        return Err(invalid("duplicate presentation output ID"));
      }
      let (width, height) = output.pixels()?;
      pixels += u64::from(width) * u64::from(height);
    }
    if pixels > MAX_TOTAL_PIXELS {
      return Err(invalid(
        "presentation topology exceeds aggregate pixel budget",
      ));
    }
    Ok(())
  }

  pub fn output(&self, id: u32) -> Option<Output> {
    self.outputs.iter().find(|output| output.id == id).copied()
  }

  /// Input is output-local and bound to the exact admitted configuration.
  /// Mapping to the private desktop happens only after these checks.
  pub fn map_input(&self, generation: u32, id: u32, x: i32, y: i32) -> Option<(i32, i32)> {
    let output = self.output(id)?;
    (generation == self.generation && output.contains(x, y)).then_some((output.x + x, output.y + y))
  }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Targeted {
  pub output: u32,
  pub epoch: u32,
  pub event: Input,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Input {
  Presented(u64),
  Pointer {
    kind: u32,
    code: u32,
    x: i32,
    y: i32,
  },
  Scroll(crate::controller::Scroll),
  Key(crate::controller::Key),
}

impl Targeted {
  pub(crate) fn words(self) -> io::Result<[u32; 8]> {
    if self.output == 0 || self.epoch == 0 {
      return Err(invalid("invalid input target"));
    }
    let values = match self.event {
      Input::Presented(serial) if serial != 0 => [1, serial as u32, (serial >> 32) as u32, 0, 0, 0],
      Input::Pointer { kind, code, x, y } if kind <= 6 => [2, kind, code, x as u32, y as u32, 0],
      Input::Scroll(scroll) => {
        scroll.validate()?;
        [
          3,
          scroll.source,
          scroll.x as u32,
          scroll.y as u32,
          scroll.horizontal as u32,
          scroll.vertical as u32,
        ]
      }
      Input::Key(key) => {
        key.validate()?;
        [4, key.code, key.symbol, u32::from(key.pressed), 0, 0]
      }
      _ => return Err(invalid("invalid targeted input")),
    };
    Ok([
      self.output,
      self.epoch,
      values[0],
      values[1],
      values[2],
      values[3],
      values[4],
      values[5],
    ])
  }

  pub(crate) fn from_words(values: [u32; 8]) -> io::Result<Self> {
    let event = match values[2..] {
      [1, low, high, 0, 0, 0] => Input::Presented(u64::from(low) | (u64::from(high) << 32)),
      [2, kind, code, x, y, 0] => Input::Pointer {
        kind,
        code,
        x: x as i32,
        y: y as i32,
      },
      [3, source, x, y, horizontal, vertical] => Input::Scroll(crate::controller::Scroll {
        source,
        x: x as i32,
        y: y as i32,
        horizontal: horizontal as i32,
        vertical: vertical as i32,
      }),
      [4, code, symbol, pressed @ 0..=1, 0, 0] => Input::Key(crate::controller::Key {
        code,
        symbol,
        pressed: pressed == 1,
      }),
      _ => return Err(invalid("invalid targeted input fields")),
    };
    let target = Self {
      output: values[0],
      epoch: values[1],
      event,
    };
    target.words()?;
    Ok(target)
  }
}

/// Constant-space lifetime tracking: newly introduced output IDs must advance
/// the high-water mark. Retired IDs cannot alias a later physical output.
#[derive(Clone, Default)]
pub struct Lifetime {
  current: Option<Topology>,
  high_water: u32,
}

impl Lifetime {
  pub fn admit(&mut self, next: Topology) -> io::Result<()> {
    next.validate()?;
    let previous_generation = self.current.as_ref().map_or(0, |value| value.generation);
    if next.generation <= previous_generation {
      return Err(invalid("stale presentation topology"));
    }
    for output in &next.outputs {
      let retained = self
        .current
        .as_ref()
        .is_some_and(|value| value.output(output.id).is_some());
      if !retained && output.id <= self.high_water {
        return Err(invalid("retired presentation output ID"));
      }
    }
    self.high_water = next
      .outputs
      .iter()
      .map(|output| output.id)
      .max()
      .unwrap_or(0)
      .max(self.high_water);
    self.current = Some(next);
    Ok(())
  }

  pub fn current(&self) -> Option<&Topology> {
    self.current.as_ref()
  }
}

fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn targeted_records_round_trip_and_reject_noncanonical_fields() {
    for event in [
      Input::Presented(u64::MAX),
      Input::Pointer {
        kind: 2,
        code: 0,
        x: -12,
        y: 33,
      },
      Input::Scroll(crate::controller::Scroll {
        source: 0,
        x: 12,
        y: 20,
        horizontal: -120,
        vertical: 240,
      }),
      Input::Key(crate::controller::Key {
        code: 30,
        symbol: 97,
        pressed: true,
      }),
    ] {
      let target = Targeted {
        output: 9,
        epoch: 7,
        event,
      };
      assert_eq!(
        Targeted::from_words(target.words().unwrap()).unwrap(),
        target
      );
      let (producer, consumer) = crate::channel::Channel::pair().unwrap();
      crate::controller::Control::Targeted(target)
        .send(&producer)
        .unwrap();
      assert!(
        matches!(crate::controller::Control::decode(consumer.receive().unwrap()).unwrap(), crate::controller::Control::Targeted(value) if value == target)
      );
    }
    for words in [
      [0, 1, 1, 1, 0, 0, 0, 0],
      [1, 0, 1, 1, 0, 0, 0, 0],
      [1, 1, 1, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 0, 1, 0, 0],
      [1, 1, 2, 7, 0, 0, 0, 0],
      [1, 1, 2, 2, 0, 0, 0, 1],
      [1, 1, 4, 30, 97, 2, 0, 0],
      [1, 1, 4, 30, 97, 1, 1, 0],
      [1, 1, 5, 0, 0, 0, 0, 0],
    ] {
      assert!(Targeted::from_words(words).is_err(), "{words:?}");
    }
  }

  #[test]
  fn sealed_topology_preserves_signed_fractional_allocations() {
    let topology = topology(vec![Output {
      x: -700,
      y: -230,
      scale_fixed: 150,
      ..output(4)
    }]);
    assert_eq!(
      Topology::unseal(topology.seal().unwrap().into()).unwrap(),
      topology
    );
    assert!(Topology::unseal(std::fs::File::open("/dev/null").unwrap().into()).is_err());
    let (producer, consumer) = crate::channel::Channel::pair().unwrap();
    crate::controller::Control::Topology(topology.clone())
      .send(&producer)
      .unwrap();
    assert!(
      matches!(crate::controller::Control::decode(consumer.receive().unwrap()).unwrap(), crate::controller::Control::Topology(value) if value == topology)
    );
  }

  fn output(id: u32) -> Output {
    Output {
      id,
      x: 0,
      y: 0,
      width: 1920,
      height: 1080,
      scale_fixed: 120,
    }
  }

  fn topology(outputs: Vec<Output>) -> Topology {
    Topology {
      version: 1,
      generation: 1,
      outputs,
    }
  }

  #[test]
  fn mixed_scale_negative_origins_portrait_and_gaps_cost_only_output_pixels() {
    let wall = topology(vec![
      Output {
        x: -20000,
        scale_fixed: 150,
        ..output(1)
      },
      Output {
        x: 20000,
        y: -1080,
        width: 1080,
        height: 1920,
        scale_fixed: 180,
        ..output(2)
      },
      Output {
        y: 20000,
        scale_fixed: 240,
        ..output(3)
      },
    ]);
    wall.validate().unwrap();
    assert_eq!(wall.outputs[0].pixels().unwrap(), (2400, 1350));
    assert_eq!(wall.outputs[1].pixels().unwrap(), (1620, 2880));
    assert_eq!(wall.map_input(1, 1, 123, 45), Some((-19877, 45)));
    assert_eq!(wall.map_input(1, 2, 10, 20), Some((20010, -1060)));
    assert_eq!(wall.map_input(2, 1, 0, 0), None);
    assert_eq!(wall.map_input(1, 4, 0, 0), None);
    assert_eq!(wall.map_input(1, 1, 1920, 0), None);
    assert_eq!(wall.map_input(1, 1, -1, 0), None);
    assert_eq!(
      Topology::parse(&serde_json::to_vec(&wall).unwrap()).unwrap(),
      wall
    );
  }

  #[test]
  fn count_identity_version_and_pixel_limits_are_enforced() {
    for (width, height, scale_fixed) in [
      (4096, 1, 480),
      (1, 4096, 480),
      (4096, 1, 240),
      (1, 4096, 240),
    ] {
      let allocation = Output {
        width,
        height,
        scale_fixed,
        ..output(1)
      };
      let viewport = crate::presentation::Viewport {
        width,
        height,
        scale_fixed,
      };
      assert_eq!(allocation.pixels().is_ok(), viewport.pixels().is_ok());
    }
    assert!(topology(vec![output(0)]).validate().is_err());
    assert!(topology(vec![output(1), output(1)]).validate().is_err());
    assert!(topology((1..=9).map(output).collect()).validate().is_err());
    assert!(
      Topology {
        version: 2,
        ..topology(vec![])
      }
      .validate()
      .is_err()
    );
    assert!(
      Topology {
        generation: 0,
        ..topology(vec![])
      }
      .validate()
      .is_err()
    );
    for bad in [
      Output {
        width: 0,
        ..output(1)
      },
      Output {
        width: u32::MAX,
        ..output(1)
      },
      Output {
        x: i32::MIN,
        ..output(1)
      },
      Output {
        scale_fixed: 119,
        ..output(1)
      },
      Output {
        scale_fixed: 481,
        ..output(1)
      },
      Output {
        scale_fixed: 480,
        ..output(1)
      },
    ] {
      assert!(topology(vec![bad]).validate().is_err(), "{bad:?}");
    }
    let large = |id| Output {
      width: 3840,
      height: 2160,
      ..output(id)
    };
    topology((1..=4).map(large).collect()).validate().unwrap();
    assert!(topology((1..=5).map(large).collect()).validate().is_err());
    assert!(Topology::parse(&vec![b' '; MAX_BYTES + 1]).is_err());
    assert!(Topology::parse(br#"{"version":1,"generation":1,"outputs":[],"grant":true}"#).is_err());
  }

  #[test]
  fn hotplug_cannot_reuse_ids_or_revive_stale_input() {
    let mut lifetime = Lifetime::default();
    lifetime
      .admit(topology(vec![output(1), output(2)]))
      .unwrap();
    assert!(lifetime.admit(topology(vec![output(1)])).is_err());
    lifetime
      .admit(Topology {
        generation: 2,
        ..topology(vec![output(2)])
      })
      .unwrap();
    assert!(
      lifetime
        .admit(Topology {
          generation: 3,
          ..topology(vec![output(1)])
        })
        .is_err()
    );
    assert_eq!(lifetime.current().unwrap().generation, 2);
    assert_eq!(lifetime.current().unwrap().map_input(1, 2, 0, 0), None);
    lifetime
      .admit(Topology {
        generation: 3,
        ..topology(vec![])
      })
      .unwrap();
    assert!(
      lifetime
        .admit(Topology {
          generation: 4,
          ..topology(vec![output(2)])
        })
        .is_err()
    );
    lifetime
      .admit(Topology {
        generation: 4,
        ..topology(vec![output(3)])
      })
      .unwrap();
  }
}
