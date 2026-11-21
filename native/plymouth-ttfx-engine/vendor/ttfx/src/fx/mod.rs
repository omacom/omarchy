//! The fx engine: the old engine (src/engine) rebuilt on flat primitives,
//! with the same output byte for byte.
//!
//! Characters are struct-of-arrays indexed by slot (`u32`). Slots are
//! allocated in character_id order, so ascending slot order is the canonical
//! order. Scenes, paths, names and visuals are `u32` handles into flat
//! tables; the per-frame path never allocates, hashes a string or refcounts.
//! Visuals are formatted once and rendered by copying bytes (visual.rs), the
//! cell grid is kept incrementally and only dirty rows re-emitted
//! (render.rs), pure path steps are computed lanes wide ahead of the tick
//! (batch.rs), and ticks that change nothing are skipped (update.rs).
//!
//! Input parsing and layout still run through `engine::terminal::Terminal`
//! (once, at startup); its characters are converted into the arrays here.

pub mod batch;
pub mod effects;
pub mod events;
pub mod motion;
pub mod particles;
pub mod render;
pub mod run;
pub mod scene;
pub mod update;
pub mod visual;

use std::collections::HashMap;

use crate::engine::animation::ExistingColorHandling;
use crate::engine::canvas::Canvas;
use crate::engine::ctx::Clock;
use crate::engine::error::EngineError;
use crate::engine::terminal::{
    CharacterFilter, CharacterGroup, CharacterSort, ColorSort, Terminal, TerminalConfig,
};
use crate::utils::geometry::Coord;
use crate::utils::graphics::Color;
use crate::utils::rng::Rng;

pub use events::{Action, Caller, Event};
pub use scene::{Frame, SceneId};
pub use visual::{Visual, VisualInfo};

/// The effect side of CALLBACK actions: `Action::Callback(id, arg)` calls
/// `callback(engine, slot, id, arg)`.
pub trait Hooks {
    fn callback(&mut self, _engine: &mut Engine, _slot: u32, _id: u32, _arg: i64) {}
}

// ------------------------------------------------------------------ indexing

/// An index into one of the engine's tables: a slot, scene, frame, cell or
/// bitmap word.
pub trait Ix: Copy {
    fn ix(self) -> usize;
}

impl Ix for u32 {
    #[inline(always)]
    fn ix(self) -> usize {
        self as usize
    }
}

impl Ix for usize {
    #[inline(always)]
    fn ix(self) -> usize {
        self
    }
}

/// Per-frame indexing without bounds checks.
///
/// Every table is indexed by handles the engine hands out itself (slots,
/// scene ids, frame spans, grid cells, bitmap words sized by `grow`), so an
/// index is in bounds by construction; debug builds still check it. Build
/// paths and anything indexed by effect-supplied values use plain indexing.
pub trait At<T> {
    fn at(&self, i: impl Ix) -> &T;
    fn at_mut(&mut self, i: impl Ix) -> &mut T;
}

impl<T> At<T> for [T] {
    #[inline(always)]
    fn at(&self, i: impl Ix) -> &T {
        let i = i.ix();
        debug_assert!(i < self.len(), "index {i} out of bounds ({})", self.len());
        // SAFETY: engine handles are in bounds by construction (see At).
        unsafe { self.get_unchecked(i) }
    }

    #[inline(always)]
    fn at_mut(&mut self, i: impl Ix) -> &mut T {
        let i = i.ix();
        debug_assert!(i < self.len(), "index {i} out of bounds ({})", self.len());
        // SAFETY: engine handles are in bounds by construction (see At).
        unsafe { self.get_unchecked_mut(i) }
    }
}

/// Slot sentinel: no scene, path, character or cell.
pub const NONE: u32 = u32::MAX;

pub use crate::utils::hash::{FxBuild, FxHasher};

// ------------------------------------------------------------------ symbols

/// An interned symbol string.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Sym(pub u32);

pub struct Symbols {
    strings: Vec<Box<str>>,
    map: HashMap<Box<str>, Sym, FxBuild>,
    /// Single-codepoint symbols below this bound skip the map.
    ascii: [u32; 128],
}

