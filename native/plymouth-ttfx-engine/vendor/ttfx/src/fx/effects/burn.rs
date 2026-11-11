//! burn on the fx engine (old engine: effects/burn.rs).
//!
//! RNG order is BurnIterator.__init__'s: PrimsSimple's starting coord, the
//! smoke pool's 2000 symbol draws, then build() runs PrimsSimple to
//! completion. Each frame draws randint(2, 4); every finished burn draws
//! random() and may emit a smoke particle (one randint for its target).
//!
//! The burn scene is the same for every plain character, so later ones copy
//! the first one's record (sharing its frames); likewise each smoke symbol's
//! scene. Final color frames are memoized by (symbol, final color).
//!
//! The old engine registers a fresh reclaim callback per emission; all run
//! on SCENE_COMPLETE and reclaim is idempotent (after the first the particle
//! is hidden, inactive and queued), so one registration per particle is
//! equivalent.

use std::collections::HashMap;

use crate::effects::burn::BurnConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::particles::{ParticlePool, ParticleReset};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

/// Callback ids: _emit_smoke at the character's input coordinate, and the
/// pool's reclaim.
const CB_EMIT_SMOKE: u32 = 0;
const CB_RECLAIM_SMOKE: u32 = 1;

const BURN_CHAR_ORDER: [&str; 9] = ["'", ".", "▖", "▙", "█", "▜", "▀", "▝", "."];
const SMOKE_SYMBOLS: [&str; 6] = [".", ",", "'", "`", "#", "*"];
const SMOKE_PARTICLES: usize = 2000;

/// Particle activations fire no events a particle observes.
struct NoHooks;

impl Hooks for NoHooks {}

pub struct Burn {
    config: BurnConfig,
    /// PrimsSimple.char_link_order, consumed from `head`.
    order: Vec<u32>,
    head: usize,
    /// Per slot: the "burn" scene (NONE for characters without one).
    burn_scene: Vec<u32>,
    space: Sym,
    pool: ParticlePool,
    /// Per particle (slot - first_particle): its "smoke" scene, and whether
    /// its reclaim callback is registered.
    first_particle: u32,
    smoke_scene: Vec<u32>,
    reclaim_registered: Vec<bool>,
    smoke_name: Name,
}

impl Burn {
    pub fn new(config: BurnConfig) -> Self {
        Burn {
            config,
            order: Vec::new(),
            head: 0,
            burn_scene: Vec::new(),
            space: Sym(NONE),
            pool: ParticlePool {
                symbols: Vec::new(),
                max_size: None,
                coord: Coord::new(0, 0),
                available: Vec::new(),
                particles: Vec::new(),
            },
            first_particle: 0,
            smoke_scene: Vec::new(),
            reclaim_registered: Vec::new(),
            smoke_name: Name::NONE,
        }
    }

    /// BurnIterator._is_burnable.
    #[inline]
    fn is_burnable(&self, e: &Engine, slot: u32) -> bool {
        *e.ch.sym.at(slot) != self.space
            || (e.existing_color_handling() != ExistingColorHandling::Ignore
                && (e.ch.fg.at(slot).is_some() || e.ch.bg.at(slot).is_some()))
    }

    /// BurnIterator._emit_smoke.
    fn emit_smoke(&mut self, e: &mut Engine, origin: Coord) {
        if e.rng.random() > self.config.smoke_chance {
            return;
        }
        let Burn {
            pool,
            first_particle,
            smoke_scene,
            reclaim_registered,
            smoke_name,
            ..
        } = self;
        let (first_particle, smoke_name) = (*first_particle, *smoke_name);
        // the pool never grows past its preallocation, so the initializer
        // cannot run
        pool.emit(
            e,
            origin,
            None,
            true,
            ParticleReset::default(),
            |_, _| {},
            |e, particle| {
                // on_emit_smoke
                let k = (particle - first_particle) as usize;
                e.scene_reset(smoke_scene[k]);
                let path = e
                    .path_new(particle, 0.5, None, None, 0, false, Name::NONE)
                    .expect("smoke path");
                let rise_target = Coord::new(
                    e.rng.randint(origin.column - 4, origin.column + 4),
                    e.canvas.top + 1,
                );
                e.path_new_waypoint(path, rise_target, None, Name::NONE)
                    .expect("smoke waypoint");
                e.activate_path(&mut NoHooks, particle, path);
                e.activate_scene(&mut NoHooks, particle, smoke_scene[k]);
                // ParticlePool.reclaim_on_event(next_particle, caller="smoke")
                if !reclaim_registered[k] {
                    reclaim_registered[k] = true;
                    e.register_event(
                        particle,
                        Event::SceneComplete,
                        Caller::Scene(smoke_name),
                        Action::Callback(CB_RECLAIM_SMOKE, 0),
                    )
                    .expect("register reclaim");
                }
            },
        );
    }
}

