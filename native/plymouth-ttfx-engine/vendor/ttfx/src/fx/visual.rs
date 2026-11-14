//! The visual pool: every CharacterVisual is formatted once (SGR prefix,
//! symbol, reset) and interned. A visual is then a `Visual` handle, and the
//! renderer only copies bytes: it never formats, allocates or refcounts.
//!
//! The key is what the visual *is* (symbol, colors, attributes); the bytes are
//! a function of it and of the run's color flags, which are fixed.

use std::hash::{Hash, Hasher};

use crate::engine::animation::CharacterVisual;
use crate::utils::graphics::{Color, ColorPair};
use crate::utils::{ansi, hexterm};

use super::{At, Sym, Symbols};
use crate::utils::hash::FxHasher;

/// A pooled visual.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(transparent)]
pub struct Visual(pub u32);

// Attribute bits, in format_symbol_into's order. `dim` is stored but never
// emitted, faithfully.
pub const BOLD: u16 = 1;
pub const ITALIC: u16 = 2;
pub const UNDERLINE: u16 = 4;
pub const BLINK: u16 = 8;
pub const REVERSE: u16 = 16;
pub const HIDDEN: u16 = 32;
pub const STRIKE: u16 = 64;
pub const DIM: u16 = 128;
/// `colors` is `Some(pair)` (possibly both None) rather than `None`.
pub const HAS_COLORS: u16 = 256;

/// What a visual is: CharacterVisual's logical fields.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct VisualInfo {
    pub sym: Sym,
    pub fg: Option<Color>,
    pub bg: Option<Color>,
    pub attrs: u16,
}

/// One word per color, 0 when absent: equal exactly when the colors are.
#[inline]
pub fn color_key(color: Option<Color>) -> u64 {
    color.map_or(0, |c| c.color_arg.key())
}

/// A VisualInfo packed into three words, equal exactly when the infos are:
/// symbol, attributes and which colors are present, then each color's key
/// (0 when absent). A probe compares these rather than the infos.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Key([u64; 3]);

impl Key {
    #[inline]
    fn of(info: &VisualInfo) -> Key {
        let present = (info.fg.is_some() as u64) << 48 | (info.bg.is_some() as u64) << 49;
        Key([
            info.sym.0 as u64 | (info.attrs as u64) << 32 | present,
            info.fg.map_or(0, |c| c.color_arg.key()),
            info.bg.map_or(0, |c| c.color_arg.key()),
        ])
    }

    /// The VisualInfo it was made of.
    fn info(&self) -> VisualInfo {
        let [head, fg, bg] = self.0;
        VisualInfo {
            sym: Sym(head as u32),
            // SAFETY: fg and bg are color_arg.key()s of Colors (Key::of) or
            // Color::hex_key words (make_rgb), both valid from_key keys
            fg: (head >> 48 & 1 != 0).then(|| unsafe { Color::from_key(fg) }),
            bg: (head >> 49 & 1 != 0).then(|| unsafe { Color::from_key(bg) }),
            attrs: (head >> 32) as u16,
        }
    }

    /// The table's hash: the index comes from its low bits.
    #[inline]
    fn hash(&self) -> u32 {
        let mut h = FxHasher::default();
        h.write_u64(self.0[0]);
        h.write_u64(self.0[1]);
        h.write_u64(self.0[2]);
        (h.finish() >> 32) as u32
    }
}

/// The interning table: open addressing over one word per entry, the key's
/// hash in the high half and the handle plus one in the low half (0: empty),
/// so a probe reads the key only on a hash match and growing never reads
/// keys.
/// Kept at most half full, quadrupling from TABLE_INITIAL:
/// its entries are written where the hashes fall, so a table sized for the
/// run's end up front would be touched all over from the start, and each
/// growth rehashes every entry, so it grows in few steps.
struct Table {
    entries: Vec<u64>,
    count: usize,
}

const TABLE_INITIAL: usize = 1 << 15;

impl Table {
    fn new() -> Self {
        Table {
            entries: vec![0; TABLE_INITIAL],
            count: 0,
        }
    }

    /// The handle of `key`, or Err(the empty entry where it goes).
    #[inline]
    fn find(&self, key: &Key, hash: u32, keys: &[Key]) -> Result<Visual, usize> {
        let mask = self.entries.len() - 1;
        let mut i = hash as usize & mask;
        loop {
            let e = *self.entries.at(i);
            if e == 0 {
                return Err(i);
            }
            if (e >> 32) as u32 == hash && keys.at(e as u32 - 1) == key {
                return Ok(Visual(e as u32 - 1));
            }
            i = (i + 1) & mask;
        }
    }

