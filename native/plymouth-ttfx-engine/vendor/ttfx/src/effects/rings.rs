//! rings, ported from effects/effect_rings.py.
//!
//! The inner RingsIterator.Ring class is the `Ring` struct; Python Path/Scene
//! object references become path/scene id strings (Path equality is by id).
//! No observable set iteration beyond the engine-canonical active_characters
//! (docs/ordering-inventory.md).

use std::collections::{HashMap, HashSet};

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_positive_float, parse_positive_float_range,
    parse_positive_int,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::round_half_even;

/// Callback id: terminal.set_character_visibility(character, False).
const CB_SET_INVISIBLE: u32 = 0;

#[derive(Args, Debug, Clone)]
pub struct RingsConfig {
    /// Space separated, unquoted, list of colors for the rings.
    #[arg(long = "ring-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["ab48ff", "e7b2b2", "fffebd"])]
    pub ring_colors: Vec<Color>,

    /// Distance between rings as a percent of the smallest canvas dimension.
    #[arg(long = "ring-gap", default_value_t = 0.1, value_parser = parse_positive_float)]
    pub ring_gap: f64,

    /// Number of frames for each cycle of the spin phase.
    #[arg(long = "spin-duration", default_value_t = 200, value_parser = parse_positive_int)]
    pub spin_duration: i64,

    /// Range of speeds for the rotation of the rings. The speed is randomly selected from this range for each ring.
    #[arg(long = "spin-speed", default_value = "0.25-1.0", value_parser = parse_positive_float_range)]
    pub spin_speed: (f64, f64),

    /// Number of frames spent in the dispersed state between spinning cycles.
    #[arg(long = "disperse-duration", default_value_t = 200, value_parser = parse_positive_int)]
    pub disperse_duration: i64,

    /// Number of times the animation will cycles between spinning rings and dispersed characters.
    #[arg(long = "spin-disperse-cycles", default_value_t = 3, value_parser = parse_positive_int)]
    pub spin_disperse_cycles: i64,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ab48ff", "e7b2b2", "fffebd"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// RingsIterator.Ring.
struct Ring {
    #[allow(dead_code)]
    radius: i64,
    #[allow(dead_code)]
    origin: Coord,
    counter_clockwise_coords: Vec<Coord>,
    clockwise_coords: Vec<Coord>,
    ring_gap: i64,
    ring_color: Color,
    characters: Vec<CharId>,
    /// Path ids (upstream holds Path objects; Path equality is by id).
    character_last_ring_path: HashMap<CharId, String>,
    rotation_speed: f64,
}

impl Ring {
    /// Ring.__init__ — consumes one uniform() for rotation_speed.
    fn new(ctx: &mut EngineCtx, config: &RingsConfig, radius: i64, origin: Coord, ring_coords: Vec<Coord>, ring_gap: i64, ring_color: Color) -> Self {
        let clockwise_coords: Vec<Coord> = ring_coords.iter().rev().copied().collect();
        let rotation_speed = ctx.rng.uniform(config.spin_speed.0, config.spin_speed.1);
        Ring {
            radius,
            origin,
            counter_clockwise_coords: ring_coords,
            clockwise_coords,
            ring_gap,
            ring_color,
            characters: Vec::new(),
            character_last_ring_path: HashMap::new(),
            rotation_speed,
        }
    }

    /// Ring.make_disperse_waypoints.
    fn make_disperse_waypoints(&self, ctx: &mut EngineCtx, id: CharId, origin: Coord) -> Result<String, EngineError> {
        let disperse_coords = geometry::find_coords_in_rect(origin, self.ring_gap);
        let mut waypoint_coords: Vec<Coord> = Vec::with_capacity(5);
        for _ in 0..5 {
            let index = ctx.rng.randrange(0, disperse_coords.len() as i64) as usize;
            waypoint_coords.push(disperse_coords[index]);
        }
        let ch = &mut ctx.terminal.arena[id.0 as usize];
        ch.motion.paths.remove("disperse");
        let path_id = ch
            .motion
            .new_path(0.14, None, None, 0, true, "disperse")
            .map_err(EngineError::Other)?;
        let path = ch.motion.paths.get_mut(&path_id).unwrap();
        for coord in waypoint_coords {
            path.new_waypoint(coord, None, "").map_err(EngineError::Other)?;
        }
        Ok(path_id)
    }
}

/// dict phase strings from RingsIterator.__next__.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Start,
    Disperse,
    Spin,
    Final,
    Complete,
}

