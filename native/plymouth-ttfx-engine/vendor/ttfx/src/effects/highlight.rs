//! highlight, ported from effects/effect_highlight.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_character_group, parse_gradient_direction, parse_gradient_steps, parse_positive_float, parse_positive_int,
};
use crate::engine::animation::{Animation, ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::{Easing, SequenceEaser};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct HighlightConfig {
    /// Brightness of the highlight color.
    #[arg(long = "highlight-brightness", default_value_t = 1.75, value_parser = parse_positive_float)]
    pub highlight_brightness: f64,

    /// Direction the highlight will travel.
    #[arg(long = "highlight-direction", default_value = "diagonal_bottom_left_to_top_right",
          value_parser = parse_character_group)]
    pub highlight_direction: CharacterGroup,

    /// Width of the highlight. n >= 1
    #[arg(long = "highlight-width", default_value_t = 8, value_parser = parse_positive_int)]
    pub highlight_width: i64,

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

pub struct Highlight {
    config: HighlightConfig,
    #[allow(dead_code)] // upstream stores this map; nothing reads it (faithful)
    character_final_color_map: HashMap<CharId, Option<Color>>,
    easer: Option<SequenceEaser<Vec<CharId>>>,
}

impl Highlight {
    pub fn new(config: HighlightConfig) -> Self {
        Highlight { config, character_final_color_map: HashMap::new(), easer: None }
    }
}

impl EffectHooks for Highlight {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Highlight {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let groups =
            ctx.terminal.get_characters_grouped(CharacterFilter::default(), self.config.highlight_direction);
        self.easer = Some(SequenceEaser::new(groups, Easing::InOutCirc, 100));

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
            let (base_color, input_bg_color) = if dynamic {
                (input_fg, input_bg)
            } else {
                (Some(final_gradient_mapping.get(&input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, base_color.clone());
            let base_colors = ColorPair::new(base_color.clone(), input_bg_color.clone());
            let highlight_gradient = match &base_color {
                Some(base) => {
                    let highlight_color =
                        Animation::adjust_color_brightness(base, self.config.highlight_brightness);
                    Some(
                        Gradient::new(
                            &[base.clone(), highlight_color.clone(), highlight_color, base.clone()],
                            &[3, self.config.highlight_width, 3],
                            false,
                            false,
                        )
                        .map_err(EngineError::Other)?,
                    )
                }
                None => None,
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.set_appearance(&input_symbol, uses_pre, Some(&input_symbol), Some(base_colors.clone()));
                ch.animation.new_scene(false, None, None, "highlight", uses_pre);
                let scene = ch.animation.scenes.get_mut("highlight").unwrap();
                if let Some(gradient) = &highlight_gradient {
                    for color in &gradient.spectrum {
                        scene
                            .add_frame(
                                &input_symbol,
                                2,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(color.clone()), input_bg_color.clone())),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            2,
                            VisualParams { colors: Some(base_colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
            ctx.terminal.set_character_visibility(id, true);
        }
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        let easer_complete = self.easer.as_ref().unwrap().is_complete();
        if !ctx.active_characters.is_empty() || !easer_complete {
            let mut easer = self.easer.take().unwrap();
            let step = easer.step();
            for group in step.added {
                for &id in group {
                    ctx.activate_scene(self, id, "highlight");
                    ctx.active_characters.insert(id);
                }
            }
            self.easer = Some(easer);
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
