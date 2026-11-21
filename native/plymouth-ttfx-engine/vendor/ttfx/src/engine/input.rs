//! Input preprocessing: the mini terminal emulator from Terminal._preprocess_input_data.
//!
//! Walks the input codepoint-by-codepoint (one char = one cell, faithfully — no
//! wcwidth upstream), tracking SGR color state and cursor movement, producing
//! rows of arena character ids. Everything here, including which malformed
//! sequences error vs. get silently ignored, transcribes terminal.py:604-862.

use std::collections::HashMap;

use crate::utils::hash::FxBuild;

use crate::engine::character::CharId;
use crate::engine::error::EngineError;
use crate::engine::terminal::{TerminalConfig, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::Color;

/// Insertion-ordered Color -> count map (upstream: dict[Color, int]). Iteration
/// order is behavior for get_input_colors; the population is small, linear scan.
#[derive(Debug, Default, Clone)]
pub struct ColorFrequency(pub Vec<(Color, i64)>);

impl ColorFrequency {
    fn increment(&mut self, color: &Color) {
        if let Some(entry) = self.0.iter_mut().find(|(c, _)| c == color) {
            entry.1 += 1;
        } else {
            self.0.push((*color, 1));
        }
    }
}

/// The input SGR sequences a character was parsed under (fg, bg): only the
/// old engine keeps them, so they live in a side table (`Sequences`).
pub type Sequences = Vec<(Option<String>, Option<String>)>;

/// A character as parsed: what both engines build their own characters from.
/// Index in the parse output is the arena slot (CharId). Plain data: the
/// strings it was parsed under are in the side table.
#[derive(Debug, Clone, Copy)]
pub struct InputChar {
    /// Python-compatible allocation id.
    pub character_id: u32,
    pub symbol: char,
    pub input_coord: Coord,
    /// Where the character starts (Motion.current_coord): its anchored input
    /// coordinate, or the origin for one that was never anchored.
    pub coord: Coord,
    /// Its entry in the Sequences table, NONE for none.
    pub sequences: u32,
    pub fg: Option<Color>,
    pub bg: Option<Color>,
    pub bold: bool,
    /// Parsed characters use their input colors; fill characters do not.
    pub uses_preexisting_colors: bool,
    pub is_fill: bool,
}

impl InputChar {
    pub fn fill(character_id: u32, coord: Coord) -> Self {
        InputChar {
            character_id,
            symbol: ' ',
            input_coord: coord,
            coord,
            sequences: NONE,
            fg: None,
            bg: None,
            bold: false,
            uses_preexisting_colors: false,
            is_fill: true,
        }
    }

    /// A plain space: trailing ones are trimmed and they become fill.
    pub fn is_blank(&self) -> bool {
        self.symbol == ' ' && self.fg.is_none() && self.bg.is_none()
    }
}

#[derive(Clone, Default)]
struct ActiveState {
    fg_sequence: String, // "" = none, like upstream's active_sequences
    bg_sequence: String,
    fg_color: Option<Color>,
    bg_color: Option<Color>,
    bold: bool,
    standard_fg_parameter: Option<i64>,
}

/// Whether the input holds ESC or CR (both ASCII, so a byte scan finds
/// them): 32 bytes at a time, which vectorizes.
fn has_esc_or_cr(bytes: &[u8]) -> bool {
    let mut chunks = bytes.chunks_exact(32);
    let mut found = false;
    for chunk in &mut chunks {
        let mut hit = 0u8;
        for &b in chunk {
            hit |= (b == 0x1b) as u8 | (b == b'\r') as u8;
        }
        found |= hit != 0;
    }
    found || chunks.remainder().iter().any(|&b| b == 0x1b || b == b'\r')
}

pub struct Preprocessor<'a> {
    pub arena: &'a mut Vec<InputChar>,
    pub sequences: &'a mut Sequences,
    pub next_character_id: &'a mut u32,
    pub input_colors_frequency: &'a mut ColorFrequency,
    pub config: &'a TerminalConfig,
}

