//! Easing functions, ported from utils/easing.py.
//!
//! Transcription rule: Python `x ** n` routes through C `pow()` even for int
//! exponents, so every `**` here is `powf`, never `powi` — they can differ by
//! ULPs and coordinate quantization sits downstream (plan.md §5.20).

use std::f64::consts::PI;

/// A named easing or a custom cubic bezier (make_easing). Copyable so Paths and
/// Scenes can carry it by value.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Easing {
    Linear,
    InSine,
    OutSine,
    InOutSine,
    InQuad,
    OutQuad,
    InOutQuad,
    InCubic,
    OutCubic,
    InOutCubic,
    InQuart,
    OutQuart,
    InOutQuart,
    InQuint,
    OutQuint,
    InOutQuint,
    InExpo,
    OutExpo,
    InOutExpo,
    InCirc,
    OutCirc,
    InOutCirc,
    InBack,
    OutBack,
    InOutBack,
    InElastic,
    OutElastic,
    InOutElastic,
    InBounce,
    OutBounce,
    InOutBounce,
    /// easing.make_easing(x1, y1, x2, y2): CSS-style cubic bezier.
    CubicBezier(f64, f64, f64, f64),
}

impl Easing {

    /// CLI parser for the 31 named functions (argutils.Ease.type_parser).
    pub fn parse(s: &str) -> Option<Easing> {
        Some(match s.to_lowercase().as_str() {
            "linear" => Easing::Linear,
            "in_sine" => Easing::InSine,
            "out_sine" => Easing::OutSine,
            "in_out_sine" => Easing::InOutSine,
            "in_quad" => Easing::InQuad,
            "out_quad" => Easing::OutQuad,
            "in_out_quad" => Easing::InOutQuad,
            "in_cubic" => Easing::InCubic,
            "out_cubic" => Easing::OutCubic,
            "in_out_cubic" => Easing::InOutCubic,
            "in_quart" => Easing::InQuart,
            "out_quart" => Easing::OutQuart,
            "in_out_quart" => Easing::InOutQuart,
            "in_quint" => Easing::InQuint,
            "out_quint" => Easing::OutQuint,
            "in_out_quint" => Easing::InOutQuint,
            "in_expo" => Easing::InExpo,
            "out_expo" => Easing::OutExpo,
            "in_out_expo" => Easing::InOutExpo,
            "in_circ" => Easing::InCirc,
            "out_circ" => Easing::OutCirc,
            "in_out_circ" => Easing::InOutCirc,
            "in_back" => Easing::InBack,
            "out_back" => Easing::OutBack,
            "in_out_back" => Easing::InOutBack,
            "in_elastic" => Easing::InElastic,
            "out_elastic" => Easing::OutElastic,
            "in_out_elastic" => Easing::InOutElastic,
            "in_bounce" => Easing::InBounce,
            "out_bounce" => Easing::OutBounce,
            "in_out_bounce" => Easing::InOutBounce,
            _ => return None,
        })
    }

