//! wipe, ported from effects/effect_wipe.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_character_group, parse_easing, parse_gradient_direction, parse_gradient_steps, parse_non_negative_int,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::{Easing, SequenceEaser};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct WipeConfig {
    /// Direction the text will wipe.
    #[arg(long = "wipe-direction", default_value = "diagonal_top_left_to_bottom_right",
          value_parser = parse_character_group)]
    pub wipe_direction: CharacterGroup,

    /// Number of frames to wait before adding the next character group.
    #[arg(long = "wipe-delay", default_value_t = 0, value_parser = parse_non_negative_int)]
    pub wipe_delay: i64,

    /// Easing function to use for the wipe effect.
    #[arg(long = "wipe-ease", default_value = "in_out_circ", value_parser = parse_easing)]
    pub wipe_ease: Easing,

    /// Space separated, unquoted, list of colors for the wipe gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["833ab4", "fd1d1d", "fcb045"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step.
    #[arg(long = "final-gradient-frames", default_value_t = 3)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Wipe {
    config: WipeConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
    easer: Option<SequenceEaser<Vec<CharId>>>,
    wipe_delay: i64,
}

impl Wipe {
    pub fn new(config: WipeConfig) -> Self {
        let wipe_delay = config.wipe_delay;
        Wipe { config, character_final_color_map: HashMap::new(), easer: None, wipe_delay }
    }
}

impl EffectHooks for Wipe {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Wipe {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let groups = ctx.terminal.get_characters_grouped(CharacterFilter::default(), self.config.wipe_direction);
        self.easer = Some(SequenceEaser::new(groups, self.config.wipe_ease, 100));

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

            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "wipe", uses_pre);
                let scene = ch.animation.scenes.get_mut("wipe").unwrap();
                if dynamic {
                    let frame_count: i64 = self.config.final_gradient_steps.iter().sum::<i64>() + 1;
                    for _ in 0..frame_count {
                        scene
                            .add_frame(
                                &input_symbol,
                                self.config.final_gradient_frames,
                                VisualParams { colors: Some(final_colors.clone()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let final_fg = final_colors.fg_color.clone().expect("gradient mapping fg");
                    let wipe_gradient = Gradient::new(
                        &[final_gradient.spectrum[0].clone(), final_fg],
                        &self.config.final_gradient_steps,
                        false,
                        false,
                    )
                    .map_err(EngineError::Other)?;
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            self.config.final_gradient_frames,
                            Some(&wipe_gradient),
                            None,
                        )
                        .map_err(EngineError::Other)?;
                }
            }
        }
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        let easer_complete = self.easer.as_ref().unwrap().is_complete();
        if !ctx.active_characters.is_empty() || !easer_complete {
            if self.wipe_delay == 0 {
                let mut easer = self.easer.take().unwrap();
                let step = easer.step();
                for group in step.added {
                    for &id in group {
                        ctx.activate_scene(self, id, "wipe");
                        ctx.terminal.set_character_visibility(id, true);
                        ctx.active_characters.insert(id);
                    }
                }
                for group in step.removed {
                    for &id in group {
                        ctx.deactivate_scene(id, None);
                        ctx.terminal.arena[id.0 as usize]
                            .animation
                            .scenes
                            .get_mut("wipe")
                            .unwrap()
                            .reset_scene();
                        ctx.terminal.set_character_visibility(id, false);
                    }
                }
                self.easer = Some(easer);
                self.wipe_delay = self.config.wipe_delay;
            } else {
                self.wipe_delay -= 1;
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
