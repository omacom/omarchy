//! thunderstorm on the fx engine (old engine: effects/thunderstorm.rs).
//!
//! Two particle pools (rain, sparks) and a hand-managed stack of strike
//! characters (available / pending / active lists). The storm budget reads
//! the clock at exactly the old engine's points: build, fade_complete and
//! every storm frame. Characters are created, scenes built and RNG draws
//! taken in the old engine's order, so slots and the random stream line up.
//!
//! Frames are memoized: a text character's four scenes by (symbol, visible
//! colors, input colors), a spark's glow by symbol, a strike character's
//! flash and fade by strike symbol (config only); a scene is one bulk append.

use std::collections::HashMap;

use crate::effects::thunderstorm::ThunderstormConfig;
use crate::engine::animation::{Animation, ExistingColorHandling};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::particles::{ParticlePool, ParticleReset};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym, NONE};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::floor_div;

/// fade_complete: phase -> storm, restart the clock.
const CB_FADE_COMPLETE: u32 = 0;
/// hide_character.
const CB_HIDE_CHARACTER: u32 = 1;
/// make_char_glow.
const CB_MAKE_CHAR_GLOW: u32 = 2;
/// return_strike_to_pool.
const CB_RETURN_STRIKE_TO_POOL: u32 = 3;
/// set_strike_in_progress_false.
const CB_SET_STRIKE_IN_PROGRESS_FALSE: u32 = 4;
/// rain_pool.reclaim_on_event.
const CB_RECLAIM_RAIN: u32 = 5;
/// spark_pool.reclaim_on_event.
const CB_RECLAIM_SPARK: u32 = 6;

/// The strike symbols, in setup_lightning_strike's choice order.
const STRIKE_SYMBOLS: [&str; 3] = ["\\", "/", "|"];
const BACKSLASH: u8 = 0;
const SLASH: u8 = 1;

const RESET: ParticleReset = ParticleReset {
    clear_paths: true,
    clear_scenes: false,
    clear_events: true,
    deactivate_path: true,
    deactivate_scene: true,
    reset_appearance: false,
};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    PreStorm,
    Waiting,
    Storm,
    Complete,
}

/// Particle setup activates scenes and paths nobody listens to (their events
/// were just cleared).
struct NoHooks;

impl Hooks for NoHooks {}

/// A memoized text character: where its frames start in `text_frames`, the
/// glow, fade, unfade and flash frame counts, and the first plain scenes
/// built from them (NONE until one is), which later characters copy.
#[derive(Clone, Copy)]
struct TextFrames {
    start: u32,
    counts: [u8; 4],
    templates: [u32; 4],
}

pub struct Thunderstorm {
    config: ThunderstormConfig,
    phase: Phase,
    delay: i64,
    strike_progression_delay: i64,
    strike_in_progress: bool,
    strike_branch_chance: f64,
    storm_start_time: f64,
    rain_pool: Option<ParticlePool>,
    spark_pool: Option<ParticlePool>,
    /// The strike lists: pending is consumed from `pending_head`.
    pending: Vec<u32>,
    pending_head: usize,
    available: Vec<u32>,
    active_strikes: Vec<u32>,
    pending_glow: Vec<u32>,
    /// Input characters, top to bottom, left to right.
    text: Vec<u32>,
    /// Per slot: the text scenes; `flash` also holds a strike character's
    /// flash scene, and `strike_sym` its strike symbol index.
    glow: Vec<u32>,
    fade: Vec<u32>,
    unfade: Vec<u32>,
    flash: Vec<u32>,
    strike_sym: Vec<u8>,
    strike_syms: [Sym; 3],
    /// Per strike symbol: the flash and fade frames.
    strike_flash: [Vec<Frame>; 3],
    strike_fade: [Vec<Frame>; 3],
    spark_frames: Vec<(Sym, Vec<Frame>)>,
    rain_color: Color,
    names: Names,
}

#[derive(Clone, Copy)]
struct Names {
    glow: Name,
    fade: Name,
    unfade: Name,
    flash: Name,
}

