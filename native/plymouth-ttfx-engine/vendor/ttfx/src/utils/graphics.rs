//! Color, ColorPair, and Gradient, ported from utils/graphics.py.

use std::fmt;
use std::ops::Deref;

use crate::utils::geometry::{self, Coord};
use crate::utils::hexterm;
use crate::utils::pycompat::floor_div;
use crate::utils::rng::Rng;

/// The original constructor argument, preserved because upstream `Color.__eq__`
/// and `__hash__` compare `color_arg` — `Color(255) != Color("ffffff")` even
/// when they resolve to the same RGB. Dict/set keying depends on this.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ColorArg {
    Xterm(u8),
    Hex(RgbString), // stored stripped of '#', case preserved (upstream strips '#' only)
}

impl ColorArg {
    /// The argument as one word, equal exactly when the arguments are: an
    /// xterm code with the top bit set, or the hex string's zero-padded bytes
    /// and its length.
    #[inline]
    pub fn key(&self) -> u64 {
        match self {
            ColorArg::Xterm(code) => 1 << 63 | *code as u64,
            ColorArg::Hex(rgb) => {
                let mut word = [0; 8];
                word[..7].copy_from_slice(&rgb.bytes);
                word[7] = rgb.len;
                u64::from_le_bytes(word)
            }
        }
    }
}

/// One word per argument (see `key`); visual interning hashes colors on every
/// frame an effect builds.
impl std::hash::Hash for ColorArg {
    #[inline]
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        state.write_u64(self.key());
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub struct RgbString {
    bytes: [u8; 7],
    len: u8,
}

impl RgbString {
    fn new(value: &str) -> Self {
        debug_assert!(value.len() <= 7);
        let mut bytes = [0; 7];
        bytes[..value.len()].copy_from_slice(value.as_bytes());
        RgbString {
            bytes,
            len: value.len() as u8,
        }
    }
}

impl Deref for RgbString {
    type Target = str;

    #[inline]
    fn deref(&self) -> &Self::Target {
        // SAFETY: the bytes are a prefix copied whole from a &str (new) or
        // ASCII hex digits (from_rgb), so they are valid UTF-8.
        unsafe { std::str::from_utf8_unchecked(self.bytes.get_unchecked(..self.len as usize)) }
    }
}

impl AsRef<str> for RgbString {
    fn as_ref(&self) -> &str {
        self
    }
}

impl std::borrow::Borrow<str> for RgbString {
    fn borrow(&self) -> &str {
        self
    }
}

impl std::hash::Hash for RgbString {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        std::hash::Hash::hash(&**self, state);
    }
}

impl fmt::Display for RgbString {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self)
    }
}

impl fmt::Debug for RgbString {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(&**self, f)
    }
}

#[derive(Clone, Copy)]
pub struct Color {
    pub color_arg: ColorArg,
    /// Some(code) when constructed from an xterm int, None for hex strings.
    pub xterm_color: Option<u8>,
    /// hex string without '#'
    pub rgb_color: RgbString,
    rgb: [u8; 3],
}

impl fmt::Debug for Color {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Color")
            .field("color_arg", &self.color_arg)
            .field("xterm_color", &self.xterm_color)
            .field("rgb_color", &self.rgb_color)
            .finish()
    }
}

impl PartialEq for Color {
    fn eq(&self, other: &Self) -> bool {
        self.color_arg == other.color_arg
    }
}
impl Eq for Color {}
impl std::hash::Hash for Color {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.color_arg.hash(state);
    }
}

impl Color {
    /// `from_rgb(rgb >> 16, rgb >> 8, rgb).color_arg.key()` without making
    /// the color: the six lowercase hex digits worked out in one word, a
    /// nibble per byte, and the length 6 in the top byte.
    #[inline]
    pub(crate) fn hex_key(rgb: u32) -> u64 {
        let v = rgb as u64 & 0xff_ffff;
        let mut nibbles = 0;
        for i in 0..6 {
            nibbles |= (v >> (20 - 4 * i) & 15) << (8 * i);
        }
        let letters = (nibbles + 0x0606_0606_0606) >> 4 & 0x0101_0101_0101;
        (nibbles + 0x3030_3030_3030 + letters * 0x27) | 6 << 56
    }

