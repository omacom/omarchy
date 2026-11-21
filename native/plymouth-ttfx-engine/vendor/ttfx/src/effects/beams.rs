//! beams, ported from effects/effect_beams.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_positive_int, parse_positive_int_range, parse_symbol,
};
use crate::engine::animation::{Animation, ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct BeamsConfig {
    /// Symbols to use for the beam effect when moving along a row. Strings will be used in sequence to create an animation.
    #[arg(long = "beam-row-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["▂", "▁", "_"])]
    pub beam_row_symbols: Vec<String>,

    /// Symbols to use for the beam effect when moving along a column. Strings will be used in sequence to create an animation.
    #[arg(long = "beam-column-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["▌", "▍", "▎", "▏"])]
    pub beam_column_symbols: Vec<String>,

    /// Number of frames to wait before adding the next group of beams. Beams are added in groups of size random(1, 5).
    #[arg(long = "beam-delay", default_value_t = 6, value_parser = parse_positive_int)]
    pub beam_delay: i64,

    /// Speed range of the beam when moving along a row.
    #[arg(long = "beam-row-speed-range", default_value = "15-60", value_parser = parse_positive_int_range)]
    pub beam_row_speed_range: (i64, i64),

    /// Speed range of the beam when moving along a column.
    #[arg(long = "beam-column-speed-range", default_value = "9-15", value_parser = parse_positive_int_range)]
    pub beam_column_speed_range: (i64, i64),

    /// Space separated, unquoted, list of colors for the beam, a gradient will be created between the colors.
    #[arg(long = "beam-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ffffff", "00D1FF", "8A008A"])]
    pub beam_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, numbers for the of gradient steps to use.
    #[arg(long = "beam-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["2", "6"])]
    pub beam_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step. Increase to slow down the gradient animation.
    #[arg(long = "beam-gradient-frames", default_value_t = 2, value_parser = parse_positive_int)]
    pub beam_gradient_frames: i64,

    /// Space separated, unquoted, list of colors for the wipe gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "ffffff"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step. Increase to slow down the gradient animation.
    #[arg(long = "final-gradient-frames", default_value_t = 4, value_parser = parse_positive_int)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,

    /// Speed of the final wipe as measured in diagonal groups activated per frame.
    #[arg(long = "final-wipe-speed", default_value_t = 3, value_parser = parse_positive_int)]
    pub final_wipe_speed: i64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Direction {
    Row,
    Column,
}

/// BeamsIterator.Group state (get_next_character lives on Beams for hooks access).
struct Group {
    characters: Vec<CharId>,
    direction: Direction,
    speed: f64,
    next_character_counter: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Beams,
    FinalWipe,
    Complete,
}

pub struct Beams {
    config: BeamsConfig,
    pending_groups: Vec<Group>,
    active_groups: Vec<Group>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    final_wipe_groups: Vec<Vec<CharId>>,
    delay: i64,
    phase: Phase,
}

impl Beams {
    pub fn new(config: BeamsConfig) -> Self {
        Beams {
            config,
            pending_groups: Vec::new(),
            active_groups: Vec::new(),
            character_final_color_map: HashMap::new(),
            final_wipe_groups: Vec::new(),
            delay: 0,
            phase: Phase::Beams,
        }
    }

    /// Group.__init__.
    fn make_group(&self, ctx: &mut EngineCtx, mut characters: Vec<CharId>, direction: Direction) -> Group {
        let speed_range = match direction {
            Direction::Row => self.config.beam_row_speed_range,
            Direction::Column => self.config.beam_column_speed_range,
        };
        let speed = ctx.rng.randint(speed_range.0, speed_range.1) as f64 * 0.1;
        match direction {
            Direction::Row => {
                characters.sort_by_key(|&id| ctx.terminal.arena[id.0 as usize].input_coord.column);
            }
            Direction::Column => {
                characters.sort_by_key(|&id| ctx.terminal.arena[id.0 as usize].input_coord.row);
            }
        }
        if *ctx.rng.choice(&[true, false]) {
            characters.reverse();
        }
        Group { characters, direction, speed, next_character_counter: 0.0 }
    }

    /// Group.get_next_character.
    fn get_next_character(&mut self, ctx: &mut EngineCtx, group: &mut Group) -> Option<CharId> {
        group.next_character_counter -= 1.0;
        let next_character = group.characters.remove(0);
        let active_scene = ctx.terminal.arena[next_character.0 as usize].animation.active_scene.clone();
        let return_value = if let Some(scene_id) = active_scene {
            ctx.terminal.arena[next_character.0 as usize]
                .animation
                .scenes
                .get_mut(&scene_id)
                .unwrap()
                .reset_scene();
            None
        } else {
            ctx.terminal.set_character_visibility(next_character, true);
            Some(next_character)
        };
        let scene_name = match group.direction {
            Direction::Row => "beam_row",
            Direction::Column => "beam_column",
        };
        ctx.activate_scene(self, next_character, scene_name);
        return_value
    }
}

impl EffectHooks for Beams {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Beams {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // __init__ precomputation (no RNG)
        self.final_wipe_groups = ctx
            .terminal
            .get_characters_grouped(CharacterFilter::default(), CharacterGroup::DiagonalTopLeftToBottomRight);

        let all_chars_filter = CharacterFilter {
            input_chars: true,
            inner_fill_chars: true,
            outer_fill_chars: true,
            added_chars: false,
        };
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters =
            ctx.terminal.get_characters(&mut ctx.rng, all_chars_filter, CharacterSort::TopToBottomLeftToRight);
        for id in characters {
            let ch = &ctx.terminal.arena[id.0 as usize];
            if ch.is_fill_character {
                self.character_final_color_map
                    .insert(id, ColorPair::new(Some(Color::from_hex("#000000").unwrap()), None));
                continue;
            }
            let final_colors = if dynamic {
                ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
            } else {
                ColorPair::new(Some(final_gradient_mapping.get(&ch.input_coord).unwrap().clone()), None)
            };
            self.character_final_color_map.insert(id, final_colors);
        }

        let beam_gradient =
            Gradient::new(&self.config.beam_gradient_stops, &self.config.beam_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let mut groups: Vec<Group> = Vec::new();
        for row in ctx.terminal.get_characters_grouped(all_chars_filter, CharacterGroup::RowTopToBottom) {
            groups.push(self.make_group(ctx, row, Direction::Row));
        }
        for column in ctx.terminal.get_characters_grouped(all_chars_filter, CharacterGroup::ColumnLeftToRight) {
            groups.push(self.make_group(ctx, column, Direction::Column));
        }
        // Rows and columns contain the same characters; initialize each character's scenes only once.
        for group in groups.iter().filter(|group| group.direction == Direction::Row) {
            for &id in &group.characters {
                let (input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation.new_scene(false, None, None, "beam_row", uses_pre);
                    ch.animation.new_scene(false, None, None, "beam_column", uses_pre);
                    ch.animation.new_scene(false, None, None, "brighten", uses_pre);
                    ch.animation
                        .scenes
                        .get_mut("beam_row")
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &self.config.beam_row_symbols,
                            self.config.beam_gradient_frames,
                            Some(&beam_gradient),
                            None,
                        )
                        .map_err(EngineError::Other)?;
                    ch.animation
                        .scenes
                        .get_mut("beam_column")
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &self.config.beam_column_symbols,
                            self.config.beam_gradient_frames,
                            Some(&beam_gradient),
                            None,
                        )
                        .map_err(EngineError::Other)?;
                }
                let char_colors = self.character_final_color_map.get(&id).unwrap().clone();
                let mut fg_fade_gradient: Option<Gradient> = None;
                let mut bg_fade_gradient: Option<Gradient> = None;
                let mut fg_brighten_gradient: Option<Gradient> = None;
                let mut bg_brighten_gradient: Option<Gradient> = None;
                if let Some(fg) = &char_colors.fg_color {
                    let faded_fg_color = Animation::adjust_color_brightness(fg, 0.3);
                    fg_fade_gradient = Some(
                        Gradient::with_steps(&[fg.clone(), faded_fg_color.clone()], 10, false)
                            .map_err(EngineError::Other)?,
                    );
                    fg_brighten_gradient = Some(
                        Gradient::with_steps(&[faded_fg_color, fg.clone()], 10, false)
                            .map_err(EngineError::Other)?,
                    );
                }
                if let Some(bg) = &char_colors.bg_color {
                    let faded_bg_color = Animation::adjust_color_brightness(bg, 0.3);
                    bg_fade_gradient = Some(
                        Gradient::with_steps(&[bg.clone(), faded_bg_color.clone()], 10, false)
                            .map_err(EngineError::Other)?,
                    );
                    bg_brighten_gradient = Some(
                        Gradient::with_steps(&[faded_bg_color, bg.clone()], 10, false)
                            .map_err(EngineError::Other)?,
                    );
                }

                let ch = &mut ctx.terminal.arena[id.0 as usize];
                if fg_fade_gradient.is_some() || bg_fade_gradient.is_some() {
                    ch.animation
                        .scenes
                        .get_mut("beam_row")
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            2,
                            fg_fade_gradient.as_ref(),
                            bg_fade_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                    ch.animation
                        .scenes
                        .get_mut("beam_column")
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            2,
                            fg_fade_gradient.as_ref(),
                            bg_fade_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    ch.animation
                        .scenes
                        .get_mut("beam_row")
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            2,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                    ch.animation
                        .scenes
                        .get_mut("beam_column")
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            2,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }

                if fg_brighten_gradient.is_some() || bg_brighten_gradient.is_some() {
                    ch.animation
                        .scenes
                        .get_mut("brighten")
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            self.config.final_gradient_frames,
                            fg_brighten_gradient.as_ref(),
                            bg_brighten_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    ch.animation
                        .scenes
                        .get_mut("brighten")
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            self.config.final_gradient_frames,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
        }

        self.pending_groups = groups;
        ctx.rng.shuffle(&mut self.pending_groups);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.phase != Phase::Complete || !ctx.active_characters.is_empty() {
            match self.phase {
                Phase::Beams => {
                    if self.delay == 0 {
                        if !self.pending_groups.is_empty() {
                            for _ in 0..ctx.rng.randint(1, 5) {
                                if !self.pending_groups.is_empty() {
                                    self.active_groups.push(self.pending_groups.remove(0));
                                }
                            }
                        }
                        self.delay = self.config.beam_delay;
                    } else {
                        self.delay -= 1;
                    }
                    let mut active_groups = std::mem::take(&mut self.active_groups);
                    for group in &mut active_groups {
                        group.next_character_counter += group.speed;
                        // int() truncation
                        let count = group.next_character_counter as i64;
                        if count > 1 {
                            for _ in 0..count {
                                if !group.characters.is_empty() {
                                    if let Some(next_char) = self.get_next_character(ctx, group) {
                                        ctx.active_characters.insert(next_char);
                                    }
                                }
                            }
                        }
                    }
                    active_groups.retain(|group| !group.characters.is_empty());
                    self.active_groups = active_groups;
                    if self.pending_groups.is_empty()
                        && self.active_groups.is_empty()
                        && ctx.active_characters.is_empty()
                    {
                        self.phase = Phase::FinalWipe;
                    }
                }
                Phase::FinalWipe => {
                    if !self.final_wipe_groups.is_empty() {
                        for _ in 0..self.config.final_wipe_speed {
                            if self.final_wipe_groups.is_empty() {
                                break;
                            }
                            let next_group = self.final_wipe_groups.remove(0);
                            for id in next_group {
                                ctx.activate_scene(self, id, "brighten");
                                ctx.terminal.set_character_visibility(id, true);
                                ctx.active_characters.insert(id);
                            }
                        }
                    } else {
                        self.phase = Phase::Complete;
                    }
                }
                Phase::Complete => {}
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
