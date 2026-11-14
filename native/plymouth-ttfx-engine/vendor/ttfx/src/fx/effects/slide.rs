//! slide on the fx engine (old engine: effects/slide.rs).
//!
//! Characters are grouped by row, column or diagonal, parked outside the
//! canvas, and released one per group per frame onto an eased "input_path"
//! back to their input coordinate, while a gradient scene (activated at
//! build) fades them to their final color. A scene's frames are memoized by
//! (symbol, final color). No RNG draws and no events, so the order in which
//! characters get their paths and scenes is free.
//!
//! The old engine's row/column/diagonal branches reduce to one flag,
//! flip = merge ? (index even) : reverse_direction:
//!   row:      flip -> from canvas.right + 1 in order, else from left - 1 reversed
//!   column:   flip -> from canvas.bottom - 1 in order, else from top + 1 reversed
//!   diagonal: flip -> from above the first character reversed, else from
//!             below the last character in order

use std::collections::HashMap;
use std::ops::Range;

use crate::effects::slide::{SlideConfig, SlideGrouping};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Slide {
    config: SlideConfig,
    /// (slot, input path) of every character, group after group, each group
    /// in release order.
    chars: Vec<(u32, u32)>,
    /// Every group's range in `chars`.
    groups: Vec<Range<u32>>,
    next_group: usize,
    /// The released groups' remaining ranges (Vec::retain order).
    active: Vec<Range<u32>>,
    current_gap: i64,
}

impl Slide {
    pub fn new(config: SlideConfig) -> Self {
        Slide {
            config,
            chars: Vec::new(),
            groups: Vec::new(),
            next_group: 0,
            active: Vec::new(),
            current_gap: 0,
        }
    }
}

impl Hooks for Slide {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Slide {
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
        let first_stop = config.final_gradient_stops[0];
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let grouping = match config.grouping {
            SlideGrouping::Row => CharacterGroup::RowTopToBottom,
            SlideGrouping::Column => CharacterGroup::ColumnLeftToRight,
            SlideGrouping::Diagonal => CharacterGroup::DiagonalTopLeftToBottomRight,
        };
        let groups = e.get_characters_grouped(CharacterFilter::default(), grouping);
        let input_path = e.name("input_path");
        let scene_name = Name::auto(0);
        let total: usize = groups.iter().map(Vec::len).sum();
        self.chars = Vec::with_capacity(total);
        self.groups = Vec::with_capacity(groups.len());
        // (symbol, final color) -> the frames of a plain scene
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();

        for (index, group) in groups.iter().enumerate() {
            let start = self.chars.len();
            for &slot in group {
                let path = e
                    .path_new(
                        slot,
                        config.movement_speed,
                        Some(config.movement_easing),
                        None,
                        0,
                        false,
                        input_path,
                    )
                    .map_err(other)?;
                e.path_new_waypoint(path, e.input_coord(slot), None, Name::NONE)
                    .map_err(other)?;
                self.chars.push((slot, path));
            }
            let flip = if config.merge {
                index % 2 == 0
            } else {
                config.reverse_direction
            };
            let mut reversed = !flip;
            match config.grouping {
                SlideGrouping::Row => {
                    let column = if flip {
                        canvas.right + 1
                    } else {
                        canvas.left - 1
                    };
                    for &slot in group {
                        e.set_coordinate(slot, Coord::new(column, e.input_coord(slot).row));
                    }
                }
                SlideGrouping::Column => {
                    let row = if flip {
                        canvas.bottom - 1
                    } else {
                        canvas.top + 1
                    };
                    for &slot in group {
                        e.set_coordinate(slot, Coord::new(e.input_coord(slot).column, row));
                    }
                }
                SlideGrouping::Diagonal => {
                    reversed = flip;
                    let start = if flip {
                        let first = e.input_coord(group[0]);
                        let distance = (canvas.top + 1) - first.row;
                        Coord::new(first.column + distance, first.row + distance)
                    } else {
                        let last = e.input_coord(*group.last().unwrap());
                        let distance = last.row - (canvas.bottom - 1);
                        Coord::new(last.column - distance, last.row - distance)
                    };
                    for &slot in group {
                        e.set_coordinate(slot, start);
                    }
                }
            }
            for &slot in group {
                let sym = e.input_sym(slot);
                let scene = e.scene_new(slot, scene_name, false, None, None);
                if dynamic {
                    let colors = ColorPair::new(e.input_fg(slot), e.input_bg(slot));
                    e.add_frame(scene, sym, config.final_gradient_frames, Some(colors), 0)
                        .map_err(other)?;
                } else {
                    let final_fg = *final_gradient_mapping
                        .get(&e.input_coord(slot))
                        .expect("gradient mapping fg");
                    let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                    match memo.get(&(sym, final_fg)) {
                        Some(frames) if plain => e.append_frames(scene, frames),
                        _ => {
                            let spectrum = Gradient::with_steps(&[first_stop, final_fg], 10, false)
                                .map_err(other)?
                                .spectrum;
                            e.apply_gradient(
                                scene,
                                &[sym],
                                config.final_gradient_frames,
                                Some(&spectrum),
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
            if reversed {
                self.chars[start..].reverse();
            }
            self.groups.push(start as u32..self.chars.len() as u32);
        }
        self.active = Vec::with_capacity(self.groups.len());
        self.next_group = 0;
        self.current_gap = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        let pending = self.next_group < self.groups.len();
        if !pending && e.active_is_empty() && self.active.is_empty() {
            return false;
        }
        if pending {
            if self.current_gap == self.config.gap {
                let group = self.groups.at(self.next_group).clone();
                if !group.is_empty() {
                    self.active.push(group);
                }
                self.next_group += 1;
                self.current_gap = 0;
            } else {
                self.current_gap += 1;
            }
        }
        let mut write = 0;
        for read in 0..self.active.len() {
            let range = self.active.at_mut(read);
            // a released group is never empty
            let (slot, path) = *self.chars.at(range.start as usize);
            range.start += 1;
            if range.start < range.end {
                let range = range.clone();
                *self.active.at_mut(write) = range;
                write += 1;
            }
            e.set_visible(slot, true);
            e.activate_path(self, slot, path);
            e.active_insert(slot);
        }
        self.active.truncate(write);
        e.update(self);
        true
    }
}
