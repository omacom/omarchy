//! slice, ported from effects/effect_slice.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct SliceConfig {
    /// Direction of the slice.
    #[arg(long = "slice-direction", default_value = "vertical",
          value_parser = ["vertical", "horizontal", "diagonal"])]
    pub slice_direction: String,

    /// Movement speed of the characters.
    #[arg(long = "movement-speed", default_value_t = 0.25, value_parser = parse_positive_float)]
    pub movement_speed: f64,

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "in_out_expo", value_parser = parse_easing)]
    pub movement_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Slice {
    config: SliceConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
}

impl Slice {
    pub fn new(config: SliceConfig) -> Self {
        Slice { config, character_final_color_map: HashMap::new() }
    }
}

impl EffectHooks for Slice {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Slice {
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
            let (input_fg, input_bg, input_coord, input_symbol, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (
                    ch.animation.input_fg_color.clone(),
                    ch.animation.input_bg_color.clone(),
                    ch.input_coord,
                    ch.input_symbol.clone(),
                    ch.uses_input_preexisting_colors,
                )
            };
            let final_colors = if dynamic {
                ColorPair::new(input_fg, input_bg)
            } else {
                ColorPair::new(Some(final_gradient_mapping.get(&input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors.clone());
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation.set_appearance(&input_symbol, uses_pre, Some(&input_symbol), Some(final_colors));
        }

        // Per-character path setup shared by every branch: set the origin
        // coordinate, create the input-coord path, and activate it.
        macro_rules! send_to {
            ($id:expr, $origin:expr) => {{
                let id = $id;
                let origin: Coord = $origin;
                let input_coord = ctx.terminal.arena[id.0 as usize].input_coord;
                let input_coord_path = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.motion.set_coordinate(origin);
                    let path_id = ch
                        .motion
                        .new_path(self.config.movement_speed, Some(self.config.movement_easing), None, 0, false, "")
                        .map_err(EngineError::Other)?;
                    ch.motion
                        .paths
                        .get_mut(&path_id)
                        .unwrap()
                        .new_waypoint(input_coord, None, "")
                        .map_err(EngineError::Other)?;
                    path_id
                };
                ctx.activate_path(self, id, &input_coord_path);
            }};
        }

        let canvas_top = ctx.terminal.canvas.top;
        let canvas_bottom = ctx.terminal.canvas.bottom;
        let canvas_left = ctx.terminal.canvas.left;
        let canvas_right = ctx.terminal.canvas.right;
        let text_center_column = ctx.terminal.canvas.text_center_column;
        let text_center_row = ctx.terminal.canvas.text_center_row;
        let text_left = ctx.terminal.canvas.text_left;
        let text_right = ctx.terminal.canvas.text_right;
        let text_top = ctx.terminal.canvas.text_top;
        let text_bottom = ctx.terminal.canvas.text_bottom;

        if self.config.slice_direction == "vertical" {
            let rows =
                ctx.terminal.get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowBottomToTop);
            for row_index in 0..rows.len() {
                let row = &rows[row_index];
                let left_half: Vec<CharId> = row
                    .iter()
                    .copied()
                    .filter(|&id| ctx.terminal.arena[id.0 as usize].input_coord.column <= text_center_column)
                    .collect();
                for id in &left_half {
                    let column = ctx.terminal.arena[id.0 as usize].input_coord.column;
                    send_to!(*id, Coord::new(column, canvas_top + 1));
                }
                let opposite_row = &rows[rows.len() - (row_index + 1)];
                let right_half: Vec<CharId> = opposite_row
                    .iter()
                    .copied()
                    .filter(|&id| ctx.terminal.arena[id.0 as usize].input_coord.column > text_center_column)
                    .collect();
                for id in &right_half {
                    let column = ctx.terminal.arena[id.0 as usize].input_coord.column;
                    send_to!(*id, Coord::new(column, canvas_bottom - 1));
                }
                ctx.active_characters.extend(left_half);
                ctx.active_characters.extend(right_half);
            }
        } else if self.config.slice_direction == "horizontal" {
            self.config.movement_speed *= 2.0;
            let columns = ctx.terminal.get_characters_grouped(
                CharacterFilter {
                    input_chars: true,
                    inner_fill_chars: true,
                    outer_fill_chars: true,
                    added_chars: false,
                },
                CharacterGroup::ColumnRightToLeft,
            );
            let mut trimmed_columns: Vec<Vec<CharId>> = Vec::new();
            for column in &columns {
                let new_column: Vec<CharId> = column
                    .iter()
                    .copied()
                    .filter(|&id| {
                        let c = ctx.terminal.arena[id.0 as usize].input_coord;
                        (text_left <= c.column && c.column <= text_right)
                            && (text_bottom <= c.row && c.row <= text_top)
                    })
                    .collect();
                if !new_column.is_empty() {
                    trimmed_columns.push(new_column);
                }
            }
            let columns = trimmed_columns;
            let mid_point = text_center_row;
            for column_index in 0..columns.len() {
                let column = &columns[column_index];
                let bottom_half: Vec<CharId> = column
                    .iter()
                    .copied()
                    .filter(|&id| ctx.terminal.arena[id.0 as usize].input_coord.row <= mid_point)
                    .collect();
                for id in &bottom_half {
                    let row = ctx.terminal.arena[id.0 as usize].input_coord.row;
                    send_to!(*id, Coord::new(canvas_left - 1, row));
                }
                let opposite_column = &columns[columns.len() - (column_index + 1)];
                let top_half: Vec<CharId> = opposite_column
                    .iter()
                    .copied()
                    .filter(|&id| ctx.terminal.arena[id.0 as usize].input_coord.row > mid_point)
                    .collect();
                for id in &top_half {
                    let row = ctx.terminal.arena[id.0 as usize].input_coord.row;
                    send_to!(*id, Coord::new(canvas_right + 1, row));
                }
                ctx.active_characters.extend(bottom_half);
                ctx.active_characters.extend(top_half);
            }
        } else if self.config.slice_direction == "diagonal" {
            let diagonals = ctx
                .terminal
                .get_characters_grouped(CharacterFilter::default(), CharacterGroup::DiagonalBottomLeftToTopRight);
            let mut left: Vec<Vec<CharId>> = diagonals[..diagonals.len() / 2].to_vec();
            let mut right: Vec<Vec<CharId>> = diagonals[diagonals.len() / 2..].to_vec();
            while !left.is_empty() || !right.is_empty() {
                if !left.is_empty() {
                    let left_group = left.remove(0);
                    let origin_coord = Coord::new(
                        ctx.terminal.arena[left_group[0].0 as usize].input_coord.column,
                        canvas_bottom - 1,
                    );
                    for id in &left_group {
                        send_to!(*id, origin_coord);
                    }
                    ctx.active_characters.extend(left_group);
                }
                if !right.is_empty() {
                    let right_group = right.remove(0);
                    let origin_coord = Coord::new(
                        ctx.terminal.arena[right_group[right_group.len() - 1].0 as usize].input_coord.column,
                        canvas_top + 1,
                    );
                    for id in &right_group {
                        send_to!(*id, origin_coord);
                    }
                    ctx.active_characters.extend(right_group);
                }
            }
        }
        let active: Vec<CharId> = ctx.active_characters.iter().collect();
        for id in active {
            ctx.terminal.set_character_visibility(id, true);
        }
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !ctx.active_characters.is_empty() {
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
