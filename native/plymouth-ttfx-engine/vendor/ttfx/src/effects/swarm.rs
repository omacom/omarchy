//! swarm, ported from effects/effect_swarm.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_non_negative_ratio, parse_positive_int_range,
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
pub struct SwarmConfig {
    /// Space separated, unquoted, list of colors for the swarms.
    #[arg(long = "base-color", num_args = 1.., value_parser = parse_color,
          default_values = ["31a0d4"])]
    pub base_color: Vec<Color>,

    /// Color for the character flash. Characters flash when moving.
    #[arg(long = "flash-color", default_value = "f2ea79", value_parser = parse_color)]
    pub flash_color: Color,

    /// Percent of total characters in each swarm.
    #[arg(long = "swarm-size", default_value_t = 0.1, value_parser = parse_non_negative_ratio)]
    pub swarm_size: f64,

    /// Percent of characters in a swarm that move as a group.
    #[arg(long = "swarm-coordination", default_value_t = 0.80, value_parser = parse_non_negative_ratio)]
    pub swarm_coordination: f64,

    /// Range of the number of areas where characters will swarm.
    #[arg(long = "swarm-area-count-range", default_value = "2-4", value_parser = parse_positive_int_range)]
    pub swarm_area_count_range: (i64, i64),

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["31b900", "f0ff65"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "horizontal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

pub struct Swarm {
    config: SwarmConfig,
    swarms: Vec<Vec<CharId>>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    call_next: bool,
    active_swarm_area: String,
    current_swarm: Vec<CharId>,
}

impl Swarm {
    pub fn new(config: SwarmConfig) -> Self {
        Swarm {
            config,
            swarms: Vec::new(),
            character_final_color_map: HashMap::new(),
            call_next: true,
            active_swarm_area: "0_swarm_area".to_string(),
            current_swarm: Vec::new(),
        }
    }

    /// SwarmIterator.make_swarms.
    fn make_swarms(&mut self, ctx: &mut EngineCtx, swarm_size: i64) {
        let mut unswarmed_characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::BottomToTopRightToLeft)
        };
        while !unswarmed_characters.is_empty() {
            let mut new_swarm: Vec<CharId> = Vec::new();
            for _ in 0..swarm_size {
                if let Some(id) = unswarmed_characters.pop() {
                    new_swarm.push(id);
                } else {
                    break;
                }
            }
            self.swarms.push(new_swarm);
        }
        let final_swarm = self.swarms.pop().expect("make_swarms: no swarms");
        if (final_swarm.len() as i64) < floor_div(swarm_size, 2) {
            self.swarms
                .last_mut()
                .expect("upstream IndexError: no preceding swarm to merge into")
                .extend(final_swarm);
        } else {
            self.swarms.push(final_swarm);
        }
    }
}

/// int(s[0]) on a path id string (effect_swarm.py's first-character parse).
fn first_char_digit(s: &str) -> i64 {
    s.chars().next().and_then(|c| c.to_digit(10)).expect("path id must start with a digit") as i64
}

