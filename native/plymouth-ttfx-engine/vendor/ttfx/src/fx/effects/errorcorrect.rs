//! errorcorrect on the fx engine (old engine: effects/errorcorrect.rs).
//!
//! Every character shows in its final color from the start; error_pairs of
//! them are swapped pairwise and, one pair every swap_delay frames, flicker,
//! wipe, travel home on layer 1 and fade to their final color. Scenes are
//! created in the old engine's order, so their auto ids (and so the event keys)
//! match. Visuals are memoized per symbol, and the frames shared by every
//! swapped character (the block wipes, the correcting scene, a static final
//! scene per (symbol, final color)) are built once and copied.

use std::collections::HashMap;

use crate::effects::errorcorrect::ErrorCorrectConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SceneId, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, Visual, NONE};
use crate::utils::graphics::{Color, ColorPair, Gradient};

const BLOCK_WIPE_START: [&str; 8] = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"];
const BLOCK_WIPE_END: [&str; 7] = ["▇", "▆", "▅", "▄", "▃", "▂", "▁"];

pub struct ErrorCorrect {
    config: ErrorCorrectConfig,
    /// (char1, char2) in swap order, and the next pair to start.
    swapped: Vec<(u32, u32)>,
    swapped_head: usize,
    swap_delay: i64,
    error_name: Name,
}

impl ErrorCorrect {
    pub fn new(config: ErrorCorrectConfig) -> Self {
        ErrorCorrect {
            config,
            swapped: Vec::new(),
            swapped_head: 0,
            swap_delay: 0,
            error_name: Name::NONE,
        }
    }
}

impl Hooks for ErrorCorrect {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// Vec::remove at a random index over a fixed list, without the shifting: a
/// Fenwick tree of the elements still present finds the k-th one.
struct Remaining<'a> {
    items: &'a [u32],
    tree: Vec<u32>,
    top: usize,
    len: usize,
}

impl<'a> Remaining<'a> {
    fn new(items: &'a [u32]) -> Self {
        let n = items.len();
        let tree = (0..=n).map(|i| (i & i.wrapping_neg()) as u32).collect();
        let top = if n == 0 { 0 } else { 1 << n.ilog2() };
        Remaining {
            items,
            tree,
            top,
            len: n,
        }
    }

    /// Remove and return the k-th remaining element.
    fn take(&mut self, k: usize) -> u32 {
        let n = self.items.len();
        let (mut pos, mut rest) = (0, k + 1);
        let mut step = self.top;
        while step != 0 {
            let next = pos + step;
            if next <= n && (self.tree[next] as usize) < rest {
                pos = next;
                rest -= self.tree[next] as usize;
            }
            step >>= 1;
        }
        let mut i = pos + 1;
        while i <= n {
            self.tree[i] -= 1;
            i += i & i.wrapping_neg();
        }
        self.len -= 1;
        self.items[pos]
    }
}

/// Visuals and frames shared across characters.
struct Memo {
    error: Color,
    white: Color,
    /// By symbol: the symbol in the error color, and in white.
    by_sym: Vec<[Visual; 2]>,
    first_wipe: [Frame; 8],
    last_wipe: [Frame; 7],
    /// The correcting scene's frames (empty until the first plain one).
    correcting: Vec<Frame>,
    /// (symbol, final fg) -> a plain static final scene's frames.
    finals: HashMap<(Sym, Color), Vec<Frame>, FxBuild>,
}

impl Memo {
    #[inline]
    fn sym_visuals(&mut self, e: &mut Engine, sym: Sym) -> [Visual; 2] {
        let i = sym.0 as usize;
        if i >= self.by_sym.len() {
            self.by_sym.resize(i + 1, [Visual(NONE); 2]);
        }
        // in bounds: resized above
        let entry = self.by_sym.at_mut(i as u32);
        if entry[0].0 == NONE {
            for (visual, color) in entry.iter_mut().zip([self.error, self.white]) {
                *visual = e.visuals.make(
                    &e.symbols,
                    VisualInfo {
                        sym,
                        fg: Some(color),
                        bg: None,
                        attrs: HAS_COLORS,
                    },
                );
            }
        }
        *entry
    }
}

fn plain(e: &Engine, scene: SceneId) -> bool {
    e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0
}

