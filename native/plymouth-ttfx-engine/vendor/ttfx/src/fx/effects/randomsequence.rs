//! randomsequence on the fx engine (old engine: effects/random_sequence.rs).
//!
//! Every character gets one scene fading its input symbol in from the
//! terminal background to its final colors (8 frames), starts invisible, and
//! is revealed `characters_per_tick` at a time from the end of a shuffled
//! list. The shuffle is the only RNG draw. A scene's frames are memoized by
//! (symbol, final fg, final bg), so building costs a lookup and a bulk append.

use std::collections::HashMap;

use crate::effects::random_sequence::RandomSequenceConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::graphics::{Color, ColorPair, Gradient};

const DYNAMIC_NEUTRAL_GRAY: &str = "808080";

pub struct RandomSequence {
    config: RandomSequenceConfig,
    /// Shuffled slots, popped from the end.
    pending: Vec<u32>,
    characters_per_tick: i64,
}

impl RandomSequence {
    pub fn new(config: RandomSequenceConfig) -> Self {
        RandomSequence {
            config,
            pending: Vec::new(),
            characters_per_tick: 1,
        }
    }
}

impl Hooks for RandomSequence {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for RandomSequence {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let canvas = e.canvas.clone();
        // characters_per_tick = max(int(speed * len(input_characters)), 1)
        self.characters_per_tick = ((config.speed * e.input_chars.len() as f64) as i64).max(1);
        let background = e.config.terminal_background_color;
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let fade = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[background, c], 7, false)
                .map_err(other)?
                .spectrum)
        };
        let frames = config.final_gradient_frames;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        // (symbol, final fg, final bg) -> the frames of a plain scene, as a
        // range of `store`
        type MemoKey = (Sym, Option<Color>, Option<Color>);
        let mut memo: HashMap<MemoKey, (u32, u32), FxBuild> = HashMap::default();
        memo.reserve(1024);
        let mut store: Vec<Frame> = Vec::with_capacity(1024 * 8);
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        // one fade (8 frames, 9 for the neutral one) per character
        e.scenes.reserve(characters.len(), characters.len() * 9);
        for &slot in &characters {
            e.set_visible(slot, false);
            let scene = e.scene_new(slot, Name::NONE, false, None, None);
            let sym = e.input_sym(slot);
            let (fg, bg) = if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                )
            };
            let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
            match memo.get(&(sym, fg, bg)) {
                Some(&(start, len)) if plain => {
                    e.append_frames(scene, &store[start as usize..(start + len) as usize])
                }
                _ => {
                    if fg.is_some() || bg.is_some() {
                        let fg_fade = fg.map(fade).transpose()?;
                        let bg_fade = bg.map(fade).transpose()?;
                        e.apply_gradient(
                            scene,
                            &[sym],
                            frames,
                            fg_fade.as_deref(),
                            bg_fade.as_deref(),
                        )
                        .map_err(other)?;
                    } else {
                        let neutral = fade(Color::from_hex(DYNAMIC_NEUTRAL_GRAY).unwrap())?;
                        e.apply_gradient(scene, &[sym], frames, Some(&neutral), None)
                            .map_err(other)?;
                        e.add_frame(scene, sym, frames, Some(ColorPair::default()), 0)
                            .map_err(other)?;
                    }
                    if plain {
                        let frames = e.scenes.frames_of(scene);
                        memo.insert((sym, fg, bg), (store.len() as u32, frames.len() as u32));
                        store.extend_from_slice(frames);
                    }
                }
            }
            e.activate_scene(self, slot, scene);
        }
        self.pending = characters;
        e.rng.shuffle(&mut self.pending);
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.pending.is_empty() && e.active_is_empty() {
            return false;
        }
        let reveal = (self.characters_per_tick.max(0) as usize).min(self.pending.len());
        let rest = self.pending.len() - reveal;
        for k in (rest..self.pending.len()).rev() {
            let slot = *self.pending.at(k);
            e.set_visible(slot, true);
            e.active_insert(slot);
        }
        self.pending.truncate(rest);
        e.update(self);
        true
    }
}
