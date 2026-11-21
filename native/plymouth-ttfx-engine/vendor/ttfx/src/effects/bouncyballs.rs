//! bouncyballs, ported from effects/effect_bouncyballs.py.

use std::collections::{BTreeMap, HashMap};

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_non_negative_int, parse_positive_float,
    parse_symbol,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
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
pub struct BouncyBallsConfig {
    /// Space separated list of colors from which ball colors will be randomly selected.
    #[arg(long = "ball-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["d1f4a5", "96e2a4", "5acda9"])]
    pub ball_colors: Vec<Color>,

    /// Space separated list of symbols to use for the balls.
    #[arg(long = "ball-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["*", "o", "O", "0", "."])]
    pub ball_symbols: Vec<String>,

    /// Number of frames between ball drops, increase to reduce ball drop rate.
    #[arg(long = "ball-delay", default_value_t = 4, value_parser = parse_non_negative_int)]
    pub ball_delay: i64,

    /// Movement speed of the characters.
    #[arg(long = "movement-speed", default_value_t = 0.45, value_parser = parse_positive_float)]
    pub movement_speed: f64,

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "out_bounce", value_parser = parse_easing)]
    pub movement_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["f8ffae", "43c6ac"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct BouncyBalls {
    config: BouncyBallsConfig,
    pending_chars: Vec<CharId>,
    group_by_row: BTreeMap<i64, Vec<CharId>>,
    character_final_color_map: HashMap<CharId, Color>,
    ball_delay: i64,
}

impl BouncyBalls {
    pub fn new(config: BouncyBallsConfig) -> Self {
        BouncyBalls {
            config,
            pending_chars: Vec::new(),
            group_by_row: BTreeMap::new(),
            character_final_color_map: HashMap::new(),
            ball_delay: 0,
        }
    }
}

impl EffectHooks for BouncyBalls {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for BouncyBalls {
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
        let canvas_top = ctx.terminal.canvas.top;
        for id in characters {
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
            let color = ctx.rng.choice(&self.config.ball_colors).clone();
            let symbol = ctx.rng.choice(&self.config.ball_symbols).clone();
            let ball_scene = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .add_frame(
                        &symbol,
                        1,
                        VisualParams { colors: Some(ColorPair::new(Some(color.clone()), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
                scene_id
            };
            let final_scene = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            if dynamic {
                let fg_gradient = match &input_fg {
                    Some(fg) => Some(
                        Gradient::with_steps(&[color.clone(), fg.clone()], 10, false).map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &input_bg {
                    Some(bg) => Some(
                        Gradient::with_steps(&[color.clone(), bg.clone()], 10, false).map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&final_scene).unwrap();
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            6,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            6,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                let char_final_gradient =
                    Gradient::with_steps(&[color.clone(), final_color], 10, false).map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&final_scene)
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 6, Some(&char_final_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            // Coord(input column, int(canvas.top * uniform(1.0, 1.5))) — int() truncation
            let drop_row = (canvas_top as f64 * ctx.rng.uniform(1.0, 1.5)) as i64;
            let input_coord_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(Coord::new(input_coord.column, drop_row));
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
            ctx.activate_path(self, id, &input_coord_path);
            ctx.activate_scene(self, id, &ball_scene);
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(input_coord_path),
                EventAction::ActivateScene(final_scene),
            )
            .map_err(EngineError::Other)?;
            self.pending_chars.push(id);
        }
        let mut sorted_chars = self.pending_chars.clone();
        sorted_chars.sort_by_key(|&id| ctx.terminal.arena[id.0 as usize].input_coord.row);
        for id in sorted_chars {
            let row = ctx.terminal.arena[id.0 as usize].input_coord.row;
            self.group_by_row.entry(row).or_default().push(id);
        }
        self.pending_chars.clear();
        self.ball_delay = 0;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.group_by_row.is_empty() || !ctx.active_characters.is_empty() || !self.pending_chars.is_empty() {
            if self.pending_chars.is_empty() && !self.group_by_row.is_empty() {
                let min_row = *self.group_by_row.keys().next().unwrap();
                let group = self.group_by_row.remove(&min_row).unwrap();
                self.pending_chars.extend(group);
            }
            if !self.pending_chars.is_empty() {
                if self.ball_delay == 0 {
                    for _ in 0..ctx.rng.randint(2, 6) {
                        if self.pending_chars.is_empty() {
                            break;
                        }
                        let index = ctx.rng.randint(0, self.pending_chars.len() as i64 - 1) as usize;
                        let next_character = self.pending_chars.remove(index);
                        ctx.terminal.set_character_visibility(next_character, true);
                        ctx.active_characters.insert(next_character);
                    }
                    self.ball_delay = self.config.ball_delay;
                } else {
                    self.ball_delay -= 1;
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
