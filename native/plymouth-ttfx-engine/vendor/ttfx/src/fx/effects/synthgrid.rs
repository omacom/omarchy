//! synthgrid on the fx engine (old engine: effects/synthgrid.rs).
//!
//! A grid line is a run of consecutive added slots, so it is (first slot,
//! count) plus the length of its extended prefix: extension reveals from the
//! front, and the old collapse reverses the fully extended list once and
//! hides from its front, which is hiding from the back of the line. Groups
//! (blocks) keep their members in one flat array in group-number order;
//! `pending` is the shuffled group numbers, consumed from the front. Dissolve
//! visuals are memoized by (generation symbol, spectrum color).

use crate::effects::synthgrid::SynthGridConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, Hooks, Name, Sym, Visual, CF_INPUT, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{ColorPair, CoordColorMap, Gradient};
use crate::utils::pycompat::floor_div;

/// Callback id: update_group_tracker(group_number).
const UPDATE_GROUP_TRACKER: u32 = 0;
/// A dissolve scene: at most 30 random frames and the final one.
const MAX_DISSOLVE: usize = 31;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    GridExpand,
    AddChars,
    Collapse,
    Complete,
}

#[derive(Clone, Copy)]
struct Line {
    first: u32,
    count: u32,
    /// The extended prefix [first, first + ext).
    ext: u32,
    /// Characters per extend / collapse: 3 horizontal, 1 vertical.
    step: u32,
}

pub struct SynthGrid {
    config: SynthGridConfig,
    lines: Vec<Line>,
    /// Group members, flat, and each group's (start, count) in them.
    members: Vec<u32>,
    groups: Vec<(u32, u32)>,
    tracker: Vec<i64>,
    pending: Vec<u32>,
    pending_next: usize,
    phase: Phase,
    active_groups: i64,
}

impl SynthGrid {
    pub fn new(config: SynthGridConfig) -> Self {
        SynthGrid {
            config,
            lines: Vec::new(),
            members: Vec::new(),
            groups: Vec::new(),
            tracker: Vec::new(),
            pending: Vec::new(),
            pending_next: 0,
            phase: Phase::GridExpand,
            active_groups: 0,
        }
    }

    /// SynthGridIterator.find_even_gap: the gap closest to
    /// (dimension - 2) // 5 among dimension-2 down to 5 that divide it with a
    /// remainder of at most 1, the first (largest) on ties.
    fn find_even_gap(dimension: i64) -> i64 {
        let dimension = dimension - 2;
        if dimension <= 0 {
            return 0;
        }
        let target = floor_div(dimension, 5);
        let mut best = None;
        let mut best_key = 0;
        let mut i = dimension;
        while i > 4 {
            if dimension % i <= 1 {
                let key = (i - target).abs();
                if best.is_none() || key < best_key {
                    best = Some(i);
                    best_key = key;
                }
            }
            i -= 1;
        }
        best.unwrap_or(4)
    }

    /// GridLine.__init__: each character added at (0, 0) with one frame of
    /// the grid color at its coordinate, activated, layer 2, then moved.
    fn make_grid_line(
        &mut self,
        e: &mut Engine,
        fixed: i64,
        vertical: bool,
        sym: Sym,
        map: &CoordColorMap,
    ) {
        let canvas = &e.canvas;
        let coords: Vec<Coord> = if vertical {
            (canvas.bottom..canvas.top)
                .map(|row| Coord::new(fixed, row))
                .collect()
        } else {
            (canvas.left..=canvas.right)
                .map(|column| Coord::new(column, fixed))
                .collect()
        };
        let mut line = Line {
            first: e.char_count() as u32,
            count: 0,
            ext: 0,
            step: if vertical { 1 } else { 3 },
        };
        for coord in coords {
            let slot = e.add_character_sym(sym, Coord::new(0, 0));
            let scene = e.scene_new(slot, Name::NONE, false, None, None);
            let fg = *map
                .get(&coord)
                .expect("grid gradient mapping missing coord");
            e.add_frame(scene, sym, 1, Some(ColorPair::new(Some(fg), None)), 0)
                .expect("duration 1");
            e.activate_scene(self, slot, scene);
            e.set_layer(slot, 2);
            e.set_coordinate(slot, coord);
            line.count += 1;
        }
        self.lines.push(line);
    }
}

