//! scattered, ported from effects/effect_scattered.py.

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
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct ScatteredConfig {
    /// Movement speed of the characters.
    #[arg(long = "movement-speed", default_value_t = 0.5, value_parser = parse_positive_float)]
    pub movement_speed: f64,

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "in_out_back", value_parser = parse_easing)]
    pub movement_easing: Easing,

    /// Space separated, unquoted, list of colors for the character gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ff9048", "ab9dff", "bdffea"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step.
    #[arg(long = "final-gradient-frames", default_value_t = 9)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Scattered {
    config: ScatteredConfig,
    pending_chars: Vec<CharId>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    initial_hold_frames: i64,
}

impl Scattered {
    pub fn new(config: ScatteredConfig) -> Self {
        Scattered {
            config,
            pending_chars: Vec::new(),
            character_final_color_map: HashMap::new(),
            initial_hold_frames: 0,
        }
    }
}

impl EffectHooks for Scattered {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Scattered {
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
            let start_coord = if ctx.terminal.canvas.right < 2 || ctx.terminal.canvas.top < 2 {
                Coord::new(1, 1)
            } else {
                ctx.terminal.canvas.random_coord(&mut ctx.rng, false, false)
            };
            let input_coord_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(start_coord);
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
            ctx.terminal.set_character_visibility(id, true);
            let gradient_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, Some(SyncMetric::Distance), None, "", uses_pre)
            };
            {
                let scene = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.scenes.get_mut(&gradient_scn).unwrap()
                };
                if dynamic {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.final_gradient_frames,
                            VisualParams { colors: Some(final_colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    let final_fg_color = final_colors.fg_color.clone().expect("gradient mapping fg");
                    let char_gradient =
                        Gradient::with_steps(&[final_gradient.spectrum[0].clone(), final_fg_color], 10, false)
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
            ctx.active_characters.insert(id);
        }
        self.initial_hold_frames = 25;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_chars.is_empty() || !ctx.active_characters.is_empty() {
            if self.initial_hold_frames != 0 {
                self.initial_hold_frames -= 1;
                return Some(ctx.frame());
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
