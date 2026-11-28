//! vhstape on the fx engine (old engine: effects/vhstape.rs).
//!
//! Lines are the row groups of get_characters_grouped (bottom to top), kept
//! flat; a line is its index. Each character's four paths are created back
//! to back, so the restore and wave paths sit at fixed offsets from its
//! glitch path; its snow, final snow and final redraw scenes are kept per
//! slot. Glitch-color visuals are memoized per input symbol and snow visuals
//! per (color, symbol). The effect registers no callbacks.

use crate::effects::vhstape::VhsTapeConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, Frame, Hooks, Sym, Visual, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, Gradient};
use crate::utils::pycompat::round_half_even;

const SNOW_CHARS: [&str; 4] = ["#", "*", ".", ":"];
const SNOW_FRAMES: usize = 25;
const FINAL_SNOW_FRAMES: usize = 30;

/// Path offsets from a character's glitch path.
const P_RESTORE: u32 = 1;
const P_MID: u32 = 2;
const P_END: u32 = 3;
/// The glitch wave's lines take mid, end, mid.
const WAVE_PATHS: [u32; 3] = [P_MID, P_END, P_MID];

/// A character's scenes that the effect activates itself.
const S_SNOW: usize = 0;
const S_FINAL_SNOW: usize = 1;
const S_FINAL_REDRAW: usize = 2;
/// rgb_glitch_fwd.
const S_FWD: usize = 3;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Glitching,
    Noise,
    Redraw,
    Complete,
}

/// A short list of line indices (the glitch wave and the glitch lines hold at
/// most three).
#[derive(Default, Clone, Copy)]
struct Lines {
    at: [u32; 3],
    len: usize,
}

impl Lines {
    #[inline]
    fn as_slice(&self) -> &[u32] {
        &self.at[..self.len]
    }

    #[inline]
    fn contains(&self, line: u32) -> bool {
        self.as_slice().contains(&line)
    }

    #[inline]
    fn push(&mut self, line: u32) {
        self.at[self.len] = line;
        self.len += 1;
    }
}

struct NoHooks;

impl Hooks for NoHooks {}

pub struct VhsTape {
    config: VhsTapeConfig,
    /// Line k's characters are `line_slots[line_start[k]..line_start[k + 1]]`.
    line_slots: Vec<u32>,
    line_start: Vec<u32>,
    /// Per slot: the glitch path, and the scenes S_*.
    glitch_path: Vec<u32>,
    scenes: Vec<[u32; 4]>,
    /// Upstream `active_glitch_wave_top: int | None`.
    wave_top: Option<i64>,
    wave: Lines,
    glitch: Lines,
    glitching_steps_elapsed: i64,
    phase: Phase,
    /// Lines 0..to_redraw are still to redraw (popped from the top).
    to_redraw: usize,
    redrawing: bool,
}

impl VhsTape {
    pub fn new(config: VhsTapeConfig) -> Self {
        VhsTape {
            config,
            line_slots: Vec::new(),
            line_start: Vec::new(),
            glitch_path: Vec::new(),
            scenes: Vec::new(),
            wave_top: None,
            wave: Lines::default(),
            glitch: Lines::default(),
            glitching_steps_elapsed: 0,
            phase: Phase::Glitching,
            to_redraw: 0,
            redrawing: false,
        }
    }

    #[inline]
    fn line_count(&self) -> usize {
        self.line_start.len() - 1
    }

    #[inline]
    fn line(&self, line: u32) -> &[u32] {
        let (start, end) = (*self.line_start.at(line), *self.line_start.at(line + 1));
        &self.line_slots[start as usize..end as usize]
    }

    /// Line.line_movement_complete: no character has an active path.
    #[inline]
    fn line_complete(&self, e: &Engine, line: u32) -> bool {
        self.line(line)
            .iter()
            .all(|&slot| *e.ch.path.at(slot) == NONE)
    }

    fn lines_complete(&self, e: &Engine, lines: Lines) -> bool {
        lines
            .as_slice()
            .iter()
            .all(|&line| self.line_complete(e, line))
    }

    fn line_insert(&self, e: &mut Engine, line: u32) {
        for &slot in self.line(line) {
            e.active_insert(slot);
        }
    }

    #[inline]
    fn random_speed(e: &mut Engine) -> f64 {
        40.0 / e.rng.randint(20, 40) as f64
    }

    /// Line.set_hold_time on the glitch paths.
    fn line_set_hold(&self, e: &mut Engine, line: u32, hold_time: i64) {
        for &slot in self.line(line) {
            e.path_set_hold(*self.glitch_path.at(slot), hold_time);
        }
    }

