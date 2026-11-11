//! decrypt on the fx engine (old engine: effects/decrypt.rs).
//!
//! Scenes are created in exactly the order the old engine creates them, so
//! every RNG draw lines up. Cipher visuals are memoized by (color, symbol)
//! and a discovered scene's frames by (symbol, final color), so building
//! costs a table lookup per frame.

use std::collections::HashMap;

use crate::effects::decrypt::DecryptConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{Engine, FxBuild, Hooks, Sym, Visual, NONE};
use crate::utils::graphics::{Color, ColorPair, Gradient};

/// The _DecryptChars ranges: 94 + 24 + 127 + 278 symbols.
const SYMBOL_RANGES: [(u32, u32); 4] = [(33, 127), (9608, 9632), (9472, 9599), (174, 452)];
const ENCRYPTED_COUNT: usize = 523;
/// The typing blocks, after the encrypted symbols in the memo.
const BLOCKS: [&str; 4] = ["▉", "▓", "▒", "░"];
const SYMBOLS: usize = ENCRYPTED_COUNT + BLOCKS.len();

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Typing,
    Decrypting,
}

pub struct Decrypt {
    config: DecryptConfig,
    phase: Phase,
    /// The characters in typing order, and each one's typing and
    /// fast_decrypt scenes.
    order: Vec<u32>,
    typing_scene: Vec<u32>,
    fast_scene: Vec<u32>,
    typing_pos: usize,
    symbols: Vec<Sym>,
    /// (cipher color, symbol) -> visual.
    memo: Vec<Visual>,
}

impl Decrypt {
    pub fn new(config: DecryptConfig) -> Self {
        Decrypt {
            config,
            phase: Phase::Typing,
            order: Vec::new(),
            typing_scene: Vec::new(),
            fast_scene: Vec::new(),
            typing_pos: 0,
            symbols: Vec::new(),
            memo: Vec::new(),
        }
    }

    /// The visual of a cipher symbol in a cipher color.
    #[inline]
    fn cipher_visual(&mut self, e: &mut Engine, color: usize, symbol: usize) -> Visual {
        let entry = &mut self.memo[color * SYMBOLS + symbol];
        if entry.0 == NONE {
            let info = VisualInfo {
                sym: self.symbols[symbol],
                fg: Some(self.config.ciphertext_colors[color]),
                bg: None,
                attrs: HAS_COLORS,
            };
            *entry = e.visuals.make(&e.symbols, info);
        }
        *entry
    }

    fn choose_cipher(&self, e: &mut Engine) -> usize {
        e.rng.choice_index(self.config.ciphertext_colors.len())
    }
}

impl Hooks for Decrypt {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Decrypt {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        for (start, end) in SYMBOL_RANGES {
            for code in start..end {
                let symbol = char::from_u32(code).unwrap().to_string();
                self.symbols.push(e.sym(&symbol));
            }
        }
        for block in BLOCKS {
            self.symbols.push(e.sym(block));
        }
        self.memo = vec![Visual(NONE); self.config.ciphertext_colors.len() * SYMBOLS];
        let typing = e.name("typing");
        let fast_decrypt = e.name("fast_decrypt");
        let slow_decrypt = e.name("slow_decrypt");
        let discovered = e.name("discovered");

        let final_gradient = Gradient::new(
            &self.config.final_gradient_stops,
            &self.config.final_gradient_steps,
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
                self.config.final_gradient_direction,
            )
            .map_err(other)?;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        self.order = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        let order = std::mem::take(&mut self.order);

        // typing (5 frames), fast (80), slow (at most 15), discovered (11)
        e.scenes
            .reserve(order.len() * 4, order.len() * (5 + 80 + 15 + 11));
        // prepare_data_for_type_effect
        self.typing_scene.reserve(order.len());
        for &slot in &order {
            let scene = e.scene_new(slot, typing, false, None, None);
            self.typing_scene.push(scene);
            let mut frames = [Frame {
                visual: Visual(NONE),
                duration: 2,
            }; BLOCKS.len() + 1];
            for (block, frame) in frames[..BLOCKS.len()].iter_mut().enumerate() {
                let color = self.choose_cipher(e);
                frame.visual = self.cipher_visual(e, color, ENCRYPTED_COUNT + block);
            }
            let symbol = e.rng.choice_index(ENCRYPTED_COUNT);
            let color = self.choose_cipher(e);
            frames[BLOCKS.len()] = Frame {
                visual: self.cipher_visual(e, color, symbol),
                duration: 1,
            };
            e.add_frames_visual(scene, &frames).map_err(other)?;
        }