impl Hooks for SynthGrid {
    fn callback(&mut self, _e: &mut Engine, _slot: u32, id: u32, arg: i64) {
        if id == UPDATE_GROUP_TRACKER {
            *self.tracker.at_mut(arg as usize) -= 1;
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for SynthGrid {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let canvas = e.canvas.clone();
        let grid_gradient = Gradient::new(
            &config.grid_gradient_stops,
            &config.grid_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let grid_map = grid_gradient
            .build_coordinate_color_mapping(
                1,
                canvas.top,
                1,
                canvas.right,
                config.grid_gradient_direction,
            )
            .map_err(other)?;
        let text_gradient = Gradient::new(
            &config.text_gradient_stops,
            &config.text_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let text_map = text_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.text_gradient_direction,
            )
            .map_err(other)?;
        let spectrum = &text_gradient.spectrum;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;

        let row_sym = e.sym(&config.grid_row_symbol);
        let column_sym = e.sym(&config.grid_column_symbol);
        self.make_grid_line(e, canvas.bottom, false, row_sym, &grid_map);
        self.make_grid_line(e, canvas.top, false, row_sym, &grid_map);
        self.make_grid_line(e, canvas.left, true, column_sym, &grid_map);
        self.make_grid_line(e, canvas.right, true, column_sym, &grid_map);

        let (row_gap, column_gap) = if canvas.top > 2 * canvas.right {
            let row_gap = Self::find_even_gap(canvas.top) + 1;
            (row_gap, row_gap * 2)
        } else {
            let column_gap = Self::find_even_gap(canvas.right) + 1;
            (floor_div(column_gap, 2), column_gap)
        };
        let mut row_indexes: Vec<i64> = Vec::new();
        let mut column_indexes: Vec<i64> = Vec::new();
        // range(bottom + row_gap, top, max(row_gap, 1))
        let mut row_index = canvas.bottom + row_gap;
        while row_index < canvas.top {
            if canvas.top - row_index >= 2 {
                row_indexes.push(row_index);
                self.make_grid_line(e, row_index, false, row_sym, &grid_map);
            }
            row_index += row_gap.max(1);
        }
        // range(left + column_gap, right, max(column_gap, 1))
        let mut column_index = canvas.left + column_gap;
        while column_index < canvas.right {
            if canvas.right - column_index >= 2 {
                column_indexes.push(column_index);
                self.make_grid_line(e, column_index, true, column_sym, &grid_map);
            }
            column_index += column_gap.max(1);
        }
        row_indexes.push(canvas.top + 1);
        column_indexes.push(canvas.right + 1);

        // the blocks between consecutive indexes, row-major inside each block;
        // a block with any character is a group
        let mut prev_row_index = 1i64;
        for &row_index_value in &row_indexes {
            // row_index is reassigned inside the column loop upstream and the
            // mutated value flows into prev_row_index
            let mut row_index = row_index_value;
            let mut prev_column_index = 1i64;
            for &column_index in &column_indexes {
                if row_index == canvas.top {
                    // make sure the top row is included
                    row_index += 1;
                }
                let start = self.members.len() as u32;
                for row in prev_row_index..row_index {
                    for column in prev_column_index..column_index {
                        if let Some(slot) = e.char_at_input_coord(Coord::new(column, row)) {
                            self.members.push(slot);
                        }
                    }
                }
                let count = self.members.len() as u32 - start;
                if count != 0 {
                    self.groups.push((start, count));
                }
                prev_column_index = column_index;
            }
            prev_row_index = row_index;
        }
        self.tracker = vec![0; self.groups.len()];

        // the dissolve scenes, group by group
        let symbols: Vec<Sym> = config
            .text_generation_symbols
            .iter()
            .map(|s| e.sym(s))
            .collect();
        let colors = spectrum.len();
        let mut memo = vec![Visual(NONE); symbols.len() * colors];
        let (members, groups) = (
            std::mem::take(&mut self.members),
            std::mem::take(&mut self.groups),
        );
        e.scenes.reserve(members.len(), members.len() * 24);
        for (group_number, &(start, count)) in groups.iter().enumerate() {
            for &slot in &members[start as usize..(start + count) as usize] {
                let scene = e.scene_new(slot, Name::NONE, false, None, None);
                let frame_count = e.rng.randint(15, 30) as usize;
                let mut frames = [Frame {
                    visual: Visual(NONE),
                    duration: 2,
                }; MAX_DISSOLVE];
                let mut visual_of = |e: &mut Engine, symbol: usize, color: usize| {
                    let entry = &mut memo[symbol * colors + color];
                    if entry.0 == NONE {
                        let info = VisualInfo {
                            sym: symbols[symbol],
                            fg: Some(spectrum[color]),
                            bg: None,
                            attrs: HAS_COLORS,
                        };
                        *entry = e.visuals.make(&e.symbols, info);
                    }
                    *entry
                };
                if symbols.len() <= 1 << 16 && colors <= 1 << 16 {
                    // the (symbol, color) choices in one batch
                    let mut draws = [0u16; 2 * (MAX_DISSOLVE - 1)];
                    e.rng.fill_below_pairs(
                        symbols.len() as u64,
                        colors as u64,
                        &mut draws[..2 * frame_count],
                    );
                    for (frame, pair) in frames[..frame_count].iter_mut().zip(draws.chunks_exact(2))
                    {
                        frame.visual = visual_of(e, pair[0] as usize, pair[1] as usize);
                    }
                } else {
                    // indexes past u16 (a huge --text-gradient-steps)
                    for frame in &mut frames[..frame_count] {
                        let symbol = e.rng.choice_index(symbols.len());
                        let color = e.rng.choice_index(colors);
                        frame.visual = visual_of(e, symbol, color);
                    }
                }
                // character_final_color_map: input characters only
                let sym = e.input_sym(slot);
                let (fg, bg) = if e.ch.flags[slot as usize] & CF_INPUT == 0 {
                    (None, None)
                } else if dynamic {
                    (e.input_fg(slot), e.input_bg(slot))
                } else if e.symbol(sym) != " " {
                    (
                        Some(
                            *text_map
                                .get(&e.input_coord(slot))
                                .expect("text gradient mapping"),
                        ),
                        None,
                    )
                } else {
                    (None, None)
                };
                let visual = e.visuals.make(
                    &e.symbols,
                    VisualInfo {
                        sym,
                        fg,
                        bg,
                        attrs: HAS_COLORS,
                    },
                );
                frames[frame_count] = Frame {
                    visual,
                    duration: 1,
                };
                e.add_frames_visual(scene, &frames[..=frame_count])
                    .map_err(other)?;
                e.activate_scene(self, slot, scene);
                let name = e.scene_name(scene);
                e.register_event(
                    slot,
                    Event::SceneComplete,
                    Caller::Scene(name),
                    Action::Callback(UPDATE_GROUP_TRACKER, group_number as i64),
                )
                .map_err(other)?;
            }
        }
        self.members = members;
        self.groups = groups;

        self.pending = (0..self.groups.len() as u32).collect();
        e.rng.shuffle(&mut self.pending);
        self.pending_next = 0;
        self.phase = Phase::GridExpand;
        if self.groups.is_empty() {
            // no groups: every input character is shown and active at once
            for slot in e.get_characters(
                CharacterFilter::default(),
                CharacterSort::TopToBottomLeftToRight,
            ) {
                e.set_visible(slot, true);
                e.active_insert(slot);
            }
        }
        self.active_groups = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        let pending = self.pending_next < self.pending.len();
        if !pending && e.active_is_empty() && self.phase == Phase::Complete {
            return false;
        }
        match self.phase {
            Phase::GridExpand => {
                let mut any = false;
                for line in &mut self.lines {
                    if line.ext < line.count {
                        any = true;
                        let end = (line.ext + line.step).min(line.count);
                        for k in line.ext..end {
                            e.set_visible(line.first + k, true);
                        }
                        line.ext = end;
                    }
                }
                if !any {
                    self.phase = Phase::AddChars;
                }
            }
            Phase::AddChars => {
                if self.pending_next < self.pending.len()
                    && (self.active_groups as f64)
                        < self.groups.len() as f64 * self.config.max_active_blocks
                {
                    let group = *self.pending.at(self.pending_next);
                    self.pending_next += 1;
                    let (start, count) = *self.groups.at(group);
                    for k in start..start + count {
                        let slot = *self.members.at(k);
                        e.set_visible(slot, true);
                        e.active_insert(slot);
                    }
                    *self.tracker.at_mut(group) += count as i64;
                }
                if self.pending_next == self.pending.len()
                    && e.active_is_empty()
                    && self.active_groups == 0
                {
                    self.phase = Phase::Collapse;
                }
            }
            Phase::Collapse => {
                let mut any = false;
                for line in &mut self.lines {
                    if line.ext != 0 {
                        any = true;
                        let end = line.ext.saturating_sub(line.step);
                        for k in (end..line.ext).rev() {
                            e.set_visible(line.first + k, false);
                        }
                        line.ext = end;
                    }
                }
                if !any {
                    self.phase = Phase::Complete;
                }
            }
            Phase::Complete => {}
        }
        e.update(self);
        self.active_groups = self.tracker.iter().map(|&n| (n != 0) as i64).sum();
        true
    }
}
