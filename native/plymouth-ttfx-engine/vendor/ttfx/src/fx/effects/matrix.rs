//! matrix on the fx engine (old engine: effects/matrix.rs).
//!
//! Rain columns fall until --rain-time seconds of wall clock have passed
//! (virtual under --parity-dump / --virtual-clock), then every column fills
//! and the text resolves out of it.
//!
//! A column's characters are a span of one flat array, bottom to top. Its
//! pending ones are always a suffix (pending.remove(0) only), so an index;
//! its visible ones are pushed at the back at most once per setup, so a
//! same-length span with start/end indices holds them (front pops advance
//! the start, resolve_char and drop_column compact in place).
//! pending_columns is a ring (a column is pending at most once).
//!
//! Almost every swap draw misses; misses are skipped straight from the RNG
//! batch. A column's swap draws end its tick and the next column's tick
//! usually draws nothing first, so they are owed and flushed as one run
//! right before anything else draws.

use std::collections::hash_map::Entry;
use std::collections::{HashMap, VecDeque};

use crate::effects::matrix::MatrixConfig;
use crate::engine::animation::{Animation, ExistingColorHandling};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, Visual, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::floor_div;
use crate::utils::rng::Rng;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Rain,
    Fill,
    Resolve,
}

/// MatrixIterator.RainColumn.
struct Column {
    /// The column's span of `chars` and `vis`.
    start: u32,
    len: u32,
    /// First pending character; visible[0] and one past the last visible.
    pend: u32,
    vstart: u32,
    vend: u32,
    /// Rain or Fill.
    phase: Phase,
    in_full: bool,
    drop_chance: f64,
    base_delay: i64,
    delay: i64,
    length: i64,
    hold: i64,
}

impl Column {
    #[inline]
    fn visible(&self) -> u32 {
        self.vend - self.vstart
    }
}

pub struct Matrix {
    config: MatrixConfig,
    phase: Phase,
    columns: Vec<Column>,
    /// Every column's characters, bottom to top, and its visible buffer.
    chars: Vec<u32>,
    vis: Vec<u32>,
    pending: VecDeque<u32>,
    active: Vec<u32>,
    full: Vec<u32>,
    /// Every appearance the effect gives is (a rain symbol, a color): these
    /// are indices into the distinct symbols and colors (distinct by ==, so
    /// comparing indices compares values), and memo holds their visuals.
    syms: Vec<Sym>,
    pal: Vec<Color>,
    memo: Vec<Visual>,
    /// rain_symbols, Gradient(*rain_color_gradient, steps=6).spectrum, the
    /// faded tail colors (rain_colors[-3:] at 0.65 brightness) and the
    /// highlight, as indices.
    symbols: Vec<u32>,
    rain: Vec<u32>,
    faded: Vec<u32>,
    highlight: u32,
    /// Per slot: the (symbol, color) the effect last gave it.
    look: Vec<(u32, u32)>,
    /// --existing-color-handling always: characters that use their input
    /// colors show those instead (set_appearance).
    always: bool,
    /// random() < chance is (draw >> 11) < threshold.
    symbol_threshold: u64,
    color_threshold: u64,
    /// Per slot: its resolve scene (NONE for fill characters).
    resolve_scene: Vec<u32>,
    resolve_name: Name,
    column_delay: i64,
    resolve_delay: i64,
    final_frame_shown: bool,
    rain_complete: bool,
    rain_start: f64,
    /// Owed swap draws: vis index ranges, and their characters' count.
    owed: Vec<(u32, u32)>,
    owed_count: usize,
    avx2: bool,
}

/// The threshold t with random() < chance exactly when (draw >> 11) < t:
/// the draw is m / 2^53, and m < chance * 2^53 (exact) is m < ceil of it.
fn threshold(chance: f64) -> u64 {
    // saturating: at 2^53 every draw hits
    (chance * (1u64 << 53) as f64)
        .ceil()
        .min((1u64 << 53) as f64) as u64
}

