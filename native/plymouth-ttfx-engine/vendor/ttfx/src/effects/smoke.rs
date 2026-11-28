//! smoke, ported from effects/effect_smoke.py.
//!
//! RNG order mirrors SmokeIterator.__init__: PrimsWeighted construction
//! (random starting coord + one randint(0, 99) weight per character over
//! get_characters(inner+outer fill)), then the BreadthFirst starting-coord
//! draw, then build() (PrimsWeighted run to completion). __next__ consumes no
//! RNG. BreadthFirst's links-set traversal is the canonical ascending
//! character_id order (shim-patched; docs/ordering-inventory.md) — no new
//! observable set iterations in this effect.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps, parse_symbol};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::spanning_tree::{BreadthFirst, PrimsWeighted};

#[derive(Args, Debug, Clone)]
pub struct SmokeConfig {
    /// Color of the text before being colorized by the smoke.
    #[arg(long = "starting-color", default_value = "7A7A7A", value_parser = parse_color)]
    pub starting_color: Color,

    /// Symbols to use for the smoke. Strings will be used in sequence to create an animation.
    #[arg(long = "smoke-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["░", "▒", "▓", "▒", "░"])]
    pub smoke_symbols: Vec<String>,

    /// Space separated, unquoted, list of colors for the smoke gradient.
    #[arg(long = "smoke-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["242424", "FFFFFF"])]
    pub smoke_gradient_stops: Vec<Color>,

    /// If True, the entire canvas will be flooded. Otherwise the effect is limited to the text boundary.
    #[arg(long = "use-whole-canvas", default_value_t = false)]
    pub use_whole_canvas: bool,

    /// Space separated, unquoted, list of colors for the character gradient (applied across the canvas).
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

pub struct Smoke {
    config: SmokeConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
    /// Option so next_frame can move it out of self while stepping needs ctx
    /// and event dispatch needs &mut self.
    fill_alg: Option<BreadthFirst>,
}

impl Smoke {
    pub fn new(config: SmokeConfig) -> Self {
        Smoke { config, character_final_color_map: HashMap::new(), fill_alg: None }
    }
}

impl EffectHooks for Smoke {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Smoke {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // SmokeIterator.__init__ order: PrimsWeighted (random starting coord +
        // per-character weights), then the BreadthFirst starting character
        // (random coord lookup; a failed lookup falls back to BreadthFirst's
        // own draw, exactly like Python's `starting_char or ...`).
        let limit_to_text_boundary = !self.config.use_whole_canvas;
        let mut gen_alg = PrimsWeighted::new(ctx, None, limit_to_text_boundary).map_err(EngineError::Other)?;
        let fill_start_coord = ctx.terminal.canvas.random_coord(&mut ctx.rng, false, limit_to_text_boundary);
        let fill_start_char = ctx.terminal.get_character_by_input_coord(fill_start_coord);
        let fill_alg =
            BreadthFirst::new(ctx, fill_start_char, limit_to_text_boundary).map_err(EngineError::Other)?;

        // SmokeIterator.build()
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let blk = Color::from_hex("000000").unwrap();
        // Gradient(*smoke_gradient_stops, *final_gradient_stops[::-1], steps=(3, 4))
        let smoke_gradient_colors: Vec<Color> = self
            .config
            .smoke_gradient_stops
            .iter()
            .chain(self.config.final_gradient_stops.iter().rev())
            .cloned()
            .collect();
        let smoke_gradient =
            Gradient::new(&smoke_gradient_colors, &[3, 4], false, false).map_err(EngineError::Other)?;

        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter {
                input_chars: true,
                inner_fill_chars: true,
                outer_fill_chars: true,
                added_chars: false,
            };
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &characters {
            ctx.terminal.set_character_visibility(id, true);
            let (input_coord, input_symbol, input_fg, input_bg, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (
                    ch.input_coord,
                    ch.input_symbol.clone(),
                    ch.animation.input_fg_color.clone(),
                    ch.animation.input_bg_color.clone(),
                    ch.uses_input_preexisting_colors,
                )
            };
            let base_colors = if dynamic {
                self.character_final_color_map.insert(id, ColorPair::new(input_fg, input_bg));
                ColorPair::new(Some(blk.clone()), None)
            } else {
                self.character_final_color_map.insert(
                    id,
                    ColorPair::new(
                        Some(final_gradient_mapping.get(&input_coord).cloned().unwrap_or_else(|| blk.clone())),
                        None,
                    ),
                );
                ColorPair::new(Some(self.config.starting_color.clone()), None)
            };
            let paint_chars = [input_symbol.clone()];
            let paint_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "paint", uses_pre)
            };
            if dynamic {
                let colors = self.character_final_color_map.get(&id).unwrap().clone();
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&paint_scn)
                    .unwrap()
                    .add_frame(&input_symbol, 5, VisualParams { colors: Some(colors), ..Default::default() })
                    .map_err(EngineError::Other)?;
            } else {
                let final_fg_color = self
                    .character_final_color_map
                    .get(&id)
                    .unwrap()
                    .fg_color
                    .clone()
                    .expect("final fg color");
                // Gradient(*final_gradient_stops, final_fg_color, steps=5)
                let paint_stops: Vec<Color> = self
                    .config
                    .final_gradient_stops
                    .iter()
                    .cloned()
                    .chain(std::iter::once(final_fg_color))
                    .collect();
                let paint_gradient = Gradient::with_steps(&paint_stops, 5, false).map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&paint_scn)
                    .unwrap()
                    .apply_gradient_to_symbols(&paint_chars, 5, Some(&paint_gradient), None)
                    .map_err(EngineError::Other)?;
            }

            let smoke_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "smoke", uses_pre)
            };
            if dynamic {
                let colors = self.character_final_color_map.get(&id).unwrap().clone();
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&smoke_scn).unwrap();
                for smoke_symbol in &self.config.smoke_symbols {
                    scene
                        .add_frame(
                            smoke_symbol,
                            10,
                            VisualParams { colors: Some(colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&smoke_scn)
                    .unwrap()
                    .apply_gradient_to_symbols(&self.config.smoke_symbols, 3, Some(&smoke_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(smoke_scn),
                EventAction::ActivateScene(paint_scn),
            )
            .map_err(EngineError::Other)?;
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.set_appearance(&input_symbol, uses_pre, Some(&input_symbol), Some(base_colors));
            }
        }

        while !gen_alg.complete {
            gen_alg.step(ctx);
        }

        // trigger effects on starting char since it will not be 'explored'
        let starting_char = fill_alg.starting_char;
        ctx.activate_scene(self, starting_char, "smoke");
        ctx.active_characters.insert(starting_char);

        self.fill_alg = Some(fill_alg);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        let mut fill_alg = self.fill_alg.take().expect("fill alg");
        let result = if !fill_alg.complete || !ctx.active_characters.is_empty() {
            if !fill_alg.complete {
                fill_alg.step(ctx);
                for i in 0..fill_alg.explored_last_step.len() {
                    let id = fill_alg.explored_last_step[i];
                    ctx.activate_scene(self, id, "smoke");
                    ctx.active_characters.insert(id);
                }
            }
            ctx.update(self);
            Some(ctx.frame())
        } else {
            None
        };
        self.fill_alg = Some(fill_alg);
        result
    }
}