    /// Put `visual` in the empty entry `at` found for `hash`.
    #[inline]
    fn insert(&mut self, at: usize, hash: u32, visual: Visual) {
        *self.entries.at_mut(at) = (hash as u64) << 32 | (visual.0 + 1) as u64;
        self.count += 1;
        if self.count * 2 > self.entries.len() {
            self.grow();
        }
    }

    #[cold]
    fn grow(&mut self) {
        let len = self.entries.len() * 4;
        let old = std::mem::replace(&mut self.entries, vec![0; len]);
        let mask = self.entries.len() - 1;
        for e in old.into_iter().filter(|&e| e != 0) {
            let mut i = (e >> 32) as usize & mask;
            while *self.entries.at(i) != 0 {
                i = (i + 1) & mask;
            }
            *self.entries.at_mut(i) = e;
        }
    }
}

impl VisualInfo {
    /// CharacterVisual.colors.
    pub fn colors(&self) -> Option<ColorPair> {
        (self.attrs & HAS_COLORS != 0).then(|| ColorPair::new(self.fg, self.bg))
    }
}

/// Byte span of a visual in the pool.
#[derive(Debug, Clone, Copy)]
pub struct Span {
    pub offset: u32,
    pub len: u32,
}

/// Every visual is readable this far past its start, so emission may copy a
/// fixed block and then advance by the real length.
pub const COPY_BLOCK: usize = 64;

pub struct VisualPool {
    no_color: bool,
    xterm_colors: bool,
    table: Table,
    /// Every visual's key (`raw` ones too), by handle: its info follows from
    /// it, so only the key is kept (a new visual writes 24 bytes, not ~70).
    keys: Vec<Key>,
    pub spans: Vec<Span>,
    /// Formatted bytes of every visual, plus COPY_BLOCK bytes of slack.
    pub bytes: Vec<u8>,
    /// The longest visual's byte length.
    pub max_len: usize,
}

impl VisualPool {
    pub fn new(no_color: bool, xterm_colors: bool) -> Self {
        VisualPool {
            no_color,
            xterm_colors,
            table: Table::new(),
            keys: Vec::with_capacity(1 << 14),
            spans: Vec::with_capacity(1 << 14),
            bytes: vec![0; COPY_BLOCK],
            max_len: 1,
        }
    }

    /// The visual for these fields, formatting it on first use.
    pub fn make(&mut self, symbols: &Symbols, info: VisualInfo) -> Visual {
        let key = Key::of(&info);
        let hash = key.hash();
        match self.table.find(&key, hash, &self.keys) {
            Ok(visual) => visual,
            Err(at) => self.add(symbols, &info, key, hash, at),
        }
    }

    /// `make` of `sym` in generated colors with no attributes but
    /// HAS_COLORS, each color given as `1 << 24 | rgb` (Color::from_rgb's
    /// channels) or 0 when absent. The key is built in registers: a
    /// VisualInfo written to memory and read back as words stalled the loads.
    #[inline]
    pub fn make_rgb(&mut self, symbols: &Symbols, sym: Sym, fg: u32, bg: u32) -> Visual {
        let word = |c: u32| if c != 0 { Color::hex_key(c) } else { 0 };
        let present = ((fg != 0) as u64) << 48 | ((bg != 0) as u64) << 49;
        let key = Key([
            sym.0 as u64 | (HAS_COLORS as u64) << 32 | present,
            word(fg),
            word(bg),
        ]);
        debug_assert_eq!(key, Key::of(&rgb_info(sym, fg, bg)));
        let hash = key.hash();
        match self.table.find(&key, hash, &self.keys) {
            Ok(visual) => visual,
            Err(at) => self.add(symbols, &rgb_info(sym, fg, bg), key, hash, at),
        }
    }

    /// A new visual: `info`'s bytes formatted at the pool's end, its `key`
    /// put in the table's empty entry `at`.
    #[inline(never)]
    fn add(
        &mut self,
        symbols: &Symbols,
        info: &VisualInfo,
        key: Key,
        hash: u32,
        at: usize,
    ) -> Visual {
        let (no_color, xterm_colors) = (self.no_color, self.xterm_colors);
        let offset = self.bytes.len() - COPY_BLOCK;
        // formatted in place, over the slack and room made past it (a
        // constant-size extend unless the symbol is long): formatting on
        // the stack and copying that stalled, as the copy's wide loads
        // waited on the narrow stores that built it
        let symbol = symbols.get(info.sym).as_bytes();
        let most = SGR_MAX + symbol.len() + RESET.len();
        if most <= ROOM {
            self.bytes.extend_from_slice(&[0; ROOM]);
        } else {
            self.bytes.resize(self.bytes.len() + most, 0);
        }
        let len = format_visual(
            &mut self.bytes[offset..],
            symbol,
            info,
            no_color,
            xterm_colors,
        );
        self.bytes.truncate(offset + len + COPY_BLOCK);
        self.max_len = self.max_len.max(len);
        let handle = Visual(self.keys.len() as u32);
        self.keys.push(key);
        self.spans.push(Span {
            offset: offset as u32,
            len: len as u32,
        });
        self.table.insert(at, hash, handle);
        handle
    }

