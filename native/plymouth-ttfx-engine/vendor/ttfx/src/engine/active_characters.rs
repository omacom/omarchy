//! Dense ordered set for active arena characters.
//!
//! `CharId` is a dense arena index, so a packed bitmap avoids the allocation
//! and pointer chasing of a tree while its set bits naturally iterate in
//! ascending id order.

use std::iter::FromIterator;

use crate::engine::character::CharId;

const WORD_BITS: usize = u64::BITS as usize;
const PROMOTE_LEN: usize = 128;
const DEMOTE_LEN: usize = 64;

#[derive(Clone, Default)]
pub struct ActiveCharacters {
    sparse: Vec<CharId>,
    words: Vec<u64>,
    len: usize,
    dense: bool,
}

impl ActiveCharacters {
    #[inline]
    pub const fn new() -> Self {
        Self {
            sparse: Vec::new(),
            words: Vec::new(),
            len: 0,
            dense: false,
        }
    }

    #[inline]
    pub fn len(&self) -> usize {
        self.len
    }

    #[inline]
    pub fn is_empty(&self) -> bool {
        self.len == 0
    }

    #[inline]
    pub fn clear(&mut self) {
        self.sparse.clear();
        self.words.clear();
        self.len = 0;
        self.dense = false;
    }

    #[inline]
    pub fn contains(&self, id: &CharId) -> bool {
        if !self.dense {
            return self.sparse.binary_search(id).is_ok();
        }
        let index = id.0 as usize;
        self.words
            .get(index / WORD_BITS)
            .is_some_and(|word| word & (1 << (index % WORD_BITS)) != 0)
    }

    #[inline]
    pub fn insert(&mut self, id: CharId) -> bool {
        if !self.dense {
            let Err(index) = self.sparse.binary_search(&id) else {
                return false;
            };
            self.sparse.insert(index, id);
            self.len += 1;
            if self.len == PROMOTE_LEN {
                self.promote();
            }
            return true;
        }
        let index = id.0 as usize;
        let word_index = index / WORD_BITS;
        if word_index >= self.words.len() {
            self.words.resize(word_index + 1, 0);
        }
        let bit = 1 << (index % WORD_BITS);
        let word = &mut self.words[word_index];
        if *word & bit != 0 {
            return false;
        }
        *word |= bit;
        self.len += 1;
        true
    }

    #[inline]
    pub fn remove(&mut self, id: &CharId) -> bool {
        if !self.dense {
            let Ok(index) = self.sparse.binary_search(id) else {
                return false;
            };
            self.sparse.remove(index);
            self.len -= 1;
            return true;
        }
        let index = id.0 as usize;
        let word_index = index / WORD_BITS;
        let Some(word) = self.words.get_mut(word_index) else {
            return false;
        };
        let bit = 1 << (index % WORD_BITS);
        if *word & bit == 0 {
            return false;
        }
        *word &= !bit;
        self.len -= 1;
        if word_index + 1 == self.words.len() {
            while self.words.last() == Some(&0) {
                self.words.pop();
            }
        }
        if self.len == DEMOTE_LEN {
            self.demote();
        }
        true
    }

    #[inline]
    pub fn iter(&self) -> Iter<'_> {
        Iter {
            inner: if self.dense {
                IterInner::Dense {
                    words: self.words.iter().enumerate(),
                    remaining: 0,
                    word_index: 0,
                }
            } else {
                IterInner::Sparse(self.sparse.iter())
            },
            len: self.len,
        }
    }

    /// Retains elements in the same ascending order in which `BTreeSet`
    /// invokes its predicate.
    pub fn retain(&mut self, mut keep: impl FnMut(&CharId) -> bool) {
        if !self.dense {
            self.sparse.retain(|id| keep(id));
            self.len = self.sparse.len();
            return;
        }
        let mut removed = 0;
        for (word_index, word) in self.words.iter_mut().enumerate() {
            let mut candidates = *word;
            while candidates != 0 {
                let bit_index = candidates.trailing_zeros() as usize;
                let bit = 1 << bit_index;
                let id = CharId((word_index * WORD_BITS + bit_index) as u32);
                if !keep(&id) {
                    *word &= !bit;
                    removed += 1;
                }
                candidates &= candidates - 1;
            }
        }
        self.len -= removed;
        while self.words.last() == Some(&0) {
            self.words.pop();
        }
        if self.len <= DEMOTE_LEN {
            self.demote();
        }
    }

    fn promote(&mut self) {
        let word_len = self
            .sparse
            .last()
            .map_or(0, |id| id.0 as usize / WORD_BITS + 1);
        self.words.clear();
        self.words.resize(word_len, 0);
        for id in self.sparse.drain(..) {
            let index = id.0 as usize;
            self.words[index / WORD_BITS] |= 1 << (index % WORD_BITS);
        }
        self.dense = true;
    }

    fn demote(&mut self) {
        self.sparse.clear();
        self.sparse.reserve(self.len);
        for (word_index, &word) in self.words.iter().enumerate() {
            let mut remaining = word;
            while remaining != 0 {
                let bit_index = remaining.trailing_zeros() as usize;
                self.sparse
                    .push(CharId((word_index * WORD_BITS + bit_index) as u32));
                remaining &= remaining - 1;
            }
        }
        self.words.clear();
        self.dense = false;
    }
}