impl<'a> Preprocessor<'a> {
    /// Returns rows of character ids (top row first, as parsed).
    pub fn preprocess(&mut self, input_data: &str) -> Result<Vec<Vec<CharId>>, EngineError> {
        if !has_esc_or_cr(input_data.as_bytes()) {
            return self.preprocess_plain(input_data);
        }
        let chars: Vec<char> = input_data.chars().collect();
        let mut screen: HashMap<(i64, i64), CharId, FxBuild> = HashMap::default();
        let mut state = ActiveState::default();
        let (mut row, mut column) = (0i64, 0i64);
        let (mut max_row, mut max_column) = (0i64, 0i64);
        let mut i = 0usize;

        while i < chars.len() {
            if chars[i] == '\x1b' {
                let end = match_escape_sequence(&chars, i)
                    .ok_or_else(|| EngineError::UnsupportedAnsiSequence(chars[i].to_string()))?;
                let sequence: String = chars[i..end].iter().collect();
                if sequence.starts_with("\x1b[") {
                    let (params, intermediates, final_byte) = split_csi(&sequence)
                        .ok_or_else(|| EngineError::UnsupportedAnsiSequence(sequence.clone()))?;
                    if final_byte == 'm' {
                        self.apply_sgr_sequence(&sequence, &params, &mut state)?;
                    } else if is_supported_private_mode_sequence(&sequence) {
                        // ignored: cursor show/hide, autowrap on/off
                    } else {
                        let (new_row, new_column) = apply_cursor_sequence(
                            &sequence,
                            &params,
                            &intermediates,
                            final_byte,
                            row,
                            column,
                        )?;
                        row = new_row;
                        column = new_column;
                        max_row = max_row.max(row);
                        max_column = max_column.max(column);
                    }
                } else {
                    return Err(EngineError::UnsupportedAnsiSequence(sequence));
                }
                i = end;
            } else if chars[i] == '\n' {
                row += 1;
                column = 0;
                max_row = max_row.max(row);
                i += 1;
            } else if chars[i] == '\r' {
                column = 0;
                i += 1;
            } else {
                let (symbol, count) = if chars[i] == '\t' {
                    (
                        ' ',
                        self.config.tab_width - (column % self.config.tab_width),
                    )
                } else {
                    (chars[i], 1)
                };
                for _ in 0..count {
                    let id = self.build_character(symbol, &state)?;
                    screen.insert((row, column), id);
                    max_row = max_row.max(row);
                    max_column = max_column.max(column);
                    column += 1;
                }
                i += 1;
            }
        }

        self.screen_lines(max_row, max_column, &state, |row, column| {
            screen.get(&(row, column)).copied()
        })
    }

    /// preprocess for input without ESC or CR: every cell is written once,
    /// in row-major order, so each row's characters are its written ones in
    /// column order (no screen map), and no SGR state ever applies.
    fn preprocess_plain(&mut self, input_data: &str) -> Result<Vec<Vec<CharId>>, EngineError> {
        let state = ActiveState::default();
        let mut rows: Vec<Vec<CharId>> = vec![Vec::new()];
        let tab_width = self.config.tab_width;
        for c in input_data.chars() {
            if c == '\n' {
                rows.push(Vec::new());
                continue;
            }
            let row = rows.last_mut().unwrap();
            let (symbol, count) = if c == '\t' {
                (' ', tab_width - (row.len() as i64 % tab_width))
            } else {
                (c, 1)
            };
            for _ in 0..count {
                let id = self.build_character(symbol, &state)?;
                row.push(id);
            }
        }
        let max_row = rows.len() as i64 - 1;
        let max_column = rows
            .iter()
            .map(|r| r.len() as i64 - 1)
            .max()
            .unwrap_or(0)
            .max(0);
        self.screen_lines(max_row, max_column, &state, |row, column| {
            rows[row as usize].get(column as usize).copied()
        })
    }

