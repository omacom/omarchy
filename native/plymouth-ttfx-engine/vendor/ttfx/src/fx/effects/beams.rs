//! beams on the fx engine (old engine: effects/beams.rs).
//!
//! Every row and every column is a group; the shuffled groups start a few at
//! a time and sweep their characters with the "beam_row" / "beam_column"
//! scene, then a diagonal wipe plays every character's "brighten" scene. A
//! character's three scenes depend only on its symbol and final colors, so
//! the first character with a given (symbol, fg, bg) builds them and later
//! ones copy them (frames shared). Scene construction draws no RNG, so the
//! character order is free; the group RNG draws follow the old engine.

use std::collections::HashMap;

use crate::effects::beams::BeamsConfig;
use crate::engine::animation::{Animation, ExistingColorHandling};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::{At, Engine, FxBuild, Hooks, Sym, NONE};
use crate::utils::graphics::{Color, ColorPair, Gradient};

const ALL_CHARS: CharacterFilter = CharacterFilter {
    input_chars: true,
    inner_fill_chars: true,
    outer_fill_chars: true,
    added_chars: false,
};

/// Scene indices in `Beams::scenes`: a group's direction picks its beam scene.
const ROW: usize = 0;
const COLUMN: usize = 1;
const BRIGHTEN: usize = 2;

/// BeamsIterator.Group: the characters not yet started are `chars[pos..]`.
struct Group {
    chars: Vec<u32>,
    pos: usize,
    direction: usize,
    speed: f64,
    counter: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Beams,
    FinalWipe,
    Complete,
}

pub struct Beams {
    config: BeamsConfig,
    /// All groups, in shuffled (pending) order; groups[..next_pending] have
    /// started.
    groups: Vec<Group>,
    next_pending: usize,
    /// Indices into groups of the groups still sweeping, in start order.
    active: Vec<u32>,
    /// Per slot: the beam_row, beam_column and brighten scenes.
    scenes: Vec<[u32; 3]>,
    wipe: Vec<Vec<u32>>,
    next_wipe: usize,
    delay: i64,
    phase: Phase,
}

impl Beams {
    pub fn new(config: BeamsConfig) -> Self {
        Beams {
            config,
            groups: Vec::new(),
            next_pending: 0,
            active: Vec::new(),
            scenes: Vec::new(),
            wipe: Vec::new(),
            next_wipe: 0,
            delay: 0,
            phase: Phase::Beams,
        }
    }

    /// Group.__init__ (the rows and columns come sorted along the group).
    fn make_group(&self, e: &mut Engine, mut chars: Vec<u32>, direction: usize) -> Group {
        let (lo, hi) = if direction == ROW {
            self.config.beam_row_speed_range
        } else {
            self.config.beam_column_speed_range
        };
        let speed = e.rng.randint(lo, hi) as f64 * 0.1;
        if e.rng.choice_index(2) == 0 {
            chars.reverse();
        }
        Group {
            chars,
            pos: 0,
            direction,
            speed,
            counter: 0.0,
        }
    }
}

impl Hooks for Beams {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// A color's fade (to 30% brightness) and brighten (back) spectra.
type Fades = Option<(Vec<Color>, Vec<Color>)>;

/// Gradient([from, to], 10).spectrum.
fn pair_spectrum(from: Color, to: Color) -> Result<Vec<Color>, EngineError> {
    Ok(Gradient::with_steps(&[from, to], 10, false)
        .map_err(other)?
        .spectrum)
}

impl Effect for Beams {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        self.wipe = e.get_characters_grouped(
            CharacterFilter::default(),
            CharacterGroup::DiagonalTopLeftToBottomRight,
        );

        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let canvas = &e.canvas;
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let handling = e.existing_color_handling();
        let dynamic = handling == ExistingColorHandling::Dynamic;
        let black = Color::from_hex("#000000").unwrap();
        let characters = e.get_characters(ALL_CHARS, CharacterSort::TopToBottomLeftToRight);