/// The number of characters, up to `max`, whose two swap draws both miss,
/// consumed from the RNG batch. Stops before a hit or when the batch has
/// fewer than two draws left.
#[inline]
fn skip_misses(rng: &mut Rng, symbol: u64, color: u64, avx2: bool, max: usize) -> usize {
    let draws = rng.ahead();
    let pairs = draws.len() / 2;
    let mut k = 0;
    #[cfg(target_arch = "x86_64")]
    if avx2 {
        // SAFETY: the CPU supports AVX2 (Matrix::new checked).
        k = unsafe { skip_quads_avx2(draws, symbol, color, max) };
    }
    #[cfg(not(target_arch = "x86_64"))]
    let _ = avx2;
    let max = max.min(pairs);
    while k < max && (draws[k * 2] >> 11) >= symbol && (draws[k * 2 + 1] >> 11) >= color {
        k += 1;
    }
    rng.skip(k * 2);
    k
}

/// skip_misses four characters a pass with AVX2, while four characters'
/// draws are left in the batch: the characters before the first hit, up to
/// `max`. Draws >> 11 and the thresholds are at most 2^53, so the signed
/// compare is exact.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx2")]
fn skip_quads_avx2(draws: &[u64], symbol: u64, color: u64, max: usize) -> usize {
    use crate::utils::simd::load_si256;
    use std::arch::x86_64::*;
    let t = _mm256_setr_epi64x(symbol as i64, color as i64, symbol as i64, color as i64);
    let pairs = draws.len() / 2;
    let hit = |v: __m256i| _mm256_cmpgt_epi64(t, _mm256_srli_epi64::<11>(v));
    let mut k = 0;
    while k + 8 <= max && k + 8 <= pairs {
        // draws k * 2 .. k * 2 + 16 are in the slice
        let v = [0, 1, 2, 3].map(|i| load_si256(draws, k * 2 + i * 4));
        let any = _mm256_or_si256(
            _mm256_or_si256(hit(v[0]), hit(v[1])),
            _mm256_or_si256(hit(v[2]), hit(v[3])),
        );
        if _mm256_testz_si256(any, any) == 0 {
            break;
        }
        k += 8;
    }
    while k < max && k + 4 <= pairs {
        // draws k * 2 .. k * 2 + 8 are in the slice
        let (a, b) = (load_si256(draws, k * 2), load_si256(draws, k * 2 + 4));
        let (a, b) = (hit(a), hit(b));
        // bit 2j: character j's symbol draw hits, bit 2j + 1: its color draw
        let mask = (_mm256_movemask_pd(_mm256_castsi256_pd(a))
            | _mm256_movemask_pd(_mm256_castsi256_pd(b)) << 4) as u32;
        let hits = (mask | mask >> 1) & 0x55;
        let misses = (hits | 0x100).trailing_zeros() as usize / 2;
        if misses < 4 || k + 4 >= max {
            return (k + misses).min(max);
        }
        k += 4;
    }
    k
}

impl Matrix {
    pub fn new(config: MatrixConfig) -> Self {
        let resolve_delay = config.resolve_delay;
        Matrix {
            config,
            phase: Phase::Rain,
            columns: Vec::new(),
            chars: Vec::new(),
            vis: Vec::new(),
            pending: VecDeque::new(),
            active: Vec::new(),
            full: Vec::new(),
            syms: Vec::new(),
            pal: Vec::new(),
            memo: Vec::new(),
            symbols: Vec::new(),
            rain: Vec::new(),
            faded: Vec::new(),
            highlight: 0,
            look: Vec::new(),
            always: false,
            symbol_threshold: 0,
            color_threshold: 0,
            resolve_scene: Vec::new(),
            resolve_name: Name::NONE,
            column_delay: 0,
            resolve_delay,
            final_frame_shown: false,
            rain_complete: false,
            rain_start: 0.0,
            owed: Vec::new(),
            owed_count: 0,
            #[cfg(target_arch = "x86_64")]
            avx2: std::arch::is_x86_feature_detected!("avx2"),
            #[cfg(not(target_arch = "x86_64"))]
            avx2: false,
        }
    }

