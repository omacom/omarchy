//! print on the fx engine (old engine: effects/print_effect.rs).
//!
//! Rows are the RowTopToBottom groups, trimmed as Row.__init__ and the
//! carriage return trim them, so each group is the row: the first `pos`
//! characters of the current row are typed, the rest untyped, and every row
//! before `cur` is a processed row (fully typed). A typed scene's frames are
//! memoized by (symbol, final color). Print draws no random numbers.

use std::collections::HashMap;

use crate::effects::print_effect::PrintConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

const SET_INVISIBLE_CALLBACK: u32 = 0;
const BLOCKS: [&str; 4] = ["█", "▓", "▒", "░"];

pub struct Print {
    config: PrintConfig,
    head: u32,
    rows: Vec<Vec<u32>>,
    /// The current row, and how many of its characters are typed.
    cur: usize,
    pos: usize,
    typing: bool,
    last_column: i64,
    carriage_return: Name,
}

impl Print {
    pub fn new(config: PrintConfig) -> Self {
        Print {
            config,
            head: NONE,
            rows: Vec::new(),
            cur: 0,
            pos: 0,
            typing: false,
            last_column: 0,
            carriage_return: Name::NONE,
        }
    }
}

impl Hooks for Print {
    fn callback(&mut self, e: &mut Engine, slot: u32, id: u32, _arg: i64) {
        if id == SET_INVISIBLE_CALLBACK {
            // EventHandler.Callback(self.terminal.set_character_visibility, False)
            e.set_visible(slot, false);
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

fn all_fill(e: &Engine, slots: &[u32]) -> bool {
    slots.iter().all(|&s| e.is_fill(s))
}

impl Effect for Print {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        // PrintIterator.__init__: the typing head is added before build()
        self.head = e.add_character("█", Coord::new(1, 1));
        self.carriage_return = e.name("carriage_return_path");
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
        let white = Color::from_hex("ffffff").unwrap();
        let space = e.sym(" ");
        let mut symbols: Vec<Sym> = BLOCKS.iter().map(|b| e.sym(b)).collect();
        symbols.push(space);
        let head_gradient = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[white, c], 5, false)
                .map_err(other)?
                .spectrum)
        };
        // (symbol, final color) -> the typed frames of a plain scene
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();

        let filter = CharacterFilter {
            inner_fill_chars: true,
            outer_fill_chars: true,
            ..Default::default()
        };
        let mut rows = e.get_characters_grouped(filter, CharacterGroup::RowTopToBottom);
        // PrintIterator.Row.__init__
        for row in &mut rows {
            if row.iter().all(|&s| e.symbol(e.input_sym(s)) == " ") {
                row.truncate(1);
            } else {
                let right_extent = row
                    .iter()
                    .filter(|&&s| !e.is_fill(s))
                    .map(|&s| e.input_coord(s).column)
                    .max()
                    .expect("row has a non-fill character");
                row.retain(|&s| e.input_coord(s).column <= right_extent);
            }
            for &slot in row.iter() {
                let input = e.input_coord(slot);
                e.set_coordinate(slot, Coord::new(input.column, 1));
                let scene = e.scene_new(slot, Name::NONE, false, None, None);
                let sym = e.input_sym(slot);
                symbols[4] = sym;
                if dynamic {
                    let fg = e.input_fg(slot).map(head_gradient).transpose()?;
                    let bg = e.input_bg(slot).map(head_gradient).transpose()?;
                    if fg.is_some() || bg.is_some() {
                        e.apply_gradient(scene, &symbols, 3, fg.as_deref(), bg.as_deref())
                            .map_err(other)?;
                    } else {
                        let head = Gradient::with_steps(&[white, white], 4, false)
                            .map_err(other)?
                            .spectrum;
                        e.apply_gradient(scene, &symbols[..4], 3, Some(&head), None)
                            .map_err(other)?;
                        e.add_frame(scene, sym, 3, Some(ColorPair::default()), 0)
                            .map_err(other)?;
                    }
                } else {
                    let final_fg = final_gradient_mapping.get(&input).copied().unwrap_or(white);
                    let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                    match memo.get(&(sym, final_fg)) {
                        Some(frames) if plain => e.append_frames(scene, frames),
                        _ => {
                            let spectrum = head_gradient(final_fg)?;
                            e.apply_gradient(scene, &symbols, 3, Some(&spectrum), None)
                                .map_err(other)?;
                            if plain {
                                memo.insert((sym, final_fg), e.scenes.frames_of(scene).to_vec());
                            }
                        }
                    }
                }
                e.activate_scene(self, slot, scene);
            }
        }
        if rows.is_empty() {
            // pending_rows.remove(0) on an empty list panics upstream
            panic!("print: no rows");
        }
        self.rows = rows;
        self.cur = 0;
        self.pos = 0;
        self.typing = true;
        self.last_column = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() && !self.typing {
            return false;
        }
        let head = self.head;
        if e.ch.path[head as usize] != NONE {
            // the print head is performing a carriage return
        } else if self.pos < self.rows[self.cur].len() {
            let row = &self.rows[self.cur];
            let count = (row.len() - self.pos).min(self.config.print_speed.max(0) as usize);
            for &slot in &row[self.pos..self.pos + count] {
                e.set_visible(slot, true);
                e.active_insert(slot);
                self.last_column = e.input_coord(slot).column;
            }
            self.pos += count;
        } else if self.cur + 1 < self.rows.len() {
            // the finished row joins the processed ones; all of them move up
            self.cur += 1;
            self.pos = 0;
            for row in &self.rows[..self.cur] {
                for &slot in row {
                    let c = e.coord(slot);
                    e.set_coordinate(slot, Coord::new(c.column, c.row + 1));
                }
            }
            let last_row_all_fill = all_fill(e, &self.rows[self.cur - 1]);
            let current = &mut self.rows[self.cur];
            if !last_row_all_fill && !all_fill(e, current) {
                let left_extent = current
                    .iter()
                    .filter(|&&s| !e.is_fill(s))
                    .map(|&s| e.input_coord(s).column)
                    .min()
                    .expect("row has a non-fill character");
                let text_right = e.canvas.text_right;
                current.retain(|&s| {
                    let column = e.input_coord(s).column;
                    left_extent <= column && column <= text_right
                });
            }
            e.set_coordinate(head, Coord::new(self.last_column, 1));
            e.set_visible(head, true);
            // current_row.untyped_chars[0] on an empty row panics upstream
            let target_column = e.input_coord(self.rows[self.cur][0]).column;
            e.paths_clear(head);
            let path = e
                .path_new(
                    head,
                    self.config.print_head_return_speed,
                    Some(self.config.print_head_easing),
                    None,
                    0,
                    false,
                    self.carriage_return,
                )
                .expect("fresh path table");
            e.path_new_waypoint(path, Coord::new(target_column, 1), None, Name::NONE)
                .expect("fresh waypoint");
            e.activate_path(self, head, path);
            // contextlib.suppress(DuplicateEventRegistrationError): the same
            // (event, path id, callback) registers every row and is rejected
            // after the first
            let _ = e.register_event(
                head,
                Event::PathComplete,
                Caller::Path(self.carriage_return),
                Action::Callback(SET_INVISIBLE_CALLBACK, 0),
            );
            e.active_insert(head);
        } else {
            self.typing = false;
        }
        e.update(self);
        true
    }
}
