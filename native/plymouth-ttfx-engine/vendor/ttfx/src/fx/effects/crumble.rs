//! crumble on the fx engine (old engine: effects/crumble.rs).
//!
//! Every character gets, in the old engine's order: an initial weak scene
//! (auto), the fall path (auto), "weaken", the "top" and "input" paths, the
//! strengthen flash and strengthen scenes (auto) and the distance-synced dust
//! scene (auto, five choice draws), then its events. The old engine's five
//! actions are three callbacks that act on the stored scene and path ids, in
//! the same order, instead of looking them up by name. Characters sharing
//! their (fg, bg) pair share the derived colors and gradients, and characters
//! sharing the pair and their symbol share the frames of every scene but dust.

use std::collections::HashMap;

use crate::effects::crumble::CrumbleConfig;
use crate::engine::animation::{Animation, ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SceneId, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, Visual, NONE};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

const NEUTRAL_GRAY: &str = "808080";
const WHITE: &str = "ffffff";
const DUST_SYMBOLS: [&str; 3] = ["*", ".", ","];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Stage {
    Falling,
    Vacuuming,
    Resetting,
    Complete,
}

/// The colors and gradients derived from one (fg, bg) pair.
struct Derived {
    weak: ColorPair,
    weaken_fg: Option<Vec<Color>>,
    weaken_bg: Option<Vec<Color>>,
    flash_fg: Option<Vec<Color>>,
    flash_bg: Option<Vec<Color>>,
    strengthen_fg: Option<Vec<Color>>,
    strengthen_bg: Option<Vec<Color>>,
    /// Dynamic handling and no input colors: strengthen is one plain frame.
    strengthen_plain: bool,
    /// The dust symbols in the dust colors.
    dust: [Visual; 3],
}

/// A character's scenes and paths.
#[derive(Debug, Clone, Copy)]
struct Parts {
    weaken: SceneId,
    flash: SceneId,
    strengthen: SceneId,
    dust: SceneId,
    fall: u32,
    top: u32,
    input: u32,
}

const NO_PARTS: Parts = Parts {
    weaken: NONE,
    flash: NONE,
    strengthen: NONE,
    dust: NONE,
    fall: NONE,
    top: NONE,
    input: NONE,
};

/// Event callbacks: the old engine's actions by name, on the ids directly.
const WEAKENED: u32 = 0;
const RETURNED: u32 = 1;
const FLASHED: u32 = 2;

/// The frames of a plain character's initial, weaken, flash and strengthen
/// scenes.
struct Frames([Vec<Frame>; 4]);

pub struct Crumble {
    config: CrumbleConfig,
    stage: Stage,
    /// The characters in top-to-bottom order (the reset order).
    order: Vec<u32>,
    pending: Vec<u32>,
    pending_pos: usize,
    unvacuumed: Vec<u32>,
    unvacuumed_pos: usize,
    /// Per slot.
    parts: Vec<Parts>,
    fall_delay: i64,
    max_fall_delay: i64,
    min_fall_delay: i64,
    fall_group_maxsize: i64,
    reset: bool,
}

impl Crumble {
    pub fn new(config: CrumbleConfig) -> Self {
        Crumble {
            config,
            stage: Stage::Falling,
            order: Vec::new(),
            pending: Vec::new(),
            pending_pos: 0,
            unvacuumed: Vec::new(),
            unvacuumed_pos: 0,
            parts: Vec::new(),
            fall_delay: 0,
            max_fall_delay: 0,
            min_fall_delay: 0,
            fall_group_maxsize: 1,
            reset: false,
        }
    }
}

