//! matrix, ported from effects/effect_matrix.py.
//!
//! THE CLOCK EFFECT: upstream reads time.time() at effect_matrix.py:430
//! (rain_start, set after build) and :549 (rain-phase deadline check). Both
//! sites use ctx.clock.now_wall(); the parity harness virtualizes the clock
//! on both sides (plan.md §4.7).
//!
//! The inner RainColumn class is the `RainColumn` struct. Columns migrate
//! between pending/active/full lists and are compared by identity upstream
//! (`column not in self.full_columns`), so ttfx keeps them in a Vec arena and
//! the lists hold indices. No observable set iteration beyond the
//! engine-canonical active_characters (docs/ordering-inventory.md).

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_positive_float, parse_positive_int,
    parse_positive_int_range, parse_symbol,
};
use crate::engine::animation::{Animation, ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::floor_div;

#[derive(Args, Debug, Clone)]
pub struct MatrixConfig {
    /// Color for the bottom of the rain column.
    #[arg(long = "highlight-color", default_value = "dbffdb", value_parser = parse_color)]
    pub highlight_color: Color,

    /// Space separated, unquoted, list of colors for the rain gradient. Colors are selected from the gradient randomly. If only one color is provided, the characters will be displayed in that color.
    #[arg(long = "rain-color-gradient", num_args = 1.., value_parser = parse_color,
          default_values = ["92be92", "185318"])]
    pub rain_color_gradient: Vec<Color>,

    /// Space separated, unquoted, list of symbols to use for the rain.
    #[arg(long = "rain-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = [
              "2", "5", "9", "8", "Z", "*", ")", ":", ".", "\"", "=", "+", "-", "¦", "|", "_",
              "ｦ", "ｱ", "ｳ", "ｴ", "ｵ", "ｶ", "ｷ", "ｹ", "ｺ", "ｻ", "ｼ", "ｽ", "ｾ", "ｿ", "ﾀ", "ﾂ",
              "ﾃ", "ﾅ", "ﾆ", "ﾇ", "ﾈ", "ﾊ", "ﾋ", "ﾎ", "ﾏ", "ﾐ", "ﾑ", "ﾒ", "ﾓ", "ﾔ", "ﾕ", "ﾗ",
              "ﾘ", "ﾜ",
          ])]
    pub rain_symbols: Vec<String>,

    /// Range for the speed of the falling rain as determined by the delay between rows. Actual delay is randomly selected from the range.
    #[arg(long = "rain-fall-delay-range", default_value = "2-15", value_parser = parse_positive_int_range)]
    pub rain_fall_delay_range: (i64, i64),

    /// Range of frames to wait between adding new rain columns.
    #[arg(long = "rain-column-delay-range", default_value = "3-9", value_parser = parse_positive_int_range)]
    pub rain_column_delay_range: (i64, i64),

    /// Time, in seconds, to display the rain effect before transitioning to the input text.
    #[arg(long = "rain-time", default_value_t = 15, value_parser = parse_positive_int)]
    pub rain_time: i64,

    /// Chance of swapping a character's symbol on each tick.
    #[arg(long = "symbol-swap-chance", default_value_t = 0.005, value_parser = parse_positive_float)]
    pub symbol_swap_chance: f64,

    /// Chance of swapping a character's color on each tick.
    #[arg(long = "color-swap-chance", default_value_t = 0.001, value_parser = parse_positive_float)]
    pub color_swap_chance: f64,

    /// Number of frames to wait between resolving the next group of characters. This is used to adjust the speed of the final resolve phase.
    #[arg(long = "resolve-delay", default_value_t = 3, value_parser = parse_positive_int)]
    pub resolve_delay: i64,

    /// Space separated, unquoted, list of colors for the character gradient (applied from bottom to top). If only one color is provided, the characters will be displayed in that color.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["92be92", "336b33"])]
    pub final_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, list of the number of gradient steps to use. More steps will create a smoother and longer gradient animation.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step. Increase to slow down the gradient animation.
    #[arg(long = "final-gradient-frames", default_value_t = 3, value_parser = parse_positive_int)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "radial", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// Animation.set_appearance shorthand (upstream character.animation.set_appearance).
