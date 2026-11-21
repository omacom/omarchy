//! Coord and geometry math, ported from utils/geometry.py.
//!
//! Upstream wraps every function in lru_cache; behavior is identical without
//! the caches, so they are omitted. All `round()` calls are banker's rounding
//! (pycompat), all int() casts truncate.

use std::collections::HashSet;

use crate::utils::pycompat::round_half_even;

/// 1-based canvas coordinate: column grows right, row grows UP (origin bottom-left).
/// `repr(C)`: the fx motion batch loads a run of them as (column, row) pairs.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(C)]
pub struct Coord {
    pub column: i64,
    pub row: i64,
}

impl Coord {
    pub fn new(column: i64, row: i64) -> Self {
        Coord { column, row }
    }
}

/// Float-valued point for bezier intermediates: upstream builds Coord objects
/// with float fields inside de_casteljau (violating its own annotation) and
/// only rounds the final result.
#[derive(Debug, Clone, Copy)]
struct FloatPoint {
    column: f64,
    row: f64,
}

impl FloatPoint {
    #[inline]
    fn interpolate(self, other: Self, t: f64) -> Self {
        FloatPoint {
            column: (1.0 - t) * self.column + t * other.column,
            row: (1.0 - t) * self.row + t * other.row,
        }
    }
}

/// find_coords_on_circle: coords_limit 0 -> round(2*pi*r); x offset from the
/// origin is doubled for cell aspect; every point rounded (banker's).
pub fn find_coords_on_circle(
    origin: Coord,
    radius: i64,
    coords_limit: i64,
    unique: bool,
) -> Vec<Coord> {
    let mut points: Vec<Coord> = Vec::new();
    if radius == 0 {
        return points;
    }
    let coords_limit = if coords_limit == 0 {
        round_half_even(2.0 * std::f64::consts::PI * radius as f64)
    } else {
        coords_limit
    };
    let mut seen = (unique && coords_limit > 1).then(HashSet::new);
    let angle_step = 2.0 * std::f64::consts::PI / coords_limit as f64;
    for i in 0..coords_limit {
        let angle = angle_step * i as f64;
        let mut x = origin.column as f64 + radius as f64 * angle.cos();
        let x_diff = x - origin.column as f64;
        x += x_diff;
        let y = origin.row as f64 + radius as f64 * angle.sin();
        let point = Coord::new(round_half_even(x), round_half_even(y));
        if seen.as_mut().map_or(true, |seen| seen.insert(point)) {
            points.push(point);
        }
    }
    points
}

/// find_coords_in_circle: actually an ellipse (a = diameter, b = diameter/2);
/// int() truncation on the y offset, faithfully.
pub fn find_coords_in_circle(center: Coord, diameter: i64) -> Vec<Coord> {
    let mut coords = Vec::new();
    if diameter == 0 {
        return coords;
    }
    let (h, k) = (center.column, center.row);
    let a_squared = (diameter as f64).powf(2.0);
    let b_squared = (diameter as f64 / 2.0).powf(2.0);
    // Keep the eager nested loop: collecting the flattened iterator is slower
    // for callers that need a vector, particularly for small circles.
    for x in (h - diameter)..=(h + diameter) {
        for y in circle_column_y_range(x, h, k, a_squared, b_squared) {
            coords.push(Coord::new(x, y));
        }
    }
    coords
}

#[inline]
fn circle_column_y_range(
    x: i64,
    h: i64,
    k: i64,
    a_squared: f64,
    b_squared: f64,
) -> std::ops::RangeInclusive<i64> {
    let x_component = ((x - h) as f64).powf(2.0) / a_squared;
    let max_y_offset = (b_squared * (1.0 - x_component)).powf(0.5) as i64;
    (k - max_y_offset)..=(k + max_y_offset)
}

/// Stream the same column-major ellipse for callers that only visit its cells.
pub(crate) fn coords_in_circle(center: Coord, diameter: i64) -> impl Iterator<Item = Coord> {
    let (h, k) = (center.column, center.row);
    let columns = (diameter != 0).then(|| (h - diameter)..=(h + diameter));
    let a_squared = (diameter as f64).powf(2.0);
    let b_squared = (diameter as f64 / 2.0).powf(2.0);
    columns.into_iter().flatten().flat_map(move |x| {
        circle_column_y_range(x, h, k, a_squared, b_squared).map(move |y| Coord::new(x, y))
    })
}

/// find_coords_in_rect: full (2d+1)^2 block, empty for distance 0.
/// Iteration order is column-major like upstream.
pub fn find_coords_in_rect(origin: Coord, distance: i64) -> Vec<Coord> {
    let mut coords: Vec<Coord> = Vec::new();
    if distance == 0 {
        return coords;
    }
    for column in (origin.column - distance)..=(origin.column + distance) {
        for row in (origin.row - distance)..=(origin.row + distance) {
            coords.push(Coord::new(column, row));
        }
    }
    coords
}