impl Default for Symbols {
    fn default() -> Self {
        Symbols {
            strings: Vec::new(),
            map: HashMap::default(),
            ascii: [0; 128],
        }
    }
}

impl Symbols {
    pub fn intern(&mut self, symbol: &str) -> Sym {
        let bytes = symbol.as_bytes();
        if bytes.len() == 1 && bytes[0] < 128 {
            let slot = self.ascii[bytes[0] as usize];
            if slot != 0 {
                return Sym(slot - 1);
            }
        }
        let sym = match self.map.get(symbol) {
            Some(&sym) => sym,
            None => {
                let sym = Sym(self.strings.len() as u32);
                self.strings.push(symbol.into());
                self.map.insert(symbol.into(), sym);
                sym
            }
        };
        if bytes.len() == 1 && bytes[0] < 128 {
            self.ascii[bytes[0] as usize] = sym.0 + 1;
        }
        sym
    }

    /// intern() of a one-character symbol.
    #[inline]
    pub fn intern_char(&mut self, c: char) -> Sym {
        if (c as u32) < 128 {
            let slot = self.ascii[c as usize];
            if slot != 0 {
                return Sym(slot - 1);
            }
        }
        self.intern(c.encode_utf8(&mut [0; 4]))
    }

    #[inline]
    pub fn get(&self, sym: Sym) -> &str {
        &self.strings[sym.0 as usize]
    }
}

// ------------------------------------------------------------------ names

/// A scene, path or waypoint name. The old engine's auto ids are the decimal
/// strings "0", "1", ...; those are the numbers themselves, so a literal name
/// that spells a number is the same name. Other literals are interned above
/// `NAME_LITERAL`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Name(pub u32);

pub const NAME_LITERAL: u32 = 0x8000_0000;

impl Name {
    pub const NONE: Name = Name(NONE);

    #[inline]
    pub fn auto(n: usize) -> Name {
        Name(n as u32)
    }
}

#[derive(Default)]
pub struct Names {
    strings: Vec<Box<str>>,
    map: HashMap<Box<str>, Name, FxBuild>,
}

impl Names {
    pub fn intern(&mut self, name: &str) -> Name {
        // canonical decimal (no sign, no leading zero) below NAME_LITERAL
        let canonical = !name.is_empty()
            && name.len() <= 10
            && name.bytes().all(|b| b.is_ascii_digit())
            && (name == "0" || !name.starts_with('0'));
        if canonical {
            if let Ok(n) = name.parse::<u64>() {
                if n < NAME_LITERAL as u64 {
                    return Name(n as u32);
                }
            }
        }
        if let Some(&n) = self.map.get(name) {
            return n;
        }
        let n = Name(NAME_LITERAL + self.strings.len() as u32);
        self.strings.push(name.into());
        self.map.insert(name.into(), n);
        n
    }

    pub fn to_string(&self, name: Name) -> String {
        if name.0 < NAME_LITERAL {
            name.0.to_string()
        } else {
            self.strings[(name.0 - NAME_LITERAL) as usize].to_string()
        }
    }
}

// ------------------------------------------------------------------ characters

pub const CF_VISIBLE: u16 = 1;
pub const CF_INPUT: u16 = 4;
pub const CF_FILL_INNER: u16 = 8;
pub const CF_FILL_OUTER: u16 = 16;
pub const CF_ADDED: u16 = 32;
pub const CF_PREEXISTING: u16 = 64;
pub const CF_BOLD: u16 = 128;
/// In its particle pool's available queue.
pub const CF_POOLED: u16 = 256;
pub const CF_FILL: u16 = CF_FILL_INNER | CF_FILL_OUTER;

/// Cardinal neighbors (north, east, south, west), NONE at the edges.
#[derive(Debug, Clone, Copy)]
pub struct Neighbors {
    pub north: u32,
    pub east: u32,
    pub south: u32,
    pub west: u32,
}

impl Neighbors {
    const NONE: Neighbors = Neighbors {
        north: NONE,
        east: NONE,
        south: NONE,
        west: NONE,
    };
}

