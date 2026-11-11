//! Terminal: config, canvas assembly, character queries, renderer, tty output.
//! Ported from engine/terminal.py. Unlike upstream (which builds two Terminals
//! per run), this single Terminal owns both the simulation and the tty side.

use std::collections::HashMap;

use crate::utils::hash::FxBuild;
use std::io::Write;
use std::time::Instant;

use crate::engine::animation::{CharacterVisual, ExistingColorHandling};
use crate::engine::canvas::{Anchor, Canvas};
use crate::engine::character::{CharId, EffectCharacter, Neighbors};
use crate::engine::error::EngineError;
use crate::engine::input::{ColorFrequency, InputChar, Preprocessor};
use crate::utils::ansi;
use crate::utils::geometry::Coord;
use crate::utils::graphics::Color;
use crate::utils::rng::Rng;

/// Empty cell of `Terminal::input_grid`.
pub(crate) const NONE: u32 = u32::MAX;

const EMPTY_RENDER_CELL: u32 = u32::MAX;
const NOT_VISIBLE: usize = usize::MAX;

#[derive(Debug, Clone)]
pub struct TerminalConfig {
    pub tab_width: i64,
    pub xterm_colors: bool,
    pub no_color: bool,
    pub terminal_background_color: Color,
    pub existing_color_handling: ExistingColorHandling,
    pub wrap_text: bool,
    pub frame_rate: i64,
    pub canvas_width: i64,
    pub canvas_height: i64,
    pub anchor_canvas: Anchor,
    pub anchor_text: Anchor,
    pub ignore_terminal_dimensions: bool,
    pub reuse_canvas: bool,
    pub no_eol: bool,
    pub no_restore_cursor: bool,
}

impl Default for TerminalConfig {
    fn default() -> Self {
        TerminalConfig {
            tab_width: 4,
            xterm_colors: false,
            no_color: false,
            terminal_background_color: Color::from_hex("000000").unwrap(),
            existing_color_handling: ExistingColorHandling::Ignore,
            wrap_text: false,
            frame_rate: 60,
            canvas_width: -1,
            canvas_height: -1,
            anchor_canvas: Anchor::Sw,
            anchor_text: Anchor::Sw,
            ignore_terminal_dimensions: false,
            reuse_canvas: false,
            no_eol: false,
            no_restore_cursor: false,
        }
    }
}

/// CharacterSort (argutils.CharacterSort).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CharacterSort {
    Random,
    TopToBottomLeftToRight,
    BottomToTopRightToLeft,
    BottomToTopLeftToRight,
    TopToBottomRightToLeft,
    OutsideRowToMiddle,
    MiddleRowToOutside,
}

/// CharacterGroup (argutils.CharacterGroup).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CharacterGroup {
    ColumnLeftToRight,
    ColumnRightToLeft,
    RowTopToBottom,
    RowBottomToTop,
    DiagonalBottomLeftToTopRight,
    DiagonalTopRightToBottomLeft,
    DiagonalTopLeftToBottomRight,
    DiagonalBottomRightToTopLeft,
    CenterToOutside,
    OutsideToCenter,
}

/// ColorSort (argutils.ColorSort).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ColorSort {
    LeastToMost,
    MostToLeast,
    Random,
}

/// Which character populations to include in a query (the four bool kwargs).
#[derive(Debug, Clone, Copy)]
pub struct CharacterFilter {
    pub input_chars: bool,
    pub inner_fill_chars: bool,
    pub outer_fill_chars: bool,
    pub added_chars: bool,
}

impl Default for CharacterFilter {
    fn default() -> Self {
        CharacterFilter {
            input_chars: true,
            inner_fill_chars: false,
            outer_fill_chars: false,
            added_chars: false,
        }
    }
}

pub struct Terminal {
    pub config: TerminalConfig,
    pub canvas: Canvas,
    pub arena: Vec<EffectCharacter>,
    pub(crate) next_character_id: u32,
    pub input_colors_frequency: ColorFrequency,
    terminal_dimensions: (i64, i64),
    resize_seen_at: Option<Instant>,
    /// A resize was seen since the last frame was written. The terminal may
    /// have reflowed what it shows, so differential output cannot trust it.
    repaint: bool,
    /// Pre-wrap input line lengths — all `compute_layout` needs from the input,
    /// so a resize can re-derive the geometry without re-preprocessing.
    input_line_lengths: Vec<i64>,
    pub canvas_column_offset: i64,
    pub canvas_row_offset: i64,
    pub visible_top: i64,
    pub visible_bottom: i64,
    pub visible_right: i64,
    pub visible_left: i64,
    pub input_characters: Vec<CharId>,
    pub added_characters: Vec<CharId>,
    pub character_by_input_coord: HashMap<Coord, CharId, FxBuild>,
    /// Slot by input coordinate over the canvas rectangle, row-major from
    /// (1, 1) (NONE when empty: only before fill characters exist).
    pub input_grid: Vec<u32>,
    /// The input characters' SGR sequences (InputChar::sequences).
    pub input_sequences: crate::engine::input::Sequences,
    pub inner_fill_characters: Vec<CharId>,
    pub outer_fill_characters: Vec<CharId>,
    visible_characters: Vec<CharId>,
    visible_positions: Vec<usize>,
    render_cells: Vec<u32>,
    /// Winner visual per cell, filled alongside `render_cells` so the emitter
    /// never goes back through the arena.
    render_visuals: Vec<*const CharacterVisual>,
    /// The visual each cell was last emitted with (null for a blank cell).
    /// Visuals are pooled, so pointer equality means byte equality.
    emitted_visuals: Vec<*const CharacterVisual>,
    /// Emitted bytes per row (index 0 is the bottom row).
    row_bytes: Vec<Vec<u8>>,
    pub terminal_state: Vec<String>,
    output_buffer: String,
    differential: crate::utils::differential::DifferentialOutput,
    move_cursor_to_top: String,
    frame_rate: i64,
    last_time_printed: Instant,
}

