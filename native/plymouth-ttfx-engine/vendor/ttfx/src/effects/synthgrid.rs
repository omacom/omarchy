//! synthgrid, ported from effects/effect_synthgrid.py.
//!
//! The module-level GridLine class is the `GridLine` struct; its constructor
//! lives on `Synthgrid` (make_grid_line) for EffectHooks access. Groups are
//! `(group_number, Vec<CharId>)` tuples; the SCENE_COMPLETE-driven group
//! tracker is a Vec indexed by group_number, decremented via an effect
//! callback (upstream EventHandler.Callback(update_group_tracker, n)).
//! No observable set iteration beyond the engine-canonical active_characters
//! (docs/ordering-inventory.md).

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_positive_ratio, parse_symbol,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallbackValue, CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, CoordColorMap, Gradient, GradientDirection};
use crate::utils::pycompat::floor_div;

/// Callback id: update_group_tracker(group_number) — decrements the tracker.
const CB_UPDATE_GROUP_TRACKER: u32 = 0;

#[derive(Args, Debug, Clone)]
pub struct SynthGridConfig {
    /// Space separated, unquoted, list of colors for the grid gradient.
    #[arg(long = "grid-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["CC00CC", "ffffff"])]
    pub grid_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, list of the number of gradient steps to use. More steps will create a smoother and longer gradient animation.
    #[arg(long = "grid-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub grid_gradient_steps: Vec<i64>,

    /// Direction of the gradient for the grid color.
    #[arg(long = "grid-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub grid_gradient_direction: GradientDirection,

    /// Space separated, unquoted, list of colors for the text gradient.
    #[arg(long = "text-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub text_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, list of the number of gradient steps to use. More steps will create a smoother and longer gradient animation.
    #[arg(long = "text-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub text_gradient_steps: Vec<i64>,

    /// Direction of the gradient for the text color.
    #[arg(long = "text-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub text_gradient_direction: GradientDirection,

    /// Symbol to use for grid row lines.
    #[arg(long = "grid-row-symbol", default_value = "─", value_parser = parse_symbol)]
    pub grid_row_symbol: String,

    /// Symbol to use for grid column lines.
    #[arg(long = "grid-column-symbol", default_value = "│", value_parser = parse_symbol)]
    pub grid_column_symbol: String,

    /// Space separated, unquoted, list of characters for the text generation animation.
    #[arg(long = "text-generation-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["░", "▒", "▓"])]
    pub text_generation_symbols: Vec<String>,

    /// Maximum percentage of blocks to have active at any given time. For example, if set to 0.1, 10 percent of the blocks will be active at any given time.
    #[arg(long = "max-active-blocks", default_value_t = 0.1, value_parser = parse_positive_ratio)]
    pub max_active_blocks: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Direction {
    Horizontal,
    Vertical,
}

/// GridLine (module-level class in effect_synthgrid.py).
struct GridLine {
    direction: Direction,
    #[allow(dead_code)]
    characters: Vec<CharId>,
    collapsed_characters: Vec<CharId>,
    extended_characters: Vec<CharId>,
}

impl GridLine {
    /// GridLine.extend.
    fn extend(&mut self, ctx: &mut EngineCtx) {
        let count = if self.direction == Direction::Horizontal { 3 } else { 1 };
        for _ in 0..count {
            if !self.collapsed_characters.is_empty() {
                let next_char = self.collapsed_characters.remove(0);
                ctx.terminal.set_character_visibility(next_char, true);
                self.extended_characters.push(next_char);
            }
        }
    }

    /// GridLine.collapse.
    fn collapse(&mut self, ctx: &mut EngineCtx) {
        let count = if self.direction == Direction::Horizontal { 3 } else { 1 };
        if self.collapsed_characters.is_empty() {
            self.extended_characters.reverse();
        }
        for _ in 0..count {
            if !self.extended_characters.is_empty() {
                let next_char = self.extended_characters.remove(0);
                ctx.terminal.set_character_visibility(next_char, false);
                self.collapsed_characters.push(next_char);
            }
        }
    }

    /// GridLine.is_extended.
    fn is_extended(&self) -> bool {
        self.collapsed_characters.is_empty()
    }

    /// GridLine.is_collapsed.
    fn is_collapsed(&self) -> bool {
        self.extended_characters.is_empty()
    }
}

/// _phase strings from SynthGridIterator.__next__.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    GridExpand,
    AddChars,
    Collapse,
    Complete,
}

