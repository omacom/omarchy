//! orbittingvolley, ported from effects/effect_orbittingvolley.py.
//!
//! The inner OrbittingVolleyIterator.Launcher class is the `Launcher` struct.
//! No observable set iteration beyond the engine-canonical active_characters
//! (docs/ordering-inventory.md); the effect consumes no RNG at all.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_non_negative_int, parse_non_negative_ratio,
    parse_positive_float, parse_symbol,
};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, CoordColorMap, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct OrbittingVolleyConfig {
    /// Symbol for the top launcher.
    #[arg(long = "top-launcher-symbol", default_value = "█", value_parser = parse_symbol)]
    pub top_launcher_symbol: String,

    /// Symbol for the right launcher.
    #[arg(long = "right-launcher-symbol", default_value = "█", value_parser = parse_symbol)]
    pub right_launcher_symbol: String,

    /// Symbol for the bottom launcher.
    #[arg(long = "bottom-launcher-symbol", default_value = "█", value_parser = parse_symbol)]
    pub bottom_launcher_symbol: String,

    /// Symbol for the left launcher.
    #[arg(long = "left-launcher-symbol", default_value = "█", value_parser = parse_symbol)]
    pub left_launcher_symbol: String,

    /// Orbitting speed of the launchers.
    #[arg(long = "launcher-movement-speed", default_value_t = 0.8, value_parser = parse_positive_float)]
    pub launcher_movement_speed: f64,

    /// Speed of the launched characters.
    #[arg(long = "character-movement-speed", default_value_t = 1.5, value_parser = parse_positive_float)]
    pub character_movement_speed: f64,

    /// Percent of total input characters each launcher will fire per volley. Lower limit of one character.
    #[arg(long = "volley-size", default_value_t = 0.03, value_parser = parse_non_negative_ratio)]
    pub volley_size: f64,

    /// Number of animation ticks to wait between volleys of characters.
    #[arg(long = "launch-delay", default_value_t = 30, value_parser = parse_non_negative_int)]
    pub launch_delay: i64,

    /// Easing function to use for launched character movement.
    #[arg(long = "character-easing", default_value = "out_sine", value_parser = parse_easing)]
    pub character_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["FFA15C", "44D492"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "radial", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// OrbittingVolleyIterator.Launcher.
struct Launcher {
    character: CharId,
    magazine: Vec<CharId>,
}

pub struct OrbittingVolley {
    config: OrbittingVolleyConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
    launcher_gradient_coordinate_map: CoordColorMap,
    final_gradient_last_color: Option<Color>,
    launchers: Vec<Launcher>,
    delay: i64,
    complete: bool,
}

impl OrbittingVolley {
    pub fn new(config: OrbittingVolleyConfig) -> Self {
        OrbittingVolley {
            config,
            character_final_color_map: HashMap::new(),
            launcher_gradient_coordinate_map: CoordColorMap::default(),
            final_gradient_last_color: None,
            launchers: Vec::new(),
            delay: 0,
            complete: false,
        }
    }

    /// Launcher.build_paths (only called for the main launcher).
    fn build_launcher_paths(&self, ctx: &mut EngineCtx, id: CharId) -> Result<(), EngineError> {
        let waypoints = [
            Coord::new(ctx.terminal.canvas.left, ctx.terminal.canvas.top),
            Coord::new(ctx.terminal.canvas.right, ctx.terminal.canvas.top),
        ];
        let input_coord = ctx.terminal.arena[id.0 as usize].input_coord;
        let waypoint_start_index = waypoints
            .iter()
            .position(|&c| c == input_coord)
            .expect("launcher input coord not on perimeter waypoint list");
        let ch = &mut ctx.terminal.arena[id.0 as usize];
        let perimeter_path = ch
            .motion
            .new_path(self.config.launcher_movement_speed, None, Some(2), 0, false, "perimeter")
            .map_err(EngineError::Other)?;
        let path = ch.motion.paths.get_mut(&perimeter_path).unwrap();
        for waypoint in waypoints[waypoint_start_index..].iter().chain(waypoints[..waypoint_start_index].iter()) {
            path.new_waypoint(*waypoint, None, "").map_err(EngineError::Other)?;
        }
        Ok(())
    }

    /// Launcher.launch.
    fn launch(&mut self, ctx: &mut EngineCtx, launcher_index: usize) -> Option<CharId> {
        let launcher = &mut self.launchers[launcher_index];
        if launcher.magazine.is_empty() {
            return None;
        }
        let next_char = launcher.magazine.remove(0);
        let launcher_coord = ctx.terminal.arena[launcher.character.0 as usize].motion.current_coord;
        ctx.terminal.arena[next_char.0 as usize].motion.set_coordinate(launcher_coord);
        ctx.activate_path(self, next_char, "input_path");
        ctx.terminal.set_character_visibility(next_char, true);
        Some(next_char)
    }

    /// OrbittingVolleyIterator._set_launcher_coordinates.
    fn set_launcher_coordinates(&mut self, ctx: &mut EngineCtx, parent_index: usize, child_index: usize) {
        let canvas_top = ctx.terminal.canvas.top;
        let canvas_bottom = ctx.terminal.canvas.bottom;
        let canvas_left = ctx.terminal.canvas.left;
        let canvas_right = ctx.terminal.canvas.right;
        let parent_char = self.launchers[parent_index].character;
        let child_char = self.launchers[child_index].character;
        let parent_progress =
            ctx.terminal.arena[parent_char.0 as usize].motion.current_coord.column as f64 / canvas_right as f64;
        let child_input_coord = ctx.terminal.arena[child_char.0 as usize].input_coord;
        if child_input_coord == Coord::new(canvas_right, canvas_top) {
            let child_row = canvas_top - (canvas_top as f64 * parent_progress) as i64;
            ctx.terminal.arena[child_char.0 as usize]
                .motion
                .set_coordinate(Coord::new(canvas_right, std::cmp::max(1, child_row)));
        } else if child_input_coord == Coord::new(canvas_right, canvas_bottom) {
            let child_column = canvas_right - (canvas_right as f64 * parent_progress) as i64;
            ctx.terminal.arena[child_char.0 as usize]
                .motion
                .set_coordinate(Coord::new(std::cmp::max(1, child_column), canvas_bottom));
        } else if child_input_coord == Coord::new(canvas_left, canvas_bottom) {
            let child_row = canvas_bottom + (canvas_top as f64 * parent_progress) as i64;
            ctx.terminal.arena[child_char.0 as usize]
                .motion
                .set_coordinate(Coord::new(canvas_left, std::cmp::min(canvas_top, child_row)));
        }
        let current_coord = ctx.terminal.arena[child_char.0 as usize].motion.current_coord;
        let color = self
            .launcher_gradient_coordinate_map
            .get(&current_coord)
            .expect("launcher coord outside gradient map")
            .clone();
        let ch = &mut ctx.terminal.arena[child_char.0 as usize];
        let input_symbol = ch.input_symbol.clone();
        let uses_pre = ch.uses_input_preexisting_colors;
        ch.animation.set_appearance(
            &input_symbol,
            uses_pre,
            Some(&input_symbol.clone()),
            Some(ColorPair::new(Some(color), None)),
        );
    }
}

impl EffectHooks for OrbittingVolley {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for OrbittingVolley {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_coordinate_map = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        self.launcher_gradient_coordinate_map = final_gradient
            .build_coordinate_color_mapping(
                ctx.terminal.canvas.bottom,
                ctx.terminal.canvas.top,
                ctx.terminal.canvas.left,
                ctx.terminal.canvas.right,
                self.config.final_gradient_direction,
            )
            .map_err(EngineError::Other)?;
        self.final_gradient_last_color = Some(final_gradient.spectrum.last().unwrap().clone());

        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
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
                ColorPair::new(Some(final_gradient_coordinate_map.get(&input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors.clone());
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let input_path = ch
                    .motion
                    .new_path(
                        self.config.character_movement_speed,
                        Some(self.config.character_easing),
                        Some(1),
                        0,
                        false,
                        "input_path",
                    )
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&input_path)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
            }
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("input_path".to_string()),
                EventAction::SetLayer(0),
            )
            .map_err(EngineError::Other)?;
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation.set_appearance(&input_symbol, uses_pre, Some(&input_symbol.clone()), Some(final_colors));
        }

        let launcher_specs = [
            (
                Coord::new(ctx.terminal.canvas.left, ctx.terminal.canvas.top),
                self.config.top_launcher_symbol.clone(),
            ),
            (
                Coord::new(ctx.terminal.canvas.right, ctx.terminal.canvas.top),
                self.config.right_launcher_symbol.clone(),
            ),
            (
                Coord::new(ctx.terminal.canvas.right, ctx.terminal.canvas.bottom),
                self.config.bottom_launcher_symbol.clone(),
            ),
            (
                Coord::new(ctx.terminal.canvas.left, ctx.terminal.canvas.bottom),
                self.config.left_launcher_symbol.clone(),
            ),
        ];
        for (coord, symbol) in launcher_specs {
            let character = ctx.terminal.add_character(&symbol, coord);
            ctx.terminal.arena[character.0 as usize].layer = 2;
            ctx.terminal.set_character_visibility(character, true);
            ctx.active_characters.insert(character);
            self.launchers.push(Launcher { character, magazine: Vec::new() });
        }
        let main_character = self.launchers[0].character;
        {
            let color = self.final_gradient_last_color.clone();
            let ch = &mut ctx.terminal.arena[main_character.0 as usize];
            let input_symbol = ch.input_symbol.clone();
            let uses_pre = ch.uses_input_preexisting_colors;
            ch.animation.set_appearance(
                &input_symbol,
                uses_pre,
                Some(&input_symbol.clone()),
                Some(ColorPair::new(color, None)),
            );
        }
        self.build_launcher_paths(ctx, main_character)?;
        ctx.activate_path(self, main_character, "perimeter");

        let mut sorted_chars: Vec<CharId> = Vec::new();
        for char_list in
            ctx.terminal.get_characters_grouped(CharacterFilter::default(), CharacterGroup::CenterToOutside)
        {
            sorted_chars.extend(char_list);
        }
        for (index, character) in sorted_chars.into_iter().enumerate() {
            let launcher_index = index % self.launchers.len();
            self.launchers[launcher_index].magazine.push(character);
        }
        self.delay = 0;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.launchers.iter().any(|l| !l.magazine.is_empty()) || ctx.active_characters.len() > 1 {
            let main_character = self.launchers[0].character;
            if ctx.terminal.arena[main_character.0 as usize].motion.active_path.is_none() {
                let first_waypoint_coord = ctx.terminal.arena[main_character.0 as usize]
                    .motion
                    .paths
                    .get("perimeter")
                    .expect("perimeter path missing")
                    .waypoints[0]
                    .coord;
                ctx.terminal.arena[main_character.0 as usize].motion.set_coordinate(first_waypoint_coord);
                ctx.activate_path(self, main_character, "perimeter");
                ctx.active_characters.insert(main_character);
            }
            {
                let current_coord = ctx.terminal.arena[main_character.0 as usize].motion.current_coord;
                let color = self
                    .launcher_gradient_coordinate_map
                    .get(&current_coord)
                    .expect("main launcher coord outside gradient map")
                    .clone();
                let symbol = self.config.top_launcher_symbol.clone();
                let ch = &mut ctx.terminal.arena[main_character.0 as usize];
                let input_symbol = ch.input_symbol.clone();
                let uses_pre = ch.uses_input_preexisting_colors;
                ch.animation.set_appearance(
                    &input_symbol,
                    uses_pre,
                    Some(&symbol),
                    Some(ColorPair::new(Some(color), None)),
                );
            }
            for child_index in 1..self.launchers.len() {
                self.set_launcher_coordinates(ctx, 0, child_index);
            }
            if self.delay == 0 {
                for launcher_index in 0..self.launchers.len() {
                    // max(int((volley_size * len(input_characters)) / 4), 1) — int() truncation
                    let characters_to_launch = std::cmp::max(
                        ((self.config.volley_size * ctx.terminal.input_characters.len() as f64) / 4.0) as i64,
                        1,
                    );
                    for _ in 0..characters_to_launch {
                        if let Some(next_char) = self.launch(ctx, launcher_index) {
                            ctx.active_characters.insert(next_char);
                        }
                    }
                }
                self.delay = self.config.launch_delay;
            } else {
                self.delay -= 1;
            }

            ctx.update(self);
            return Some(ctx.frame());
        }
        if !self.complete {
            self.complete = true;
            for launcher_index in 0..self.launchers.len() {
                let character = self.launchers[launcher_index].character;
                ctx.terminal.set_character_visibility(character, false);
            }
            return Some(ctx.frame());
        }
        None
    }
}
