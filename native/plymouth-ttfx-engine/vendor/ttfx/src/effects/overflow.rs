//! overflow, ported from effects/effect_overflow.py.

use std::collections::{HashMap, VecDeque};

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_positive_int, parse_positive_int_range,
};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::floor_div;

#[derive(Args, Debug, Clone)]
pub struct OverflowConfig {
    /// Space separated, unquoted, list of colors for the overflow gradient.
    #[arg(long = "overflow-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["f2ebc0", "8dbfb3", "f2ebc0"])]
    pub overflow_gradient_stops: Vec<Color>,

    /// Number of cycles to overflow the text.
    #[arg(long = "overflow-cycles-range", default_value = "2-4", value_parser = parse_positive_int_range)]
    pub overflow_cycles_range: (i64, i64),

    /// Speed of the overflow effect.
    #[arg(long = "overflow-speed", default_value_t = 3, value_parser = parse_positive_int)]
    pub overflow_speed: i64,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// OverflowIterator.Row.
struct Row {
    characters: Vec<CharId>,
    final_: bool,
}

impl Row {
    /// Row.move_up.
    fn move_up(&self, ctx: &mut EngineCtx) {
        for &id in &self.characters {
            let motion = &mut ctx.terminal.arena[id.0 as usize].motion;
            let current = motion.current_coord;
            motion.set_coordinate(Coord::new(current.column, current.row + 1));
        }
    }

    /// Row.setup.
    fn setup(&self, ctx: &mut EngineCtx) {
        for &id in &self.characters {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let column = ch.input_coord.column;
            ch.motion.set_coordinate(Coord::new(column, 0));
        }
    }

