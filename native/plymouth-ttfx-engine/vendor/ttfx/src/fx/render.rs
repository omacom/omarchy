//! Visibility and the frame renderer (terminal.rs update_render_cells and
//! get_formatted_output_string).
//!
//! The cell grid keeps each cell's winning slot (maximum (layer, slot): the
//! old engine's painter order, slots ascending with character_id) and its
//! visual. The old engine rebuilds and formats every cell each frame; here
//! the renderer alone maintains the grid incrementally. The effect's side
//! (`set_visible`, `coordinate_changed`, `layer_changed`, `set_visual`) only
//! tracks each character's cell and appends 8-byte records to the frame's
//! change log (`Front`); the renderer replays the log before formatting
//! (`Render::apply`):
//!
//!   * a visual change reaches the grid when its character owns the cell;
//!   * a character entering a cell competes for it on the spot;
//!   * moving, changing layer or hiding takes a character out of its cell's
//!     occupant list; a cell whose owner left picks the best of the rest
//!     after the replay (scanned once a frame, not once per departure).
//!
//! A cell's winner depends only on its occupants, so replaying the log in
//! order gives the grid a direct update would. The renderer can thus run on
//! its own thread (run.rs), with its own copy of the visual pool's bytes.
//!
//! Every write to a cell sets its dirty byte. Grid rows are padded to a power
//! of two of at least 64 cells, so a row's dirty bytes are whole 64-byte
//! chunks.
//!
//! Emission: each row keeps its bytes (with its joining newline) and the byte
//! offset of every BLOCK-cell block. Clean rows are skipped. A row with few
//! dirty runs of blocks is patched in place, right to left, moving the tail
//! only when a run's length changed; a mostly dirty row is formatted whole.
//! A frame goes to the kernel as one iovec per row.

use crate::engine::terminal::Terminal;
use crate::utils::geometry::Coord;
use crate::utils::simd::{load, store};

use super::visual::{Span, VisualPool, COPY_BLOCK};
use super::{At, Engine, Sym, Symbols, Visual, CF_VISIBLE, NONE};

/// Cells per dirty block (one emission step).
const BLOCK: usize = 4;
/// A clean gap of fewer blocks than this between dirty runs is formatted
/// along with them: a copy has a fixed cost of several blocks' formatting.
const MIN_GAP: usize = 4;
/// Rows with more dirty runs than this are rebuilt, not patched in place.
const IN_PLACE_RUNS: usize = 1;
/// Row buffer room past the cells at their longest: the newline and the
/// fixed-size copies' overrun.
const ROW_SLACK: usize = 2 * COPY_BLOCK + 64;
/// Block start entries past a row's end: offset shifts run over by up to
/// OFFS_RUN - 1 entries.
const OFFS_RUN: usize = 16;

// Change log records: (slot | op) in the low word, the value (the visual,
// the layer, or the cell or NONE) in the high one.
const LOG_HANDLE: u32 = 0;
const LOG_LAYER: u32 = 1 << 30;
const LOG_MOVE: u32 = 2 << 30;
const LOG_SLOT: u32 = (1 << 30) - 1;
/// An owner to be chosen again once the frame's log is replayed.
const PENDING: u32 = NONE - 1;

/// Which grid cell a coordinate shows.
struct CellMap {
    stride: usize,
    row_offset: i64,
    column_offset: i64,
    bottom: i64,
    left: i64,
    /// Rows and columns in the visible window, 0 when it is empty (the
    /// terminal can report a top below the bottom, e.g. under LINES=0).
    rows: u64,
    columns: u64,
}

impl CellMap {
    /// The grid cell showing this coordinate, or NONE outside the window.
    #[inline(always)]
    fn cell_of(&self, coord: Coord) -> u32 {
        // unsigned: bottom <= row <= top and left <= column <= right; an
        // empty window has 0 rows or columns and matches nothing
        let row = coord.row.wrapping_add(self.row_offset);
        let column = coord.column.wrapping_add(self.column_offset);
        if (row.wrapping_sub(self.bottom) as u64) < self.rows
            && (column.wrapping_sub(self.left) as u64) < self.columns
        {
            ((row - 1) as usize * self.stride + (column - 1) as usize) as u32
        } else {
            NONE
        }
    }
}

/// The effect's side of the renderer: the cell map and the open frame's
/// change log. `ch.cell` is the cell the log last put a character in (NONE
/// when hidden or outside the window); only characters with a cell log
/// visual and layer changes, and one entering a cell logs both first.
pub struct Front {
    map: CellMap,
    pub(super) log: Vec<u64>,
    /// The renderer, while it runs on this thread.
    pub(super) back: Option<Box<Render>>,
}

impl Front {
    pub fn new(terminal: &Terminal, visuals: &mut VisualPool, symbols: &mut Symbols) -> Self {
        let back = Render::new(terminal, visuals, symbols);
        Front {
            map: CellMap {
                stride: back.stride,
                row_offset: terminal.canvas_row_offset,
                column_offset: terminal.canvas_column_offset,
                bottom: terminal.visible_bottom,
                left: terminal.visible_left,
                rows: (terminal.visible_top - terminal.visible_bottom + 1).max(0) as u64,
                columns: (terminal.visible_right - terminal.visible_left + 1).max(0) as u64,
            },
            log: Vec::with_capacity(1 << 16),
            back: Some(Box::new(back)),
        }
    }

    #[inline(always)]
    fn push(&mut self, slot_op: u32, value: u32) {
        self.log.push((value as u64) << 32 | slot_op as u64);
    }
}

#[derive(Debug, Clone, Copy)]
#[repr(C)]
struct CellRec {
    /// The occupant list's head.
    head: u32,
    /// The owner's layer.
    layer: i32,
}

