//! Events (engine/events.rs and EngineCtx::handle_event).
//!
//! Each character keeps a list of registered (event, caller) entries, each
//! with its actions in registration order (one flat list), and a bitmask of
//! the events it subscribes to, so an emission nobody listens to costs one
//! bit test.
//! Actions run synchronously at the emission point, like upstream.

use crate::utils::geometry::Coord;

use super::{Engine, Hooks, Name, NONE};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Event {
    SegmentEntered,
    SegmentExited,
    PathActivated,
    PathComplete,
    PathHolding,
    SceneActivated,
    SceneComplete,
}

impl Event {
    #[inline]
    fn bit(self) -> u8 {
        1 << (self as u8)
    }
}

/// A waypoint as an event key: equal by value (coordinate, name and bezier
/// controls), like the old engine's WaypointKey. Bezier control lists are
/// interned, so equal controls have equal ids.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct WaypointKey {
    pub coord: Coord,
    pub name: Name,
    /// Interned bezier control list, NONE when there is none.
    pub bezier: u32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Caller {
    Scene(Name),
    Path(Name),
    Waypoint(WaypointKey),
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Action {
    ActivatePath(Name),
    ActivateScene(Name),
    DeactivatePath(Option<Name>),
    DeactivateScene(Option<Name>),
    ResetAppearance,
    SetLayer(i32),
    SetCoordinate(Coord),
    /// The effect's Hooks::callback with (id, arg).
    Callback(u32, i64),
}

struct Entry {
    next: u32,
    /// The character's last entry (kept in its first entry only).
    tail: u32,
    /// (event, caller kind, caller name) in one word: a named caller's
    /// entry matches on it alone, a waypoint's also on `caller`.
    key: u64,
    caller: Caller,
    /// Actions in registration order: a list through `ActionNode::next`.
    first: u32,
    last: u32,
}

/// Entry::key.
#[inline(always)]
fn entry_key(event: Event, caller: Caller) -> u64 {
    let (kind, name) = match caller {
        Caller::Scene(name) => (0, name),
        Caller::Path(name) => (1, name),
        Caller::Waypoint(w) => (2, w.name),
    };
    event as u64 | kind << 8 | (name.0 as u64) << 32
}

struct ActionNode {
    action: Action,
    next: u32,
}

#[derive(Default)]
pub struct EventStore {
    entries: Vec<Entry>,
    actions: Vec<ActionNode>,
}

impl Engine {
    #[inline]
    pub fn observes(&self, slot: u32, event: Event) -> bool {
        self.ch.subs[slot as usize] & event.bit() != 0
    }

    fn event_entry(&self, slot: u32, event: Event, caller: Caller) -> Option<u32> {
        let key = entry_key(event, caller);
        let waypoint = matches!(caller, Caller::Waypoint(_));
        let mut e = self.ch.events[slot as usize];
        while e != NONE {
            let entry = &self.events.entries[e as usize];
            if entry.key == key && (!waypoint || entry.caller == caller) {
                return Some(e);
            }
            e = entry.next;
        }
        None
    }

    /// EventHandler.register_event: callers and targets that name a path or
    /// scene must exist, and an identical registration is an error.
    pub fn register_event(
        &mut self,
        slot: u32,
        event: Event,
        caller: Caller,
        action: Action,
    ) -> Result<(), String> {
        match caller {
            Caller::Path(name) if self.path_find(slot, name).is_none() => {
                return Err(format!("path not found: {}", self.names.to_string(name)));
            }
            Caller::Scene(name) if self.scene_find(slot, name).is_none() => {
                return Err(format!("scene not found: {}", self.names.to_string(name)));
            }
            _ => {}
        }
        match action {
            Action::ActivatePath(name) | Action::DeactivatePath(Some(name))
                if self.path_find(slot, name).is_none() =>
            {
                return Err(format!("path not found: {}", self.names.to_string(name)));
            }
            Action::ActivateScene(name) | Action::DeactivateScene(Some(name))
                if self.scene_find(slot, name).is_none() =>
            {
                return Err(format!("scene not found: {}", self.names.to_string(name)));
            }
            _ => {}
        }
        let node = self.events.actions.len() as u32;
        match self.event_entry(slot, event, caller) {
            Some(e) => {
                let mut a = self.events.entries[e as usize].first;
                while a != NONE {
                    if self.events.actions[a as usize].action == action {
                        return Err(format!(
                            "duplicate event registration: {:?} {:?}",
                            (event, caller),
                            action
                        ));
                    }
                    a = self.events.actions[a as usize].next;
                }
                self.events.actions.push(ActionNode { action, next: NONE });
                let entry = &mut self.events.entries[e as usize];
                self.events.actions[entry.last as usize].next = node;
                entry.last = node;
            }
            None => {
                self.events.actions.push(ActionNode { action, next: NONE });
                let id = self.events.entries.len() as u32;
                let key = entry_key(event, caller);
                self.events.entries.push(Entry {
                    next: NONE,
                    tail: id,
                    key,
                    caller,
                    first: node,
                    last: node,
                });
                // append, keeping registration order
                let head = self.ch.events[slot as usize];
                if head == NONE {
                    self.ch.events[slot as usize] = id;
                } else {
                    let tail = std::mem::replace(&mut self.events.entries[head as usize].tail, id);
                    self.events.entries[tail as usize].next = id;
                }
            }
        }
        self.ch.subs[slot as usize] |= event.bit();
        Ok(())
    }

    /// Execute every action registered for (event, caller), in registration
    /// order, inline. The list is re-read per action: a callback may add to it.
    pub fn handle_event(&mut self, hooks: &mut dyn Hooks, slot: u32, event: Event, caller: Caller) {
        if !self.observes(slot, event) {
            return;
        }
        let Some(entry) = self.event_entry(slot, event, caller) else {
            return;
        };
        let mut a = self.events.entries[entry as usize].first;
        while a != NONE {
            let action = self.events.actions[a as usize].action;
            match action {
                Action::ActivatePath(name) => {
                    let path = self
                        .path_find(slot, name)
                        .expect("activate_path: path not found");
                    self.activate_path(hooks, slot, path);
                }
                Action::ActivateScene(name) => self.activate_scene_name(hooks, slot, name),
                Action::DeactivatePath(name) => self.deactivate_path(slot, name),
                Action::DeactivateScene(name) => self.deactivate_scene(slot, name),
                Action::ResetAppearance => self.reset_appearance(slot),
                Action::SetLayer(layer) => self.set_layer(slot, layer),
                Action::SetCoordinate(coord) => self.set_coordinate(slot, coord),
                Action::Callback(id, arg) => {
                    self.motion_settle();
                    self.motion_epoch = self.motion_epoch.wrapping_add(1);
                    hooks.callback(self, slot, id, arg)
                }
            }
            a = self.events.actions[a as usize].next;
        }
    }

    /// Drop every registration of the character.
    pub fn event_clear(&mut self, slot: u32) {
        self.ch.events[slot as usize] = NONE;
        self.ch.subs[slot as usize] = 0;
    }

    /// Motion.chain_paths.
    pub fn chain_paths(&mut self, slot: u32, paths: &[Name], looping: bool) -> Result<(), String> {
        if paths.len() < 2 {
            return Ok(());
        }
        for pair in paths.windows(2) {
            self.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(pair[0]),
                Action::ActivatePath(pair[1]),
            )?;
        }
        if looping {
            self.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(paths[paths.len() - 1]),
                Action::ActivatePath(paths[0]),
            )?;
        }
        Ok(())
    }
}