    /// Line.glitch(final=False): new glitch and restore speeds (drawn in that
    /// order), then the glitch path.
    fn line_glitch(&self, e: &mut Engine, line: u32) {
        for &slot in self.line(line) {
            let glitch = *self.glitch_path.at(slot);
            let glitch_speed = Self::random_speed(e);
            let restore_speed = Self::random_speed(e);
            e.path_set_speed(glitch, glitch_speed);
            e.path_set_speed(glitch + P_RESTORE, restore_speed);
            e.activate_path(&mut NoHooks, slot, glitch);
            e.activate_scene(&mut NoHooks, slot, self.scenes.at(slot)[S_FWD]);
        }
    }

    /// Line.restore: a new restore speed, then the restore path.
    fn line_restore(&self, e: &mut Engine, line: u32) {
        for &slot in self.line(line) {
            let restore = *self.glitch_path.at(slot) + P_RESTORE;
            let speed = Self::random_speed(e);
            e.path_set_speed(restore, speed);
            e.activate_path(&mut NoHooks, slot, restore);
        }
    }

    /// Line.activate_path with the path at `offset` from the glitch path.
    fn line_activate_path(&self, e: &mut Engine, line: u32, offset: u32) {
        for &slot in self.line(line) {
            e.activate_path(&mut NoHooks, slot, *self.glitch_path.at(slot) + offset);
            e.activate_scene(&mut NoHooks, slot, self.scenes.at(slot)[S_FWD]);
        }
    }

    fn line_scene(&self, e: &mut Engine, line: u32, scene: usize) {
        for &slot in self.line(line) {
            e.activate_scene(&mut NoHooks, slot, self.scenes.at(slot)[scene]);
        }
    }

    /// VHSTapeIterator.glitch_wave. The caller has established that every
    /// wave line completed its movement, which is its only other condition.
    fn glitch_wave(&mut self, e: &mut Engine) {
        let (text_bottom, text_top, text_height) = (
            e.canvas.text_bottom,
            e.canvas.text_top,
            e.canvas.text_height,
        );
        // Python falsy check: None, or 0
        if matches!(self.wave_top, None | Some(0)) {
            if text_height < 3 {
                return;
            }
            // a wave top in the top half of the canvas or at least 3 rows up
            let lower = round_half_even(text_height as f64 * 0.5).max(3);
            self.wave_top = Some(text_bottom + e.rng.randint(lower, text_height));
        }
        if self.wave.len != 0 {
            // only move 30% of the time (the outer condition draws first)
            let should_move = e.rng.random() < 0.3;
            let delta = if should_move {
                if e.rng.random() < 0.3 {
                    1
                } else {
                    -1
                }
            } else {
                0
            };
            let top = (self.wave_top.unwrap() + delta).min(text_top).max(2);
            self.wave_top = Some(top);
        }
        // the lines of rows wave_top - 2 ..= wave_top
        let wave_top = self.wave_top.unwrap();
        let mut new_wave = Lines::default();
        for row in wave_top - 2..=wave_top {
            let line = row - (text_bottom - 1);
            if line >= 0 && (line as usize) < self.line_count() {
                new_wave.push(line as u32);
            }
        }
        let old_wave = self.wave;
        for &line in old_wave.as_slice() {
            if !new_wave.contains(line) {
                self.line_restore(e, line);
                self.line_insert(e, line);
            }
        }
        self.wave = new_wave;
        if wave_top < text_bottom + 2 {
            for &line in new_wave.as_slice() {
                self.line_restore(e, line);
                self.line_insert(e, line);
            }
            self.wave = Lines::default();
            self.wave_top = None;
        } else {
            for (&line, &offset) in new_wave.as_slice().iter().zip(&WAVE_PATHS) {
                self.line_activate_path(e, line, offset);
                self.line_insert(e, line);
            }
        }
    }

    fn glitching(&mut self, e: &mut Engine) {
        if self.lines_complete(e, self.wave) {
            self.glitch_wave(e);
        }
        // drop the glitch lines that completed their movement (order kept)
        let mut kept = Lines::default();
        for &line in self.glitch.as_slice() {
            if !self.line_complete(e, line) {
                kept.push(line);
            }
        }
        self.glitch = kept;
        if e.rng.random() < self.config.glitch_line_chance && self.glitch.len < 3 {
            let line = e.rng.choice_index(self.line_count()) as u32;
            if !self.wave.contains(line) && !self.glitch.contains(line) {
                let hold_time = e.rng.randint(20, 75);
                self.line_set_hold(e, line, hold_time);
                self.glitch.push(line);
                self.line_glitch(e, line);
                self.line_insert(e, line);
            }
        }
        if e.rng.random() < self.config.noise_chance {
            for line in 0..self.line_count() as u32 {
                self.line_scene(e, line, S_SNOW);
                if !self.wave.contains(line) && !self.glitch.contains(line) {
                    self.line_insert(e, line);
                }
            }
        }
        self.glitching_steps_elapsed += 1;
        if self.glitching_steps_elapsed >= self.config.total_glitch_time {
            for &line in self.wave.as_slice() {
                self.line_restore(e, line);
            }
            for &line in self.glitch.as_slice() {
                self.line_restore(e, line);
            }
            self.phase = Phase::Noise;
        }
    }
}

