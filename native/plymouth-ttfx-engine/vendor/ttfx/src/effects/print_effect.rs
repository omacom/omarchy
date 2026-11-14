//! print, ported from effects/effect_print.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float, parse_positive_int,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterGroup};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct PrintConfig {
    /// Speed of the print head when performing a carriage return.
    #[arg(long = "print-head-return-speed", default_value_t = 1.5, value_parser = parse_positive_float)]
    pub print_head_return_speed: f64,

    /// Speed of the print head when printing characters.
    #[arg(long = "print-speed", default_value_t = 2, value_parser = parse_positive_int)]
    pub print_speed: i64,

    /// Easing function to use for print head movement.
    #[arg(long = "print-head-easing", default_value = "in_out_quad", value_parser = parse_easing)]
    pub print_head_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["02b8bd", "c1f0e3", "00ffa0"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// PrintIterator.Row (plain struct over CharIds; scene/coord setup happens in
/// Print::make_row so it can borrow the engine).
struct Row {
    untyped_chars: Vec<CharId>,
    typed_chars: Vec<CharId>,
}

impl Row {
    /// Row.move_up.
    fn move_up(&self, ctx: &mut EngineCtx) {
        for &id in &self.typed_chars {
            let motion = &mut ctx.terminal.arena[id.0 as usize].motion;
            let current = motion.current_coord;
            motion.set_coordinate(Coord::new(current.column, current.row + 1));
        }
    }

    /// Row.type_char.
    fn type_char(&mut self) -> Option<CharId> {
        if self.untyped_chars.is_empty() {
            return None;
        }
        let next_char = self.untyped_chars.remove(0);
        self.typed_chars.push(next_char);
        Some(next_char)
    }
}

const SET_INVISIBLE_CALLBACK: u32 = 0;

pub struct Print {
    config: PrintConfig,
    pending_rows: Vec<Row>,
    processed_rows: Vec<Row>,
    typing_head: CharId,
    character_final_color_map: HashMap<CharId, ColorPair>,
    current_row: Row,
    typing: bool,
    last_column: i64,
}

impl Print {
    pub fn new(config: PrintConfig) -> Self {
        Print {
            config,
            pending_rows: Vec::new(),
            processed_rows: Vec::new(),
            typing_head: CharId(0),
            character_final_color_map: HashMap::new(),
            current_row: Row { untyped_chars: Vec::new(), typed_chars: Vec::new() },
            typing: false,
            last_column: 0,
        }
    }

    /// PrintIterator.Row.__init__.
    fn make_row(&mut self, ctx: &mut EngineCtx, characters: Vec<CharId>) -> Result<Row, EngineError> {
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let typing_head_color = Color::from_hex("ffffff").unwrap();
        let all_spaces =
            characters.iter().all(|&id| ctx.terminal.arena[id.0 as usize].input_symbol == " ");
        let characters: Vec<CharId> = if all_spaces {
            characters.into_iter().take(1).collect()
        } else {
            let right_extent = characters
                .iter()
                .copied()
                .filter(|&id| !ctx.terminal.arena[id.0 as usize].is_fill_character)
                .map(|id| ctx.terminal.arena[id.0 as usize].input_coord.column)
                .max()
                .expect("row has a non-fill character");
            characters
                .into_iter()
                .filter(|&id| ctx.terminal.arena[id.0 as usize].input_coord.column <= right_extent)
                .collect()
        };
        let mut untyped_chars: Vec<CharId> = Vec::new();
        for id in characters {
            let (input_symbol, input_column, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.input_symbol.clone(), ch.input_coord.column, ch.uses_input_preexisting_colors)
            };
            let typed_animation = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(Coord::new(input_column, 1));
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            if dynamic {
                let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
                let fg_gradient = match &final_colors.fg_color {
                    Some(fg) => Some(
                        Gradient::with_steps(&[typing_head_color.clone(), fg.clone()], 5, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &final_colors.bg_color {
                    Some(bg) => Some(
                        Gradient::with_steps(&[typing_head_color.clone(), bg.clone()], 5, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    ch.animation
                        .scenes
                        .get_mut(&typed_animation)
                        .unwrap()
                        .apply_gradient_to_symbols(
                            &[
                                "█".to_string(),
                                "▓".to_string(),
                                "▒".to_string(),
                                "░".to_string(),
                                input_symbol.clone(),
                            ],
                            3,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    let head_gradient =
                        Gradient::with_steps(&[typing_head_color.clone(), typing_head_color.clone()], 4, false)
                            .map_err(EngineError::Other)?;
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut(&typed_animation).unwrap();
                    scene
                        .apply_gradient_to_symbols(
                            &["█".to_string(), "▓".to_string(), "▒".to_string(), "░".to_string()],
                            3,
                            Some(&head_gradient),
                            None,
                        )
                        .map_err(EngineError::Other)?;
                    scene
                        .add_frame(
                            &input_symbol,
                            3,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_fg = self
                    .character_final_color_map
                    .get(&id)
                    .unwrap()
                    .fg_color
                    .clone()
                    .expect("final fg color present");
                let color_gradient = Gradient::with_steps(&[typing_head_color.clone(), final_fg], 5, false)
                    .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&typed_animation)
                    .unwrap()
                    .apply_gradient_to_symbols(
                        &[
                            "█".to_string(),
                            "▓".to_string(),
                            "▒".to_string(),
                            "░".to_string(),
                            input_symbol.clone(),
                        ],
                        3,
                        Some(&color_gradient),
                        None,
                    )
                    .map_err(EngineError::Other)?;
            }
            ctx.activate_scene(self, id, &typed_animation);
            untyped_chars.push(id);
        }
        Ok(Row { untyped_chars, typed_chars: Vec::new() })
    }
}

impl EffectHooks for Print {
    fn dispatch_callback(&mut self, ctx: &mut EngineCtx, character: CharId, callback: &EffectCallback) {
        if callback.id == SET_INVISIBLE_CALLBACK {
            // EventHandler.Callback(self.terminal.set_character_visibility, False)
            ctx.terminal.set_character_visibility(character, false);
        }
    }
}

impl Effect for Print {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // PrintIterator.__init__: the typing head is added before build().
        self.typing_head = ctx.terminal.add_character("█", Coord::new(1, 1));

        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let filter = CharacterFilter { inner_fill_chars: true, outer_fill_chars: true, ..Default::default() };
        let characters = ctx.terminal.get_characters(
            &mut ctx.rng,
            filter,
            crate::engine::terminal::CharacterSort::TopToBottomLeftToRight,
        );
        for &id in &characters {
            let final_colors = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                if dynamic {
                    ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
                } else {
                    ColorPair::new(
                        Some(
                            final_gradient_mapping
                                .get(&ch.input_coord)
                                .cloned()
                                .unwrap_or_else(|| Color::from_hex("ffffff").unwrap()),
                        ),
                        None,
                    )
                }
            };
            self.character_final_color_map.insert(id, final_colors);
        }
        let input_rows = ctx.terminal.get_characters_grouped(filter, CharacterGroup::RowTopToBottom);
        for input_row in input_rows {
            let row = self.make_row(ctx, input_row)?;
            self.pending_rows.push(row);
        }
        self.current_row = self.pending_rows.remove(0);
        self.typing = true;
        self.last_column = 0;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !ctx.active_characters.is_empty() || self.typing {
            if ctx.terminal.arena[self.typing_head.0 as usize].motion.active_path.is_some() {
                // print head is performing a carriage return
            } else if !self.current_row.untyped_chars.is_empty() {
                let count =
                    std::cmp::min(self.current_row.untyped_chars.len() as i64, self.config.print_speed);
                for _ in 0..count {
                    if let Some(next_char) = self.current_row.type_char() {
                        ctx.terminal.set_character_visibility(next_char, true);
                        ctx.active_characters.insert(next_char);
                        self.last_column = ctx.terminal.arena[next_char.0 as usize].input_coord.column;
                    }
                }
            } else {
                let finished_row = std::mem::replace(
                    &mut self.current_row,
                    Row { untyped_chars: Vec::new(), typed_chars: Vec::new() },
                );
                self.processed_rows.push(finished_row);
                if !self.pending_rows.is_empty() {
                    for row in &self.processed_rows {
                        row.move_up(ctx);
                    }
                    self.current_row = self.pending_rows.remove(0);
                    let last_row_all_fill = self
                        .processed_rows
                        .last()
                        .unwrap()
                        .typed_chars
                        .iter()
                        .all(|&id| ctx.terminal.arena[id.0 as usize].is_fill_character);
                    let current_row_all_fill = self
                        .current_row
                        .untyped_chars
                        .iter()
                        .all(|&id| ctx.terminal.arena[id.0 as usize].is_fill_character);
                    if !last_row_all_fill && !current_row_all_fill {
                        let left_extent = self
                            .current_row
                            .untyped_chars
                            .iter()
                            .copied()
                            .filter(|&id| !ctx.terminal.arena[id.0 as usize].is_fill_character)
                            .map(|id| ctx.terminal.arena[id.0 as usize].input_coord.column)
                            .min()
                            .expect("row has a non-fill character");
                        let text_right = ctx.terminal.canvas.text_right;
                        let arena = &ctx.terminal.arena;
                        self.current_row.untyped_chars.retain(|&id| {
                            let column = arena[id.0 as usize].input_coord.column;
                            left_extent <= column && column <= text_right
                        });
                    }
                    {
                        let head = &mut ctx.terminal.arena[self.typing_head.0 as usize];
                        head.motion.set_coordinate(Coord::new(self.last_column, 1));
                    }
                    ctx.terminal.set_character_visibility(self.typing_head, true);
                    let target_column = ctx.terminal.arena
                        [self.current_row.untyped_chars[0].0 as usize]
                        .input_coord
                        .column;
                    {
                        let head = &mut ctx.terminal.arena[self.typing_head.0 as usize];
                        head.motion.paths.clear();
                        let path_id = head
                            .motion
                            .new_path(
                                self.config.print_head_return_speed,
                                Some(self.config.print_head_easing),
                                None,
                                0,
                                false,
                                "carriage_return_path",
                            )
                            .expect("fresh path table");
                        head.motion
                            .paths
                            .get_mut(&path_id)
                            .unwrap()
                            .new_waypoint(Coord::new(target_column, 1), None, "")
                            .expect("fresh waypoint");
                    }
                    let typing_head = self.typing_head;
                    ctx.activate_path(self, typing_head, "carriage_return_path");
                    // contextlib.suppress(DuplicateEventRegistrationError):
                    // the same (event, path-id, callback) tuple re-registers
                    // every row and is rejected after the first.
                    let _ = ctx.register_event(
                        self.typing_head,
                        Event::PathComplete,
                        CallerKey::Path("carriage_return_path".to_string()),
                        EventAction::Callback(EffectCallback { id: SET_INVISIBLE_CALLBACK, args: Vec::new() }),
                    );
                    ctx.active_characters.insert(self.typing_head);
                } else {
                    self.typing = false;
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
