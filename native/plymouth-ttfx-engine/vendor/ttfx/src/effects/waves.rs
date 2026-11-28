//! waves, ported from effects/effect_waves.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_int, parse_symbol,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

/// waves --wave-direction choices (a subset of CharacterGroup, upstream grouping_map).
fn parse_wave_direction(s: &str) -> Result<CharacterGroup, String> {
    Ok(match s {
        "column_left_to_right" => CharacterGroup::ColumnLeftToRight,
        "column_right_to_left" => CharacterGroup::ColumnRightToLeft,
        "row_top_to_bottom" => CharacterGroup::RowTopToBottom,
        "row_bottom_to_top" => CharacterGroup::RowBottomToTop,
        "center_to_outside" => CharacterGroup::CenterToOutside,
        "outside_to_center" => CharacterGroup::OutsideToCenter,
        _ => return Err(format!("invalid wave direction: '{s}'")),
    })
}

#[derive(Args, Debug, Clone)]
pub struct WavesConfig {
    /// Symbols to use for the wave animation.
    #[arg(long = "wave-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁"])]
    pub wave_symbols: Vec<String>,

    /// Space separated, unquoted, list of colors for the character gradient (applied across the canvas).
    #[arg(long = "wave-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["f0ff65", "ffb102", "31a0d4", "ffb102", "f0ff65"])]
    pub wave_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, list of the number of gradient steps to use.
    #[arg(long = "wave-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["6"])]
    pub wave_gradient_steps: Vec<i64>,

    /// Number of waves to generate. n > 0.
    #[arg(long = "wave-count", default_value_t = 7, value_parser = parse_positive_int)]
    pub wave_count: i64,

    /// The number of frames for each step of the wave.
    #[arg(long = "wave-length", default_value_t = 2, value_parser = parse_positive_int)]
    pub wave_length: i64,

    /// Direction of the wave.
    #[arg(long = "wave-direction", default_value = "column_left_to_right", value_parser = parse_wave_direction)]
    pub wave_direction: CharacterGroup,

    /// Easing function to use for wave travel.
    #[arg(long = "wave-easing", default_value = "in_out_sine", value_parser = parse_easing)]
    pub wave_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ffb102", "31a0d4", "f0ff65"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Waves {
    config: WavesConfig,
    pending_columns: Vec<Vec<CharId>>,
    character_final_color_map: HashMap<CharId, ColorPair>,
}

impl Waves {
    pub fn new(config: WavesConfig) -> Self {
        Waves { config, pending_columns: Vec::new(), character_final_color_map: HashMap::new() }
    }
}

impl EffectHooks for Waves {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Waves {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let wave_gradient =
            Gradient::new(&self.config.wave_gradient_stops, &self.config.wave_gradient_steps, false, false)
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

            let wave_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene_id = ch.animation.new_scene(false, None, Some(self.config.wave_easing), "", uses_pre);
                let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                for _ in 0..self.config.wave_count {
                    scene
                        .apply_gradient_to_symbols(
                            &self.config.wave_symbols,
                            self.config.wave_length,
                            Some(&wave_gradient),
                            None,
                        )
                        .map_err(EngineError::Other)?;
                }
                scene_id
            };
            let final_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            if dynamic {
                let final_fg_color = final_colors.fg_color.clone();
                let final_bg_color = final_colors.bg_color.clone();
                if final_fg_color.is_none() && final_bg_color.is_none() {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation
                        .scenes
                        .get_mut(&final_scn)
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            10,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    let fg_gradient = match &final_fg_color {
                        Some(c) => Some(
                            Gradient::new(
                                &[wave_gradient.spectrum.last().unwrap().clone(), c.clone()],
                                &self.config.final_gradient_steps,
                                false,
                                false,
                            )
                            .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let bg_gradient = match &final_bg_color {
                        Some(c) => Some(
                            Gradient::new(
                                &[wave_gradient.spectrum.last().unwrap().clone(), c.clone()],
                                &self.config.final_gradient_steps,
                                false,
                                false,
                            )
                            .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut(&final_scn).unwrap();
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            10,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                    if final_fg_color.is_none() {
                        scene
                            .add_frame(
                                &input_symbol,
                                10,
                                VisualParams {
                                    colors: Some(ColorPair::new(None, final_bg_color.clone())),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
            } else {
                let final_fg_color =
                    final_colors.fg_color.clone().expect("gradient mapping fg");
                let final_scene_gradient = Gradient::new(
                    &[wave_gradient.spectrum.last().unwrap().clone(), final_fg_color],
                    &self.config.final_gradient_steps,
                    false,
                    false,
                )
                .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&final_scn).unwrap();
                for step in &final_scene_gradient.spectrum {
                    scene
                        .add_frame(
                            &input_symbol,
                            10,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(step.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(wave_scn.clone()),
                EventAction::ActivateScene(final_scn),
            )
            .map_err(EngineError::Other)?;
            ctx.activate_scene(self, id, &wave_scn);
            if dynamic {
                let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.set_appearance(&input_symbol, uses_pre, Some(&input_symbol), Some(final_colors));
            }
        }

        for column in ctx.terminal.get_characters_grouped(CharacterFilter::default(), self.config.wave_direction) {
            self.pending_columns.push(column);
        }
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_columns.is_empty() || !ctx.active_characters.is_empty() {
            if !self.pending_columns.is_empty() {
                let next_column = self.pending_columns.remove(0);
                for id in next_column {
                    ctx.terminal.set_character_visibility(id, true);
                    ctx.active_characters.insert(id);
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
