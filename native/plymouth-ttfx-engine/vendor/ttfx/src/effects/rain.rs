//! rain, ported from effects/effect_rain.py.

use std::collections::{BTreeMap, HashMap};

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float_range, parse_symbol,
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
pub struct RainConfig {
    /// List of colors for the rain drops. Colors are randomly chosen from the list.
    #[arg(long = "rain-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["00315C", "004C8F", "0075DB", "3F91D9", "78B9F2", "9AC8F5", "B8D8F8", "E3EFFC"])]
    pub rain_colors: Vec<Color>,

    /// Falling speed range of the rain drops.
    #[arg(long = "movement-speed", default_value = "0.33-0.57", value_parser = parse_positive_float_range)]
    pub movement_speed: (f64, f64),

    /// Space separated list of symbols to use for the rain drops. Symbols are randomly chosen from the list.
    #[arg(long = "rain-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["o", ".", ",", "*", "|"])]
    pub rain_symbols: Vec<String>,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["488bff", "b2e7de", "57eaf7"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,

    /// Easing function to use for character movement.
    #[arg(long = "movement-easing", default_value = "in_quart", value_parser = parse_easing)]
    pub movement_easing: Easing,
}

pub struct Rain {
    config: RainConfig,
    pending_chars: Vec<CharId>,
    group_by_row: BTreeMap<i64, Vec<CharId>>,
    character_final_color_map: HashMap<CharId, ColorPair>,
}

impl Rain {
    pub fn new(config: RainConfig) -> Self {
        Rain {
            config,
            pending_chars: Vec::new(),
            group_by_row: BTreeMap::new(),
            character_final_color_map: HashMap::new(),
        }
    }
}

impl EffectHooks for Rain {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Rain {
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

        let canvas_top = ctx.terminal.canvas.top;
        for id in characters {
            let (input_coord, input_symbol, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.input_coord, ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
            };
            let raindrop_color = ctx.rng.choice(&self.config.rain_colors).clone();
            let rain_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            let rain_symbol = ctx.rng.choice(&self.config.rain_symbols).clone();
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&rain_scn)
                    .unwrap()
                    .add_frame(
                        &rain_symbol,
                        1,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(raindrop_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
            }
            let fade_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
            if dynamic {
                let fg_gradient = match &final_colors.fg_color {
                    Some(fg) => Some(
                        Gradient::with_steps(&[raindrop_color.clone(), fg.clone()], 7, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &final_colors.bg_color {
                    Some(bg) => Some(
                        Gradient::with_steps(&[raindrop_color.clone(), bg.clone()], 7, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&fade_scn).unwrap();
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            3,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            3,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_fg = final_colors.fg_color.clone().expect("gradient mapping fg");
                let raindrop_gradient = Gradient::with_steps(&[raindrop_color.clone(), final_fg], 7, false)
                    .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&fade_scn)
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 3, Some(&raindrop_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            ctx.activate_scene(self, id, &rain_scn);
            let speed = ctx.rng.uniform(self.config.movement_speed.0, self.config.movement_speed.1);
            let input_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(Coord::new(input_coord.column, canvas_top));
                let path_id = ch
                    .motion
                    .new_path(speed, Some(self.config.movement_easing), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(input_path.clone()),
                EventAction::ActivateScene(fade_scn),
            )
            .map_err(EngineError::Other)?;
            ctx.activate_path(self, id, &input_path);
            self.pending_chars.push(id);
        }
        let mut sorted_chars = self.pending_chars.clone();
        sorted_chars.sort_by_key(|&id| ctx.terminal.arena[id.0 as usize].input_coord.row);
        for id in sorted_chars {
            let row = ctx.terminal.arena[id.0 as usize].input_coord.row;
            self.group_by_row.entry(row).or_default().push(id);
        }
        self.pending_chars.clear();
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
                for _ in 0..ctx.rng.randint(1, 2) {
                    if self.pending_chars.is_empty() {
                        break;
                    }
                    let index = ctx.rng.randint(0, self.pending_chars.len() as i64 - 1) as usize;
                    let next_character = self.pending_chars.remove(index);
                    ctx.terminal.set_character_visibility(next_character, true);
                    ctx.active_characters.insert(next_character);
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