/// The character store: one array per field, indexed by slot.
#[derive(Default)]
pub struct Chars {
    pub sym: Vec<Sym>,
    pub coord: Vec<Coord>,
    pub prev_coord: Vec<Coord>,
    pub input_coord: Vec<Coord>,
    pub id: Vec<u32>,
    pub layer: Vec<i32>,
    pub visual: Vec<Visual>,
    pub scene: Vec<u32>,
    pub scenes: Vec<u32>,
    pub path: Vec<u32>,
    pub done_path: Vec<u32>,
    pub paths: Vec<u32>,
    pub events: Vec<u32>,
    pub subs: Vec<u8>,
    pub flags: Vec<u16>,
    pub fg: Vec<Option<Color>>,
    pub bg: Vec<Option<Color>>,
    pub nbr: Vec<Neighbors>,
    pub cell: Vec<u32>,
}

impl Chars {
    #[inline]
    pub fn len(&self) -> usize {
        self.sym.len()
    }

    #[inline]
    pub fn is_empty(&self) -> bool {
        self.sym.is_empty()
    }

    fn push(&mut self, sym: Sym, coord: Coord, id: u32, visual: Visual) -> u32 {
        let slot = self.sym.len() as u32;
        self.sym.push(sym);
        self.coord.push(coord);
        self.prev_coord.push(Coord::new(-1, -1));
        self.input_coord.push(coord);
        self.id.push(id);
        self.layer.push(0);
        self.visual.push(visual);
        self.scene.push(NONE);
        self.scenes.push(NONE);
        self.path.push(NONE);
        self.done_path.push(NONE);
        self.paths.push(NONE);
        self.events.push(NONE);
        self.subs.push(0);
        self.flags.push(0);
        self.fg.push(None);
        self.bg.push(None);
        self.nbr.push(Neighbors::NONE);
        self.cell.push(NONE);
        slot
    }
}

// ------------------------------------------------------------------ engine

pub struct Engine {
    pub config: TerminalConfig,
    pub canvas: Canvas,
    pub rng: Rng,
    pub clock: Clock,
    pub symbols: Symbols,
    pub names: Names,
    pub visuals: visual::VisualPool,
    /// add_character's plain visual per symbol id (NONE until made).
    plain_visuals: Vec<Visual>,
    pub ch: Chars,
    next_character_id: u32,
    /// Terminal.input_characters etc., in the old engine's order.
    pub input_chars: Vec<u32>,
    pub inner_fill_chars: Vec<u32>,
    pub outer_fill_chars: Vec<u32>,
    pub added_chars: Vec<u32>,
    /// Slot by input coordinate over the canvas rectangle (NONE when empty).
    by_input_coord: Vec<u32>,
    pub input_colors_frequency: Vec<(Color, i64)>,
    pub preexisting_colors_present: bool,
    pub scenes: scene::Scenes,
    pub paths: motion::Paths,
    pub events: events::EventStore,
    pub active: update::Active,
    pub render: render::Front,
    /// motion_batch's results for the word update is ticking.
    batch: batch::Batch,
    /// Bumped when an effect callback runs: it may change any path.
    motion_epoch: u32,
    /// The old front end's terminal, kept for resize handling only.
    pub terminal: Terminal,
}

