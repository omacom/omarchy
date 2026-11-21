//! middleout, ported from effects/effect_middleout.py.
//!
//! Ordering note: upstream's __next__ iterates the freshly rebuilt
//! active_characters *set* (effect_middleout.py:229-232) to activate the
//! "full" path/scene. Canonical order here is ascending character_id
//! (docs/ordering-inventory.md), matched by a shim patch on
//! MiddleOutIterator.__next__.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

/// typing.Literal["vertical", "horizontal"].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExpandDirection {
    Vertical,
    Horizontal,
}

fn parse_expand_direction(s: &str) -> Result<ExpandDirection, String> {
    Ok(match s {
        "vertical" => ExpandDirection::Vertical,
        "horizontal" => ExpandDirection::Horizontal,
        _ => return Err(format!("invalid choice: '{s}' (choose from 'vertical', 'horizontal')")),
    })
}

#[derive(Args, Debug, Clone)]
pub struct MiddleoutConfig {
    /// Color for the initial text in the center of the canvas.
    #[arg(long = "starting-color", default_value = "ffffff", value_parser = parse_color)]
    pub starting_color: Color,

    /// Direction the text will expand.
    #[arg(long = "expand-direction", default_value = "vertical", value_parser = parse_expand_direction)]
    pub expand_direction: ExpandDirection,

    /// Speed of the characters during the initial expansion of the center vertical/horiztonal line.
    #[arg(long = "center-movement-speed", default_value_t = 0.6, value_parser = parse_positive_float)]
    pub center_movement_speed: f64,

    /// Speed of the characters during the final full expansion.
    #[arg(long = "full-movement-speed", default_value_t = 0.6, value_parser = parse_positive_float)]
    pub full_movement_speed: f64,

    /// Easing function to use for initial expansion.
    #[arg(long = "center-easing", default_value = "in_out_sine", value_parser = parse_easing)]
    pub center_easing: Easing,

    /// Easing function to use for full expansion.
    #[arg(long = "full-easing", default_value = "in_out_sine", value_parser = parse_easing)]
    pub full_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Center,
    Full,
}

pub struct Middleout {
    config: MiddleoutConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
    phase: Phase,
}

impl Middleout {
    pub fn new(config: MiddleoutConfig) -> Self {
        Middleout { config, character_final_color_map: HashMap::new(), phase: Phase::Center }
    }
}

impl EffectHooks for Middleout {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Middleout {
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
            let center = ctx.terminal.canvas.center;
            ctx.terminal.arena[id.0 as usize].motion.set_coordinate(center);
            // setup waypoints
            let (column, row) = match self.config.expand_direction {
                ExpandDirection::Vertical => (input_coord.column, ctx.terminal.canvas.center_row),
                ExpandDirection::Horizontal => (ctx.terminal.canvas.center_column, input_coord.row),
            };
            let center_path = {
                let motion = &mut ctx.terminal.arena[id.0 as usize].motion;
                let path_id = motion
                    .new_path(self.config.center_movement_speed, Some(self.config.center_easing), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(Coord::new(column, row), None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            {
                let motion = &mut ctx.terminal.arena[id.0 as usize].motion;
                motion
                    .new_path(self.config.full_movement_speed, Some(self.config.full_easing), None, 0, false, "full")
                    .map_err(EngineError::Other)?;
                motion
                    .paths
                    .get_mut("full")
                    .unwrap()
                    .new_waypoint(input_coord, None, "full")
                    .map_err(EngineError::Other)?;
            }

            // setup scenes
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "full", uses_pre);
                let scene = ch.animation.scenes.get_mut("full").unwrap();
                let final_fg_color = final_colors.fg_color.clone();
                let final_bg_color = final_colors.bg_color.clone();
                if dynamic {
                    let fg_gradient = match &final_fg_color {
                        Some(c) => Some(
                            Gradient::with_steps(&[self.config.starting_color.clone(), c.clone()], 10, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let bg_gradient = match &final_bg_color {
                        Some(c) => Some(
                            Gradient::with_steps(&[self.config.starting_color.clone(), c.clone()], 10, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    if fg_gradient.is_some() || bg_gradient.is_some() {
                        scene
                            .apply_gradient_to_symbols(
                                &[input_symbol.clone()],
                                6,
                                fg_gradient.as_ref(),
                                bg_gradient.as_ref(),
                            )
                            .map_err(EngineError::Other)?;
                    } else {
                        scene
                            .add_frame(
                                &input_symbol,
                                6,
                                VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let final_fg_color = final_fg_color.expect("gradient mapping fg");
                    let full_gradient =
                        Gradient::with_steps(&[self.config.starting_color.clone(), final_fg_color], 10, false)
                            .map_err(EngineError::Other)?;
                    scene
                        .apply_gradient_to_symbols(&[input_symbol.clone()], 6, Some(&full_gradient), None)
                        .map_err(EngineError::Other)?;
                }
            }

            // initialize character state
            ctx.activate_path(self, id, &center_path);
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let input_symbol = ch.input_symbol.clone();
                let uses_pre = ch.uses_input_preexisting_colors;
                ch.animation.set_appearance(
                    &input_symbol,
                    uses_pre,
                    Some(&input_symbol.clone()),
                    Some(ColorPair::new(Some(self.config.starting_color.clone()), None)),
                );
            }
            ctx.terminal.set_character_visibility(id, true);
            ctx.active_characters.insert(id);
        }
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.phase == Phase::Center && ctx.active_characters.is_empty() {
            self.phase = Phase::Full;
            let characters = {
                let filter = CharacterFilter::default();
                ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
            };
            ctx.active_characters = characters.into_iter().collect();
            // upstream iterates the set here; canonical ascending character_id
            let ordered: Vec<CharId> = ctx.active_characters.iter().collect();
            for id in ordered {
                ctx.activate_path(self, id, "full");
                ctx.activate_scene(self, id, "full");
            }
        }
        if !ctx.active_characters.is_empty() {
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
