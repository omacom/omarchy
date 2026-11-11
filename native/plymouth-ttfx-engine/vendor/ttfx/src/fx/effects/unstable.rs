//! unstable on the fx engine (old engine: effects/unstable.rs).
//!
//! Build walks the characters top to bottom, left to right, drawing each
//! one's edge target and then its jumbled start in the old engine's order.
//! The jumbled start is Vec::remove(randint(0, len - 1)) on the remaining
//! input coordinates; an order-statistic Fenwick tree picks the same element
//! without the O(n) shifts. That character order never changes (the sort
//! draws nothing), so it is fetched once.
//!
//! The old engine renders an offset rumble frame mid-next_frame and then
//! moves the characters back; here the run loop renders after next_frame
//! returns, so the move back is deferred to the start of the next call.
//!
//! Rumble frames step every character through update (no path or event
//! makes the order or the pruning observable). Explosion and reassembly tick
//! the active set in ascending slot order and prune by the effect's own rule
//! (not update's): a tick only touches its own character, so ticking and
//! checking in one pass equals the old engine's two passes.

use std::collections::HashMap;

use crate::effects::unstable::UnstableConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Rumble,
    Explosion,
    Reassembly,
}

const MAX_RUMBLE_STEPS: i64 = 150;

pub struct Unstable {
    config: UnstableConfig,
    phase: Phase,
    /// The characters, top to bottom, left to right.
    order: Vec<u32>,
    /// Per slot: the jumbled start, the explosion target, the explosion and
    /// reassembly paths and the final scene.
    jumbled: Vec<Coord>,
    target: Vec<Coord>,
    explosion: Vec<u32>,
    reassembly: Vec<u32>,
    final_scene: Vec<u32>,
    explosion_hold_time: i64,
    current_rumble_steps: i64,
    rumble_mod_delay: i64,
    /// An offset rumble frame was rendered: move everyone back first.
    restore_pending: bool,
}

impl Unstable {
    pub fn new(config: UnstableConfig) -> Self {
        Unstable {
            config,
            phase: Phase::Rumble,
            order: Vec::new(),
            jumbled: Vec::new(),
            target: Vec::new(),
            explosion: Vec::new(),
            reassembly: Vec::new(),
            final_scene: Vec::new(),
            explosion_hold_time: 30,
            current_rumble_steps: 0,
            rumble_mod_delay: 18,
            restore_pending: false,
        }
    }

    /// Tick every active character in ascending slot order and drop the ones
    /// that reached the phase's waypoint (and, reassembling, finished their
    /// scene).
    fn tick_and_retain(&mut self, e: &mut Engine, reassembly: bool) {
        for w in 0..e.active.bits.len() {
            let mut m = *e.active.bits.at(w);
            while m != 0 {
                let slot = (w as u32) << 6 | m.trailing_zeros();
                m &= m - 1;
                e.tick(self, slot);
                let coord = e.coord(slot);
                let done = if reassembly {
                    coord == e.input_coord(slot) && e.scene_is_complete(slot)
                } else {
                    coord == *self.target.at(slot)
                };
                if done {
                    e.active_remove(slot);
                }
            }
        }
    }
}

impl Hooks for Unstable {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// An order-statistic Fenwick tree over n present elements.
struct Fenwick {
    tree: Vec<u32>,
    top: usize,
}

impl Fenwick {
    fn new(n: usize) -> Self {
        let mut tree = vec![0u32; n + 1];
        for (i, t) in tree.iter_mut().enumerate().skip(1) {
            *t = (i & i.wrapping_neg()) as u32;
        }
        let top = if n == 0 {
            0
        } else {
            1 << (usize::BITS - 1 - n.leading_zeros())
        };
        Fenwick { tree, top }
    }