impl Engine {
    pub fn new(
        input_data: &str,
        config: TerminalConfig,
        rng: Rng,
        clock: Clock,
    ) -> Result<Self, EngineError> {
        let (terminal, chars) = Terminal::parse(input_data, config.clone())?;
        let mut symbols = Symbols::default();
        let mut visuals = visual::VisualPool::new(config.no_color, config.xterm_colors);
        // input parsing's appearance: under --existing-color-handling always a
        // character that uses its input colors shows them (set_appearance)
        let always = config.existing_color_handling == ExistingColorHandling::Always;
        let mut plain = [Visual(NONE); 128];
        let n = chars.len();
        let mut sym = Vec::with_capacity(n);
        let mut visual = Vec::with_capacity(n);
        for c in &chars {
            let s = symbols.intern_char(c.symbol);
            let v = if always && c.uses_preexisting_colors {
                let attrs = visual::HAS_COLORS | if c.bold { visual::BOLD } else { 0 };
                visuals.make(
                    &symbols,
                    VisualInfo {
                        sym: s,
                        fg: c.fg,
                        bg: c.bg,
                        attrs,
                    },
                )
            } else {
                let info = VisualInfo {
                    sym: s,
                    fg: None,
                    bg: None,
                    attrs: 0,
                };
                match plain.get_mut(c.symbol as usize) {
                    Some(v) if v.0 != NONE => *v,
                    Some(v) => {
                        *v = visuals.make(&symbols, info);
                        *v
                    }
                    None => visuals.make(&symbols, info),
                }
            };
            sym.push(s);
            visual.push(v);
        }
        let mut ch = Chars {
            sym,
            coord: chars.iter().map(|c| c.coord).collect(),
            prev_coord: vec![Coord::new(-1, -1); n],
            input_coord: chars.iter().map(|c| c.input_coord).collect(),
            id: chars.iter().map(|c| c.character_id).collect(),
            layer: vec![0; n],
            visual,
            scene: vec![NONE; n],
            scenes: vec![NONE; n],
            path: vec![NONE; n],
            done_path: vec![NONE; n],
            paths: vec![NONE; n],
            events: vec![NONE; n],
            subs: vec![0; n],
            flags: chars
                .iter()
                .map(|c| {
                    (if c.uses_preexisting_colors {
                        CF_PREEXISTING
                    } else {
                        0
                    }) | if c.bold { CF_BOLD } else { 0 }
                })
                .collect(),
            fg: chars.iter().map(|c| c.fg).collect(),
            bg: chars.iter().map(|c| c.bg).collect(),
            nbr: vec![Neighbors::NONE; n],
            cell: vec![NONE; n],
        };
        // Terminal._setup_character_neighbors over the coordinate grid
        let canvas = terminal.canvas.clone();
        let by_input_coord = terminal.input_grid.clone();
        let width = canvas.right.max(0);
        let at = |column: i64, row: i64| match canvas_index(&canvas, Coord::new(column, row)) {
            Some(index) => by_input_coord[index],
            None => NONE,
        };
        for (index, &slot) in by_input_coord.iter().enumerate() {
            if slot != NONE {
                let (column, row) = (index as i64 % width + 1, index as i64 / width + 1);
                ch.nbr[slot as usize] = Neighbors {
                    north: at(column, row + 1),
                    east: at(column + 1, row),
                    south: at(column, row - 1),
                    west: at(column - 1, row),
                };
            }
        }
        let slots = |ids: &[crate::engine::character::CharId]| {
            ids.iter().map(|id| id.0).collect::<Vec<u32>>()
        };
        let input_chars = slots(&terminal.input_characters);
        let inner_fill_chars = slots(&terminal.inner_fill_characters);
        let outer_fill_chars = slots(&terminal.outer_fill_characters);
        for &s in &input_chars {
            ch.flags[s as usize] |= CF_INPUT;
        }
        for &s in &inner_fill_chars {
            ch.flags[s as usize] |= CF_FILL_INNER;
        }
        for &s in &outer_fill_chars {
            ch.flags[s as usize] |= CF_FILL_OUTER;
        }
        let preexisting_colors_present = input_chars
            .iter()
            .any(|&s| ch.fg[s as usize].is_some() || ch.bg[s as usize].is_some());
        let render = render::Front::new(&terminal, &mut visuals, &mut symbols);
        let next_character_id = terminal.next_character_id;
        let input_colors_frequency = terminal.input_colors_frequency.0.clone();
        let mut engine = Engine {
            config,
            canvas,
            rng,
            clock,
            symbols,
            names: Names::default(),
            visuals,
            plain_visuals: Vec::new(),
            ch,
            next_character_id,
            input_chars,
            inner_fill_chars,
            outer_fill_chars,
            added_chars: Vec::new(),
            by_input_coord,
            input_colors_frequency,
            preexisting_colors_present,
            scenes: scene::Scenes::default(),
            paths: motion::Paths::default(),
            events: events::EventStore::default(),
            active: update::Active::default(),
            render,
            batch: batch::Batch::default(),
            motion_epoch: 0,
            terminal,
        };
        engine.active.grow(engine.ch.len());
        engine.paths.m.grow(engine.ch.len());
        Ok(engine)
    }