fn ordered_buckets(
    characters: Vec<CharId>,
    first_key: i64,
    last_key: i64,
    mut key: impl FnMut(CharId) -> i64,
) -> Vec<Vec<CharId>> {
    if first_key > last_key {
        return Vec::new();
    }
    let bucket_count = last_key
        .checked_sub(first_key)
        .and_then(|span| span.checked_add(1))
        .and_then(|span| usize::try_from(span).ok())
        .expect("terminal canvas is too large");
    let expected_bucket_len = characters.len() / bucket_count;
    let mut buckets: Vec<Vec<CharId>> = (0..bucket_count)
        .map(|_| Vec::with_capacity(expected_bucket_len))
        .collect();
    for id in characters {
        let character_key = key(id);
        if first_key <= character_key && character_key <= last_key {
            buckets[(character_key - first_key) as usize].push(id);
        }
    }
    buckets
        .into_iter()
        .filter(|bucket| !bucket.is_empty())
        .collect()
}

impl Terminal {
    pub fn new(input_data: &str, config: TerminalConfig) -> Result<Self, EngineError> {
        let (mut terminal, chars) = Terminal::parse(input_data, config)?;
        let config = &terminal.config;
        let always = config.existing_color_handling == ExistingColorHandling::Always;
        let mut arena = Vec::with_capacity(chars.len());
        let mut symbol = String::new();
        for c in &chars {
            symbol.clear();
            symbol.push(c.symbol);
            let mut ch = EffectCharacter::new(c.character_id, &symbol, c.coord.column, c.coord.row);
            ch.input_coord = c.input_coord;
            if c.sequences != NONE {
                let (fg, bg) = &terminal.input_sequences[c.sequences as usize];
                ch.input_ansi_fg_sequence = fg.clone();
                ch.input_ansi_bg_sequence = bg.clone();
            }
            ch.animation.input_fg_color = c.fg;
            ch.animation.input_bg_color = c.bg;
            ch.animation.input_bold = c.bold;
            ch.animation.no_color = config.no_color;
            ch.animation.use_xterm_colors = config.xterm_colors;
            ch.animation.existing_color_handling = config.existing_color_handling;
            ch.uses_input_preexisting_colors = c.uses_preexisting_colors;
            ch.is_fill_character = c.is_fill;
            if always && c.uses_preexisting_colors {
                ch.animation.set_appearance(&symbol, true, None, None);
            }
            arena.push(ch);
        }
        terminal.arena = arena;
        terminal.visible_positions = vec![NOT_VISIBLE; terminal.arena.len()];
        let canvas = &terminal.canvas;
        for (index, &slot) in terminal.input_grid.iter().enumerate() {
            if slot != NONE {
                let coord = Coord::new(
                    index as i64 % canvas.right + 1,
                    index as i64 / canvas.right + 1,
                );
                terminal
                    .character_by_input_coord
                    .insert(coord, CharId(slot));
            }
        }
        let neighbors = terminal.neighbors(&chars);
        for (ch, n) in terminal.arena.iter_mut().zip(neighbors) {
            ch.neighbors = n;
        }
        terminal.update_terminal_state();
        Ok(terminal)
    }