/// A slot's link in its cell's occupant list, and its layer (for the scan).
#[derive(Debug, Clone, Copy)]
#[repr(C)]
struct Link {
    next: u32,
    layer: i32,
}

#[derive(Debug, Clone, Copy)]
#[repr(C)]
struct Back {
    prev: u32,
    /// The slot's cell, or NONE.
    cell: u32,
}

struct Row {
    /// Formatted cells, then the joining newline (all rows but the bottom),
    /// in the first `len` bytes. The buffer is zeroed and sized for every
    /// cell at its longest plus ROW_SLACK.
    bytes: Vec<u8>,
    len: usize,
    /// Byte offset of every block, and the cells' end.
    offs: Vec<u32>,
}

impl Row {
    fn new(blocks: usize) -> Self {
        Row {
            bytes: Vec::new(),
            len: 0,
            offs: vec![0; blocks + 1 + OFFS_RUN],
        }
    }
}

/// The renderer: the grid, its own copies of each character's layer, visual
/// and cell links, the visual pool's bytes, and the rows.
pub struct Render {
    width: usize,
    height: usize,
    /// Grid cells per row (a power of two, at least 64 and the width).
    stride: usize,
    /// Per cell: the owner (NONE when empty, PENDING while it is chosen
    /// again), and its visual's bytes (or the blank's).
    owner: Vec<u32>,
    cell_span: Vec<Span>,
    rec: Vec<CellRec>,
    link: Vec<Link>,
    back: Vec<Back>,
    visual: Vec<u32>,
    /// Cells whose owner is PENDING.
    pending: Vec<u32>,
    /// Cells whose owner showed a visual made after the last sync: their
    /// span is read once the frame's visuals are synced.
    late: Vec<u32>,
    /// The visual pool's spans and bytes (plus COPY_BLOCK bytes of slack),
    /// as far as the log has needed them.
    spans: Vec<Span>,
    bytes: Vec<u8>,
    max_len: usize,
    /// A byte per cell: written since the last frame.
    dirty: Vec<u8>,
    /// A byte per row: some cell of it is dirty.
    row_dirty: Vec<u8>,
    /// log2(stride): a cell's row.
    stride_shift: u32,
    all_dirty: bool,
    /// Blocks per row, and a row's dirty blocks (render_rows' scratch).
    blocks: usize,
    block_bits: Vec<u64>,
    /// A row's dirty runs of blocks (render_rows' scratch).
    runs: Vec<(u32, u32)>,
    /// The emission code's level: 0 baseline, 3 x86-64-v3, 4 x86-64-v4.
    tier: u8,
    rows: Vec<Row>,
    spare: Row,
    blank: Span,
}

impl Render {
    fn new(terminal: &Terminal, visuals: &mut VisualPool, symbols: &mut Symbols) -> Self {
        let width = terminal.visible_right.max(0) as usize;
        let height = terminal.visible_top.max(0) as usize;
        let stride = width.next_power_of_two().max(64);
        let cells = stride
            .checked_mul(height)
            .expect("terminal canvas is too large");
        let blank = visuals.raw(symbols.intern(" "), b" ");
        let blank = visuals.spans[blank.0 as usize];
        let blocks = width.div_ceil(BLOCK);
        let rows = (0..height).map(|_| Row::new(blocks)).collect();
        let mut r = Render {
            width,
            height,
            stride,
            owner: vec![NONE; cells],
            cell_span: vec![blank; cells],
            rec: vec![
                CellRec {
                    head: NONE,
                    layer: 0
                };
                cells
            ],
            link: Vec::new(),
            back: Vec::new(),
            visual: Vec::new(),
            pending: Vec::new(),
            late: Vec::new(),
            spans: Vec::new(),
            bytes: vec![0; COPY_BLOCK],
            max_len: 1,
            dirty: vec![0; cells],
            row_dirty: vec![0; height],
            stride_shift: stride.trailing_zeros(),
            all_dirty: true,
            blocks,
            // whole chunks of 64 / BLOCK blocks, the sentinel and a zero word
            block_bits: vec![0; width.div_ceil(64) * (64 / BLOCK) / 64 + 2],
            rows,
            spare: Row::new(blocks),
            runs: Vec::new(),
            tier: cpu_tier(),
            blank,
        };
        r.sync_pool(visuals);
        r
    }

    /// Take the pool's visuals made since the last sync.
    pub(super) fn sync_pool(&mut self, pool: &VisualPool) {
        let (spans, bytes) = pool_delta(pool, self.spans.len(), self.bytes.len() - COPY_BLOCK);
        self.sync(spans, bytes, 0);
    }

    /// Append visuals (their spans and bytes, which follow the ones held),
    /// and room for `slots` characters.
    pub(super) fn sync(&mut self, spans: &[Span], bytes: &[u8], slots: usize) {
        if !spans.is_empty() {
            self.bytes.truncate(self.bytes.len() - COPY_BLOCK);
            self.bytes.extend_from_slice(bytes);
            self.bytes.resize(self.bytes.len() + COPY_BLOCK, 0);
            for s in spans {
                self.max_len = self.max_len.max(s.len as usize);
            }
            self.spans.extend_from_slice(spans);
        }
        if self.link.len() < slots {
            self.link.resize(
                slots,
                Link {
                    next: NONE,
                    layer: 0,
                },
            );
            self.back.resize(
                slots,
                Back {
                    prev: NONE,
                    cell: NONE,
                },
            );
            self.visual.resize(slots, 0);
        }
    }

