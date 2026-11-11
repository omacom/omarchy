//! laseretch on the fx engine (old engine: effects/laseretch.rs).
//!
//! build() makes every character's spawn scene, then (for the "algorithm"
//! pattern) runs RecursiveBacktracker from a random text coordinate; its link
//! order is the etch order. A character-group pattern etches nothing (the
//! upstream dead branch the old engine reproduces). The laser follows: the
//! spark pool (2000 particles, each reclaimed when its spark scene completes;
//! particles the pool creates later never are, as in the old engine) and one
//! beam character per canvas row up the diagonal from (0, 0).
//!
//! Spawn frames are memoized by (symbol, final color), spark frames by symbol.

use std::collections::HashMap;

use crate::effects::laseretch::{EtchPattern, LaserEtchConfig};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::particles::{ParticlePool, ParticleReset};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym, NONE};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

/// Callback id: sparks_pool.reclaim(spark, hide=True, deactivate=True).
const CB_RECLAIM_SPARK: u32 = 0;
const SPARK_COUNT: usize = 2000;

pub struct LaserEtch {
    config: LaserEtchConfig,
    /// The etch order and its head (pending_chars.pop(0)).
    pending: Vec<u32>,
    head: usize,
    char_delay: i64,
    space: Sym,
    /// The laser: its beam, position and spark pool (taken out while it
    /// emits, as the old engine takes the laser).
    beam: Vec<u32>,
    position: Coord,
    pool: Option<ParticlePool>,
    spark: Name,
    spark_frames: Vec<(Sym, Vec<Frame>)>,
}

impl LaserEtch {
    pub fn new(config: LaserEtchConfig) -> Self {
        LaserEtch {
            config,
            pending: Vec::new(),
            head: 0,
            char_delay: 0,
            space: Sym(NONE),
            beam: Vec::new(),
            position: Coord::new(0, 0),
            pool: None,
            spark: Name::NONE,
            spark_frames: Vec::new(),
        }
    }

    fn pop_pending(&mut self) -> Option<u32> {
        let slot = self.pending.get(self.head).copied()?;
        self.head += 1;
        Some(slot)
    }

    /// Laser.__init__ (+ _make_sparks_pool). The pool is created before the
    /// beam characters, matching upstream's character_id allocation order.
    fn make_laser(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let laser_gradient = Gradient::new(&config.laser_gradient_stops, &[6], true, true)
            .map_err(other)?
            .spectrum;
        let spark_gradient = Gradient::new(&config.spark_gradient_stops, &[3, 8], false, false)
            .map_err(other)?
            .spectrum;

        // Laser._make_sparks_pool
        self.spark = e.name("spark");
        let symbols: Vec<Sym> = [".", ",", "*"].iter().map(|s| e.sym(s)).collect();
        for &sym in &symbols {
            let frames = spark_gradient
                .iter()
                .map(|&color| {
                    let info = VisualInfo {
                        sym,
                        fg: Some(color),
                        bg: None,
                        attrs: HAS_COLORS,
                    };
                    Frame {
                        visual: e.visuals.make(&e.symbols, info),
                        duration: config.spark_cooling_frames as u32,
                    }
                })
                .collect();
            self.spark_frames.push((sym, frames));
        }
        let mut pool = ParticlePool::new(symbols, None, None).map_err(other)?;
        let (spark, spark_frames) = (self.spark, &self.spark_frames);
        pool.preallocate(e, SPARK_COUNT, |e, slot| {
            initialize_spark(e, slot, spark, spark_frames)
        })
        .map_err(other)?;
        for &slot in &pool.particles {
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(spark),
                Action::Callback(CB_RECLAIM_SPARK, 0),
            )
            .map_err(other)?;
        }
        self.pool = Some(pool);