pub struct Rings {
    config: RingsConfig,
    rings: Vec<Ring>,
    non_ring_chars: Vec<CharId>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    phase: Phase,
    initial_disperse_complete: bool,
    spin_time_remaining: i64,
    disperse_time_remaining: i64,
    cycles_remaining: i64,
    initial_phase_time_remaining: i64,
}

impl Rings {
    pub fn new(config: RingsConfig) -> Self {
        let spin_time_remaining = config.spin_duration;
        let disperse_time_remaining = config.disperse_duration;
        let cycles_remaining = config.spin_disperse_cycles;
        Rings {
            config,
            rings: Vec::new(),
            non_ring_chars: Vec::new(),
            character_final_color_map: HashMap::new(),
            phase: Phase::Start,
            initial_disperse_complete: false,
            spin_time_remaining,
            disperse_time_remaining,
            cycles_remaining,
            initial_phase_time_remaining: 100,
        }
    }

    /// Ring.add_character (needs the effect-level color map, so lives here).
    fn ring_add_character(
        &mut self,
        ctx: &mut EngineCtx,
        ring: &mut Ring,
        id: CharId,
        clockwise: bool,
    ) -> Result<(), EngineError> {
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let (input_symbol, uses_pre) = {
            let ch = &ctx.terminal.arena[id.0 as usize];
            (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
        };
        // make gradient scene
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let gradient_scn = ch.animation.new_scene(false, None, None, "gradient", uses_pre);
            let scene = ch.animation.scenes.get_mut(&gradient_scn).unwrap();
            if dynamic {
                let colors = self.character_final_color_map.get(&id).unwrap().clone();
                scene
                    .add_frame(&input_symbol, 1, VisualParams { colors: Some(colors), ..Default::default() })
                    .map_err(EngineError::Other)?;
            } else {
                let final_fg_color = self
                    .character_final_color_map
                    .get(&id)
                    .unwrap()
                    .fg_color
                    .clone()
                    .expect("gradient mapping fg");
                let char_gradient = Gradient::with_steps(&[final_fg_color, ring.ring_color.clone()], 8, false)
                    .map_err(EngineError::Other)?;
                scene
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 3, Some(&char_gradient), None)
                    .map_err(EngineError::Other)?;
            }
        }

        // make rotation waypoints
        let mut ring_paths: Vec<String> = Vec::new();
        let character_starting_index = ring.characters.len();
        let coords = if clockwise { &ring.clockwise_coords } else { &ring.counter_clockwise_coords };
        let rotated: Vec<Coord> = coords[character_starting_index..]
            .iter()
            .chain(coords[..character_starting_index].iter())
            .copied()
            .collect();
        for coord in rotated {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let path_id = ch
                .motion
                .new_path(ring.rotation_speed, None, None, 0, false, &ring_paths.len().to_string())
                .map_err(EngineError::Other)?;
            let path = ch.motion.paths.get_mut(&path_id).unwrap();
            let waypoint_id = path.waypoints.len().to_string();
            path.new_waypoint(coord, None, &waypoint_id).map_err(EngineError::Other)?;
            ring_paths.push(path_id);
        }
        ring.character_last_ring_path.insert(id, ring_paths[0].clone());

        // make disperse scene
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let disperse_scn = ch.animation.new_scene(false, None, None, "disperse", uses_pre);
            let scene = ch.animation.scenes.get_mut(&disperse_scn).unwrap();
            if dynamic {
                let colors = self.character_final_color_map.get(&id).unwrap().clone();
                scene
                    .add_frame(&input_symbol, 1, VisualParams { colors: Some(colors), ..Default::default() })
                    .map_err(EngineError::Other)?;
            } else {
                let final_fg_color = self
                    .character_final_color_map
                    .get(&id)
                    .unwrap()
                    .fg_color
                    .clone()
                    .expect("gradient mapping fg");
                let disperse_gradient = Gradient::with_steps(&[ring.ring_color.clone(), final_fg_color], 8, false)
                    .map_err(EngineError::Other)?;
                scene
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 10, Some(&disperse_gradient), None)
                    .map_err(EngineError::Other)?;
            }
        }
        ctx.chain_paths(id, &ring_paths, true).map_err(EngineError::Other)?;
        ring.characters.push(id);
        Ok(())
    }

    /// Ring.disperse.
    fn ring_disperse(&mut self, ctx: &mut EngineCtx, ring: &mut Ring) -> Result<(), EngineError> {
        let characters = ring.characters.clone();
        for id in characters {
            let (active_path, current_coord) = {
                let motion = &ctx.terminal.arena[id.0 as usize].motion;
                (motion.active_path.clone(), motion.current_coord)
            };
            let last = match active_path {
                Some(path_id) => path_id.to_string(),
                None => "0".to_string(),
            };
            ring.character_last_ring_path.insert(id, last);
            let disperse_path = ring.make_disperse_waypoints(ctx, id, current_coord)?;
            ctx.activate_path(self, id, &disperse_path);
            ctx.activate_scene(self, id, "disperse");
        }
        Ok(())
    }

    /// Ring.spin.
    fn ring_spin(&mut self, ctx: &mut EngineCtx, ring: &mut Ring) -> Result<(), EngineError> {
        let characters = ring.characters.clone();
        for id in characters {
            let last_ring_path = ring.character_last_ring_path.get(&id).unwrap().clone();
            let condense_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let first_waypoint_coord = ch
                    .motion
                    .paths
                    .get(&last_ring_path)
                    .expect("last ring path missing")
                    .waypoints[0]
                    .coord;
                let path_id = ch.motion.new_path(0.1, None, None, 0, false, "").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(first_waypoint_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(condense_path.clone()),
                EventAction::ActivatePath(last_ring_path),
            )
            .map_err(EngineError::Other)?;
            ctx.activate_path(self, id, &condense_path);
            ctx.activate_scene(self, id, "gradient");
        }
        Ok(())
    }
}