impl Thunderstorm {
    pub fn new(config: ThunderstormConfig) -> Self {
        Thunderstorm {
            config,
            phase: Phase::PreStorm,
            delay: 0,
            strike_progression_delay: 0,
            strike_in_progress: false,
            strike_branch_chance: 0.05,
            storm_start_time: 0.0,
            rain_pool: None,
            spark_pool: None,
            pending: Vec::new(),
            pending_head: 0,
            available: Vec::new(),
            active_strikes: Vec::new(),
            pending_glow: Vec::new(),
            text: Vec::new(),
            glow: Vec::new(),
            fade: Vec::new(),
            unfade: Vec::new(),
            flash: Vec::new(),
            strike_sym: Vec::new(),
            strike_syms: [Sym(0); 3],
            strike_flash: Default::default(),
            strike_fade: Default::default(),
            spark_frames: Vec::new(),
            rain_color: Color::from_hex("aaaaff").unwrap(),
            names: Names {
                glow: Name::NONE,
                fade: Name::NONE,
                unfade: Name::NONE,
                flash: Name::NONE,
            },
        }
    }

    /// build_strike_characters: "|" characters at (1, 1) onto the available
    /// stack.
    fn build_strike_characters(&mut self, e: &mut Engine, count: usize) {
        let bar = self.strike_syms[2];
        for _ in 0..count {
            let slot = e.add_character_sym(bar, Coord::new(1, 1));
            self.available.push(slot);
        }
        let slots = e.char_count();
        self.flash.resize(slots, NONE);
        self.strike_sym.resize(slots, 0);
    }

    /// setup_lightning_strike, with its recursive branching.
    fn setup_lightning_strike(&mut self, e: &mut Engine, branch_neighbor: u32) {
        let mut branch_neighbor = branch_neighbor;
        let (mut column, mut row);
        if branch_neighbor != NONE {
            let coord = e.coord(branch_neighbor);
            column = coord.column;
            row = coord.row;
        } else {
            column = e.rng.randint(1, e.canvas.right);
            row = e.canvas.top;
        }
        while row >= e.canvas.bottom {
            if self.available.is_empty() {
                self.build_strike_characters(e, 20);
            }
            let symbol: u8;
            if branch_neighbor != NONE {
                // strike characters are all created with input symbol "|", so
                // the "/" and "\\" arms are unreachable (upstream too)
                let neighbor_sym = e.input_sym(branch_neighbor);
                if neighbor_sym == self.strike_syms[SLASH as usize] {
                    column += 1;
                    symbol = [2, BACKSLASH][e.rng.choice_index(2)];
                } else if neighbor_sym == self.strike_syms[BACKSLASH as usize] {
                    column -= 1;
                    symbol = [2, SLASH][e.rng.choice_index(2)];
                } else {
                    // delta = choice([-1, 1])
                    if e.rng.choice_index(2) == 1 {
                        column += 1;
                        symbol = BACKSLASH;
                    } else {
                        column -= 1;
                        symbol = SLASH;
                    }
                }
            } else {
                symbol = e.rng.choice_index(3) as u8;
            }

            // get_next_strike_char: its scenes and events are dropped
            let strike_char = self.available.pop().unwrap();
            e.scenes_clear(strike_char);
            e.event_clear(strike_char);
            e.set_coordinate(strike_char, Coord::new(column, row));
            self.strike_sym[strike_char as usize] = symbol;
            let colors = ColorPair::new(Some(self.config.lightning_color), None);
            e.set_appearance(
                strike_char,
                Some(self.strike_syms[symbol as usize]),
                Some(colors),
            );
            row -= 1;
            if symbol == BACKSLASH {
                column += 1;
            } else if symbol == SLASH {
                column -= 1;
            }

            self.pending.push(strike_char);
            // random() is always drawn (the left operand of `and`)
            if e.rng.random() < self.strike_branch_chance && branch_neighbor == NONE {
                self.strike_branch_chance -= 0.01;
                self.setup_lightning_strike(e, strike_char);
            }
            branch_neighbor = NONE;
        }
        self.strike_branch_chance = 0.05;
    }