    /// Room for `additional` more visuals (of about `bytes` bytes each)
    /// without growing the arrays (the table grows as it fills).
    pub fn reserve(&mut self, additional: usize, bytes: usize) {
        self.keys.reserve(additional);
        self.spans.reserve(additional);
        self.bytes.reserve(additional * bytes);
    }

    /// A visual that is just these bytes, outside the map (the renderer's
    /// blank cell).
    pub fn raw(&mut self, sym: Sym, bytes: &[u8]) -> Visual {
        let offset = self.begin();
        self.bytes.extend_from_slice(bytes);
        self.finish(
            VisualInfo {
                sym,
                fg: None,
                bg: None,
                attrs: 0,
            },
            offset,
        )
    }

    /// Start a visual's bytes where the slack begins.
    fn begin(&mut self) -> usize {
        let offset = self.bytes.len() - COPY_BLOCK;
        self.bytes.truncate(offset);
        offset
    }

    /// The bytes from `offset` on are the visual's: restore the slack.
    fn finish(&mut self, info: VisualInfo, offset: usize) -> Visual {
        let len = self.bytes.len() - offset;
        self.bytes.resize(self.bytes.len() + COPY_BLOCK, 0);
        self.max_len = self.max_len.max(len);
        let handle = Visual(self.keys.len() as u32);
        self.keys.push(Key::of(&info));
        self.spans.push(Span {
            offset: offset as u32,
            len: len as u32,
        });
        handle
    }

    pub fn info(&self, visual: Visual) -> VisualInfo {
        self.keys[visual.0 as usize].info()
    }

    #[inline]
    pub fn bytes_of(&self, visual: Visual) -> &[u8] {
        let span = self.spans[visual.0 as usize];
        &self.bytes[span.offset as usize..(span.offset + span.len) as usize]
    }
}

/// make_rgb's fields as a VisualInfo.
fn rgb_info(sym: Sym, fg: u32, bg: u32) -> VisualInfo {
    let color =
        |c: u32| (c != 0).then(|| Color::from_rgb((c >> 16) as u8, (c >> 8) as u8, c as u8));
    VisualInfo {
        sym,
        fg: color(fg),
        bg: color(bg),
        attrs: HAS_COLORS,
    }
}

/// Converts the old engine's CharacterVisual (input parsing can set
/// appearances) into a pool key.
pub fn info_of(symbols: &mut Symbols, visual: &CharacterVisual) -> VisualInfo {
    let mut attrs = 0;
    for (on, bit) in [
        (visual.bold, BOLD),
        (visual.italic, ITALIC),
        (visual.underline, UNDERLINE),
        (visual.blink, BLINK),
        (visual.reverse, REVERSE),
        (visual.hidden, HIDDEN),
        (visual.strike, STRIKE),
        (visual.dim, DIM),
    ] {
        if on {
            attrs |= bit;
        }
    }
    let (fg, bg) = match visual.colors {
        Some(pair) => {
            attrs |= HAS_COLORS;
            (pair.fg_color, pair.bg_color)
        }
        None => (None, None),
    };
    VisualInfo {
        sym: symbols.intern(&visual.symbol),
        fg,
        bg,
        attrs,
    }
}

