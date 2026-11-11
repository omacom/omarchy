//! xterm-256 <-> RGB conversion, ported from utils/hexterm.py.

use std::cell::RefCell;
use std::collections::HashMap;
use std::sync::OnceLock;

include!("hexterm_table.rs");

type Rgb = [u8; 3];

static XTERM_RGB: OnceLock<[Rgb; 256]> = OnceLock::new();

thread_local! {
    /// Scene and Animation both memoize this conversion upstream. Keeping the
    /// memo here also covers callers outside the animation engine and lets all
    /// scenes on the render thread share the same results.
    static HEX_TO_XTERM_CACHE: RefCell<HashMap<u32, u8>> = RefCell::new(HashMap::new());
}

fn parse_rgb(hex_color: &str) -> Rgb {
    let s = hex_color.trim_matches('#');
    [
        u8::from_str_radix(&s[0..2], 16).unwrap(),
        u8::from_str_radix(&s[2..4], 16).unwrap(),
        u8::from_str_radix(&s[4..6], 16).unwrap(),
    ]
}

/// Parse the generated palette once rather than reparsing all 768 channels on
/// every conversion.
fn xterm_rgb() -> &'static [Rgb; 256] {
    XTERM_RGB.get_or_init(|| std::array::from_fn(|code| parse_rgb(XTERM_TO_HEX[code])))
}

fn closest_xterm([r, g, b]: Rgb) -> u8 {
    let mut min_diff = u16::MAX;
    let mut closest = 0u8;
    for (code, &[xr, xg, xb]) in xterm_rgb().iter().enumerate() {
        // Upstream divides this sum by three before comparing it. Division by
        // the same positive constant is order-preserving, so comparing the
        // integer sums retains its strict-first-minimum tie behavior exactly.
        let diff = r.abs_diff(xr) as u16 + g.abs_diff(xg) as u16 + b.abs_diff(xb) as u16;
        if diff < min_diff {
            min_diff = diff;
            closest = code as u8;
        }
    }
    closest
}

/// Closest xterm-256 code by mean absolute channel difference; linear scan over
/// codes 0..=255 in order, strict `<` so the first minimum wins (upstream
/// hexterm.py hex_to_xterm).
pub fn hex_to_xterm(hex_color: &str) -> u8 {
    let rgb = parse_rgb(hex_color);
    let key = u32::from_be_bytes([0, rgb[0], rgb[1], rgb[2]]);
    HEX_TO_XTERM_CACHE.with(|cache| {
        if let Some(cached) = cache.borrow().get(&key).copied() {
            return cached;
        }
        let closest = closest_xterm(rgb);
        cache.borrow_mut().insert(key, closest);
        closest
    })
}

/// xterm code -> hex string without leading '#'.
pub fn xterm_to_hex(xterm_color: u8) -> &'static str {
    XTERM_TO_HEX[xterm_color as usize]
}

/// Upstream is_valid_color for strings: 6 (or, faithfully, 7) hex digits with
/// optional leading '#'s. Integer codes are validated by range at the type level (u8).
pub fn is_valid_hex_color(color: &str) -> bool {
    let stripped_len = color.trim_start_matches('#').len();
    if stripped_len != 6 && stripped_len != 7 {
        return false;
    }
    i64::from_str_radix(color.trim_matches('#'), 16).is_ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn reference_hex_to_xterm(hex_color: &str) -> u8 {
        let [r, g, b] = parse_rgb(hex_color).map(i64::from);
        let mut min_diff = f64::INFINITY;
        let mut closest = 0u8;
        for (code, hex) in XTERM_TO_HEX.iter().enumerate() {
            let [xr, xg, xb] = parse_rgb(hex).map(i64::from);
            let diff = ((r - xr).abs() + (g - xg).abs() + (b - xb).abs()) as f64 / 3.0;
            if diff < min_diff {
                min_diff = diff;
                closest = code as u8;
            }
        }
        closest
    }

    #[test]
    fn table_spot_checks() {
        // Golden values from the pinned reference
        assert_eq!(xterm_to_hex(0), "000000");
        assert_eq!(xterm_to_hex(15), "ffffff");
        assert_eq!(xterm_to_hex(196), "ff0000");
    }

    #[test]
    fn cached_conversion_matches_reference_across_rgb_space() {
        // Include exact palette boundaries, neighboring values, and mixed-case
        // spelling. This exercises ties as well as ordinary nearest colors.
        let channels = [
            0u8, 1, 14, 15, 16, 31, 47, 63, 79, 95, 127, 128, 159, 191, 223, 254, 255,
        ];
        for &r in &channels {
            for &g in &channels {
                for &b in &channels {
                    let hex = format!("#{r:02X}{g:02x}{b:02X}");
                    assert_eq!(hex_to_xterm(&hex), reference_hex_to_xterm(&hex), "{hex}");
                }
            }
        }
    }

    #[test]
    fn repeated_and_equivalent_spellings_share_the_exact_result() {
        let expected = reference_hex_to_xterm("ff00aa");
        assert_eq!(hex_to_xterm("ff00aa"), expected);
        assert_eq!(hex_to_xterm("#FF00AA"), expected);
        // Seven digits are accepted elsewhere and the existing converter uses
        // its first six, a compatibility quirk worth keeping explicit.
        assert_eq!(hex_to_xterm("ff00aa7"), expected);
    }

    #[test]
    fn valid_hex() {
        assert!(is_valid_hex_color("#ff00aa"));
        assert!(is_valid_hex_color("ff00aa"));
        assert!(!is_valid_hex_color("ff00a"));
        assert!(!is_valid_hex_color("gg00aa"));
        // Upstream quirk: 7 hex digits pass validation
        assert!(is_valid_hex_color("1234567"));
    }
}
