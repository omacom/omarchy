//! Event system, ported from engine/base_character.py EventHandler.
//!
//! Storage is plain data; dispatch lives on EngineCtx (engine/ctx.rs) so that
//! actions execute inline at the exact upstream emission points, reentrantly
//! (plan.md §4.2). Effect callbacks are (CallbackId, payload) routed through
//! EffectHooks::dispatch_callback — never closures in the arena.

use crate::engine::character::CharId;
use crate::utils::geometry::Coord;
use crate::utils::graphics::Color;

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

/// Waypoint identity for event keying: upstream Waypoint is a frozen dataclass
/// hashed/compared by ALL fields (id, coord, bezier controls) — two waypoints
/// with identical fields in different paths collide, faithfully.
///
/// Field order is load-bearing for speed, not for meaning: the derived
/// comparison short-circuits in declaration order, and `coord` rejects
/// non-matches with two integer compares instead of a string memcmp.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct WaypointKey {
    pub coord: Coord,
    pub waypoint_id: std::rc::Rc<str>,
    pub bezier_control: Option<std::rc::Rc<[Coord]>>,
}

/// Event caller identity. Scene/Path compare by id (their upstream __eq__).
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum CallerKey {
    Scene(String),
    Path(String),
    Waypoint(WaypointKey),
}

/// A caller identity borrowed for the duration of a lookup. Emission sites
/// already hold the id they are firing for, so matching against the table costs
/// nothing — building an owned CallerKey per emission did.
#[derive(Debug, Clone, Copy)]
pub enum CallerRef<'a> {
    Scene(&'a str),
    Path(&'a str),
    Waypoint(&'a WaypointKey),
}

/// FNV-1a over a byte run, seeded so the three caller kinds cannot collide.
#[inline]
fn fnv(mut hash: u32, bytes: &[u8]) -> u32 {
    for &byte in bytes {
        hash ^= byte as u32;
        hash = hash.wrapping_mul(16_777_619);
    }
    hash
}

impl CallerRef<'_> {
    /// A cheap digest of the caller's identity. Registered entries store theirs,
    /// so a lookup hashes once and then rejects candidates with an integer
    /// compare instead of a string compare each.
    #[inline]
    fn fingerprint(self) -> u32 {
        match self {
            CallerRef::Scene(id) => fnv(0x0100_0193, id.as_bytes()),
            CallerRef::Path(id) => fnv(0x0200_0193, id.as_bytes()),
            CallerRef::Waypoint(key) => {
                let hash = fnv(0x0300_0193, &key.coord.column.to_le_bytes());
                let hash = fnv(hash, &key.coord.row.to_le_bytes());
                fnv(hash, key.waypoint_id.as_bytes())
            }
        }
    }
}

impl CallerKey {
    #[inline]
    fn as_ref(&self) -> CallerRef<'_> {
        match self {
            CallerKey::Scene(id) => CallerRef::Scene(id),
            CallerKey::Path(id) => CallerRef::Path(id),
            CallerKey::Waypoint(key) => CallerRef::Waypoint(key),
        }
    }

    #[inline]
    fn matches(&self, caller: CallerRef<'_>) -> bool {
        match (self, caller) {
            (CallerKey::Scene(a), CallerRef::Scene(b)) => **a == *b,
            (CallerKey::Path(a), CallerRef::Path(b)) => **a == *b,
            (CallerKey::Waypoint(a), CallerRef::Waypoint(b)) => a == b,
            _ => false,
        }
    }
}

/// Typed payload values for effect callbacks (upstream Callback *args).
#[derive(Debug, Clone, PartialEq)]
pub enum CallbackValue {
    Int(i64),
    Float(f64),
    Str(String),
    Coord(Coord),
    Char(CharId),
    Color(Color),
}

/// An effect-defined callback: the id selects behavior inside the effect's
/// dispatch_callback; args are owned data captured at registration.
#[derive(Debug, Clone, PartialEq)]
pub struct EffectCallback {
    pub id: u32,
    pub args: Vec<CallbackValue>,
}

/// A registered action with its resolved target (upstream resolves string ids
/// to objects at registration; Scene/Path equality is by id, so ids suffice).
#[derive(Debug, Clone, PartialEq)]
pub enum EventAction {
    ActivatePath(String),
    ActivateScene(String),
    DeactivatePath(Option<String>),
    DeactivateScene(Option<String>),
    ResetAppearance,
    SetLayer(i64),
    SetCoordinate(Coord),
    Callback(EffectCallback),
}

/// Per-character event table: insertion-ordered (event, caller) -> actions.
///
/// `subscribed` mirrors the table as a bitmask of registered event kinds. Most
/// characters register a handful of events while the engine emits thousands,
/// so callers test it first and skip building the (allocating) CallerKey when
/// nothing could match.
#[derive(Debug, Clone, Default)]
pub struct EventHandler {
    registered_events: Vec<RegisteredEvent>,
    subscribed: u8,
}

#[derive(Debug, Clone)]
struct RegisteredEvent {
    event: Event,
    fingerprint: u32,
    caller: CallerKey,
    actions: Vec<EventAction>,
}

impl EventHandler {
    /// register_event with the duplicate check (upstream raises
    /// DuplicateEventRegistrationError). Caller/target id resolution and type
    /// validation happen in EngineCtx::register_event, which has arena access.
    pub fn push(&mut self, event: Event, caller: CallerKey, action: EventAction) -> Result<(), String> {
        let fingerprint = caller.as_ref().fingerprint();
        let existing = self.registered_events.iter_mut().find(|entry| {
            entry.event == event && entry.fingerprint == fingerprint && entry.caller == caller
        });
        if let Some(entry) = existing {
            if entry.actions.contains(&action) {
                return Err(format!(
                    "duplicate event registration: {:?} {:?}",
                    (entry.event, &entry.caller),
                    action
                ));
            }
            entry.actions.push(action);
        } else {
            self.registered_events.push(RegisteredEvent { event, fingerprint, caller, actions: vec![action] });
        }
        self.subscribed |= event.bit();
        Ok(())
    }

    /// True when at least one action is registered for this event kind, for any
    /// caller. A false answer means `actions_index` cannot match.
    #[inline]
    pub fn subscribes(&self, event: Event) -> bool {
        self.subscribed & event.bit() != 0
    }

    #[inline]
    pub fn actions_index(&self, event: Event, caller: CallerRef<'_>) -> Option<usize> {
        if !self.subscribes(event) {
            return None;
        }
        // Hashing the query only pays once there is a run of candidates to
        // reject; a table with a couple of entries compares them directly.
        if self.registered_events.len() <= 2 {
            return self
                .registered_events
                .iter()
                .position(|entry| entry.event == event && entry.caller.matches(caller));
        }
        let fingerprint = caller.fingerprint();
        self.registered_events.iter().position(|entry| {
            entry.event == event && entry.fingerprint == fingerprint && entry.caller.matches(caller)
        })
    }

    #[inline]
    pub fn actions(&self, index: usize) -> &[EventAction] {
        &self.registered_events[index].actions
    }

    pub fn clear(&mut self) {
        self.registered_events.clear();
        self.subscribed = 0;
    }
}