    /// Parse and lay out the input without building the old engine's
    /// characters: the terminal (with an empty arena and coordinate map) and
    /// every character as parsed, indexed by arena slot, fill characters
    /// included.
    pub fn parse(
        input_data: &str,
        config: TerminalConfig,
    ) -> Result<(Self, Vec<InputChar>), EngineError> {
        let input_data = if input_data.is_empty() {
            "No Input."
        } else {
            input_data
        };
        let mut chars: Vec<InputChar> = Vec::with_capacity(input_data.len() + input_data.len() / 8);
        let mut next_character_id: u32 = 0;
        let mut input_colors_frequency = ColorFrequency::default();

        let mut input_sequences = Vec::new();
        let preprocessed_lines = Preprocessor {
            arena: &mut chars,
            sequences: &mut input_sequences,
            next_character_id: &mut next_character_id,
            input_colors_frequency: &mut input_colors_frequency,
            config: &config,
        }
        .preprocess(input_data)?;

        let input_line_lengths: Vec<i64> =
            preprocessed_lines.iter().map(|l| l.len() as i64).collect();
        let terminal_dimensions = terminal_dimensions_for_config(&config, get_terminal_dimensions);
        let layout = compute_layout(
            &config,
            &input_line_lengths,
            terminal_dimensions.0,
            terminal_dimensions.1,
        );
        let mut canvas = Canvas::new(layout.canvas_height, layout.canvas_width);
        let Layout {
            column_offset: canvas_column_offset,
            row_offset: canvas_row_offset,
            visible_top,
            visible_bottom,
            visible_right,
            visible_left,
            ..
        } = layout;

        let input_characters =
            setup_input_characters(&config, &mut canvas, &mut chars, preprocessed_lines)?
                .into_iter()
                .filter(|&id| {
                    let coord = chars[id.0 as usize].input_coord;
                    coord.row <= canvas.top && coord.column <= canvas.right
                })
                .collect::<Vec<_>>();

        // Terminal._make_fill_characters: row-major from (1,1), fresh space
        // characters for unoccupied canvas coordinates, split inner/outer by
        // the text bounds. Input characters lie inside the canvas, so a dense
        // grid over it is the coordinate map.
        let (width, height) = (canvas.right.max(0) as usize, canvas.top.max(0) as usize);
        let mut input_grid = vec![
            NONE;
            width
                .checked_mul(height)
                .expect("terminal canvas is too large")
        ];
        for &id in &input_characters {
            let c = chars[id.0 as usize].input_coord;
            input_grid[(c.row - 1) as usize * width + (c.column - 1) as usize] = id.0;
        }
        let mut inner_fill_characters = Vec::new();
        let mut outer_fill_characters = Vec::new();
        for row in 1..=canvas.top {
            for column in 1..=canvas.right {
                let cell = &mut input_grid[(row - 1) as usize * width + (column - 1) as usize];
                if *cell != NONE {
                    continue;
                }
                let id = CharId(chars.len() as u32);
                chars.push(InputChar::fill(next_character_id, Coord::new(column, row)));
                next_character_id += 1;
                *cell = id.0;
                if canvas.text_left <= column
                    && column <= canvas.text_right
                    && canvas.text_bottom <= row
                    && row <= canvas.text_top
                {
                    inner_fill_characters.push(id);
                } else {
                    outer_fill_characters.push(id);
                }
            }
        }

        let frame_rate = config.frame_rate;
        let move_cursor_to_top = format!(
            "{}{}{}",
            ansi::DEC_RESTORE_CURSOR,
            ansi::DEC_SAVE_CURSOR,
            ansi::move_cursor_up(visible_top.max(0) as usize)
        );
        let terminal = Terminal {
            config,
            canvas,
            arena: Vec::new(),
            next_character_id,
            input_colors_frequency,
            terminal_dimensions,
            resize_seen_at: None,
            repaint: false,
            input_line_lengths,
            canvas_column_offset,
            canvas_row_offset,
            visible_top,
            visible_bottom,
            visible_right,
            visible_left,
            input_characters,
            added_characters: Vec::new(),
            character_by_input_coord: HashMap::default(),
            input_grid,
            input_sequences,
            inner_fill_characters,
            outer_fill_characters,
            visible_characters: Vec::new(),
            visible_positions: Vec::new(),
            render_cells: Vec::new(),
            render_visuals: Vec::new(),
            emitted_visuals: Vec::new(),
            row_bytes: Vec::new(),
            terminal_state: Vec::new(),
            output_buffer: String::new(),
            differential: Default::default(),
            move_cursor_to_top,
            frame_rate,
            last_time_printed: Instant::now(),
        };
        Ok((terminal, chars))
    }

    /// The cardinal neighbors of every parsed character (arena slot order):
    /// the characters at the adjacent input coordinates, over input and fill
    /// characters.
    pub fn neighbors(&self, chars: &[InputChar]) -> Vec<Neighbors> {
        let (width, height) = (self.canvas.right.max(0), self.canvas.top.max(0));
        let at = |column: i64, row: i64| -> Option<CharId> {
            if 1 <= column && column <= width && 1 <= row && row <= height {
                let slot = self.input_grid[((row - 1) * width + (column - 1)) as usize];
                (slot != NONE).then_some(CharId(slot))
            } else {
                None
            }
        };
        let mut out = vec![Neighbors::default(); chars.len()];
        for (index, &slot) in self.input_grid.iter().enumerate() {
            if slot == NONE {
                continue;
            }
            let (column, row) = (index as i64 % width + 1, index as i64 / width + 1);
            out[slot as usize] = Neighbors {
                north: at(column, row + 1),
                east: at(column + 1, row),
                south: at(column, row - 1),
                west: at(column - 1, row),
            };
        }
        out
    }

    /// Terminal.add_character: registered only in added_characters, not in
    /// character_by_input_coord or the neighbor map.
    pub fn add_character(&mut self, symbol: &str, coord: Coord) -> CharId {
        let mut ch = EffectCharacter::new(self.next_character_id, symbol, coord.column, coord.row);
        ch.animation.no_color = self.config.no_color;
        ch.animation.use_xterm_colors = self.config.xterm_colors;
        ch.animation.existing_color_handling = self.config.existing_color_handling;
        ch.uses_input_preexisting_colors = false;
        self.next_character_id += 1;
        let id = CharId(self.arena.len() as u32);
        self.arena.push(ch);
        self.added_characters.push(id);
        id
    }

    pub fn get_character_by_input_coord(&self, coord: Coord) -> Option<CharId> {
        self.character_by_input_coord.get(&coord).copied()
    }

    pub fn set_character_visibility(&mut self, id: CharId, is_visible: bool) {
        let arena_index = id.0 as usize;
        if self.arena[arena_index].is_visible == is_visible {
            return;
        }
        self.arena[arena_index].is_visible = is_visible;
        self.visible_positions.resize(self.arena.len(), NOT_VISIBLE);
        if is_visible {
            self.visible_positions[arena_index] = self.visible_characters.len();
            self.visible_characters.push(id);
        } else {
            let position = std::mem::replace(&mut self.visible_positions[arena_index], NOT_VISIBLE);
            self.visible_characters.swap_remove(position);
            if position < self.visible_characters.len() {
                let moved = self.visible_characters[position];
                self.visible_positions[moved.0 as usize] = position;
            }
        }
    }