    /// The character now shows `visual` (the renderer runs on the
    /// effect's thread, between frames): the grid shows it at once when the
    /// character owns its cell. The log's moves come after, but they only
    /// settle who owns which cell, and a new owner's span is read then.
    #[inline(always)]
    pub(super) fn show(&mut self, slot: u32, visual: Visual) {
        if slot as usize >= self.visual.len() {
            self.grow_slots(slot as usize + 1);
        }
        *self.visual.at_mut(slot) = visual.0;
        let cell = self.back.at(slot).cell;
        if cell != NONE && *self.owner.at(cell) == slot {
            match self.spans.get(visual.0 as usize) {
                Some(&span) => *self.cell_span.at_mut(cell) = span,
                // made this frame: its bytes come with the frame's sync
                None => self.late.push(cell),
            }
            *self.dirty.at_mut(cell) = 1;
            *self.row_dirty.at_mut(cell >> self.stride_shift) = 1;
        }
    }

    /// The late cells take their owner's span (the visuals synced; the log
    /// replayed, or still to set the spans of the cells it changes).
    pub(super) fn settle_late(&mut self) {
        for &cell in &self.late {
            let owner = *self.owner.at(cell);
            *self.cell_span.at_mut(cell) = if owner == NONE {
                self.blank
            } else {
                *self.spans.at(*self.visual.at(owner))
            };
        }
        self.late.clear();
    }

    /// Room for as many visuals as the pool has (`pool_room`): the copies
    /// are reserved as large at once, rather than doubling (and copying)
    /// their way up to it.
    #[inline]
    pub(super) fn fit(&mut self, room: (usize, usize)) {
        if self.spans.capacity() < room.0 || self.bytes.capacity() < room.1 {
            self.reserve_room(room);
        }
    }

    #[cold]
    #[inline(never)]
    fn reserve_room(&mut self, room: (usize, usize)) {
        self.spans
            .reserve_exact(room.0.saturating_sub(self.spans.len()));
        self.bytes
            .reserve_exact(room.1.saturating_sub(self.bytes.len()));
    }

    #[cold]
    fn grow_slots(&mut self, slots: usize) {
        self.sync(&[], &[], slots.max(self.visual.len() * 2));
    }

    /// Replay a frame's change log onto the grid.
    pub(super) fn apply(&mut self, log: &[u64]) {
        // the tables as locals, so the dirty-byte stores don't force reloads
        let mut g = Grid {
            owner: &mut self.owner,
            cell_span: &mut self.cell_span,
            rec: &mut self.rec,
            link: &mut self.link,
            back: &mut self.back,
            visual: &mut self.visual,
            spans: &self.spans,
            dirty: &mut self.dirty,
            row_dirty: &mut self.row_dirty,
            pending: &mut self.pending,
            shift: self.stride_shift,
            blank: self.blank,
        };
        for &r in log {
            let (op, value) = (r as u32, (r >> 32) as u32);
            let slot = op & LOG_SLOT;
            match op >> 30 {
                0 => {
                    *g.visual.at_mut(slot) = value;
                    let cell = g.back.at(slot).cell;
                    if cell != NONE && *g.owner.at(cell) == slot {
                        *g.cell_span.at_mut(cell) = *g.spans.at(value);
                        g.mark(cell);
                    }
                }
                1 => {
                    g.link.at_mut(slot).layer = value as i32;
                    let cell = g.back.at(slot).cell;
                    if cell != NONE {
                        g.cell_pending(cell);
                    }
                }
                _ => {
                    g.cell_unlink(slot);
                    if value != NONE {
                        g.cell_link(slot, value);
                    }
                }
            }
        }
        while let Some(cell) = g.pending.pop() {
            g.cell_rewin(cell);
        }
    }
}

/// The renderer's grid tables, borrowed for one replay.
struct Grid<'a> {
    owner: &'a mut [u32],
    cell_span: &'a mut [Span],
    rec: &'a mut [CellRec],
    link: &'a mut [Link],
    back: &'a mut [Back],
    visual: &'a mut [u32],
    spans: &'a [Span],
    dirty: &'a mut [u8],
    row_dirty: &'a mut [u8],
    pending: &'a mut Vec<u32>,
    shift: u32,
    blank: Span,
}

impl Grid<'_> {
    #[inline(always)]
    fn mark(&mut self, cell: u32) {
        *self.dirty.at_mut(cell) = 1;
        *self.row_dirty.at_mut(cell >> self.shift) = 1;
    }

    /// Put a character into a cell's list and let it compete for the cell:
    /// it takes the cell when empty or when it outranks the owner on (layer,
    /// slot); a cell whose owner is pending chooses later.
    #[inline(always)]
    fn cell_link(&mut self, slot: u32, cell: u32) {
        let head = self.rec.at(cell).head;
        *self.back.at_mut(slot) = Back { prev: NONE, cell };
        self.link.at_mut(slot).next = head;
        self.rec.at_mut(cell).head = slot;
        if head != NONE {
            self.back.at_mut(head).prev = slot;
        }
        let owner = *self.owner.at(cell);
        if owner == PENDING {
            return;
        }
        let layer = self.link.at(slot).layer;
        if owner == NONE || (layer, slot) > (self.rec.at(cell).layer, owner) {
            *self.owner.at_mut(cell) = slot;
            self.rec.at_mut(cell).layer = layer;
            *self.cell_span.at_mut(cell) = *self.spans.at(*self.visual.at(slot));
            self.mark(cell);
        }
    }

    /// Take a character out of its cell; if it owned the cell, the best
    /// remaining character (or nobody) takes over: at once when one or none
    /// is left, else once the log is replayed.
    #[inline(always)]
    fn cell_unlink(&mut self, slot: u32) {
        let Back { prev, cell } = *self.back.at(slot);
        if cell == NONE {
            return;
        }
        self.back.at_mut(slot).cell = NONE;
        let next = self.link.at(slot).next;
        if prev == NONE {
            self.rec.at_mut(cell).head = next;
        } else {
            self.link.at_mut(prev).next = next;
        }
        if next != NONE {
            self.back.at_mut(next).prev = prev;
        }
        if *self.owner.at(cell) == slot {
            let head = self.rec.at(cell).head;
            if head == NONE || self.link.at(head).next == NONE {
                self.cell_rewin(cell);
            } else {
                self.cell_pending(cell);
            }
        }
    }

    /// The cell's owner is chosen again once the log is replayed.
    #[inline(always)]
    fn cell_pending(&mut self, cell: u32) {
        let owner = self.owner.at_mut(cell);
        if *owner != PENDING {
            *owner = PENDING;
            self.pending.push(cell);
        }
    }

    /// The best of the cell's occupants takes it, or nobody.
    #[inline(always)]
    fn cell_rewin(&mut self, cell: u32) {
        let (mut best, mut best_layer) = (NONE, 0);
        let mut s = self.rec.at(cell).head;
        while s != NONE {
            let Link { next, layer } = *self.link.at(s);
            if best == NONE || (layer, s) > (best_layer, best) {
                best = s;
                best_layer = layer;
            }
            s = next;
        }
        *self.owner.at_mut(cell) = best;
        self.rec.at_mut(cell).layer = best_layer;
        *self.cell_span.at_mut(cell) = if best == NONE {
            self.blank
        } else {
            *self.spans.at(*self.visual.at(best))
        };
        self.mark(cell);
    }
}

