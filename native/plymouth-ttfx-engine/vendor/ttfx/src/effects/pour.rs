//! pour, ported from effects/effect_pour.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_non_negative_int, parse_positive_float_range,
    parse_positive_int,
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

/// PourIterator.PourDirection.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PourDirection {
    Up,
    Down,
    Left,
    Right,
}

fn parse_pour_direction(s: &str) -> Result<PourDirection, String> {
    Ok(match s {
        "up" => PourDirection::Up,
        "down" => PourDirection::Down,
        "left" => PourDirection::Left,
        "right" => PourDirection::Right,
        _ => return Err(format!("invalid choice: '{s}' (choose from 'up', 'down', 'left', 'right')")),
    })
}

#[derive(Args, Debug, Clone)]
pub struct PourConfig {
    /// Direction the text will pour.
    #[arg(long = "pour-direction", default_value = "down", value_parser = parse_pour_direction)]
    pub pour_direction: PourDirection,

    /// Number of characters poured in per tick. Increase to speed up the effect.
    #[arg(long = "pour-speed", default_value_t = 2, value_parser = parse_positive_int)]
    pub pour_speed: i64,

    /// Movement speed range of the characters.
    #[arg(long = "movement-speed-range", default_value = "0.4-0.6", value_parser = parse_positive_float_range)]
    pub movement_speed_range: (f64, f64),

    /// Number of frames to wait between each character in the pour effect.
    #[arg(long = "gap", default_value_t = 1, value_parser = parse_non_negative_int)]
    pub gap: i64,

    /// Color of the characters before the gradient starts.
    #[arg(long = "starting-color", default_value = "ffffff", value_parser = parse_color)]
    pub starting_color: Color,

    /// Space separated, unquoted, list of colors for the character gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step.
    #[arg(long = "final-gradient-frames", default_value_t = 6)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "in_quad", value_parser = parse_easing)]
    pub movement_easing: Easing,
}

pub struct Pour {
    config: PourConfig,
    pending_groups: Vec<Vec<CharId>>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    current_group: Vec<CharId>,
    gap: i64,
}

impl Pour {
    pub fn new(config: PourConfig) -> Self {
        Pour {
            config,
            pending_groups: Vec::new(),
            character_final_color_map: HashMap::new(),
            current_group: Vec::new(),
            gap: 0,
        }
    }
}

impl EffectHooks for Pour {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Pour {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let pour_direction = self.config.pour_direction;
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
        let grouping = match pour_direction {
            PourDirection::Down => CharacterGroup::RowBottomToTop,
            PourDirection::Up => CharacterGroup::RowTopToBottom,
            PourDirection::Left => CharacterGroup::ColumnLeftToRight,
            PourDirection::Right => CharacterGroup::ColumnRightToLeft,
        };
        let groups = ctx.terminal.get_characters_grouped(CharacterFilter::default(), grouping);
        for (i, group) in groups.iter().enumerate() {
            for &id in group {
                ctx.terminal.set_character_visibility(id, false);
                let (input_coord, input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (ch.input_coord, ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                let start_coord = match pour_direction {
                    PourDirection::Down => Coord::new(input_coord.column, ctx.terminal.canvas.top),
                    PourDirection::Up => Coord::new(input_coord.column, ctx.terminal.canvas.bottom),
                    PourDirection::Left => Coord::new(ctx.terminal.canvas.right, input_coord.row),
                    PourDirection::Right => Coord::new(ctx.terminal.canvas.left, input_coord.row),
                };
                ctx.terminal.arena[id.0 as usize].motion.set_coordinate(start_coord);
                let speed = ctx.rng.uniform(self.config.movement_speed_range.0, self.config.movement_speed_range.1);
                let input_coord_path = ctx.terminal.arena[id.0 as usize]
                    .motion
                    .new_path(speed, Some(self.config.movement_easing), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ctx.terminal.arena[id.0 as usize]
                    .motion
                    .paths
                    .get_mut(&input_coord_path)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                ctx.activate_path(self, id, &input_coord_path);

                let pour_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.new_scene(false, None, None, "", uses_pre)
                };
                let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
                {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut(&pour_scn).unwrap();
                    if dynamic {
                        let final_fg_color = final_colors.fg_color.clone();
                        let final_bg_color = final_colors.bg_color.clone();
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
                                    self.config.final_gradient_frames,
                                    fg_gradient.as_ref(),
                                    bg_gradient.as_ref(),
                                )
                                .map_err(EngineError::Other)?;
                        } else {
                            scene
                                .add_frame(
                                    &input_symbol,
                                    self.config.final_gradient_frames,
                                    VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                                )
                                .map_err(EngineError::Other)?;
                        }
                    } else {
                        let final_fg_color = final_colors.fg_color.clone().expect("gradient mapping fg");
                        let pour_gradient = Gradient::new(
                            &[self.config.starting_color.clone(), final_fg_color],
                            &self.config.final_gradient_steps,
                            false,
                            false,
                        )
                        .map_err(EngineError::Other)?;
                        scene
                            .apply_gradient_to_symbols(
                                &[input_symbol.clone()],
                                self.config.final_gradient_frames,
                                Some(&pour_gradient),
                                None,
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
                ctx.activate_scene(self, id, &pour_scn);
            }
            if i % 2 == 0 {
                self.pending_groups.push(group.clone());
            } else {
                let mut reversed = group.clone();
                reversed.reverse();
                self.pending_groups.push(reversed);
            }
        }
        self.gap = 0;
        self.current_group = self.pending_groups.remove(0);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_groups.is_empty() || !ctx.active_characters.is_empty() || !self.current_group.is_empty() {
            if self.current_group.is_empty() && !self.pending_groups.is_empty() {
                self.current_group = self.pending_groups.remove(0);
            }
            if !self.current_group.is_empty() {
                if self.gap == 0 {
                    for _ in 0..self.config.pour_speed {
                        if !self.current_group.is_empty() {
                            let next_character = self.current_group.remove(0);
                            ctx.terminal.set_character_visibility(next_character, true);
                            ctx.active_characters.insert(next_character);
                        }
                    }
                    self.gap = self.config.gap;
                } else {
                    self.gap -= 1;
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