    /// Terminal.get_input_colors. Equal-count ties keep insertion order
    /// (Python's stable sort over dict keys).
    pub fn get_input_colors(&self, rng: &mut Rng, sort: ColorSort) -> Vec<Color> {
        let mut colors: Vec<(Color, i64)> = self.input_colors_frequency.0.clone();
        match sort {
            ColorSort::MostToLeast => {
                // Python: sorted(keys, key=count, reverse=True) — reverse of a
                // stable ascending sort reverses tie order too; replicate by
                // sorting descending with stable tie order = insertion order.
                colors.sort_by(|a, b| b.1.cmp(&a.1));
            }
            ColorSort::LeastToMost => {
                colors.sort_by(|a, b| a.1.cmp(&b.1));
            }
            ColorSort::Random => {
                rng.shuffle(&mut colors);
            }
        }
        colors.into_iter().map(|(c, _)| c).collect()
    }

    pub fn collect_characters(&self, filter: CharacterFilter) -> Vec<CharId> {
        let capacity = if filter.input_chars {
            self.input_characters.len()
        } else {
            0
        } + if filter.inner_fill_chars {
            self.inner_fill_characters.len()
        } else {
            0
        } + if filter.outer_fill_chars {
            self.outer_fill_characters.len()
        } else {
            0
        } + if filter.added_chars {
            self.added_characters.len()
        } else {
            0
        };
        let mut all: Vec<CharId> = Vec::with_capacity(capacity);
        if filter.input_chars {
            all.extend(&self.input_characters);
        }
        if filter.inner_fill_chars {
            all.extend(&self.inner_fill_characters);
        }
        if filter.outer_fill_chars {
            all.extend(&self.outer_fill_characters);
        }
        if filter.added_chars {
            all.extend(&self.added_characters);
        }
        all
    }

    /// Terminal.get_characters with all sort variants.
    pub fn get_characters(
        &self,
        rng: &mut Rng,
        filter: CharacterFilter,
        sort: CharacterSort,
    ) -> Vec<CharId> {
        let mut all = self.collect_characters(filter);
        // default sort: (-row, column), stable
        all.sort_by_key(|&id| {
            let c = self.arena[id.0 as usize].input_coord;
            (-c.row, c.column)
        });
        match sort {
            CharacterSort::Random => rng.shuffle(&mut all),
            CharacterSort::TopToBottomLeftToRight => {}
            CharacterSort::BottomToTopRightToLeft => all.reverse(),
            CharacterSort::BottomToTopLeftToRight | CharacterSort::TopToBottomRightToLeft => {
                all.sort_by_key(|&id| {
                    let c = self.arena[id.0 as usize].input_coord;
                    (c.row, c.column)
                });
                if sort == CharacterSort::TopToBottomRightToLeft {
                    all.reverse();
                }
            }
            CharacterSort::OutsideRowToMiddle | CharacterSort::MiddleRowToOutside => {
                // upstream: alternate pop(0)/pop(-1)
                let mut deque: std::collections::VecDeque<CharId> = all.into();
                let mut interleaved = Vec::with_capacity(deque.len());
                let mut from_front = true;
                while let Some(id) = if from_front {
                    deque.pop_front()
                } else {
                    deque.pop_back()
                } {
                    interleaved.push(id);
                    from_front = !from_front;
                }
                all = interleaved;
                if sort == CharacterSort::MiddleRowToOutside {
                    all.reverse();
                }
            }
        }
        all
    }