    /// set_appearance(slot, symbol, (color, None)).
    #[inline]
    fn appear(&mut self, e: &mut Engine, slot: u32, symbol: u32, color: u32) {
        *self.look.at_mut(slot) = (symbol, color);
        if self.always && e.uses_preexisting_colors(slot) {
            let colors = ColorPair::new(Some(*self.pal.at(color)), None);
            e.set_appearance(slot, Some(*self.syms.at(symbol)), Some(colors));
            return;
        }
        let visual = self
            .memo
            .at_mut(symbol as usize * self.pal.len() + color as usize);
        if visual.0 == NONE {
            let info = VisualInfo {
                sym: self.syms[symbol as usize],
                fg: Some(self.pal[color as usize]),
                bg: None,
                attrs: HAS_COLORS,
            };
            *visual = e.visuals.make(&e.symbols, info);
        }
        let visual = *visual;
        e.doze_wake(slot);
        e.set_visual(slot, visual);
    }

    /// The character's current fg is this color. (Under
    /// --existing-color-handling always it may show its input colors.)
    #[inline]
    fn shows_color(&self, e: &Engine, slot: u32, color: u32) -> bool {
        if self.always && e.uses_preexisting_colors(slot) {
            e.visuals.info(e.current_visual(slot)).fg == Some(*self.pal.at(color))
        } else {
            self.look.at(slot).1 == color
        }
    }

    /// set_appearance(slot, current symbol, (color, None)).
    #[inline]
    fn recolor(&mut self, e: &mut Engine, slot: u32, color: u32) {
        let symbol = self.look.at(slot).0;
        self.appear(e, slot, symbol, color);
    }

    #[inline]
    fn rain_choice(&self, e: &mut Engine) -> u32 {
        *self.rain.at(e.rng.choice_index(self.rain.len()))
    }

    /// RainColumn.setup_column.
    fn setup_column(&mut self, e: &mut Engine, c: u32, phase: Phase) {
        let col = self.columns.at_mut(c);
        col.phase = phase;
        let (start, len) = (col.start as usize, col.len as usize);
        for &slot in &self.chars[start..start + len] {
            e.set_visible(slot, false);
            let coord = e.input_coord(slot);
            e.set_coordinate(slot, coord);
        }
        let (lo, hi) = self.config.rain_fall_delay_range;
        let col = self.columns.at_mut(c);
        col.pend = 0;
        col.vstart = 0;
        col.vend = 0;
        col.base_delay = if phase == Phase::Fill {
            e.rng
                .randint(floor_div(lo, 3).max(1), floor_div(hi, 3).max(1))
        } else {
            e.rng.randint(lo, hi)
        };
        col.delay = 0;
        col.length = if phase == Phase::Rain {
            e.rng.randint(1.max((len as f64 * 0.1) as i64), len as i64)
        } else {
            len as i64
        };
        col.hold = 0;
        if col.length == len as i64 {
            col.hold = e.rng.randint(20, 45);
        }
    }

    /// RainColumn.trim_column.
    fn trim_column(&mut self, e: &mut Engine, c: u32) {
        let col = self.columns.at_mut(c);
        if col.vstart == col.vend {
            return;
        }
        let popped = *self.vis.at(col.start + col.vstart);
        col.vstart += 1;
        let (base, remaining) = (col.start + col.vstart, col.visible());
        e.set_visible(popped, false);
        if remaining > 1 {
            // fade_last_character: random.choice(rain_colors[-3:]) at 0.65
            let color = *self.faded.at(e.rng.choice_index(self.faded.len()));
            self.recolor(e, *self.vis.at(base), color);
        }
    }

    /// RainColumn.drop_column.
    fn drop_column(&mut self, e: &mut Engine, c: u32) {
        let bottom = e.canvas.bottom;
        let col = self.columns.at_mut(c);
        let base = col.start as usize;
        let mut write = col.vstart as usize;
        for read in col.vstart as usize..col.vend as usize {
            let slot = *self.vis.at(base + read);
            let coord = e.coord(slot);
            let coord = Coord::new(coord.column, coord.row - 1);
            e.set_coordinate(slot, coord);
            if coord.row < bottom {
                e.set_visible(slot, false);
            } else {
                *self.vis.at_mut(base + write) = slot;
                write += 1;
            }
        }
        col.vend = write as u32;
    }

    /// RainColumn.resolve_char: remove a random visible character.
    fn resolve_char(&mut self, e: &mut Engine, c: u32) -> u32 {
        let col = self.columns.at_mut(c);
        let index = e.rng.randint(0, col.visible() as i64 - 1) as u32;
        let base = col.start as usize;
        let at = base + (col.vstart + index) as usize;
        let end = base + col.vend as usize;
        let slot = *self.vis.at(at);
        self.vis.copy_within(at + 1..end, at);
        col.vend -= 1;
        slot
    }

