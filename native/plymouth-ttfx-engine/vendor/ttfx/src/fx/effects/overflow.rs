//! overflow on the fx engine (old engine: effects/overflow.rs).
//!
//! Rows scroll up from the bottom of the canvas: randint(lower, upper) cycles
//! of shuffled copies of the input rows colored by the overflow gradient, then
//! the real rows (input and fill characters) in their final appearance.
//!
//! Every row (OverflowIterator.Row) is a record in one array in pending order,
//! so pending_rows is an index into it; its slots are a span of one flat slot
//! list. Active rows are row indices, retained in order like Vec::retain. A
//! row remembers the spectrum index it shows, and the copies' visuals are
//! memoized by (spectrum index, symbol).

use crate::effects::overflow::OverflowConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup};
use crate::fx::visual::HAS_COLORS;
use crate::fx::{At, Engine, Hooks, Visual, VisualInfo, CF_PREEXISTING, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::floor_div;

/// OverflowIterator.Row.
#[derive(Clone, Copy)]
struct Row {
    /// Span of `Overflow::slots`.
    start: u32,
    len: u32,
    final_: bool,
    /// The spectrum index last applied by set_color, or NONE.
    last: u32,
}

pub struct Overflow {
    config: OverflowConfig,
    rows: Vec<Row>,
    slots: Vec<u32>,
    /// First pending row.
    next: usize,
    active: Vec<u32>,
    delay: i64,
    spectrum: Vec<Color>,
    /// Visual per (spectrum index, symbol), NONE = unmade; empty when the
    /// input colors win (existing color handling "always").
    cache: Vec<Visual>,
    nsym: usize,
}

impl Overflow {
    pub fn new(config: OverflowConfig) -> Self {
        Overflow {
            config,
            rows: Vec::new(),
            slots: Vec::new(),
            next: 0,
            active: Vec::new(),
            delay: 0,
            spectrum: Vec::new(),
            cache: Vec::new(),
            nsym: 0,
        }
    }

    fn push_row(&mut self, start: usize, final_: bool) {
        let len = (self.slots.len() - start) as u32;
        self.rows.push(Row {
            start: start as u32,
            len,
            final_,
            last: NONE,
        });
    }

    /// Row.move_up.
    #[inline]
    fn move_up(&self, e: &mut Engine, row: Row) {
        for &slot in &self.slots[row.start as usize..(row.start + row.len) as usize] {
            e.ch.coord.at_mut(slot).row += 1;
            e.coordinate_changed(slot);
        }
    }

    /// Row.set_color(spectrum[index], None). The visual depends only on the
    /// symbol and the color, so a row already showing that index is unchanged.
    #[inline]
    fn set_color(&mut self, e: &mut Engine, r: usize, index: u32) {
        let row = self.rows.at_mut(r);
        if row.last == index {
            return;
        }
        row.last = index;
        let row = *row;
        let slots = &self.slots[row.start as usize..(row.start + row.len) as usize];
        let color = *self.spectrum.at(index);
        if self.cache.is_empty() {
            for &slot in slots {
                e.set_appearance(slot, None, Some(ColorPair::new(Some(color), None)));
            }
            return;
        }
        // (no doze_wake: a copy never joins the active set, so never dozes)
        let base = index as usize * self.nsym;
        let row_cache = &mut self.cache[base..base + self.nsym];
        for &slot in slots {
            let sym = *e.ch.sym.at(slot);
            let cached = row_cache.at_mut(sym.0);
            if cached.0 == NONE {
                *cached = e.visuals.make(
                    &e.symbols,
                    VisualInfo {
                        sym,
                        fg: Some(color),
                        bg: None,
                        attrs: HAS_COLORS,
                    },
                );
            }
        }
        let row_cache = &*row_cache;
        e.set_visuals(slots, |sym| *row_cache.at(sym.0));
    }
}

impl Hooks for Overflow {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl crate::fx::run::Effect for Overflow {
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
        let fills_filter = CharacterFilter {
            inner_fill_chars: true,
            outer_fill_chars: true,
            ..Default::default()
        };
        let (lower_range, upper_range) = config.overflow_cycles_range;
        let mut groups =
            e.get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowTopToBottom);
        let cycles = if upper_range > 0 {
            e.rng.randint(lower_range, upper_range)
        } else {
            0
        };
        let total: usize = groups.iter().map(Vec::len).sum();
        self.slots.reserve(total * cycles.max(0) as usize);
        for _ in 0..cycles {
            e.rng.shuffle(&mut groups);
            for group in &groups {
                // copies of the characters, keeping their input colors (not the bold)
                let start = self.slots.len();
                for &source in group {
                    let copy = e.add_character_sym(e.input_sym(source), e.input_coord(source));
                    *e.ch.flags.at_mut(copy) |= CF_PREEXISTING;
                    *e.ch.fg.at_mut(copy) = *e.ch.fg.at(source);
                    *e.ch.bg.at_mut(copy) = *e.ch.bg.at(source);
                    self.slots.push(copy);
                }
                self.push_row(start, false);
            }
        }
        // the real rows, top to bottom, in their final appearance
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let black = Color::from_hex("000000").unwrap();
        for group in e.get_characters_grouped(fills_filter, CharacterGroup::RowTopToBottom) {
            let start = self.slots.len();
            for &slot in &group {
                let current = e.visual_info(e.current_visual(slot)).sym;
                let colors = if dynamic {
                    ColorPair::new(e.input_fg(slot), e.input_bg(slot))
                } else {
                    let color = final_gradient_mapping
                        .get(&e.input_coord(slot))
                        .copied()
                        .unwrap_or(black);
                    ColorPair::new(Some(color), None)
                };
                e.set_appearance(slot, Some(current), Some(colors));
            }
            self.slots.extend_from_slice(&group);
            self.push_row(start, true);
        }
        self.delay = 0;
        let steps = floor_div(
            canvas.top,
            (config.overflow_gradient_stops.len() as i64 - 1).max(1),
        )
        .max(1);
        self.spectrum = Gradient::with_steps(&config.overflow_gradient_stops, steps, false)
            .map_err(other)?
            .spectrum;
        if e.existing_color_handling() != ExistingColorHandling::Always && cycles > 0 {
            self.nsym = groups
                .iter()
                .flatten()
                .map(|&s| e.input_sym(s).0 as usize + 1)
                .max()
                .unwrap_or(0);
            self.cache = vec![Visual(NONE); self.spectrum.len() * self.nsym];
        }
        self.active.reserve(self.rows.len());
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.next >= self.rows.len() {
            return false;
        }
        if self.delay == 0 {
            let last_index = self.spectrum.len() as i64 - 1;
            for _ in 0..e.rng.randint(1, self.config.overflow_speed) {
                if self.next >= self.rows.len() {
                    continue;
                }
                // move every active row up, recoloring the overflow rows by height
                for i in 0..self.active.len() {
                    let r = *self.active.at(i) as usize;
                    let row = *self.rows.at(r);
                    self.move_up(e, row);
                    if !row.final_ {
                        let head_row = e.ch.coord.at(*self.slots.at(row.start)).row;
                        self.set_color(e, r, head_row.min(last_index) as u32);
                    }
                }
                // pending_rows.pop_front(): setup, move_up, color, reveal
                let r = self.next;
                self.next += 1;
                let row = *self.rows.at(r);
                for &slot in &self.slots[row.start as usize..(row.start + row.len) as usize] {
                    let column = e.input_coord(slot).column;
                    e.set_coordinate(slot, Coord::new(column, 1));
                }
                if !row.final_ {
                    self.set_color(e, r, 0);
                }
                for &slot in &self.slots[row.start as usize..(row.start + row.len) as usize] {
                    e.set_visible(slot, true);
                }
                self.active.push(r as u32);
            }
            self.delay = e.rng.randint(0, 3);
        } else {
            self.delay -= 1;
        }
        let canvas_top = e.canvas.top;
        let (rows, slots) = (&self.rows, &self.slots);
        self.active
            .retain(|&r| e.ch.coord.at(*slots.at(rows.at(r).start)).row <= canvas_top);
        e.update(self);
        true
    }
}