/// The pool's visuals from span `spans` and content byte `bytes` on.
pub(super) fn pool_delta(pool: &VisualPool, spans: usize, bytes: usize) -> (&[Span], &[u8]) {
    (
        &pool.spans[spans..],
        &pool.bytes[bytes..pool.bytes.len() - COPY_BLOCK],
    )
}

/// The pool's capacity (spans, bytes) for `Render::fit`.
pub(super) fn pool_room(pool: &VisualPool) -> (usize, usize) {
    (pool.spans.capacity(), pool.bytes.capacity())
}

impl Engine {
    // -------------------------------------------------------------- the log

    /// The character now shows `visual`. With the renderer on this thread
    /// the grid shows it at once; else a character with a cell logs it.
    #[inline(always)]
    pub fn set_visual(&mut self, slot: u32, visual: Visual) {
        // the effect's slot, checked
        assert!((slot as usize) < self.ch.len(), "set_visual: no character {slot}");
        self.show_visual(slot, visual);
    }

    /// set_visual for a slot known to be a character's: the scene steps
    /// take theirs from the active set or a table indexed checked before,
    /// and every Chars column is len() long. The hot path of every effect.
    #[inline(always)]
    pub(super) fn show_visual(&mut self, slot: u32, visual: Visual) {
        let current = self.ch.visual.at_mut(slot);
        if *current == visual {
            return;
        }
        *current = visual;
        if let Some(r) = &mut self.render.back {
            // show grows its tables to the slot
            r.show(slot, visual);
        } else if *self.ch.cell.at(slot) != NONE {
            self.render.push(slot | LOG_HANDLE, visual.0);
        }
    }

    /// set_visual for each of `slots`, the visual `visual_of(its symbol)`;
    /// with the renderer on this thread, the grid is looked up once.
    pub fn set_visuals(&mut self, slots: &[u32], visual_of: impl Fn(Sym) -> Visual) {
        let Some(r) = &mut self.render.back else {
            for &slot in slots {
                // the effect's slot, checked here
                let visual = visual_of(self.ch.sym[slot as usize]);
                self.show_visual(slot, visual);
            }
            return;
        };
        r.sync_pool(&self.visuals);
        if r.visual.len() < self.ch.len() {
            r.grow_slots(self.ch.len());
        }
        let (sym, current) = (&self.ch.sym[..], &mut self.ch.visual[..]);
        let spans = &r.spans[..];
        let shift = r.stride_shift;
        let (owner, cell_span, back, shown) = (
            &r.owner[..],
            &mut r.cell_span[..],
            &r.back[..],
            &mut r.visual[..],
        );
        let (dirty, row_dirty) = (&mut r.dirty[..], &mut r.row_dirty[..]);
        for &slot in slots {
            // the effect's slot, checked once; the renderer's slot tables were
            // grown to ch.len() above and every Chars column is that long
            let visual = visual_of(sym[slot as usize]);
            let current = current.at_mut(slot);
            if *current == visual {
                continue;
            }
            *current = visual;
            // as show(), the pool synced and the slots grown above
            *shown.at_mut(slot) = visual.0;
            let cell = back.at(slot).cell;
            if cell != NONE && *owner.at(cell) == slot {
                *cell_span.at_mut(cell) = *spans.at(visual.0);
                *dirty.at_mut(cell) = 1;
                *row_dirty.at_mut(cell >> shift) = 1;
            }
        }
    }

    /// Terminal.set_character_visibility.
    pub fn set_visible(&mut self, slot: u32, visible: bool) {
        let flags = &mut self.ch.flags[slot as usize];
        if (*flags & CF_VISIBLE != 0) == visible {
            return;
        }
        if visible {
            *flags |= CF_VISIBLE;
            let cell = self.render.map.cell_of(self.ch.coord[slot as usize]);
            if cell != NONE {
                self.enter_cell(slot, cell);
            }
        } else {
            *flags &= !CF_VISIBLE;
            // in bounds: flags[slot] above was checked
            let cell = self.ch.cell.at_mut(slot);
            if *cell != NONE {
                *cell = NONE;
                self.render.push(slot | LOG_MOVE, NONE);
            }
        }
    }

    /// A character without a cell takes one; the renderer learns its visual
    /// (at once when it runs on this thread) and layer first.
    #[inline(never)]
    fn enter_cell(&mut self, slot: u32, cell: u32) {
        *self.ch.cell.at_mut(slot) = cell;
        let (visual, layer) = (*self.ch.visual.at(slot), *self.ch.layer.at(slot));
        let log = &mut self.render;
        match &mut log.back {
            Some(r) => r.show(slot, visual),
            None => log.push(slot | LOG_HANDLE, visual.0),
        }
        log.push(slot | LOG_LAYER, layer as u32);
        log.push(slot | LOG_MOVE, cell);
    }

