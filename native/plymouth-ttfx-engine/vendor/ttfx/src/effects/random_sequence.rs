//! randomsequence, ported from effects/effect_random_sequence.py.

use std::collections::HashMap;

use clap::Args;

use crate::effects::common::{parse_gradient_direction, parse_gradient_steps, parse_positive_float};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

use crate::cli::parse_color;

#[derive(Args, Debug, Clone)]
pub struct RandomSequenceConfig {
    /// Speed of the animation as a percentage of the total number of characters to reveal in each tick.
    #[arg(long, default_value_t = 0.007, value_parser = parse_positive_float)]
    pub speed: f64,

    /// Space separated, unquoted, list of colors for the final gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step.
    #[arg(long = "final-gradient-frames", default_value_t = 8)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct RandomSequence {
    config: RandomSequenceConfig,
    pending_chars: Vec<CharId>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    characters_per_tick: i64,
}

const DYNAMIC_NEUTRAL_GRAY: &str = "808080";

impl RandomSequence {
    pub fn new(config: RandomSequenceConfig) -> Self {
        RandomSequence {
            config,
            pending_chars: Vec::new(),
            character_final_color_map: HashMap::new(),
            characters_per_tick: 1,
        }
    }
}

impl EffectHooks for RandomSequence {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for RandomSequence {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // characters_per_tick = max(int(speed * len(input_characters)), 1)
        self.characters_per_tick =
            std::cmp::max((self.config.speed * ctx.terminal.input_characters.len() as f64) as i64, 1);

        let terminal_background_color = ctx.terminal.config.terminal_background_color.clone();
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
            ctx.terminal.set_character_visibility(id, false);

            let scene_id = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            let symbols = vec![input_symbol.clone()];
            let frames = self.config.final_gradient_frames;
            {
                let scene = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.scenes.get_mut(&scene_id).unwrap()
                };
                if dynamic {
                    let final_fg = final_colors.fg_color.clone();
                    let final_bg = final_colors.bg_color.clone();
                    if final_fg.is_some() || final_bg.is_some() {
                        let fg_gradient = match &final_fg {
                            Some(c) => Some(
                                Gradient::with_steps(&[terminal_background_color.clone(), c.clone()], 7, false)
                                    .map_err(EngineError::Other)?,
                            ),
                            None => None,
                        };
                        let bg_gradient = match &final_bg {
                            Some(c) => Some(
                                Gradient::with_steps(&[terminal_background_color.clone(), c.clone()], 7, false)
                                    .map_err(EngineError::Other)?,
                            ),
                            None => None,
                        };
                        scene
                            .apply_gradient_to_symbols(&symbols, frames, fg_gradient.as_ref(), bg_gradient.as_ref())
                            .map_err(EngineError::Other)?;
                    } else {
                        let neutral = Gradient::with_steps(
                            &[terminal_background_color.clone(), Color::from_hex(DYNAMIC_NEUTRAL_GRAY).unwrap()],
                            7,
                            false,
                        )
                        .map_err(EngineError::Other)?;
                        scene
                            .apply_gradient_to_symbols(&symbols, frames, Some(&neutral), None)
                            .map_err(EngineError::Other)?;
                        scene
                            .add_frame(
                                &input_symbol,
                                frames,
                                crate::engine::animation::VisualParams {
                                    colors: Some(ColorPair::default()),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let final_fg = final_colors.fg_color.clone().expect("gradient mapping fg");
                    let gradient = Gradient::with_steps(&[terminal_background_color.clone(), final_fg], 7, false)
                        .map_err(EngineError::Other)?;
                    scene
                        .apply_gradient_to_symbols(&symbols, frames, Some(&gradient), None)
                        .map_err(EngineError::Other)?;
                }
            }
            ctx.activate_scene(self, id, &scene_id);
            self.pending_chars.push(id);
        }
        ctx.rng.shuffle(&mut self.pending_chars);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_chars.is_empty() || !ctx.active_characters.is_empty() {
            for _ in 0..self.characters_per_tick {
                if let Some(next_char) = self.pending_chars.pop() {
                    ctx.terminal.set_character_visibility(next_char, true);
                    ctx.active_characters.insert(next_char);
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