    /// Construct a generated color without formatting and reparsing its channels.
    /// The lowercase hex argument is observable in color equality and hashing.
    pub(crate) fn from_rgb(red: u8, green: u8, blue: u8) -> Self {
        // the digits built in one word (stored a byte at a time, they stalled
        // the key's word load that follows)
        let digits =
            Self::hex_key((red as u32) << 16 | (green as u32) << 8 | blue as u32).to_le_bytes();
        let bytes = [
            digits[0], digits[1], digits[2], digits[3], digits[4], digits[5], 0,
        ];
        let rgb_color = RgbString { bytes, len: 6 };
        Color {
            color_arg: ColorArg::Hex(rgb_color),
            xterm_color: None,
            rgb_color,
            rgb: [red, green, blue],
        }
    }

    pub fn from_xterm(code: u8) -> Self {
        let rgb_color = RgbString::new(hexterm::xterm_to_hex(code));
        Color {
            color_arg: ColorArg::Xterm(code),
            xterm_color: Some(code),
            rgb: Self::parse_rgb(&rgb_color),
            rgb_color,
        }
    }

    /// Hex-string constructor. Errors mirror upstream ValueError.
    pub fn from_hex(hex: &str) -> Result<Self, String> {
        let stripped = hex.trim_matches('#');
        if !hexterm::is_valid_hex_color(stripped) {
            return Err(
                "Invalid color value. Color must be an XTerm-256 color code or an RGB hex color string. \
                 Example: 255 or 'ffffff' or '#ffffff'"
                    .to_string(),
            );
        }
        let rgb_color = RgbString::new(stripped);
        Ok(Color {
            color_arg: ColorArg::Hex(rgb_color),
            xterm_color: None,
            rgb: Self::parse_rgb(&rgb_color),
            rgb_color,
        })
    }

    pub fn rgb_ints(&self) -> (u8, u8, u8) {
        (self.rgb[0], self.rgb[1], self.rgb[2])
    }

    /// The color whose `color_arg.key()` is `key`: every field follows from
    /// the argument, as from_xterm and from_hex make it.
    ///
    /// # Safety
    ///
    /// `key` must be the `color_arg.key()` of a Color: either an xterm key
    /// (top bit set), or a hex key whose low seven bytes start with `len`
    /// (the top byte, at most 7) bytes of valid UTF-8. `RgbString`'s deref
    /// trusts both without checking.
    pub(crate) unsafe fn from_key(key: u64) -> Self {
        if key >> 63 != 0 {
            return Color::from_xterm(key as u8);
        }
        let b = key.to_le_bytes();
        debug_assert!(b[7] <= 7, "from_key: hex length {} > 7", b[7]);
        debug_assert!(std::str::from_utf8(&b[..(b[7] as usize).min(7)]).is_ok());
        let rgb_color = RgbString {
            bytes: [b[0], b[1], b[2], b[3], b[4], b[5], b[6]],
            len: b[7],
        };
        Color {
            color_arg: ColorArg::Hex(rgb_color),
            xterm_color: None,
            rgb: Self::parse_rgb(&rgb_color),
            rgb_color,
        }
    }