impl EffectHooks for Rings {
    fn dispatch_callback(&mut self, ctx: &mut EngineCtx, character: CharId, callback: &EffectCallback) {
        if callback.id == CB_SET_INVISIBLE {
            ctx.terminal.set_character_visibility(character, false);
        }
    }
}

impl Effect for Rings {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // ring_gap = int(max(round(min(top, right) * config.ring_gap), 1))
        let ring_gap = std::cmp::max(
            round_half_even(
                std::cmp::min(ctx.terminal.canvas.top, ctx.terminal.canvas.right) as f64 * self.config.ring_gap,
            ),
            1,
        );
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
        let mut pending_chars: Vec<CharId> = Vec::new();
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
            let final_colors = if dynamic {
                ColorPair::new(input_fg, input_bg)
            } else {
                ColorPair::new(Some(final_gradient_mapping.get(&input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors.clone());
            let start_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .add_frame(&input_symbol, 1, VisualParams { colors: Some(final_colors), ..Default::default() })
                    .map_err(EngineError::Other)?;
                scene_id
            };
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let home_path = ch
                    .motion
                    .new_path(0.8, Some(Easing::OutQuad), None, 0, false, "home")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&home_path)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            ctx.activate_scene(self, id, &start_scn);
            ctx.terminal.set_character_visibility(id, true);
            pending_chars.push(id);
        }

        ctx.rng.shuffle(&mut pending_chars);

        // make rings
        let mut rings: Vec<Ring> = Vec::new();
        let center = ctx.terminal.canvas.center;
        let radius_limit = std::cmp::max(ctx.terminal.canvas.right, ctx.terminal.canvas.top);
        let mut radius = 1;
        while radius < radius_limit {
            let ring_coords = geometry::find_coords_on_circle(center, radius, 7 * radius, true);
            // check if any part of the ring is in the canvas, if not, stop creating rings
            let in_canvas_count =
                ring_coords.iter().filter(|&&coord| ctx.terminal.canvas.coord_is_in_canvas(coord)).count();
            if (in_canvas_count as f64) / (ring_coords.len() as f64) < 0.25 {
                break;
            }
            let ring_color = self.config.ring_colors[rings.len() % self.config.ring_colors.len()].clone();
            let ring = Ring::new(ctx, &self.config, radius, center, ring_coords, ring_gap, ring_color);
            rings.push(ring);
            radius += ring_gap;
        }

        // assign characters to rings
        let mut pending_iter = pending_chars.into_iter().collect::<std::collections::VecDeque<_>>();
        let mut ring_chars: HashSet<CharId> = HashSet::new();
        for (ring_count, ring) in rings.iter_mut().enumerate() {
            for _ in 0..ring.counter_clockwise_coords.len() {
                if let Some(next_character) = pending_iter.pop_front() {
                    // set rings to rotate in opposite directions
                    let clockwise = ring_count % 2 == 1;
                    self.ring_add_character(ctx, ring, next_character, clockwise)?;
                    ring_chars.insert(next_character);
                }
            }
        }
        self.rings = rings;