    pub fn ease(&self, p: f64) -> f64 {
        match *self {
            Easing::Linear => p,
            Easing::InSine => 1.0 - ((p * PI) / 2.0).cos(),
            Easing::OutSine => ((p * PI) / 2.0).sin(),
            Easing::InOutSine => -((PI * p).cos() - 1.0) / 2.0,
            Easing::InQuad => p.powf(2.0),
            Easing::OutQuad => 1.0 - (1.0 - p) * (1.0 - p),
            Easing::InOutQuad => {
                if p < 0.5 {
                    2.0 * p.powf(2.0)
                } else {
                    1.0 - (-2.0 * p + 2.0).powf(2.0) / 2.0
                }
            }
            Easing::InCubic => p.powf(3.0),
            Easing::OutCubic => 1.0 - (1.0 - p).powf(3.0),
            Easing::InOutCubic => {
                if p < 0.5 {
                    4.0 * p.powf(3.0)
                } else {
                    1.0 - (-2.0 * p + 2.0).powf(3.0) / 2.0
                }
            }
            Easing::InQuart => p.powf(4.0),
            Easing::OutQuart => 1.0 - (1.0 - p).powf(4.0),
            Easing::InOutQuart => {
                if p < 0.5 {
                    8.0 * p.powf(4.0)
                } else {
                    1.0 - (-2.0 * p + 2.0).powf(4.0) / 2.0
                }
            }
            Easing::InQuint => p.powf(5.0),
            Easing::OutQuint => 1.0 - (1.0 - p).powf(5.0),
            Easing::InOutQuint => {
                if p < 0.5 {
                    16.0 * p.powf(5.0)
                } else {
                    1.0 - (-2.0 * p + 2.0).powf(5.0) / 2.0
                }
            }
            Easing::InExpo => {
                if p == 0.0 {
                    0.0
                } else {
                    2.0_f64.powf(10.0 * p - 10.0)
                }
            }
            Easing::OutExpo => {
                if p == 1.0 {
                    1.0
                } else {
                    1.0 - 2.0_f64.powf(-10.0 * p)
                }
            }
            Easing::InOutExpo => {
                if p == 0.0 {
                    0.0
                } else if p == 1.0 {
                    1.0
                } else if p < 0.5 {
                    2.0_f64.powf(20.0 * p - 10.0) / 2.0
                } else {
                    (2.0 - 2.0_f64.powf(-20.0 * p + 10.0)) / 2.0
                }
            }
            Easing::InCirc => 1.0 - (1.0 - p.powf(2.0)).sqrt(),
            Easing::OutCirc => (1.0 - (p - 1.0).powf(2.0)).sqrt(),
            Easing::InOutCirc => {
                if p < 0.5 {
                    (1.0 - (1.0 - (2.0 * p).powf(2.0)).sqrt()) / 2.0
                } else {
                    ((1.0 - (-2.0 * p + 2.0).powf(2.0)).sqrt() + 1.0) / 2.0
                }
            }
            Easing::InBack => {
                let c1 = 1.70158;
                let c3 = c1 + 1.0;
                c3 * p.powf(3.0) - c1 * p.powf(2.0)
            }
            Easing::OutBack => {
                let c1 = 1.70158;
                let c3 = c1 + 1.0;
                1.0 + c3 * (p - 1.0).powf(3.0) + c1 * (p - 1.0).powf(2.0)
            }
            Easing::InOutBack => {
                let c1 = 1.70158;
                let c2 = c1 * 1.525;
                if p < 0.5 {
                    ((2.0 * p).powf(2.0) * ((c2 + 1.0) * 2.0 * p - c2)) / 2.0
                } else {
                    ((2.0 * p - 2.0).powf(2.0) * ((c2 + 1.0) * (p * 2.0 - 2.0) + c2) + 2.0) / 2.0
                }
            }
            Easing::InElastic => {
                let c4 = (2.0 * PI) / 3.0;
                if p == 0.0 {
                    0.0
                } else if p == 1.0 {
                    1.0
                } else {
                    -(2.0_f64.powf(10.0 * p - 10.0)) * ((p * 10.0 - 10.75) * c4).sin()
                }
            }
            Easing::OutElastic => {
                let c4 = (2.0 * PI) / 3.0;
                if p == 0.0 {
                    0.0
                } else if p == 1.0 {
                    1.0
                } else {
                    2.0_f64.powf(-10.0 * p) * ((p * 10.0 - 0.75) * c4).sin() + 1.0
                }
            }
            Easing::InOutElastic => {
                let c5 = (2.0 * PI) / 4.5;
                if p == 0.0 {
                    0.0
                } else if p == 1.0 {
                    1.0
                } else if p < 0.5 {
                    -(2.0_f64.powf(20.0 * p - 10.0) * ((20.0 * p - 11.125) * c5).sin()) / 2.0
                } else {
                    (2.0_f64.powf(-20.0 * p + 10.0) * ((20.0 * p - 11.125) * c5).sin()) / 2.0 + 1.0
                }
            }
            Easing::InBounce => 1.0 - out_bounce(1.0 - p),
            Easing::OutBounce => out_bounce(p),
            Easing::InOutBounce => {
                if p < 0.5 {
                    (1.0 - out_bounce(1.0 - 2.0 * p)) / 2.0
                } else {
                    (1.0 + out_bounce(2.0 * p - 1.0)) / 2.0
                }
            }
            Easing::CubicBezier(x1, y1, x2, y2) => bezier_easing(x1, y1, x2, y2, p),
        }
    }
}

fn out_bounce(p: f64) -> f64 {
    let n1 = 7.5625;
    let d1 = 2.75;
    if p < 1.0 / d1 {
        n1 * p.powf(2.0)
    } else if p < 2.0 / d1 {
        n1 * (p - 1.5 / d1).powf(2.0) + 0.75
    } else if p < 2.5 / d1 {
        n1 * (p - 2.25 / d1).powf(2.0) + 0.9375
    } else {
        n1 * (p - 2.625 / d1).powf(2.0) + 0.984375
    }
}

/// easing.make_easing's bezier_easing: Newton-Raphson on x with the exact
/// upstream constants (20 iterations, 1e-5 convergence, 1e-6 derivative bail).
/// Upstream lru_caches this; we just recompute (behavior-identical).
fn bezier_easing(x1: f64, y1: f64, x2: f64, y2: f64, progress: f64) -> f64 {
    let sample_curve_x = |t: f64| 3.0 * x1 * (1.0 - t).powf(2.0) * t + 3.0 * x2 * (1.0 - t) * t.powf(2.0) + t.powf(3.0);
    let sample_curve_y = |t: f64| 3.0 * y1 * (1.0 - t).powf(2.0) * t + 3.0 * y2 * (1.0 - t) * t.powf(2.0) + t.powf(3.0);
    let sample_curve_derivative_x =
        |t: f64| 3.0 * (1.0 - t).powf(2.0) * x1 + 6.0 * (1.0 - t) * t * (x2 - x1) + 3.0 * t.powf(2.0) * (1.0 - x2);

    if progress <= 0.0 {
        return 0.0;
    }
    if progress >= 1.0 {
        return 1.0;
    }
    let mut t = progress;
    for _ in 0..20 {
        let x_est = sample_curve_x(t);
        let dx = x_est - progress;
        if dx.abs() < 1e-5 {
            break;
        }
        let d = sample_curve_derivative_x(t);
        if d.abs() < 1e-6 {
            break;
        }
        t -= dx / d;
    }
    sample_curve_y(t)
}