    /// lightning_strike: lay out the bolt, give each of its characters flash
    /// (eased by a fresh random curve) and fade scenes, and ease the text's
    /// flash scenes by the same curve.
    fn lightning_strike(&mut self, e: &mut Engine) {
        self.pending.clear();
        self.pending_head = 0;
        self.setup_lightning_strike(e, NONE);
        let flash_ease = Easing::CubicBezier(0.0, 1.6, 1.0, e.rng.uniform(-0.6, 0.4));
        let n = self.names;
        for &strike_char in &self.pending {
            let symbol = self.strike_sym[strike_char as usize] as usize;
            let flash = e.scene_new(strike_char, n.flash, false, None, Some(flash_ease));
            e.add_frames_visual(flash, &self.strike_flash[symbol])
                .expect("flash frame failed");
            self.flash[strike_char as usize] = flash;
            let fade = e.scene_new(strike_char, n.fade, false, None, None);
            e.add_frames_visual(fade, &self.strike_fade[symbol])
                .expect("fade frame failed");
            e.set_layer(strike_char, 1);
            let register = |e: &mut Engine, caller: Name, action: Action| {
                e.register_event(
                    strike_char,
                    Event::SceneComplete,
                    Caller::Scene(caller),
                    action,
                )
                .expect("strike event registration failed");
            };
            register(e, n.flash, Action::ActivateScene(n.fade));
            register(e, n.fade, Action::Callback(CB_HIDE_CHARACTER, 0));
            register(e, n.fade, Action::Callback(CB_MAKE_CHAR_GLOW, 0));
            register(e, n.fade, Action::Callback(CB_RETURN_STRIKE_TO_POOL, 0));
        }
        for &slot in &self.text {
            e.scene_set_ease(self.flash[slot as usize], flash_ease);
        }
    }

    /// step_lightning_strike: reveal 1-3 bolt characters every other frame;
    /// after the last, sparks fly and everything flashes.
    fn step_lightning_strike(&mut self, e: &mut Engine) {
        if self.strike_progression_delay != 0 {
            self.strike_progression_delay -= 1;
            return;
        }
        if self.pending_head >= self.pending.len() {
            return;
        }
        let batch = e.rng.randint(1, 3);
        for _ in 0..batch {
            if self.pending_head >= self.pending.len() {
                break;
            }
            let next_strike_char = self.pending[self.pending_head];
            self.pending_head += 1;
            self.active_strikes.push(next_strike_char);
            e.set_visible(next_strike_char, true);
            self.strike_progression_delay = 1;
            if self.pending_head < self.pending.len() {
                continue;
            }
            self.pending.clear();
            self.pending_head = 0;
            let spark_count = e.rng.randint(12, 18);
            let glow = self.names.glow;
            let pool = self.spark_pool.as_mut().unwrap();
            let spark_frames = &self.spark_frames;
            for _ in 0..spark_count {
                let origin = e.coord(*self.active_strikes.last().unwrap());
                pool.emit(
                    e,
                    origin,
                    None,
                    true,
                    RESET,
                    |e, particle| initialize_spark(e, particle, glow, spark_frames),
                    |e, particle| setup_sparks_for_impact(e, particle, glow),
                );
            }
            e.register_event(
                next_strike_char,
                Event::SceneComplete,
                Caller::Scene(self.names.fade),
                Action::Callback(CB_SET_STRIKE_IN_PROGRESS_FALSE, 0),
            )
            .expect("strike-done registration failed");
            let strikes = std::mem::take(&mut self.active_strikes);
            for &strike_char in &strikes {
                let scene = self.flash[strike_char as usize];
                e.activate_scene(self, strike_char, scene);
                e.active_insert(strike_char);
            }
            self.active_strikes = strikes;
            self.active_strikes.clear();
            self.activate_text(e, SceneKind::Flash);
        }
    }

    /// rain: every few frames, 1-6 raindrops from above the canvas.
    fn rain(&mut self, e: &mut Engine) {
        if self.delay != 0 {
            self.delay -= 1;
            return;
        }
        let count = e.rng.randint(1, 6);
        let pool = self.rain_pool.as_mut().unwrap();
        let rain_color = self.rain_color;
        for _ in 0..count {
            let spawn_column = e.rng.randint(1 - e.canvas.top, e.canvas.right);
            let origin = Coord::new(spawn_column - 1, e.canvas.top + 1);
            pool.emit(
                e,
                origin,
                None,
                true,
                RESET,
                |e, particle| initialize_raindrop(e, particle, rain_color),
                setup_raindrop,
            );
        }
        self.delay = e.rng.randint(1, 7);
    }