    /// The screen's rows (0..=max_row, columns 0..=max_column): a written
    /// cell's character, else a fresh space; trailing plain spaces and empty
    /// rows at the bottom trimmed. `state` is the end-of-input state.
    fn screen_lines(
        &mut self,
        max_row: i64,
        max_column: i64,
        state: &ActiveState,
        written: impl Fn(i64, i64) -> Option<CharId>,
    ) -> Result<Vec<Vec<CharId>>, EngineError> {
        let empty_state = ActiveState::default();
        let mut characters: Vec<Vec<CharId>> = Vec::new();
        for screen_row in 0..=max_row {
            let mut line: Vec<CharId> = Vec::with_capacity(max_column as usize + 1);
            for screen_column in 0..=max_column {
                let id = match written(screen_row, screen_column) {
                    Some(id) => id,
                    None => self.build_character(' ', &empty_state)?,
                };
                line.push(id);
            }
            while let Some(&last) = line.last() {
                if self.arena[last.0 as usize].is_blank() {
                    line.pop();
                } else {
                    break;
                }
            }
            characters.push(line);
        }
        while characters.last().is_some_and(|line| line.is_empty()) {
            characters.pop();
        }

        if characters.is_empty() {
            // Faithful: the fallback character carries the END-of-input active state.
            let id = self.build_character(' ', state)?;
            characters.push(vec![id]);
        }
        Ok(characters)
    }

    /// build_character: allocates an id (even for characters later discarded),
    /// captures active colors, bumps the color frequency at CREATION time (even
    /// if a later cursor write overwrites the cell — see plan.md §5.13).
    fn build_character(
        &mut self,
        symbol: char,
        state: &ActiveState,
    ) -> Result<CharId, EngineError> {
        let mut ch = InputChar {
            character_id: *self.next_character_id,
            symbol,
            input_coord: Coord::new(0, 0),
            coord: Coord::new(0, 0),
            sequences: NONE,
            fg: None,
            bg: None,
            bold: state.bold,
            uses_preexisting_colors: true,
            is_fill: false,
        };
        *self.next_character_id += 1;
        // fg first, then bg — upstream dict iteration order over active_sequences
        let (mut fg_sequence, mut bg_sequence) = (None, None);
        if !state.fg_sequence.is_empty() {
            if let Some(color) = &state.fg_color {
                fg_sequence = Some(state.fg_sequence.clone());
                self.input_colors_frequency.increment(color);
                ch.fg = Some(*color);
            }
        }
        if !state.bg_sequence.is_empty() {
            if let Some(color) = &state.bg_color {
                bg_sequence = Some(state.bg_sequence.clone());
                self.input_colors_frequency.increment(color);
                ch.bg = Some(*color);
            }
        }
        if fg_sequence.is_some() || bg_sequence.is_some() {
            ch.sequences = self.sequences.len() as u32;
            self.sequences.push((fg_sequence, bg_sequence));
        }
        let id = CharId(self.arena.len() as u32);
        self.arena.push(ch);
        Ok(id)
    }

