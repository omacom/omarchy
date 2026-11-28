//! ParticlePool / ParticleReset, ported from engine/effect_support/particles.py.
//!
//! The pool lives in effect state and operates through &mut EngineCtx. The
//! upstream `initializer` / `on_emit` closures become explicit closure
//! parameters receiving (ctx, particle_id) — for new-particle setup the effect
//! passes its initializer to the creating call. Reclaim-on-event is wired by
//! the effect as a Callback action dispatching back to `reclaim` (plan.md §4.2).

use std::collections::VecDeque;

use crate::engine::character::CharId;
use crate::engine::ctx::EngineCtx;
use crate::utils::geometry::Coord;

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
    pub symbols: Vec<String>,
    pub max_size: Option<usize>,
    pub coord: Coord,
    /// Available queue: pop from the RIGHT (Python deque.pop), push right.
    pub available: VecDeque<CharId>,
    /// All owned particles, active and available.
    pub particles: Vec<CharId>,
}

impl ParticlePool {
    /// ParticlePool.__init__ (without preallocation — call `preallocate` after
    /// construction so the initializer closure can run against ctx).
    pub fn new(symbols: Vec<String>, max_size: Option<usize>, coord: Option<Coord>) -> Result<Self, String> {
        if symbols.is_empty() {
            return Err("ParticlePool requires at least one symbol.".to_string());
        }
        Ok(ParticlePool {
            symbols,
            max_size,
            coord: coord.unwrap_or(Coord::new(0, 0)),
            available: VecDeque::new(),
            particles: Vec::new(),
        })
    }

    /// The `initial_count` loop from __init__.
    pub fn preallocate(
        &mut self,
        ctx: &mut EngineCtx,
        initial_count: usize,
        mut initializer: impl FnMut(&mut EngineCtx, CharId),
    ) -> Result<(), String> {
        if let Some(max) = self.max_size {
            if max < initial_count {
                return Err("max_size must be greater than or equal to initial_count.".to_string());
            }
        }
        for _ in 0..initial_count {
            let particle = self.create_particle(ctx, None, &mut initializer);
            self.available.push_back(particle);
        }
        Ok(())
    }

    pub fn len(&self) -> usize {
        self.particles.len()
    }

    pub fn is_empty(&self) -> bool {
        self.particles.is_empty()
    }

    /// ParticlePool._create_particle.
    fn create_particle(
        &mut self,
        ctx: &mut EngineCtx,
        symbol: Option<&str>,
        initializer: &mut impl FnMut(&mut EngineCtx, CharId),
    ) -> CharId {
        let symbol = match symbol {
            Some(s) => s.to_string(),
            None => ctx.rng.choice(&self.symbols).clone(),
        };
        let particle = ctx.terminal.add_character(&symbol, self.coord);
        initializer(ctx, particle);
        self.particles.push(particle);
        particle
    }

    /// ParticlePool._reset_particle.
    fn reset_particle(ctx: &mut EngineCtx, id: CharId, reset: ParticleReset) {
        let ch = &mut ctx.terminal.arena[id.0 as usize];
        if reset.deactivate_path {
            ch.motion.deactivate_path(None);
        }
        if reset.deactivate_scene {
            ch.animation.active_scene = None;
        }
        if reset.clear_paths {
            ch.motion.paths.clear();
        }
        if reset.clear_scenes {
            ch.animation.scenes.clear();
        }
        if reset.clear_events {
            ch.event_handler.clear();
        }
        if reset.reset_appearance {
            let input_symbol = ch.input_symbol.clone();
            let uses = ch.uses_input_preexisting_colors;
            ch.animation.set_appearance(&input_symbol, uses, Some(&input_symbol.clone()), None);
        }
    }

    /// ParticlePool.acquire.
    pub fn acquire(
        &mut self,
        ctx: &mut EngineCtx,
        symbol: Option<&str>,
        reset: ParticleReset,
        mut initializer: impl FnMut(&mut EngineCtx, CharId),
    ) -> Option<CharId> {
        if let Some(particle) = self.available.pop_back() {
            Self::reset_particle(ctx, particle, reset);
            if let Some(symbol) = symbol {
                let ch = &mut ctx.terminal.arena[particle.0 as usize];
                ch.input_symbol = symbol.to_string();
                let uses = ch.uses_input_preexisting_colors;
                ch.animation.set_appearance(symbol, uses, Some(symbol), None);
            }
            return Some(particle);
        }
        if let Some(max) = self.max_size {
            if self.particles.len() >= max {
                return None;
            }
        }
        let particle = self.create_particle(ctx, symbol, &mut initializer);
        Self::reset_particle(ctx, particle, reset);
        Some(particle)
    }

    /// ParticlePool.emit: acquire -> position -> on_emit -> visibility -> activate.
    #[allow(clippy::too_many_arguments)]
    pub fn emit(
        &mut self,
        ctx: &mut EngineCtx,
        origin: Coord,
        symbol: Option<&str>,
        visible: bool,
        reset: ParticleReset,
        initializer: impl FnMut(&mut EngineCtx, CharId),
        on_emit: impl FnOnce(&mut EngineCtx, CharId),
    ) -> Option<CharId> {
        let particle = self.acquire(ctx, symbol, reset, initializer)?;
        ctx.terminal.arena[particle.0 as usize].motion.set_coordinate(origin);
        on_emit(ctx, particle);
        ctx.terminal.set_character_visibility(particle, visible);
        ctx.active_characters.insert(particle);
        Some(particle)
    }

    /// ParticlePool.reclaim (idempotent: no duplicate queue entries).
    pub fn reclaim(&mut self, ctx: &mut EngineCtx, id: CharId, hide: bool, deactivate: bool) {
        if hide {
            ctx.terminal.set_character_visibility(id, false);
        }
        if deactivate {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.motion.deactivate_path(None);
            ch.animation.active_scene = None;
        }
        ctx.active_characters.remove(&id);
        if !self.available.contains(&id) {
            self.available.push_back(id);
        }
    }

    /// ParticlePool.extend: adopt externally created characters, no reset.
    pub fn extend(&mut self, particles: impl IntoIterator<Item = CharId>) {
        for particle in particles {
            self.particles.push(particle);
            self.available.push_back(particle);
        }
    }
}
