//! Insertion-ordered string-keyed map with Python-dict iteration semantics.
//! Used everywhere upstream iterates dict values (plan.md §4.3): motion.paths,
//! animation.scenes, effect-level dicts. Small maps use a compact linear scan;
//! larger maps add a lookup index while retaining the canonical entry order.

use std::cell::Cell;
use std::collections::HashMap;
use std::rc::Rc;

const INDEX_THRESHOLD: usize = 8;
const NO_CACHED_LOOKUP: usize = usize::MAX;

/// Keys are shared so that long-lived handles (Motion::active_path,
/// Animation::active_scene) can hold the map's own key allocation; lookups
/// then settle on a pointer compare instead of a memcmp.
#[derive(Debug, Clone)]
pub struct OrderedMap<V> {
    entries: Vec<(Rc<str>, V)>,
    index: Option<Box<HashMap<Rc<str>, usize>>>,
    last_lookup: Cell<usize>,
}

/// Same string, same allocation — true only for keys handed out by this map.
#[inline]
fn same_allocation(entry: &str, key: &str) -> bool {
    std::ptr::eq(entry.as_ptr(), key.as_ptr()) && entry.len() == key.len()
}

impl<V> OrderedMap<V> {
    pub fn new() -> Self {
        OrderedMap { entries: Vec::new(), index: None, last_lookup: Cell::new(NO_CACHED_LOOKUP) }
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    pub fn contains_key(&self, key: &str) -> bool {
        self.position(key).is_some()
    }

    /// Python dict semantics: overwriting an existing key keeps its position.
    pub fn insert(&mut self, key: impl Into<Rc<str>>, value: V) {
        let key: Rc<str> = key.into();
        if let Some(position) = self.position(&key) {
            self.entries[position].1 = value;
            return;
        }
        let position = self.entries.len();
        if let Some(index) = &mut self.index {
            index.insert(key.clone(), position);
        }
        self.entries.push((key, value));
        self.last_lookup.set(position);
        if self.entries.len() == INDEX_THRESHOLD {
            let index = self
                .entries
                .iter()
                .enumerate()
                .map(|(position, (key, _))| (key.clone(), position))
                .collect();
            self.index = Some(Box::new(index));
        }
    }

    pub fn get(&self, key: &str) -> Option<&V> {
        self.position(key).map(|position| &self.entries[position].1)
    }

    pub fn get_mut(&mut self, key: &str) -> Option<&mut V> {
        let position = self.position(key)?;
        Some(&mut self.entries[position].1)
    }

    pub fn keys(&self) -> impl Iterator<Item = &Rc<str>> {
        self.entries.iter().map(|(k, _)| k)
    }

    /// The map's own handle for `key`, for callers that want later lookups to
    /// hit the pointer fast path.
    pub fn shared_key(&self, key: &str) -> Option<Rc<str>> {
        self.position(key).map(|position| Rc::clone(&self.entries[position].0))
    }

    /// Entry slot for `key`, for callers that read the same entry several times
    /// in a row. Slots stay valid until an entry is removed.
    pub fn slot(&self, key: &str) -> Option<usize> {
        self.position(key)
    }

    pub fn at(&self, slot: usize) -> &V {
        &self.entries[slot].1
    }

    pub fn at_mut(&mut self, slot: usize) -> &mut V {
        &mut self.entries[slot].1
    }

    pub fn key_at(&self, slot: usize) -> &Rc<str> {
        &self.entries[slot].0
    }

    pub fn values(&self) -> impl Iterator<Item = &V> {
        self.entries.iter().map(|(_, v)| v)
    }

    pub fn values_mut(&mut self) -> impl Iterator<Item = &mut V> {
        self.entries.iter_mut().map(|(_, v)| v)
    }

    pub fn iter(&self) -> impl Iterator<Item = (&Rc<str>, &V)> {
        self.entries.iter().map(|(k, v)| (k, v))
    }

    /// Python dict.pop(key, None): removes the entry, preserving the order of
    /// the remaining entries.
    pub fn remove(&mut self, key: &str) -> Option<V> {
        let pos = self.position(key)?;
        if let Some(index) = &mut self.index {
            index.remove(key);
            for indexed_position in index.values_mut() {
                if *indexed_position > pos {
                    *indexed_position -= 1;
                }
            }
        }
        self.last_lookup.set(NO_CACHED_LOOKUP);
        Some(self.entries.remove(pos).1)
    }

    pub fn clear(&mut self) {
        self.entries.clear();
        self.last_lookup.set(NO_CACHED_LOOKUP);
        if let Some(index) = &mut self.index {
            index.clear();
        }
    }

    #[inline]
    fn position(&self, key: &str) -> Option<usize> {
        let cached = self.last_lookup.get();
        if cached < self.entries.len() {
            let entry_key = &self.entries[cached].0;
            if same_allocation(entry_key, key) || **entry_key == *key {
                return Some(cached);
            }
        }
        self.find_position(key)
    }

    // Keep the indexed/linear search out of the cached path, which animation
    // and motion ticks can inline without duplicating the full lookup routine.
    #[inline(never)]
    fn find_position(&self, key: &str) -> Option<usize> {
        let position = match &self.index {
            Some(index) => index.get(key).copied(),
            None => self
                .entries
                .iter()
                .position(|(entry_key, _)| same_allocation(entry_key, key) || **entry_key == *key),
        };
        self.last_lookup.set(position.unwrap_or(NO_CACHED_LOOKUP));
        position
    }
}

impl<V> Default for OrderedMap<V> {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn indexed_maps_preserve_order_and_lookup_after_mutation() {
        let mut map = OrderedMap::new();
        for value in 0..12 {
            map.insert(value.to_string(), value);
        }
        map.insert("3".to_string(), 30);
        assert_eq!(map.get("3"), Some(&30));
        assert_eq!(map.keys().map(|key| &**key).collect::<Vec<_>>()[..5], ["0", "1", "2", "3", "4"]);

        assert_eq!(map.remove("4"), Some(4));
        assert_eq!(map.get("5"), Some(&5));
        assert!(!map.contains_key("4"));

        map.clear();
        map.insert("fresh".to_string(), 99);
        assert_eq!(map.get("fresh"), Some(&99));
    }
}
