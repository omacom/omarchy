//! bouncyballs on the fx engine (old engine: effects/bouncyballs.rs).
//!
//! Every character gets, in the old engine's order: two RNG choices (ball
//! color, ball symbol), a one-frame ball scene (auto id 0), a final scene
//! (auto id 1) fading from the ball color to its final color, a drop row from
//! rng.uniform, and a one-waypoint path (auto id 0) back to its input
//! coordinate whose completion activates the final scene. Ball visuals are
//! memoized by (color, symbol) and plain final scenes' frames by (input
//! symbol, ball color, final color).

use std::collections::HashMap;

use crate::effects::bouncyballs::BouncyBallsConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym, Visual, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

const FINAL_DURATION: i64 = 6;

pub struct BouncyBalls {
    config: BouncyBallsConfig,
    /// The characters grouped by input row, lowest row first (the old
    /// group_by_row BTreeMap), as `order[group_ends[k-1]..group_ends[k]]`.
    order: Vec<u32>,
    group_ends: Vec<usize>,
    next_group: usize,
    pending: Vec<u32>,
    ball_delay: i64,
}

impl BouncyBalls {
    pub fn new(config: BouncyBallsConfig) -> Self {
        BouncyBalls {
            config,
            order: Vec::new(),
            group_ends: Vec::new(),
            next_group: 0,
            pending: Vec::new(),
            ball_delay: 0,
        }
    }
}

impl Hooks for BouncyBalls {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for BouncyBalls {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let canvas = &e.canvas;
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let canvas_top = e.canvas.top;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let ball_symbols: Vec<Sym> = config.ball_symbols.iter().map(|s| e.sym(s)).collect();
        let (ball, final_) = (Name::auto(0), Name::auto(1));
        let with_steps = |a: Color, b: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[a, b], 10, false)
                .map_err(other)?
                .spectrum)
        };

        // (ball color, ball symbol) -> the ball frame's visual
        let mut ball_visuals = vec![Visual(NONE); config.ball_colors.len() * ball_symbols.len()];
        // (ball color, final color) -> its index; (input symbol, that index)
        // -> the final frames of a plain scene
        let mut pair_index: HashMap<(u32, Color), u32, FxBuild> = HashMap::default();
        let mut final_memo: HashMap<(Sym, u32), Vec<Frame>, FxBuild> = HashMap::default();

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        e.scenes
            .reserve(characters.len() * 2, characters.len() * 12);
        for &slot in &characters {
            let input_coord = e.input_coord(slot);
            let final_color = *final_gradient_mapping
                .get(&input_coord)
                .expect("gradient mapping");
            let color_index = e.rng.choice_index(config.ball_colors.len());
            let symbol_index = e.rng.choice_index(ball_symbols.len());
            let color = config.ball_colors[color_index];

            let ball_scene = e.scene_new(slot, ball, false, None, None);
            let visual = &mut ball_visuals[color_index * ball_symbols.len() + symbol_index];
            if visual.0 == NONE {
                let info = VisualInfo {
                    sym: ball_symbols[symbol_index],
                    fg: Some(color),
                    bg: None,
                    attrs: HAS_COLORS,
                };
                *visual = e.visuals.make(&e.symbols, info);
            }
            e.add_frame_visual(ball_scene, *visual, 1).map_err(other)?;

            let final_scene = e.scene_new(slot, final_, false, None, None);
            let sym = e.input_sym(slot);
            if dynamic {
                let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                if fg.is_some() || bg.is_some() {
                    let fg = fg.map(|c| with_steps(color, c)).transpose()?;
                    let bg = bg.map(|c| with_steps(color, c)).transpose()?;
                    e.apply_gradient(
                        final_scene,
                        &[sym],
                        FINAL_DURATION,
                        fg.as_deref(),
                        bg.as_deref(),
                    )
                    .map_err(other)?;
                } else {
                    e.add_frame(
                        final_scene,
                        sym,
                        FINAL_DURATION,
                        Some(ColorPair::default()),
                        0,
                    )
                    .map_err(other)?;
                }
            } else {
                let next_index = pair_index.len() as u32;
                let index = *pair_index
                    .entry((color_index as u32, final_color))
                    .or_insert(next_index);
                let plain = e.scene(final_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match final_memo.get(&(sym, index)) {
                    Some(frames) if plain => e.append_frames(final_scene, frames),
                    _ => {
                        let spectrum = with_steps(color, final_color)?;
                        e.apply_gradient(
                            final_scene,
                            &[sym],
                            FINAL_DURATION,
                            Some(&spectrum),
                            None,
                        )
                        .map_err(other)?;
                        if plain {
                            final_memo
                                .insert((sym, index), e.scenes.frames_of(final_scene).to_vec());
                        }
                    }
                }
            }

            // Coord(input column, int(canvas.top * uniform(1.0, 1.5)))
            let drop_row = (canvas_top as f64 * e.rng.uniform(1.0, 1.5)) as i64;
            e.set_coordinate(slot, Coord::new(input_coord.column, drop_row));
            let path = e
                .path_new(
                    slot,
                    config.movement_speed,
                    Some(config.movement_easing),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, input_coord, None, Name::NONE)
                .map_err(other)?;
            e.activate_path(self, slot, path);
            e.activate_scene(self, slot, ball_scene);
            let path_name = e.paths.recs[path as usize].name;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(path_name),
                Action::ActivateScene(final_),
            )
            .map_err(other)?;
        }

        // group_by_row: a stable sort by input row, lowest row first
        let mut order = characters;
        order.sort_by_key(|&slot| e.input_coord(slot).row);
        self.group_ends.clear();
        for k in 1..=order.len() {
            if k == order.len() || e.input_coord(order[k]).row != e.input_coord(order[k - 1]).row {
                self.group_ends.push(k);
            }
        }
        self.order = order;
        self.next_group = 0;
        self.pending.clear();
        // next_frame refills pending with one row group at a time
        let largest = self
            .group_ends
            .iter()
            .scan(0, |start, &end| Some(end - std::mem::replace(start, end)))
            .max();
        self.pending.reserve(largest.unwrap_or(0));
        self.ball_delay = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        let groups_left = self.next_group < self.group_ends.len();
        if !groups_left && e.active_is_empty() && self.pending.is_empty() {
            return false;
        }
        if self.pending.is_empty() && groups_left {
            let start = if self.next_group == 0 {
                0
            } else {
                self.group_ends[self.next_group - 1]
            };
            let end = self.group_ends[self.next_group];
            self.next_group += 1;
            self.pending.extend_from_slice(&self.order[start..end]);
        }
        if !self.pending.is_empty() {
            if self.ball_delay == 0 {
                for _ in 0..e.rng.randint(2, 6) {
                    if self.pending.is_empty() {
                        break;
                    }
                    let index = e.rng.randint(0, self.pending.len() as i64 - 1) as usize;
                    let slot = self.pending.remove(index);
                    e.set_visible(slot, true);
                    e.active_insert(slot);
                }
                self.ball_delay = self.config.ball_delay;
            } else {
                self.ball_delay -= 1;
            }
        }
        e.update(self);
        true
    }
}
