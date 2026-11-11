//! orbittingvolley on the fx engine (old engine: effects/orbittingvolley.rs).
//!
//! The main (top) launcher rides the "perimeter" path along the top row; the
//! other three are placed from its progress each frame. Launcher.magazine is
//! a cursor into the flattened center-to-outside order: launcher i owns
//! positions i, i + 4, i + 8, ... and remove(0) advances its cursor by 4.
//! Every character's "input_path" is its only path. No RNG draws.

use crate::effects::orbittingvolley::OrbittingVolleyConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::{At, Engine, Hooks, Name, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{ColorPair, CoordColorMap, Gradient};

const LAUNCHERS: usize = 4;

pub struct OrbittingVolley {
    config: OrbittingVolleyConfig,
    launcher_map: Option<CoordColorMap>,
    launchers: [u32; LAUNCHERS],
    perimeter: u32,
    /// The magazines, flattened: (slot, its input_path).
    sorted: Vec<(u32, u32)>,
    cursor: [usize; LAUNCHERS],
    volley: usize,
    delay: i64,
    complete: bool,
}

impl OrbittingVolley {
    pub fn new(config: OrbittingVolleyConfig) -> Self {
        OrbittingVolley {
            config,
            launcher_map: None,
            launchers: [NONE; LAUNCHERS],
            perimeter: NONE,
            sorted: Vec::new(),
            cursor: [0; LAUNCHERS],
            volley: 1,
            delay: 0,
            complete: false,
        }
    }

    /// launcher_gradient_coordinate_map at the launcher's coordinate, as its
    /// appearance.
    fn color_launcher(&self, e: &mut Engine, slot: u32) {
        let map = self.launcher_map.as_ref().expect("built");
        let color = *map
            .get(&e.coord(slot))
            .expect("launcher coord outside gradient map");
        e.set_appearance(slot, None, Some(ColorPair::new(Some(color), None)));
    }

    /// OrbittingVolleyIterator._set_launcher_coordinates(parent 0, child).
    fn set_child(&self, e: &mut Engine, child: u32) {
        let (top, bottom, left, right) =
            (e.canvas.top, e.canvas.bottom, e.canvas.left, e.canvas.right);
        let progress = e.coord(self.launchers[0]).column as f64 / right as f64;
        let input = e.input_coord(child);
        if input == Coord::new(right, top) {
            let row = top - (top as f64 * progress) as i64;
            e.set_coordinate(child, Coord::new(right, row.max(1)));
        } else if input == Coord::new(right, bottom) {
            let column = right - (right as f64 * progress) as i64;
            e.set_coordinate(child, Coord::new(column.max(1), bottom));
        } else if input == Coord::new(left, bottom) {
            let row = bottom + (top as f64 * progress) as i64;
            e.set_coordinate(child, Coord::new(left, row.min(top)));
        }
        self.color_launcher(e, child);
    }
}

impl Hooks for OrbittingVolley {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for OrbittingVolley {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let canvas = e.canvas.clone();
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let final_map = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        self.launcher_map = Some(
            final_gradient
                .build_coordinate_color_mapping(
                    canvas.bottom,
                    canvas.top,
                    canvas.left,
                    canvas.right,
                    config.final_gradient_direction,
                )
                .map_err(other)?,
        );
        let last_color = *final_gradient.spectrum.last().expect("non-empty spectrum");

        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let input_path = e.name("input_path");
        let mut path_of = vec![NONE; e.char_count()];
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            let input = e.input_coord(slot);
            let final_colors = if dynamic {
                ColorPair::new(e.input_fg(slot), e.input_bg(slot))
            } else {
                ColorPair::new(
                    Some(*final_map.get(&input).expect("gradient mapping fg")),
                    None,
                )
            };
            let path = e
                .path_new(
                    slot,
                    config.character_movement_speed,
                    Some(config.character_easing),
                    Some(1),
                    0,
                    false,
                    input_path,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, input, None, Name::NONE)
                .map_err(other)?;
            path_of[slot as usize] = path;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(input_path),
                Action::SetLayer(0),
            )
            .map_err(other)?;
            e.set_appearance(slot, None, Some(final_colors));
        }

        let specs = [
            (
                Coord::new(canvas.left, canvas.top),
                &config.top_launcher_symbol,
            ),
            (
                Coord::new(canvas.right, canvas.top),
                &config.right_launcher_symbol,
            ),
            (
                Coord::new(canvas.right, canvas.bottom),
                &config.bottom_launcher_symbol,
            ),
            (
                Coord::new(canvas.left, canvas.bottom),
                &config.left_launcher_symbol,
            ),
        ];
        for (i, (coord, symbol)) in specs.into_iter().enumerate() {
            let slot = e.add_character(symbol, coord);
            e.set_layer(slot, 2);
            e.set_visible(slot, true);
            e.active_insert(slot);
            self.launchers[i] = slot;
        }
        let main = self.launchers[0];
        e.set_appearance(main, None, Some(ColorPair::new(Some(last_color), None)));
        // Launcher.build_paths: the main launcher starts at waypoints[0], so
        // the rotation is the identity
        let perimeter_name = e.name("perimeter");
        let perimeter = e
            .path_new(
                main,
                config.launcher_movement_speed,
                None,
                Some(2),
                0,
                false,
                perimeter_name,
            )
            .map_err(other)?;
        for waypoint in [
            Coord::new(canvas.left, canvas.top),
            Coord::new(canvas.right, canvas.top),
        ] {
            e.path_new_waypoint(perimeter, waypoint, None, Name::NONE)
                .map_err(other)?;
        }
        self.perimeter = perimeter;
        e.activate_path(self, main, perimeter);

        self.sorted = e
            .get_characters_grouped(CharacterFilter::default(), CharacterGroup::CenterToOutside)
            .into_iter()
            .flatten()
            .map(|slot| (slot, path_of[slot as usize]))
            .collect();
        self.cursor = [0, 1, 2, 3];
        // max(int((volley_size * len(input_characters)) / 4), 1)
        self.volley =
            ((config.volley_size * e.input_chars.len() as f64 / 4.0) as i64).max(1) as usize;
        self.delay = 0;
        self.complete = false;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        let count = self.sorted.len();
        if self.cursor.iter().any(|&c| c < count) || e.active_count() > 1 {
            let main = self.launchers[0];
            if *e.ch.path.at(main) == NONE {
                // the perimeter run ended: back to its first waypoint and go again
                e.set_coordinate(main, Coord::new(e.canvas.left, e.canvas.top));
                let perimeter = self.perimeter;
                e.activate_path(self, main, perimeter);
                e.active_insert(main);
            }
            self.color_launcher(e, main);
            for i in 1..LAUNCHERS {
                self.set_child(e, self.launchers[i]);
            }
            if self.delay == 0 {
                for i in 0..LAUNCHERS {
                    let coord = e.coord(self.launchers[i]);
                    for _ in 0..self.volley {
                        let c = self.cursor[i];
                        if c >= count {
                            break;
                        }
                        self.cursor[i] = c + LAUNCHERS;
                        let (slot, path) = *self.sorted.at(c);
                        e.set_coordinate(slot, coord);
                        e.activate_path(self, slot, path);
                        e.set_visible(slot, true);
                        e.active_insert(slot);
                    }
                }
                self.delay = self.config.launch_delay;
            } else {
                self.delay -= 1;
            }
            e.update(self);
            return true;
        }
        if !self.complete {
            self.complete = true;
            for &slot in &self.launchers {
                e.set_visible(slot, false);
            }
            return true;
        }
        false
    }
}
