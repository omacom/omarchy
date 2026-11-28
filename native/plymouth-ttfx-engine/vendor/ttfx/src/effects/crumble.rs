//! crumble, ported from effects/effect_crumble.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps};
use crate::engine::animation::{Animation, ExistingColorHandling, SyncMetric, VisualParams};
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
pub struct CrumbleConfig {
    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["5CE1FF", "FF8C00"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Stage {
    Falling,
    Vacuuming,
    Resetting,
    Complete,
}

pub struct Crumble {
    config: CrumbleConfig,
    pending_chars: Vec<CharId>,
    character_final_color_map: HashMap<CharId, Color>,
    fall_delay: i64,
    max_fall_delay: i64,
    min_fall_delay: i64,
    reset: bool,
    fall_group_maxsize: i64,
    stage: Stage,
    unvacuumed_chars: Vec<CharId>,
}

impl Crumble {
    pub fn new(config: CrumbleConfig) -> Self {
        Crumble {
            config,
            pending_chars: Vec::new(),
            character_final_color_map: HashMap::new(),
            fall_delay: 0,
            max_fall_delay: 0,
            min_fall_delay: 0,
            reset: false,
            fall_group_maxsize: 1,
            stage: Stage::Falling,
            unvacuumed_chars: Vec::new(),
        }
    }
}

impl EffectHooks for Crumble {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Crumble {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // CrumbleIterator.DYNAMIC_NEUTRAL_GRAY
        let dynamic_neutral_gray = Color::from_hex("#808080").unwrap();
        let white = Color::from_hex("#ffffff").unwrap();

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
        let canvas_bottom = ctx.terminal.canvas.bottom;
        let canvas_top = ctx.terminal.canvas.top;
        let canvas_center_column = ctx.terminal.canvas.center_column;
        let canvas_center_row = ctx.terminal.canvas.center_row;
        for &id in &characters {
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
            self.character_final_color_map
                .insert(id, final_gradient_mapping.get(&input_coord).unwrap().clone());
            let (
                weak_fg_color,
                weak_bg_color,
                dust_fg_color,
                dust_bg_color,
                strengthen_flash_fg_gradient,
                strengthen_flash_bg_gradient,
                strengthen_fg_gradient,
                strengthen_bg_gradient,
            );
            if dynamic {
                let has_existing_colors = input_fg.is_some() || input_bg.is_some();
                weak_fg_color = match &input_fg {
                    Some(fg) => Some(Animation::adjust_color_brightness(fg, 0.65)),
                    None => {
                        if input_bg.is_none() {
                            Some(Animation::adjust_color_brightness(&dynamic_neutral_gray, 0.65))
                        } else {
                            None
                        }
                    }
                };
                weak_bg_color = input_bg.as_ref().map(|bg| Animation::adjust_color_brightness(bg, 0.65));
                dust_fg_color = match &input_fg {
                    Some(fg) => Some(Animation::adjust_color_brightness(fg, 0.55)),
                    None => {
                        if input_bg.is_none() {
                            Some(Animation::adjust_color_brightness(&dynamic_neutral_gray, 0.55))
                        } else {
                            None
                        }
                    }
                };
                dust_bg_color = input_bg.as_ref().map(|bg| Animation::adjust_color_brightness(bg, 0.55));
                strengthen_flash_fg_gradient = match &input_fg {
                    Some(fg) => Some(
                        Gradient::with_steps(&[fg.clone(), white.clone()], 6, false).map_err(EngineError::Other)?,
                    ),
                    None => {
                        if !has_existing_colors {
                            Some(
                                Gradient::with_steps(&[dynamic_neutral_gray.clone(), white.clone()], 6, false)
                                    .map_err(EngineError::Other)?,
                            )
                        } else {
                            None
                        }
                    }
                };
                strengthen_flash_bg_gradient = match &input_bg {
                    Some(bg) => Some(
                        Gradient::with_steps(&[bg.clone(), white.clone()], 6, false).map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                strengthen_fg_gradient = match &input_fg {
                    Some(fg) => Some(
                        Gradient::with_steps(&[white.clone(), fg.clone()], 9, false).map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                strengthen_bg_gradient = match &input_bg {
                    Some(bg) => Some(
                        Gradient::with_steps(&[white.clone(), bg.clone()], 9, false).map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
            } else {
                let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                weak_fg_color = Some(Animation::adjust_color_brightness(&final_color, 0.65));
                weak_bg_color = None;
                dust_fg_color = Some(Animation::adjust_color_brightness(&final_color, 0.55));
                dust_bg_color = None;
                strengthen_flash_fg_gradient = Some(
                    Gradient::with_steps(&[final_color.clone(), white.clone()], 6, false)
                        .map_err(EngineError::Other)?,
                );
                strengthen_flash_bg_gradient = None;
                strengthen_fg_gradient = Some(
                    Gradient::with_steps(&[white.clone(), final_color.clone()], 9, false)
                        .map_err(EngineError::Other)?,
                );
                strengthen_bg_gradient = None;
            }
            let weaken_fg_gradient = match (&weak_fg_color, &dust_fg_color) {
                (Some(weak), Some(dust)) => Some(
                    Gradient::with_steps(&[weak.clone(), dust.clone()], 9, false).map_err(EngineError::Other)?,
                ),
                _ => None,
            };
            let weaken_bg_gradient = match (&weak_bg_color, &dust_bg_color) {
                (Some(weak), Some(dust)) => Some(
                    Gradient::with_steps(&[weak.clone(), dust.clone()], 9, false).map_err(EngineError::Other)?,
                ),
                _ => None,
            };
            ctx.terminal.set_character_visibility(id, true);
            // set up initial and falling stage
            let initial_scn = {
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
                            colors: Some(ColorPair::new(weak_fg_color.clone(), weak_bg_color.clone())),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                scene_id
            };
            ctx.activate_scene(self, id, &initial_scn);
            let fall_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let path_id = ch
                    .motion
                    .new_path(0.65, Some(Easing::OutBounce), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(Coord::new(input_coord.column, canvas_bottom), None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let weaken_scn = ch.animation.new_scene(false, None, None, "weaken", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&weaken_scn)
                    .unwrap()
                    .apply_gradient_to_symbols(
                        &[input_symbol.clone()],
                        4,
                        weaken_fg_gradient.as_ref(),
                        weaken_bg_gradient.as_ref(),
                    )
                    .map_err(EngineError::Other)?;
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let top_path = ch
                    .motion
                    .new_path(1.0, Some(Easing::OutQuint), None, 0, false, "top")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&top_path)
                    .unwrap()
                    .new_waypoint(
                        Coord::new(input_coord.column, canvas_top),
                        Some(vec![Coord::new(canvas_center_column, canvas_center_row)]),
                        "",
                    )
                    .map_err(EngineError::Other)?;
            }
            // set up reset stage
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let input_path = ch.motion.new_path(1.0, None, None, 0, false, "input").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&input_path)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            let strengthen_flash_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .apply_gradient_to_symbols(
                        &[input_symbol.clone()],
                        4,
                        strengthen_flash_fg_gradient.as_ref(),
                        strengthen_flash_bg_gradient.as_ref(),
                    )
                    .map_err(EngineError::Other)?;
                scene_id
            };
            let strengthen_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                if dynamic && input_fg.is_none() && input_bg.is_none() {
                    scene
                        .add_frame(
                            &input_symbol,
                            4,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            4,
                            strengthen_fg_gradient.as_ref(),
                            strengthen_bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                }
                scene_id
            };
            let dust_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, Some(SyncMetric::Distance), None, "", uses_pre)
            };
            let dust_symbols = ["*", ".", ","];
            for _ in 0..5 {
                let symbol = *ctx.rng.choice(&dust_symbols);
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&dust_scn)
                    .unwrap()
                    .add_frame(
                        symbol,
                        1,
                        VisualParams {
                            colors: Some(ColorPair::new(dust_fg_color.clone(), dust_bg_color.clone())),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
            }

            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("weaken".to_string()),
                EventAction::ActivatePath(fall_path),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("weaken".to_string()),
                EventAction::SetLayer(1),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("weaken".to_string()),
                EventAction::ActivateScene(dust_scn),
            )
            .map_err(EngineError::Other)?;

            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("input".to_string()),
                EventAction::ActivateScene(strengthen_flash_scn.clone()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(strengthen_flash_scn),
                EventAction::ActivateScene(strengthen_scn),
            )
            .map_err(EngineError::Other)?;
            self.pending_chars.push(id);
        }
        ctx.rng.shuffle(&mut self.pending_chars);
        self.fall_delay = 12;
        self.max_fall_delay = 12;
        self.min_fall_delay = 9;
        self.reset = false;
        self.fall_group_maxsize = 1;
        self.stage = Stage::Falling;
        self.unvacuumed_chars = ctx.terminal.input_characters.clone();
        ctx.rng.shuffle(&mut self.unvacuumed_chars);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.stage != Stage::Complete {
            match self.stage {
                Stage::Falling => {
                    if !self.pending_chars.is_empty() {
                        if self.fall_delay == 0 {
                            // Determine the size of the next group of falling characters
                            let fall_group_size = ctx.rng.randint(1, self.fall_group_maxsize);
                            // Add the next group of falling characters to the animating characters list
                            for _ in 0..fall_group_size {
                                if !self.pending_chars.is_empty() {
                                    let next_char = self.pending_chars.remove(0);
                                    ctx.activate_scene(self, next_char, "weaken");
                                    ctx.active_characters.insert(next_char);
                                }
                            }
                            // Reset the fall delay and adjust the fall group size and delay range
                            self.fall_delay = ctx.rng.randint(self.min_fall_delay, self.max_fall_delay);
                            if ctx.rng.randint(1, 10) > 4 {
                                // 60% chance to modify the fall delay and group size
                                self.fall_group_maxsize += 1;
                                self.min_fall_delay = std::cmp::max(0, self.min_fall_delay - 1);
                                self.max_fall_delay = std::cmp::max(0, self.max_fall_delay - 1);
                            }
                        } else {
                            self.fall_delay -= 1;
                        }
                    }
                    if self.pending_chars.is_empty() && ctx.active_characters.is_empty() {
                        self.stage = Stage::Vacuuming;
                    }
                }
                Stage::Vacuuming => {
                    if !self.unvacuumed_chars.is_empty() {
                        for _ in 0..ctx.rng.randint(3, 10) {
                            if !self.unvacuumed_chars.is_empty() {
                                let next_char = self.unvacuumed_chars.remove(0);
                                ctx.activate_path(self, next_char, "top");
                                ctx.active_characters.insert(next_char);
                            }
                        }
                    }
                    if ctx.active_characters.is_empty() {
                        self.stage = Stage::Resetting;
                    }
                }
                Stage::Resetting => {
                    if !self.reset {
                        let characters = {
                            let filter = CharacterFilter::default();
                            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                        };
                        for id in characters {
                            ctx.activate_path(self, id, "input");
                            ctx.active_characters.insert(id);
                        }
                        self.reset = true;
                    }
                    if ctx.active_characters.is_empty() {
                        self.stage = Stage::Complete;
                    }
                }
                Stage::Complete => {}
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
