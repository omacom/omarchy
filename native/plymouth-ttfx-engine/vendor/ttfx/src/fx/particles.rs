//! ParticlePool / ParticleReset (engine/particles.rs).
//!
//! A pool lives in effect state. The upstream `initializer` / `on_emit`
//! closures are closure parameters receiving (engine, particle slot); a
//! character's membership in its pool's available queue is the CF_POOLED
//! flag (a character belongs to at most one pool), so reclaim's "no
//! duplicate entries" rule is a bit test.

use crate::utils::geometry::Coord;

use super::{Engine, Sym, CF_POOLED};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ParticleReset {
    pub clear_paths: bool,
    pub clear_scenes: bool,
    pub clear_events: bool,
    pub deactivate_path: bool,
    pub deactivate_scene: bool,
    pub reset_appearance: bool,
}

impl Default for ParticleReset {
    fn default() -> Self {
        ParticleReset {
            clear_paths: true,
            clear_scenes: false,
            clear_events: false,
            deactivate_path: true,
            deactivate_scene: true,
            reset_appearance: false,
        }
    }
}

#[derive(Debug, Clone)]
pub struct ParticlePool {
    pub symbols: Vec<Sym>,
    pub max_size: Option<usize>,
    pub coord: Coord,
    /// The available queue: pop and push on the right (Python deque.pop /
    /// append).
    pub available: Vec<u32>,
    /// Every particle owned, active and available.
    pub particles: Vec<u32>,
}

impl ParticlePool {
    /// ParticlePool.__init__ without preallocation (call `preallocate` next,
    /// so the initializer can run against the engine).
    pub fn new(
        symbols: Vec<Sym>,
        max_size: Option<usize>,
        coord: Option<Coord>,
    ) -> Result<Self, String> {
        if symbols.is_empty() {
            return Err("ParticlePool requires at least one symbol.".to_string());
        }
        Ok(ParticlePool {
            symbols,
            max_size,
            coord: coord.unwrap_or(Coord::new(0, 0)),
            available: Vec::new(),
            particles: Vec::new(),
        })
    }

    /// The `initial_count` loop from __init__.
    pub fn preallocate(
        &mut self,
        e: &mut Engine,
        initial_count: usize,
        mut initializer: impl FnMut(&mut Engine, u32),
    ) -> Result<(), String> {
        if self.max_size.is_some_and(|max| max < initial_count) {
            return Err("max_size must be greater than or equal to initial_count.".to_string());
        }
        self.available.reserve(initial_count);
        self.particles.reserve(initial_count);
        for _ in 0..initial_count {
            let particle = self.create_particle(e, None, &mut initializer);
            self.push_available(e, particle);
        }
        Ok(())
    }

    pub fn len(&self) -> usize {
        self.particles.len()
    }

    pub fn is_empty(&self) -> bool {
        self.particles.is_empty()
    }

    fn push_available(&mut self, e: &mut Engine, particle: u32) {
        e.ch.flags[particle as usize] |= CF_POOLED;
        self.available.push(particle);
    }

    /// ParticlePool._create_particle: a random pool symbol unless one is
    /// given.
    fn create_particle(
        &mut self,
        e: &mut Engine,
        symbol: Option<Sym>,
        initializer: &mut impl FnMut(&mut Engine, u32),
    ) -> u32 {
        let symbol = symbol.unwrap_or_else(|| self.symbols[e.rng.choice_index(self.symbols.len())]);
        let particle = e.add_character_sym(symbol, self.coord);
        initializer(e, particle);
        self.particles.push(particle);
        particle
    }

    /// ParticlePool._reset_particle.
    fn reset_particle(e: &mut Engine, slot: u32, reset: ParticleReset) {
        if reset.deactivate_path {
            e.deactivate_path(slot, None);
        }
        if reset.deactivate_scene {
            e.deactivate_scene(slot, None);
        }
        if reset.clear_paths {
            e.paths_clear(slot);
        }
        if reset.clear_scenes {
            e.scenes_clear(slot);
        }
        if reset.clear_events {
            e.event_clear(slot);
        }
        if reset.reset_appearance {
            e.set_appearance(slot, None, None);
        }
    }

    /// ParticlePool.acquire: an available particle (reset, and given the
    /// symbol as its input symbol), else a new one while under max_size.
    pub fn acquire(
        &mut self,
        e: &mut Engine,
        symbol: Option<Sym>,
        reset: ParticleReset,
        mut initializer: impl FnMut(&mut Engine, u32),
    ) -> Option<u32> {
        if let Some(particle) = self.available.pop() {
            e.ch.flags[particle as usize] &= !CF_POOLED;
            Self::reset_particle(e, particle, reset);
            if let Some(symbol) = symbol {
                e.ch.sym[particle as usize] = symbol;
                e.set_appearance(particle, Some(symbol), None);
            }
            return Some(particle);
        }
        if self.max_size.is_some_and(|max| self.particles.len() >= max) {
            return None;
        }
        let particle = self.create_particle(e, symbol, &mut initializer);
        Self::reset_particle(e, particle, reset);
        Some(particle)
    }

    /// ParticlePool.emit: acquire -> position -> on_emit -> visibility ->
    /// activate.
    #[allow(clippy::too_many_arguments)]
    pub fn emit(
        &mut self,
        e: &mut Engine,
        origin: Coord,
        symbol: Option<Sym>,
        visible: bool,
        reset: ParticleReset,
        initializer: impl FnMut(&mut Engine, u32),
        on_emit: impl FnOnce(&mut Engine, u32),
    ) -> Option<u32> {
        let particle = self.acquire(e, symbol, reset, initializer)?;
        e.set_coordinate(particle, origin);
        on_emit(e, particle);
        e.set_visible(particle, visible);
        e.active_insert(particle);
        Some(particle)
    }

    /// ParticlePool.reclaim (idempotent: no duplicate queue entries).
    pub fn reclaim(&mut self, e: &mut Engine, slot: u32, hide: bool, deactivate: bool) {
        if hide {
            e.set_visible(slot, false);
        }
        if deactivate {
            e.deactivate_path(slot, None);
            e.deactivate_scene(slot, None);
        }
        e.active_remove(slot);
        if e.ch.flags[slot as usize] & CF_POOLED == 0 {
            self.push_available(e, slot);
        }
    }

    /// ParticlePool.extend: adopt externally created characters, no reset.
    pub fn extend(&mut self, e: &mut Engine, particles: impl IntoIterator<Item = u32>) {
        for particle in particles {
            self.particles.push(particle);
            self.push_available(e, particle);
        }
    }
}