    /// The coordinate changed; a visible character changing cells logs it.
    #[inline(always)]
    pub fn coordinate_changed(&mut self, slot: u32) {
        // is_visible checks the effect's slot, which bounds the unchecked
        // reads below (every Chars column is len() long); this runs for every
        // moving character on every step
        if !self.is_visible(slot) {
            return;
        }
        let cell = self.render.map.cell_of(*self.ch.coord.at(slot));
        let current = *self.ch.cell.at(slot);
        if cell == current {
            return;
        }
        if current == NONE {
            self.enter_cell(slot, cell);
        } else {
            *self.ch.cell.at_mut(slot) = cell;
            self.render.push(slot | LOG_MOVE, cell);
        }
    }

    pub fn layer_changed(&mut self, slot: u32) {
        // the effect's slot, checked here; set_layer checked it already
        if self.ch.cell[slot as usize] != NONE {
            let layer = *self.ch.layer.at(slot);
            self.render.push(slot | LOG_LAYER, layer as u32);
        }
    }

    // -------------------------------------------------------------- inline rendering

    /// Replay the frame's log and bring the rows up to date, on this thread.
    pub fn render_here(&mut self) {
        let r = self
            .render
            .back
            .as_mut()
            .expect("the renderer runs on another thread");
        let (spans, bytes) = pool_delta(&self.visuals, r.spans.len(), r.bytes.len() - COPY_BLOCK);
        r.fit(pool_room(&self.visuals));
        r.sync(spans, bytes, self.ch.len());
        r.apply(&self.render.log);
        self.render.log.clear();
        r.settle_late();
        r.render_rows();
    }

    /// The renderer, when it runs on this thread.
    pub fn renderer(&self) -> &Render {
        self.render
            .back
            .as_ref()
            .expect("the renderer runs on another thread")
    }
}

impl Render {
    // -------------------------------------------------------------- emission

    /// Bring every row's bytes up to date with the grid.
    pub fn render_rows(&mut self) {
        #[cfg(target_arch = "x86_64")]
        match self.tier {
            // SAFETY: the CPU supports these features (cpu_tier checked).
            4 => return unsafe { self.render_rows_v4() },
            // SAFETY: as above.
            3 => return unsafe { self.render_rows_v3() },
            _ => {}
        }
        self.render_rows_body();
    }

    /// render_rows for x86-64-v3: the fixed copies are single 32-byte moves.
    #[cfg(target_arch = "x86_64")]
    #[target_feature(enable = "avx2,bmi1,bmi2,popcnt,lzcnt")]
    fn render_rows_v3(&mut self) {
        self.render_rows_body();
    }

    /// render_rows compiled for x86-64-v4: 64-byte copies are single moves.
    #[cfg(target_arch = "x86_64")]
    #[target_feature(enable = "avx512f,avx512bw,avx512vl,avx2,bmi1,bmi2,popcnt,lzcnt")]
    fn render_rows_v4(&mut self) {
        self.render_rows_body();
    }

    #[inline(always)]
    fn render_rows_body(&mut self) {
        let r = self;
        let need = r.width * r.max_len + ROW_SLACK;
        if need > r.spare.bytes.len() {
            // a longer visual appeared: room for every cell at its longest
            let size = need.next_power_of_two();
            for row in r.rows.iter_mut().chain(std::iter::once(&mut r.spare)) {
                row.bytes.resize(size, 0);
            }
        }
        let chunks = r.width.div_ceil(64);
        let pool = &r.bytes;
        for row in 0..r.height {
            if !r.all_dirty && *r.row_dirty.at(row) == 0 {
                continue;
            }
            *r.row_dirty.at_mut(row) = 0;
            let base = row * r.stride;
            let dirty = &mut r.dirty[base..base + chunks * 64];
            let full = if r.all_dirty {
                dirty.fill(0);
                true
            } else {
                let count = dirty_blocks(dirty, &mut r.block_bits);
                if count == 0 {
                    continue;
                }
                count * 4 >= r.blocks * 3
            };
            // the sentinel: next_set stops at the row's end
            r.block_bits[r.blocks >> 6] |= 1 << (r.blocks & 63);
            let cells = &r.cell_span[base..base + r.width];
            if full {
                let next = &mut r.spare;
                let mut len = emit(pool, cells, &mut next.bytes, &mut next.offs, 0, 0);
                next.offs[r.blocks] = len as u32;
                if row > 0 {
                    next.bytes[len] = b'\n';
                    len += 1;
                }
                next.len = len;
                std::mem::swap(&mut r.rows[row], &mut r.spare);
                continue;
            }
            let (bits, blocks) = (&r.block_bits, r.blocks);
            r.runs.clear();
            if blocks < 64 {
                // the row's bits fit one word (the sentinel is past them)
                word_runs(bits[0] & ((1u64 << blocks) - 1), &mut r.runs);
            } else {
                runs(bits, blocks, &mut r.runs);
            }
            if r.runs.len() > IN_PLACE_RUNS {
                // rebuild into the spare row, copying the clean blocks
                let prev = &r.rows[row];
                let next = &mut r.spare;
                let mut len = 0;
                let mut pos = 0;
                for &(b, e) in &r.runs {
                    let (b, e) = (b as usize, e as usize);
                    len = copy_clean(prev, next, pos, b, len);
                    let end = (e * BLOCK).min(r.width);
                    len = emit(pool, &cells[..end], &mut next.bytes, &mut next.offs, b, len);
                    pos = e;
                }
                len = copy_clean(prev, next, pos, blocks, len);
                next.offs[blocks] = len as u32;
                if row > 0 {
                    next.bytes[len] = b'\n';
                    len += 1;
                }
                next.len = len;
                std::mem::swap(&mut r.rows[row], &mut r.spare);
                continue;
            }
            // patch in place, right to left so the offsets of the runs
            // still ahead stay valid
            let current = &mut r.rows[row];
            for &(b, e) in r.runs.iter().rev() {
                let (b, e) = (b as usize, e as usize);
                let end = (e * BLOCK).min(r.width);
                let n: usize = cells[b * BLOCK..end].iter().map(|s| s.len as usize).sum();
                let (start, old_end) = (current.offs[b] as usize, current.offs[e] as usize);
                let old = old_end - start;
                // emit's fixed-size copies overrun the run by under COPY_BLOCK
                // bytes: the tail's first bytes are saved before the tail moves
                // and put back after. Past the row's end is free.
                assert!(old_end.max(start + n) + COPY_BLOCK <= current.bytes.len());
                // in bounds (checked above)
                let saved: [u8; COPY_BLOCK] = load(&current.bytes, old_end);
                if n != old {
                    current.bytes.copy_within(old_end..current.len, start + n);
                    current.len = current.len + n - old;
                    let delta = (n as u32).wrapping_sub(old as u32);
                    shift_offs(&mut current.offs, e, blocks + 1, delta);
                }
                let keep = start + n;
                let len = emit(
                    pool,
                    &cells[..end],
                    &mut current.bytes,
                    &mut current.offs,
                    b,
                    start,
                );
                debug_assert_eq!(len, keep);
                store(&mut current.bytes, keep, saved);
            }
        }
        r.all_dirty = false;
    }

