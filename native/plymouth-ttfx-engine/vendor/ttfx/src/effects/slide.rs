//! slide, ported from effects/effect_slide.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_non_negative_int, parse_positive_float,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

/// typing.Literal["row", "column", "diagonal"].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SlideGrouping {
    Row,
    Column,
    Diagonal,
}

fn parse_slide_grouping(s: &str) -> Result<SlideGrouping, String> {
    Ok(match s {
        "row" => SlideGrouping::Row,
        "column" => SlideGrouping::Column,
        "diagonal" => SlideGrouping::Diagonal,
        _ => return Err(format!("invalid choice: '{s}' (choose from 'row', 'column', 'diagonal')")),
    })
}

#[derive(Args, Debug, Clone)]
pub struct SlideConfig {
    /// Speed of the characters.
    #[arg(long = "movement-speed", default_value_t = 0.8, value_parser = parse_positive_float)]
    pub movement_speed: f64,

    /// Direction to group characters.
    #[arg(long = "grouping", default_value = "row", value_parser = parse_slide_grouping)]
    pub grouping: SlideGrouping,

    /// Number of frames to wait before adding the next group of characters.
    #[arg(long = "gap", default_value_t = 2, value_parser = parse_non_negative_int)]
    pub gap: i64,

    /// Reverse the direction of the characters.
    #[arg(long = "reverse-direction")]
    pub reverse_direction: bool,

    /// Merge the character groups originating from either side of the terminal.
    #[arg(long = "merge")]
    pub merge: bool,

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "in_out_quad", value_parser = parse_easing)]
    pub movement_easing: Easing,

    /// Space separated, unquoted, list of colors for the character gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["833ab4", "fd1d1d", "fcb045"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step.
    #[arg(long = "final-gradient-frames", default_value_t = 6)]
    pub final_gradient_frames: i64,

    /// Direction of the gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Slide {
    config: SlideConfig,
    pending_groups: Vec<Vec<CharId>>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    active_groups: Vec<Vec<CharId>>,
    current_gap: i64,
}

impl Slide {
    pub fn new(config: SlideConfig) -> Self {
        Slide {
            config,
            pending_groups: Vec::new(),
            character_final_color_map: HashMap::new(),
            active_groups: Vec::new(),
            current_gap: 0,
        }
    }
}

