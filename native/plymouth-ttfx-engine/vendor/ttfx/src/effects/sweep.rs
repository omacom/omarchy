//! sweep, ported from effects/effect_sweep.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_character_group, parse_gradient_direction, parse_gradient_steps, parse_symbol,
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
pub struct SweepConfig {
    /// Space separated list of symbols to use for the sweep shimmer.
    #[arg(long = "sweep-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["█", "▓", "▒", "░"])]
    pub sweep_symbols: Vec<String>,

    /// Direction of the first sweep, revealing uncolored characters.
    #[arg(long = "first-sweep-direction", default_value = "column_right_to_left",
          value_parser = parse_character_group)]
    pub first_sweep_direction: CharacterGroup,

    /// Direction of the second sweep, coloring the characters.
    #[arg(long = "second-sweep-direction", default_value = "column_left_to_right",
          value_parser = parse_character_group)]
    pub second_sweep_direction: CharacterGroup,

    /// Space separated, unquoted, list of colors for the character gradient (applied from bottom to top).
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "ffffff"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["8"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Sweep {
    config: SweepConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
    dynamic_second_sweep_palette: Vec<Color>,
    complete: bool,
    first_phase: bool,
    easer: Option<SequenceEaser<Vec<CharId>>>,
    groups_second_sweep: Vec<Vec<CharId>>,
}

impl Sweep {
    pub fn new(config: SweepConfig) -> Self {
        Sweep {
            config,
            character_final_color_map: HashMap::new(),
            dynamic_second_sweep_palette: Vec::new(),
            complete: false,
            first_phase: true,
            easer: None,
            groups_second_sweep: Vec::new(),
        }
    }
}

impl EffectHooks for Sweep {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Sweep {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_fg_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_fg_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let shades_of_gray: Vec<Color> = ["A0A0A0", "808080", "404040", "202020", "101010"]
            .iter()
            .map(|hex| Color::from_hex(hex).unwrap())
            .collect();

        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        if dynamic {
            let characters = {
                let filter = CharacterFilter::default();
                ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
            };
            for id in characters {
                let ch = &ctx.terminal.arena[id.0 as usize];
                if let Some(fg) = &ch.animation.input_fg_color {
                    self.dynamic_second_sweep_palette.push(fg.clone());
                }
                if let Some(bg) = &ch.animation.input_bg_color {
                    self.dynamic_second_sweep_palette.push(bg.clone());
                }
            }
            if self.dynamic_second_sweep_palette.is_empty() {
                self.dynamic_second_sweep_palette = final_fg_gradient.spectrum.clone();
            }
        }

        let fills_filter =
            CharacterFilter { inner_fill_chars: true, outer_fill_chars: true, ..Default::default() };
        let characters =
            ctx.terminal.get_characters(&mut ctx.rng, fills_filter, CharacterSort::TopToBottomLeftToRight);
        for id in characters {
            let (is_fill, input_fg, input_bg, input_coord, input_symbol, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (
                    ch.is_fill_character,
                    ch.animation.input_fg_color.clone(),
                    ch.animation.input_bg_color.clone(),
                    ch.input_coord,
                    ch.input_symbol.clone(),
                    ch.uses_input_preexisting_colors,
                )
            };
            if !is_fill {
                let final_colors = if dynamic {
                    ColorPair::new(input_fg, input_bg)
                } else {
                    ColorPair::new(Some(final_gradient_mapping.get(&input_coord).unwrap().clone()), None)
                };
                self.character_final_color_map.insert(id, final_colors);
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "initial_sweep", uses_pre);
            }
            for symbol in &self.config.sweep_symbols {
                let color = ctx.rng.choice(&shades_of_gray).clone();
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("initial_sweep")
                    .unwrap()
                    .add_frame(
                        symbol,
                        5,
                        VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("initial_sweep")
                    .unwrap()
                    .add_frame(
                        &input_symbol,
                        1,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(Color::from_hex("#808080").unwrap()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                ch.animation.new_scene(false, None, None, "second_sweep", uses_pre);
            }
            for symbol in &self.config.sweep_symbols {
                let color = if dynamic {
                    ctx.rng.choice(&self.dynamic_second_sweep_palette).clone()
                } else {
                    ctx.rng.choice(&final_fg_gradient.spectrum).clone()
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("second_sweep")
                    .unwrap()
                    .add_frame(
                        symbol,
                        5,
                        VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
            let final_colors = if !is_fill {
                self.character_final_color_map.get(&id).unwrap().clone()
            } else if dynamic {
                ColorPair::default()
            } else {
                ColorPair::new(Some(Color::from_hex("000000").unwrap()), None)
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("second_sweep")
                    .unwrap()
                    .add_frame(
                        &input_symbol,
                        1,
                        VisualParams { colors: Some(final_colors), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
        }

        let groups_first_sweep =
            ctx.terminal.get_characters_grouped(fills_filter, self.config.first_sweep_direction);
        self.easer = Some(SequenceEaser::new(groups_first_sweep, Easing::InOutCirc, 100));
        self.groups_second_sweep =
            ctx.terminal.get_characters_grouped(fills_filter, self.config.second_sweep_direction);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !ctx.active_characters.is_empty() || !self.complete {
            let mut easer = self.easer.take().unwrap();
            let step = easer.step();
            for group in step.added {
                for &id in group {
                    if self.first_phase {
                        ctx.terminal.set_character_visibility(id, true);
                    }
                    let scene_id = if self.first_phase { "initial_sweep" } else { "second_sweep" };
                    ctx.activate_scene(self, id, scene_id);
                }
                for &id in group {
                    ctx.active_characters.insert(id);
                }
            }
            let easer_complete = easer.is_complete();
            if easer_complete && self.first_phase {
                easer.sequence = std::mem::take(&mut self.groups_second_sweep);
                easer.reset();
                self.first_phase = false;
            } else if easer_complete && !self.first_phase {
                self.complete = true;
            }
            self.easer = Some(easer);
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
