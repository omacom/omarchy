//! sweep on the fx engine (old engine: effects/sweep.rs).
//!
//! Every character (input and fill) gets an initial_sweep and a second_sweep
//! scene, created in top-to-bottom, left-to-right order so the RNG draws line
//! up. Shimmer visuals are memoized by (symbol, color index), so a scene is
//! one bulk append. A SequenceEaser (in_out_circ, 100 steps) walks the first
//! sweep's groups, then the second's.

use crate::effects::sweep::SweepConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, Hooks, Sym, Visual, NONE};
use crate::utils::easing::{Easing, SequenceEaser};
use crate::utils::graphics::{Color, Gradient};

const GRAYS: [&str; 5] = ["A0A0A0", "808080", "404040", "202020", "101010"];
/// The largest (symbol, color) memo; past it visuals are made uncached.
const MEMO_LIMIT: usize = 1 << 22;

pub struct Sweep {
    config: SweepConfig,
    /// Per slot: the initial_sweep and second_sweep scenes.
    scenes: Vec<(u32, u32)>,
    first_phase: bool,
    complete: bool,
    easer: Option<SequenceEaser<Vec<u32>>>,
    groups_second_sweep: Vec<Vec<u32>>,
}

impl Sweep {
    pub fn new(config: SweepConfig) -> Self {
        Sweep {
            config,
            scenes: Vec::new(),
            first_phase: true,
            complete: false,
            easer: None,
            groups_second_sweep: Vec::new(),
        }
    }
}

impl Hooks for Sweep {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// (symbol, color) -> visual, no bg, no attrs; memoized by (symbol index,
/// color index) when the table is small enough.
struct ShimmerMemo<'a> {
    symbols: &'a [Sym],
    colors: &'a [Color],
    memo: Vec<Visual>,
}

impl<'a> ShimmerMemo<'a> {
    fn new(symbols: &'a [Sym], colors: &'a [Color]) -> Self {
        let size = symbols.len().saturating_mul(colors.len());
        let memo = if size <= MEMO_LIMIT {
            vec![Visual(NONE); size]
        } else {
            Vec::new()
        };
        ShimmerMemo {
            symbols,
            colors,
            memo,
        }
    }

    #[inline]
    fn visual(&mut self, e: &mut Engine, symbol: usize, color: usize) -> Visual {
        let make = |e: &mut Engine| {
            let info = VisualInfo {
                sym: self.symbols[symbol],
                fg: Some(self.colors[color]),
                bg: None,
                attrs: HAS_COLORS,
            };
            e.visuals.make(&e.symbols, info)
        };
        if self.memo.is_empty() {
            return make(e);
        }
        let index = symbol * self.colors.len() + color;
        let entry = self.memo[index];
        if entry.0 != NONE {
            return entry;
        }
        let visual = make(e);
        self.memo[index] = visual;
        visual
    }
}

/// choice_index(n) for every element of `out`, in order.
fn draw_below(e: &mut Engine, n: usize, out: &mut [u16], wide: &mut [usize]) {
    if n <= 1 << 16 {
        e.rng.fill_below(n as u64, out);
        for (w, &d) in wide.iter_mut().zip(out.iter()) {
            *w = d as usize;
        }
    } else {
        for w in wide.iter_mut() {
            *w = e.rng.choice_index(n);
        }
    }
}

impl Effect for Sweep {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let final_fg_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let canvas = &e.canvas;
        let final_gradient_mapping = final_fg_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let grays: Vec<Color> = GRAYS
            .iter()
            .map(|hex| Color::from_hex(hex).unwrap())
            .collect();
        let gray_808080 = Color::from_hex("#808080").unwrap();
        let black = Color::from_hex("000000").unwrap();

        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let mut palette: Vec<Color> = Vec::new();
        if dynamic {
            // the order is fixed (no RNG), so the input list serves as is
            for slot in e.get_characters(
                CharacterFilter::default(),
                CharacterSort::TopToBottomLeftToRight,
            ) {
                palette.extend(e.input_fg(slot));
                palette.extend(e.input_bg(slot));
            }
        }
        if palette.is_empty() {
            palette = final_fg_gradient.spectrum.clone();
        }