/// find_coords_on_rect: perimeter only; empty if either half-dimension is 0.
pub fn find_coords_on_rect(origin: Coord, half_width: i64, half_height: i64) -> Vec<Coord> {
    let mut coords: Vec<Coord> = Vec::new();
    if half_width == 0 || half_height == 0 {
        return coords;
    }
    for column in (origin.column - half_width)..=(origin.column + half_width) {
        if column == origin.column - half_width || column == origin.column + half_width {
            for row in (origin.row - half_height)..=(origin.row + half_height) {
                coords.push(Coord::new(column, row));
            }
        } else {
            coords.push(Coord::new(column, origin.row - half_height));
            coords.push(Coord::new(column, origin.row + half_height));
        }
    }
    coords
}

/// extrapolate_along_ray: NON-doubled line length, lerp past the target, round.
pub fn extrapolate_along_ray(origin: Coord, target: Coord, offset_from_target: f64) -> Coord {
    let base = find_length_of_line(origin, target, false);
    let total_distance = base + offset_from_target;
    if total_distance == 0.0 || origin == target {
        return target;
    }
    let t = total_distance / base;
    let next_column = (1.0 - t) * origin.column as f64 + t * target.column as f64;
    let next_row = (1.0 - t) * origin.row as f64 + t * target.row as f64;
    Coord::new(round_half_even(next_column), round_half_even(next_row))
}

/// find_coord_on_bezier_curve: recursive De Casteljau of arbitrary degree with
/// float intermediates, rounded only at the end.
pub fn find_coord_on_bezier_curve(start: Coord, control: &[Coord], end: Coord, t: f64) -> Coord {
    if control.is_empty() {
        return find_coord_on_line(start, end, t);
    }

    let start = FloatPoint {
        column: start.column as f64,
        row: start.row as f64,
    };
    let end = FloatPoint {
        column: end.column as f64,
        row: end.row as f64,
    };

    // Every production path is quadratic. Keep that per-frame hot path on the
    // stack instead of allocating a Vec at each De Casteljau level.
    if let [control] = control {
        let control = FloatPoint {
            column: control.column as f64,
            row: control.row as f64,
        };
        let point = start
            .interpolate(control, t)
            .interpolate(control.interpolate(end, t), t);
        return Coord::new(round_half_even(point.column), round_half_even(point.row));
    }

    let mut points: Vec<FloatPoint> = Vec::with_capacity(control.len() + 2);
    points.push(start);
    for c in control {
        points.push(FloatPoint {
            column: c.column as f64,
            row: c.row as f64,
        });
    }
    points.push(end);
    let mut remaining = points.len();
    while remaining > 1 {
        for i in 0..remaining - 1 {
            points[i] = points[i].interpolate(points[i + 1], t);
        }
        remaining -= 1;
    }
    Coord::new(
        round_half_even(points[0].column),
        round_half_even(points[0].row),
    )
}

/// find_coord_on_line: lerp + round.
pub fn find_coord_on_line(start: Coord, end: Coord, t: f64) -> Coord {
    let x = (1.0 - t) * start.column as f64 + t * end.column as f64;
    let y = (1.0 - t) * start.row as f64 + t * end.row as f64;
    Coord::new(round_half_even(x), round_half_even(y))
}

/// find_length_of_bezier_curve: 10-sample polyline that stops at t=0.9 — the
/// final t=0.9..1.0 span is deliberately (faithfully) omitted, systematically
/// underestimating lengths. Do not fix (plan.md §5.4).
pub fn find_length_of_bezier_curve(start: Coord, control: &[Coord], end: Coord) -> f64 {
    let mut length = 0.0;
    let mut prev_coord = start;
    for t in 1..10 {
        let coord = find_coord_on_bezier_curve(start, control, end, t as f64 / 10.0);
        length += find_length_of_line(prev_coord, coord, true);
        prev_coord = coord;
    }
    length
}

/// find_length_of_line: hypot, with the row delta doubled when requested
/// (terminal cell aspect convention).
pub fn find_length_of_line(coord1: Coord, coord2: Coord, double_row_diff: bool) -> f64 {
    let column_diff = (coord2.column - coord1.column) as f64;
    let row_diff = (coord2.row - coord1.row) as f64;
    if double_row_diff {
        f64::hypot(column_diff, 2.0 * row_diff)
    } else {
        f64::hypot(column_diff, row_diff)
    }
}

/// find_normalized_distance_from_center: rejects out-of-rectangle coords
/// (upstream ValueError); stays within [0, 1] for accepted ones.
pub fn find_normalized_distance_from_center(
    bottom: i64,
    top: i64,
    left: i64,
    right: i64,
    other_coord: Coord,
) -> Result<f64, String> {
    let y_offset = bottom - 1;
    let x_offset = left - 1;
    let right = right - x_offset;
    let top = top - y_offset;
    let center_x = right as f64 / 2.0;
    let center_y = top as f64 / 2.0;

    // Python: `n not in range(a, b+1)` — integer membership
    let col = other_coord.column - x_offset;
    let row = other_coord.row - y_offset;
    if !(left - x_offset..=right).contains(&col) || !(bottom - y_offset..=top).contains(&row) {
        return Err("Coordinate is not within the rectangle.".to_string());
    }

    let max_distance = ((right as f64).powf(2.0) + ((top * 2) as f64).powf(2.0)).powf(0.5);
    let distance =
        ((col as f64 - center_x).powf(2.0) + ((row as f64 - center_y) * 2.0).powf(2.0)).powf(0.5);
    Ok(distance / (max_distance / 2.0))
}
