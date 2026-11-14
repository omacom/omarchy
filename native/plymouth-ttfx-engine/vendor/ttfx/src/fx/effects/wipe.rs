//! wipe on the fx engine (old engine: effects/wipe.rs).
//!
//! Every character gets one "wipe" scene: its final gradient color reached
//! from spectrum[0] (or its input colors, dynamic handling). A SequenceEaser
//! over the wipe direction's groups reveals and activates characters, and
//! hides and rewinds them when the easing runs backward. No RNG is drawn, so
//! the character order is free. A scene's frames depend only on (input
//! symbol, final color), so they are built once per pair and appended.

use std::collections::HashMap;

use crate::effects::wipe::WipeConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::visual::{color_key, VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, NONE};
use crate::utils::easing::SequenceEaser;
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Wipe {
    config: WipeConfig,
    easer: Option<SequenceEaser<Vec<u32>>>,
    /// Per slot: the "wipe" scene.
    scene: Vec<u32>,
    wipe_delay: i64,
}

impl Wipe {
    pub fn new(config: WipeConfig) -> Self {
        let wipe_delay = config.wipe_delay;
        Wipe {
            config,
            easer: None,
            scene: Vec::new(),
            wipe_delay,
        }
    }
}

impl Hooks for Wipe {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Wipe {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let groups = e.get_characters_grouped(CharacterFilter::default(), config.wipe_direction);
        self.easer = Some(SequenceEaser::new(groups, config.wipe_ease, 100));

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
        let first = final_gradient.spectrum[0];

        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let wipe = e.name("wipe");
        let frames = config.final_gradient_frames;
        // out-of-range durations take add_frame's path (and its error)
        let fast = (1..=u32::MAX as i64).contains(&frames);
        let dynamic_frames: i64 = config.final_gradient_steps.iter().sum::<i64>() + 1;
        self.scene = vec![NONE; e.char_count()];

        // the last final color and its wipe spectrum; (symbol, final color) ->
        // the scene's frames
        let mut last_final: Option<(Color, Vec<Color>)> = None;
        // (symbol, final color) -> memo_frames[start..end]
        let mut memo: HashMap<[u64; 2], (u32, u32), FxBuild> =
            HashMap::with_capacity_and_hasher(e.char_count().min(1 << 14), FxBuild::default());
        let mut memo_frames: Vec<Frame> = Vec::new();
        let mut scene_frames: Vec<Frame> = Vec::new();
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            let sym = e.input_sym(slot);
            let scene = e.scene_new(slot, wipe, false, None, None);
            self.scene[slot as usize] = scene;
            if dynamic {
                let colors = ColorPair::new(e.input_fg(slot), e.input_bg(slot));
                if fast {
                    let info = VisualInfo {
                        sym,
                        fg: colors.fg_color,
                        bg: colors.bg_color,
                        attrs: HAS_COLORS,
                    };
                    let visual = e.visuals.make(&e.symbols, info);
                    scene_frames.clear();
                    scene_frames.resize(
                        dynamic_frames.max(0) as usize,
                        Frame {
                            visual,
                            duration: frames as u32,
                        },
                    );
                    e.add_frames_visual(scene, &scene_frames).map_err(other)?;
                } else {
                    for _ in 0..dynamic_frames {
                        e.add_frame(scene, sym, frames, Some(colors), 0)
                            .map_err(other)?;
                    }
                }
                continue;
            }
            let final_fg = *final_gradient_mapping
                .get(&e.input_coord(slot))
                .expect("gradient mapping fg");
            if last_final.as_ref().is_none_or(|(c, _)| *c != final_fg) {
                let spectrum = Gradient::new(
                    &[first, final_fg],
                    &config.final_gradient_steps,
                    false,
                    false,
                )
                .map_err(other)?
                .spectrum;
                last_final = Some((final_fg, spectrum));
            }
            let spectrum = &last_final.as_ref().unwrap().1;
            if !fast {
                e.apply_gradient(scene, &[sym], frames, Some(spectrum), None)
                    .map_err(other)?;
                continue;
            }
            let (start, end) = *memo
                .entry([sym.0 as u64, color_key(Some(final_fg))])
                .or_insert_with(|| {
                    let start = memo_frames.len() as u32;
                    for &c in spectrum {
                        let info = VisualInfo {
                            sym,
                            fg: Some(c),
                            bg: None,
                            attrs: HAS_COLORS,
                        };
                        memo_frames.push(Frame {
                            visual: e.visuals.make(&e.symbols, info),
                            duration: frames as u32,
                        });
                    }
                    (start, memo_frames.len() as u32)
                });
            e.add_frames_visual(scene, &memo_frames[start as usize..end as usize])
                .map_err(other)?;
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        let easer_complete = self.easer.as_ref().unwrap().is_complete();
        if e.active_is_empty() && easer_complete {
            return false;
        }
        if self.wipe_delay == 0 {
            let mut easer = self.easer.take().unwrap();
            let step = easer.step();
            for group in step.added {
                for &slot in group {
                    let scene = *self.scene.at(slot);
                    e.activate_scene(self, slot, scene);
                    e.set_visible(slot, true);
                    e.active_insert(slot);
                }
            }
            for group in step.removed {
                for &slot in group {
                    e.deactivate_scene(slot, None);
                    e.scene_reset(*self.scene.at(slot));
                    e.set_visible(slot, false);
                }
            }
            self.easer = Some(easer);
            self.wipe_delay = self.config.wipe_delay;
        } else {
            self.wipe_delay -= 1;
        }
        e.update(self);
        true
    }
}