        let symbols: Vec<Sym> = config.sweep_symbols.iter().map(|s| e.sym(s)).collect();
        let mut gray_memo = ShimmerMemo::new(&symbols, &grays);
        let mut color_memo = ShimmerMemo::new(&symbols, &palette);
        // (input symbol) -> its 808080 visual
        let mut settle_memo: Vec<Visual> = Vec::new();
        let initial_sweep = e.name("initial_sweep");
        let second_sweep = e.name("second_sweep");

        let fills_filter = CharacterFilter {
            inner_fill_chars: true,
            outer_fill_chars: true,
            ..Default::default()
        };
        let characters = e.get_characters(fills_filter, CharacterSort::TopToBottomLeftToRight);
        let count = symbols.len();
        e.scenes
            .reserve(characters.len() * 2, characters.len() * 2 * (count + 1));
        self.scenes = vec![(NONE, NONE); e.char_count()];
        let mut draws = vec![0u16; count];
        let mut picks = vec![0usize; count];
        let mut frames = vec![
            Frame {
                visual: Visual(NONE),
                duration: 5
            };
            count + 1
        ];
        for slot in characters {
            let sym = e.input_sym(slot);
            let final_colors = if e.is_fill(slot) {
                if dynamic {
                    (None, None)
                } else {
                    (Some(black), None)
                }
            } else if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                )
            };

            // initial_sweep: the symbols in random grays, then the symbol in 808080
            let initial = e.scene_new(slot, initial_sweep, false, None, None);
            draw_below(e, grays.len(), &mut draws, &mut picks);
            for (i, &pick) in picks.iter().enumerate() {
                frames[i] = Frame {
                    visual: gray_memo.visual(e, i, pick),
                    duration: 5,
                };
            }
            let index = sym.0 as usize;
            if settle_memo.len() <= index {
                settle_memo.resize(index + 1, Visual(NONE));
            }
            if settle_memo[index].0 == NONE {
                let info = VisualInfo {
                    sym,
                    fg: Some(gray_808080),
                    bg: None,
                    attrs: HAS_COLORS,
                };
                settle_memo[index] = e.visuals.make(&e.symbols, info);
            }
            frames[count] = Frame {
                visual: settle_memo[index],
                duration: 1,
            };
            e.add_frames_visual(initial, &frames).map_err(other)?;

            // second_sweep: the symbols in random palette colors, then the final look
            let second = e.scene_new(slot, second_sweep, false, None, None);
            draw_below(e, palette.len(), &mut draws, &mut picks);
            for (i, &pick) in picks.iter().enumerate() {
                frames[i] = Frame {
                    visual: color_memo.visual(e, i, pick),
                    duration: 5,
                };
            }
            let info = VisualInfo {
                sym,
                fg: final_colors.0,
                bg: final_colors.1,
                attrs: HAS_COLORS,
            };
            frames[count] = Frame {
                visual: e.visuals.make(&e.symbols, info),
                duration: 1,
            };
            e.add_frames_visual(second, &frames).map_err(other)?;
            self.scenes[slot as usize] = (initial, second);
        }

        let groups_first_sweep =
            e.get_characters_grouped(fills_filter, config.first_sweep_direction);
        self.easer = Some(SequenceEaser::new(
            groups_first_sweep,
            Easing::InOutCirc,
            100,
        ));
        self.groups_second_sweep =
            e.get_characters_grouped(fills_filter, config.second_sweep_direction);
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() && self.complete {
            return false;
        }
        let mut easer = self.easer.take().unwrap();
        for group in easer.step().added {
            for &slot in group {
                let (initial, second) = *self.scenes.at(slot);
                if self.first_phase {
                    e.set_visible(slot, true);
                    e.activate_scene(self, slot, initial);
                } else {
                    e.activate_scene(self, slot, second);
                }
            }
            for &slot in group {
                e.active_insert(slot);
            }
        }
        if easer.is_complete() {
            if self.first_phase {
                easer.sequence = std::mem::take(&mut self.groups_second_sweep);
                easer.reset();
                self.first_phase = false;
            } else {
                self.complete = true;
            }
        }
        self.easer = Some(easer);
        e.update(self);
        true
    }
}