impl Hooks for Burn {
    fn callback(&mut self, e: &mut Engine, slot: u32, id: u32, _arg: i64) {
        match id {
            CB_EMIT_SMOKE => {
                let origin = e.input_coord(slot);
                self.emit_smoke(e, origin);
            }
            CB_RECLAIM_SMOKE => self.pool.reclaim(e, slot, true, true),
            _ => {}
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// SpanningTreeGenerator.get_neighbors(unlinked_only, limit_to_text_boundary):
/// north, east, south, west.
#[inline]
fn unlinked_neighbors(e: &Engine, linked: &[bool], slot: u32, out: &mut [u32; 4]) -> usize {
    let n = e.neighbors(slot);
    let canvas = &e.canvas;
    let mut count = 0;
    for neighbor in [n.north, n.east, n.south, n.west] {
        if neighbor != NONE
            && canvas.coord_is_in_text(e.input_coord(neighbor))
            && !linked[neighbor as usize]
        {
            out[count] = neighbor;
            count += 1;
        }
    }
    count
}

/// PrimsSimple(limit_to_text_boundary=True) run to completion from `start`:
/// char_link_order. Only whether a character has links is ever read.
fn prims_simple(e: &mut Engine, start: u32) -> Vec<u32> {
    let mut linked = vec![false; e.char_count()];
    let mut order = vec![start];
    let mut edges = vec![start];
    let mut neighbors = [NONE; 4];
    let mut next_neighbors = [NONE; 4];
    while !edges.is_empty() {
        let current = edges.remove(e.rng.randrange(0, edges.len() as i64) as usize);
        let count = unlinked_neighbors(e, &linked, current, &mut neighbors);
        if count == 0 {
            continue;
        }
        let next = neighbors[e.rng.randrange(0, count as i64) as usize];
        linked[current as usize] = true;
        linked[next as usize] = true;
        order.push(next);
        if count > 1 {
            edges.push(current);
        }
        if unlinked_neighbors(e, &linked, next, &mut next_neighbors) > 0 {
            edges.push(next);
        }
    }
    order
}

impl Effect for Burn {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        // PrimsSimple::new: the starting character
        let start_coord = e.canvas.random_coord(&mut e.rng, false, true);
        let start = e
            .char_at_input_coord(start_coord)
            .ok_or_else(|| other("Unable to find a starting character.".to_string()))?;

        // the smoke pool, each particle with a "smoke" scene on layer 2
        let smoke_name = e.name("smoke");
        self.smoke_name = smoke_name;
        let smoke_symbols: Vec<Sym> = SMOKE_SYMBOLS.iter().map(|s| e.sym(s)).collect();
        let smoke_spectrum = Gradient::with_steps(
            &[
                Color::from_hex("504F4F").unwrap(),
                Color::from_hex("C7C7C7").unwrap(),
            ],
            9,
            false,
        )
        .map_err(other)?
        .spectrum;
        let mut pool =
            ParticlePool::new(smoke_symbols, Some(SMOKE_PARTICLES), None).map_err(other)?;
        self.first_particle = e.char_count() as u32;
        let mut smoke_scene = Vec::with_capacity(SMOKE_PARTICLES);
        // (symbol, scene) of the first particle with each symbol
        let mut templates: Vec<(Sym, u32)> = Vec::new();
        e.scenes.reserve(SMOKE_PARTICLES + 3 * e.char_count(), 0);
        pool.preallocate(e, SMOKE_PARTICLES, |e, particle| {
            let sym = e.input_sym(particle);
            let scene = match templates.iter().find(|t| t.0 == sym) {
                Some(&(_, template)) => e.scene_copy(particle, template, smoke_name),
                None => {
                    let scene = e.scene_new(particle, smoke_name, false, None, None);
                    for &color in &smoke_spectrum {
                        e.add_frame(scene, sym, 10, Some(ColorPair::new(Some(color), None)), 0)
                            .expect("smoke frame");
                    }
                    templates.push((sym, scene));
                    scene
                }
            };
            smoke_scene.push(scene);
            e.set_layer(particle, 2);
        })
        .map_err(other)?;
        self.pool = pool;
        self.reclaim_registered = vec![false; smoke_scene.len()];
        self.smoke_scene = smoke_scene;

        // build()
        let canvas = e.canvas.clone();
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let fire = Gradient::with_steps(&config.burn_colors, 10, false)
            .map_err(other)?
            .spectrum;
        let fire_last = *fire.last().expect("fire gradient spectrum");

        self.order = prims_simple(e, start);
        self.head = 0;
        self.space = e.sym(" ");

        let burn_name = e.name("burn");
        let burn_syms: Vec<Sym> = BURN_CHAR_ORDER.iter().map(|s| e.sym(s)).collect();
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let always = e.existing_color_handling() == ExistingColorHandling::Always;
        let pair = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[fire_last, c], 8, false)
                .map_err(other)?
                .spectrum)
        };
        let starting = Some(ColorPair::new(Some(config.starting_color), None));
        let mut burn_template = NONE;
        // (symbol, final color) -> the frames of a plain final scene
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        self.burn_scene = vec![NONE; e.char_count()];
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            e.set_visible(slot, true);
            let sym = e.input_sym(slot);
            e.set_appearance(slot, Some(sym), starting);
            let plain = !(always && e.uses_preexisting_colors(slot));
            let burn = if plain && burn_template != NONE {
                e.scene_copy(slot, burn_template, burn_name)
            } else {
                let scene = e.scene_new(slot, burn_name, false, None, None);
                e.apply_gradient(scene, &burn_syms, 4, Some(&fire), None)
                    .map_err(other)?;
                if plain {
                    burn_template = scene;
                }
                scene
            };
            self.burn_scene[slot as usize] = burn;
            // the final color scene takes the next auto id
            let final_scene = e.scene_new(slot, Name::NONE, false, None, None);
            if dynamic {
                let fg = e.input_fg(slot).map(pair).transpose()?;
                let bg = e.input_bg(slot).map(pair).transpose()?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(final_scene, &[sym], 4, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(final_scene, sym, 4, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_color = *final_gradient_mapping
                    .get(&e.input_coord(slot))
                    .expect("gradient mapping");
                match memo.get(&(sym, final_color)) {
                    Some(frames) if plain => e.append_frames(final_scene, frames),
                    _ => {
                        for color in pair(final_color)? {
                            e.add_frame(
                                final_scene,
                                sym,
                                4,
                                Some(ColorPair::new(Some(color), None)),
                                0,
                            )
                            .map_err(other)?;
                        }
                        if plain {
                            memo.insert(
                                (sym, final_color),
                                e.scenes.frames_of(final_scene).to_vec(),
                            );
                        }
                    }
                }
            }
            let final_name = e.scene_name(final_scene);
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(burn_name),
                Action::ActivateScene(final_name),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(burn_name),
                Action::Callback(CB_EMIT_SMOKE, 0),
            )
            .map_err(other)?;
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.head >= self.order.len() && e.active_is_empty() {
            return false;
        }
        for _ in 0..e.rng.randint(2, 4) {
            if self.head < self.order.len() {
                let slot = self.order[self.head];
                self.head += 1;
                if !self.is_burnable(e, slot) {
                    continue;
                }
                let scene = self.burn_scene[slot as usize];
                e.activate_scene(self, slot, scene);
                e.active_insert(slot);
            }
        }
        e.update(self);
        true
    }
}