    /// Activate one text scene on every text character, in `text` order.
    fn activate_text(&mut self, e: &mut Engine, kind: SceneKind) {
        let text = std::mem::take(&mut self.text);
        let scenes = match kind {
            SceneKind::Fade => std::mem::take(&mut self.fade),
            SceneKind::Unfade => std::mem::take(&mut self.unfade),
            SceneKind::Flash => std::mem::take(&mut self.flash),
        };
        for &slot in &text {
            e.activate_scene(self, slot, scenes[slot as usize]);
            e.active_insert(slot);
        }
        match kind {
            SceneKind::Fade => self.fade = scenes,
            SceneKind::Unfade => self.unfade = scenes,
            SceneKind::Flash => self.flash = scenes,
        }
        self.text = text;
    }

    /// The frames of a text character's glow, fade, unfade and flash scenes
    /// (build()'s scene setup), for its symbol and colors.
    #[allow(clippy::too_many_arguments)]
    fn text_frames(
        &self,
        e: &mut Engine,
        out: &mut Vec<Frame>,
        sym: Sym,
        visible: ColorPair,
        restore: ColorPair,
        dynamic: bool,
    ) -> Result<[u8; 4], EngineError> {
        let config = &self.config;
        let storm = adjust_color_pair_brightness(&visible, 0.5);
        let storm_fg = storm.fg_color.expect("storm fg");
        let visible_fg = visible.fg_color.expect("visible fg");
        let frame = |e: &mut Engine,
                     out: &mut Vec<Frame>,
                     fg: Option<Color>,
                     bg: Option<Color>,
                     duration: i64| {
            let visual = e.visuals.make(
                &e.symbols,
                VisualInfo {
                    sym,
                    fg,
                    bg,
                    attrs: HAS_COLORS,
                },
            );
            out.push(Frame {
                visual,
                duration: duration as u32,
            });
        };
        let mut counts = [0u8; 4];
        let mut mark = out.len();
        let mut count = |out: &Vec<Frame>, i: usize| {
            counts[i] = (out.len() - mark) as u8;
            mark = out.len();
        };
        // post-strike glow and cool
        let glow = gradient(config.glowing_text_color, storm_fg, false)?;
        for &color in &glow {
            frame(e, out, Some(color), storm.bg_color, config.text_glow_time);
        }
        if dynamic {
            frame(
                e,
                out,
                storm.fg_color,
                storm.bg_color,
                config.text_glow_time,
            );
        }
        count(out, 0);
        // fade before the storm
        if dynamic {
            for (fg, bg) in pair_gradient_frames(&visible, &storm)? {
                frame(e, out, fg, bg, 12);
            }
            frame(e, out, storm.fg_color, storm.bg_color, 12);
        } else {
            for &color in &gradient(visible_fg, storm_fg, false)? {
                frame(e, out, Some(color), None, 12);
            }
        }
        count(out, 1);
        // unfade
        if dynamic {
            for (fg, bg) in pair_gradient_frames(&storm, &visible)? {
                frame(e, out, fg, bg, 12);
            }
            frame(e, out, visible.fg_color, visible.bg_color, 12);
            if restore != visible {
                frame(e, out, restore.fg_color, restore.bg_color, 12);
            }
        } else {
            for &color in gradient(visible_fg, storm_fg, false)?.iter().rev() {
                frame(e, out, Some(color), None, 12);
            }
        }
        count(out, 2);
        // lightning flash
        let flash_color = Animation::adjust_color_brightness(&visible_fg, 1.7);
        for &color in &gradient(storm_fg, flash_color, true)? {
            frame(e, out, Some(color), storm.bg_color, 6);
        }
        count(out, 3);
        Ok(counts)
    }
}