        // make external waypoints for characters not in rings
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            if ring_chars.contains(&id) {
                continue;
            }
            let external_coord = ctx.terminal.canvas.random_coord(&mut ctx.rng, true, false);
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let external_path = ch
                    .motion
                    .new_path(0.8, Some(Easing::OutSine), None, 0, false, "external")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&external_path)
                    .unwrap()
                    .new_waypoint(external_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            self.non_ring_chars.push(id);
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("external".to_string()),
                EventAction::Callback(EffectCallback { id: CB_SET_INVISIBLE, args: Vec::new() }),
            )
            .map_err(EngineError::Other)?;
        }
        self.phase = Phase::Start;
        self.initial_disperse_complete = false;
        self.spin_time_remaining = self.config.spin_duration;
        self.disperse_time_remaining = self.config.disperse_duration;
        self.cycles_remaining = self.config.spin_disperse_cycles;
        self.initial_phase_time_remaining = 100;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.phase == Phase::Complete {
            return None;
        }
        match self.phase {
            Phase::Start => {
                if self.initial_phase_time_remaining == 0 {
                    self.phase = Phase::Disperse;
                } else {
                    self.initial_phase_time_remaining -= 1;
                }
            }
            Phase::Disperse => {
                if !self.initial_disperse_complete {
                    self.initial_disperse_complete = true;
                    let mut rings = std::mem::take(&mut self.rings);
                    for ring in &mut rings {
                        let characters = ring.characters.clone();
                        for id in characters {
                            let ring_start_coord =
                                ctx.terminal.arena[id.0 as usize].motion.paths.get("0").unwrap().waypoints[0].coord;
                            let disperse_path = ring
                                .make_disperse_waypoints(ctx, id, ring_start_coord)
                                .expect("make_disperse_waypoints failed");
                            let initial_path = {
                                let ch = &mut ctx.terminal.arena[id.0 as usize];
                                let disperse_first_coord =
                                    ch.motion.paths.get(&disperse_path).unwrap().waypoints[0].coord;
                                let path_id = ch
                                    .motion
                                    .new_path(0.3, Some(Easing::OutCubic), None, 0, false, "")
                                    .expect("new_path failed");
                                ch.motion
                                    .paths
                                    .get_mut(&path_id)
                                    .unwrap()
                                    .new_waypoint(disperse_first_coord, None, "")
                                    .expect("new_waypoint failed");
                                path_id
                            };
                            ctx.register_event(
                                id,
                                Event::PathComplete,
                                CallerKey::Path(initial_path.clone()),
                                EventAction::ActivatePath(disperse_path),
                            )
                            .expect("register_event failed");
                            ctx.activate_scene(self, id, "disperse");
                            ctx.activate_path(self, id, &initial_path);
                            ctx.active_characters.insert(id);
                        }
                    }
                    self.rings = rings;

                    let non_ring_chars = self.non_ring_chars.clone();
                    for id in non_ring_chars {
                        ctx.activate_path(self, id, "external");
                        ctx.active_characters.insert(id);
                    }
                } else if self.disperse_time_remaining == 0 {
                    self.phase = Phase::Spin;
                    self.cycles_remaining -= 1;
                    self.spin_time_remaining = self.config.spin_duration;
                    let mut rings = std::mem::take(&mut self.rings);
                    for ring in &mut rings {
                        self.ring_spin(ctx, ring).expect("ring spin failed");
                    }
                    self.rings = rings;
                } else {
                    self.disperse_time_remaining -= 1;
                }
            }
            Phase::Spin => {
                if self.spin_time_remaining == 0 {
                    if self.cycles_remaining == 0 {
                        self.phase = Phase::Final;
                        let characters = {
                            let filter = CharacterFilter::default();
                            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                        };
                        for id in characters {
                            ctx.terminal.set_character_visibility(id, true);
                            ctx.activate_path(self, id, "home");
                            ctx.active_characters.insert(id);
                            if ctx.terminal.arena[id.0 as usize].motion.paths.contains_key("external") {
                                continue;
                            }
                            ctx.activate_scene(self, id, "disperse");
                        }
                    } else {
                        self.disperse_time_remaining = self.config.disperse_duration;
                        let mut rings = std::mem::take(&mut self.rings);
                        for ring in &mut rings {
                            self.ring_disperse(ctx, ring).expect("ring disperse failed");
                        }
                        self.rings = rings;
                        self.phase = Phase::Disperse;
                    }
                } else {
                    self.spin_time_remaining -= 1;
                }
            }
            Phase::Final => {
                if ctx.active_characters.is_empty() {
                    self.phase = Phase::Complete;
                }
            }
            Phase::Complete => unreachable!(),
        }
        ctx.update(self);
        Some(ctx.frame())
    }
}