    fn apply_sgr_sequence(
        &mut self,
        sequence: &str,
        params_text: &str,
        state: &mut ActiveState,
    ) -> Result<(), EngineError> {
        let mut parameters = parse_csi_parameters(params_text)?;
        if parameters.is_empty() {
            parameters = vec![0];
        }
        let mut idx = 0usize;
        while idx < parameters.len() {
            let parameter = parameters[idx];
            match parameter {
                0 => {
                    state.fg_sequence.clear();
                    state.bg_sequence.clear();
                    state.fg_color = None;
                    state.bg_color = None;
                    state.bold = false;
                    state.standard_fg_parameter = None;
                }
                1 => {
                    state.bold = true;
                    if let Some(p) = state.standard_fg_parameter {
                        state.fg_color = Some(xterm_color(p - 30 + 8)?);
                    }
                }
                22 => {
                    state.bold = false;
                    if let Some(p) = state.standard_fg_parameter {
                        state.fg_color = Some(xterm_color(p - 30)?);
                    }
                }
                39 => {
                    state.fg_sequence.clear();
                    state.fg_color = None;
                    state.standard_fg_parameter = None;
                }
                49 => {
                    state.bg_sequence.clear();
                    state.bg_color = None;
                }
                30..=37 => {
                    let color = xterm_color(parameter - 30 + if state.bold { 8 } else { 0 })?;
                    state.fg_sequence = format!("\x1b[{parameter}m");
                    state.fg_color = Some(color);
                    state.standard_fg_parameter = Some(parameter);
                }
                90..=97 => {
                    let color = xterm_color(parameter - 90 + 8)?;
                    state.fg_sequence = format!("\x1b[{parameter}m");
                    state.fg_color = Some(color);
                    state.standard_fg_parameter = None;
                }
                40..=47 => {
                    let color = xterm_color(parameter - 40)?;
                    state.bg_sequence = format!("\x1b[{parameter}m");
                    state.bg_color = Some(color);
                }
                100..=107 => {
                    let color = xterm_color(parameter - 100 + 8)?;
                    state.bg_sequence = format!("\x1b[{parameter}m");
                    state.bg_color = Some(color);
                }
                38 | 48 => {
                    if idx + 1 >= parameters.len() {
                        return Err(EngineError::UnsupportedAnsiSequence(sequence.to_string()));
                    }
                    let is_fg = parameter == 38;
                    let selector = parameter;
                    let color_mode = parameters[idx + 1];
                    let (normalized_sequence, color) = match color_mode {
                        5 => {
                            if idx + 2 >= parameters.len() {
                                return Err(EngineError::UnsupportedAnsiSequence(
                                    sequence.to_string(),
                                ));
                            }
                            let code = parameters[idx + 2];
                            let color = xterm_color(code)?;
                            idx += 2;
                            (format!("\x1b[{selector};5;{code}m"), color)
                        }
                        2 => {
                            if idx + 4 >= parameters.len() {
                                return Err(EngineError::UnsupportedAnsiSequence(
                                    sequence.to_string(),
                                ));
                            }
                            let hex: String = (2..5)
                                .map(|o| format!("{:02X}", parameters[idx + o]))
                                .collect();
                            let color = Color::from_hex(&hex).map_err(EngineError::Other)?;
                            let (r, g, b) = color.rgb_ints();
                            idx += 4;
                            (format!("\x1b[{selector};2;{r};{g};{b}m"), color)
                        }
                        _ => {
                            return Err(EngineError::UnsupportedAnsiSequence(sequence.to_string()))
                        }
                    };
                    if is_fg {
                        state.fg_sequence = normalized_sequence;
                        state.fg_color = Some(color);
                        state.standard_fg_parameter = None;
                    } else {
                        state.bg_sequence = normalized_sequence;
                        state.bg_color = Some(color);
                    }
                }
                // Faithful: any other SGR parameter value is silently ignored
                // (the upstream loop has no fallback error branch).
                _ => {}
            }
            idx += 1;
        }
        Ok(())
    }
}

fn xterm_color(code: i64) -> Result<Color, EngineError> {
    // Upstream Color(int) raises ValueError outside 0..=255; that error is not
    // an UnsupportedAnsiSequenceError but still aborts the run.
    if (0..=255).contains(&code) {
        Ok(Color::from_xterm(code as u8))
    } else {
        Err(EngineError::Other(format!(
            "invalid xterm color code in input: {code}"
        )))
    }
}

/// parse_csi_parameters: only digits and ';' allowed; empty fields are 0.
fn parse_csi_parameters(parameters: &str) -> Result<Vec<i64>, EngineError> {
    if parameters.chars().any(|c| !c.is_ascii_digit() && c != ';') {
        return Err(EngineError::UnsupportedAnsiSequence(format!(
            "\x1b[{parameters}"
        )));
    }
    if parameters.is_empty() {
        return Ok(vec![]);
    }
    Ok(parameters
        .split(';')
        .map(|p| if p.is_empty() { 0 } else { p.parse().unwrap() })
        .collect())
}

fn default_parameter(parameters: &[i64]) -> i64 {
    match parameters.first() {
        None => 1,
        Some(&p) => p.max(1),
    }
}

fn is_supported_private_mode_sequence(sequence: &str) -> bool {
    matches!(
        sequence,
        "\x1b[?25h" | "\x1b[?25l" | "\x1b[?7h" | "\x1b[?7l"
    )
}