pub struct Iter<'a> {
    inner: IterInner<'a>,
    len: usize,
}

enum IterInner<'a> {
    Sparse(std::slice::Iter<'a, CharId>),
    Dense {
        words: std::iter::Enumerate<std::slice::Iter<'a, u64>>,
        remaining: u64,
        word_index: usize,
    },
}

impl Iterator for Iter<'_> {
    type Item = CharId;

    #[inline]
    fn next(&mut self) -> Option<Self::Item> {
        let id = match &mut self.inner {
            IterInner::Sparse(ids) => ids.next().copied(),
            IterInner::Dense {
                words,
                remaining,
                word_index,
            } => loop {
                if *remaining != 0 {
                    let bit_index = remaining.trailing_zeros() as usize;
                    *remaining &= *remaining - 1;
                    break Some(CharId((*word_index * WORD_BITS + bit_index) as u32));
                }
                let Some((next_word_index, &word)) = words.next() else {
                    break None;
                };
                *word_index = next_word_index;
                *remaining = word;
            },
        };
        if id.is_some() {
            self.len -= 1;
        }
        id
    }

    #[inline]
    fn size_hint(&self) -> (usize, Option<usize>) {
        (self.len, Some(self.len))
    }
}

impl ExactSizeIterator for Iter<'_> {}

impl std::iter::FusedIterator for Iter<'_> {}

impl std::fmt::Debug for ActiveCharacters {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.debug_set().entries(self.iter()).finish()
    }
}

impl PartialEq for ActiveCharacters {
    fn eq(&self, other: &Self) -> bool {
        self.len == other.len && self.iter().eq(other.iter())
    }
}

impl Eq for ActiveCharacters {}

impl<'a> IntoIterator for &'a ActiveCharacters {
    type Item = CharId;
    type IntoIter = Iter<'a>;

    #[inline]
    fn into_iter(self) -> Self::IntoIter {
        self.iter()
    }
}

impl Extend<CharId> for ActiveCharacters {
    fn extend<T: IntoIterator<Item = CharId>>(&mut self, iter: T) {
        for id in iter {
            self.insert(id);
        }
    }
}

impl FromIterator<CharId> for ActiveCharacters {
    fn from_iter<T: IntoIterator<Item = CharId>>(iter: T) -> Self {
        let mut characters = Self::new();
        characters.extend(iter);
        characters
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeSet;

    #[test]
    fn preserves_order_and_set_semantics_across_word_boundaries() {
        let mut active: ActiveCharacters =
            [CharId(130), CharId(1), CharId(64), CharId(63), CharId(1)]
                .into_iter()
                .collect();
        assert_eq!(active.len(), 4);
        assert_eq!(
            active.iter().collect::<Vec<_>>(),
            [CharId(1), CharId(63), CharId(64), CharId(130)]
        );
        assert!(active.contains(&CharId(64)));
        assert!(!active.insert(CharId(64)));
        assert!(active.remove(&CharId(130)));
        assert!(!active.remove(&CharId(130)));

        let mut visited = Vec::new();
        active.retain(|id| {
            visited.push(*id);
            id.0 % 2 == 1
        });
        assert_eq!(visited, [CharId(1), CharId(63), CharId(64)]);
        assert_eq!(active.iter().collect::<Vec<_>>(), [CharId(1), CharId(63)]);

        active.clear();
        assert!(active.is_empty());
        assert_eq!(active.iter().len(), 0);
    }

    #[test]
    fn matches_btree_set_through_mixed_operations() {
        let mut active = ActiveCharacters::new();
        let mut reference = BTreeSet::new();
        let mut state = 0x9e37_79b9_u32;

        for step in 0..10_000_u32 {
            state = state.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
            let id = CharId(state % 4096);
            match state >> 29 {
                0..=3 => assert_eq!(active.insert(id), reference.insert(id)),
                4..=5 => assert_eq!(active.remove(&id), reference.remove(&id)),
                6 => assert_eq!(active.contains(&id), reference.contains(&id)),
                _ => {
                    let modulus = step % 7 + 2;
                    active.retain(|id| id.0 % modulus != 0);
                    reference.retain(|id| id.0 % modulus != 0);
                }
            }

            if step % 97 == 0 {
                assert_eq!(active.len(), reference.len());
                assert_eq!(active.is_empty(), reference.is_empty());
                assert_eq!(
                    active.iter().collect::<Vec<_>>(),
                    reference.iter().copied().collect::<Vec<_>>()
                );
            }
            if step % 997 == 0 {
                active.clear();
                reference.clear();
            }
        }
    }
}
