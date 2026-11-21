//! colorshift, ported from effects/effect_colorshift.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps, parse_positive_int};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::geometry;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct ColorShiftConfig {
    /// Space separated, unquoted, list of colors for the gradient.
    #[arg(long = "gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["e81416", "ffa500", "faeb36", "79c314", "487de7", "4b369d", "70369d"])]
    pub gradient_stops: Vec<Color>,

    /// Number of gradient steps to use. More steps will create a smoother gradient animation.
    #[arg(long = "gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step. Increase to slow down the gradient animation.
    #[arg(long = "gradient-frames", default_value_t = 2, value_parser = parse_positive_int)]
    pub gradient_frames: i64,

    /// Do not display the gradient as a wave.
    #[arg(long = "no-travel")]
    pub no_travel: bool,

    /// Direction the gradient travels across the canvas.
    #[arg(long = "travel-direction", default_value = "radial", value_parser = parse_gradient_direction)]
    pub travel_direction: GradientDirection,

    /// Reverse the gradient travel direction.
    #[arg(long = "reverse-travel-direction")]
    pub reverse_travel_direction: bool,

    /// Do not loop the gradient.
    #[arg(long = "no-loop")]
    pub no_loop: bool,

    /// Number of times to cycle the gradient.
    #[arg(long = "cycles", default_value_t = 3, value_parser = parse_positive_int)]
    pub cycles: i64,

    /// Skip the final gradient.
    #[arg(long = "skip-final-gradient")]
    pub skip_final_gradient: bool,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["e81416", "ffa500", "faeb36", "79c314", "487de7", "4b369d", "70369d"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use for the final gradient.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct ColorShift {
    config: ColorShiftConfig,
    character_final_color_map: HashMap<CharId, Color>,
    loop_tracker_map: HashMap<CharId, i64>,
}

impl ColorShift {
    pub fn new(config: ColorShiftConfig) -> Self {
        ColorShift { config, character_final_color_map: HashMap::new(), loop_tracker_map: HashMap::new() }
    }
}

impl EffectHooks for ColorShift {
    /// ColorShiftIterator.loop_tracker.
    fn dispatch_callback(&mut self, ctx: &mut EngineCtx, character: CharId, _callback: &EffectCallback) {
        let count = {
            let entry = self.loop_tracker_map.entry(character).or_insert(0);
            *entry += 1;
            *entry
        };
        if self.config.cycles == 0 || count < self.config.cycles {
            ctx.activate_scene(self, character, "gradient");
        } else if !self.config.skip_final_gradient {
            ctx.activate_scene(self, character, "final_gradient");
        }
    }
}

impl Effect for ColorShift {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &characters {
            let input_coord = ctx.terminal.arena[id.0 as usize].input_coord;
            self.character_final_color_map
                .insert(id, final_gradient_mapping.get(&input_coord).unwrap().clone());
        }
        let gradient =
            Gradient::new(&self.config.gradient_stops, &self.config.gradient_steps, false, !self.config.no_loop)
                .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            ctx.terminal.set_character_visibility(id, true);
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
            let colors: Vec<Color> = if self.config.no_travel {
                gradient.spectrum.clone()
            } else {
                let direction_index = match self.config.travel_direction {
                    GradientDirection::Horizontal => {
                        input_coord.column as f64 / ctx.terminal.canvas.right as f64
                    }
                    GradientDirection::Vertical => input_coord.row as f64 / ctx.terminal.canvas.top as f64,
                    GradientDirection::Diagonal => {
                        (input_coord.row + input_coord.column) as f64
                            / (ctx.terminal.canvas.right + ctx.terminal.canvas.top) as f64
                    }
                    GradientDirection::Radial => geometry::find_normalized_distance_from_center(
                        ctx.terminal.canvas.text_bottom,
                        ctx.terminal.canvas.text_top,
                        ctx.terminal.canvas.text_left,
                        ctx.terminal.canvas.text_right,
                        input_coord,
                    )
                    .map_err(EngineError::Other)?,
                };
                // int() truncation
                let mut shift_distance = (gradient.spectrum.len() as f64 * direction_index) as i64;
                if self.config.reverse_travel_direction {
                    shift_distance *= -1;
                }
                // Python slicing: spectrum[shift:] + spectrum[:shift], negative shifts wrap
                let len = gradient.spectrum.len() as i64;
                let k = if shift_distance < 0 {
                    (len + shift_distance).max(0) as usize
                } else {
                    shift_distance.min(len) as usize
                };
                let mut rotated = gradient.spectrum[k..].to_vec();
                rotated.extend_from_slice(&gradient.spectrum[..k]);
                rotated
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "gradient", uses_pre);
                let scene = ch.animation.scenes.get_mut("gradient").unwrap();
                for color in &colors {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.gradient_frames,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
                ch.animation.new_scene(false, None, None, "final_gradient", uses_pre);
            }
            let last_color = colors.last().unwrap().clone();
            if dynamic {
                let fg_gradient = match &input_fg {
                    Some(c) => Some(
                        Gradient::with_steps(&[last_color.clone(), c.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &input_bg {
                    Some(c) => Some(
                        Gradient::with_steps(&[last_color.clone(), c.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut("final_gradient").unwrap();
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            self.config.gradient_frames,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.gradient_frames,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                let final_scene_gradient =
                    Gradient::with_steps(&[last_color, final_color], 8, false).map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut("final_gradient").unwrap();
                for color in &final_scene_gradient.spectrum {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.gradient_frames,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
            ctx.activate_scene(self, id, "gradient");
            ctx.active_characters.insert(id);
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("gradient".to_string()),
                EventAction::Callback(EffectCallback { id: 0, args: Vec::new() }),
            )
            .map_err(EngineError::Other)?;
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