#[derive(Clone, Copy)]
enum SceneKind {
    Fade,
    Unfade,
    Flash,
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

fn gradient(start: Color, end: Color, do_loop: bool) -> Result<Vec<Color>, EngineError> {
    Ok(Gradient::with_steps(&[start, end], 7, do_loop)
        .map_err(other)?
        .spectrum)
}

/// _adjust_color_pair_brightness.
fn adjust_color_pair_brightness(colors: &ColorPair, brightness: f64) -> ColorPair {
    ColorPair::new(
        colors
            .fg_color
            .as_ref()
            .map(|c| Animation::adjust_color_brightness(c, brightness)),
        colors
            .bg_color
            .as_ref()
            .map(|c| Animation::adjust_color_brightness(c, brightness)),
    )
}

type Pair = (Option<Color>, Option<Color>);

/// _add_color_pair_gradient_frames' colors: when both endpoint colors exist
/// the gradient has steps + 1 entries but only `range(steps)` are emitted.
fn pair_gradient_frames(start: &ColorPair, end: &ColorPair) -> Result<Vec<Pair>, EngineError> {
    let channel = |a: Option<Color>, b: Option<Color>| -> Result<Vec<Option<Color>>, EngineError> {
        Ok(match (a, b) {
            (Some(a), Some(b)) => gradient(a, b, false)?.into_iter().map(Some).collect(),
            _ => vec![b.or(a); 7],
        })
    };
    let fg = channel(start.fg_color, end.fg_color)?;
    let bg = channel(start.bg_color, end.bg_color)?;
    Ok((0..7).map(|i| (fg[i], bg[i])).collect())
}

/// build_rain_pool's initialize_raindrop.
fn initialize_raindrop(e: &mut Engine, slot: u32, color: Color) {
    e.set_layer(slot, 1);
    e.set_appearance(slot, None, Some(ColorPair::new(Some(color), None)));
}

/// build_spark_pool's _build_spark_characters: an in_circ "glow" scene down
/// the spark gradient.
fn initialize_spark(e: &mut Engine, slot: u32, glow: Name, spark_frames: &[(Sym, Vec<Frame>)]) {
    e.set_layer(slot, 2);
    let scene = e.scene_new(slot, glow, false, None, Some(Easing::InCirc));
    let sym = e.input_sym(slot);
    let frames = &spark_frames
        .iter()
        .find(|(s, _)| *s == sym)
        .expect("spark symbol")
        .1;
    e.add_frames_visual(scene, frames)
        .expect("spark glow frame failed");
}

/// _setup_raindrop: a straight fall, reclaimed when the path completes.
fn setup_raindrop(e: &mut Engine, slot: u32) {
    let origin = e.coord(slot);
    let speed = e.rng.uniform(0.5, 1.5);
    let path = e
        .path_new(slot, speed, None, None, 0, false, Name::NONE)
        .expect("rain new_path failed");
    let target = Coord::new(origin.column + e.canvas.top + 1, e.canvas.bottom - 1);
    e.path_new_waypoint(path, target, None, Name::NONE)
        .expect("rain new_waypoint failed");
    let name = e.paths.recs[path as usize].name;
    e.register_event(
        slot,
        Event::PathComplete,
        Caller::Path(name),
        Action::Callback(CB_RECLAIM_RAIN, 0),
    )
    .expect("rain reclaim registration failed");
    e.activate_path(&mut NoHooks, slot, path);
}

/// _setup_sparks_for_impact: an out_quint bezier arc to the canvas bottom,
/// the glow scene, reclaimed when the glow ends.
fn setup_sparks_for_impact(e: &mut Engine, slot: u32, glow: Name) {
    let impact = e.coord(slot);
    let speed = e.rng.uniform(0.1, 0.25);
    let path = e
        .path_new(
            slot,
            speed,
            Some(Easing::OutQuint),
            None,
            30,
            false,
            Name::NONE,
        )
        .expect("spark new_path failed");
    let offset = e.rng.randint(4, 20) * [1, -1][e.rng.choice_index(2)];
    let target = Coord::new(impact.column + offset, e.canvas.bottom);
    let bezier_column = impact.column - floor_div(impact.column - target.column, 2);
    let bezier_row = e.rng.randint(1, e.canvas.top);
    e.path_new_waypoint(
        path,
        target,
        Some(&[Coord::new(bezier_column, bezier_row)]),
        Name::NONE,
    )
    .expect("spark new_waypoint failed");
    e.register_event(
        slot,
        Event::SceneComplete,
        Caller::Scene(glow),
        Action::Callback(CB_RECLAIM_SPARK, 0),
    )
    .expect("spark reclaim registration failed");
    let scene = e.scene_find(slot, glow).expect("spark glow scene");
    e.activate_scene(&mut NoHooks, slot, scene);
    e.activate_path(&mut NoHooks, slot, path);
}

impl Hooks for Thunderstorm {
    fn callback(&mut self, e: &mut Engine, slot: u32, id: u32, _arg: i64) {
        match id {
            CB_FADE_COMPLETE => {
                self.phase = Phase::Storm;
                self.storm_start_time = e.clock.now_monotonic();
            }
            CB_HIDE_CHARACTER => e.set_visible(slot, false),
            CB_MAKE_CHAR_GLOW => {
                if let Some(input_char) = e.char_at_input_coord(e.coord(slot)) {
                    if e.is_visible(input_char) {
                        match self.glow.get(input_char as usize) {
                            Some(&scene) if scene != NONE => {
                                e.activate_scene(self, input_char, scene)
                            }
                            _ => {
                                let glow = self.names.glow;
                                e.activate_scene_name(self, input_char, glow)
                            }
                        }
                        self.pending_glow.push(input_char);
                    }
                }
            }
            CB_RETURN_STRIKE_TO_POOL => self.available.push(slot),
            CB_SET_STRIKE_IN_PROGRESS_FALSE => self.strike_in_progress = false,
            CB_RECLAIM_RAIN => self
                .rain_pool
                .as_mut()
                .unwrap()
                .reclaim(e, slot, true, true),
            CB_RECLAIM_SPARK => self
                .spark_pool
                .as_mut()
                .unwrap()
                .reclaim(e, slot, true, true),
            _ => {}
        }
    }
}

impl Effect for Thunderstorm {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        self.names = Names {
            glow: e.name("glow"),
            fade: e.name("fade"),
            unfade: e.name("unfade"),
            flash: e.name("flash"),
        };
        for (i, s) in STRIKE_SYMBOLS.iter().enumerate() {
            self.strike_syms[i] = e.sym(s);
        }
        let background = e.config.terminal_background_color;