impl Hooks for Crumble {
    fn callback(&mut self, e: &mut Engine, slot: u32, id: u32, _arg: i64) {
        let parts = *self.parts.at(slot);
        match id {
            // weaken complete: fall, on layer 1, as dust
            WEAKENED => {
                e.activate_path(self, slot, parts.fall);
                e.set_layer(slot, 1);
                e.activate_scene(self, slot, parts.dust);
            }
            // input path complete: flash
            RETURNED => e.activate_scene(self, slot, parts.flash),
            // flash complete: strengthen
            FLASHED => e.activate_scene(self, slot, parts.strengthen),
            _ => unreachable!("crumble callback {id}"),
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// Gradient::with_steps([from, to], steps) when both colors are present.
fn pair(
    from: Option<Color>,
    to: Option<Color>,
    steps: i64,
) -> Result<Option<Vec<Color>>, EngineError> {
    match (from, to) {
        (Some(from), Some(to)) => Ok(Some(
            Gradient::with_steps(&[from, to], steps, false)
                .map_err(other)?
                .spectrum,
        )),
        _ => Ok(None),
    }
}

/// Crumble::build's weak, dust, weaken, strengthen flash and strengthen
/// colors for (fg, bg): the input colors under dynamic handling, else (final
/// color, None).
fn derive(
    e: &mut Engine,
    fg: Option<Color>,
    bg: Option<Color>,
    dynamic: bool,
    dust: &[Sym; 3],
) -> Result<Derived, EngineError> {
    let gray = Color::from_hex(NEUTRAL_GRAY).unwrap();
    let white = Some(Color::from_hex(WHITE).unwrap());
    let no_colors = fg.is_none() && bg.is_none();
    // the neutral gray stands in for a missing fg when there are no colors
    let g = if dynamic && no_colors { Some(gray) } else { fg };
    let adjust = |c: Option<Color>, b: f64| c.map(|c| Animation::adjust_color_brightness(&c, b));
    let weak = ColorPair::new(adjust(g, 0.65), adjust(bg, 0.65));
    let dust_colors = ColorPair::new(adjust(g, 0.55), adjust(bg, 0.55));
    let mut visuals = [Visual(NONE); 3];
    for (visual, &sym) in visuals.iter_mut().zip(dust) {
        let info = VisualInfo {
            sym,
            fg: dust_colors.fg_color,
            bg: dust_colors.bg_color,
            attrs: HAS_COLORS,
        };
        *visual = e.visuals.make(&e.symbols, info);
    }
    Ok(Derived {
        weak,
        weaken_fg: pair(weak.fg_color, dust_colors.fg_color, 9)?,
        weaken_bg: pair(weak.bg_color, dust_colors.bg_color, 9)?,
        flash_fg: pair(g, white, 6)?,
        flash_bg: pair(bg, white, 6)?,
        strengthen_fg: pair(white, fg, 9)?,
        strengthen_bg: pair(white, bg, 9)?,
        strengthen_plain: dynamic && no_colors,
        dust: visuals,
    })
}

impl Effect for Crumble {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
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
        let dust_symbols = DUST_SYMBOLS.map(|s| e.sym(s));
        let weaken = e.name("weaken");
        let top = e.name("top");
        let input = e.name("input");
        let control = [Coord::new(canvas.center_column, canvas.center_row)];

        let slots = e.char_count();
        self.parts = vec![NO_PARTS; slots];
        // (fg, bg) -> index into derived; (symbol, pair index) -> the frames
        let mut pair_index: HashMap<(Option<Color>, Option<Color>), u32, FxBuild> =
            HashMap::default();
        let mut derived: Vec<Derived> = Vec::new();
        let mut memo: HashMap<(Sym, u32), Frames, FxBuild> = HashMap::default();

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        // initial, weaken (at most 10), flash (7), strengthen (10), dust (5)
        e.scenes
            .reserve(characters.len() * 5, characters.len() * 33);
        for &slot in &characters {
            let input_coord = e.input_coord(slot);
            let sym = e.input_sym(slot);
            let final_color = *final_gradient_mapping.get(&input_coord).unwrap();
            let key = if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (Some(final_color), None)
            };
            let next_index = derived.len() as u32;
            let index = *pair_index.entry(key).or_insert(next_index);
            if index == next_index {
                derived.push(derive(e, key.0, key.1, dynamic, &dust_symbols)?);
            }
            let d = &derived[index as usize];
            let cached = memo.get(&(sym, index));
            e.set_visible(slot, true);

            // initial scene, fall path, weaken, top and input paths, flash,
            // strengthen and dust, in the old engine's order
            let initial = e.scene_new(slot, Name::NONE, false, None, None);
            match cached {
                Some(f) => e.add_frames_visual(initial, &f.0[0]).map_err(other)?,
                None => e
                    .add_frame(initial, sym, 1, Some(d.weak), 0)
                    .map_err(other)?,
            }
            e.activate_scene(self, slot, initial);
            let fall = e
                .path_new(
                    slot,
                    0.65,
                    Some(Easing::OutBounce),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(
                fall,
                Coord::new(input_coord.column, canvas.bottom),
                None,
                Name::NONE,
            )
            .map_err(other)?;
            let weaken_scene = e.scene_new(slot, weaken, false, None, None);
            match cached {
                Some(f) => e.add_frames_visual(weaken_scene, &f.0[1]).map_err(other)?,
                None => e
                    .apply_gradient(
                        weaken_scene,
                        &[sym],
                        4,
                        d.weaken_fg.as_deref(),
                        d.weaken_bg.as_deref(),
                    )
                    .map_err(other)?,
            }
            let top_path = e
                .path_new(slot, 1.0, Some(Easing::OutQuint), None, 0, false, top)
                .map_err(other)?;
            e.path_new_waypoint(
                top_path,
                Coord::new(input_coord.column, canvas.top),
                Some(&control),
                Name::NONE,
            )
            .map_err(other)?;
            let input_path = e
                .path_new(slot, 1.0, None, None, 0, false, input)
                .map_err(other)?;
            e.path_new_waypoint(input_path, input_coord, None, Name::NONE)
                .map_err(other)?;
            let flash = e.scene_new(slot, Name::NONE, false, None, None);
            match cached {
                Some(f) => e.add_frames_visual(flash, &f.0[2]).map_err(other)?,
                None => e
                    .apply_gradient(
                        flash,
                        &[sym],
                        4,
                        d.flash_fg.as_deref(),
                        d.flash_bg.as_deref(),
                    )
                    .map_err(other)?,
            }
            let strengthen = e.scene_new(slot, Name::NONE, false, None, None);
            match cached {
                Some(f) => e.add_frames_visual(strengthen, &f.0[3]).map_err(other)?,
                None if d.strengthen_plain => e
                    .add_frame(strengthen, sym, 4, Some(ColorPair::default()), 0)
                    .map_err(other)?,
                None => e
                    .apply_gradient(
                        strengthen,
                        &[sym],
                        4,
                        d.strengthen_fg.as_deref(),
                        d.strengthen_bg.as_deref(),
                    )
                    .map_err(other)?,
            }
            if cached.is_none() && e.scene(initial).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0 {
                let frames = [initial, weaken_scene, flash, strengthen]
                    .map(|s| e.scenes.frames_of(s).to_vec());
                memo.insert((sym, index), Frames(frames));
            }
            let dust = e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Distance), None);
            let mut picks = [0u16; 5];
            e.rng.fill_below(DUST_SYMBOLS.len() as u64, &mut picks);
            let frames = picks.map(|p| Frame {
                visual: d.dust[p as usize],
                duration: 1,
            });
            e.add_frames_visual(dust, &frames).map_err(other)?;

            // (the old engine's actions, in order, as callbacks)
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(weaken),
                Action::Callback(WEAKENED, 0),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(input),
                Action::Callback(RETURNED, 0),
            )
            .map_err(other)?;
            let flash_name = e.scene_name(flash);
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(flash_name),
                Action::Callback(FLASHED, 0),
            )
            .map_err(other)?;
            self.parts[slot as usize] = Parts {
                weaken: weaken_scene,
                flash,
                strengthen,
                dust,
                fall,
                top: top_path,
                input: input_path,
            };
        }
        self.pending = characters.clone();
        e.rng.shuffle(&mut self.pending);
        self.order = characters;
        self.fall_delay = 12;
        self.max_fall_delay = 12;
        self.min_fall_delay = 9;
        self.reset = false;
        self.fall_group_maxsize = 1;
        self.stage = Stage::Falling;
        self.unvacuumed = e.input_chars.clone();
        e.rng.shuffle(&mut self.unvacuumed);
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        match self.stage {
            Stage::Falling => {
                if self.pending_pos < self.pending.len() {
                    if self.fall_delay == 0 {
                        let group = e.rng.randint(1, self.fall_group_maxsize);
                        for _ in 0..group {
                            if self.pending_pos < self.pending.len() {
                                let slot = *self.pending.at(self.pending_pos);
                                self.pending_pos += 1;
                                let scene = self.parts.at(slot).weaken;
                                e.activate_scene(self, slot, scene);
                                e.active_insert(slot);
                            }
                        }
                        self.fall_delay = e.rng.randint(self.min_fall_delay, self.max_fall_delay);
                        // 60% chance to grow the group and shorten the delay
                        if e.rng.randint(1, 10) > 4 {
                            self.fall_group_maxsize += 1;
                            self.min_fall_delay = (self.min_fall_delay - 1).max(0);
                            self.max_fall_delay = (self.max_fall_delay - 1).max(0);
                        }
                    } else {
                        self.fall_delay -= 1;
                    }
                }
                if self.pending_pos >= self.pending.len() && e.active_is_empty() {
                    self.stage = Stage::Vacuuming;
                }
            }
            Stage::Vacuuming => {
                if self.unvacuumed_pos < self.unvacuumed.len() {
                    for _ in 0..e.rng.randint(3, 10) {
                        if self.unvacuumed_pos < self.unvacuumed.len() {
                            let slot = *self.unvacuumed.at(self.unvacuumed_pos);
                            self.unvacuumed_pos += 1;
                            let path = self.parts.at(slot).top;
                            e.activate_path(self, slot, path);
                            e.active_insert(slot);
                        }
                    }
                }
                if e.active_is_empty() {
                    self.stage = Stage::Resetting;
                }
            }
            Stage::Resetting => {
                if !self.reset {
                    for k in 0..self.order.len() {
                        let slot = *self.order.at(k);
                        let path = self.parts.at(slot).input;
                        e.activate_path(self, slot, path);
                        e.active_insert(slot);
                    }
                    self.reset = true;
                }
                if e.active_is_empty() {
                    self.stage = Stage::Complete;
                }
            }
            Stage::Complete => return false,
        }
        e.update(self);
        true
    }
}
