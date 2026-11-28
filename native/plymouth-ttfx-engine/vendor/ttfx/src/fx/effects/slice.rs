//! slice on the fx engine (old engine: effects/slice.rs).
//!
//! Every character takes its final appearance, starts off to one side of the
//! canvas and slides to its input coordinate on one eased path. The halves
//! (left/right of the center column, below/above the center row, or the two
//! halves of the diagonals) come in from opposite sides. No RNG draws; the
//! send order only matters for the auto path names.

use crate::effects::slice::SliceConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::{Engine, Hooks, Name};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{ColorPair, Gradient};

pub struct Slice {
    config: SliceConfig,
}

impl Slice {
    pub fn new(config: SliceConfig) -> Self {
        Slice { config }
    }
}

impl Hooks for Slice {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// The send_to! macro: set the origin, a path to the input coordinate,
/// activate it; then the active insert and the closing visibility.
fn send(
    e: &mut Engine,
    hooks: &mut Slice,
    slot: u32,
    origin: Coord,
    speed: f64,
    ease: Easing,
) -> Result<(), EngineError> {
    let input = e.input_coord(slot);
    e.set_coordinate(slot, origin);
    let path = e
        .path_new(slot, speed, Some(ease), None, 0, false, Name::NONE)
        .map_err(other)?;
    e.path_new_waypoint(path, input, None, Name::NONE)
        .map_err(other)?;
    e.activate_path(hooks, slot, path);
    e.active_insert(slot);
    e.set_visible(slot, true);
    Ok(())
}

impl Effect for Slice {
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
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        for slot in e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        ) {
            let colors = if dynamic {
                ColorPair::new(e.input_fg(slot), e.input_bg(slot))
            } else {
                ColorPair::new(
                    Some(
                        *final_gradient_mapping
                            .get(&e.input_coord(slot))
                            .expect("gradient mapping fg"),
                    ),
                    None,
                )
            };
            e.set_appearance(slot, None, Some(colors));
        }

        let ease = config.movement_easing;
        let mut speed = config.movement_speed;
        match config.slice_direction.as_str() {
            "vertical" => {
                // row i's left half from the top, the opposite row's right
                // half from the bottom
                let rows = e.get_characters_grouped(
                    CharacterFilter::default(),
                    CharacterGroup::RowBottomToTop,
                );
                for (i, row) in rows.iter().enumerate() {
                    for &slot in row {
                        let column = e.input_coord(slot).column;
                        if column <= canvas.text_center_column {
                            send(
                                e,
                                self,
                                slot,
                                Coord::new(column, canvas.top + 1),
                                speed,
                                ease,
                            )?;
                        }
                    }
                    for &slot in &rows[rows.len() - (i + 1)] {
                        let column = e.input_coord(slot).column;
                        if column > canvas.text_center_column {
                            send(
                                e,
                                self,
                                slot,
                                Coord::new(column, canvas.bottom - 1),
                                speed,
                                ease,
                            )?;
                        }
                    }
                }
            }
            "horizontal" => {
                speed *= 2.0;
                let filter = CharacterFilter {
                    input_chars: true,
                    inner_fill_chars: true,
                    outer_fill_chars: true,
                    added_chars: false,
                };
                let mut columns =
                    e.get_characters_grouped(filter, CharacterGroup::ColumnRightToLeft);
                // trim each column to the text rectangle; drop empty columns
                for column in &mut columns {
                    column.retain(|&slot| {
                        let c = e.input_coord(slot);
                        (canvas.text_left..=canvas.text_right).contains(&c.column)
                            && (canvas.text_bottom..=canvas.text_top).contains(&c.row)
                    });
                }
                columns.retain(|column| !column.is_empty());
                // column i's bottom half from the left, the opposite column's
                // top half from the right
                for (i, column) in columns.iter().enumerate() {
                    for &slot in column {
                        let row = e.input_coord(slot).row;
                        if row <= canvas.text_center_row {
                            send(e, self, slot, Coord::new(canvas.left - 1, row), speed, ease)?;
                        }
                    }
                    for &slot in &columns[columns.len() - (i + 1)] {
                        let row = e.input_coord(slot).row;
                        if row > canvas.text_center_row {
                            send(
                                e,
                                self,
                                slot,
                                Coord::new(canvas.right + 1, row),
                                speed,
                                ease,
                            )?;
                        }
                    }
                }
            }
            "diagonal" => {
                // the first half of the diagonals from the bottom (origin
                // column of the group's first character), the second half
                // from the top (its last), interleaved
                let diagonals = e.get_characters_grouped(
                    CharacterFilter::default(),
                    CharacterGroup::DiagonalBottomLeftToTopRight,
                );
                let (left, right) = diagonals.split_at(diagonals.len() / 2);
                for (i, right_group) in right.iter().enumerate() {
                    if let Some(group) = left.get(i) {
                        let origin = Coord::new(e.input_coord(group[0]).column, canvas.bottom - 1);
                        for &slot in group {
                            send(e, self, slot, origin, speed, ease)?;
                        }
                    }
                    let last = right_group[right_group.len() - 1];
                    let origin = Coord::new(e.input_coord(last).column, canvas.top + 1);
                    for &slot in right_group {
                        send(e, self, slot, origin, speed, ease)?;
                    }
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() {
            return false;
        }
        e.update(self);
        true
    }
}