    /// The frame's length in bytes (rows and their newlines).
    pub fn frame_len(&self) -> usize {
        self.rows.iter().map(|r| r.len).sum()
    }

    pub(super) fn differential_frame<'a>(
        &self,
        output: &'a mut crate::utils::differential::DifferentialOutput,
        prefix: &[u8],
    ) -> Option<&'a [u8]> {
        output.frame(self.width, self.height, prefix, |row, col| {
            let span = self.cell_span[(self.height - 1 - row) * self.stride + col];
            &self.bytes[span.offset as usize..(span.offset + span.len) as usize]
        })
    }

    /// The frame, top row first, between `prefix` and `suffix`, as iovec parts.
    pub fn frame_parts<'a>(
        &'a self,
        prefix: &'a [u8],
        suffix: &'a [u8],
        parts: &mut Vec<IoSlice<'a>>,
    ) {
        parts.clear();
        if !prefix.is_empty() {
            parts.push(IoSlice::new(prefix));
        }
        for row in self.rows.iter().rev() {
            parts.push(IoSlice::new(&row.bytes[..row.len]));
        }
        if !suffix.is_empty() {
            parts.push(IoSlice::new(suffix));
        }
    }
}

/// Gather a row's dirty bytes into one bit per block (`bits`) and clear them;
/// returns the number of dirty blocks. `dirty` is whole 64-cell chunks.
#[inline(always)]
fn dirty_blocks(dirty: &mut [u8], bits: &mut [u64]) -> usize {
    let chunks = dirty.len() / 64;
    let mut count = 0;
    let mut any = false;
    for w in 0..chunks.div_ceil(64 / (64 / BLOCK)) {
        // 64 / BLOCK = 16 block bits per 64-cell chunk, four chunks a word
        let mut word = 0u64;
        for k in 0..4 {
            let chunk = w * 4 + k;
            if chunk >= chunks {
                break;
            }
            let m = chunk_blocks(&mut dirty[chunk * 64..chunk * 64 + 64]);
            word |= (m as u64) << (k * 16);
        }
        *bits.at_mut(w) = word;
        any |= word != 0;
        count += word.count_ones() as usize;
    }
    let words = chunks.div_ceil(4);
    *bits.at_mut(words) = 0;
    if !any {
        return 0;
    }
    count
}

/// The dirty-block mask of one 64-cell chunk (bit i: cells 4i..4i+4), which
/// is cleared.
#[inline(always)]
fn chunk_blocks(chunk: &mut [u8]) -> u32 {
    debug_assert!(chunk.len() == 64);
    #[cfg(target_arch = "x86_64")]
    // SAFETY: SSE2 is baseline on x86_64; the chunk holds 64 bytes, and the
    // accesses are unaligned.
    unsafe {
        use std::arch::x86_64::*;
        let p = chunk.as_mut_ptr() as *mut __m128i;
        let zero = _mm_setzero_si128();
        let mut clean = 0u32;
        for i in 0..4 {
            let v = _mm_loadu_si128(p.add(i));
            // a block is clean when its four bytes (one u32 lane) are zero
            let m = _mm_movemask_ps(_mm_castsi128_ps(_mm_cmpeq_epi32(v, zero))) as u32;
            clean |= m << (i * 4);
            _mm_storeu_si128(p.add(i), zero);
        }
        !clean & 0xffff
    }
    // SAFETY: NEON is baseline on aarch64.
    #[cfg(target_arch = "aarch64")]
    unsafe {
        chunk_blocks_neon(chunk)
    }
    #[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
    {
        let mut m = 0u32;
        for (i, block) in chunk.chunks_exact(4).enumerate() {
            m |= ((u32::from_ne_bytes(block.try_into().unwrap()) != 0) as u32) << i;
        }
        chunk.fill(0);
        m
    }
}