    /// RainColumn.tick; with no delay left it draws, so owed draws flush first.
    fn tick(&mut self, e: &mut Engine, c: u32) {
        let col = self.columns.at_mut(c);
        if col.delay == 0 {
            self.flush(e);
            let col = self.columns.at_mut(c);
            if col.pend < col.len {
                let next = *self.chars.at(col.start + col.pend);
                col.pend += 1;
                let symbol = *self.symbols.at(e.rng.choice_index(self.symbols.len()));
                self.appear(e, next, symbol, self.highlight);
                let col = self.columns.at_mut(c);
                if col.vend != col.vstart {
                    let previous = *self.vis.at(col.start + col.vend - 1);
                    let fg = self.rain_choice(e);
                    self.recolor(e, previous, fg);
                }
                e.set_visible(next, true);
                let col = self.columns.at_mut(c);
                *self.vis.at_mut(col.start + col.vend) = next;
                col.vend += 1;
            } else if col.vend != col.vstart {
                let last = *self.vis.at(col.start + col.vend - 1);
                if self.shows_color(e, last, self.highlight) {
                    let fg = self.rain_choice(e);
                    self.recolor(e, last, fg);
                }
                let col = self.columns.at_mut(c);
                if col.hold != 0 {
                    col.hold -= 1;
                } else if col.phase == Phase::Rain {
                    if e.rng.random() < col.drop_chance {
                        self.drop_column(e, c);
                    }
                    self.trim_column(e, c);
                }
            }
            let col = self.columns.at(c);
            if col.visible() as i64 > col.length {
                self.trim_column(e, c);
            }
            let col = self.columns.at_mut(c);
            col.delay = col.base_delay;
        } else {
            col.delay -= 1;
        }

        let col = self.columns.at(c);
        if col.vend != col.vstart {
            self.owed
                .push((col.start + col.vstart, col.start + col.vend));
            self.owed_count += col.visible() as usize;
        }
    }

    /// The owed swap draws (tick's last part), in order.
    fn flush(&mut self, e: &mut Engine) {
        let mut left = self.owed_count;
        if left == 0 {
            return;
        }
        let (symbol_threshold, color_threshold) = (self.symbol_threshold, self.color_threshold);
        // the next character: its segment, its vis index and the segment's end
        let mut segment = 0usize;
        let (mut k, mut end) = *self.owed.at(0usize);
        loop {
            let mut n = skip_misses(
                &mut e.rng,
                symbol_threshold,
                color_threshold,
                self.avx2,
                left,
            );
            left -= n;
            if left == 0 {
                break;
            }
            while n >= (end - k) as usize {
                n -= (end - k) as usize;
                segment += 1;
                (k, end) = *self.owed.at(segment);
            }
            k += n as u32;
            // a hit next, or the batch ran out: draw this one by one
            self.swap(e, *self.vis.at(k));
            left -= 1;
            if left == 0 {
                break;
            }
            k += 1;
            if k == end {
                segment += 1;
                (k, end) = *self.owed.at(segment);
            }
        }
        self.owed.clear();
        self.owed_count = 0;
    }

    #[inline(never)]
    fn swap(&mut self, e: &mut Engine, slot: u32) {
        let next_symbol = if e.rng.random() < self.config.symbol_swap_chance {
            Some(*self.symbols.at(e.rng.choice_index(self.symbols.len())))
        } else {
            None
        };
        let next_color = if e.rng.random() < self.config.color_swap_chance {
            Some(self.rain_choice(e))
        } else {
            None
        };
        if next_symbol.is_none() && next_color.is_none() {
            return;
        }
        // set_appearance only when something differs; with the symbol alone
        // the color stays (and under --existing-color-handling always the
        // input colors show either way)
        let (symbol, color) = *self.look.at(slot);
        let changed = next_symbol.is_some_and(|s| s != symbol)
            || next_color.is_some_and(|c| !self.shows_color(e, slot, c));
        if changed {
            self.appear(
                e,
                slot,
                next_symbol.unwrap_or(symbol),
                next_color.unwrap_or(color),
            );
        }
    }