fn set_appearance(ctx: &mut EngineCtx, id: CharId, symbol: &str, colors: ColorPair) {
    let ch = &mut ctx.terminal.arena[id.0 as usize];
    let uses_pre = ch.uses_input_preexisting_colors;
    ch.animation.set_appearance(&ch.input_symbol, uses_pre, Some(symbol), Some(colors));
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ColumnPhase {
    Rain,
    Fill,
}

/// MatrixIterator.RainColumn.
struct RainColumn {
    characters: Vec<CharId>,
    pending_characters: Vec<CharId>,
    visible_characters: Vec<CharId>,
    phase: ColumnPhase,
    column_drop_chance: f64,
    base_rain_fall_delay: i64,
    active_rain_fall_delay: i64,
    length: usize,
    hold_time: i64,
}

impl RainColumn {
    /// RainColumn.__init__ (calls setup_column("rain")).
    fn new(ctx: &mut EngineCtx, config: &MatrixConfig, characters: Vec<CharId>) -> Self {
        let mut column = RainColumn {
            characters,
            pending_characters: Vec::new(),
            visible_characters: Vec::new(),
            phase: ColumnPhase::Rain,
            column_drop_chance: 0.08,
            base_rain_fall_delay: 0,
            active_rain_fall_delay: 0,
            length: 0,
            hold_time: 0,
        };
        column.setup_column(ctx, config, ColumnPhase::Rain);
        column
    }

    /// RainColumn.setup_column.
    fn setup_column(&mut self, ctx: &mut EngineCtx, config: &MatrixConfig, phase: ColumnPhase) {
        self.pending_characters.clear();
        self.phase = phase;
        for &character in &self.characters {
            ctx.terminal.set_character_visibility(character, false);
            self.pending_characters.push(character);
            let ch = &mut ctx.terminal.arena[character.0 as usize];
            ch.motion.current_coord = ch.input_coord;
        }
        self.visible_characters = Vec::new();
        self.base_rain_fall_delay = if self.phase == ColumnPhase::Fill {
            ctx.rng.randint(
                std::cmp::max(floor_div(config.rain_fall_delay_range.0, 3), 1),
                std::cmp::max(floor_div(config.rain_fall_delay_range.1, 3), 1),
            )
        } else {
            ctx.rng.randint(config.rain_fall_delay_range.0, config.rain_fall_delay_range.1)
        };
        self.active_rain_fall_delay = 0;
        self.length = if self.phase == ColumnPhase::Rain {
            ctx.rng.randint(
                std::cmp::max(1, (self.characters.len() as f64 * 0.1) as i64),
                self.characters.len() as i64,
            ) as usize
        } else {
            self.characters.len()
        };
        self.hold_time = 0;
        if self.length == self.characters.len() {
            self.hold_time = ctx.rng.randint(20, 45);
        }
    }

    /// RainColumn.trim_column.
    fn trim_column(&mut self, ctx: &mut EngineCtx, rain_colors: &[Color]) {
        if self.visible_characters.is_empty() {
            return;
        }
        let popped_char = self.visible_characters.remove(0);
        ctx.terminal.set_character_visibility(popped_char, false);
        if self.visible_characters.len() > 1 {
            self.fade_last_character(ctx, rain_colors);
        }
    }

    /// RainColumn.drop_column.
    fn drop_column(&mut self, ctx: &mut EngineCtx) {
        let canvas_bottom = ctx.terminal.canvas.bottom;
        let mut out_of_canvas: Vec<CharId> = Vec::new();
        for &character in &self.visible_characters {
            let new_coord = {
                let motion = &mut ctx.terminal.arena[character.0 as usize].motion;
                let current = motion.current_coord;
                motion.current_coord = Coord::new(current.column, current.row - 1);
                motion.current_coord
            };
            if new_coord.row < canvas_bottom {
                ctx.terminal.set_character_visibility(character, false);
                out_of_canvas.push(character);
            }
        }
        self.visible_characters.retain(|ch| !out_of_canvas.contains(ch));
    }

    /// RainColumn.fade_last_character.
    fn fade_last_character(&mut self, ctx: &mut EngineCtx, rain_colors: &[Color]) {
        // random.choice(self.rain_colors[-3:])
        let tail = &rain_colors[rain_colors.len().saturating_sub(3)..];
        let darker_color = Animation::adjust_color_brightness(ctx.rng.choice(tail), 0.65);
        let target = self.visible_characters[0];
        let symbol = ctx.terminal.arena[target.0 as usize].animation.current_character_visual.symbol.clone();
        set_appearance(ctx, target, &symbol, ColorPair::new(Some(darker_color), None));
    }

    /// RainColumn.resolve_char.
    fn resolve_char(&mut self, ctx: &mut EngineCtx) -> CharId {
        let index = ctx.rng.randint(0, self.visible_characters.len() as i64 - 1) as usize;
        self.visible_characters.remove(index)
    }

    /// RainColumn.tick.
    fn tick(&mut self, ctx: &mut EngineCtx, config: &MatrixConfig, rain_colors: &[Color]) {
        if self.active_rain_fall_delay == 0 {
            if !self.pending_characters.is_empty() {
                let next_char = self.pending_characters.remove(0);
                let symbol = ctx.rng.choice(&config.rain_symbols).clone();
                set_appearance(
                    ctx,
                    next_char,
                    &symbol,
                    ColorPair::new(Some(config.highlight_color.clone()), None),
                );
                let previous_character = self.visible_characters.last().copied();
                // if there is a previous character, remove the highlight
                if let Some(previous_character) = previous_character {
                    let prev_symbol = ctx.terminal.arena[previous_character.0 as usize]
                        .animation
                        .current_character_visual
                        .symbol
                        .clone();
                    let fg = ctx.rng.choice(rain_colors).clone();
                    set_appearance(ctx, previous_character, &prev_symbol, ColorPair::new(Some(fg), None));
                }
                ctx.terminal.set_character_visibility(next_char, true);
                self.visible_characters.push(next_char);
            } else if !self.visible_characters.is_empty() {
                // adjust the bottom character color to remove the highlight
                let last_char = *self.visible_characters.last().unwrap();
                let last_is_highlight = {
                    let visual = &ctx.terminal.arena[last_char.0 as usize].animation.current_character_visual;
                    visual
                        .colors
                        .as_ref()
                        .is_some_and(|colors| colors.fg_color.as_ref() == Some(&config.highlight_color))
                };
                if last_is_highlight {
                    let symbol = ctx.terminal.arena[last_char.0 as usize]
                        .animation
                        .current_character_visual
                        .symbol
                        .clone();
                    let fg = ctx.rng.choice(rain_colors).clone();
                    set_appearance(ctx, last_char, &symbol, ColorPair::new(Some(fg), None));
                }

                if self.hold_time != 0 {
                    self.hold_time -= 1;
                } else if self.phase == ColumnPhase::Rain {
                    if ctx.rng.random() < self.column_drop_chance {
                        self.drop_column(ctx);
                    }
                    self.trim_column(ctx, rain_colors);
                }
            }

            // if the column is longer than the preset length while still adding characters, trim it
            if self.visible_characters.len() > self.length {
                self.trim_column(ctx, rain_colors);
            }
            self.active_rain_fall_delay = self.base_rain_fall_delay;
        } else {
            self.active_rain_fall_delay -= 1;
        }

        // randomly change the symbol and/or color of the characters
        for &character in &self.visible_characters {
            // Draw both chances (and any resulting choices) in upstream order,
            // but leave the cached visual alone when neither value changes.
            let next_symbol = if ctx.rng.random() < config.symbol_swap_chance {
                Some(ctx.rng.choice(&config.rain_symbols).as_str())
            } else {
                None
            };
            let next_color = if ctx.rng.random() < config.color_swap_chance {
                Some(ctx.rng.choice(rain_colors))
            } else {
                None
            };
            if next_symbol.is_none() && next_color.is_none() {
                continue;
            }

            let values_unchanged = {
                let visual = &ctx.terminal.arena[character.0 as usize].animation.current_character_visual;
                next_symbol.is_none_or(|symbol| symbol == visual.symbol)
                    && next_color.is_none_or(|color| {
                        visual.colors.as_ref().and_then(|colors| colors.fg_color.as_ref()) == Some(color)
                    })
            };
            if values_unchanged {
                continue;
            }

            match (next_symbol, next_color) {
                (Some(symbol), Some(color)) => {
                    set_appearance(ctx, character, symbol, ColorPair::new(Some(color.clone()), None));
                }
                (Some(symbol), None) => {
                    let color = ctx.terminal.arena[character.0 as usize]
                        .animation
                        .current_character_visual
                        .colors
                        .as_ref()
                        .and_then(|colors| colors.fg_color.clone());
                    set_appearance(ctx, character, symbol, ColorPair::new(color, None));
                }
                (None, Some(color)) => {
                    let symbol = ctx.terminal.arena[character.0 as usize]
                        .animation
                        .current_character_visual
                        .symbol
                        .clone();
                    set_appearance(ctx, character, &symbol, ColorPair::new(Some(color.clone()), None));
                }
                (None, None) => unreachable!("no-change case returned above"),
            }
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Rain,
    Fill,
    Resolve,
}

pub struct Matrix {
    config: MatrixConfig,
    /// Column arena; pending/active/full hold indices (identity semantics).
    columns: Vec<RainColumn>,
    pending_columns: Vec<usize>,
    active_columns: Vec<usize>,
    full_columns: Vec<usize>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    /// Gradient(*rain_color_gradient, steps=6).spectrum.
    rain_colors: Vec<Color>,
    column_delay: i64,
    resolve_delay: i64,
    final_frame_shown: bool,
    rain_complete: bool,
    phase: Phase,
    /// time.time() taken after build (effect_matrix.py:430).
    rain_start: f64,
}

impl Matrix {
    pub fn new(config: MatrixConfig) -> Self {
        let resolve_delay = config.resolve_delay;
        Matrix {
            config,
            columns: Vec::new(),
            pending_columns: Vec::new(),
            active_columns: Vec::new(),
            full_columns: Vec::new(),
            character_final_color_map: HashMap::new(),
            rain_colors: Vec::new(),
            column_delay: 0,
            resolve_delay,
            final_frame_shown: false,
            rain_complete: false,
            phase: Phase::Rain,
            rain_start: 0.0,
        }
    }

    /// MatrixIterator._has_input_colors.
    fn has_input_colors(ctx: &EngineCtx, character: CharId) -> bool {
        let anim = &ctx.terminal.arena[character.0 as usize].animation;
        anim.input_fg_color.is_some() || anim.input_bg_color.is_some()
    }

    fn column_phase_for(&self) -> ColumnPhase {
        match self.phase {
            Phase::Rain => ColumnPhase::Rain,
            Phase::Fill => ColumnPhase::Fill,
            Phase::Resolve => unreachable!("columns are never set up during resolve"),
        }
    }
}

impl EffectHooks for Matrix {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Matrix {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // __init__: rain_colors gradient (no RNG consumed)
        self.rain_colors =
            Gradient::with_steps(&self.config.rain_color_gradient, 6, false).map_err(EngineError::Other)?.spectrum;

        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters =
            ctx.terminal.get_characters(&mut ctx.rng, CharacterFilter::default(), CharacterSort::TopToBottomLeftToRight);
        for character in characters {
            let (input_symbol, input_coord, input_fg, input_bg, uses_pre) = {
                let ch = &ctx.terminal.arena[character.0 as usize];
                (
                    ch.input_symbol.clone(),
                    ch.input_coord,
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
            self.character_final_color_map.insert(character, final_colors.clone());
            let final_fg_color = final_colors.fg_color.clone();
            let final_bg_color = final_colors.bg_color.clone();
            let resolve_scn = ctx.terminal.arena[character.0 as usize]
                .animation
                .new_scene(false, None, None, "resolve", uses_pre);
            if dynamic {
                let fg_gradient = match &final_fg_color {
                    Some(fg) => Some(
                        Gradient::with_steps(&[self.config.highlight_color.clone(), fg.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &final_bg_color {
                    Some(bg) => Some(
                        Gradient::with_steps(&[self.config.highlight_color.clone(), bg.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let scene = ctx.terminal.arena[character.0 as usize]
                    .animation
                    .scenes
                    .get_mut(&resolve_scn)
                    .unwrap();
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            self.config.final_gradient_frames,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.final_gradient_frames,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_fg_color = final_fg_color.expect("non-dynamic final fg color");
                let resolve_gradient =
                    Gradient::with_steps(&[self.config.highlight_color.clone(), final_fg_color], 8, false)
                        .map_err(EngineError::Other)?;
                for color in &resolve_gradient.spectrum {
                    ctx.terminal.arena[character.0 as usize]
                        .animation
                        .scenes
                        .get_mut(&resolve_scn)
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            self.config.final_gradient_frames,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
        }

        let all_chars_filter = CharacterFilter {
            input_chars: true,
            inner_fill_chars: true,
            outer_fill_chars: true,
            added_chars: false,
        };
        for mut column_chars in
            ctx.terminal.get_characters_grouped(all_chars_filter, CharacterGroup::ColumnLeftToRight)
        {
            column_chars.reverse();
            let column = RainColumn::new(ctx, &self.config, column_chars);
            self.columns.push(column);
            self.pending_columns.push(self.columns.len() - 1);
        }
        ctx.rng.shuffle(&mut self.pending_columns);

        // MatrixIterator.__init__: rain_start = time.time() (after build).
        self.rain_start = ctx.clock.now_wall();
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.phase == Phase::Rain || self.phase == Phase::Fill {
            if self.column_delay == 0 {
                if self.phase == Phase::Rain {
                    for _ in 0..ctx.rng.randint(1, 3) {
                        if !self.pending_columns.is_empty() {
                            self.active_columns.push(self.pending_columns.remove(0));
                        }
                    }
                } else {
                    while !self.pending_columns.is_empty() {
                        self.active_columns.push(self.pending_columns.remove(0));
                    }
                }
                self.column_delay = if self.phase == Phase::Rain {
                    ctx.rng.randint(self.config.rain_column_delay_range.0, self.config.rain_column_delay_range.1)
                } else {
                    1
                };
            } else {
                self.column_delay -= 1;
            }
            let active_snapshot = self.active_columns.clone();
            for column_index in active_snapshot {
                {
                    let (columns, config, rain_colors) = (&mut self.columns, &self.config, &self.rain_colors);
                    columns[column_index].tick(ctx, config, rain_colors);
                }

                if self.columns[column_index].pending_characters.is_empty() {
                    if self.columns[column_index].phase == ColumnPhase::Fill
                        && !self.full_columns.contains(&column_index)
                    {
                        self.full_columns.push(column_index);
                    } else if self.columns[column_index].visible_characters.is_empty() {
                        let column_phase = self.column_phase_for();
                        let (columns, config) = (&mut self.columns, &self.config);
                        columns[column_index].setup_column(ctx, config, column_phase);
                        self.pending_columns.push(column_index);
                    }
                }
            }

            {
                let columns = &self.columns;
                self.active_columns.retain(|&ci| !columns[ci].visible_characters.is_empty());
            }
            if self.phase == Phase::Fill
                && self.pending_columns.is_empty()
                && self.active_columns.iter().all(|&ci| {
                    self.columns[ci].pending_characters.is_empty() && self.columns[ci].phase == ColumnPhase::Fill
                })
            {
                self.phase = Phase::Resolve;
                self.active_columns.clear();
            }

            // effect_matrix.py:549 — time.time() rain deadline check.
            if self.phase == Phase::Rain
                && self.config.rain_time > 0
                && ctx.clock.now_wall() - self.rain_start > self.config.rain_time as f64
            {
                self.rain_complete = true;
                self.phase = Phase::Fill;
                for &ci in &self.active_columns {
                    self.columns[ci].hold_time = 0;
                    self.columns[ci].column_drop_chance = 1.0;
                }
                let pending_snapshot = self.pending_columns.clone();
                for ci in pending_snapshot {
                    let (columns, config) = (&mut self.columns, &self.config);
                    columns[ci].setup_column(ctx, config, ColumnPhase::Fill);
                }
            }
        } else if self.phase == Phase::Resolve {
            let full_snapshot = self.full_columns.clone();
            for column_index in full_snapshot {
                {
                    let (columns, config, rain_colors) = (&mut self.columns, &self.config, &self.rain_colors);
                    columns[column_index].tick(ctx, config, rain_colors);
                }
                if !self.columns[column_index].visible_characters.is_empty() {
                    if self.resolve_delay == 0 {
                        for _ in 0..ctx.rng.randint(1, 4) {
                            if !self.columns[column_index].visible_characters.is_empty() {
                                let next_char = self.columns[column_index].resolve_char(ctx);
                                let input_symbol =
                                    ctx.terminal.arena[next_char.0 as usize].input_symbol.clone();
                                if input_symbol != " " || Self::has_input_colors(ctx, next_char) {
                                    ctx.activate_scene(self, next_char, "resolve");
                                    ctx.active_characters.insert(next_char);
                                } else {
                                    ctx.terminal.set_character_visibility(next_char, false);
                                }
                            }
                        }
                        self.resolve_delay = self.config.resolve_delay;
                    } else {
                        self.resolve_delay -= 1;
                    }
                }
            }
            {
                let columns = &self.columns;
                self.full_columns.retain(|&ci| !columns[ci].visible_characters.is_empty());
            }
        }

        if !self.full_columns.is_empty()
            || !self.active_columns.is_empty()
            || !ctx.active_characters.is_empty()
            || !self.pending_columns.is_empty()
            || !self.rain_complete
        {
            ctx.update(self);
            return Some(ctx.frame());
        }
        if !self.final_frame_shown {
            self.final_frame_shown = true;
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
