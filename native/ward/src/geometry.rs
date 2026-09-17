//! Read-only desktop layout, with no compositor handles, titles or controls.
//! IDs are opaque within the host lifetime. Coordinates are global logical
//! pixels; the viewport names the output on which the host placed this worker.
use serde::{Deserialize, Serialize};
use std::{collections::BTreeSet, io};

pub const MAX_BYTES: usize = 48 * 1024;

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Snapshot {
  pub viewport: u32,
  pub outputs: Vec<Output>,
  pub workspaces: Vec<Workspace>,
  pub windows: Vec<Window>,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Rect {
  pub x: f64,
  pub y: f64,
  pub width: f64,
  pub height: f64,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "camelCase")]
pub struct Output {
  pub id: u32,
  pub rect: Rect,
  pub scale: f64,
  /// Left, top, right, bottom, in logical pixels.
  pub reserved: [f64; 4],
  pub active_workspaces: Vec<u32>,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Workspace {
  pub id: u32,
  pub output: Option<u32>,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Window {
  pub id: u32,
  pub workspace: Option<u32>,
  pub rect: Rect,
  pub mapped: bool,
  pub hidden: bool,
  pub fullscreen: bool,
}

impl Rect {
  fn valid(&self) -> bool {
    [self.x, self.y]
      .into_iter()
      .all(|v| v.is_finite() && v.abs() <= 1_048_576.)
      && [self.width, self.height]
        .into_iter()
        .all(|v| v.is_finite() && (0.0..=65_536.).contains(&v))
  }
}

impl Snapshot {
  pub fn validate(&self) -> io::Result<()> {
    let unique = |ids: Vec<u32>| {
      ids.iter().all(|id| *id != 0)
        && ids.iter().copied().collect::<BTreeSet<_>>().len() == ids.len()
    };
    let output = |id| self.outputs.iter().any(|v| v.id == id);
    let workspace = |id| self.workspaces.iter().any(|v| v.id == id);
    if self.outputs.len() > 32
      || self.workspaces.len() > 256
      || self.windows.len() > 256
      || !unique(self.outputs.iter().map(|v| v.id).collect())
      || !unique(self.workspaces.iter().map(|v| v.id).collect())
      || !unique(self.windows.iter().map(|v| v.id).collect())
      || !output(self.viewport)
      || self.outputs.iter().any(|v| {
        !v.rect.valid()
          || v.rect.width == 0.
          || v.rect.height == 0.
          || !v.scale.is_finite()
          || !(0.25..=8.).contains(&v.scale)
          || v
            .reserved
            .iter()
            .any(|n| !n.is_finite() || !(0.0..=65_536.).contains(n))
          || v.active_workspaces.len() > 2
          || !unique(v.active_workspaces.clone())
          || v.active_workspaces.iter().any(|id| {
            !self
              .workspaces
              .iter()
              .any(|w| w.id == *id && w.output == Some(v.id))
          })
      })
      || self
        .workspaces
        .iter()
        .any(|v| v.output.is_some_and(|id| !output(id)))
      || self
        .windows
        .iter()
        .any(|v| !v.rect.valid() || v.workspace.is_some_and(|id| !workspace(id)))
      || serde_json::to_vec(self)?.len() > MAX_BYTES
    {
      return Err(io::Error::other("invalid or oversized desktop geometry"));
    }
    Ok(())
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::{
    context::UiContext,
    grants::{Grants, Requests},
  };
  use serde_json::json;

  fn snapshot() -> Snapshot {
    serde_json::from_value(json!({
      "viewport": 7,
      "outputs": [{"id":7, "rect":{"x":-1536.5,"y":0,"width":1536,"height":864},
        "scale":1.25,"reserved":[0,0,0,32.5],"activeWorkspaces":[3]}],
      "workspaces": [{"id":3,"output":7}],
      "windows": [{"id":9,"workspace":3,"rect":{"x":-1400.5,"y":200.25,"width":600,"height":400},
        "mapped":true,"hidden":false,"fullscreen":false}]
    }))
    .unwrap()
  }

  #[test]
  fn geometry_requires_explicit_revision_bound_selection() {
    let mut grants = Grants {
      desktop_geometry: true,
      ..Default::default()
    };
    assert!(grants.validate(&Requests::default()).is_err());
    let optional: Requests = serde_json::from_value(json!({"desktopGeometry":true})).unwrap();
    grants.validate(&optional).unwrap();
    grants.desktop_geometry = false;
    grants.validate(&optional).unwrap();
    assert!(grants.required_gap(&optional).is_empty());
    let required: Requests =
      serde_json::from_value(json!({"desktopGeometry":{"required":true}})).unwrap();
    assert_eq!(grants.required_gap(&required), ["desktopGeometry"]);
    for value in [
      json!({"titles":true}),
      json!({"write":true}),
      json!(["windows"]),
    ] {
      assert!(serde_json::from_value::<Requests>(json!({"desktopGeometry":value})).is_err());
    }
  }

  #[test]
  fn geometry_is_typed_complete_and_survives_read_only_transport() {
    let mut geometry = snapshot();
    geometry.validate().unwrap();
    let mut context = UiContext {
      geometry: Some(geometry.clone()),
      ..Default::default()
    };
    context.filter(&Grants {
      desktop_geometry: true,
      ..Default::default()
    });
    assert_eq!(
      UiContext::unseal(context.seal().unwrap().into())
        .unwrap()
        .geometry,
      Some(geometry.clone())
    );
    context.filter(&Grants::default());
    assert!(context.geometry.is_none());
    geometry.windows[0].rect.x += 100.;
    assert_eq!(geometry.windows[0].id, 9);
    for key in ["title", "address", "pid", "appId", "content"] {
      let mut value = serde_json::to_value(&geometry).unwrap();
      value["windows"][0][key] = "must not pass".into();
      assert!(serde_json::from_value::<Snapshot>(value).is_err());
    }
    let mut bad = geometry.clone();
    bad.windows.push(bad.windows[0].clone());
    assert!(bad.validate().is_err());
    bad = geometry.clone();
    bad.viewport = 8;
    assert!(bad.validate().is_err());
    bad = geometry.clone();
    bad.windows[0].workspace = Some(99);
    assert!(bad.validate().is_err());
    bad = geometry.clone();
    bad.workspaces[0].output = None;
    assert!(bad.validate().is_err());
    for number in [f64::NAN, f64::INFINITY, -f64::INFINITY, 1_048_577.] {
      bad = geometry.clone();
      bad.windows[0].rect.x = number;
      assert!(bad.validate().is_err());
    }
    bad = geometry.clone();
    bad.outputs[0].scale = 0.;
    assert!(bad.validate().is_err());
    bad = geometry.clone();
    bad.outputs[0].reserved[3] = -1.;
    assert!(bad.validate().is_err());
    bad = geometry.clone();
    bad.windows[0].rect.width = -1.;
    assert!(bad.validate().is_err());
    bad = geometry.clone();
    bad.windows.clear();
    for id in 1..=257 {
      let mut window = geometry.windows[0].clone();
      window.id = id;
      bad.windows.push(window);
    }
    assert!(
      bad.validate().is_err(),
      "must reject, not truncate, excess windows"
    );
    bad.windows.pop();
    for window in &mut bad.windows {
      window.rect = Rect {
        x: 123456.12345678912,
        y: -123456.12345678912,
        width: 65432.12345678912,
        height: 65432.12345678912,
      };
    }
    bad.workspaces.extend((10..=264).map(|id| Workspace {
      id,
      output: Some(7),
    }));
    assert!(serde_json::to_vec(&bad).unwrap().len() > MAX_BYTES);
    assert!(
      bad.validate().is_err(),
      "the byte ceiling also binds within the count ceiling"
    );
  }
}