        let beam_gradient = Gradient::new(
            &config.beam_gradient_stops,
            &config.beam_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        for row in e.get_characters_grouped(ALL_CHARS, CharacterGroup::RowTopToBottom) {
            let group = self.make_group(e, row, ROW);
            self.groups.push(group);
        }
        for column in e.get_characters_grouped(ALL_CHARS, CharacterGroup::ColumnLeftToRight) {
            let group = self.make_group(e, column, COLUMN);
            self.groups.push(group);
        }

        let names = [
            e.name("beam_row"),
            e.name("beam_column"),
            e.name("brighten"),
        ];
        let beam_symbols: [Vec<Sym>; 2] = [
            config.beam_row_symbols.iter().map(|s| e.sym(s)).collect(),
            config
                .beam_column_symbols
                .iter()
                .map(|s| e.sym(s))
                .collect(),
        ];
        self.scenes = vec![[NONE; 3]; e.char_count()];
        // (symbol, fg, bg) -> the character whose plain scenes have them
        let mut beam_frames: [Option<Vec<Frame>>; 2] = [None, None];
        let mut memo: HashMap<(Sym, Option<Color>, Option<Color>), u32, FxBuild> =
            HashMap::default();
        for slot in characters {
            let (fg, bg) = if e.is_fill(slot) {
                (Some(black), None)
            } else if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                )
            };
            let sym = e.input_sym(slot);
            let plain =
                !(handling == ExistingColorHandling::Always && e.uses_preexisting_colors(slot));
            if plain {
                if let Some(&source) = memo.get(&(sym, fg, bg)) {
                    let from = self.scenes[source as usize];
                    let mut ids = [NONE; 3];
                    for k in 0..3 {
                        ids[k] = e.scene_copy(slot, from[k], names[k]);
                    }
                    self.scenes[slot as usize] = ids;
                    continue;
                }
                memo.insert((sym, fg, bg), slot);
            }
            let ids = names.map(|name| e.scene_new(slot, name, false, None, None));
            self.scenes[slot as usize] = ids;
            // the beam frames are the same for every plain scene
            for k in [ROW, COLUMN] {
                match &beam_frames[k] {
                    Some(frames) if plain => e.append_frames(ids[k], frames),
                    _ => {
                        let spectrum = Some(&beam_gradient.spectrum[..]);
                        e.apply_gradient(
                            ids[k],
                            &beam_symbols[k],
                            config.beam_gradient_frames,
                            spectrum,
                            None,
                        )
                        .map_err(other)?;
                        if plain {
                            beam_frames[k] = Some(e.scenes.frames_of(ids[k]).to_vec());
                        }
                    }
                }
            }
            // fade to 30% brightness at the end of a beam, brighten back in
            // the wipe
            let fades = |c: Option<Color>| -> Result<Fades, EngineError> {
                c.map(|c| {
                    let faded = Animation::adjust_color_brightness(&c, 0.3);
                    Ok((pair_spectrum(c, faded)?, pair_spectrum(faded, c)?))
                })
                .transpose()
            };
            let fg_fades = fades(fg)?;
            let bg_fades = fades(bg)?;
            let has = fg_fades.is_some() || bg_fades.is_some();
            let fade = |i: usize| {
                (
                    fg_fades
                        .as_ref()
                        .map(|f| if i == 0 { &f.0[..] } else { &f.1[..] }),
                    bg_fades
                        .as_ref()
                        .map(|b| if i == 0 { &b.0[..] } else { &b.1[..] }),
                )
            };
            for k in [ROW, COLUMN, BRIGHTEN] {
                let (duration, (fg_spectrum, bg_spectrum)) = if k == BRIGHTEN {
                    (config.final_gradient_frames, fade(1))
                } else {
                    (2, fade(0))
                };
                if has {
                    e.apply_gradient(ids[k], &[sym], duration, fg_spectrum, bg_spectrum)
                        .map_err(other)?;
                } else {
                    e.add_frame(ids[k], sym, duration, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            }
        }

        e.rng.shuffle(&mut self.groups);
        self.active.reserve(self.groups.len());
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.phase == Phase::Complete && e.active_is_empty() {
            return false;
        }
        match self.phase {
            Phase::Beams => {
                if self.delay == 0 {
                    if self.next_pending < self.groups.len() {
                        let count = e.rng.randint(1, 5) as usize;
                        let end = (self.next_pending + count).min(self.groups.len());
                        for g in self.next_pending..end {
                            self.active.push(g as u32);
                        }
                        self.next_pending = end;
                    }
                    self.delay = self.config.beam_delay;
                } else {
                    self.delay -= 1;
                }
                let mut kept = 0;
                for i in 0..self.active.len() {
                    let g = *self.active.at(i);
                    let group = self.groups.at_mut(g);
                    group.counter += group.speed;
                    // int() truncation
                    let count = group.counter as i64;
                    if count > 1 {
                        let n = (count as usize).min(group.chars.len() - group.pos);
                        let (start, direction) = (group.pos, group.direction);
                        group.pos += n;
                        group.counter -= n as f64;
                        for k in start..start + n {
                            // Group.get_next_character
                            let slot = *self.groups.at(g).chars.at(k);
                            let active = e.active_scene(slot);
                            let fresh = active == NONE;
                            if fresh {
                                e.set_visible(slot, true);
                            } else {
                                e.scene_reset(active);
                            }
                            let scene = self.scenes.at(slot)[direction];
                            e.activate_scene(self, slot, scene);
                            if fresh {
                                e.active_insert(slot);
                            }
                        }
                    }
                    let group = self.groups.at(g);
                    if group.pos < group.chars.len() {
                        *self.active.at_mut(kept) = g;
                        kept += 1;
                    }
                }
                self.active.truncate(kept);
                if self.next_pending == self.groups.len()
                    && self.active.is_empty()
                    && e.active_is_empty()
                {
                    self.phase = Phase::FinalWipe;
                }
            }
            Phase::FinalWipe => {
                if self.next_wipe < self.wipe.len() {
                    let end = (self.next_wipe + self.config.final_wipe_speed as usize)
                        .min(self.wipe.len());
                    for w in self.next_wipe..end {
                        for k in 0..self.wipe.at(w).len() {
                            let slot = *self.wipe.at(w).at(k);
                            let scene = self.scenes.at(slot)[BRIGHTEN];
                            e.activate_scene(self, slot, scene);
                            e.set_visible(slot, true);
                            e.active_insert(slot);
                        }
                    }
                    self.next_wipe = end;
                } else {
                    self.phase = Phase::Complete;
                }
            }
            Phase::Complete => {}
        }
        e.update(self);
        true
    }
}