impl Hooks for VhsTape {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

#[inline]
fn visual(e: &mut Engine, sym: Sym, fg: Option<Color>, bg: Option<Color>) -> Visual {
    e.visuals.make(
        &e.symbols,
        VisualInfo {
            sym,
            fg,
            bg,
            attrs: HAS_COLORS,
        },
    )
}

impl Effect for VhsTape {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
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
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let gray = Color::from_hex("808080").unwrap();

        let names = ["glitch", "restore", "glitch_wave_mid", "glitch_wave_end"].map(|n| e.name(n));
        let [glitch, restore, wave_mid, wave_end] = names;
        let [base, fwd, bwd, snow, final_snow, final_redraw] = [
            "base",
            "rgb_glitch_fwd",
            "rgb_glitch_bwd",
            "snow",
            "final_snow",
            "final_redraw",
        ]
        .map(|n| e.name(n));

        // (noise color, snow symbol) -> visual, and the redraw block
        let snow_syms = SNOW_CHARS.map(|s| e.sym(s));
        let mut snow_memo = Vec::with_capacity(config.noise_colors.len() * SNOW_CHARS.len());
        for &color in &config.noise_colors {
            for &sym in &snow_syms {
                snow_memo.push(visual(e, sym, Some(color), None));
            }
        }
        let block_sym = e.sym("█");
        let block = visual(e, block_sym, Some(Color::from_hex("ffffff").unwrap()), None);
        // input symbol -> its visuals in the glitch line colors (NONE: not made)
        let line_colors = config.glitch_line_colors.len();
        let mut glitch_memo: Vec<Visual> = Vec::new();