    fn retain_visible(columns: &[Column], list: &mut Vec<u32>) {
        list.retain(|&c| columns.at(c).visible() != 0);
    }
}

impl Hooks for Matrix {}

/// The index of `value` among the distinct values, adding it when new.
fn distinct<T: PartialEq>(values: &mut Vec<T>, value: T) -> u32 {
    match values.iter().position(|v| *v == value) {
        Some(i) => i as u32,
        None => {
            values.push(value);
            values.len() as u32 - 1
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Matrix {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let rain = Gradient::with_steps(&config.rain_color_gradient, 6, false)
            .map_err(other)?
            .spectrum;
        let tail = rain.len().saturating_sub(3);
        let faded: Vec<Color> = rain[tail..]
            .iter()
            .map(|c| Animation::adjust_color_brightness(c, 0.65))
            .collect();
        self.highlight = distinct(&mut self.pal, config.highlight_color);
        self.rain = rain
            .into_iter()
            .map(|c| distinct(&mut self.pal, c))
            .collect();
        self.faded = faded
            .into_iter()
            .map(|c| distinct(&mut self.pal, c))
            .collect();
        for symbol in &config.rain_symbols {
            let sym = e.sym(symbol);
            self.symbols.push(distinct(&mut self.syms, sym));
        }
        self.memo = vec![Visual(NONE); self.syms.len() * self.pal.len()];
        self.look = vec![(0, 0); e.char_count()];
        self.always = e.existing_color_handling() == ExistingColorHandling::Always;
        self.symbol_threshold = threshold(config.symbol_swap_chance);
        self.color_threshold = threshold(config.color_swap_chance);

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
        let highlight = config.highlight_color;
        let frames = config.final_gradient_frames;
        let resolve = e.name("resolve");
        self.resolve_name = resolve;
        self.resolve_scene = vec![NONE; e.char_count()];
        // final color -> Gradient(highlight, final, steps=8).spectrum; (input
        // symbol, final color) -> a plain scene's frames
        let mut spectra: HashMap<Color, Vec<Color>, FxBuild> = HashMap::default();
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            let sym = e.input_sym(slot);
            let scene = e.scene_new(slot, resolve, false, None, None);
            self.resolve_scene[slot as usize] = scene;
            if dynamic {
                let spectrum = |c: Option<Color>| -> Result<Option<Vec<Color>>, EngineError> {
                    c.map(|c| Gradient::with_steps(&[highlight, c], 8, false).map(|g| g.spectrum))
                        .transpose()
                        .map_err(other)
                };
                let fg = spectrum(e.input_fg(slot))?;
                let bg = spectrum(e.input_bg(slot))?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(scene, &[sym], frames, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(scene, sym, frames, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_fg = *final_gradient_mapping.get(&e.input_coord(slot)).unwrap();
                let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match memo.get(&(sym, final_fg)) {
                    Some(frames) if plain => e.append_frames(scene, frames),
                    _ => {
                        let spectrum = match spectra.entry(final_fg) {
                            Entry::Occupied(entry) => entry.into_mut(),
                            Entry::Vacant(entry) => entry.insert(
                                Gradient::with_steps(&[highlight, final_fg], 8, false)
                                    .map_err(other)?
                                    .spectrum,
                            ),
                        };
                        for &color in spectrum.iter() {
                            e.add_frame(
                                scene,
                                sym,
                                frames,
                                Some(ColorPair::new(Some(color), None)),
                                0,
                            )
                            .map_err(other)?;
                        }
                        if plain {
                            memo.insert((sym, final_fg), e.scenes.frames_of(scene).to_vec());
                        }
                    }
                }
            }
        }

        // one RainColumn per canvas column, left to right, bottom to top
        let all_chars_filter = CharacterFilter {
            input_chars: true,
            inner_fill_chars: true,
            outer_fill_chars: true,
            added_chars: false,
        };
        let groups = e.get_characters_grouped(all_chars_filter, CharacterGroup::ColumnLeftToRight);
        self.columns.reserve(groups.len());
        for group in groups {
            let start = self.chars.len() as u32;
            self.chars.extend(group.iter().rev());
            self.columns.push(Column {
                start,
                len: group.len() as u32,
                pend: 0,
                vstart: 0,
                vend: 0,
                phase: Phase::Rain,
                in_full: false,
                drop_chance: 0.08,
                base_delay: 0,
                delay: 0,
                length: 0,
                hold: 0,
            });
            let c = self.columns.len() as u32 - 1;
            self.setup_column(e, c, Phase::Rain);
        }
        self.vis = vec![NONE; self.chars.len()];
        let mut pending: Vec<u32> = (0..self.columns.len() as u32).collect();
        e.rng.shuffle(&mut pending);
        self.pending = VecDeque::with_capacity(self.columns.len());
        self.pending.extend(pending);
        self.active.reserve(self.columns.len());
        self.full.reserve(self.columns.len());
        self.owed.reserve(self.columns.len());

        // MatrixIterator.__init__: rain_start = time.time(), after build
        self.rain_start = e.clock.now_wall();
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.phase != Phase::Resolve {
            if self.column_delay == 0 {
                if self.phase == Phase::Rain {
                    for _ in 0..e.rng.randint(1, 3) {
                        if let Some(c) = self.pending.pop_front() {
                            self.active.push(c);
                        }
                    }
                    let (lo, hi) = self.config.rain_column_delay_range;
                    self.column_delay = e.rng.randint(lo, hi);
                } else {
                    self.active.extend(self.pending.drain(..));
                    self.column_delay = 1;
                }
            } else {
                self.column_delay -= 1;
            }
            for i in 0..self.active.len() {
                let c = *self.active.at(i);
                self.tick(e, c);
                let col = self.columns.at_mut(c);
                if col.pend == col.len {
                    if col.phase == Phase::Fill && !col.in_full {
                        col.in_full = true;
                        self.full.push(c);
                    } else if col.visible() == 0 {
                        // column_phase_for: rain or fill
                        self.flush(e);
                        self.setup_column(e, c, self.phase);
                        self.pending.push_back(c);
                    }
                }
            }
            self.flush(e);
            Self::retain_visible(&self.columns, &mut self.active);
            if self.phase == Phase::Fill
                && self.pending.is_empty()
                && self.active.iter().all(|&c| {
                    let col = self.columns.at(c);
                    col.pend == col.len && col.phase == Phase::Fill
                })
            {
                self.phase = Phase::Resolve;
                self.active.clear();
            }

            // effect_matrix.py:549 - the rain deadline on the wall clock
            if self.phase == Phase::Rain
                && self.config.rain_time > 0
                && e.clock.now_wall() - self.rain_start > self.config.rain_time as f64
            {
                self.rain_complete = true;
                self.phase = Phase::Fill;
                for &c in &self.active {
                    let col = self.columns.at_mut(c);
                    col.hold = 0;
                    col.drop_chance = 1.0;
                }
                for i in 0..self.pending.len() {
                    let c = self.pending[i];
                    self.setup_column(e, c, Phase::Fill);
                }
            }
        } else {
            for i in 0..self.full.len() {
                let c = *self.full.at(i);
                self.tick(e, c);
                self.flush(e);
                if self.columns.at(c).visible() == 0 {
                    continue;
                }
                if self.resolve_delay == 0 {
                    for _ in 0..e.rng.randint(1, 4) {
                        if self.columns.at(c).visible() == 0 {
                            continue;
                        }
                        let slot = self.resolve_char(e, c);
                        if e.symbol(e.input_sym(slot)) != " "
                            || e.input_fg(slot).is_some()
                            || e.input_bg(slot).is_some()
                        {
                            let scene = self.resolve_scene[slot as usize];
                            if scene == NONE {
                                let name = self.resolve_name;
                                e.activate_scene_name(self, slot, name);
                            } else {
                                e.activate_scene(self, slot, scene);
                            }
                            e.active_insert(slot);
                        } else {
                            e.set_visible(slot, false);
                        }
                    }
                    self.resolve_delay = self.config.resolve_delay;
                } else {
                    self.resolve_delay -= 1;
                }
            }
            Self::retain_visible(&self.columns, &mut self.full);
        }

        if !self.full.is_empty()
            || !self.active.is_empty()
            || !e.active_is_empty()
            || !self.pending.is_empty()
            || !self.rain_complete
        {
            e.update(self);
            return true;
        }
        if !self.final_frame_shown {
            self.final_frame_shown = true;
            e.update(self);
            return true;
        }
        false
    }
}
