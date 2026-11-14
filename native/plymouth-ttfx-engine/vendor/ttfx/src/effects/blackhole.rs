//! blackhole, ported from effects/effect_blackhole.py.

use std::collections::{HashMap, HashSet};

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps};
use crate::engine::animation::{ExistingColorHandling, SyncMetric, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::{floor_div, round_half_even};

#[derive(Args, Debug, Clone)]
pub struct BlackholeConfig {
    /// Color for the stars that comprise the blackhole border.
    #[arg(long = "blackhole-color", default_value = "ffffff", value_parser = parse_color)]
    pub blackhole_color: Color,

    /// List of colors from which character colors will be chosen and applied after the explosion, but before the cooldown to final color.
    #[arg(long = "star-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["ffcc0d", "ff7326", "ff194d", "bf2669", "702a8c", "049dbf"])]
    pub star_colors: Vec<Color>,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "ffffff"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["9"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Phase {
    Forming,
    Consuming,
    Collapsing,
    Exploding,
    Complete,
}

pub struct Blackhole {
    config: BlackholeConfig,
    blackhole_chars: Vec<CharId>,
    awaiting_consumption_chars: Vec<CharId>,
    blackhole_radius: i64,
    character_final_color_map: HashMap<CharId, Color>,
    formation_delay: i64,
    f_delay: i64,
    phase: Phase,
    awaiting_blackhole_chars: Vec<CharId>,
}

impl Blackhole {
    pub fn new(config: BlackholeConfig) -> Self {
        Blackhole {
            config,
            blackhole_chars: Vec::new(),
            awaiting_consumption_chars: Vec::new(),
            blackhole_radius: 0,
            character_final_color_map: HashMap::new(),
            formation_delay: 0,
            f_delay: 0,
            phase: Phase::Forming,
            awaiting_blackhole_chars: Vec::new(),
        }
    }

    /// BlackholeIterator.prepare_blackhole.
    fn prepare_blackhole(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let star_symbols = ["*", "'", "`", "¤", "•", "°", "·"];
        let starfield_colors = Gradient::with_steps(
            &[Color::from_hex("#4a4a4d").unwrap(), Color::from_hex("#ffffff").unwrap()],
            6,
            false,
        )
        .map_err(EngineError::Other)?
        .spectrum;
        // gradient_map: dict keyed by starfield color, indexed here by spectrum position
        let mut gradient_map: Vec<Gradient> = Vec::new();
        for color in &starfield_colors {
            gradient_map.push(
                Gradient::with_steps(&[color.clone(), Color::from_hex("#000000").unwrap()], 10, false)
                    .map_err(EngineError::Other)?,
            );
        }
        let mut available_chars: Vec<CharId> = ctx.terminal.input_characters.clone();
        while (self.blackhole_chars.len() as i64) < self.blackhole_radius * 3 && !available_chars.is_empty() {
            let index = ctx.rng.randrange(0, available_chars.len() as i64) as usize;
            self.blackhole_chars.push(available_chars.remove(index));
        }
        let black_hole_ring_positions = geometry::find_coords_on_circle(
            ctx.terminal.canvas.center,
            self.blackhole_radius,
            self.blackhole_chars.len() as i64,
            true,
        );
        for (position_index, &id) in self.blackhole_chars.iter().enumerate() {
            let starting_pos = black_hole_ring_positions[position_index];
            let blackhole_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let path_id = ch
                    .motion
                    .new_path(0.7, Some(Easing::InOutSine), None, 0, false, "blackhole")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(starting_pos, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let uses_pre = ch.uses_input_preexisting_colors;
                let blackhole_scn = ch.animation.new_scene(false, None, None, "blackhole", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&blackhole_scn)
                    .unwrap()
                    .add_frame(
                        "*",
                        1,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(self.config.blackhole_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
            }
            ctx.register_event(
                id,
                Event::PathActivated,
                CallerKey::Path(blackhole_path),
                EventAction::SetLayer(1),
            )
            .map_err(EngineError::Other)?;
            // make rotation waypoints
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let rotation_path = ch
                    .motion
                    .new_path(0.45, None, None, 0, true, "blackhole_rotation")
                    .map_err(EngineError::Other)?;
                let rotated: Vec<_> = black_hole_ring_positions[position_index..]
                    .iter()
                    .chain(black_hole_ring_positions[..position_index].iter())
                    .copied()
                    .collect();
                for coord in rotated {
                    let path = ch.motion.paths.get_mut(&rotation_path).unwrap();
                    let waypoint_id = path.waypoints.len().to_string();
                    path.new_waypoint(coord, None, &waypoint_id).map_err(EngineError::Other)?;
                }
            }
        }
        let blackhole_set: HashSet<CharId> = self.blackhole_chars.iter().copied().collect();
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        let canvas_center = ctx.terminal.canvas.center;
        for &id in &characters {
            ctx.terminal.set_character_visibility(id, true);
            let star_symbol = *ctx.rng.choice(&star_symbols);
            let star_color_index = {
                // random.choice(starfield_colors)
                let _ = &starfield_colors;
                ctx.rng.choice_index(starfield_colors.len())
            };
            let star_color = starfield_colors[star_color_index].clone();
            let starting_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let uses_pre = ch.uses_input_preexisting_colors;
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .add_frame(
                        star_symbol,
                        1,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(star_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                scene_id
            };
            ctx.activate_scene(self, id, &starting_scn);
            if !blackhole_set.contains(&id) {
                let starfield_coord = ctx.terminal.canvas.random_coord(&mut ctx.rng, false, false);
                let speed = ctx.rng.uniform(0.17, 0.30);
                let singularity_path = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.motion.set_coordinate(starfield_coord);
                    let path_id = ch
                        .motion
                        .new_path(speed, Some(Easing::InExpo), None, 0, false, "singularity")
                        .map_err(EngineError::Other)?;
                    ch.motion
                        .paths
                        .get_mut(&path_id)
                        .unwrap()
                        .new_waypoint(canvas_center, None, "")
                        .map_err(EngineError::Other)?;
                    path_id
                };
                let consumed_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let uses_pre = ch.uses_input_preexisting_colors;
                    let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                    let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                    for color in &gradient_map[star_color_index].spectrum {
                        scene
                            .add_frame(
                                star_symbol,
                                1,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(color.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                    scene.add_frame(" ", 1, VisualParams::default()).map_err(EngineError::Other)?;
                    scene.sync = Some(SyncMetric::Distance);
                    scene_id
                };
                ctx.register_event(
                    id,
                    Event::PathActivated,
                    CallerKey::Path(singularity_path.clone()),
                    EventAction::SetLayer(2),
                )
                .map_err(EngineError::Other)?;
                ctx.register_event(
                    id,
                    Event::PathActivated,
                    CallerKey::Path(singularity_path),
                    EventAction::ActivateScene(consumed_scn),
                )
                .map_err(EngineError::Other)?;
                self.awaiting_consumption_chars.push(id);
            }
        }
        ctx.rng.shuffle(&mut self.awaiting_consumption_chars);
        Ok(())
    }

    /// BlackholeIterator.rotate_blackhole.
    fn rotate_blackhole(&mut self, ctx: &mut EngineCtx) {
        for &id in &self.blackhole_chars.clone() {
            ctx.activate_path(self, id, "blackhole_rotation");
            ctx.active_characters.insert(id);
        }
    }

    /// BlackholeIterator.collapse_blackhole.
    fn collapse_blackhole(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let mut black_hole_ring_positions = geometry::find_coords_on_circle(
            ctx.terminal.canvas.center,
            self.blackhole_radius + 3,
            self.blackhole_chars.len() as i64,
            true,
        );
        let unstable_symbols = ["◦", "◎", "◉", "●", "◉", "◎", "◦"];
        let mut point_char_made = false;
        let canvas_center = ctx.terminal.canvas.center;
        for &id in &self.blackhole_chars.clone() {
            let next_pos = black_hole_ring_positions.remove(0);
            let (expand_path, collapse_path) = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let expand_path =
                    ch.motion.new_path(0.2, Some(Easing::InExpo), None, 0, false, "").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&expand_path)
                    .unwrap()
                    .new_waypoint(next_pos, None, "")
                    .map_err(EngineError::Other)?;
                let collapse_path =
                    ch.motion.new_path(0.3, Some(Easing::InExpo), None, 0, false, "").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&collapse_path)
                    .unwrap()
                    .new_waypoint(canvas_center, None, "")
                    .map_err(EngineError::Other)?;
                (expand_path, collapse_path)
            };
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(expand_path.clone()),
                EventAction::ActivatePath(collapse_path.clone()),
            )
            .map_err(EngineError::Other)?;
            if !point_char_made {
                let point_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let uses_pre = ch.uses_input_preexisting_colors;
                    ch.animation.new_scene(false, None, None, "", uses_pre)
                };
                for _ in 0..3 {
                    for symbol in unstable_symbols {
                        let color = ctx.rng.choice(&self.config.star_colors).clone();
                        let ch = &mut ctx.terminal.arena[id.0 as usize];
                        ch.animation
                            .scenes
                            .get_mut(&point_scn)
                            .unwrap()
                            .add_frame(
                                symbol,
                                3,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(color), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
                ctx.register_event(
                    id,
                    Event::PathComplete,
                    CallerKey::Path(collapse_path.clone()),
                    EventAction::ActivateScene(point_scn),
                )
                .map_err(EngineError::Other)?;
                ctx.register_event(
                    id,
                    Event::PathComplete,
                    CallerKey::Path(collapse_path),
                    EventAction::SetLayer(3),
                )
                .map_err(EngineError::Other)?;
                point_char_made = true;
            }

            ctx.activate_path(self, id, &expand_path);
            ctx.active_characters.insert(id);
        }
        Ok(())
    }

    /// BlackholeIterator.explode_singularity.
    fn explode_singularity(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let star_colors = [
            Color::from_hex("#ffcc0d").unwrap(),
            Color::from_hex("#ff7326").unwrap(),
            Color::from_hex("#ff194d").unwrap(),
            Color::from_hex("#bf2669").unwrap(),
            Color::from_hex("#702a8c").unwrap(),
            Color::from_hex("#049dbf").unwrap(),
        ];
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
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
            let circle_coords = geometry::find_coords_on_circle(input_coord, 3, 5, true);
            let nearby_coord = circle_coords[ctx.rng.randrange(0, 5) as usize];
            let nearby_speed = ctx.rng.randint(3, 4) as f64 / 10.0;
            let nearby_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let path_id = ch
                    .motion
                    .new_path(nearby_speed, Some(Easing::OutExpo), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(nearby_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            let input_speed = ctx.rng.randint(4, 6) as f64 / 100.0;
            let input_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let path_id = ch
                    .motion
                    .new_path(input_speed, Some(Easing::InCubic), None, 0, false, "")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            let explode_star_color = ctx.rng.choice(&star_colors).clone();
            let explode_scn = {
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
                            colors: Some(ColorPair::new(Some(explode_star_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                scene_id
            };
            let cooling_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            if dynamic && ctx.preexisting_colors_present {
                if input_fg.is_none() && input_bg.is_none() {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation
                        .scenes
                        .get_mut(&cooling_scn)
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            1,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    let cooling_gradient_fg = match &input_fg {
                        Some(fg) => Some(
                            Gradient::with_steps(&[explode_star_color.clone(), fg.clone()], 10, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let cooling_gradient_bg = match &input_bg {
                        Some(bg) => Some(
                            Gradient::with_steps(&[explode_star_color.clone(), bg.clone()], 10, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation
                        .scenes
                        .get_mut(&cooling_scn)
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            20,
                            cooling_gradient_fg.as_ref(),
                            cooling_gradient_bg.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                let cooling_gradient =
                    Gradient::with_steps(&[explode_star_color.clone(), final_color], 10, false)
                        .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&cooling_scn)
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 20, Some(&cooling_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(nearby_path.clone()),
                EventAction::ActivatePath(input_path),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(nearby_path.clone()),
                EventAction::ActivateScene(cooling_scn),
            )
            .map_err(EngineError::Other)?;
            ctx.activate_scene(self, id, &explode_scn);
            ctx.activate_path(self, id, &nearby_path);
            ctx.active_characters.insert(id);
        }
        Ok(())
    }
}

impl EffectHooks for Blackhole {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Blackhole {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // BlackholeIterator.__init__
        self.blackhole_radius = std::cmp::max(
            std::cmp::min(
                round_half_even(ctx.terminal.canvas.width as f64 * 0.3),
                round_half_even(ctx.terminal.canvas.height as f64 * 0.20),
            ),
            3,
        );
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &characters {
            let input_coord = ctx.terminal.arena[id.0 as usize].input_coord;
            self.character_final_color_map
                .insert(id, final_gradient_mapping.get(&input_coord).unwrap().clone());
        }
        self.prepare_blackhole(ctx)?;
        self.formation_delay = std::cmp::max(floor_div(100, self.blackhole_chars.len() as i64), 6);
        self.f_delay = self.formation_delay;
        self.phase = Phase::Forming;
        self.awaiting_blackhole_chars = self.blackhole_chars.clone();
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !ctx.active_characters.is_empty() || self.phase != Phase::Complete {
            match self.phase {
                Phase::Forming => {
                    if !self.awaiting_blackhole_chars.is_empty() {
                        if self.f_delay == 0 {
                            let next_char = self.awaiting_blackhole_chars.remove(0);
                            ctx.activate_path(self, next_char, "blackhole");
                            ctx.activate_scene(self, next_char, "blackhole");
                            ctx.active_characters.insert(next_char);
                            self.f_delay = self.formation_delay;
                        } else {
                            self.f_delay -= 1;
                        }
                    } else if ctx.active_characters.is_empty() {
                        self.rotate_blackhole(ctx);
                        self.phase = Phase::Consuming;
                    }
                }
                Phase::Consuming => {
                    if !self.awaiting_consumption_chars.is_empty() {
                        for &id in &self.awaiting_consumption_chars.clone() {
                            ctx.activate_path(self, id, "singularity");
                            ctx.active_characters.insert(id);
                        }
                        self.awaiting_consumption_chars.clear();
                    } else {
                        let blackhole_set: HashSet<CharId> = self.blackhole_chars.iter().copied().collect();
                        if ctx.active_characters.iter().all(|id| blackhole_set.contains(&id)) {
                            self.phase = Phase::Collapsing;
                        }
                    }
                }
                Phase::Collapsing => {
                    self.collapse_blackhole(ctx).expect("collapse_blackhole failed");
                    self.phase = Phase::Exploding;
                }
                Phase::Exploding => {
                    if self.blackhole_chars.iter().all(|&id| {
                        let ch = &ctx.terminal.arena[id.0 as usize];
                        ch.motion.active_path.is_none() && ch.animation.active_scene.is_none()
                    }) {
                        self.explode_singularity(ctx).expect("explode_singularity failed");
                        self.phase = Phase::Complete;
                    }
                }
                Phase::Complete => {}
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