    fn parse_rgb(s: &str) -> [u8; 3] {
        [
            u8::from_str_radix(&s[0..2], 16).unwrap(),
            u8::from_str_radix(&s[2..4], 16).unwrap(),
            u8::from_str_radix(&s[4..6], 16).unwrap(),
        ]
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub struct ColorPair {
    pub fg_color: Option<Color>,
    pub bg_color: Option<Color>,
}

impl ColorPair {
    pub fn new(fg: Option<Color>, bg: Option<Color>) -> Self {
        ColorPair {
            fg_color: fg,
            bg_color: bg,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GradientDirection {
    Vertical,
    Horizontal,
    Radial,
    Diagonal,
}

/// Insertion-ordered Coord -> Color mapping (upstream returns a dict; iteration
/// order is Python dict insertion order, which some effects walk).
/// Gradient mappings fill a rectangle, so colors can be indexed directly in
/// the builder's row-major or column-major order without hashing coordinates.
#[derive(Debug, Clone, Default)]
pub struct CoordColorMap {
    pub order: Vec<Coord>,
    colors: Vec<Color>,
    min_row: i64,
    min_column: i64,
    width: usize,
    height: usize,
    column_major: bool,
}

impl CoordColorMap {
    fn new(
        min_row: i64,
        max_row: i64,
        min_column: i64,
        max_column: i64,
        column_major: bool,
    ) -> Self {
        let width =
            usize::try_from(max_column - min_column + 1).expect("gradient canvas is too large");
        let height = usize::try_from(max_row - min_row + 1).expect("gradient canvas is too large");
        let len = width
            .checked_mul(height)
            .expect("gradient canvas is too large");
        Self {
            order: Vec::with_capacity(len),
            colors: Vec::with_capacity(len),
            min_row,
            min_column,
            width,
            height,
            column_major,
        }
    }

    /// The gradient builder visits every cell once in its declared order.
    fn push(&mut self, coord: Coord, color: Color) {
        self.order.push(coord);
        self.colors.push(color);
    }

    pub fn get(&self, coord: &Coord) -> Option<&Color> {
        let column = usize::try_from(coord.column.checked_sub(self.min_column)?).ok()?;
        let row = usize::try_from(coord.row.checked_sub(self.min_row)?).ok()?;
        if column >= self.width || row >= self.height {
            return None;
        }
        let index = if self.column_major {
            column * self.height + row
        } else {
            row * self.width + column
        };
        self.colors.get(index)
    }

    pub fn iter(&self) -> impl Iterator<Item = (Coord, &Color)> {
        self.order
            .iter()
            .map(move |c| (*c, self.get(c).expect("coordinate missing from gradient")))
    }
}

/// graphics.Gradient. The spectrum is NOT float lerp: channel deltas use
/// Python integer floor division and the exact end stop is appended per pair
/// (plan.md §5.2).
#[derive(Debug, Clone)]
pub struct Gradient {
    pub spectrum: Vec<Color>,
}

impl Gradient {
    /// Gradient(*stops, steps=...). `steps_was_int` mirrors the upstream quirk
    /// that only scalar (int) steps are validated before generation.
    pub fn new(
        stops: &[Color],
        steps: &[i64],
        steps_was_int: bool,
        do_loop: bool,
    ) -> Result<Self, String> {
        if stops.is_empty() {
            return Err("At least one stop must be provided.".to_string());
        }
        if steps_was_int {
            for &step in steps {
                if step < 1 {
                    return Err("Steps must be greater than 0.".to_string());
                }
            }
        }
        let mut spectrum: Vec<Color> = Vec::new();
        if stops.len() == 1 {
            for _ in 0..steps[0] {
                spectrum.push(stops[0]);
            }
            return Ok(Gradient { spectrum });
        }
        let mut stops: Vec<Color> = stops.to_vec();
        if do_loop {
            stops.push(stops[0]);
        }
        let pair_count = stops.len() - 1;
        let mut steps: Vec<i64> = steps[..steps.len().min(pair_count)].to_vec();
        while steps.len() < pair_count {
            steps.push(*steps.last().unwrap());
        }
        for (pair_index, step_count) in steps.iter().copied().enumerate() {
            if step_count < 1 {
                return Err(format!(
                    "Invalid steps: {step_count} | Steps must be greater than 0."
                ));
            }
            let start = &stops[pair_index];
            let end = &stops[pair_index + 1];
            let (sr, sg, sb) = start.rgb_ints();
            let (er, eg, eb) = end.rgb_ints();
            let (sr, sg, sb) = (sr as i64, sg as i64, sb as i64);
            let red_delta = floor_div(er as i64 - sr, step_count);
            let green_delta = floor_div(eg as i64 - sg, step_count);
            let blue_delta = floor_div(eb as i64 - sb, step_count);
            let range_start = i64::from(!spectrum.is_empty());
            for i in range_start..step_count.max(0) {
                let red = (sr + red_delta * i).clamp(0, 255);
                let green = (sg + green_delta * i).clamp(0, 255);
                let blue = (sb + blue_delta * i).clamp(0, 255);
                spectrum.push(Color::from_rgb(red as u8, green as u8, blue as u8));
            }
            spectrum.push(*end);
        }
        Ok(Gradient { spectrum })
    }

    /// Convenience: single scalar step count (the common upstream call shape).
    pub fn with_steps(stops: &[Color], steps: i64, do_loop: bool) -> Result<Self, String> {
        Gradient::new(stops, &[steps], true, do_loop)
    }

    /// get_color_at_fraction: first i in 1..=len with fraction <= i/len.
    pub fn get_color_at_fraction(&self, fraction: f64) -> Result<&Color, String> {
        if !(0.0..=1.0).contains(&fraction) {
            return Err("Fraction must be 0 <= fraction <= 1.".to_string());
        }
        let len = self.spectrum.len();
        if len == 0 {
            return Ok(self.spectrum.last().unwrap()); // Preserve the original empty-spectrum panic.
        }
        // Multiplication gives a nearby index, but is not the inverse of the
        // rounded division used by Python. Check those original boundaries so
        // a fraction exactly on (or one ulp from) a stop keeps the same color.
        let mut index = ((fraction * len as f64) as usize).min(len - 1);
        while index > 0 && fraction <= index as f64 / len as f64 {
            index -= 1;
        }
        while index + 1 < len && fraction > (index + 1) as f64 / len as f64 {
            index += 1;
        }
        Ok(&self.spectrum[index])
    }

    /// Five solid horizontal bands, top to bottom, with 4:3:4:3:5 row weights.
    /// Round cumulative boundaries to the nearest row (half up), relative to
    /// the supplied text bounds. Sample the authored spectrum at quarter points;
    /// never change the spectrum itself, which animation scenes also consume.
    pub fn build_banded_coordinate_color_mapping(
        &self,
        min_row: i64,
        max_row: i64,
        min_column: i64,
        max_column: i64,
    ) -> Result<CoordColorMap, String> {
        if min_row < 1 || min_column < 1 || min_row > max_row || min_column > max_column {
            return Err("Invalid text bounds for horizontal bands.".to_string());
        }
        let height = i128::from(max_row - min_row) + 1;
        let boundaries = [4, 7, 11, 14].map(|weight| (height * weight + 9) / 19);
        let colors = [0.0, 0.25, 0.5, 0.75, 1.0]
            .map(|fraction| self.get_color_at_fraction(fraction).cloned())
            .into_iter()
            .collect::<Result<Vec<_>, _>>()?;
        let mut mapping = CoordColorMap::new(min_row, max_row, min_column, max_column, false);
        // Keep the usual vertical-map insertion order (bottom to top).
        for row in min_row..=max_row {
            let from_top = i128::from(max_row - row);
            let band = boundaries.iter().filter(|&&end| from_top >= end).count();
            for column in min_column..=max_column {
                mapping.push(Coord::new(column, row), colors[band]);
            }
        }
        Ok(mapping)
    }

    /// build_coordinate_color_mapping with upstream's insertion order per direction.
    pub fn build_coordinate_color_mapping(
        &self,
        min_row: i64,
        max_row: i64,
        min_column: i64,
        max_column: i64,
        direction: GradientDirection,
    ) -> Result<CoordColorMap, String> {
        if max_row < 1 || max_column < 1 || min_row < 1 || min_column < 1 {
            return Err("max_row and max_column must be greater than 0.".to_string());
        }
        if min_row > max_row || min_column > max_column {
            return Err(
                "min_row and min_column must be less than or equal to max_row and max_column."
                    .to_string(),
            );
        }
        let row_offset = min_row - 1;
        let column_offset = min_column - 1;
        let mut mapping = CoordColorMap::new(
            min_row,
            max_row,
            min_column,
            max_column,
            direction == GradientDirection::Horizontal,
        );
        match direction {
            GradientDirection::Vertical => {
                for row in min_row..=max_row {
                    let fraction = (row - row_offset) as f64 / (max_row - row_offset) as f64;
                    let color = *self.get_color_at_fraction(fraction)?;
                    for column in min_column..=max_column {
                        mapping.push(Coord::new(column, row), color);
                    }
                }
            }
            GradientDirection::Horizontal => {
                for column in min_column..=max_column {
                    let fraction =
                        (column - column_offset) as f64 / (max_column - column_offset) as f64;
                    let color = *self.get_color_at_fraction(fraction)?;
                    for row in min_row..=max_row {
                        mapping.push(Coord::new(column, row), color);
                    }
                }
            }
            GradientDirection::Radial => {
                for row in min_row..=max_row {
                    for column in min_column..=max_column {
                        let distance = geometry::find_normalized_distance_from_center(
                            min_row,
                            max_row,
                            min_column,
                            max_column,
                            Coord::new(column, row),
                        )?;
                        let color = *self.get_color_at_fraction(distance)?;
                        mapping.push(Coord::new(column, row), color);
                    }
                }
            }
            GradientDirection::Diagonal => {
                for row in min_row..=max_row {
                    for column in min_column..=max_column {
                        let fraction = (((row - row_offset) * 2) + (column - column_offset)) as f64
                            / (((max_row - row_offset) * 2) + (max_column - column_offset)) as f64;
                        let color = *self.get_color_at_fraction(fraction)?;
                        mapping.push(Coord::new(column, row), color);
                    }
                }
            }
        }
        Ok(mapping)
    }
}

/// graphics.random_color.
pub fn random_color(rng: &mut Rng) -> Color {
    let value = rng.randint(0, 0xFFFFFF);
    Color::from_rgb((value >> 16) as u8, (value >> 8) as u8, value as u8)
}

/// graphics.shift_color_towards: float lerp with int() TRUNCATION back to hex
/// (unlike adjust_color_brightness's round()). Negative components format
/// Python-style ("-3" not two's complement) so error conditions match.
pub fn shift_color_towards(
    color: &Color,
    target_color: &Color,
    factor: f64,
) -> Result<Color, String> {
    let interpolate = |start: f64, end: f64, factor: f64| start + (end - start) * factor;
    let norm = |c: &Color| {
        let (r, g, b) = c.rgb_ints();
        (r as f64 / 255.0, g as f64 / 255.0, b as f64 / 255.0)
    };
    let (cr, cg, cb) = norm(color);
    let (tr, tg, tb) = norm(target_color);
    let channels = [
        (interpolate(cr, tr, factor) * 255.0) as i64,
        (interpolate(cg, tg, factor) * 255.0) as i64,
        (interpolate(cb, tb, factor) * 255.0) as i64,
    ];
    if channels.iter().all(|channel| (0..=255).contains(channel)) {
        return Ok(Color::from_rgb(
            channels[0] as u8,
            channels[1] as u8,
            channels[2] as u8,
        ));
    }
    let py_hex = |v: f64| {
        let i = (v * 255.0) as i64; // int() truncation
        if i < 0 {
            format!("-{:01x}", -i)
        } else {
            format!("{i:02x}")
        }
    };
    let hex = format!(
        "{}{}{}",
        py_hex(interpolate(cr, tr, factor)),
        py_hex(interpolate(cg, tg, factor)),
        py_hex(interpolate(cb, tb, factor))
    );
    Color::from_hex(&hex)
}

#[cfg(test)]
mod tests {
    use std::collections::HashMap;

    use super::Color;

    #[test]
    fn final_text_has_five_solid_top_to_bottom_bands() {
        use super::Gradient;
        use crate::utils::geometry::Coord;
        let stops = ["112244", "44aacc", "ffeedd"].map(|hex| Color::from_hex(hex).unwrap());
        let gradient = Gradient::with_steps(&stops, 12, false).unwrap();
        let mapping = gradient
            .build_banded_coordinate_color_mapping(8, 26, 3, 10)
            .unwrap();
        let expected = [4, 3, 4, 3, 5];
        let mut row = 26;
        for (band, count) in expected.into_iter().enumerate() {
            let color = gradient.get_color_at_fraction(band as f64 / 4.0).unwrap();
            for _ in 0..count {
                for column in 3..=10 {
                    assert_eq!(
                        mapping.get(&Coord::new(column, row)),
                        Some(color),
                        "band {band}, row {row}"
                    );
                }
                row -= 1;
            }
        }
        assert_eq!(row, 7);
    }

    #[test]
    fn generated_rgb_preserves_hex_identity_and_channels() {
        for red in 0..=255_u8 {
            for green in 0..=255_u8 {
                let blue = red.wrapping_add(green);
                let expected = Color::from_hex(&format!("{red:02x}{green:02x}{blue:02x}")).unwrap();
                let actual = Color::from_rgb(red, green, blue);
                assert_eq!(actual, expected);
                assert_eq!(actual.rgb_color, expected.rgb_color);
                assert_eq!(actual.rgb_ints(), expected.rgb_ints());
                assert_eq!(actual.xterm_color, None);
                assert_eq!(HashMap::from([(actual, 1)]).get(&expected), Some(&1));
            }
        }
        assert_ne!(Color::from_rgb(255, 255, 255), Color::from_xterm(15));
        assert_ne!(
            Color::from_rgb(255, 255, 255),
            Color::from_hex("FFFFFF").unwrap()
        );
    }

    #[test]
    fn extrapolated_colors_keep_hex_validation_behavior() {
        use super::shift_color_towards;
        let black = Color::from_hex("000000").unwrap();
        let red = Color::from_hex("ff0000").unwrap();
        // Upstream accepts seven hex digits and parses the first six. Preserve
        // that quirk when extrapolation carries a channel beyond one byte.
        assert_eq!(
            shift_color_towards(&black, &red, 2.0).unwrap(),
            Color::from_hex("1fe0000").unwrap()
        );
        // Preserve the Rust constructor's existing panic when a leading minus
        // passes string validation but fails unsigned channel parsing.
        assert!(std::panic::catch_unwind(|| shift_color_towards(&red, &black, 2.0)).is_err());
        assert!(shift_color_towards(&black, &red, f64::INFINITY).is_err());
    }

    #[test]
    fn fraction_lookup_preserves_division_boundaries() {
        use super::Gradient;
        for len in [1, 2, 3, 5, 7, 12, 25, 64, 127, 256, 257, 1024] {
            let gradient = Gradient {
                spectrum: (0..len).map(|i| Color::from_xterm(i as u8)).collect(),
            };
            let check = |fraction| {
                if !(0.0..=1.0).contains(&fraction) {
                    assert!(gradient.get_color_at_fraction(fraction).is_err());
                    return;
                }
                let expected = (1..=len)
                    .find(|&i| fraction <= i as f64 / len as f64)
                    .unwrap()
                    - 1;
                assert!(
                    std::ptr::eq(
                        gradient.get_color_at_fraction(fraction).unwrap(),
                        &gradient.spectrum[expected]
                    ),
                    "len={len}, fraction={fraction:?}, expected={expected}"
                );
            };
            for index in 0..=len {
                let boundary = index as f64 / len as f64;
                check(boundary.next_down());
                check(boundary);
                check(boundary.next_up());
            }
            for index in 0..1000 {
                check(index as f64 / 999.0);
            }
            check(f64::NAN);
            check(f64::INFINITY);
            check(f64::NEG_INFINITY);
        }
    }

    #[test]
    fn coordinate_mapping_keeps_bounds_and_public_iteration_order() {
        use super::{CoordColorMap, Gradient, GradientDirection};
        use crate::utils::geometry::Coord;
        let gradient =
            Gradient::with_steps(&[Color::from_xterm(1), Color::from_xterm(15)], 7, false).unwrap();
        for direction in [
            GradientDirection::Vertical,
            GradientDirection::Horizontal,
            GradientDirection::Diagonal,
            GradientDirection::Radial,
        ] {
            let mut mapping = gradient
                .build_coordinate_color_mapping(3, 7, 4, 9, direction)
                .unwrap();
            let original: Vec<_> = mapping
                .iter()
                .map(|(coord, color)| (coord, *color))
                .collect();
            assert_eq!(original.len(), 30);
            for &(coord, color) in &original {
                assert_eq!(mapping.get(&coord), Some(&color));
            }
            for coord in [
                Coord::new(3, 3),
                Coord::new(10, 3),
                Coord::new(4, 2),
                Coord::new(4, 8),
                Coord::new(i64::MIN, 3),
                Coord::new(4, i64::MAX),
            ] {
                assert_eq!(mapping.get(&coord), None);
            }
            // `order` is public: iteration must still respect caller edits.
            mapping.order.reverse();
            mapping.order.push(original[0].0);
            let mut expected = original;
            expected.reverse();
            expected.push(*expected.last().unwrap());
            assert_eq!(
                mapping
                    .iter()
                    .map(|(coord, color)| (coord, *color))
                    .collect::<Vec<_>>(),
                expected
            );
        }
        assert_eq!(CoordColorMap::default().get(&Coord::new(0, 0)), None);
    }

    #[test]
    fn rgb_string_borrowed_lookup_matches_str_hash() {
        let rgb = Color::from_hex("12AbEf7").unwrap().rgb_color;
        let mut colors = HashMap::new();
        colors.insert(rgb, 1);
        assert_eq!(colors.get("12AbEf7"), Some(&1));
    }

    #[test]
    fn color_debug_hides_the_cached_representation() {
        let color = Color::from_hex("12AbEf7").unwrap();
        assert_eq!(
            format!("{color:?}"),
            "Color { color_arg: Hex(\"12AbEf7\"), xterm_color: None, rgb_color: \"12AbEf7\" }"
        );
    }

    #[test]
    fn from_rgb_is_lowercase_hex() {
        for v in (0..1u32 << 24)
            .step_by(4099)
            .chain([0, 0xffffff, 0x0a0b0c, 0x9fa0af])
        {
            let (r, g, b) = ((v >> 16) as u8, (v >> 8) as u8, v as u8);
            let c = Color::from_rgb(r, g, b);
            assert_eq!(&*c.rgb_color, format!("{r:02x}{g:02x}{b:02x}"));
            assert_eq!(c.rgb_ints(), (r, g, b));
            assert_eq!(c.color_arg.key(), Color::hex_key(v));
        }
    }
}
