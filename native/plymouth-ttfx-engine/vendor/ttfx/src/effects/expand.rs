//! expand, ported from effects/effect_expand.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float};
use crate::engine::animation::{ExistingColorHandling, SyncMetric, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct ExpandConfig {
    /// Easing function to use for character movement.
    #[arg(long = "expand-easing", default_value = "in_out_quart", value_parser = parse_easing)]
    pub expand_easing: Easing,

    /// Movement speed of the characters.
    #[arg(long = "movement-speed", default_value_t = 0.35, value_parser = parse_positive_float)]
    pub movement_speed: f64,

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

pub struct Expand {
    config: ExpandConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
}

impl Expand {
    pub fn new(config: ExpandConfig) -> Self {
        Expand { config, character_final_color_map: HashMap::new() }
    }
}

impl EffectHooks for Expand {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Expand {
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
            let center = ctx.terminal.canvas.center;
            let input_coord_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(center);
                let path_id = ch
                    .motion
                    .new_path(self.config.movement_speed, Some(self.config.expand_easing), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            ctx.terminal.set_character_visibility(id, true);
            ctx.active_characters.insert(id);
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
            ctx.activate_path(self, id, &input_coord_path);
            let gradient_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, Some(SyncMetric::Distance), None, "", uses_pre)
            };
            let symbols = vec![input_symbol.clone()];
            {
                let scene = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.scenes.get_mut(&gradient_scn).unwrap()
                };
                if dynamic {
                    let fg_gradient = match &input_fg {
                        Some(c) => Some(
                            Gradient::with_steps(&[final_gradient.spectrum[0].clone(), c.clone()], 10, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let bg_gradient = match &input_bg {
                        Some(c) => Some(
                            Gradient::with_steps(&[final_gradient.spectrum[0].clone(), c.clone()], 10, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    if fg_gradient.is_some() || bg_gradient.is_some() {
                        scene
                            .apply_gradient_to_symbols(&symbols, 1, fg_gradient.as_ref(), bg_gradient.as_ref())
                            .map_err(EngineError::Other)?;
                    } else {
                        scene
                            .add_frame(
                                &input_symbol,
                                1,
                                VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let final_fg = self.character_final_color_map[&id]
                        .fg_color
                        .clone()
                        .expect("gradient mapping fg");
                    let gradient =
                        Gradient::with_steps(&[final_gradient.spectrum[0].clone(), final_fg], 10, false)
                            .map_err(EngineError::Other)?;
                    scene
                        .apply_gradient_to_symbols(&symbols, 5, Some(&gradient), None)
                        .map_err(EngineError::Other)?;
                }
            }
            ctx.activate_scene(self, id, &gradient_scn);
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