impl EffectHooks for Swarm {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Swarm {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // SwarmIterator.DYNAMIC_CLEAR_COLOR
        let dynamic_clear_color = Color::from_hex("#ffffff").unwrap();
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        let swarm_size: i64 =
            std::cmp::max(round_half_even(characters.len() as f64 * self.config.swarm_size), 1);
        self.make_swarms(ctx, swarm_size);
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        for &id in &characters {
            let ch = &ctx.terminal.arena[id.0 as usize];
            let final_colors = if dynamic {
                ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
            } else {
                ColorPair::new(Some(final_gradient_mapping.get(&ch.input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors);
        }
        let flash_list: Vec<Color> = (0..10).map(|_| self.config.flash_color.clone()).collect();
        let canvas_right = ctx.terminal.canvas.right;
        let canvas_top = ctx.terminal.canvas.top;
        // stands in for upstream's process-wide find_coords_on_circle lru_cache
        let mut circle_cache: HashMap<Coord, Vec<Coord>> = HashMap::new();
        for swarm_index in 0..self.swarms.len() {
            let swarm = self.swarms[swarm_index].clone();
            let base = ctx.rng.choice(&self.config.base_color).clone();
            let swarm_gradient = Gradient::with_steps(&[base, self.config.flash_color.clone()], 7, false)
                .map_err(EngineError::Other)?;
            let swarm_gradient_mirror: Vec<Color> = swarm_gradient
                .spectrum
                .iter()
                .cloned()
                .chain(flash_list.iter().cloned())
                .chain(swarm_gradient.spectrum.iter().rev().cloned())
                .collect();
            // dict[Coord, list[Coord]] — insertion-ordered with key-overwrite-in-place
            let mut swarm_area_coordinate_map: Vec<(Coord, Vec<Coord>)> = Vec::new();
            let swarm_spawn = ctx.terminal.canvas.random_coord(&mut ctx.rng, true, false);
            let mut swarm_areas: Vec<Coord> = Vec::new();
            let swarm_area_count =
                ctx.rng.randint(self.config.swarm_area_count_range.0, self.config.swarm_area_count_range.1);
            // create areas where characters will swarm
            let mut last_focus_coord = swarm_spawn;
            let radius = std::cmp::max(floor_div(std::cmp::min(canvas_right, canvas_top), 2), 1);
            while (swarm_areas.len() as i64) < swarm_area_count {
                // Upstream find_coords_on_circle is lru_cached and swarm shuffles the
                // RETURNED LIST IN PLACE, mutating the cache: a later call with the
                // same focus coord returns the previously shuffled list, not the
                // freshly computed one. Reproduce that observable quirk with an
                // effect-local cache whose entries persist the shuffle mutation
                // (the only in-process mutator of this cache is this loop).
                let cached = circle_cache
                    .entry(last_focus_coord)
                    .or_insert_with(|| geometry::find_coords_on_circle(last_focus_coord, radius, 0, true));
                ctx.rng.shuffle(cached);
                let potential_focus_coords = cached.clone();
                let mut next_focus_coord: Option<Coord> = None;
                for coord in &potential_focus_coords {
                    if ctx.terminal.canvas.coord_is_in_canvas(*coord) {
                        next_focus_coord = Some(*coord);
                        break;
                    }
                }
                let next_focus_coord = match next_focus_coord {
                    Some(coord) => coord,
                    None => ctx.terminal.canvas.random_coord(&mut ctx.rng, false, false),
                };
                swarm_areas.push(next_focus_coord);
                let area_coords = geometry::find_coords_in_circle(
                    last_focus_coord,
                    std::cmp::max(floor_div(std::cmp::min(canvas_right, canvas_top), 6), 1) * 2,
                );
                if let Some(entry) =
                    swarm_area_coordinate_map.iter_mut().find(|(coord, _)| *coord == last_focus_coord)
                {
                    entry.1 = area_coords;
                } else {
                    swarm_area_coordinate_map.push((last_focus_coord, area_coords));
                }
                last_focus_coord = next_focus_coord;
            }

            // assign characters waypoints for swarm areas and inner waypoints within the swarm areas
            for &id in &swarm {
                let (input_coord, input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (ch.input_coord, ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                let flash_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.motion.set_coordinate(swarm_spawn);
                    let scene_id = ch.animation.new_scene(false, Some(SyncMetric::Distance), None, "", uses_pre);
                    let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                    for step in &swarm_gradient_mirror {
                        scene
                            .add_frame(
                                &input_symbol,
                                1,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(step.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                    scene_id
                };
                for (swarm_area_count, (_, swarm_area_coords)) in swarm_area_coordinate_map.iter().enumerate() {
                    let swarm_area_name = format!("{swarm_area_count}_swarm_area");
                    let origin_waypoint_coord = *ctx.rng.choice(swarm_area_coords);
                    {
                        let ch = &mut ctx.terminal.arena[id.0 as usize];
                        let origin_path = ch
                            .motion
                            .new_path(0.4, Some(Easing::OutSine), None, 0, false, &swarm_area_name)
                            .map_err(EngineError::Other)?;
                        ch.motion
                            .paths
                            .get_mut(&origin_path)
                            .unwrap()
                            .new_waypoint(origin_waypoint_coord, None, &swarm_area_name)
                            .map_err(EngineError::Other)?;
                    }
                    ctx.register_event(
                        id,
                        Event::PathActivated,
                        CallerKey::Path(swarm_area_name.clone()),
                        EventAction::ActivateScene(flash_scn.clone()),
                    )
                    .map_err(EngineError::Other)?;
                    ctx.register_event(
                        id,
                        Event::PathActivated,
                        CallerKey::Path(swarm_area_name.clone()),
                        EventAction::SetLayer(1),
                    )
                    .map_err(EngineError::Other)?;
                    ctx.register_event(
                        id,
                        Event::PathComplete,
                        CallerKey::Path(swarm_area_name.clone()),
                        EventAction::DeactivateScene(None),
                    )
                    .map_err(EngineError::Other)?;
                    let mut inner_paths = 0;
                    let total_inner_paths = 2;
                    while inner_paths < total_inner_paths {
                        let next_coord = *ctx.rng.choice(swarm_area_coords);
                        inner_paths += 1;
                        let ch = &mut ctx.terminal.arena[id.0 as usize];
                        let inner_path_id = ch.motion.paths.len().to_string();
                        let inner_path = ch
                            .motion
                            .new_path(0.18, Some(Easing::InOutSine), None, 0, false, &inner_path_id)
                            .map_err(EngineError::Other)?;
                        let waypoint_id = ch.motion.paths.len().to_string();
                        ch.motion
                            .paths
                            .get_mut(&inner_path)
                            .unwrap()
                            .new_waypoint(next_coord, None, &waypoint_id)
                            .map_err(EngineError::Other)?;
                    }
                }
                // create landing waypoint and scene
                let input_path = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let path_id = ch
                        .motion
                        .new_path(0.45, Some(Easing::InOutQuad), None, 0, false, "")
                        .map_err(EngineError::Other)?;
                    ch.motion
                        .paths
                        .get_mut(&path_id)
                        .unwrap()
                        .new_waypoint(input_coord, None, "")
                        .map_err(EngineError::Other)?;
                    path_id
                };
                let input_scn = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.new_scene(false, None, None, "", uses_pre)
                };
                let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
                if dynamic {
                    if final_colors.fg_color.is_none() && final_colors.bg_color.is_none() {
                        let clear_gradient = Gradient::with_steps(
                            &[self.config.flash_color.clone(), dynamic_clear_color.clone()],
                            10,
                            false,
                        )
                        .map_err(EngineError::Other)?;
                        let ch = &mut ctx.terminal.arena[id.0 as usize];
                        let scene = ch.animation.scenes.get_mut(&input_scn).unwrap();
                        for step in &clear_gradient.spectrum {
                            scene
                                .add_frame(
                                    &input_symbol,
                                    3,
                                    VisualParams {
                                        colors: Some(ColorPair::new(Some(step.clone()), None)),
                                        ..Default::default()
                                    },
                                )
                                .map_err(EngineError::Other)?;
                        }
                        scene
                            .add_frame(
                                &input_symbol,
                                3,
                                VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    } else {
                        let fg_gradient = match &final_colors.fg_color {
                            Some(fg) => Some(
                                Gradient::with_steps(&[self.config.flash_color.clone(), fg.clone()], 10, false)
                                    .map_err(EngineError::Other)?,
                            ),
                            None => None,
                        };
                        let bg_gradient = match &final_colors.bg_color {
                            Some(bg) => Some(
                                Gradient::with_steps(&[self.config.flash_color.clone(), bg.clone()], 10, false)
                                    .map_err(EngineError::Other)?,
                            ),
                            None => None,
                        };
                        let ch = &mut ctx.terminal.arena[id.0 as usize];
                        ch.animation
                            .scenes
                            .get_mut(&input_scn)
                            .unwrap()
                            .apply_gradient_to_symbols(
                                &[input_symbol.clone()],
                                3,
                                fg_gradient.as_ref(),
                                bg_gradient.as_ref(),
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let final_fg = final_colors.fg_color.clone().expect("gradient mapping fg");
                    let landing_gradient =
                        Gradient::with_steps(&[self.config.flash_color.clone(), final_fg], 10, false)
                            .map_err(EngineError::Other)?;
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut(&input_scn).unwrap();
                    for step in &landing_gradient.spectrum {
                        scene
                            .add_frame(
                                &input_symbol,
                                3,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(step.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
                ctx.register_event(
                    id,
                    Event::PathComplete,
                    CallerKey::Path(input_path.clone()),
                    EventAction::ActivateScene(input_scn),
                )
                .map_err(EngineError::Other)?;
                ctx.register_event(
                    id,
                    Event::PathComplete,
                    CallerKey::Path(input_path.clone()),
                    EventAction::SetLayer(0),
                )
                .map_err(EngineError::Other)?;
                ctx.register_event(
                    id,
                    Event::PathActivated,
                    CallerKey::Path(input_path),
                    EventAction::ActivateScene(flash_scn),
                )
                .map_err(EngineError::Other)?;
                let all_paths: Vec<String> = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    ch.motion.paths.keys().map(|key| key.to_string()).collect()
                };
                ctx.chain_paths(id, &all_paths, false).map_err(EngineError::Other)?;
            }
        }
        self.call_next = true;
        self.active_swarm_area = "0_swarm_area".to_string();
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.swarms.is_empty() || !ctx.active_characters.is_empty() {
            if !self.swarms.is_empty() && self.call_next {
                self.call_next = false;
                self.current_swarm = self.swarms.pop().unwrap();
                self.active_swarm_area = "0_swarm_area".to_string();
                for &id in &self.current_swarm.clone() {
                    ctx.activate_path(self, id, "0_swarm_area");
                    ctx.terminal.set_character_visibility(id, true);
                    ctx.active_characters.insert(id);
                }
            }
            if ctx.active_characters.len() < self.current_swarm.len() {
                // some of the characters have landed
                self.call_next = true;
            }
            if !self.current_swarm.is_empty() {
                for i in 0..self.current_swarm.len() {
                    let id = self.current_swarm[i];
                    let active_path_id = ctx.terminal.arena[id.0 as usize].motion.active_path.clone();
                    if let Some(path_id) = active_path_id {
                        if path_id.as_ref() != self.active_swarm_area
                            && path_id.contains("swarm_area")
                            && first_char_digit(&path_id) > first_char_digit(&self.active_swarm_area)
                        {
                            self.active_swarm_area = path_id.to_string();
                            for &other in &self.current_swarm.clone() {
                                if other != id && ctx.rng.random() < self.config.swarm_coordination {
                                    let area = self.active_swarm_area.clone();
                                    ctx.activate_path(self, other, &area);
                                }
                            }
                            break;
                        }
                    }
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
