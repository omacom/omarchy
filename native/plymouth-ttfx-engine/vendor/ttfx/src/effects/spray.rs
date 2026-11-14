//! spray, ported from effects/effect_spray.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float_range, parse_positive_ratio,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::floor_div;

/// SprayIterator.SprayPosition.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SprayPosition {
    N,
    Ne,
    E,
    Se,
    S,
    Sw,
    W,
    Nw,
    Center,
}

fn parse_spray_position(s: &str) -> Result<SprayPosition, String> {
    Ok(match s {
        "n" => SprayPosition::N,
        "ne" => SprayPosition::Ne,
        "e" => SprayPosition::E,
        "se" => SprayPosition::Se,
        "s" => SprayPosition::S,
        "sw" => SprayPosition::Sw,
        "w" => SprayPosition::W,
        "nw" => SprayPosition::Nw,
        "center" => SprayPosition::Center,
        _ => {
            return Err(format!(
                "invalid choice: '{s}' (choose from 'n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw', 'center')"
            ))
        }
    })
}

#[derive(Args, Debug, Clone)]
pub struct SprayConfig {
    /// Position for the spray origin.
    #[arg(long = "spray-position", default_value = "e", value_parser = parse_spray_position)]
    pub spray_position: SprayPosition,

    /// Number of characters to spray per tick as a percent of the total number of characters.
    #[arg(long = "spray-volume", default_value_t = 0.005, value_parser = parse_positive_ratio)]
    pub spray_volume: f64,

    /// Movement speed range of the characters.
    #[arg(long = "movement-speed-range", default_value = "0.6-1.4", value_parser = parse_positive_float_range)]
    pub movement_speed_range: (f64, f64),

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "out_expo", value_parser = parse_easing)]
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
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Spray {
    config: SprayConfig,
    pending_chars: Vec<CharId>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    volume: i64,
}

impl Spray {
    pub fn new(config: SprayConfig) -> Self {
        Spray { config, pending_chars: Vec::new(), character_final_color_map: HashMap::new(), volume: 1 }
    }
}

impl EffectHooks for Spray {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Spray {
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
        for &id in &characters {
            let final_colors = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                if dynamic {
                    ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
                } else {
                    ColorPair::new(Some(final_gradient_mapping.get(&ch.input_coord).unwrap().clone()), None)
                }
            };
            self.character_final_color_map.insert(id, final_colors);
        }

        let canvas = &ctx.terminal.canvas;
        let spray_origin = match self.config.spray_position {
            SprayPosition::Center => canvas.center,
            SprayPosition::N => Coord::new(floor_div(canvas.right, 2), canvas.top),
            SprayPosition::Nw => Coord::new(canvas.left, canvas.top),
            SprayPosition::W => Coord::new(canvas.left, floor_div(canvas.top, 2)),
            SprayPosition::Sw => Coord::new(canvas.left, canvas.bottom),
            SprayPosition::S => Coord::new(floor_div(canvas.right, 2), canvas.bottom),
            SprayPosition::Se => Coord::new(canvas.right - 1, canvas.bottom),
            SprayPosition::E => Coord::new(canvas.right - 1, floor_div(canvas.top, 2)),
            SprayPosition::Ne => Coord::new(canvas.right - 1, canvas.top),
        };

        for id in characters {
            let (input_coord, input_symbol, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.input_coord, ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
            };
            let speed = ctx.rng.uniform(self.config.movement_speed_range.0, self.config.movement_speed_range.1);
            let input_coord_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(spray_origin);
                let path_id = ch
                    .motion
                    .new_path(speed, Some(self.config.movement_easing), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            ctx.register_event(
                id,
                Event::PathActivated,
                CallerKey::Path(input_coord_path.clone()),
                EventAction::SetLayer(1),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(input_coord_path.clone()),
                EventAction::SetLayer(0),
            )
            .map_err(EngineError::Other)?;

            let droplet_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
            if dynamic {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&droplet_scn).unwrap();
                for _ in 0..7 {
                    scene
                        .add_frame(
                            &input_symbol,
                            20,
                            VisualParams { colors: Some(final_colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let start_color = ctx.rng.choice(&final_gradient.spectrum).clone();
                let final_fg = final_colors.fg_color.clone().expect("gradient mapping fg");
                let spray_gradient =
                    Gradient::with_steps(&[start_color, final_fg], 7, false).map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&droplet_scn)
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 20, Some(&spray_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            ctx.activate_scene(self, id, &droplet_scn);
            ctx.activate_path(self, id, &input_coord_path);
            self.pending_chars.push(id);
        }
        ctx.rng.shuffle(&mut self.pending_chars);
        self.volume = std::cmp::max((self.pending_chars.len() as f64 * self.config.spray_volume) as i64, 1);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_chars.is_empty() || !ctx.active_characters.is_empty() {
            if !self.pending_chars.is_empty() {
                for _ in 0..ctx.rng.randint(1, self.volume) {
                    if let Some(next_character) = self.pending_chars.pop() {
                        ctx.terminal.set_character_visibility(next_character, true);
                        ctx.active_characters.insert(next_character);
                    }
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