    // -------------------------------------------------------------- names

    #[inline]
    pub fn name(&mut self, name: &str) -> Name {
        self.names.intern(name)
    }

    #[inline]
    pub fn sym(&mut self, symbol: &str) -> Sym {
        self.symbols.intern(symbol)
    }

    #[inline]
    pub fn symbol(&self, sym: Sym) -> &str {
        self.symbols.get(sym)
    }

    // -------------------------------------------------------------- characters

    #[inline]
    pub fn char_count(&self) -> usize {
        self.ch.len()
    }

    #[inline]
    pub fn coord(&self, slot: u32) -> Coord {
        self.ch.coord[slot as usize]
    }

    #[inline]
    pub fn input_coord(&self, slot: u32) -> Coord {
        self.ch.input_coord[slot as usize]
    }

    #[inline]
    pub fn input_sym(&self, slot: u32) -> Sym {
        self.ch.sym[slot as usize]
    }

    #[inline]
    pub fn layer(&self, slot: u32) -> i32 {
        self.ch.layer[slot as usize]
    }

    #[inline]
    pub fn is_visible(&self, slot: u32) -> bool {
        self.ch.flags[slot as usize] & CF_VISIBLE != 0
    }

    #[inline]
    pub fn uses_preexisting_colors(&self, slot: u32) -> bool {
        self.ch.flags[slot as usize] & CF_PREEXISTING != 0
    }

    #[inline]
    pub fn is_fill(&self, slot: u32) -> bool {
        self.ch.flags[slot as usize] & CF_FILL != 0
    }

    #[inline]
    pub fn input_fg(&self, slot: u32) -> Option<Color> {
        self.ch.fg[slot as usize]
    }

    #[inline]
    pub fn input_bg(&self, slot: u32) -> Option<Color> {
        self.ch.bg[slot as usize]
    }

    #[inline]
    pub fn input_bold(&self, slot: u32) -> bool {
        self.ch.flags[slot as usize] & CF_BOLD != 0
    }

    #[inline]
    pub fn neighbors(&self, slot: u32) -> Neighbors {
        self.ch.nbr[slot as usize]
    }

    /// The character's current visual (current_character_visual).
    #[inline]
    pub fn current_visual(&self, slot: u32) -> Visual {
        self.ch.visual[slot as usize]
    }

    #[inline]
    pub fn visual_info(&self, visual: Visual) -> VisualInfo {
        self.visuals.info(visual)
    }

    /// Motion.set_coordinate.
    pub fn set_coordinate(&mut self, slot: u32, coord: Coord) {
        self.ch.coord[slot as usize] = coord;
        self.coordinate_changed(slot);
    }

    pub fn set_layer(&mut self, slot: u32, layer: i32) {
        if self.ch.layer[slot as usize] != layer {
            self.ch.layer[slot as usize] = layer;
            self.layer_changed(slot);
        }
    }

    /// Terminal.add_character: registered only in added_chars, not in the
    /// input-coordinate map or the neighbor graph.
    pub fn add_character(&mut self, symbol: &str, coord: Coord) -> u32 {
        let sym = self.symbols.intern(symbol);
        self.add_character_sym(sym, coord)
    }

    /// add_character with an interned symbol.
    pub fn add_character_sym(&mut self, sym: Sym, coord: Coord) -> u32 {
        let i = sym.0 as usize;
        if i >= self.plain_visuals.len() {
            self.plain_visuals.resize(i + 1, Visual(NONE));
        }
        let mut visual = self.plain_visuals[i];
        if visual.0 == NONE {
            let info = VisualInfo {
                sym,
                fg: None,
                bg: None,
                attrs: 0,
            };
            visual = self.visuals.make(&self.symbols, info);
            self.plain_visuals[i] = visual;
        }
        let slot = self.ch.push(sym, coord, self.next_character_id, visual);
        self.next_character_id += 1;
        self.ch.flags[slot as usize] = CF_ADDED;
        self.added_chars.push(slot);
        self.active.grow(self.ch.len());
        self.paths.m.grow(self.ch.len());
        slot
    }