    /// Terminal.get_characters_grouped with all grouping variants.
    pub fn get_characters_grouped(
        &self,
        filter: CharacterFilter,
        grouping: CharacterGroup,
    ) -> Vec<Vec<CharId>> {
        let mut all = self.collect_characters(filter);
        all.sort_by_key(|&id| {
            let c = self.arena[id.0 as usize].input_coord;
            (c.row, c.column)
        });
        let coord = |id: &CharId| self.arena[id.0 as usize].input_coord;
        match grouping {
            CharacterGroup::ColumnLeftToRight | CharacterGroup::ColumnRightToLeft => {
                let mut columns =
                    ordered_buckets(all, 0, self.canvas.right, |id| coord(&id).column);
                if grouping == CharacterGroup::ColumnRightToLeft {
                    columns.reverse();
                }
                columns
            }
            CharacterGroup::RowBottomToTop | CharacterGroup::RowTopToBottom => {
                let mut rows = ordered_buckets(all, 0, self.canvas.top, |id| coord(&id).row);
                if grouping == CharacterGroup::RowTopToBottom {
                    rows.reverse();
                }
                rows
            }
            CharacterGroup::DiagonalBottomLeftToTopRight
            | CharacterGroup::DiagonalTopRightToBottomLeft => {
                let mut diagonals =
                    ordered_buckets(all, 0, self.canvas.top + self.canvas.right, |id| {
                        let c = coord(&id);
                        c.row + c.column
                    });
                if grouping == CharacterGroup::DiagonalTopRightToBottomLeft {
                    diagonals.reverse();
                }
                diagonals
            }
            CharacterGroup::DiagonalTopLeftToBottomRight
            | CharacterGroup::DiagonalBottomRightToTopLeft => {
                let mut diagonals = ordered_buckets(
                    all,
                    self.canvas.left - self.canvas.top,
                    self.canvas.right - self.canvas.bottom,
                    |id| {
                        let c = coord(&id);
                        c.column - c.row
                    },
                );
                if grouping == CharacterGroup::DiagonalBottomRightToTopLeft {
                    diagonals.reverse();
                }
                diagonals
            }
            CharacterGroup::CenterToOutside | CharacterGroup::OutsideToCenter => {
                let max_distance = all
                    .iter()
                    .map(|&id| {
                        let c = coord(&id);
                        (c.column - self.canvas.text_center.column).abs()
                            + (c.row - self.canvas.text_center.row).abs()
                    })
                    .max();
                let dense_limit = all.len().saturating_mul(4).max(256);
                let mut groups = if max_distance
                    .and_then(|distance| usize::try_from(distance).ok())
                    .is_some_and(|distance| distance <= dense_limit)
                {
                    ordered_buckets(all, 0, max_distance.unwrap(), |id| {
                        let c = coord(&id);
                        (c.column - self.canvas.text_center.column).abs()
                            + (c.row - self.canvas.text_center.row).abs()
                    })
                } else {
                    // Out-of-canvas added characters can have sparse, arbitrarily
                    // large distances; avoid allocating through the largest key.
                    let mut distances: HashMap<i64, Vec<CharId>> = HashMap::new();
                    for id in all {
                        let c = coord(&id);
                        let distance = (c.column - self.canvas.text_center.column).abs()
                            + (c.row - self.canvas.text_center.row).abs();
                        distances.entry(distance).or_default().push(id);
                    }
                    let mut distances: Vec<(i64, Vec<CharId>)> = distances.into_iter().collect();
                    distances.sort_by_key(|&(distance, _)| distance);
                    distances.into_iter().map(|(_, group)| group).collect()
                };
                if grouping == CharacterGroup::OutsideToCenter {
                    groups.reverse();
                }
                groups
            }
        }
    }

    /// Paint the visible characters into the reusable cell buffer using the
    /// canonical (layer, character_id) painter order (plan.md §4.3).
    fn update_render_cells(&mut self) -> (usize, usize) {
        let width = self.visible_right.max(0) as usize;
        let height = self.visible_top.max(0) as usize;
        let cell_count = width
            .checked_mul(height)
            .expect("terminal canvas is too large");
        self.render_cells.resize(cell_count, EMPTY_RENDER_CELL);
        self.render_cells.fill(EMPTY_RENDER_CELL);
        self.render_visuals.resize(cell_count, std::ptr::null());
        self.render_visuals.fill(std::ptr::null());

        // The old implementation sorted every visible character by painter
        // order and overwrote cells in that order.  A cell only needs the
        // maximum key, so select that winner directly and avoid the per-frame
        // allocation and O(n log n) sort.
        for &id in &self.visible_characters {
            let ch = &self.arena[id.0 as usize];
            let row = ch.motion.current_coord.row + self.canvas_row_offset;
            let column = ch.motion.current_coord.column + self.canvas_column_offset;
            if self.visible_bottom <= row
                && row <= self.visible_top
                && self.visible_left <= column
                && column <= self.visible_right
            {
                let index = (row - 1) as usize * width + (column - 1) as usize;
                let cell = &mut self.render_cells[index];
                let wins = *cell == EMPTY_RENDER_CELL || {
                    let painted = &self.arena[*cell as usize];
                    (ch.layer, ch.character_id) > (painted.layer, painted.character_id)
                };
                if wins {
                    *cell = id.0;
                    self.render_visuals[index] = ch.animation.current_character_visual;
                }
            }
        }

        (width, height)
    }

    /// Visit the canonical composited cells in bottom-to-top row-major order.
    /// Empty cells are reported as `None`; populated cells expose structured
    /// visuals without reparsing their cached ANSI representation.
    pub fn visit_render_cells(
        &mut self,
        mut visit: impl FnMut(Option<&crate::engine::animation::CharacterVisual>),
    ) -> (usize, usize) {
        let dimensions = self.update_render_cells();
        for &cell in &self.render_cells {
            let visual = (cell != EMPTY_RENDER_CELL)
                .then(|| &*self.arena[cell as usize].animation.current_character_visual);
            visit(visual);
        }
        dimensions
    }

    /// Terminal._update_terminal_state: materialize the row-oriented state
    /// exposed by the upstream API. Frame output uses the cell buffer directly
    /// so the hot path does not copy every rendered byte through these rows.
    pub fn update_terminal_state(&mut self) {
        let (width, height) = self.update_render_cells();

        self.terminal_state.resize_with(height, String::new);
        self.terminal_state.truncate(height);
        let arena = &self.arena;
        for (row_index, row) in self.terminal_state.iter_mut().enumerate() {
            row.clear();
            if row.capacity() < width {
                row.reserve(width);
            }
            for &cell in &self.render_cells[row_index * width..(row_index + 1) * width] {
                if cell == EMPTY_RENDER_CELL {
                    row.push(' ');
                } else {
                    row.push_str(
                        arena[cell as usize]
                            .animation
                            .current_character_visual
                            .formatted_symbol
                            .as_str(),
                    );
                }
            }
        }
    }