impl EffectHooks for Slide {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Slide {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            let (input_fg, input_bg, input_coord) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone(), ch.input_coord)
            };
            let final_colors = if dynamic {
                ColorPair::new(input_fg, input_bg)
            } else {
                ColorPair::new(Some(final_gradient_mapping.get(&input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors);
        }

        let grouping = match self.config.grouping {
            SlideGrouping::Row => CharacterGroup::RowTopToBottom,
            SlideGrouping::Column => CharacterGroup::ColumnLeftToRight,
            SlideGrouping::Diagonal => CharacterGroup::DiagonalTopLeftToBottomRight,
        };
        let mut groups = ctx.terminal.get_characters_grouped(CharacterFilter::default(), grouping);
        for group in &groups {
            for &id in group {
                let input_coord = ctx.terminal.arena[id.0 as usize].input_coord;
                let motion = &mut ctx.terminal.arena[id.0 as usize].motion;
                motion
                    .new_path(self.config.movement_speed, Some(self.config.movement_easing), None, 0, false, "input_path")
                    .map_err(EngineError::Other)?;
                motion
                    .paths
                    .get_mut("input_path")
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
        }

        for group_index in 0..groups.len() {
            // Python's loop variable `group` keeps the original (pre-reversal) list.
            let group = groups[group_index].clone();
            match self.config.grouping {
                SlideGrouping::Row => {
                    let starting_column;
                    if self.config.merge && group_index % 2 == 0 {
                        starting_column = ctx.terminal.canvas.right + 1;
                    } else {
                        groups[group_index].reverse();
                        starting_column = ctx.terminal.canvas.left - 1;
                    }
                    let starting_column = if self.config.reverse_direction && !self.config.merge {
                        groups[group_index].reverse();
                        ctx.terminal.canvas.right + 1
                    } else {
                        starting_column
                    };
                    for i in 0..groups[group_index].len() {
                        let id = groups[group_index][i];
                        let row = ctx.terminal.arena[id.0 as usize].input_coord.row;
                        ctx.terminal.arena[id.0 as usize].motion.set_coordinate(Coord::new(starting_column, row));
                    }
                }
                SlideGrouping::Column => {
                    let starting_row;
                    if self.config.merge && group_index % 2 == 0 {
                        starting_row = ctx.terminal.canvas.bottom - 1;
                    } else {
                        groups[group_index].reverse();
                        starting_row = ctx.terminal.canvas.top + 1;
                    }
                    let starting_row = if self.config.reverse_direction && !self.config.merge {
                        groups[group_index].reverse();
                        ctx.terminal.canvas.bottom - 1
                    } else {
                        starting_row
                    };
                    for i in 0..groups[group_index].len() {
                        let id = groups[group_index][i];
                        let column = ctx.terminal.arena[id.0 as usize].input_coord.column;
                        ctx.terminal.arena[id.0 as usize].motion.set_coordinate(Coord::new(column, starting_row));
                    }
                }
                SlideGrouping::Diagonal => {}
            }
            if self.config.grouping == SlideGrouping::Diagonal {
                let last_coord = ctx.terminal.arena[group.last().unwrap().0 as usize].input_coord;
                let distance_from_outside_bottom = last_coord.row - (ctx.terminal.canvas.bottom - 1);
                let mut starting_coord = Coord::new(
                    last_coord.column - distance_from_outside_bottom,
                    last_coord.row - distance_from_outside_bottom,
                );
                if self.config.merge && group_index % 2 == 0 {
                    groups[group_index].reverse();
                    let first_coord = ctx.terminal.arena[group[0].0 as usize].input_coord;
                    let distance_from_outside = (ctx.terminal.canvas.top + 1) - first_coord.row;
                    starting_coord = Coord::new(
                        first_coord.column + distance_from_outside,
                        first_coord.row + distance_from_outside,
                    );
                }
                if self.config.reverse_direction && !self.config.merge {
                    groups[group_index].reverse();
                    let first_coord = ctx.terminal.arena[group[0].0 as usize].input_coord;
                    let distance_from_outside = (ctx.terminal.canvas.top + 1) - first_coord.row;
                    starting_coord = Coord::new(
                        first_coord.column + distance_from_outside,
                        first_coord.row + distance_from_outside,
                    );
                }
                for i in 0..groups[group_index].len() {
                    let id = groups[group_index][i];
                    ctx.terminal.arena[id.0 as usize].motion.set_coordinate(starting_coord);
                }
            }
            for &id in &group {
                let (input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
                let gradient_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.new_scene(false, None, None, "", uses_pre)
                };
                {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut(&gradient_scn).unwrap();
                    if dynamic {
                        scene
                            .add_frame(
                                &input_symbol,
                                self.config.final_gradient_frames,
                                VisualParams { colors: Some(final_colors), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    } else {
                        let final_fg_color = final_colors.fg_color.clone().expect("gradient mapping fg");
                        let char_gradient = Gradient::with_steps(
                            &[self.config.final_gradient_stops[0].clone(), final_fg_color],
                            10,
                            false,
                        )
                        .map_err(EngineError::Other)?;
                        scene
                            .apply_gradient_to_symbols(
                                &[input_symbol.clone()],
                                self.config.final_gradient_frames,
                                Some(&char_gradient),
                                None,
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
                ctx.activate_scene(self, id, &gradient_scn);
            }
        }

        self.pending_groups = groups;
        self.active_groups = Vec::new();
        self.current_gap = 0;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_groups.is_empty() || !ctx.active_characters.is_empty() || !self.active_groups.is_empty() {
            if self.current_gap == self.config.gap && !self.pending_groups.is_empty() {
                self.active_groups.push(self.pending_groups.remove(0));
                self.current_gap = 0;
            } else if !self.pending_groups.is_empty() {
                self.current_gap += 1;
            }
            for group_index in 0..self.active_groups.len() {
                if !self.active_groups[group_index].is_empty() {
                    let next_char = self.active_groups[group_index].remove(0);
                    ctx.terminal.set_character_visibility(next_char, true);
                    ctx.activate_path(self, next_char, "input_path");
                    ctx.active_characters.insert(next_char);
                }
            }
            self.active_groups.retain(|group| !group.is_empty());
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