/// easing.EasingTracker.
#[derive(Debug, Clone)]
pub struct EasingTracker {
    pub easing_function: Easing,
    pub total_steps: i64,
    clamp: bool,
    pub current_step: i64,
    pub progress_ratio: f64,
    pub step_delta: f64,
    pub eased_value: f64,
    last_eased_value: f64,
}

impl EasingTracker {
    pub fn new(easing_function: Easing, total_steps: i64, clamp: bool) -> Self {
        EasingTracker {
            easing_function,
            total_steps,
            clamp,
            current_step: 0,
            progress_ratio: 0.0,
            step_delta: 0.0,
            eased_value: 0.0,
            last_eased_value: 0.0,
        }
    }

    pub fn step(&mut self) -> f64 {
        if self.current_step < self.total_steps {
            self.current_step += 1;
            self.progress_ratio = self.current_step as f64 / self.total_steps as f64;
            self.eased_value = self.easing_function.ease(self.progress_ratio);
            if self.clamp {
                self.eased_value = self.eased_value.min(1.0).max(0.0);
            }
            self.step_delta = self.eased_value - self.last_eased_value;
            self.last_eased_value = self.eased_value;
        }
        self.eased_value
    }

    pub fn reset(&mut self) {
        self.current_step = 0;
        self.progress_ratio = 0.0;
        self.step_delta = 0.0;
        self.eased_value = 0.0;
        self.last_eased_value = 0.0;
    }

    pub fn is_complete(&self) -> bool {
        self.current_step >= self.total_steps
    }
}

/// easing.SequenceEaser over owned elements (effects use it over id groups).
#[derive(Debug, Clone)]
pub struct SequenceEaser<T> {
    pub sequence: Vec<T>,
    pub easing_tracker: EasingTracker,
}

#[derive(Debug, Clone, Copy)]
pub struct SequenceStep<'a, T> {
    pub added: &'a [T],
    pub removed: &'a [T],
}

impl<T> SequenceEaser<T> {
    pub fn new(sequence: Vec<T>, easing_function: Easing, total_steps: i64) -> Self {
        SequenceEaser {
            sequence,
            easing_tracker: EasingTracker::new(easing_function, total_steps, true),
        }
    }

    pub fn step(&mut self) -> SequenceStep<'_, T> {
        let previous_eased = self.easing_tracker.eased_value;
        let eased_value = self.easing_tracker.step();
        let seq_len = self.sequence.len();
        if seq_len == 0 {
            return SequenceStep { added: &[], removed: &[] };
        }
        // int() truncation, faithfully
        let length = (eased_value * seq_len as f64) as i64 as usize;
        let previous_length = (previous_eased * seq_len as f64) as i64 as usize;

        match length.cmp(&previous_length) {
            std::cmp::Ordering::Greater => SequenceStep {
                added: &self.sequence[previous_length..length],
                removed: &[],
            },
            std::cmp::Ordering::Less => SequenceStep {
                added: &[],
                removed: &self.sequence[length..previous_length],
            },
            std::cmp::Ordering::Equal => SequenceStep { added: &[], removed: &[] },
        }
    }

    pub fn is_complete(&self) -> bool {
        self.easing_tracker.is_complete()
    }

    pub fn reset(&mut self) {
        self.easing_tracker.reset();
    }
}

#[cfg(test)]
mod tests {
    use super::{Easing, SequenceEaser};

    #[derive(Debug, PartialEq)]
    struct NonClone(u8);

    #[test]
    fn sequence_easer_returns_borrowed_deltas_without_clone() {
        let mut easer = SequenceEaser::new(
            vec![NonClone(0), NonClone(1), NonClone(2), NonClone(3)],
            Easing::Linear,
            4,
        );

        assert_eq!(easer.step().added, &[NonClone(0)]);
        assert_eq!(easer.step().added, &[NonClone(1)]);
        assert_eq!(easer.step().added, &[NonClone(2)]);
        assert_eq!(easer.step().added, &[NonClone(3)]);
        assert!(easer.step().added.is_empty());

        easer.reset();
        assert_eq!(easer.step().added, &[NonClone(0)]);
    }

    #[test]
    fn sequence_easer_reports_reversed_easing_as_removed() {
        let sequence: Vec<usize> = (0..100).collect();
        let mut easer = SequenceEaser::new(sequence, Easing::OutBounce, 100);
        let mut saw_removed = false;

        for _ in 0..100 {
            let step = easer.step();
            assert!(step.added.is_empty() || step.removed.is_empty());
            saw_removed |= !step.removed.is_empty();
        }

        assert!(saw_removed);
    }
}