    pub fn char_at_input_coord(&self, coord: Coord) -> Option<u32> {
        canvas_index(&self.canvas, coord)
            .map(|i| self.by_input_coord[i])
            .filter(|&s| s != NONE)
    }

    pub fn collect_characters(&self, filter: CharacterFilter) -> Vec<u32> {
        let mut all = Vec::new();
        if filter.input_chars {
            all.extend(&self.input_chars);
        }
        if filter.inner_fill_chars {
            all.extend(&self.inner_fill_chars);
        }
        if filter.outer_fill_chars {
            all.extend(&self.outer_fill_chars);
        }
        if filter.added_chars {
            all.extend(&self.added_chars);
        }
        all
    }

    /// Terminal.get_characters.
    pub fn get_characters(&mut self, filter: CharacterFilter, sort: CharacterSort) -> Vec<u32> {
        let mut all = match self.top_down(filter) {
            Some(all) => all,
            None => {
                let mut all = self.collect_characters(filter);
                let ic = &self.ch.input_coord;
                all.sort_by_key(|&s| {
                    let c = ic[s as usize];
                    (-c.row, c.column)
                });
                all
            }
        };
        let ic = &self.ch.input_coord;
        match sort {
            CharacterSort::Random => self.rng.shuffle(&mut all),
            CharacterSort::TopToBottomLeftToRight => {}
            CharacterSort::BottomToTopRightToLeft => all.reverse(),
            CharacterSort::BottomToTopLeftToRight | CharacterSort::TopToBottomRightToLeft => {
                all.sort_by_key(|&s| {
                    let c = ic[s as usize];
                    (c.row, c.column)
                });
                if sort == CharacterSort::TopToBottomRightToLeft {
                    all.reverse();
                }
            }
            CharacterSort::OutsideRowToMiddle | CharacterSort::MiddleRowToOutside => {
                let mut interleaved = Vec::with_capacity(all.len());
                let (mut lo, mut hi) = (0usize, all.len());
                let mut from_front = true;
                while lo < hi {
                    if from_front {
                        interleaved.push(all[lo]);
                        lo += 1;
                    } else {
                        hi -= 1;
                        interleaved.push(all[hi]);
                    }
                    from_front = !from_front;
                }
                all = interleaved;
                if sort == CharacterSort::MiddleRowToOutside {
                    all.reverse();
                }
            }
        }
        all
    }

    /// collect_characters sorted by (-row, column), without added
    /// characters: the input and fill characters are one per canvas cell,
    /// so that is the coordinate grid read from the top row down. None when
    /// added characters are asked for.
    fn top_down(&self, filter: CharacterFilter) -> Option<Vec<u32>> {
        if filter.added_chars && !self.added_chars.is_empty() {
            return None;
        }
        let mask = if filter.input_chars { CF_INPUT } else { 0 }
            | if filter.inner_fill_chars {
                CF_FILL_INNER
            } else {
                0
            }
            | if filter.outer_fill_chars {
                CF_FILL_OUTER
            } else {
                0
            };
        let width = self.canvas.right.max(0) as usize;
        let mut all = Vec::with_capacity(self.by_input_coord.len());
        if width > 0 {
            for row in self.by_input_coord.chunks_exact(width).rev() {
                for &s in row {
                    if s != NONE && self.ch.flags[s as usize] & mask != 0 {
                        all.push(s);
                    }
                }
            }
        }
        Some(all)
    }

