//! Exact own-entry setting keys. System settings need separate trusted backends.
use crate::grants::{invalid, validate_id};
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value};
use std::{collections::BTreeSet, io};

#[derive(Clone, Debug, Default, PartialEq, Eq, Deserialize, Serialize)]
#[serde(default, deny_unknown_fields)]
pub struct Grant {
  pub read: BTreeSet<String>,
  pub write: BTreeSet<String>,
}

#[derive(Clone, Debug, Default, PartialEq, Eq, Deserialize, Serialize)]
#[serde(default, deny_unknown_fields)]
pub struct Ask {
  pub read: BTreeSet<String>,
  pub write: BTreeSet<String>,
  pub required: bool,
}

impl Ask {
  pub fn access(&self) -> Grant {
    Grant {
      read: self.read.clone(),
      write: self.write.clone(),
    }
  }
}

impl Grant {
  pub fn can_write(&self) -> bool {
    !self.write.is_empty()
  }

  pub fn covers(&self, other: &Self) -> bool {
    self.read.is_superset(&other.read) && self.write.is_superset(&other.write)
  }

  pub fn validate(&self) -> io::Result<()> {
    if self.read.len() + self.write.len() > crate::grants::MAX_GRANTED_DIRS {
      return Err(invalid("too many setting-key selections"));
    }
    for key in self.read.iter().chain(&self.write) {
      validate_id(key)?;
      if [
        "id",
        "sandbox",
        "sandboxPresentation",
        "__proto__",
        "constructor",
        "prototype",
      ]
      .contains(&key.as_str())
      {
        return Err(invalid("setting scope cannot name host structure"));
      }
    }
    Ok(())
  }

  pub fn filter(&self, settings: &mut Map<String, Value>) {
    settings.retain(|key, _| self.read.contains(key));
  }

  pub fn check_write(&self, settings: &Map<String, Value>) -> io::Result<()> {
    if settings.keys().any(|key| !self.write.contains(key)) {
      return Err(invalid("settings update exceeds approved write keys"));
    }
    Ok(())
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::grants::{Grants, Requests};
  use serde_json::json;

  #[test]
  fn exact_read_and_write_keys_are_independent_and_bounded_by_the_request() {
    let request: Requests = serde_json::from_value(json!({
      "settings": {"read": ["theme"], "write": ["volume"], "required": true}
    }))
    .unwrap();
    let mut granted = Grants::default();
    granted.validate(&request).unwrap();
    assert_eq!(granted.required_gap(&request), ["settings"]);
    granted.settings = request.settings.access();
    granted.validate(&request).unwrap();
    assert!(granted.required_gap(&request).is_empty());
    let mut values =
      serde_json::from_value(json!({"theme": "dark", "volume": 50, "secret": "hidden"})).unwrap();
    granted.settings.filter(&mut values);
    assert_eq!(Value::Object(values), json!({"theme": "dark"}));
    assert!(
      granted
        .settings
        .check_write(&serde_json::from_value(json!({"volume": 10})).unwrap())
        .is_ok()
    );
    assert!(
      granted
        .settings
        .check_write(&serde_json::from_value(json!({"theme": "light"})).unwrap())
        .is_err()
    );
    granted.settings.read.insert("volume".into());
    assert!(
      granted.validate(&request).is_err(),
      "write must not imply read"
    );
  }

  #[test]
  fn schema_has_no_obsolete_forms_or_implicit_wildcards() {
    for value in [
      json!(true),
      json!(false),
      json!({"read": true}),
      json!({"write": ["volume"], "unknown": true}),
    ] {
      assert!(serde_json::from_value::<Grant>(value.clone()).is_err());
      assert!(serde_json::from_value::<Ask>(value).is_err());
    }
    for key in [
      "*",
      "id",
      "sandbox",
      "sandboxPresentation",
      "constructor",
      "__proto__",
      "prototype",
    ] {
      let grant = Grant {
        read: [key.into()].into(),
        ..Default::default()
      };
      assert!(grant.validate().is_err());
    }
    assert!(serde_json::from_value::<Requests>(json!({"read": ["notes"]})).is_err());
    assert!(serde_json::from_value::<Requests>(json!({"filesystem": ["notes"]})).is_err());
    assert!(serde_json::from_value::<Grants>(json!({"read": {}})).is_err());
    assert!(serde_json::from_value::<Requests>(json!({"filesystem": [{"name": "notes", "path": "/data/notes"}]})).is_ok());
  }
}