    /// The index of the k-th (0-based) remaining element, which is removed.
    fn take(&mut self, k: usize) -> usize {
        let n = self.tree.len() - 1;
        let mut rest = k as u32 + 1;
        let mut pos = 0;
        let mut step = self.top;
        while step != 0 {
            let next = pos + step;
            if next <= n && self.tree[next] < rest {
                pos = next;
                rest -= self.tree[next];
            }
            step >>= 1;
        }
        let mut i = pos + 1;
        while i <= n {
            self.tree[i] -= 1;
            i += i & i.wrapping_neg();
        }
        pos
    }
}

impl Effect for Unstable {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let canvas = e.canvas.clone();
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
        let gray = Color::from_hex("808080").unwrap();
        let unstable = config.unstable_color;
        let pair = |a: Color, b: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[a, b], 12, false)
                .map_err(other)?
                .spectrum)
        };
        let explosion = e.name("explosion");
        let reassembly = e.name("reassembly");
        let rumble = e.name("rumble");
        let final_ = e.name("final");

        let order = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        let n = e.char_count();
        self.jumbled = vec![Coord::new(0, 0); n];
        self.target = vec![Coord::new(0, 0); n];
        self.explosion = vec![0; n];
        self.reassembly = vec![0; n];
        self.final_scene = vec![0; n];
        let mut fenwick = Fenwick::new(order.len());
        // (symbol, final color) -> the rumble and final frames of plain scenes
        type RumbleFinal = (Vec<Frame>, Vec<Frame>);
        let mut memo: HashMap<(Sym, Color), RumbleFinal, FxBuild> = HashMap::default();
        for (k, &slot) in order.iter().enumerate() {
            let (col, row) = match e.rng.randint(0, 3) {
                0 => (canvas.left, canvas.random_row(&mut e.rng, false)),
                1 => (canvas.right, canvas.random_row(&mut e.rng, false)),
                2 => (canvas.random_column(&mut e.rng, false), canvas.bottom),
                _ => (canvas.random_column(&mut e.rng, false), canvas.top),
            };
            let target = Coord::new(col, row);
            let remaining = (order.len() - k) as i64;
            let pick = fenwick.take(e.rng.randint(0, remaining - 1) as usize);
            let jumbled = e.input_coord(order[pick]);
            let s = slot as usize;
            self.jumbled[s] = jumbled;
            self.target[s] = target;
            e.set_coordinate(slot, jumbled);
            let path = e
                .path_new(
                    slot,
                    config.explosion_speed,
                    Some(config.explosion_ease),
                    None,
                    0,
                    false,
                    explosion,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, target, None, Name::NONE)
                .map_err(other)?;
            self.explosion[s] = path;
            let path = e
                .path_new(
                    slot,
                    config.reassembly_speed,
                    Some(config.reassembly_ease),
                    None,
                    0,
                    false,
                    reassembly,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, e.input_coord(slot), None, Name::NONE)
                .map_err(other)?;
            self.reassembly[s] = path;

            let sym = e.input_sym(slot);
            let rumble_scene = e.scene_new(slot, rumble, false, None, None);
            if dynamic {
                let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                let start_fg = fg.unwrap_or(gray);
                let fg_spectrum = pair(start_fg, unstable)?;
                let bg_spectrum = bg.map(|bg| pair(bg, unstable)).transpose()?;
                e.apply_gradient(
                    rumble_scene,
                    &[sym],
                    10,
                    Some(&fg_spectrum),
                    bg_spectrum.as_deref(),
                )
                .map_err(other)?;
                let scene = e.scene_new(slot, final_, false, None, None);
                self.final_scene[s] = scene;
                if fg.is_none() && bg.is_none() {
                    e.apply_gradient(scene, &[sym], 3, Some(&pair(unstable, gray)?), None)
                        .map_err(other)?;
                    e.add_frame(scene, sym, 3, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                } else {
                    let fg_spectrum = fg.map(|fg| pair(unstable, fg)).transpose()?;
                    let bg_spectrum = bg.map(|bg| pair(unstable, bg)).transpose()?;
                    e.apply_gradient(
                        scene,
                        &[sym],
                        3,
                        fg_spectrum.as_deref(),
                        bg_spectrum.as_deref(),
                    )
                    .map_err(other)?;
                    if fg.is_none() {
                        e.add_frame(scene, sym, 3, Some(ColorPair::new(None, bg)), 0)
                            .map_err(other)?;
                    }
                }
                e.activate_scene(self, slot, rumble_scene);
                e.set_appearance(slot, Some(sym), Some(ColorPair::new(Some(start_fg), bg)));
            } else {
                let final_fg = *final_gradient_mapping
                    .get(&e.input_coord(slot))
                    .expect("gradient mapping fg");
                let plain = e.scene(rumble_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                let scene = match memo.get(&(sym, final_fg)) {
                    Some((rumble_frames, final_frames)) if plain => {
                        e.append_frames(rumble_scene, rumble_frames);
                        let scene = e.scene_new(slot, final_, false, None, None);
                        e.append_frames(scene, final_frames);
                        scene
                    }
                    _ => {
                        e.apply_gradient(
                            rumble_scene,
                            &[sym],
                            10,
                            Some(&pair(final_fg, unstable)?),
                            None,
                        )
                        .map_err(other)?;
                        let scene = e.scene_new(slot, final_, false, None, None);
                        e.apply_gradient(scene, &[sym], 3, Some(&pair(unstable, final_fg)?), None)
                            .map_err(other)?;
                        if plain {
                            memo.insert(
                                (sym, final_fg),
                                (
                                    e.scenes.frames_of(rumble_scene).to_vec(),
                                    e.scenes.frames_of(scene).to_vec(),
                                ),
                            );
                        }
                        scene
                    }
                };
                self.final_scene[s] = scene;
                e.activate_scene(self, slot, rumble_scene);
            }
            e.set_visible(slot, true);
        }
        // the old engine steps every character's animation each rumble frame;
        // nothing observes the order and no path is active, so update steps
        // them (dozing through the frames' pure ticks)
        for &slot in &order {
            e.active_insert(slot);
        }
        self.order = order;
        self.explosion_hold_time = 30;
        self.phase = Phase::Rumble;
        self.current_rumble_steps = 0;
        self.rumble_mod_delay = 18;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.restore_pending {
            self.restore_pending = false;
            for k in 0..self.order.len() {
                let slot = *self.order.at(k);
                e.set_coordinate(slot, *self.jumbled.at(slot));
            }
        }
        if self.phase == Phase::Rumble {
            if self.current_rumble_steps < MAX_RUMBLE_STEPS {
                if self.current_rumble_steps > 30
                    && self.current_rumble_steps % self.rumble_mod_delay == 0
                {
                    let row_offset = e.rng.choice_index(3) as i64 - 1;
                    let column_offset = e.rng.choice_index(3) as i64 - 1;
                    for k in 0..self.order.len() {
                        let slot = *self.order.at(k);
                        let current = e.coord(slot);
                        e.set_coordinate(
                            slot,
                            Coord::new(current.column + column_offset, current.row + row_offset),
                        );
                    }
                    self.restore_pending = true;
                    self.rumble_mod_delay = (self.rumble_mod_delay - 1).max(1);
                }
                // step every rumbling character (the set holds them all until
                // their scene completes; afterwards stepping is a no-op)
                e.update(self);
                self.current_rumble_steps += 1;
                return true;
            }
            self.phase = Phase::Explosion;
            for k in 0..self.order.len() {
                let slot = *self.order.at(k);
                let path = *self.explosion.at(slot);
                e.activate_path(self, slot, path);
            }
            e.active_clear();
            for k in 0..self.order.len() {
                e.active_insert(*self.order.at(k));
            }
        }

        if self.phase == Phase::Explosion {
            if !e.active_is_empty() {
                self.tick_and_retain(e, false);
                return true;
            } else if self.explosion_hold_time != 0 {
                self.explosion_hold_time -= 1;
                return true;
            }
            self.phase = Phase::Reassembly;
            for k in 0..self.order.len() {
                let slot = *self.order.at(k);
                let scene = *self.final_scene.at(slot);
                e.activate_scene(self, slot, scene);
                e.active_insert(slot);
                let path = *self.reassembly.at(slot);
                e.activate_path(self, slot, path);
            }
        }

        if self.phase == Phase::Reassembly && !e.active_is_empty() {
            self.tick_and_retain(e, true);
            return true;
        }
        false
    }
}
