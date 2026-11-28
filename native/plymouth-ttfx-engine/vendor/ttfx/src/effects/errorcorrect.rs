//! errorcorrect, ported from effects/effect_errorcorrect.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_positive_float, parse_positive_int,
};
use crate::engine::animation::{ExistingColorHandling, SyncMetric, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct ErrorCorrectConfig {
    /// Percent of characters that are in the wrong position. This is a float between 0 and 1.0.
    #[arg(long = "error-pairs", default_value_t = 0.1, value_parser = parse_positive_float)]
    pub error_pairs: f64,

    /// Number of frames between swaps.
    #[arg(long = "swap-delay", default_value_t = 6, value_parser = parse_positive_int)]
    pub swap_delay: i64,

    /// Color for the characters that are in the wrong position.
    #[arg(long = "error-color", default_value = "e74c3c", value_parser = parse_color)]
    pub error_color: Color,

    /// Color for the characters once corrected, this is a gradient from error-color and fades to final-color.
    #[arg(long = "correct-color", default_value = "45bf55", value_parser = parse_color)]
    pub correct_color: Color,

    /// Speed of the characters while moving to the correct position.
    #[arg(long = "movement-speed", default_value_t = 0.9, value_parser = parse_positive_float)]
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

const BLOCK_WIPE_START: [&str; 8] = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"];
const BLOCK_WIPE_END: [&str; 7] = ["▇", "▆", "▅", "▄", "▃", "▂", "▁"];

pub struct ErrorCorrect {
    config: ErrorCorrectConfig,
    swapped: Vec<(CharId, CharId)>,
    swap_delay: i64,
    character_final_color_map: HashMap<CharId, ColorPair>,
}

impl ErrorCorrect {
    pub fn new(config: ErrorCorrectConfig) -> Self {
        ErrorCorrect { config, swapped: Vec::new(), swap_delay: 0, character_final_color_map: HashMap::new() }
    }

    /// ErrorCorrectIterator._get_dynamic_final_scene.
    fn get_dynamic_final_scene(&self, ctx: &mut EngineCtx, id: CharId) -> Result<String, EngineError> {
        let (input_symbol, input_fg, input_bg, uses_pre) = {
            let ch = &ctx.terminal.arena[id.0 as usize];
            (
                ch.input_symbol.clone(),
                ch.animation.input_fg_color.clone(),
                ch.animation.input_bg_color.clone(),
                ch.uses_input_preexisting_colors,
            )
        };
        let final_scene = {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation.new_scene(false, None, None, "", uses_pre)
        };
        let fg_gradient = match &input_fg {
            Some(fg) => Some(
                Gradient::with_steps(&[self.config.correct_color.clone(), fg.clone()], 10, false)
                    .map_err(EngineError::Other)?,
            ),
            None => None,
        };
        let bg_gradient = match &input_bg {
            Some(bg) => Some(
                Gradient::with_steps(&[self.config.correct_color.clone(), bg.clone()], 10, false)
                    .map_err(EngineError::Other)?,
            ),
            None => None,
        };
        let ch = &mut ctx.terminal.arena[id.0 as usize];
        let scene = ch.animation.scenes.get_mut(&final_scene).unwrap();
        if fg_gradient.is_some() || bg_gradient.is_some() {
            scene
                .apply_gradient_to_symbols(&[input_symbol.clone()], 3, fg_gradient.as_ref(), bg_gradient.as_ref())
                .map_err(EngineError::Other)?;
        } else {
            scene
                .add_frame(&input_symbol, 3, VisualParams { colors: Some(ColorPair::default()), ..Default::default() })
                .map_err(EngineError::Other)?;
        }
        Ok(final_scene)
    }

    /// ErrorCorrectIterator._configure_swapped_character.
    fn configure_swapped_character(
        &mut self,
        ctx: &mut EngineCtx,
        id: CharId,
        correcting_gradient: &Gradient,
    ) -> Result<(), EngineError> {
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let (input_symbol, uses_pre) = {
            let ch = &ctx.terminal.arena[id.0 as usize];
            (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
        };
        let (first_block_wipe, last_block_wipe) = {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let first = ch.animation.new_scene(false, None, None, "", uses_pre);
            let last = ch.animation.new_scene(false, None, None, "", uses_pre);
            (first, last)
        };
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let scene = ch.animation.scenes.get_mut(&first_block_wipe).unwrap();
            for block in BLOCK_WIPE_START {
                scene
                    .add_frame(
                        block,
                        3,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(self.config.error_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
            }
        }
        let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let scene = ch.animation.scenes.get_mut(&last_block_wipe).unwrap();
            if dynamic {
                for block in &BLOCK_WIPE_END[..BLOCK_WIPE_END.len() - 1] {
                    scene
                        .add_frame(
                            block,
                            3,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(self.config.correct_color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
                scene
                    .add_frame(
                        BLOCK_WIPE_END[BLOCK_WIPE_END.len() - 1],
                        3,
                        VisualParams { colors: Some(final_colors), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            } else {
                for block in BLOCK_WIPE_END {
                    scene
                        .add_frame(
                            block,
                            3,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(self.config.correct_color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
        }
        let initial_scene = {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
            ch.animation
                .scenes
                .get_mut(&scene_id)
                .unwrap()
                .add_frame(
                    &input_symbol,
                    1,
                    VisualParams {
                        colors: Some(ColorPair::new(Some(self.config.error_color.clone()), None)),
                        ..Default::default()
                    },
                )
                .map_err(EngineError::Other)?;
            scene_id
        };
        ctx.activate_scene(self, id, &initial_scene);
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let error_scene = ch.animation.new_scene(false, None, None, "error", uses_pre);
            let scene = ch.animation.scenes.get_mut(&error_scene).unwrap();
            for _ in 0..10 {
                scene
                    .add_frame(
                        "▓",
                        3,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(self.config.error_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                scene
                    .add_frame(
                        &input_symbol,
                        3,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(Color::from_hex("ffffff").unwrap()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
            }
        }
        let correcting_scene = {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let scene_id = ch.animation.new_scene(false, Some(SyncMetric::Distance), None, "", uses_pre);
            ch.animation
                .scenes
                .get_mut(&scene_id)
                .unwrap()
                .apply_gradient_to_symbols(&["█".to_string()], 3, Some(correcting_gradient), None)
                .map_err(EngineError::Other)?;
            scene_id
        };
        let final_scene = if dynamic {
            self.get_dynamic_final_scene(ctx, id)?
        } else {
            let final_fg = final_colors_fg(&self.character_final_color_map, id);
            let char_final_gradient =
                Gradient::with_steps(&[self.config.correct_color.clone(), final_fg], 10, false)
                    .map_err(EngineError::Other)?;
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
            ch.animation
                .scenes
                .get_mut(&scene_id)
                .unwrap()
                .apply_gradient_to_symbols(&[input_symbol.clone()], 3, Some(&char_final_gradient), None)
                .map_err(EngineError::Other)?;
            scene_id
        };
        ctx.register_event(
            id,
            Event::SceneComplete,
            CallerKey::Scene("error".to_string()),
            EventAction::ActivateScene(first_block_wipe.clone()),
        )
        .map_err(EngineError::Other)?;
        ctx.register_event(
            id,
            Event::SceneComplete,
            CallerKey::Scene(first_block_wipe.clone()),
            EventAction::ActivateScene(correcting_scene),
        )
        .map_err(EngineError::Other)?;
        ctx.register_event(
            id,
            Event::SceneComplete,
            CallerKey::Scene(first_block_wipe),
            EventAction::ActivatePath("input_coord".to_string()),
        )
        .map_err(EngineError::Other)?;
        ctx.register_event(
            id,
            Event::PathActivated,
            CallerKey::Path("input_coord".to_string()),
            EventAction::SetLayer(1),
        )
        .map_err(EngineError::Other)?;
        ctx.register_event(
            id,
            Event::PathComplete,
            CallerKey::Path("input_coord".to_string()),
            EventAction::SetLayer(0),
        )
        .map_err(EngineError::Other)?;
        ctx.register_event(
            id,
            Event::PathComplete,
            CallerKey::Path("input_coord".to_string()),
            EventAction::ActivateScene(last_block_wipe.clone()),
        )
        .map_err(EngineError::Other)?;
        ctx.register_event(
            id,
            Event::SceneComplete,
            CallerKey::Scene(last_block_wipe),
            EventAction::ActivateScene(final_scene),
        )
        .map_err(EngineError::Other)?;
        Ok(())
    }
}

fn final_colors_fg(map: &HashMap<CharId, ColorPair>, id: CharId) -> Color {
    map.get(&id).unwrap().fg_color.clone().expect("gradient mapping fg")
}

impl EffectHooks for ErrorCorrect {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for ErrorCorrect {
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
        for &id in &characters {
            let spawn_colors = self.character_final_color_map.get(&id).unwrap().clone();
            let spawn_scene = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let uses_pre = ch.uses_input_preexisting_colors;
                let input_symbol = ch.input_symbol.clone();
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .add_frame(&input_symbol, 1, VisualParams { colors: Some(spawn_colors), ..Default::default() })
                    .map_err(EngineError::Other)?;
                scene_id
            };
            ctx.activate_scene(self, id, &spawn_scene);
            ctx.terminal.set_character_visibility(id, true);
        }

        let mut all_characters: Vec<CharId> = ctx.terminal.input_characters.clone();
        let correcting_gradient = Gradient::with_steps(
            &[self.config.error_color.clone(), self.config.correct_color.clone()],
            10,
            false,
        )
        .map_err(EngineError::Other)?;

        let pair_count = (self.config.error_pairs * characters.len() as f64) as i64;
        for _ in 0..pair_count {
            if all_characters.len() < 2 {
                break;
            }
            let index1 = ctx.rng.randrange(0, all_characters.len() as i64) as usize;
            let char1 = all_characters.remove(index1);
            let index2 = ctx.rng.randrange(0, all_characters.len() as i64) as usize;
            let char2 = all_characters.remove(index2);
            let char1_input_coord = ctx.terminal.arena[char1.0 as usize].input_coord;
            let char2_input_coord = ctx.terminal.arena[char2.0 as usize].input_coord;
            {
                let ch = &mut ctx.terminal.arena[char1.0 as usize];
                ch.motion.set_coordinate(char2_input_coord);
                let path_id = ch
                    .motion
                    .new_path(self.config.movement_speed, None, None, 0, false, "input_coord")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(char1_input_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            {
                let ch = &mut ctx.terminal.arena[char2.0 as usize];
                ch.motion.set_coordinate(char1_input_coord);
                let path_id = ch
                    .motion
                    .new_path(self.config.movement_speed, None, None, 0, false, "input_coord")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(char2_input_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            self.swapped.push((char1, char2));
            for id in [char1, char2] {
                self.configure_swapped_character(ctx, id, &correcting_gradient)?;
            }
        }
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.swapped.is_empty() && self.swap_delay == 0 {
            let (char1, char2) = self.swapped.remove(0);
            for id in [char1, char2] {
                ctx.activate_scene(self, id, "error");
                ctx.active_characters.insert(id);
            }
            self.swap_delay = self.config.swap_delay;
        } else if self.swap_delay != 0 {
            self.swap_delay -= 1;
        }
        if !ctx.active_characters.is_empty() {
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