        // beam characters up the diagonal from (0, 0), the looping laser
        // gradient rotated left once per character
        let laser = e.name("laser");
        let len = laser_gradient.len();
        let mut row: i64 = 0;
        while row <= e.canvas.top {
            let slot = e.add_character(if row == 0 { "*" } else { "/" }, Coord::new(row, row));
            e.set_layer(slot, 2);
            e.set_visible(slot, true);
            self.beam.push(slot);
            let scene = e.scene_new(slot, laser, true, None, None);
            let sym = e.input_sym(slot);
            let r = row as usize % len.max(1);
            for &color in laser_gradient[r..].iter().chain(&laser_gradient[..r]) {
                e.add_frame(scene, sym, 3, Some(ColorPair::new(Some(color), None)), 0)
                    .map_err(other)?;
            }
            e.activate_scene(self, slot, scene);
            row += 1;
        }
        Ok(())
    }

    /// Laser.reposition: the beam up the diagonal from the target, then
    /// emit_sparks(1).
    fn reposition(&mut self, e: &mut Engine, target: Coord) {
        let mut pool = self.pool.take().expect("laser missing");
        self.position = target;
        for (k, &slot) in self.beam.iter().enumerate() {
            e.set_coordinate(
                slot,
                Coord::new(target.column + k as i64, target.row + k as i64),
            );
        }
        // ParticlePool.emit: acquire -> position -> setup_spark_path ->
        // visibility -> activate
        let (spark, spark_frames) = (self.spark, &self.spark_frames);
        let acquired = pool.acquire(e, None, ParticleReset::default(), |e, slot| {
            initialize_spark(e, slot, spark, spark_frames)
        });
        if let Some(slot) = acquired {
            let position = self.position;
            e.set_coordinate(slot, position);
            // setup_spark_path
            e.set_coordinate(slot, position);
            let path = e
                .path_new(slot, 0.3, Some(Easing::OutSine), None, 0, false, Name::NONE)
                .expect("spark path");
            let column = e.rng.randint(position.column - 20, position.column + 20);
            let fall_target = Coord::new(column, e.canvas.bottom);
            let control = Coord::new(column, position.row + e.rng.randint(-10, 20));
            e.path_new_waypoint(path, fall_target, Some(&[control]), Name::NONE)
                .expect("spark waypoint");
            e.activate_path(self, slot, path);
            e.activate_scene_name(self, slot, spark);
            e.set_visible(slot, true);
            e.active_insert(slot);
        }
        self.pool = Some(pool);
    }
}

/// Laser._make_sparks_pool's initialize_sparks: layer 2 and the "spark"
/// cooling scene.
fn initialize_spark(e: &mut Engine, slot: u32, spark: Name, spark_frames: &[(Sym, Vec<Frame>)]) {
    e.set_layer(slot, 2);
    let scene = e.scene_new(slot, spark, false, None, None);
    let sym = e.input_sym(slot);
    let (_, frames) = spark_frames
        .iter()
        .find(|(s, _)| *s == sym)
        .expect("pool symbol");
    e.add_frames_visual(scene, frames).expect("spark frame");
}