fn apply_cursor_sequence(
    sequence: &str,
    params_text: &str,
    intermediates: &str,
    final_byte: char,
    mut row: i64,
    mut column: i64,
) -> Result<(i64, i64), EngineError> {
    if !intermediates.is_empty() {
        return Err(EngineError::UnsupportedAnsiSequence(sequence.to_string()));
    }
    if params_text.starts_with('?') {
        return Err(EngineError::UnsupportedAnsiSequence(sequence.to_string()));
    }
    let parameters = parse_csi_parameters(params_text)?;
    match final_byte {
        'A' => row -= default_parameter(&parameters),
        'B' => row += default_parameter(&parameters),
        'C' => column += default_parameter(&parameters),
        'D' => column -= default_parameter(&parameters),
        'E' => {
            row += default_parameter(&parameters);
            column = 0;
        }
        'F' => {
            row -= default_parameter(&parameters);
            column = 0;
        }
        'G' => column = default_parameter(&parameters) - 1,
        'H' | 'f' => {
            row = default_parameter(&parameters) - 1;
            column = match parameters.get(1) {
                Some(&p) if p != 0 => p - 1,
                _ => 0, // (1) - 1
            };
        }
        _ => return Err(EngineError::UnsupportedAnsiSequence(sequence.to_string())),
    }
    Ok((row.max(0), column.max(0)))
}

/// Emulates upstream's ansi_escape_sequence_pattern.match at a position, with
/// the same alternation order: OSC, CSI, then `\x1b.` (any char except newline).
/// Returns the exclusive end index of the match.
fn match_escape_sequence(chars: &[char], start: usize) -> Option<usize> {
    debug_assert_eq!(chars[start], '\x1b');
    // OSC: \x1b\] [^\x07]* (\x07 | \x1b\\)  — greedy class run, longest match first
    if chars.get(start + 1) == Some(&']') {
        let run_start = start + 2;
        let mut t = run_start;
        while t < chars.len() && chars[t] != '\x07' {
            t += 1;
        }
        if t < chars.len() {
            // class run ends right before \x07: longest match consumes it
            return Some(t + 1);
        }
        // no BEL: backtrack for the rightmost \x1b\\ terminator inside the run
        let mut p = chars.len();
        while p >= run_start + 2 {
            if chars[p - 2] == '\x1b' && chars[p - 1] == '\\' {
                return Some(p);
            }
            p -= 1;
        }
        // fall through to the remaining alternatives, like regex alternation
    }
    // CSI: \x1b\[ [0-?]* [ -/]* [@-~]
    if chars.get(start + 1) == Some(&'[') {
        let mut t = start + 2;
        while t < chars.len() && ('\u{30}'..='\u{3f}').contains(&chars[t]) {
            t += 1;
        }
        while t < chars.len() && ('\u{20}'..='\u{2f}').contains(&chars[t]) {
            t += 1;
        }
        if t < chars.len() && ('\u{40}'..='\u{7e}').contains(&chars[t]) {
            return Some(t + 1);
        }
        // no valid final byte: fall through to \x1b.
    }
    // \x1b. — '.' does not match newline
    match chars.get(start + 1) {
        Some(&c) if c != '\n' => Some(start + 2),
        _ => None,
    }
}

/// splits a full CSI sequence into (params, intermediates, final) like
/// csi_sequence_pattern.fullmatch; None if it isn't a well-formed CSI sequence.
fn split_csi(sequence: &str) -> Option<(String, String, char)> {
    let chars: Vec<char> = sequence.chars().collect();
    if chars.len() < 3 || chars[0] != '\x1b' || chars[1] != '[' {
        return None;
    }
    let mut t = 2;
    let params_start = t;
    while t < chars.len() && ('\u{30}'..='\u{3f}').contains(&chars[t]) {
        t += 1;
    }
    let params: String = chars[params_start..t].iter().collect();
    let inter_start = t;
    while t < chars.len() && ('\u{20}'..='\u{2f}').contains(&chars[t]) {
        t += 1;
    }
    let intermediates: String = chars[inter_start..t].iter().collect();
    if t != chars.len() - 1 {
        return None;
    }
    let final_byte = chars[t];
    if !('\u{40}'..='\u{7e}').contains(&final_byte) {
        return None;
    }
    Some((params, intermediates, final_byte))
}
