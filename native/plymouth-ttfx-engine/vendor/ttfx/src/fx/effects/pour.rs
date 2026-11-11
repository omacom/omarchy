//! pour on the fx engine (old engine: effects/pour.rs).
//!
//! Characters are built group by group in the old engine's order, so the speed
//! draws and the auto-numbered path and scene names line up. Every character
//! gets one eased path from its pour start to its input coordinate and one
//! scene fading from the starting color to its final color; a plain scene's
//! frames are memoized by (symbol, final color). The groups are walked by
//! index afterwards: odd groups pour from their far end.

use std::collections::HashMap;

use crate::effects::pour::{PourConfig, PourDirection};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Pour {
    config: PourConfig,
    groups: Vec<Vec<u32>>,
    /// The next group to take (pending_groups.remove(0)).
    next_group: usize,
    /// The current group, its next character's index and the characters
    /// left in it; odd groups walk backward.
    current: usize,
    cursor: usize,
    left: usize,
    gap: i64,
}

impl Pour {
    pub fn new(config: PourConfig) -> Self {
        Pour {
            config,
            groups: Vec::new(),
            next_group: 0,
            current: 0,
            cursor: 0,
            left: 0,
            gap: 0,
        }
    }

    /// current_group = pending_groups.remove(0), when a group is pending.
    fn take_group(&mut self) {
        if self.next_group < self.groups.len() {
            let g = self.next_group;
            self.next_group += 1;
            self.current = g;
            self.left = self.groups[g].len();
            self.cursor = if g.is_multiple_of(2) {
                0
            } else {
                self.left.wrapping_sub(1)
            };
        }
    }
}

impl Hooks for Pour {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Pour {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
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
        let start = config.starting_color;
        let ten_steps = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[start, c], 10, false)
                .map_err(other)?
                .spectrum)
        };
        // the old engine's first pass (TopToBottomLeftToRight) draws nothing
        // and only fills the final color map, which is read directly here
        let grouping = match config.pour_direction {
            PourDirection::Down => CharacterGroup::RowBottomToTop,
            PourDirection::Up => CharacterGroup::RowTopToBottom,
            PourDirection::Left => CharacterGroup::ColumnLeftToRight,
            PourDirection::Right => CharacterGroup::ColumnRightToLeft,
        };
        let groups = e.get_characters_grouped(CharacterFilter::default(), grouping);
        let total: usize = groups.iter().map(Vec::len).sum();
        // a hint: the two-stop pour gradient reads only the first step count
        // (the rest may be anything, even huge)
        let steps = config
            .final_gradient_steps
            .first()
            .copied()
            .unwrap_or(1)
            .clamp(1, 1 << 10) as usize;
        e.scenes.reserve(total, total * (steps + 11));
        // the last final color and its pour spectrum; (symbol, final color)
        // -> the frames of a plain scene
        let mut last: Option<(Color, Vec<Color>)> = None;
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        for group in &groups {
            for &slot in group {
                e.set_visible(slot, false);
                let input = e.input_coord(slot);
                let start_coord = match config.pour_direction {
                    PourDirection::Down => Coord::new(input.column, canvas.top),
                    PourDirection::Up => Coord::new(input.column, canvas.bottom),
                    PourDirection::Left => Coord::new(canvas.right, input.row),
                    PourDirection::Right => Coord::new(canvas.left, input.row),
                };
                e.set_coordinate(slot, start_coord);
                let speed = e
                    .rng
                    .uniform(config.movement_speed_range.0, config.movement_speed_range.1);
                let path = e
                    .path_new(
                        slot,
                        speed,
                        Some(config.movement_easing),
                        None,
                        0,
                        false,
                        Name::NONE,
                    )
                    .map_err(other)?;
                e.path_new_waypoint(path, input, None, Name::NONE)
                    .map_err(other)?;
                e.activate_path(self, slot, path);

                let scene = e.scene_new(slot, Name::NONE, false, None, None);
                let sym = e.input_sym(slot);
                if dynamic {
                    let fg = e.input_fg(slot).map(ten_steps).transpose()?;
                    let bg = e.input_bg(slot).map(ten_steps).transpose()?;
                    if fg.is_some() || bg.is_some() {
                        e.apply_gradient(
                            scene,
                            &[sym],
                            config.final_gradient_frames,
                            fg.as_deref(),
                            bg.as_deref(),
                        )
                        .map_err(other)?;
                    } else {
                        e.add_frame(
                            scene,
                            sym,
                            config.final_gradient_frames,
                            Some(ColorPair::default()),
                            0,
                        )
                        .map_err(other)?;
                    }
                } else {
                    let final_fg = *final_gradient_mapping
                        .get(&input)
                        .expect("gradient mapping fg");
                    let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                    match memo.get(&(sym, final_fg)) {
                        Some(frames) if plain => e.append_frames(scene, frames),
                        _ => {
                            if last.as_ref().is_none_or(|(c, _)| *c != final_fg) {
                                let spectrum = Gradient::new(
                                    &[start, final_fg],
                                    &config.final_gradient_steps,
                                    false,
                                    false,
                                )
                                .map_err(other)?
                                .spectrum;
                                last = Some((final_fg, spectrum));
                            }
                            let spectrum = &last.as_ref().unwrap().1;
                            e.apply_gradient(
                                scene,
                                &[sym],
                                config.final_gradient_frames,
                                Some(spectrum),
                                None,
                            )
                            .map_err(other)?;
                            if plain {
                                memo.insert((sym, final_fg), e.scenes.frames_of(scene).to_vec());
                            }
                        }
                    }
                }
                e.activate_scene(self, slot, scene);
            }
        }
        self.groups = groups;
        self.next_group = 0;
        self.left = 0;
        self.take_group();
        self.gap = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.next_group >= self.groups.len() && self.left == 0 && e.active_is_empty() {
            return false;
        }
        if self.left == 0 {
            self.take_group();
        }
        if self.left != 0 {
            if self.gap == 0 {
                let group = &self.groups[self.current];
                let backward = self.current % 2 == 1;
                for _ in 0..self.config.pour_speed {
                    if self.left == 0 {
                        break;
                    }
                    self.left -= 1;
                    let slot = *group.at(self.cursor);
                    self.cursor = if backward {
                        self.cursor.wrapping_sub(1)
                    } else {
                        self.cursor + 1
                    };
                    e.set_visible(slot, true);
                    e.active_insert(slot);
                }
                self.gap = self.config.gap;
            } else {
                self.gap -= 1;
            }
        }
        e.update(self);
        true
    }
}