impl Effect for ErrorCorrect {
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
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );

        // character_final_color_map, by slot
        let slots = e.char_count();
        let mut final_fg: Vec<Option<Color>> = vec![None; slots];
        let mut final_bg: Vec<Option<Color>> = vec![None; slots];
        // spawn: one frame in the final colors (the map has no observable
        // effect, so both of the old engine's loops run as one)
        e.scenes.reserve(characters.len(), characters.len());
        for &slot in &characters {
            let (fg, bg) = if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                )
            };
            final_fg[slot as usize] = fg;
            final_bg[slot as usize] = bg;
            let scene = e.scene_new(slot, Name::NONE, false, None, None);
            let sym = e.input_sym(slot);
            e.add_frame(scene, sym, 1, Some(ColorPair::new(fg, bg)), 0)
                .map_err(other)?;
            e.activate_scene(self, slot, scene);
            e.set_visible(slot, true);
        }

        let correcting_spectrum =
            Gradient::with_steps(&[config.error_color, config.correct_color], 10, false)
                .map_err(other)?
                .spectrum;
        let visual = |e: &mut Engine, symbol: &str, color: Color| {
            let sym = e.sym(symbol);
            e.visuals.make(
                &e.symbols,
                VisualInfo {
                    sym,
                    fg: Some(color),
                    bg: None,
                    attrs: HAS_COLORS,
                },
            )
        };
        let mut memo = Memo {
            error: config.error_color,
            white: Color::from_hex("ffffff").unwrap(),
            by_sym: Vec::new(),
            first_wipe: [Frame {
                visual: Visual(NONE),
                duration: 3,
            }; 8],
            last_wipe: [Frame {
                visual: Visual(NONE),
                duration: 3,
            }; 7],
            correcting: Vec::new(),
            finals: HashMap::default(),
        };
        for (frame, block) in memo.first_wipe.iter_mut().zip(BLOCK_WIPE_START) {
            frame.visual = visual(e, block, config.error_color);
        }
        for (frame, block) in memo.last_wipe.iter_mut().zip(BLOCK_WIPE_END) {
            frame.visual = visual(e, block, config.correct_color);
        }
        let error_block = visual(e, "▓", config.error_color);
        let full_block = e.sym("█");
        let error_name = e.name("error");
        self.error_name = error_name;
        let input_coord = e.name("input_coord");

        let all_characters = e.input_chars.clone();
        let mut remaining = Remaining::new(&all_characters);
        let pair_count = (config.error_pairs * characters.len() as f64) as i64;
        for _ in 0..pair_count {
            if remaining.len < 2 {
                break;
            }
            let index1 = e.rng.randrange(0, remaining.len as i64) as usize;
            let char1 = remaining.take(index1);
            let index2 = e.rng.randrange(0, remaining.len as i64) as usize;
            let char2 = remaining.take(index2);
            for (slot, other_slot) in [(char1, char2), (char2, char1)] {
                let home = e.input_coord(slot);
                e.set_coordinate(slot, e.input_coord(other_slot));
                let path = e
                    .path_new(
                        slot,
                        config.movement_speed,
                        None,
                        None,
                        0,
                        false,
                        input_coord,
                    )
                    .map_err(other)?;
                e.path_new_waypoint(path, home, None, Name::NONE)
                    .map_err(other)?;
            }
            self.swapped.push((char1, char2));
            for slot in [char1, char2] {
                // _configure_swapped_character
                let sym = e.input_sym(slot);
                let [error_visual, white_visual] = memo.sym_visuals(e, sym);
                let first_wipe = e.scene_new(slot, Name::NONE, false, None, None);
                let last_wipe = e.scene_new(slot, Name::NONE, false, None, None);
                e.add_frames_visual(first_wipe, &memo.first_wipe)
                    .map_err(other)?;
                if dynamic {
                    e.add_frames_visual(last_wipe, &memo.last_wipe[..6])
                        .map_err(other)?;
                    let colors = ColorPair::new(final_fg[slot as usize], final_bg[slot as usize]);
                    let last = e.sym(BLOCK_WIPE_END[6]);
                    e.add_frame(last_wipe, last, 3, Some(colors), 0)
                        .map_err(other)?;
                } else {
                    e.add_frames_visual(last_wipe, &memo.last_wipe)
                        .map_err(other)?;
                }
                let initial = e.scene_new(slot, Name::NONE, false, None, None);
                e.add_frame_visual(initial, error_visual, 1)
                    .map_err(other)?;
                e.activate_scene(self, slot, initial);
                let error = e.scene_new(slot, error_name, false, None, None);
                let mut frames = [Frame {
                    visual: error_block,
                    duration: 3,
                }; 20];
                for pair in frames.chunks_exact_mut(2) {
                    pair[1].visual = white_visual;
                }
                e.add_frames_visual(error, &frames).map_err(other)?;
                let correcting =
                    e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Distance), None);
                if !memo.correcting.is_empty() && plain(e, correcting) {
                    e.append_frames(correcting, &memo.correcting);
                } else {
                    e.apply_gradient(
                        correcting,
                        &[full_block],
                        3,
                        Some(&correcting_spectrum),
                        None,
                    )
                    .map_err(other)?;
                    if plain(e, correcting) {
                        memo.correcting = e.scenes.frames_of(correcting).to_vec();
                    }
                }
                let final_scene = e.scene_new(slot, Name::NONE, false, None, None);
                if dynamic {
                    // _get_dynamic_final_scene
                    let spectrum = |c: Option<Color>| -> Result<Option<Vec<Color>>, EngineError> {
                        c.map(|c| {
                            Gradient::with_steps(&[config.correct_color, c], 10, false)
                                .map(|g| g.spectrum)
                        })
                        .transpose()
                        .map_err(other)
                    };
                    let fg = spectrum(e.input_fg(slot))?;
                    let bg = spectrum(e.input_bg(slot))?;
                    if fg.is_some() || bg.is_some() {
                        e.apply_gradient(final_scene, &[sym], 3, fg.as_deref(), bg.as_deref())
                            .map_err(other)?;
                    } else {
                        e.add_frame(final_scene, sym, 3, Some(ColorPair::default()), 0)
                            .map_err(other)?;
                    }
                } else {
                    let fg = final_fg[slot as usize].expect("gradient mapping fg");
                    let is_plain = plain(e, final_scene);
                    match memo.finals.get(&(sym, fg)) {
                        Some(frames) if is_plain => e.append_frames(final_scene, frames),
                        _ => {
                            let spectrum =
                                Gradient::with_steps(&[config.correct_color, fg], 10, false)
                                    .map_err(other)?
                                    .spectrum;
                            e.apply_gradient(final_scene, &[sym], 3, Some(&spectrum), None)
                                .map_err(other)?;
                            if is_plain {
                                memo.finals
                                    .insert((sym, fg), e.scenes.frames_of(final_scene).to_vec());
                            }
                        }
                    }
                }
                let first_name = e.scene_name(first_wipe);
                let last_name = e.scene_name(last_wipe);
                let registrations = [
                    (
                        Event::SceneComplete,
                        Caller::Scene(error_name),
                        Action::ActivateScene(first_name),
                    ),
                    (
                        Event::SceneComplete,
                        Caller::Scene(first_name),
                        Action::ActivateScene(e.scene_name(correcting)),
                    ),
                    (
                        Event::SceneComplete,
                        Caller::Scene(first_name),
                        Action::ActivatePath(input_coord),
                    ),
                    (
                        Event::PathActivated,
                        Caller::Path(input_coord),
                        Action::SetLayer(1),
                    ),
                    (
                        Event::PathComplete,
                        Caller::Path(input_coord),
                        Action::SetLayer(0),
                    ),
                    (
                        Event::PathComplete,
                        Caller::Path(input_coord),
                        Action::ActivateScene(last_name),
                    ),
                    (
                        Event::SceneComplete,
                        Caller::Scene(last_name),
                        Action::ActivateScene(e.scene_name(final_scene)),
                    ),
                ];
                for (event, caller, action) in registrations {
                    e.register_event(slot, event, caller, action)
                        .map_err(other)?;
                }
            }
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.swapped_head < self.swapped.len() && self.swap_delay == 0 {
            let (char1, char2) = self.swapped[self.swapped_head];
            self.swapped_head += 1;
            let error = self.error_name;
            for slot in [char1, char2] {
                e.activate_scene_name(self, slot, error);
                e.active_insert(slot);
            }
            self.swap_delay = self.config.swap_delay;
        } else if self.swap_delay != 0 {
            self.swap_delay -= 1;
        }
        if e.active_is_empty() {
            return false;
        }
        e.update(self);
        true
    }
}
