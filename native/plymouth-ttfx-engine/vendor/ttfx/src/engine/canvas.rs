//! Canvas, ported from engine/terminal.py Canvas.

use crate::engine::character::CharId;
use crate::engine::input::InputChar;
use crate::utils::geometry::Coord;
use crate::utils::pycompat::floor_div;
use crate::utils::rng::Rng;

/// Text anchor / canvas anchor directions (the 9 compass points).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Anchor {
    N,
    Ne,
    E,
    Se,
    S,
    Sw,
    W,
    Nw,
    C,
}

impl Anchor {
    pub fn parse(s: &str) -> Option<Self> {
        Some(match s {
            "n" => Anchor::N,
            "ne" => Anchor::Ne,
            "e" => Anchor::E,
            "se" => Anchor::Se,
            "s" => Anchor::S,
            "sw" => Anchor::Sw,
            "w" => Anchor::W,
            "nw" => Anchor::Nw,
            "c" => Anchor::C,
            _ => return None,
        })
    }
}

#[derive(Debug, Clone)]
pub struct Canvas {
    pub top: i64,
    pub right: i64,
    pub bottom: i64,
    pub left: i64,
    pub center_row: i64,
    pub center_column: i64,
    pub center: Coord,
    pub width: i64,
    pub height: i64,
    pub text_left: i64,
    pub text_right: i64,
    pub text_top: i64,
    pub text_bottom: i64,
    pub text_width: i64,
    pub text_height: i64,
    pub text_center_row: i64,
    pub text_center_column: i64,
    pub text_center: Coord,
}

impl Canvas {
    /// Canvas.__post_init__ with bottom=1, left=1 defaults.
    pub fn new(top: i64, right: i64) -> Self {
        let bottom = 1;
        let left = 1;
        let mut center_row = std::cmp::max(floor_div(top, 2), bottom);
        if top % 2 != 0 && top > 1 {
            center_row += 1;
        }
        let mut center_column = std::cmp::max(floor_div(right, 2), left);
        if right % 2 != 0 && right > 1 {
            center_column += 1;
        }
        Canvas {
            top,
            right,
            bottom,
            left,
            center_row,
            center_column,
            center: Coord::new(center_column, center_row),
            width: right,
            height: top,
            text_left: 0,
            text_right: 0,
            text_top: 0,
            text_bottom: 0,
            text_width: 0,
            text_height: 0,
            text_center_row: 0,
            text_center_column: 0,
            text_center: Coord::new(0, 0),
        }
    }

    /// Canvas._anchor_text: shift characters per the anchor, drop out-of-canvas
    /// ones, then compute text extents. `characters` must be non-empty after the
    /// in-canvas filter or this errors (upstream crashes on bare max()/min()).
    pub fn anchor_text(
        &mut self,
        arena: &mut [InputChar],
        characters: Vec<CharId>,
        anchor: Anchor,
    ) -> Result<Vec<CharId>, String> {
        use Anchor::*;
        let input_width = characters
            .iter()
            .map(|&id| arena[id.0 as usize].input_coord.column)
            .max()
            .ok_or("no input characters to anchor")?;
        let input_height = characters
            .iter()
            .map(|&id| arena[id.0 as usize].input_coord.row)
            .max()
            .unwrap();

        let mut column_delta = 0;
        let mut row_delta = 0;
        if input_width != self.width {
            match anchor {
                S | N | C => column_delta = self.center_column - floor_div(input_width, 2),
                Se | E | Ne => column_delta = self.right - input_width,
                Sw | W | Nw => column_delta = self.left - 1,
            }
        }
        if input_height != self.height {
            match anchor {
                W | E | C => row_delta = self.center_row - floor_div(input_height, 2),
                Nw | N | Ne => row_delta = self.top - input_height,
                Sw | S | Se => row_delta = self.bottom - 1,
            }
        }

        for &id in &characters {
            let ch = &mut arena[id.0 as usize];
            ch.input_coord = Coord::new(
                ch.input_coord.column + column_delta,
                ch.input_coord.row + row_delta,
            );
            ch.coord = ch.input_coord;
        }

        let kept: Vec<CharId> = characters
            .into_iter()
            .filter(|&id| self.coord_is_in_canvas(arena[id.0 as usize].input_coord))
            .collect();

        if kept.is_empty() {
            // Upstream raises ValueError from max() on an empty sequence here.
            return Err("all input characters fall outside the canvas after anchoring".to_string());
        }

        self.text_left = kept
            .iter()
            .map(|&id| arena[id.0 as usize].input_coord.column)
            .min()
            .unwrap();
        self.text_right = kept
            .iter()
            .map(|&id| arena[id.0 as usize].input_coord.column)
            .max()
            .unwrap();
        self.text_top = kept
            .iter()
            .map(|&id| arena[id.0 as usize].input_coord.row)
            .max()
            .unwrap();
        self.text_bottom = kept
            .iter()
            .map(|&id| arena[id.0 as usize].input_coord.row)
            .min()
            .unwrap();
        self.text_width = std::cmp::max(self.text_right - self.text_left + 1, 1);
        self.text_height = std::cmp::max(self.text_top - self.text_bottom + 1, 1);
        self.text_center_row = self.text_bottom + floor_div(self.text_top - self.text_bottom, 2);
        self.text_center_column = self.text_left + floor_div(self.text_right - self.text_left, 2);
        self.text_center = Coord::new(self.text_center_column, self.text_center_row);
        Ok(kept)
    }

    pub fn coord_is_in_canvas(&self, coord: Coord) -> bool {
        self.left <= coord.column
            && coord.column <= self.right
            && self.bottom <= coord.row
            && coord.row <= self.top
    }

    pub fn coord_is_in_text(&self, coord: Coord) -> bool {
        self.text_left <= coord.column
            && coord.column <= self.text_right
            && self.text_bottom <= coord.row
            && coord.row <= self.text_top
    }

    pub fn random_column(&self, rng: &mut Rng, within_text_boundary: bool) -> i64 {
        if within_text_boundary {
            rng.randint(self.text_left, self.text_right)
        } else {
            rng.randint(self.left, self.right)
        }
    }

    pub fn random_row(&self, rng: &mut Rng, within_text_boundary: bool) -> i64 {
        if within_text_boundary {
            rng.randint(self.text_bottom, self.text_top)
        } else {
            rng.randint(self.bottom, self.top)
        }
    }

    /// random_coord: outside_scope picks among four coords exactly one cell past
    /// an edge — note the RNG call ORDER (above, below, left, right built first,
    /// then choice) is part of the parity contract.
    pub fn random_coord(
        &self,
        rng: &mut Rng,
        outside_scope: bool,
        within_text_boundary: bool,
    ) -> Coord {
        if outside_scope {
            let above = Coord::new(self.random_column(rng, false), self.top + 1);
            let below = Coord::new(self.random_column(rng, false), self.bottom - 1);
            let left = Coord::new(self.left - 1, self.random_row(rng, false));
            let right = Coord::new(self.right + 1, self.random_row(rng, false));
            return *rng.choice(&[above, below, left, right]);
        }
        Coord::new(
            self.random_column(rng, within_text_boundary),
            self.random_row(rng, within_text_boundary),
        )
    }
}