        // prepare_data_for_decrypt_effect
        let white = Color::from_hex("ffffff").unwrap();
        // final color -> its index; (input symbol, final color) -> the
        // discovered frames
        let mut final_index: HashMap<Color, u32, FxBuild> = HashMap::default();
        let mut discovered_memo: HashMap<(Sym, u32), Vec<Frame>, FxBuild> = HashMap::default();
        self.fast_scene.reserve(order.len());
        for &slot in &order {
            // fast_decrypt: one color, 80 random symbols of duration 2
            let fast = e.scene_new(slot, fast_decrypt, false, None, None);
            self.fast_scene.push(fast);
            let color = self.choose_cipher(e);
            let mut symbols = [0u16; 80];
            e.rng.fill_below(ENCRYPTED_COUNT as u64, &mut symbols);
            let mut frames = [Frame {
                visual: Visual(NONE),
                duration: 2,
            }; 80];
            for (frame, &symbol) in frames.iter_mut().zip(&symbols) {
                frame.visual = self.cipher_visual(e, color, symbol as usize);
            }
            e.add_frames_visual(fast, &frames).map_err(other)?;
            // slow_decrypt: 1-15 frames of long or flickering durations
            let slow = e.scene_new(slot, slow_decrypt, false, None, None);
            let count = e.rng.randint(1, 15) as usize;
            let mut frames = [Frame {
                visual: Visual(NONE),
                duration: 0,
            }; 15];
            for frame in &mut frames[..count] {
                let symbol = e.rng.choice_index(ENCRYPTED_COUNT);
                // 30% chance of extra long duration; a wide range reduces
                // 'waves', shorter durations flip
                let duration = if e.rng.randint(0, 100) <= 30 {
                    e.rng.randrange(35, 60)
                } else {
                    e.rng.randrange(3, 6)
                };
                *frame = Frame {
                    visual: self.cipher_visual(e, color, symbol),
                    duration: duration as u32,
                };
            }
            e.add_frames_visual(slow, &frames[..count]).map_err(other)?;
            // discovered: white -> the final color in 10 steps
            let scene = e.scene_new(slot, discovered, false, None, None);
            let sym = e.input_sym(slot);
            if dynamic {
                let spectrum = |c: Option<Color>| -> Result<Option<Vec<Color>>, EngineError> {
                    c.map(|c| Gradient::with_steps(&[white, c], 10, false).map(|g| g.spectrum))
                        .transpose()
                        .map_err(other)
                };
                let fg = spectrum(e.input_fg(slot))?;
                let bg = spectrum(e.input_bg(slot))?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(scene, &[sym], 5, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(scene, sym, 5, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_fg = *final_gradient_mapping.get(&e.input_coord(slot)).unwrap();
                let next_index = final_index.len() as u32;
                let index = *final_index.entry(final_fg).or_insert(next_index);
                let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match discovered_memo.get(&(sym, index)) {
                    Some(frames) if plain => e.append_frames(scene, frames),
                    _ => {
                        let spectrum = Gradient::with_steps(&[white, final_fg], 10, false)
                            .map_err(other)?
                            .spectrum;
                        e.apply_gradient(scene, &[sym], 5, Some(&spectrum), None)
                            .map_err(other)?;
                        if plain {
                            discovered_memo
                                .insert((sym, index), e.scenes.frames_of(scene).to_vec());
                        }
                    }
                }
            }
            // fast complete -> slow; slow complete -> discovered; start on fast
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(fast_decrypt),
                Action::ActivateScene(slow_decrypt),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(slow_decrypt),
                Action::ActivateScene(discovered),
            )
            .map_err(other)?;
            e.activate_scene(self, slot, fast);
        }
        self.order = order;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.phase == Phase::Typing {
            let pending = self.typing_pos < self.order.len();
            if pending || !e.active_is_empty() {
                if pending && e.rng.randint(0, 100) <= 75 {
                    for _ in 0..self.config.typing_speed {
                        if self.typing_pos < self.order.len() {
                            let k = self.typing_pos;
                            self.typing_pos += 1;
                            let slot = self.order[k];
                            e.set_visible(slot, true);
                            let scene = self.typing_scene[k];
                            e.activate_scene(self, slot, scene);
                            e.active_insert(slot);
                        }
                    }
                }
                e.update(self);
                return true;
            }
            // every character typed and settled: decrypt all of them
            // (activation only touches the character itself, so the order is
            // unobservable)
            e.active_clear();
            for k in 0..self.order.len() {
                let slot = self.order[k];
                e.active_insert(slot);
                let scene = self.fast_scene[k];
                e.activate_scene(self, slot, scene);
            }
            self.phase = Phase::Decrypting;
        }
        if e.active_is_empty() {
            return false;
        }
        e.update(self);
        true
    }
}