        let rows =
            e.get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowBottomToTop);
        let slots = e.char_count();
        self.glitch_path = vec![NONE; slots];
        self.scenes = vec![[NONE; 4]; slots];
        let chars: usize = rows.iter().map(Vec::len).sum();
        e.scenes.reserve(
            chars * 7,
            chars * (1 + 2 * line_colors + SNOW_FRAMES + 1 + FINAL_SNOW_FRAMES + 2),
        );
        self.line_start.push(0);
        let mut frames: Vec<Frame> = Vec::with_capacity(FINAL_SNOW_FRAMES.max(line_colors) + 1);
        let mut draws = [0u32; 2 * (SNOW_FRAMES + FINAL_SNOW_FRAMES)];
        let noise_count = config.noise_colors.len();
        for row in &rows {
            // Line.build_line_effects: offset, direction and hold time per line
            let offset = e.rng.randint(4, 25);
            let direction = [-1i64, 1][e.rng.choice_index(2)];
            let hold_time = e.rng.randint(1, 50);
            for &slot in row {
                let input = e.input_coord(slot);
                let sym = e.input_sym(slot);
                let (stable_fg, stable_bg, final_fg, final_bg) = if dynamic {
                    let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                    (fg.or(Some(gray)), bg, fg, bg)
                } else {
                    let color = Some(
                        *final_gradient_mapping
                            .get(&input)
                            .expect("gradient mapping fg"),
                    );
                    (color, None, color, None)
                };
                // paths: glitch, restore, glitch_wave_mid, glitch_wave_end
                let shifted = |dx: i64| Coord::new(input.column + dx, input.row);
                let path = e
                    .path_new(slot, 2.0, None, None, hold_time, false, glitch)
                    .map_err(other)?;
                e.path_new_waypoint(path, shifted(offset * direction), None, glitch)
                    .map_err(other)?;
                let p = e
                    .path_new(slot, 2.0, None, None, 0, false, restore)
                    .map_err(other)?;
                e.path_new_waypoint(p, input, None, restore)
                    .map_err(other)?;
                let p = e
                    .path_new(slot, 2.0, None, None, 0, false, wave_mid)
                    .map_err(other)?;
                e.path_new_waypoint(p, shifted(8), None, wave_mid)
                    .map_err(other)?;
                let p = e
                    .path_new(slot, 2.0, None, None, 0, false, wave_end)
                    .map_err(other)?;
                e.path_new_waypoint(p, shifted(14), None, wave_end)
                    .map_err(other)?;
                debug_assert_eq!(p, path + P_END);
                self.glitch_path[slot as usize] = path;

                let stable = visual(e, sym, stable_fg, stable_bg);
                let scene = e.scene_new(slot, base, false, None, None);
                e.add_frame_visual(scene, stable, 1).map_err(other)?;
                // the input symbol in each glitch line color, forward then backward
                let memo_at = sym.0 as usize * line_colors;
                if glitch_memo.len() < memo_at + line_colors {
                    glitch_memo.resize(memo_at + line_colors, Visual(NONE));
                }
                if glitch_memo[memo_at].0 == NONE {
                    for (i, &color) in config.glitch_line_colors.iter().enumerate() {
                        glitch_memo[memo_at + i] = visual(e, sym, Some(color), None);
                    }
                }
                let glitch_visuals = &glitch_memo[memo_at..memo_at + line_colors];
                frames.clear();
                frames.extend(glitch_visuals.iter().map(|&visual| Frame {
                    visual,
                    duration: 1,
                }));
                let fwd_scene = e.scene_new(slot, fwd, false, Some(SyncMetric::Step), None);
                e.add_frames_visual(fwd_scene, &frames).map_err(other)?;
                frames.reverse();
                let scene = e.scene_new(slot, bwd, false, Some(SyncMetric::Step), None);
                e.add_frames_visual(scene, &frames).map_err(other)?;
                // snow: 25 draws of (symbol, color), then final_snow's 30
                for pair in draws.chunks_exact_mut(2) {
                    pair[0] = e.rng.choice_index(SNOW_CHARS.len()) as u32;
                    pair[1] = e.rng.choice_index(noise_count) as u32;
                }
                let (snow_draws, final_draws) = draws.split_at(2 * SNOW_FRAMES);
                let snow_frames = |draws: &[u32], frames: &mut Vec<Frame>| {
                    frames.clear();
                    frames.extend(draws.chunks_exact(2).map(|pair| Frame {
                        visual: snow_memo[pair[1] as usize * SNOW_CHARS.len() + pair[0] as usize],
                        duration: 2,
                    }));
                };
                let scene = e.scene_new(slot, snow, false, None, None);
                snow_frames(snow_draws, &mut frames);
                frames.push(Frame {
                    visual: stable,
                    duration: 1,
                });
                e.add_frames_visual(scene, &frames).map_err(other)?;
                let snow_scene = scene;
                let final_snow_scene = e.scene_new(slot, final_snow, false, None, None);
                let scene = e.scene_new(slot, final_redraw, false, None, None);
                let final_visual = visual(e, sym, final_fg, final_bg);
                e.add_frames_visual(
                    scene,
                    &[
                        Frame {
                            visual: block,
                            duration: 6,
                        },
                        Frame {
                            visual: final_visual,
                            duration: 1,
                        },
                    ],
                )
                .map_err(other)?;
                snow_frames(final_draws, &mut frames);
                e.add_frames_visual(final_snow_scene, &frames)
                    .map_err(other)?;
                self.scenes[slot as usize] = [snow_scene, final_snow_scene, scene, fwd_scene];

                // events. Only the effect activates the glitch and wave
                // paths, so it activates their rgb_glitch_fwd scene itself
                // right after (what their PATH_ACTIVATED events would do);
                // restore is also activated by glitch's PATH_COMPLETE.
                let events = [
                    (
                        Event::PathComplete,
                        Caller::Path(glitch),
                        Action::ActivatePath(restore),
                    ),
                    (
                        Event::PathActivated,
                        Caller::Path(restore),
                        Action::ActivateScene(bwd),
                    ),
                    (
                        Event::SceneComplete,
                        Caller::Scene(bwd),
                        Action::ActivateScene(base),
                    ),
                ];
                for (event, caller, action) in events {
                    e.register_event(slot, event, caller, action)
                        .map_err(other)?;
                }
            }
            self.line_slots.extend_from_slice(row);
            self.line_start.push(self.line_slots.len() as u32);
        }

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            e.set_visible(slot, true);
            e.activate_scene_name(self, slot, base);
        }
        self.glitching_steps_elapsed = 0;
        self.phase = Phase::Glitching;
        self.to_redraw = self.line_count();
        self.redrawing = false;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        match self.phase {
            Phase::Glitching => self.glitching(e),
            Phase::Noise => {
                if e.active_is_empty() {
                    for k in 0..self.line_slots.len() {
                        let slot = self.line_slots[k];
                        e.activate_scene(&mut NoHooks, slot, self.scenes.at(slot)[S_FINAL_SNOW]);
                        e.active_insert(slot);
                    }
                    self.phase = Phase::Redraw;
                }
            }
            Phase::Redraw => {
                // redraw lines one by one, the top line first
                if self.redrawing || e.active_is_empty() {
                    self.redrawing = true;
                    if self.to_redraw > 0 {
                        self.to_redraw -= 1;
                        let line = self.to_redraw as u32;
                        self.line_scene(e, line, S_FINAL_REDRAW);
                        self.line_insert(e, line);
                    } else {
                        self.phase = Phase::Complete;
                    }
                }
            }
            Phase::Complete => {
                if e.active_is_empty() {
                    return false;
                }
            }
        }
        e.update(self);
        true
    }
}