    /// Row.set_color.
    fn set_color(&self, ctx: &mut EngineCtx, fg_color: Option<Color>, bg_color: Option<Color>) {
        for &id in &self.characters {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let uses_pre = ch.uses_input_preexisting_colors;
            ch.animation.set_appearance(
                &ch.input_symbol,
                uses_pre,
                None,
                Some(ColorPair::new(fg_color.clone(), bg_color.clone())),
            );
        }
    }
}

pub struct Overflow {
    config: OverflowConfig,
    pending_rows: VecDeque<Row>,
    active_rows: Vec<Row>,
    character_final_color_map: HashMap<CharId, Color>,
    delay: i64,
    overflow_gradient: Option<Gradient>,
}

impl Overflow {
    pub fn new(config: OverflowConfig) -> Self {
        Overflow {
            config,
            pending_rows: VecDeque::new(),
            active_rows: Vec::new(),
            character_final_color_map: HashMap::new(),
            delay: 0,
            overflow_gradient: None,
        }
    }
}

impl EffectHooks for Overflow {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Overflow {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let fills_filter =
            CharacterFilter { inner_fill_chars: true, outer_fill_chars: true, ..Default::default() };
        let characters = ctx.terminal.get_characters(
            &mut ctx.rng,
            fills_filter,
            crate::engine::terminal::CharacterSort::TopToBottomLeftToRight,
        );
        for &id in &characters {
            let coord = ctx.terminal.arena[id.0 as usize].input_coord;
            let color = final_gradient_mapping
                .get(&coord)
                .cloned()
                .unwrap_or_else(|| Color::from_hex("000000").unwrap());
            self.character_final_color_map.insert(id, color);
        }
        let (lower_range, upper_range) = self.config.overflow_cycles_range;
        let mut rows =
            ctx.terminal.get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowTopToBottom);
        if upper_range > 0 {
            for _ in 0..ctx.rng.randint(lower_range, upper_range) {
                ctx.rng.shuffle(&mut rows);
                for row in &rows {
                    let mut copied_characters: Vec<CharId> = Vec::new();
                    // copy the character attributes to new characters
                    for &id in row {
                        let (symbol, coord, fg_seq, bg_seq, no_color, use_xterm, input_fg, input_bg) = {
                            let ch = &ctx.terminal.arena[id.0 as usize];
                            (
                                ch.input_symbol.clone(),
                                ch.input_coord,
                                ch.input_ansi_fg_sequence.clone(),
                                ch.input_ansi_bg_sequence.clone(),
                                ch.animation.no_color,
                                ch.animation.use_xterm_colors,
                                ch.animation.input_fg_color.clone(),
                                ch.animation.input_bg_color.clone(),
                            )
                        };
                        let copy_id = ctx.terminal.add_character(&symbol, coord);
                        let copy = &mut ctx.terminal.arena[copy_id.0 as usize];
                        copy.animation.existing_color_handling = ctx.terminal.config.existing_color_handling;
                        copy.uses_input_preexisting_colors = true;
                        copy.input_ansi_fg_sequence = fg_seq;
                        copy.input_ansi_bg_sequence = bg_seq;
                        copy.animation.no_color = no_color;
                        copy.animation.use_xterm_colors = use_xterm;
                        copy.animation.input_fg_color = input_fg;
                        copy.animation.input_bg_color = input_bg;
                        copied_characters.push(copy_id);
                    }
                    self.pending_rows.push_back(Row { characters: copied_characters, final_: false });
                }
            }
        }
        // add rows in correct order to the end of pending_rows
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        for row in ctx.terminal.get_characters_grouped(fills_filter, CharacterGroup::RowTopToBottom) {
            for &id in &row {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let current_symbol = ch.animation.current_character_visual.symbol.clone();
                let input_symbol = ch.input_symbol.clone();
                let uses_pre = ch.uses_input_preexisting_colors;
                if dynamic {
                    let input_fg = ch.animation.input_fg_color.clone();
                    let input_bg = ch.animation.input_bg_color.clone();
                    if input_fg.is_some() || input_bg.is_some() {
                        ch.animation.set_appearance(
                            &input_symbol,
                            uses_pre,
                            Some(&current_symbol),
                            Some(ColorPair::new(input_fg, input_bg)),
                        );
                    } else {
                        ch.animation.set_appearance(
                            &input_symbol,
                            uses_pre,
                            Some(&current_symbol),
                            Some(ColorPair::default()),
                        );
                    }
                } else {
                    let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                    ch.animation.set_appearance(
                        &input_symbol,
                        uses_pre,
                        Some(&current_symbol),
                        Some(ColorPair::new(Some(final_color), None)),
                    );
                }
            }
            self.pending_rows.push_back(Row { characters: row, final_: true });
        }
        self.delay = 0;
        let steps = std::cmp::max(
            floor_div(
                ctx.terminal.canvas.top,
                std::cmp::max(1, self.config.overflow_gradient_stops.len() as i64 - 1),
            ),
            1,
        );
        self.overflow_gradient = Some(
            Gradient::with_steps(&self.config.overflow_gradient_stops, steps, false)
                .map_err(EngineError::Other)?,
        );
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.pending_rows.is_empty() {
            if self.delay == 0 {
                let spectrum = &self.overflow_gradient.as_ref().unwrap().spectrum;
                for _ in 0..ctx.rng.randint(1, self.config.overflow_speed) {
                    if !self.pending_rows.is_empty() {
                        for row in &self.active_rows {
                            row.move_up(ctx);
                            if !row.final_ {
                                let head_row =
                                    ctx.terminal.arena[row.characters[0].0 as usize].motion.current_coord.row;
                                let index = std::cmp::min(head_row, spectrum.len() as i64 - 1) as usize;
                                row.set_color(ctx, Some(spectrum[index].clone()), None);
                            }
                        }
                        let next_row = self.pending_rows.pop_front().unwrap();
                        next_row.setup(ctx);
                        next_row.move_up(ctx);
                        if !next_row.final_ {
                            next_row.set_color(ctx, Some(spectrum[0].clone()), None);
                        }
                        for &id in &next_row.characters {
                            ctx.terminal.set_character_visibility(id, true);
                        }
                        self.active_rows.push(next_row);
                    }
                }
                self.delay = ctx.rng.randint(0, 3);
            } else {
                self.delay -= 1;
            }
            let canvas_top = ctx.terminal.canvas.top;
            let arena = &ctx.terminal.arena;
            self.active_rows
                .retain(|row| arena[row.characters[0].0 as usize].motion.current_coord.row <= canvas_top);
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