/// chunk_blocks with NEON: a byte per block (dirty when its u32 lane is not
/// zero), then one bit per byte.
#[cfg(target_arch = "aarch64")]
#[target_feature(enable = "neon")]
#[inline]
fn chunk_blocks_neon(chunk: &mut [u8]) -> u32 {
    use crate::utils::simd::{bits_u8x16, load_u8x64, store_u8x64};
    use std::arch::aarch64::*;
    let q = load_u8x64(chunk, 0);
    let dirty = |v: uint8x16_t| {
        let v = vreinterpretq_u32_u8(v);
        vmovn_u32(vtstq_u32(v, v))
    };
    let lo = vcombine_u16(dirty(q.0), dirty(q.1));
    let hi = vcombine_u16(dirty(q.2), dirty(q.3));
    let zero = vdupq_n_u8(0);
    store_u8x64(chunk, 0, uint8x16x4_t(zero, zero, zero, zero));
    bits_u8x16(vcombine_u8(vmovn_u16(lo), vmovn_u16(hi)))
}

/// The dirty runs of blocks [b, e) of a row's bitmap (with the sentinel at
/// `blocks`); a clean gap shorter than MIN_GAP joins the runs around it.
fn runs(bits: &[u64], blocks: usize, out: &mut Vec<(u32, u32)>) {
    let mut b = next_set(bits, 0);
    while b < blocks {
        let mut e = next_clear(bits, b, blocks);
        while e < blocks {
            let n = next_set(bits, e);
            if n >= e + MIN_GAP || n >= blocks {
                break;
            }
            e = next_clear(bits, n, blocks);
        }
        out.push((b as u32, e as u32));
        if e >= blocks {
            break;
        }
        b = next_set(bits, e);
    }
}

/// `runs` for a row of fewer than 64 blocks, in registers: `m` is the dirty
/// mask (no sentinel).
#[inline(always)]
fn word_runs(m: u64, out: &mut Vec<(u32, u32)>) {
    const _: () = assert!(MIN_GAP == 4);
    // join clean gaps of at most 3 blocks: a clean block with dirty ones at
    // distances a (below) and b (above), a + b <= 4
    let (l1, l2, l3) = (m << 1, m << 2, m << 3);
    let (h1, h2, h3) = (m >> 1, m >> 2, m >> 3);
    let mut m = m | (l1 & (h1 | h2 | h3)) | (l2 & (h1 | h2)) | (l3 & h1);
    while m != 0 {
        let b = m.trailing_zeros();
        // m < 2^63 (fewer than 64 blocks): a clean bit follows the run
        let e = b + (!(m >> b)).trailing_zeros();
        out.push((b, e));
        m &= !0u64 << e;
    }
}

/// The first block >= `b` whose bit is set (the sentinel stops the scan).
#[inline(always)]
fn next_set(bits: &[u64], b: usize) -> usize {
    let mut w = b >> 6;
    let mut m = *bits.at(w) & (!0u64 << (b & 63));
    while m == 0 {
        w += 1;
        m = *bits.at(w);
    }
    w << 6 | m.trailing_zeros() as usize
}

/// The first block >= `b` whose bit is clear, at most `limit`.
#[inline(always)]
fn next_clear(bits: &[u64], b: usize, limit: usize) -> usize {
    let mut w = b >> 6;
    let mut m = !*bits.at(w) & (!0u64 << (b & 63));
    while m == 0 {
        w += 1;
        m = !*bits.at(w);
    }
    (w << 6 | m.trailing_zeros() as usize).min(limit)
}

/// The x86-64 level emission may use (see Render::tier).
fn cpu_tier() -> u8 {
    #[cfg(target_arch = "x86_64")]
    {
        use std::arch::is_x86_feature_detected as has;
        let v3 = has!("avx2") && has!("bmi1") && has!("bmi2") && has!("popcnt") && has!("lzcnt");
        if v3 && has!("avx512f") && has!("avx512bw") && has!("avx512vl") {
            return 4;
        }
        if v3 {
            return 3;
        }
    }
    0
}

/// Copy the clean blocks [from, to) from the previous bytes to `len`,
/// shifting their offsets; returns the new length. Offsets past `to` and
/// bytes past the copy may be overwritten (the caller writes them next, or
/// they are slack).
#[inline(always)]
fn copy_clean(prev: &Row, next: &mut Row, from: usize, to: usize, len: usize) -> usize {
    if from >= to {
        return len;
    }
    let start = *prev.offs.at(from) as usize;
    let run = *prev.offs.at(to) as usize - start;
    let delta = (len as u32).wrapping_sub(start as u32);
    let mut i = from;
    while i < to {
        // every offs array has OFFS_RUN entries past the row's blocks, so
        // the run-over stays inside it
        let s: [u32; OFFS_RUN] = load(&prev.offs, i);
        store(&mut next.offs, i, s.map(|o| o.wrapping_add(delta)));
        i += OFFS_RUN;
    }
    debug_assert!(start + run.next_multiple_of(COPY_BLOCK) <= prev.bytes.len());
    debug_assert!(len + run.next_multiple_of(COPY_BLOCK) <= next.bytes.len());
    // SAFETY: both buffers hold the run rounded up to whole COPY_BLOCKs:
    // every buffer keeps ROW_SLACK past its longest content.
    unsafe {
        let (src, dst) = (
            prev.bytes.as_ptr().add(start),
            next.bytes.as_mut_ptr().add(len),
        );
        let mut i = 0;
        while i < run {
            copy_block(src.add(i), dst.add(i));
            i += COPY_BLOCK;
        }
    }
    len + run
}

/// offs[from..to] += delta, OFFS_RUN entries at a time (running over into
/// the slack).
#[inline(always)]
fn shift_offs(offs: &mut [u32], from: usize, to: usize, delta: u32) {
    debug_assert!(to + OFFS_RUN - 1 <= offs.len());
    let mut i = from;
    while i < to {
        // the run-over stays inside the OFFS_RUN slack entries
        let s: [u32; OFFS_RUN] = load(offs, i);
        store(offs, i, s.map(|o| o.wrapping_add(delta)));
        i += OFFS_RUN;
    }
}