impl Hooks for LaserEtch {
    fn callback(&mut self, e: &mut Engine, slot: u32, id: u32, _arg: i64) {
        if id == CB_RECLAIM_SPARK {
            if let Some(pool) = self.pool.as_mut() {
                pool.reclaim(e, slot, true, true);
            }
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for LaserEtch {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        // LaserEtchIterator.build
        let config = self.config.clone();
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
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let spawn = e.name("spawn");
        let caret = e.sym("^");
        self.space = e.sym(" ");
        let yellow = Color::from_hex("ffe680").unwrap();
        let white = Color::from_hex("ffffff").unwrap();
        let cool = |stops: &[Color]| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(stops, 8, false)
                .map_err(other)?
                .spectrum)
        };
        // dynamic: one cool gradient for all; else the last final color and
        // its cool gradient (the cool stops, then the final color)
        let dynamic_cool = if dynamic {
            cool(&config.cool_gradient_stops)?
        } else {
            Vec::new()
        };
        let mut last_cool: Option<(Color, Vec<Color>)> = None;
        let mut cool_stops = config.cool_gradient_stops.clone();
        cool_stops.push(white);
        // (symbol, final color) -> the "^" + cool frames of a plain scene
        let mut memo: HashMap<(Sym, Option<Color>), Vec<Frame>, FxBuild> = HashMap::default();
        let caret_visual = e.visuals.make(
            &e.symbols,
            VisualInfo {
                sym: caret,
                fg: Some(yellow),
                bg: None,
                attrs: HAS_COLORS,
            },
        );

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        e.scenes.reserve(characters.len(), characters.len() * 10);
        for &slot in &characters {
            let sym = e.input_sym(slot);
            let (key, spectrum) = if dynamic {
                (None, &dynamic_cool)
            } else {
                let mapped = *final_gradient_mapping.get(&e.input_coord(slot)).unwrap();
                if last_cool.as_ref().is_none_or(|(c, _)| *c != mapped) {
                    *cool_stops.last_mut().unwrap() = mapped;
                    last_cool = Some((mapped, cool(&cool_stops)?));
                }
                (Some(mapped), &last_cool.as_ref().unwrap().1)
            };
            let scene = e.scene_new(slot, spawn, false, None, None);
            let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
            let frames = memo.entry((sym, key)).or_insert_with(|| {
                let mut frames = Vec::with_capacity(spectrum.len() + 1);
                frames.push(Frame {
                    visual: caret_visual,
                    duration: 3,
                });
                for &color in spectrum {
                    let info = VisualInfo {
                        sym,
                        fg: Some(color),
                        bg: None,
                        attrs: HAS_COLORS,
                    };
                    frames.push(Frame {
                        visual: e.visuals.make(&e.symbols, info),
                        duration: 3,
                    });
                }
                frames
            });
            if plain {
                e.append_frames(scene, frames);
            } else {
                e.add_frames_visual(scene, frames).map_err(other)?;
            }
            if dynamic {
                let cool_last = *spectrum.last().unwrap();
                let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                let pair = |c: Color| cool(&[cool_last, c]);
                if fg.is_some() || bg.is_some() {
                    let fg = fg.map(pair).transpose()?;
                    let bg = bg.map(pair).transpose()?;
                    e.apply_gradient(scene, &[sym], 3, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    let white_cooldown = pair(white)?;
                    e.apply_gradient(scene, &[sym], 3, Some(&white_cooldown), None)
                        .map_err(other)?;
                    e.add_frame(scene, sym, 3, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            }
            e.activate_scene(self, slot, scene);
        }

        if config.etch_pattern == EtchPattern::Algorithm {
            self.pending = recursive_backtracker(e)?;
        }

        // LaserEtchIterator.__init__ tail
        self.head = 0;
        self.char_delay = 0;
        self.make_laser(e)?;
        for &slot in &self.beam {
            e.active_insert(slot);
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.head >= self.pending.len() && e.active_is_empty() {
            return false;
        }
        if self.char_delay == 0 {
            for _ in 0..self.config.etch_speed {
                let Some(mut next) = self.pop_pending() else {
                    break;
                };
                while e.input_sym(next) == self.space
                    && e.input_fg(next).is_none()
                    && e.input_bg(next).is_none()
                {
                    match self.pop_pending() {
                        Some(slot) => next = slot,
                        None => break,
                    }
                }
                e.set_visible(next, true);
                e.active_insert(next);
                let target = e.input_coord(next);
                self.reposition(e, target);
            }
            self.char_delay = self.config.etch_delay;
        } else {
            self.char_delay -= 1;
        }
        if self.head < self.pending.len() {
            for &slot in &self.beam {
                e.active_insert(slot);
            }
        } else {
            // Laser.disable
            for &slot in &self.beam {
                e.set_visible(slot, false);
            }
        }
        e.update(self);
        true
    }
}

/// RecursiveBacktracker(starting_char=None, limit_to_text_boundary=True) run
/// to completion: its char_link_order. Links are only ever tested for
/// emptiness, and a character gains its first link exactly when it is first
/// linked to or (the start) links out, before it can be a neighbor candidate,
/// so a visited mark stands in for them.
fn recursive_backtracker(e: &mut Engine) -> Result<Vec<u32>, EngineError> {
    let coord = e.canvas.random_coord(&mut e.rng, false, true);
    let start = e
        .char_at_input_coord(coord)
        .ok_or_else(|| other("Unable to find a starting character.".to_string()))?;
    let mut visited = vec![false; e.char_count()];
    visited[start as usize] = true;
    let mut order = vec![start];
    let mut stack = vec![start];
    let mut current = start;
    let canvas = &e.canvas;
    while !stack.is_empty() {
        let n = e.ch.nbr[current as usize];
        let mut unvisited = [0u32; 4];
        let mut count = 0;
        for neighbor in [n.north, n.east, n.south, n.west] {
            if neighbor != NONE
                && canvas.coord_is_in_text(e.ch.input_coord[neighbor as usize])
                && !visited[neighbor as usize]
            {
                unvisited[count] = neighbor;
                count += 1;
            }
        }
        if count > 0 {
            let next = unvisited[e.rng.choice_index(count)];
            visited[next as usize] = true;
            order.push(next);
            stack.push(next);
            current = next;
        } else {
            stack.pop();
            if let Some(&top) = stack.last() {
                current = top;
            }
        }
    }
    Ok(order)
}