    /// Terminal.get_characters_grouped.
    pub fn get_characters_grouped(
        &self,
        filter: CharacterFilter,
        grouping: CharacterGroup,
    ) -> Vec<Vec<u32>> {
        let mut all = self.collect_characters(filter);
        let ic = &self.ch.input_coord;
        all.sort_by_key(|&s| {
            let c = ic[s as usize];
            (c.row, c.column)
        });
        let coord = |s: u32| ic[s as usize];
        let canvas = &self.canvas;
        let mut groups = match grouping {
            CharacterGroup::ColumnLeftToRight | CharacterGroup::ColumnRightToLeft => {
                ordered_buckets(all, 0, canvas.right, |s| coord(s).column)
            }
            CharacterGroup::RowBottomToTop | CharacterGroup::RowTopToBottom => {
                ordered_buckets(all, 0, canvas.top, |s| coord(s).row)
            }
            CharacterGroup::DiagonalBottomLeftToTopRight
            | CharacterGroup::DiagonalTopRightToBottomLeft => {
                ordered_buckets(all, 0, canvas.top + canvas.right, |s| {
                    coord(s).row + coord(s).column
                })
            }
            CharacterGroup::DiagonalTopLeftToBottomRight
            | CharacterGroup::DiagonalBottomRightToTopLeft => ordered_buckets(
                all,
                canvas.left - canvas.top,
                canvas.right - canvas.bottom,
                |s| coord(s).column - coord(s).row,
            ),
            CharacterGroup::CenterToOutside | CharacterGroup::OutsideToCenter => {
                let center = canvas.text_center;
                let distance = |s: u32| {
                    let c = coord(s);
                    (c.column - center.column).abs() + (c.row - center.row).abs()
                };
                let max_distance = all.iter().map(|&s| distance(s)).max();
                let dense_limit = all.len().saturating_mul(4).max(256);
                if max_distance
                    .and_then(|d| usize::try_from(d).ok())
                    .is_some_and(|d| d <= dense_limit)
                {
                    ordered_buckets(all, 0, max_distance.unwrap(), distance)
                } else {
                    let mut by_distance: Vec<(i64, u32)> =
                        all.iter().map(|&s| (distance(s), s)).collect();
                    by_distance.sort_by_key(|&(d, _)| d);
                    let mut groups: Vec<Vec<u32>> = Vec::new();
                    let mut last = None;
                    for (d, s) in by_distance {
                        if last != Some(d) {
                            groups.push(Vec::new());
                            last = Some(d);
                        }
                        groups.last_mut().unwrap().push(s);
                    }
                    groups
                }
            }
        };
        if matches!(
            grouping,
            CharacterGroup::ColumnRightToLeft
                | CharacterGroup::RowTopToBottom
                | CharacterGroup::DiagonalTopRightToBottomLeft
                | CharacterGroup::DiagonalBottomRightToTopLeft
                | CharacterGroup::OutsideToCenter
        ) {
            groups.reverse();
        }
        groups
    }

    /// Terminal.get_input_colors.
    pub fn get_input_colors(&mut self, sort: ColorSort) -> Vec<Color> {
        let mut colors = self.input_colors_frequency.clone();
        match sort {
            ColorSort::MostToLeast => colors.sort_by(|a, b| b.1.cmp(&a.1)),
            ColorSort::LeastToMost => colors.sort_by(|a, b| a.1.cmp(&b.1)),
            ColorSort::Random => self.rng.shuffle(&mut colors),
        }
        colors.into_iter().map(|(c, _)| c).collect()
    }

    #[inline]
    pub fn existing_color_handling(&self) -> ExistingColorHandling {
        self.config.existing_color_handling
    }
}

fn canvas_index(canvas: &Canvas, coord: Coord) -> Option<usize> {
    (1 <= coord.column && coord.column <= canvas.right && 1 <= coord.row && coord.row <= canvas.top)
        .then(|| ((coord.row - 1) * canvas.right + (coord.column - 1)) as usize)
}

fn ordered_buckets(
    characters: Vec<u32>,
    first_key: i64,
    last_key: i64,
    key: impl Fn(u32) -> i64,
) -> Vec<Vec<u32>> {
    if first_key > last_key {
        return Vec::new();
    }
    let bucket_count =
        usize::try_from(last_key - first_key + 1).expect("terminal canvas is too large");
    let mut buckets: Vec<Vec<u32>> = vec![Vec::new(); bucket_count];
    for s in characters {
        let k = key(s);
        if first_key <= k && k <= last_key {
            buckets[(k - first_key) as usize].push(s);
        }
    }
    buckets.into_iter().filter(|b| !b.is_empty()).collect()
}