    /// get_formatted_output_string: refresh + emit top row first.
    pub fn get_formatted_output_string(&mut self) -> String {
        let (width, height) = self.update_render_cells();
        let minimum_capacity = width
            .checked_mul(height)
            .and_then(|cells| cells.checked_add(height.saturating_sub(1)))
            .expect("terminal canvas is too large");
        let mut out = std::mem::take(&mut self.output_buffer).into_bytes();
        out.clear();
        if out.capacity() < minimum_capacity {
            out.reserve(minimum_capacity);
        }
        let cell_count = width * height;
        if self.emitted_visuals.len() != cell_count || self.row_bytes.len() != height {
            self.emitted_visuals.clear();
            self.emitted_visuals.resize(cell_count, std::ptr::null());
            self.row_bytes.clear();
            self.row_bytes.resize_with(height, Vec::new);
            // Force every row to be emitted on the first frame after a resize.
            for row in &mut self.row_bytes {
                row.push(0);
            }
        }
        for row_index in 0..height {
            let range = row_index * width..(row_index + 1) * width;
            let bytes = &mut self.row_bytes[row_index];
            let fresh = &self.render_visuals[range.clone()];
            let emitted = &mut self.emitted_visuals[range];
            let first_frame = bytes.len() == 1 && bytes[0] == 0;
            if first_frame || fresh != &emitted[..] {
                emitted.copy_from_slice(fresh);
                bytes.clear();
                for &visual in fresh {
                    // SAFETY: non-null entries point at pooled visuals, which are never freed.
                    match unsafe { visual.as_ref() } {
                        None => bytes.push(b' '),
                        Some(visual) => visual.formatted_symbol.append_to(bytes),
                    }
                }
            }
        }
        for row_index in (0..height).rev() {
            if row_index + 1 < height {
                out.push(b'\n');
            }
            out.extend_from_slice(&self.row_bytes[row_index]);
        }
        // SAFETY: every appended run is a whole formatted symbol, which is UTF-8.
        unsafe { String::from_utf8_unchecked(out) }
    }

    pub(crate) fn recycle_output_string(&mut self, mut output: String) {
        output.clear();
        if output.capacity() > self.output_buffer.capacity() {
            self.output_buffer = output;
        }
    }

    /// Whether a resize has landed, settled, and actually moved something.
    ///
    /// Settled: dragging a window edge emits a SIGWINCH per step, and rebuilding
    /// for each one pins the animation at its opening frames for the whole drag.
    /// Each signal restarts a quiet window; the old canvas keeps animating until
    /// it expires, so the wait costs nothing on screen.
    ///
    /// Moved something: a new terminal size is not enough. With an input-sized
    /// canvas and no anchor offsets most resizes leave every rendered cell
    /// exactly where it was, and restarting for those is pure loss. Explicitly
    /// ignored dimensions are fixed by definition.
    pub fn resize_settled(&mut self) -> bool {
        let seen_before = self.resize_seen_at;
        let settled = resize_settled(
            &mut self.resize_seen_at,
            &self.config,
            &self.input_line_lengths,
            self.terminal_dimensions,
        );
        // A new signal always restamps seen_at; most resizes never restart.
        self.repaint |= self.resize_seen_at.is_some() && self.resize_seen_at != seen_before;
        settled
    }

    /// Whether the next frame must be written whole, consuming the request.
    pub(crate) fn take_repaint(&mut self) -> bool {
        std::mem::take(&mut self.repaint)
    }

    /// After a resize: go back to the top of the area this run allocated, wipe
    /// it, and leave the cursor there so the rebuilt canvas takes the same rows
    /// instead of scrolling a second one into the terminal.
    pub fn reset_canvas_area(&self, out: &mut impl Write) -> std::io::Result<()> {
        out.write_all(ansi::DEC_RESTORE_CURSOR.as_bytes())?;
        if self.visible_top > 0 {
            out.write_all(ansi::move_cursor_up(self.visible_top as usize).as_bytes())?;
        }
        out.write_all(ansi::CLEAR_TO_END_OF_SCREEN.as_bytes())?;
        Ok(())
    }

    // --- tty side (upstream's second Terminal instance) ---

    pub fn prep_canvas(&mut self, out: &mut impl Write) -> std::io::Result<()> {
        out.write_all(ansi::HIDE_CURSOR.as_bytes())?;
        if self.config.reuse_canvas {
            self.write_move_cursor_to_top(out)?;
        }
        for _ in 0..self.visible_top {
            let blank = " ".repeat(self.visible_right.max(0) as usize);
            out.write_all(blank.as_bytes())?;
            out.write_all(b"\n")?;
        }
        out.write_all(ansi::DEC_SAVE_CURSOR.as_bytes())?;
        Ok(())
    }

    pub fn restore_cursor(&self, out: &mut impl Write, end_symbol: &str) -> std::io::Result<()> {
        let end_symbol = if self.config.no_eol { "" } else { end_symbol };
        if !self.config.no_restore_cursor {
            out.write_all(ansi::SHOW_CURSOR.as_bytes())?;
        }
        out.write_all(end_symbol.as_bytes())?;
        Ok(())
    }

    pub fn print_frame(
        &mut self,
        out: &mut impl Write,
        output_string: &str,
    ) -> std::io::Result<()> {
        self.write_move_cursor_to_top(out)?;
        out.write_all(output_string.as_bytes())?;
        out.flush()
    }