        // __init__ preamble: the pools are preallocated, then the storm clock
        // is read once
        let rain_symbols: Vec<Sym> = config.raindrop_symbols.iter().map(|s| e.sym(s)).collect();
        let mut rain_pool = ParticlePool::new(rain_symbols, None, None).map_err(other)?;
        let rain_color = self.rain_color;
        rain_pool
            .preallocate(e, 50, |e, p| initialize_raindrop(e, p, rain_color))
            .map_err(other)?;
        self.rain_pool = Some(rain_pool);
        let spark_gradient = Gradient::with_steps(&[config.spark_glow_color, background], 7, false)
            .map_err(other)?;
        let spark_symbols: Vec<Sym> = config.spark_symbols.iter().map(|s| e.sym(s)).collect();
        for &sym in &spark_symbols {
            if self.spark_frames.iter().any(|(s, _)| *s == sym) {
                continue;
            }
            let frames = spark_gradient
                .spectrum
                .iter()
                .map(|&color| {
                    let visual = e.visuals.make(
                        &e.symbols,
                        VisualInfo {
                            sym,
                            fg: Some(color),
                            bg: None,
                            attrs: HAS_COLORS,
                        },
                    );
                    Frame {
                        visual,
                        duration: config.spark_glow_time as u32,
                    }
                })
                .collect();
            self.spark_frames.push((sym, frames));
        }
        let mut spark_pool = ParticlePool::new(spark_symbols, Some(2000), None).map_err(other)?;
        let glow = self.names.glow;
        let spark_frames = &self.spark_frames;
        spark_pool
            .preallocate(e, 200, |e, p| initialize_spark(e, p, glow, spark_frames))
            .map_err(other)?;
        self.spark_pool = Some(spark_pool);
        self.storm_start_time = e.clock.now_monotonic();

        // build(): the final gradient mapping, 200 strike characters
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
        self.build_strike_characters(e, 200);

        let lightning = config.lightning_color;
        let flash_colors = gradient(
            lightning,
            Animation::adjust_color_brightness(&lightning, 1.7),
            true,
        )?;
        let fade_colors = Gradient::with_steps(&[lightning, background], 6, false)
            .map_err(other)?
            .spectrum;
        for i in 0..3 {
            let sym = self.strike_syms[i];
            let mut frames = |colors: &[Color], duration: u32| -> Vec<Frame> {
                colors
                    .iter()
                    .map(|&color| {
                        let info = VisualInfo {
                            sym,
                            fg: Some(color),
                            bg: None,
                            attrs: HAS_COLORS,
                        };
                        Frame {
                            visual: e.visuals.make(&e.symbols, info),
                            duration,
                        }
                    })
                    .collect()
            };
            self.strike_flash[i] = frames(&flash_colors, 6);
            self.strike_fade[i] = frames(&fade_colors, 2);
        }

