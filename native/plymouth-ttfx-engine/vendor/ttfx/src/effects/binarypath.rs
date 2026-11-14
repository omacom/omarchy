//! binarypath, ported from effects/effect_binarypath.py.
//!
//! The inner _BinaryRepresentation class is the `BinaryRepresentation` struct.
//! No observable set iteration beyond the engine-canonical active_characters
//! (docs/ordering-inventory.md).

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_non_negative_ratio, parse_positive_float,
};
use crate::engine::animation::{Animation, ExistingColorHandling, VisualParams};
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
pub struct BinaryPathConfig {
    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["00d500", "007500"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "radial", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,

    /// Space separated, unquoted, list of colors for the binary characters. Character color is randomly assigned from this list.
    #[arg(long = "binary-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["044E29", "157e38", "45bf55", "95ed87"])]
    pub binary_colors: Vec<Color>,

    /// Speed of the binary groups as they travel around the terminal.
    #[arg(long = "movement-speed", default_value_t = 1.0, value_parser = parse_positive_float)]
    pub movement_speed: f64,

    /// Maximum number of binary groups that are active at any given time as a percentage of the total number of binary groups. Lower this to improve performance.
    #[arg(long = "active-binary-groups", default_value_t = 0.08, value_parser = parse_non_negative_ratio)]
    pub active_binary_groups: f64,
}

/// BinaryPathIterator._BinaryRepresentation.
struct BinaryRepresentation {
    character: CharId,
    binary_characters: Vec<CharId>,
    pending_binary_characters: Vec<CharId>,
    input_coord: Coord,
    is_active: bool,
}

impl BinaryRepresentation {
    /// _BinaryRepresentation._travel_complete.
    fn travel_complete(&self, ctx: &EngineCtx) -> bool {
        self.binary_characters
            .iter()
            .all(|&bin_char| ctx.terminal.arena[bin_char.0 as usize].motion.current_coord == self.input_coord)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Travel,
    Wipe,
}

/// typing.Literal["col", "row"].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Orientation {
    Col,
    Row,
}

pub struct BinaryPath {
    config: BinaryPathConfig,
    pending_binary_representations: Vec<BinaryRepresentation>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    last_frame_provided: bool,
    active_binary_reps: Vec<BinaryRepresentation>,
    complete: bool,
    phase: Phase,
    final_wipe_chars: Vec<Vec<CharId>>,
    max_active_binary_groups: i64,
}

impl BinaryPath {
    pub fn new(config: BinaryPathConfig) -> Self {
        BinaryPath {
            config,
            pending_binary_representations: Vec::new(),
            character_final_color_map: HashMap::new(),
            last_frame_provided: false,
            active_binary_reps: Vec::new(),
            complete: false,
            phase: Phase::Travel,
            final_wipe_chars: Vec::new(),
            max_active_binary_groups: 0,
        }
    }
}

impl EffectHooks for BinaryPath {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for BinaryPath {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // __init__: final_wipe_chars computed before build()
        self.final_wipe_chars = ctx
            .terminal
            .get_characters_grouped(CharacterFilter::default(), CharacterGroup::DiagonalTopRightToBottomLeft);

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
        for &id in &characters {
            let ch = &ctx.terminal.arena[id.0 as usize];
            let final_colors = if dynamic {
                ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
            } else {
                ColorPair::new(Some(final_gradient_mapping.get(&ch.input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors);
        }

        for &id in &characters {
            let (symbol, input_coord) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.animation.current_character_visual.symbol.clone(), ch.input_coord)
            };
            // format(ord(symbol), "08b")
            let code_point = symbol.chars().next().expect("empty symbol") as u32;
            let binary_string = format!("{code_point:08b}");
            let mut bin_rep = BinaryRepresentation {
                character: id,
                binary_characters: Vec::new(),
                pending_binary_characters: Vec::new(),
                input_coord,
                is_active: false,
            };
            for binary_char in binary_string.chars() {
                let added = ctx.terminal.add_character(&binary_char.to_string(), Coord::new(0, 0));
                bin_rep.binary_characters.push(added);
                bin_rep.pending_binary_characters.push(added);
            }
            self.pending_binary_representations.push(bin_rep);
        }

        let mut pending_reps = std::mem::take(&mut self.pending_binary_representations);
        for bin_rep in &pending_reps {
            let mut path_coords: Vec<Coord> = Vec::new();
            let starting_coord = ctx.terminal.canvas.random_coord(&mut ctx.rng, true, false);
            path_coords.push(starting_coord);
            let mut last_orientation = *ctx.rng.choice(&[Orientation::Col, Orientation::Row]);
            let mut next_coord = starting_coord; // will be rebound in the loop
            let input_coord = bin_rep.input_coord;
            while *path_coords.last().unwrap() != input_coord {
                let last_coord = *path_coords.last().unwrap();
                let column_direction = if last_coord.column > input_coord.column {
                    -1
                } else if last_coord.column == input_coord.column {
                    0
                } else {
                    1
                };
                let row_direction = if last_coord.row > input_coord.row {
                    -1
                } else if last_coord.row == input_coord.row {
                    0
                } else {
                    1
                };
                let max_column_distance = (last_coord.column - input_coord.column).abs();
                let max_row_distance = (last_coord.row - input_coord.row).abs();
                if last_orientation == Orientation::Col && max_row_distance > 0 {
                    // min(max_row_distance, max(10, int(canvas.right * 0.2))) — int() truncation
                    let limit = std::cmp::min(
                        max_row_distance,
                        std::cmp::max(10, (ctx.terminal.canvas.right as f64 * 0.2) as i64),
                    );
                    next_coord = Coord::new(
                        last_coord.column,
                        last_coord.row + ctx.rng.randint(1, limit) * row_direction,
                    );
                    last_orientation = Orientation::Row;
                } else if last_orientation == Orientation::Row && max_column_distance > 0 {
                    next_coord = Coord::new(
                        last_coord.column + ctx.rng.randint(1, std::cmp::min(max_column_distance, 4)) * column_direction,
                        last_coord.row,
                    );
                    last_orientation = Orientation::Col;
                } else {
                    next_coord = input_coord;
                }

                path_coords.push(next_coord);
            }

            path_coords.push(next_coord);
            let final_coord = input_coord;
            path_coords.push(final_coord);
            for &bin_effectchar in &bin_rep.binary_characters {
                let digital_path = {
                    let ch = &mut ctx.terminal.arena[bin_effectchar.0 as usize];
                    ch.motion.set_coordinate(path_coords[0]);
                    let path_id = ch
                        .motion
                        .new_path(self.config.movement_speed, None, None, 0, false, "")
                        .map_err(EngineError::Other)?;
                    let path = ch.motion.paths.get_mut(&path_id).unwrap();
                    for &coord in &path_coords {
                        path.new_waypoint(coord, None, "").map_err(EngineError::Other)?;
                    }
                    path_id
                };
                ctx.activate_path(self, bin_effectchar, &digital_path);
                ctx.terminal.arena[bin_effectchar.0 as usize].layer = 1;
                let color = ctx.rng.choice(&self.config.binary_colors).clone();
                let color_scn = {
                    let ch = &mut ctx.terminal.arena[bin_effectchar.0 as usize];
                    let symbol = ch.animation.current_character_visual.symbol.clone();
                    let uses_pre = ch.uses_input_preexisting_colors;
                    let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                    ch.animation
                        .scenes
                        .get_mut(&scene_id)
                        .unwrap()
                        .add_frame(
                            &symbol,
                            1,
                            VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                    scene_id
                };
                ctx.activate_scene(self, bin_effectchar, &color_scn);
            }
        }
        self.pending_binary_representations = pending_reps.drain(..).collect();

        for &id in &characters {
            let (input_symbol, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
            };
            let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
            let final_fg_color = final_colors.fg_color.clone();
            let final_bg_color = final_colors.bg_color.clone();
            let dim_fg_color = final_fg_color.as_ref().map(|c| Animation::adjust_color_brightness(c, 0.5));
            let dim_bg_color = final_bg_color.as_ref().map(|c| Animation::adjust_color_brightness(c, 0.5));
            let collapse_fg_gradient = match &dim_fg_color {
                Some(dim) => Some(
                    Gradient::with_steps(&[Color::from_hex("ffffff").unwrap(), dim.clone()], 7, false)
                        .map_err(EngineError::Other)?,
                ),
                None => None,
            };
            let collapse_bg_gradient = match &dim_bg_color {
                Some(dim) => Some(
                    Gradient::with_steps(&[Color::from_hex("ffffff").unwrap(), dim.clone()], 7, false)
                        .map_err(EngineError::Other)?,
                ),
                None => None,
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let collapse_scn = ch.animation.new_scene(false, None, Some(Easing::InQuad), "collapse_scn", uses_pre);
                let scene = ch.animation.scenes.get_mut(&collapse_scn).unwrap();
                if collapse_fg_gradient.is_some() || collapse_bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            3,
                            collapse_fg_gradient.as_ref(),
                            collapse_bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            3,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            }

            let brighten_fg_gradient = match (&dim_fg_color, &final_fg_color) {
                (Some(dim), Some(final_fg)) => Some(
                    Gradient::with_steps(&[dim.clone(), final_fg.clone()], 10, false).map_err(EngineError::Other)?,
                ),
                _ => None,
            };
            let brighten_bg_gradient = match (&dim_bg_color, &final_bg_color) {
                (Some(dim), Some(final_bg)) => Some(
                    Gradient::with_steps(&[dim.clone(), final_bg.clone()], 10, false).map_err(EngineError::Other)?,
                ),
                _ => None,
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let brighten_scn = ch.animation.new_scene(false, None, None, "brighten_scn", uses_pre);
                let scene = ch.animation.scenes.get_mut(&brighten_scn).unwrap();
                if brighten_fg_gradient.is_some() || brighten_bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            2,
                            brighten_fg_gradient.as_ref(),
                            brighten_bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            2,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
        }
        self.max_active_binary_groups = std::cmp::max(
            1,
            (self.config.active_binary_groups * self.pending_binary_representations.len() as f64) as i64,
        );
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.complete || !ctx.active_characters.is_empty() {
            if self.phase == Phase::Travel {
                while (self.active_binary_reps.len() as i64) < self.max_active_binary_groups
                    && !self.pending_binary_representations.is_empty()
                {
                    let index =
                        ctx.rng.randrange(0, self.pending_binary_representations.len() as i64) as usize;
                    let mut next_binary_rep = self.pending_binary_representations.remove(index);
                    next_binary_rep.is_active = true;
                    self.active_binary_reps.push(next_binary_rep);
                }

                if !self.active_binary_reps.is_empty() {
                    let mut active_reps = std::mem::take(&mut self.active_binary_reps);
                    for active_rep in &mut active_reps {
                        if !active_rep.pending_binary_characters.is_empty() {
                            let next_char = active_rep.pending_binary_characters.remove(0);
                            ctx.active_characters.insert(next_char);
                            ctx.terminal.set_character_visibility(next_char, true);
                        } else if active_rep.travel_complete(ctx) {
                            // _deactivate
                            for &bin_char in &active_rep.binary_characters {
                                ctx.terminal.set_character_visibility(bin_char, false);
                            }
                            active_rep.is_active = false;
                            // _activate_source_character
                            ctx.terminal.set_character_visibility(active_rep.character, true);
                            ctx.activate_scene(self, active_rep.character, "collapse_scn");
                            ctx.active_characters.insert(active_rep.character);
                        }
                    }
                    active_reps.retain(|binary_rep| binary_rep.is_active);
                    self.active_binary_reps = active_reps;
                }

                if ctx.active_characters.is_empty() {
                    self.phase = Phase::Wipe;
                }
            }

            if self.phase == Phase::Wipe {
                for _ in 0..2 {
                    if !self.final_wipe_chars.is_empty() {
                        let next_group = self.final_wipe_chars.remove(0);
                        for character in next_group {
                            ctx.activate_scene(self, character, "brighten_scn");
                            ctx.terminal.set_character_visibility(character, true);
                            ctx.active_characters.insert(character);
                        }
                    } else {
                        self.complete = true;
                    }
                }
            }

            ctx.update(self);
            return Some(ctx.frame());
        }

        if !self.last_frame_provided {
            self.last_frame_provided = true;
            return Some(ctx.frame());
        }

        None
    }
}