pub struct SynthGrid {
    config: SynthGridConfig,
    pending_groups: Vec<(i64, Vec<CharId>)>,
    grid_lines: Vec<GridLine>,
    /// group_tracker dict, indexed by group_number (keys are 0..n in order).
    group_tracker: Vec<i64>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    phase: Phase,
    total_group_count: usize,
    active_groups: i64,
}

impl SynthGrid {
    pub fn new(config: SynthGridConfig) -> Self {
        SynthGrid {
            config,
            pending_groups: Vec::new(),
            grid_lines: Vec::new(),
            group_tracker: Vec::new(),
            character_final_color_map: HashMap::new(),
            phase: Phase::GridExpand,
            total_group_count: 0,
            active_groups: 0,
        }
    }

    /// SynthGridIterator.find_even_gap.
    fn find_even_gap(dimension: i64) -> i64 {
        let dimension = dimension - 2;
        if dimension <= 0 {
            return 0;
        }
        // [i for i in range(dimension, 4, -1) if dimension % i <= 1]
        let mut potential_gaps: Vec<i64> = Vec::new();
        let mut i = dimension;
        while i > 4 {
            if dimension % i <= 1 {
                potential_gaps.push(i);
            }
            i -= 1;
        }
        if potential_gaps.is_empty() {
            return 4;
        }
        // min(potential_gaps, key=lambda x: abs(x - dimension // 5)) — first minimum wins
        let target = floor_div(dimension, 5);
        let mut best = potential_gaps[0];
        let mut best_key = (potential_gaps[0] - target).abs();
        for &gap in &potential_gaps[1..] {
            let key = (gap - target).abs();
            if key < best_key {
                best = gap;
                best_key = key;
            }
        }
        best
    }

