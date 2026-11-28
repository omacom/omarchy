//! fireworks, ported from effects/effect_fireworks.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_non_negative_int, parse_non_negative_ratio, parse_symbol,
};
use crate::engine::animation::{ExistingColorHandling, SyncMetric, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::{floor_div, round_half_even};

#[derive(Args, Debug, Clone)]
pub struct FireworksConfig {
    /// If set, fireworks explode anywhere in the canvas. Otherwise, fireworks explode above highest settled row of text.
    #[arg(long = "explode-anywhere", default_value_t = false)]
    pub explode_anywhere: bool,

    /// Space separated list of colors from which firework colors will be randomly selected.
    #[arg(long = "firework-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["88F7E2", "44D492", "F5EB67", "FFA15C", "FA233E"])]
    pub firework_colors: Vec<Color>,

    /// Symbol to use for the firework shell.
    #[arg(long = "firework-symbol", default_value = "o", value_parser = parse_symbol)]
    pub firework_symbol: String,

    /// Percent of total characters in each firework shell.
    #[arg(long = "firework-volume", default_value_t = 0.05, value_parser = parse_non_negative_ratio)]
    pub firework_volume: f64,

    /// Number of frames to wait between launching each firework shell. +/- 0-50 percent randomness is applied to this value.
    #[arg(long = "launch-delay", default_value_t = 45, value_parser = parse_non_negative_int)]
    pub launch_delay: i64,

    /// Maximum distance from the firework shell origin to the explode waypoint as a percentage of the total canvas width.
    #[arg(long = "explode-distance", default_value_t = 0.2, value_parser = parse_non_negative_ratio)]
    pub explode_distance: f64,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "horizontal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Fireworks {
    config: FireworksConfig,
    shells: Vec<Vec<CharId>>,
    firework_volume: i64,
    explode_distance: i64,
    character_final_color_map: HashMap<CharId, ColorPair>,
    launch_delay: i64,
}

impl Fireworks {
    pub fn new(config: FireworksConfig) -> Self {
        Fireworks {
            config,
            shells: Vec::new(),
            firework_volume: 0,
            explode_distance: 0,
            character_final_color_map: HashMap::new(),
            launch_delay: 0,
        }
    }

    /// FireworksIterator.prepare_waypoints.
    fn prepare_waypoints(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let mut firework_shell: Vec<CharId> = Vec::new();
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        let canvas_bottom = ctx.terminal.canvas.bottom;
        let canvas_top = ctx.terminal.canvas.top;
        let canvas_right = ctx.terminal.canvas.right;
        // Loop variables assigned at each shell boundary and reused across the
        // following characters, like the Python loop-scoped names.
        let mut origin_x: i64 = 0;
        let mut origin_coord = Coord::new(0, 0);
        let mut explode_waypoint_coords: Vec<Coord> = Vec::new();
        for id in characters {
            if firework_shell.len() as i64 == self.firework_volume || firework_shell.is_empty() {
                origin_x = ctx.rng.randrange(0, canvas_right);
                self.shells.push(std::mem::take(&mut firework_shell));
                let min_row = if !self.config.explode_anywhere {
                    ctx.terminal.arena[id.0 as usize].input_coord.row
                } else {
                    canvas_bottom
                };
                let origin_y = ctx.rng.randrange(min_row, canvas_top + 1);
                origin_coord = Coord::new(origin_x, origin_y);
                explode_waypoint_coords = geometry::find_coords_in_circle(origin_coord, self.explode_distance);
            }
            let input_coord = ctx.terminal.arena[id.0 as usize].input_coord;
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(Coord::new(origin_x, canvas_bottom));
                let apex_path = ch
                    .motion
                    .new_path(0.35, Some(Easing::OutExpo), Some(2), 0, false, "apex_pth")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&apex_path)
                    .unwrap()
                    .new_waypoint(origin_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            let apex_wpt_coord = origin_coord;
            let explode_speed = ctx.rng.uniform(0.2, 0.4);
            let explode_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion
                    .new_path(explode_speed, Some(Easing::OutCirc), Some(2), 0, false, "")
                    .map_err(EngineError::Other)?
            };
            let explode_wpt_coord = *ctx.rng.choice(&explode_waypoint_coords);
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion
                    .paths
                    .get_mut(&explode_path)
                    .unwrap()
                    .new_waypoint(explode_wpt_coord, None, "")
                    .map_err(EngineError::Other)?;
            }

            let bloom_control_point = geometry::extrapolate_along_ray(
                apex_wpt_coord,
                explode_wpt_coord,
                floor_div(self.explode_distance, 2) as f64,
            );
            let bloom_wpt_coord =
                Coord::new(bloom_control_point.column, std::cmp::max(1, bloom_control_point.row - 7));
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion
                    .paths
                    .get_mut(&explode_path)
                    .unwrap()
                    .new_waypoint(bloom_wpt_coord, Some(vec![bloom_control_point]), "")
                    .map_err(EngineError::Other)?;
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let input_path = ch
                    .motion
                    .new_path(0.6, Some(Easing::InOutQuart), Some(2), 0, false, "input_pth")
                    .map_err(EngineError::Other)?;
                let input_control_point = Coord::new(bloom_wpt_coord.column, 1);
                ch.motion
                    .paths
                    .get_mut(&input_path)
                    .unwrap()
                    .new_waypoint(input_coord, Some(vec![input_control_point]), "")
                    .map_err(EngineError::Other)?;
            }
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("apex_pth".to_string()),
                EventAction::ActivatePath(explode_path.clone()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(explode_path),
                EventAction::ActivatePath("input_pth".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("input_pth".to_string()),
                EventAction::SetLayer(0),
            )
            .map_err(EngineError::Other)?;

            ctx.activate_path(self, id, "apex_pth");

            firework_shell.push(id);
        }
        if !firework_shell.is_empty() {
            self.shells.push(firework_shell);
        }
        Ok(())
    }

    /// FireworksIterator.prepare_scenes.
    fn prepare_scenes(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
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
        let white = Color::from_hex("FFFFFF").unwrap();
        let shells = self.shells.clone();
        for firework_shell in shells {
            let shell_color = ctx.rng.choice(&self.config.firework_colors).clone();
            let shell_gradient =
                Gradient::with_steps(&[shell_color.clone(), white.clone(), shell_color.clone()], 5, false)
                    .map_err(EngineError::Other)?;
            for id in firework_shell {
                let (input_symbol, input_fg, input_bg, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (
                        ch.input_symbol.clone(),
                        ch.animation.input_fg_color.clone(),
                        ch.animation.input_bg_color.clone(),
                        ch.uses_input_preexisting_colors,
                    )
                };
                // launch scene
                let launch_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                    let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                    scene
                        .add_frame(
                            &self.config.firework_symbol,
                            2,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(shell_color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                    scene
                        .add_frame(
                            &self.config.firework_symbol,
                            1,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(white.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                    scene.is_looping = true;
                    scene_id
                };
                // bloom scene
                let bloom_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene_id = ch.animation.new_scene(false, Some(SyncMetric::Step), None, "", uses_pre);
                    let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                    for color in &shell_gradient.spectrum {
                        scene
                            .add_frame(
                                &input_symbol,
                                2,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(color.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                    scene_id
                };
                // fall scene
                let fall_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.new_scene(false, None, None, "fall_scn", uses_pre)
                };
                if dynamic {
                    let fg_gradient = match &input_fg {
                        Some(fg) => Some(
                            Gradient::with_steps(&[shell_color.clone(), fg.clone()], 15, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let bg_gradient = match &input_bg {
                        Some(bg) => Some(
                            Gradient::with_steps(&[shell_color.clone(), bg.clone()], 15, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut(&fall_scn).unwrap();
                    if fg_gradient.is_some() || bg_gradient.is_some() {
                        scene
                            .apply_gradient_to_symbols(
                                &[input_symbol.clone()],
                                10,
                                fg_gradient.as_ref(),
                                bg_gradient.as_ref(),
                            )
                            .map_err(EngineError::Other)?;
                    } else {
                        scene
                            .add_frame(
                                &input_symbol,
                                10,
                                VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let final_fg = self
                        .character_final_color_map
                        .get(&id)
                        .unwrap()
                        .fg_color
                        .clone()
                        .expect("gradient mapping fg");
                    let fall_gradient = Gradient::with_steps(&[shell_color.clone(), final_fg], 15, false)
                        .map_err(EngineError::Other)?;
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation
                        .scenes
                        .get_mut(&fall_scn)
                        .unwrap()
                        .apply_gradient_to_symbols(&[input_symbol.clone()], 10, Some(&fall_gradient), None)
                        .map_err(EngineError::Other)?;
                }
                ctx.activate_scene(self, id, &launch_scn);
                ctx.register_event(
                    id,
                    Event::PathComplete,
                    CallerKey::Path("apex_pth".to_string()),
                    EventAction::ActivateScene(bloom_scn),
                )
                .map_err(EngineError::Other)?;
                ctx.register_event(
                    id,
                    Event::PathActivated,
                    CallerKey::Path("input_pth".to_string()),
                    EventAction::ActivateScene(fall_scn),
                )
                .map_err(EngineError::Other)?;
            }
        }
        Ok(())
    }
}

impl EffectHooks for Fireworks {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Fireworks {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // __init__ precomputations (no RNG)
        self.firework_volume = std::cmp::max(
            1,
            round_half_even(self.config.firework_volume * ctx.terminal.input_characters.len() as f64),
        );
        self.explode_distance = std::cmp::min(
            15,
            std::cmp::max(1, round_half_even(ctx.terminal.canvas.right as f64 * self.config.explode_distance)),
        );
        self.launch_delay = 0;
        self.prepare_waypoints(ctx)?;
        self.prepare_scenes(ctx)?;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.shells.is_empty() || !ctx.active_characters.is_empty() {
            if !self.shells.is_empty() && self.launch_delay <= 0 {
                let next_group = self.shells.pop().unwrap();
                for id in next_group {
                    ctx.terminal.set_character_visibility(id, true);
                    ctx.active_characters.insert(id);
                }
                // int(launch_delay * uniform(0.5, 1.5)) — truncation
                self.launch_delay = (self.config.launch_delay as f64 * ctx.rng.uniform(0.5, 1.5)) as i64;
            }
            self.launch_delay -= 1;
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