/// Format `cells[first_block * BLOCK..]` into `out` from `len`, recording
/// every block's start; returns the new length. A block whose visuals are all
/// shorter than 32 bytes is four fixed 32-byte copies.
#[inline(always)]
fn emit(
    pool: &[u8],
    cells: &[Span],
    out: &mut [u8],
    offs: &mut [u32],
    first_block: usize,
    mut len: usize,
) -> usize {
    let mut c = first_block * BLOCK;
    let mut b = first_block;
    let out = out.as_mut_ptr();
    let pool = pool.as_ptr();
    // SAFETY: `out` holds every cell at the longest visual's length plus
    // ROW_SLACK (render_rows sizes it), so the fixed copies stay inside it;
    // the pool keeps COPY_BLOCK readable bytes past every visual.
    unsafe {
        while c + BLOCK <= cells.len() {
            *offs.at_mut(b) = len as u32;
            b += 1;
            let q = [
                *cells.at(c),
                *cells.at(c + 1),
                *cells.at(c + 2),
                *cells.at(c + 3),
            ];
            if (q[0].len | q[1].len | q[2].len | q[3].len) < 32 {
                for s in q {
                    copy32(pool.add(s.offset as usize), out.add(len));
                    len += s.len as usize;
                }
            } else {
                for s in q {
                    len = emit_cell(pool, s, out, len);
                }
            }
            c += BLOCK;
        }
        if c < cells.len() {
            *offs.at_mut(b) = len as u32;
            for &s in &cells[c..] {
                len = emit_cell(pool, s, out, len);
            }
        }
    }
    len
}

/// One cell of any length.
///
/// # Safety
/// As for `emit`.
#[inline(always)]
unsafe fn emit_cell(pool: *const u8, s: Span, out: *mut u8, len: usize) -> usize {
    // SAFETY: the caller's contract.
    unsafe {
        let src = pool.add(s.offset as usize);
        if s.len as usize <= COPY_BLOCK {
            copy_block(src, out.add(len));
        } else {
            copy_long(src, out.add(len), s.len as usize);
        }
    }
    len + s.len as usize
}

/// Copy 32 bytes.
///
/// # Safety
/// Both ranges must be valid for 32 bytes.
#[inline(always)]
unsafe fn copy32(src: *const u8, dst: *mut u8) {
    // SAFETY: the caller's contract; the accesses are unaligned.
    unsafe {
        std::ptr::write_unaligned(
            dst as *mut [u8; 32],
            std::ptr::read_unaligned(src as *const [u8; 32]),
        )
    }
}

/// Copy COPY_BLOCK bytes: a visual of any usual length.
///
/// # Safety
/// Both ranges must be valid for COPY_BLOCK bytes.
#[inline(always)]
unsafe fn copy_block(src: *const u8, dst: *mut u8) {
    const _: () = assert!(COPY_BLOCK == 64);
    // SAFETY: the caller's contract; the accesses are unaligned.
    unsafe {
        std::ptr::write_unaligned(
            dst as *mut [u8; 64],
            std::ptr::read_unaligned(src as *const [u8; 64]),
        )
    }
}

#[cold]
#[inline(never)]
unsafe fn copy_long(src: *const u8, dst: *mut u8, len: usize) {
    // SAFETY: the caller guarantees both ranges.
    unsafe { std::ptr::copy_nonoverlapping(src, dst, len) }
}

pub use std::io::IoSlice;

/// Write every part to stdout with writev, resuming after short writes.
pub fn write_all_vectored(parts: &mut [IoSlice<'_>]) -> std::io::Result<()> {
    use std::io::Write;
    let mut out = RawStdout;
    let mut parts = &mut parts[..];
    IoSlice::advance_slices(&mut parts, 0);
    while !parts.is_empty() {
        match out.write_vectored(parts) {
            Ok(0) => return Err(std::io::ErrorKind::WriteZero.into()),
            Ok(n) => IoSlice::advance_slices(&mut parts, n),
            Err(e) if e.kind() == std::io::ErrorKind::Interrupted => {}
            Err(e) => return Err(e),
        }
    }
    Ok(())
}

/// File descriptor 1 without std's line buffer: frames are written whole.
pub struct RawStdout;

impl std::io::Write for RawStdout {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        self.write_vectored(&[IoSlice::new(buf)])
    }

    fn write_vectored(&mut self, bufs: &[IoSlice<'_>]) -> std::io::Result<usize> {
        unsafe extern "C" {
            fn writev(fd: i32, iov: *const IoSlice<'_>, iovcnt: i32) -> isize;
        }
        // IOV_MAX is 1024 on Linux and macOS
        let count = bufs.len().min(1024) as i32;
        // SAFETY: IoSlice is ABI-compatible with struct iovec on Unix.
        let n = unsafe { writev(1, bufs.as_ptr(), count) };
        if n < 0 {
            Err(std::io::Error::last_os_error())
        } else {
            Ok(n as usize)
        }
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

#[cfg(test)]
mod chunk_tests {
    use super::chunk_blocks;

    #[test]
    fn chunk_blocks_matches_scalar() {
        let mut x = 0xda94_2042_e4dd_58b5u64;
        for _ in 0..10_000 {
            let mut chunk = [0u8; 64];
            for b in &mut chunk {
                x = x
                    .wrapping_mul(6_364_136_223_846_793_005)
                    .wrapping_add(1_442_695_040_888_963_407);
                // mostly zero, so blocks come out both clean and dirty
                *b = if x >> 60 == 0 { (x >> 32) as u8 | 1 } else { 0 };
            }
            let want = chunk
                .chunks_exact(4)
                .enumerate()
                .fold(0u32, |m, (i, c)| m | ((c != [0; 4]) as u32) << i);
            assert_eq!(chunk_blocks(&mut chunk), want);
            assert_eq!(chunk, [0; 64]);
        }
    }
}