    pub(crate) fn print_differential_frame(
        &mut self,
        out: &mut impl Write,
        output_string: &str,
    ) -> std::io::Result<()> {
        if self.take_repaint() {
            self.differential.invalidate();
            return self.print_frame(out, output_string);
        }
        let width = self.visible_right.max(0) as usize;
        let height = self.visible_top.max(0) as usize;
        let cells = &self.render_visuals;
        let frame = self.differential.frame(
            width,
            height,
            self.move_cursor_to_top.as_bytes(),
            |row, col| {
                let visual = cells[(height - 1 - row) * width + col];
                // SAFETY: visuals are pooled for the lifetime of the terminal.
                unsafe { visual.as_ref() }
                    .map_or(b" " as &[u8], |v| v.formatted_symbol.as_str().as_bytes())
            },
        );
        match frame {
            Some(bytes) => out.write_all(bytes)?,
            None => return self.print_frame(out, output_string),
        }
        out.flush()
    }

    /// The escape sequence every frame starts with.
    pub(crate) fn move_cursor_to_top(&self) -> &str {
        &self.move_cursor_to_top
    }

    fn write_move_cursor_to_top(&self, out: &mut impl Write) -> std::io::Result<()> {
        out.write_all(self.move_cursor_to_top.as_bytes())
    }

    /// Terminal.enforce_framerate: sleep off the remainder; timestamp taken
    /// AFTER the sleep (drift accumulates, faithfully).
    pub fn enforce_framerate(&mut self) {
        if self.frame_rate == 0 {
            return;
        }
        let frame_delay = 1.0 / self.frame_rate as f64;
        let elapsed = self.last_time_printed.elapsed().as_secs_f64();
        if elapsed < frame_delay {
            std::thread::sleep(std::time::Duration::from_secs_f64(frame_delay - elapsed));
        }
        self.last_time_printed = Instant::now();
    }
}

/// [`Terminal::resize_settled`] for a run described only by its settings,
/// input line lengths and starting dimensions.
pub fn resize_settled(
    seen_at: &mut Option<Instant>,
    config: &TerminalConfig,
    line_lengths: &[i64],
    dimensions: (i64, i64),
) -> bool {
    const QUIET: std::time::Duration = std::time::Duration::from_millis(50);

    if crate::take_terminal_resize() {
        *seen_at = Some(Instant::now());
    }
    match *seen_at {
        Some(seen) if seen.elapsed() >= QUIET => *seen_at = None,
        _ => return false,
    }
    if config.ignore_terminal_dimensions {
        return false;
    }
    let (width, height) = get_terminal_dimensions();
    if (width, height) == dimensions {
        return false;
    }
    compute_layout(config, line_lengths, width, height)
        != compute_layout(config, line_lengths, dimensions.0, dimensions.1)
}

fn terminal_dimensions_for_config(
    config: &TerminalConfig,
    probe: impl FnOnce() -> (i64, i64),
) -> (i64, i64) {
    if config.ignore_terminal_dimensions && config.canvas_width > 0 && config.canvas_height > 0 {
        (config.canvas_width, config.canvas_height)
    } else {
        probe()
    }
}

/// shutil.get_terminal_size semantics: COLUMNS/LINES env vars win; else query
/// the tty; on failure (80, 24).
pub fn get_terminal_dimensions() -> (i64, i64) {
    let env_dim = |name: &str| -> Option<i64> { std::env::var(name).ok()?.parse::<i64>().ok() };
    let columns = env_dim("COLUMNS");
    let lines = env_dim("LINES");
    if let (Some(c), Some(l)) = (columns, lines) {
        return (c, l);
    }
    match terminal_size::terminal_size() {
        Some((terminal_size::Width(w), terminal_size::Height(h))) => {
            (columns.unwrap_or(w as i64), lines.unwrap_or(h as i64))
        }
        None => (columns.unwrap_or(80), lines.unwrap_or(24)),
    }
}

/// Everything about the drawing area that is derived from the terminal size.
/// A resize only matters if recomputing this yields something different, so it
/// is factored out of Terminal::new rather than inlined there.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Layout {
    canvas_height: i64,
    canvas_width: i64,
    column_offset: i64,
    row_offset: i64,
    visible_top: i64,
    visible_bottom: i64,
    visible_right: i64,
    visible_left: i64,
}

fn compute_layout(
    config: &TerminalConfig,
    line_lengths: &[i64],
    terminal_width: i64,
    terminal_height: i64,
) -> Layout {
    let (canvas_height, canvas_width) =
        get_canvas_dimensions(config, line_lengths, terminal_width, terminal_height);
    let canvas = Canvas::new(canvas_height, canvas_width);
    let (mut width, mut height) = (terminal_width, terminal_height);
    let (column_offset, row_offset) = if !config.ignore_terminal_dimensions {
        calc_canvas_offsets(config, &canvas, width, height)
    } else {
        width = canvas.right;
        height = canvas.top;
        (0, 0)
    };
    Layout {
        canvas_height,
        canvas_width,
        column_offset,
        row_offset,
        visible_top: std::cmp::min(canvas.top + row_offset, height),
        visible_bottom: std::cmp::max(canvas.bottom + row_offset, 1),
        visible_right: std::cmp::min(canvas.right + column_offset, width),
        visible_left: std::cmp::max(canvas.left + column_offset, 1),
    }
}