    /// GridLine.__init__ (needs EffectHooks for activate_scene, so lives here).
    fn make_grid_line(
        &mut self,
        ctx: &mut EngineCtx,
        origin: Coord,
        direction: Direction,
        grid_gradient_mapping: &CoordColorMap,
    ) -> Result<GridLine, EngineError> {
        let grid_symbol = match direction {
            Direction::Horizontal => self.config.grid_row_symbol.clone(),
            Direction::Vertical => self.config.grid_column_symbol.clone(),
        };
        let mut characters: Vec<CharId> = Vec::new();
        let coords: Vec<Coord> = match direction {
            Direction::Horizontal => (ctx.terminal.canvas.left..=ctx.terminal.canvas.right)
                .map(|column_index| Coord::new(column_index, origin.row))
                .collect(),
            Direction::Vertical => (ctx.terminal.canvas.bottom..ctx.terminal.canvas.top)
                .map(|row_index| Coord::new(origin.column, row_index))
                .collect(),
        };
        for coord in coords {
            let effect_char = ctx.terminal.add_character(&grid_symbol, Coord::new(0, 0));
            let grid_scn = {
                let ch = &mut ctx.terminal.arena[effect_char.0 as usize];
                let uses_pre = ch.uses_input_preexisting_colors;
                let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                let fg = grid_gradient_mapping.get(&coord).expect("grid gradient mapping missing coord").clone();
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .add_frame(
                        &grid_symbol,
                        1,
                        VisualParams { colors: Some(ColorPair::new(Some(fg), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
                scene_id
            };
            ctx.activate_scene(self, effect_char, &grid_scn);
            let ch = &mut ctx.terminal.arena[effect_char.0 as usize];
            ch.layer = 2;
            ch.motion.set_coordinate(coord);
            characters.push(effect_char);
        }
        let collapsed_characters = characters.clone();
        Ok(GridLine { direction, characters, collapsed_characters, extended_characters: Vec::new() })
    }
}

impl EffectHooks for SynthGrid {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, callback: &EffectCallback) {
        if callback.id == CB_UPDATE_GROUP_TRACKER {
            if let CallbackValue::Int(group_number) = callback.args[0] {
                self.group_tracker[group_number as usize] -= 1;
            }
        }
    }
}

impl Effect for SynthGrid {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let grid_gradient =
            Gradient::new(&self.config.grid_gradient_stops, &self.config.grid_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let grid_gradient_mapping = grid_gradient
            .build_coordinate_color_mapping(
                1,
                ctx.terminal.canvas.top,
                1,
                ctx.terminal.canvas.right,
                self.config.grid_gradient_direction,
            )
            .map_err(EngineError::Other)?;
        let text_gradient =
            Gradient::new(&self.config.text_gradient_stops, &self.config.text_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let text_gradient_mapping = ctx
            .final_gradient_mapping(&text_gradient, self.config.text_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters =
            ctx.terminal.get_characters(&mut ctx.rng, CharacterFilter::default(), CharacterSort::TopToBottomLeftToRight);
        for id in characters {
            let ch = &ctx.terminal.arena[id.0 as usize];
            let colors = if dynamic {
                ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
            } else if ch.input_symbol != " " {
                ColorPair::new(
                    Some(text_gradient_mapping.get(&ch.input_coord).expect("text gradient mapping").clone()),
                    None,
                )
            } else {
                ColorPair::default()
            };
            self.character_final_color_map.insert(id, colors);
        }

        let (canvas_left, canvas_right, canvas_bottom, canvas_top) = {
            let c = &ctx.terminal.canvas;
            (c.left, c.right, c.bottom, c.top)
        };
        let line = self.make_grid_line(
            ctx,
            Coord::new(canvas_left, canvas_bottom),
            Direction::Horizontal,
            &grid_gradient_mapping,
        )?;
        self.grid_lines.push(line);
        let line = self.make_grid_line(
            ctx,
            Coord::new(canvas_left, canvas_top),
            Direction::Horizontal,
            &grid_gradient_mapping,
        )?;
        self.grid_lines.push(line);
        let line = self.make_grid_line(
            ctx,
            Coord::new(canvas_left, canvas_bottom),
            Direction::Vertical,
            &grid_gradient_mapping,
        )?;
        self.grid_lines.push(line);
        let line = self.make_grid_line(
            ctx,
            Coord::new(canvas_right, canvas_bottom),
            Direction::Vertical,
            &grid_gradient_mapping,
        )?;
        self.grid_lines.push(line);

        let mut column_indexes: Vec<i64> = Vec::new();
        let mut row_indexes: Vec<i64> = Vec::new();
        let (row_gap, column_gap) = if canvas_top > 2 * canvas_right {
            let row_gap = Self::find_even_gap(canvas_top) + 1;
            (row_gap, row_gap * 2)
        } else {
            let column_gap = Self::find_even_gap(canvas_right) + 1;
            (floor_div(column_gap, 2), column_gap)
        };

        // range(bottom + row_gap, top, max(row_gap, 1))
        let row_step = std::cmp::max(row_gap, 1);
        let mut row_index = canvas_bottom + row_gap;
        while row_index < canvas_top {
            if canvas_top - row_index >= 2 {
                row_indexes.push(row_index);
                let line = self.make_grid_line(
                    ctx,
                    Coord::new(canvas_left, row_index),
                    Direction::Horizontal,
                    &grid_gradient_mapping,
                )?;
                self.grid_lines.push(line);
            }
            row_index += row_step;
        }
        // range(left + column_gap, right, max(column_gap, 1))
        let column_step = std::cmp::max(column_gap, 1);
        let mut column_index = canvas_left + column_gap;
        while column_index < canvas_right {
            if canvas_right - column_index >= 2 {
                column_indexes.push(column_index);
                let line = self.make_grid_line(
                    ctx,
                    Coord::new(column_index, canvas_bottom),
                    Direction::Vertical,
                    &grid_gradient_mapping,
                )?;
                self.grid_lines.push(line);
            }
            column_index += column_step;
        }
        row_indexes.push(canvas_top + 1);
        column_indexes.push(canvas_right + 1);
        let mut prev_row_index = 1i64;
        for &row_index_value in &row_indexes {
            // row_index is reassigned inside the column loop (noqa: PLW2901
            // upstream) and the mutated value flows into prev_row_index.
            let mut row_index = row_index_value;
            let mut prev_column_index = 1i64;
            for &column_index in &column_indexes {
                let mut coords_in_block: Vec<Coord> = Vec::new();
                if row_index == canvas_top {
                    // make sure the top row is included
                    row_index += 1;
                }
                for row in prev_row_index..row_index {
                    for column in prev_column_index..column_index {
                        coords_in_block.push(Coord::new(column, row));
                    }
                }
                let mut characters_in_block: Vec<CharId> = Vec::new();
                for coord in &coords_in_block {
                    if let Some(&id) = ctx.terminal.character_by_input_coord.get(coord) {
                        characters_in_block.push(id);
                    }
                }
                if !characters_in_block.is_empty() {
                    self.pending_groups.push((self.pending_groups.len() as i64, characters_in_block));
                }
                prev_column_index = column_index;
            }
            prev_row_index = row_index;
        }

        self.group_tracker = vec![0; self.pending_groups.len()];
        let pending_groups = std::mem::take(&mut self.pending_groups);
        for (group_number, group) in &pending_groups {
            for &character in group {
                let (input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[character.0 as usize];
                    (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                let dissolve_scn =
                    ctx.terminal.arena[character.0 as usize].animation.new_scene(false, None, None, "", uses_pre);
                let frame_count = ctx.rng.randint(15, 30);
                for _ in 0..frame_count {
                    let symbol = ctx.rng.choice(&self.config.text_generation_symbols).clone();
                    let fg = ctx.rng.choice(&text_gradient.spectrum).clone();
                    ctx.terminal.arena[character.0 as usize]
                        .animation
                        .scenes
                        .get_mut(&dissolve_scn)
                        .unwrap()
                        .add_frame(
                            &symbol,
                            2,
                            VisualParams { colors: Some(ColorPair::new(Some(fg), None)), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
                let final_colors = self.character_final_color_map.get(&character).cloned().unwrap_or_default();
                ctx.terminal.arena[character.0 as usize]
                    .animation
                    .scenes
                    .get_mut(&dissolve_scn)
                    .unwrap()
                    .add_frame(
                        &input_symbol,
                        1,
                        VisualParams { colors: Some(final_colors), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
                ctx.activate_scene(self, character, &dissolve_scn);
                ctx.register_event(
                    character,
                    Event::SceneComplete,
                    CallerKey::Scene(dissolve_scn.clone()),
                    EventAction::Callback(EffectCallback {
                        id: CB_UPDATE_GROUP_TRACKER,
                        args: vec![CallbackValue::Int(*group_number)],
                    }),
                )
                .map_err(EngineError::Other)?;
            }
        }
        self.pending_groups = pending_groups;
        ctx.rng.shuffle(&mut self.pending_groups);
        self.phase = Phase::GridExpand;
        self.total_group_count = self.pending_groups.len();
        if self.total_group_count == 0 {
            let characters = ctx.terminal.get_characters(
                &mut ctx.rng,
                CharacterFilter::default(),
                CharacterSort::TopToBottomLeftToRight,
            );
            for character in characters {
                ctx.terminal.set_character_visibility(character, true);
                ctx.active_characters.insert(character);
            }
        }
        self.active_groups = 0;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_groups.is_empty() || !ctx.active_characters.is_empty() || self.phase != Phase::Complete {
            match self.phase {
                Phase::GridExpand => {
                    if !self.grid_lines.iter().all(|grid_line| grid_line.is_extended()) {
                        let mut grid_lines = std::mem::take(&mut self.grid_lines);
                        for grid_line in &mut grid_lines {
                            if !grid_line.is_extended() {
                                grid_line.extend(ctx);
                            }
                        }
                        self.grid_lines = grid_lines;
                    } else {
                        self.phase = Phase::AddChars;
                    }
                }
                Phase::AddChars => {
                    if !self.pending_groups.is_empty()
                        && (self.active_groups as f64)
                            < self.total_group_count as f64 * self.config.max_active_blocks
                    {
                        let (group_number, next_group) = self.pending_groups.remove(0);
                        for &ch in &next_group {
                            ctx.terminal.set_character_visibility(ch, true);
                            ctx.active_characters.insert(ch);
                            self.group_tracker[group_number as usize] += 1;
                        }
                    }
                    if self.pending_groups.is_empty()
                        && ctx.active_characters.is_empty()
                        && self.active_groups == 0
                    {
                        self.phase = Phase::Collapse;
                    }
                }
                Phase::Collapse => {
                    if !self.grid_lines.iter().all(|grid_line| grid_line.is_collapsed()) {
                        let mut grid_lines = std::mem::take(&mut self.grid_lines);
                        for grid_line in &mut grid_lines {
                            if !grid_line.is_collapsed() {
                                grid_line.collapse(ctx);
                            }
                        }
                        self.grid_lines = grid_lines;
                    } else {
                        self.phase = Phase::Complete;
                    }
                }
                Phase::Complete => {}
            }
            ctx.update(self);
            self.active_groups = 0;
            for &active_count in &self.group_tracker {
                if active_count != 0 {
                    self.active_groups += 1;
                }
            }
            return Some(ctx.frame());
        }
        None
    }
}