        // scenes on the text characters
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let always = e.existing_color_handling() == ExistingColorHandling::Always;
        let neutral_gray = Color::from_hex("808080").unwrap();
        self.text = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        let slots = e.char_count();
        self.glow = vec![NONE; slots];
        self.fade = vec![NONE; slots];
        self.unfade = vec![NONE; slots];
        self.flash.resize(slots, NONE);
        type Key = (
            Sym,
            Option<Color>,
            Option<Color>,
            Option<Color>,
            Option<Color>,
        );
        let mut memo: HashMap<Key, TextFrames, FxBuild> = HashMap::default();
        let mut memo_frames: Vec<Frame> = Vec::new();
        let n = self.names;
        let text = std::mem::take(&mut self.text);
        for &slot in &text {
            let sym = e.input_sym(slot);
            let (input_fg, input_bg) = (e.input_fg(slot), e.input_bg(slot));
            let (visible, restore) = if dynamic {
                (
                    ColorPair::new(Some(input_fg.unwrap_or(neutral_gray)), input_bg),
                    ColorPair::new(input_fg, input_bg),
                )
            } else {
                let visible = ColorPair::new(
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                );
                (visible, visible)
            };
            let key = (
                sym,
                visible.fg_color,
                visible.bg_color,
                restore.fg_color,
                restore.bg_color,
            );
            let tf = match memo.get_mut(&key) {
                Some(tf) => tf,
                None => {
                    let start = memo_frames.len() as u32;
                    let counts =
                        self.text_frames(e, &mut memo_frames, sym, visible, restore, dynamic)?;
                    memo.entry(key).or_insert(TextFrames {
                        start,
                        counts,
                        templates: [NONE; 4],
                    })
                }
            };
            // a copy shares its template's frames: the scenes are pristine and
            // no frame is appended to them later
            let clone = tf.templates[0] != NONE && !(always && e.uses_preexisting_colors(slot));
            let mut at = tf.start as usize;
            for (i, name) in [n.glow, n.fade, n.unfade, n.flash].into_iter().enumerate() {
                let count = tf.counts[i] as usize;
                let scene = if clone {
                    e.scene_copy(slot, tf.templates[i], name)
                } else {
                    let scene = e.scene_new(slot, name, false, None, None);
                    e.add_frames_visual(scene, &memo_frames[at..at + count])
                        .map_err(other)?;
                    scene
                };
                at += count;
                let table = match i {
                    0 => &mut self.glow,
                    1 => &mut self.fade,
                    2 => &mut self.unfade,
                    _ => &mut self.flash,
                };
                table[slot as usize] = scene;
            }
            if !clone
                && e.scene(self.glow[slot as usize]).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0
            {
                for (i, table) in [&self.glow, &self.fade, &self.unfade, &self.flash]
                    .into_iter()
                    .enumerate()
                {
                    tf.templates[i] = table[slot as usize];
                }
            }
            e.set_visible(slot, true);
        }
        self.text = text;

        // the first character's fade completing starts the storm
        let reference_char = self.text[0];
        e.register_event(
            reference_char,
            Event::SceneComplete,
            Caller::Scene(n.fade),
            Action::Callback(CB_FADE_COMPLETE, 0),
        )
        .map_err(other)?;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() && self.phase == Phase::Complete {
            return false;
        }
        match self.phase {
            Phase::PreStorm => {
                self.activate_text(e, SceneKind::Fade);
                self.phase = Phase::Waiting;
            }
            Phase::Storm => {
                self.rain(e);
                if !self.strike_in_progress && e.rng.random() < 0.008 {
                    self.strike_in_progress = true;
                    self.lightning_strike(e);
                }
                if self.strike_in_progress {
                    self.step_lightning_strike(e);
                }
                for &glow_char in &self.pending_glow {
                    e.active_insert(glow_char);
                }
                self.pending_glow.clear();
                if e.clock.now_monotonic() - self.storm_start_time >= self.config.storm_time as f64
                    && !self.strike_in_progress
                {
                    self.activate_text(e, SceneKind::Unfade);
                    self.phase = Phase::Complete;
                }
            }
            Phase::Waiting | Phase::Complete => {}
        }
        e.update(self);
        true
    }
}
