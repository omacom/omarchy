//! Shared clap value parsers for effect configs (argutils validators).

use crate::utils::easing::Easing;
use crate::utils::graphics::GradientDirection;

pub fn parse_positive_float(s: &str) -> Result<f64, String> {
    let v: f64 = s.parse().map_err(|_| format!("invalid float value: '{s}'"))?;
    if v > 0.0 {
        Ok(v)
    } else {
        Err(format!("{v} is not a valid value. Argument must be a float > 0."))
    }
}

pub fn parse_non_negative_float(s: &str) -> Result<f64, String> {
    let v: f64 = s.parse().map_err(|_| format!("invalid float value: '{s}'"))?;
    if v >= 0.0 {
        Ok(v)
    } else {
        Err(format!("{v} is not a valid value. Argument must be a float >= 0."))
    }
}

/// argutils.PositiveInt for gradient steps (nargs +).
pub fn parse_gradient_steps(s: &str) -> Result<i64, String> {
    let v: i64 = s.parse().map_err(|_| format!("invalid int value: '{s}'"))?;
    if v > 0 {
        Ok(v)
    } else {
        Err(format!("{v} is not a valid value. Argument must be an int > 0."))
    }
}

pub fn parse_positive_int(s: &str) -> Result<i64, String> {
    parse_gradient_steps(s)
}

pub fn parse_non_negative_int(s: &str) -> Result<i64, String> {
    let v: i64 = s.parse().map_err(|_| format!("invalid int value: '{s}'"))?;
    if v >= 0 {
        Ok(v)
    } else {
        Err(format!("{v} is not a valid value. Argument must be an int >= 0."))
    }
}

/// argutils.NonNegativeRatio: 0 <= n <= 1.
pub fn parse_non_negative_ratio(s: &str) -> Result<f64, String> {
    let v: f64 = s.parse().map_err(|_| format!("invalid float value: '{s}'"))?;
    if (0.0..=1.0).contains(&v) {
        Ok(v)
    } else {
        Err(format!("{v} is not a valid value. Argument must be a float 0 <= n <= 1."))
    }
}

/// argutils.PositiveRatio: 0 < n <= 1.
pub fn parse_positive_ratio(s: &str) -> Result<f64, String> {
    let v: f64 = s.parse().map_err(|_| format!("invalid float value: '{s}'"))?;
    if v > 0.0 && v <= 1.0 {
        Ok(v)
    } else {
        Err(format!("{v} is not a valid value. Argument must be a float 0 < n <= 1."))
    }
}

pub fn parse_gradient_direction(s: &str) -> Result<GradientDirection, String> {
    match s {
        "horizontal" => Ok(GradientDirection::Horizontal),
        "vertical" => Ok(GradientDirection::Vertical),
        "diagonal" => Ok(GradientDirection::Diagonal),
        "radial" => Ok(GradientDirection::Radial),
        _ => Err(format!("invalid gradient direction: '{s}'")),
    }
}

pub fn parse_easing(s: &str) -> Result<Easing, String> {
    Easing::parse(s).ok_or_else(|| format!("invalid easing function: '{s}'"))
}

/// argutils.CharacterGroupArg: lowercased enum member names.
pub fn parse_character_group(s: &str) -> Result<crate::engine::terminal::CharacterGroup, String> {
    use crate::engine::terminal::CharacterGroup::*;
    Ok(match s {
        "column_left_to_right" => ColumnLeftToRight,
        "column_right_to_left" => ColumnRightToLeft,
        "row_top_to_bottom" => RowTopToBottom,
        "row_bottom_to_top" => RowBottomToTop,
        "diagonal_top_left_to_bottom_right" => DiagonalTopLeftToBottomRight,
        "diagonal_bottom_left_to_top_right" => DiagonalBottomLeftToTopRight,
        "diagonal_top_right_to_bottom_left" => DiagonalTopRightToBottomLeft,
        "diagonal_bottom_right_to_top_left" => DiagonalBottomRightToTopLeft,
        "center_to_outside" => CenterToOutside,
        "outside_to_center" => OutsideToCenter,
        _ => return Err(format!("invalid character group: '{s}'")),
    })
}

/// argutils.CharacterSortArg: lowercased enum member names.
pub fn parse_character_sort(s: &str) -> Result<crate::engine::terminal::CharacterSort, String> {
    use crate::engine::terminal::CharacterSort::*;
    Ok(match s {
        "random" => Random,
        "top_to_bottom_left_to_right" => TopToBottomLeftToRight,
        "top_to_bottom_right_to_left" => TopToBottomRightToLeft,
        "bottom_to_top_left_to_right" => BottomToTopLeftToRight,
        "bottom_to_top_right_to_left" => BottomToTopRightToLeft,
        "outside_row_to_middle" => OutsideRowToMiddle,
        "middle_row_to_outside" => MiddleRowToOutside,
        _ => return Err(format!("invalid character sort: '{s}'")),
    })
}

/// argutils.Symbol: single printable character.
pub fn parse_symbol(s: &str) -> Result<String, String> {
    if s.chars().count() == 1 {
        Ok(s.to_string())
    } else {
        Err(format!("invalid symbol: '{s}' argument must be a single character"))
    }
}

/// argutils.PositiveIntRange: "1-10".
pub fn parse_positive_int_range(s: &str) -> Result<(i64, i64), String> {
    let (a, b) = s.split_once('-').ok_or_else(|| format!("invalid range: '{s}'"))?;
    let a: i64 = a.parse().map_err(|_| format!("invalid range: '{s}'"))?;
    let b: i64 = b.parse().map_err(|_| format!("invalid range: '{s}'"))?;
    if a > 0 && a <= b {
        Ok((a, b))
    } else {
        Err(format!("invalid range: '{s}'"))
    }
}

/// argutils.PositiveFloatRange: "0.25-0.5".
pub fn parse_positive_float_range(s: &str) -> Result<(f64, f64), String> {
    let (a, b) = s.split_once('-').ok_or_else(|| format!("invalid range: '{s}'"))?;
    let a: f64 = a.parse().map_err(|_| format!("invalid range: '{s}'"))?;
    let b: f64 = b.parse().map_err(|_| format!("invalid range: '{s}'"))?;
    if a > 0.0 && a <= b {
        Ok((a, b))
    } else {
        Err(format!("invalid range: '{s}'"))
    }
}
