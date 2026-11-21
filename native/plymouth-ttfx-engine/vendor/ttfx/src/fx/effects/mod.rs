//! Effects on the fx engine. `build` offers an effect command to it;
//! commands it declines (see `durations_fit`) run on the old engine.

pub mod beams;
pub mod binarypath;
pub mod blackhole;
pub mod bouncyballs;
pub mod bubbles;
pub mod burn;
pub mod colorshift;
pub mod crumble;
pub mod decrypt;
pub mod errorcorrect;
pub mod expand;
pub mod fireworks;
pub mod highlight;
pub mod laseretch;
pub mod matrix;
pub mod middleout;
pub mod orbittingvolley;
pub mod overflow;
pub mod pour;
pub mod print;
pub mod rain;
pub mod randomsequence;
pub mod rings;
pub mod scattered;
pub mod slice;
pub mod slide;
pub mod smoke;
pub mod spotlights;
pub mod spray;
pub mod swarm;
pub mod sweep;
pub mod synthgrid;
pub mod thunderstorm;
pub mod unstable;
pub mod vhstape;
pub mod waves;
pub mod wipe;

use crate::effects::EffectCommand;

use super::run::Effect;

/// The fx-engine effect for this command, if there is one. `TTFX_FX=0`
/// skips the fx engine (for comparisons): the original engine takes the run.
pub fn build(command: &EffectCommand) -> Option<Box<dyn Effect>> {
    if std::env::var_os("TTFX_FX").is_some_and(|v| v == "0") || !durations_fit(command) {
        return None;
    }
    match command {
        EffectCommand::Decrypt(config) => Some(Box::new(decrypt::Decrypt::new(config.clone()))),
        EffectCommand::Colorshift(config) => {
            Some(Box::new(colorshift::ColorShift::new(config.clone())))
        }
        EffectCommand::Expand(config) => Some(Box::new(expand::Expand::new(config.clone()))),
        EffectCommand::Print(config) => Some(Box::new(print::Print::new(config.clone()))),
        EffectCommand::Rings(config) => Some(Box::new(rings::Rings::new(config.clone()))),
        EffectCommand::Synthgrid(config) => {
            Some(Box::new(synthgrid::SynthGrid::new(config.clone())))
        }
        EffectCommand::Vhstape(config) => Some(Box::new(vhstape::VhsTape::new(config.clone()))),
        EffectCommand::Waves(config) => Some(Box::new(waves::Waves::new(config.clone()))),
        EffectCommand::Blackhole(config) => {
            Some(Box::new(blackhole::Blackhole::new(config.clone())))
        }
        EffectCommand::Errorcorrect(config) => {
            Some(Box::new(errorcorrect::ErrorCorrect::new(config.clone())))
        }
        EffectCommand::Unstable(config) => Some(Box::new(unstable::Unstable::new(config.clone()))),
        EffectCommand::Crumble(config) => Some(Box::new(crumble::Crumble::new(config.clone()))),
        EffectCommand::Beams(config) => Some(Box::new(beams::Beams::new(config.clone()))),
        EffectCommand::Matrix(config) => Some(Box::new(matrix::Matrix::new(config.clone()))),
        EffectCommand::Fireworks(config) => {
            Some(Box::new(fireworks::Fireworks::new(config.clone())))
        }
        EffectCommand::Laseretch(config) => {
            Some(Box::new(laseretch::LaserEtch::new(config.clone())))
        }
        EffectCommand::Swarm(config) => Some(Box::new(swarm::Swarm::new(config.clone()))),
        EffectCommand::Overflow(config) => Some(Box::new(overflow::Overflow::new(config.clone()))),
        EffectCommand::Burn(config) => Some(Box::new(burn::Burn::new(config.clone()))),
        EffectCommand::Rain(config) => Some(Box::new(rain::Rain::new(config.clone()))),
        EffectCommand::Middleout(config) => {
            Some(Box::new(middleout::Middleout::new(config.clone())))
        }
        EffectCommand::Spray(config) => Some(Box::new(spray::Spray::new(config.clone()))),
        EffectCommand::Thunderstorm(config) => {
            Some(Box::new(thunderstorm::Thunderstorm::new(config.clone())))
        }
        EffectCommand::Wipe(config) => Some(Box::new(wipe::Wipe::new(config.clone()))),
        EffectCommand::Highlight(config) => {
            Some(Box::new(highlight::Highlight::new(config.clone())))
        }
        EffectCommand::Bubbles(config) => Some(Box::new(bubbles::Bubbles::new(config.clone()))),
        EffectCommand::Smoke(config) => Some(Box::new(smoke::Smoke::new(config.clone()))),
        EffectCommand::Orbittingvolley(config) => Some(Box::new(
            orbittingvolley::OrbittingVolley::new(config.clone()),
        )),
        EffectCommand::Spotlights(config) => {
            Some(Box::new(spotlights::Spotlights::new(config.clone())))
        }
        EffectCommand::Binarypath(config) => {
            Some(Box::new(binarypath::BinaryPath::new(config.clone())))
        }
        EffectCommand::Slide(config) => Some(Box::new(slide::Slide::new(config.clone()))),
        EffectCommand::Pour(config) => Some(Box::new(pour::Pour::new(config.clone()))),
        EffectCommand::Scattered(config) => {
            Some(Box::new(scattered::Scattered::new(config.clone())))
        }
        EffectCommand::Bouncyballs(config) => {
            Some(Box::new(bouncyballs::BouncyBalls::new(config.clone())))
        }
        EffectCommand::Randomsequence(config) => Some(Box::new(
            randomsequence::RandomSequence::new(config.clone()),
        )),
        EffectCommand::Slice(config) => Some(Box::new(slice::Slice::new(config.clone()))),
        EffectCommand::Sweep(config) => Some(Box::new(sweep::Sweep::new(config.clone()))),
    }
}

/// Frame durations and eased step totals are u32 in the engine, and some
/// effects push frames without add_frame's "at least 1" check, so frame
/// durations from the command line must lie in 1..=limit or the command goes
/// to the old engine (this engine's limits: 32-bit durations, 2^24 where
/// they are summed into an eased scene).
fn durations_fit(command: &EffectCommand) -> bool {
    const PLAIN: i64 = i32::MAX as i64;
    const EASED: i64 = 1 << 24;
    let fit = |limit: i64, frames: &[i64]| frames.iter().all(|f| (1..=limit).contains(f));
    match command {
        EffectCommand::Beams(c) => fit(PLAIN, &[c.beam_gradient_frames, c.final_gradient_frames]),
        EffectCommand::Colorshift(c) => fit(PLAIN, &[c.gradient_frames]),
        EffectCommand::Laseretch(c) => fit(EASED, &[c.spark_cooling_frames]),
        EffectCommand::Matrix(c) => fit(PLAIN, &[c.final_gradient_frames]),
        EffectCommand::Pour(c) => fit(PLAIN, &[c.final_gradient_frames]),
        EffectCommand::Randomsequence(c) => fit(PLAIN, &[c.final_gradient_frames]),
        EffectCommand::Scattered(c) => fit(PLAIN, &[c.final_gradient_frames]),
        EffectCommand::Slide(c) => fit(PLAIN, &[c.final_gradient_frames]),
        EffectCommand::Thunderstorm(c) => fit(EASED, &[c.text_glow_time, c.spark_glow_time]),
        EffectCommand::Wipe(c) => fit(PLAIN, &[c.final_gradient_frames]),
        _ => true,
    }
}