/// Terminal._get_canvas_dimensions -> (height, width).
fn get_canvas_dimensions(
    config: &TerminalConfig,
    line_lengths: &[i64],
    terminal_width: i64,
    terminal_height: i64,
) -> (i64, i64) {
    let canvas_width = if config.canvas_width > 0 {
        config.canvas_width
    } else if config.canvas_width == 0 {
        terminal_width
    } else {
        let input_width = line_lengths.iter().copied().max().unwrap_or(0);
        if config.ignore_terminal_dimensions {
            input_width
        } else {
            std::cmp::min(terminal_width, input_width)
        }
    };
    let canvas_height = if config.canvas_height > 0 {
        config.canvas_height
    } else if config.canvas_height == 0 {
        terminal_height
    } else {
        let input_height = line_lengths.len() as i64;
        if config.ignore_terminal_dimensions {
            input_height
        } else if config.wrap_text {
            std::cmp::min(
                wrapped_line_count(line_lengths, canvas_width),
                terminal_height,
            )
        } else {
            std::cmp::min(terminal_height, input_height)
        }
    };
    (canvas_height, canvas_width)
}

fn wrapped_line_count(line_lengths: &[i64], width: i64) -> i64 {
    let mut count: i64 = 0;
    for &length in line_lengths {
        let mut remaining = length;
        while remaining > width {
            count += 1;
            remaining -= width;
        }
        count += 1;
    }
    count
}

/// Terminal._wrap_lines.
fn wrap_lines(lines: Vec<Vec<CharId>>, width: i64) -> Vec<Vec<CharId>> {
    let mut wrapped: Vec<Vec<CharId>> = Vec::new();
    for line in lines {
        let mut current = line;
        while current.len() as i64 > width {
            let rest = current.split_off(width as usize);
            wrapped.push(current);
            current = rest;
        }
        wrapped.push(current);
    }
    wrapped
}

fn calc_canvas_offsets(
    config: &TerminalConfig,
    canvas: &Canvas,
    terminal_width: i64,
    terminal_height: i64,
) -> (i64, i64) {
    use crate::engine::canvas::Anchor::*;
    use crate::utils::pycompat::floor_div;
    let mut column_offset = 0;
    let mut row_offset = 0;
    match config.anchor_canvas {
        S | N | C => column_offset = floor_div(terminal_width, 2) - floor_div(canvas.width, 2),
        Se | E | Ne => column_offset = terminal_width - canvas.width,
        _ => {}
    }
    match config.anchor_canvas {
        W | E | C => row_offset = floor_div(terminal_height, 2) - floor_div(canvas.height, 2),
        Nw | N | Ne => row_offset = terminal_height - canvas.height,
        _ => {}
    }
    (column_offset, row_offset)
}

/// Terminal._setup_input_characters: wrap, assign 1-based bottom-up coords,
/// drop plain spaces (they become fill), anchor, and keep in-canvas chars.
fn setup_input_characters(
    config: &TerminalConfig,
    canvas: &mut Canvas,
    arena: &mut [InputChar],
    preprocessed_lines: Vec<Vec<CharId>>,
) -> Result<Vec<CharId>, EngineError> {
    let formatted_lines = if config.wrap_text {
        wrap_lines(preprocessed_lines, canvas.right)
    } else {
        preprocessed_lines
    };
    let input_height = formatted_lines.len() as i64;
    let mut input_characters: Vec<CharId> = Vec::new();
    for (row, line) in formatted_lines.iter().enumerate() {
        for (column0, &id) in line.iter().enumerate() {
            let column = column0 as i64 + 1;
            let ch = &mut arena[id.0 as usize];
            ch.input_coord = Coord::new(column, input_height - row as i64);
            if !ch.is_blank() {
                input_characters.push(id);
            }
        }
    }
    canvas
        .anchor_text(arena, input_characters, config.anchor_text)
        .map_err(EngineError::Other)
}

#[cfg(test)]
mod differential_tests {
    use super::*;

    #[test]
    fn a_resize_repaints_the_whole_frame_once() {
        let config = TerminalConfig {
            ignore_terminal_dimensions: true,
            ..TerminalConfig::default()
        };
        let mut terminal = Terminal::new("ab\ncd", config).unwrap();
        for id in terminal.input_characters.clone() {
            terminal.set_character_visibility(id, true);
        }
        let frame = |terminal: &mut Terminal| {
            let whole = terminal.get_formatted_output_string();
            let mut out = Vec::new();
            terminal.print_differential_frame(&mut out, &whole).unwrap();
            (whole, String::from_utf8(out).unwrap())
        };
        frame(&mut terminal);
        assert_eq!(frame(&mut terminal).1, "");

        terminal.repaint = true;
        let (whole, written) = frame(&mut terminal);
        assert_eq!(written, format!("{}{}", terminal.move_cursor_to_top(), whole));
        assert!(!frame(&mut terminal).1.is_empty(), "the cache was not invalidated");
    }
}

#[cfg(test)]
mod embedded_dimensions_tests {
    use super::*;

    #[test]
    fn explicit_embedded_dimensions_do_not_probe_the_tty() {
        let config = TerminalConfig {
            canvas_width: 80,
            canvas_height: 24,
            ignore_terminal_dimensions: true,
            ..TerminalConfig::default()
        };

        let dimensions = terminal_dimensions_for_config(&config, || {
            panic!("embedded rendering must not query a tty")
        });

        assert_eq!(dimensions, (80, 24));
    }
}