/// CharacterVisual.format_symbol_into for these fields: the SGR attributes
/// in upstream's fixed order (`dim` intentionally omitted), the colors, the
/// symbol, and a reset when anything came before it: written from the start
/// of `out`, which has room for SGR_MAX + the symbol + the reset; returns
/// the length.
fn format_visual(
    out: &mut [u8],
    symbol: &[u8],
    info: &VisualInfo,
    no_color: bool,
    xterm: bool,
) -> usize {
    debug_assert_eq!(RESET, ansi::RESET_ALL.as_bytes());
    let mut sgr = Sgr { buf: out, len: 0 };
    for (bit, code) in [
        (BOLD, ansi::BOLD),
        (ITALIC, ansi::ITALIC),
        (UNDERLINE, ansi::UNDERLINE),
        (BLINK, ansi::BLINK),
        (REVERSE, ansi::REVERSE),
        (HIDDEN, ansi::HIDDEN),
        (STRIKE, ansi::STRIKETHROUGH),
    ] {
        if info.attrs & bit != 0 {
            sgr.put_str(code);
        }
    }
    if !no_color {
        if let Some(fg) = &info.fg {
            sgr.color(fg, b"38", xterm);
        }
        if let Some(bg) = &info.bg {
            sgr.color(bg, b"48", xterm);
        }
    }
    let colored = sgr.len != 0;
    // a byte at a time: symbols are short, and a copy of a run-time length
    // is a memcpy call
    for &b in symbol {
        sgr.buf[sgr.len] = b;
        sgr.len += 1;
    }
    if colored {
        sgr.put(RESET);
    }
    sgr.len
}

/// The attributes and colors: at most 7 * 5 + 2 * 19 bytes.
const SGR_MAX: usize = 80;
/// ansi::RESET_ALL.
const RESET: &[u8; 4] = b"\x1b[0m";
/// Room made past the slack for a visual formatted in place.
const ROOM: usize = 128;

/// A visual's bytes, written in place.
struct Sgr<'a> {
    buf: &'a mut [u8],
    len: usize,
}

impl Sgr<'_> {
    /// Fixed-size copies (a copy of a length only known at run time would
    /// be a memcpy call).
    #[inline(always)]
    fn put<const N: usize>(&mut self, bytes: &[u8; N]) {
        self.buf[self.len..self.len + N].copy_from_slice(bytes);
        self.len += N;
    }

    fn put_str(&mut self, s: &str) {
        for &b in s.as_bytes() {
            self.buf[self.len] = b;
            self.len += 1;
        }
    }

    /// resolve_color_code + colorterm._color: `ESC[38;2;r;g;bm` from the
    /// hex string, or `ESC[38;5;nm` under --xterm-colors.
    #[inline(always)]
    fn color(&mut self, color: &Color, location: &[u8; 2], xterm: bool) {
        self.put(b"\x1b[");
        self.put(location);
        if xterm {
            let code = color
                .xterm_color
                .unwrap_or_else(|| hexterm::hex_to_xterm(&color.rgb_color));
            self.put(b";5;");
            self.decimal(code);
        } else {
            // the channels of the hex string (Color parses them once)
            let (r, g, b) = color.rgb_ints();
            self.put(b";2;");
            self.decimal(r);
            self.put(b";");
            self.decimal(g);
            self.put(b";");
            self.decimal(b);
        }
        self.put(b"m");
    }

    /// The value's decimal digits: three bytes from a table, of which the
    /// first `n` count (the rest is written over next).
    #[inline(always)]
    fn decimal(&mut self, value: u8) {
        let (digits, n) = DECIMAL[value as usize];
        self.put(&digits);
        self.len -= 3 - n as usize;
    }
}

/// Every u8's decimal digits, left-aligned in three bytes, and their count.
static DECIMAL: [([u8; 3], u8); 256] = {
    let mut t = [([0u8; 3], 0u8); 256];
    let mut v = 0;
    while v < 256 {
        let (h, d, u) = (
            b'0' + (v / 100) as u8,
            b'0' + (v / 10 % 10) as u8,
            b'0' + (v % 10) as u8,
        );
        t[v] = if v >= 100 {
            ([h, d, u], 3)
        } else if v >= 10 {
            ([d, u, 0], 2)
        } else {
            ([u, 0, 0], 1)
        };
        v += 1;
    }
    t
};

#[cfg(test)]
mod tests {
    use super::*;

    /// Every field of a VisualInfo comes back from its key (Color's own
    /// equality compares the argument only, so compare the Debug forms).
    #[test]
    fn key_round_trips() {
        let colors = [
            None,
            Some(Color::from_rgb(0, 0, 0)),
            Some(Color::from_rgb(0xab, 0x12, 0xff)),
            Some(Color::from_xterm(0)),
            Some(Color::from_xterm(255)),
            Some(Color::from_hex("#FfA0b1").unwrap()),
            Some(Color::from_hex("00ff00").unwrap()),
        ];
        for fg in colors {
            for bg in colors {
                for attrs in [0, BOLD | HAS_COLORS, HAS_COLORS | STRIKE | DIM, 0x1ff] {
                    let info = VisualInfo {
                        sym: Sym(123_456),
                        fg,
                        bg,
                        attrs,
                    };
                    assert_eq!(format!("{:?}", Key::of(&info).info()), format!("{info:?}"));
                }
            }
        }
    }
}
