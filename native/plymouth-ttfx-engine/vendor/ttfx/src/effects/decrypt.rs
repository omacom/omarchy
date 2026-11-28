//! decrypt, ported from effects/effect_decrypt.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps, parse_positive_int};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct DecryptConfig {
    /// Number of characters typed per keystroke.
    #[arg(long = "typing-speed", default_value_t = 2, value_parser = parse_positive_int)]
    pub typing_speed: i64,

    /// Space separated, unquoted, list of colors for the ciphertext. Color will be randomly selected for each character.
    #[arg(long = "ciphertext-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["008000", "00cb00", "00ff00"])]
    pub ciphertext_colors: Vec<Color>,

    /// Space separated, unquoted, list of colors for the character gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["eda000"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Typing,
    Decrypting,
}

pub struct Decrypt {
    config: DecryptConfig,
    typing_pending_chars: Vec<CharId>,
    /// Upstream is a set; membership only feeds `active_characters`, which is
    /// canonically ordered, so insertion-ordered Vec is equivalent.
    decrypting_pending_chars: Vec<CharId>,
    phase: Phase,
    encrypted_symbols: Vec<String>,
    character_final_color_map: HashMap<CharId, ColorPair>,
}

impl Decrypt {
    pub fn new(config: DecryptConfig) -> Self {
        let mut effect = Decrypt {
            config,
            typing_pending_chars: Vec::new(),
            decrypting_pending_chars: Vec::new(),
            phase: Phase::Typing,
            encrypted_symbols: Vec::new(),
            character_final_color_map: HashMap::new(),
        };
        effect.make_encrypted_symbols();
        effect
    }

    /// DecryptIterator.make_encrypted_symbols (_DecryptChars ranges).
    fn make_encrypted_symbols(&mut self) {
        for n in 33u32..127 {
            self.encrypted_symbols.push(char::from_u32(n).unwrap().to_string());
        }
        for n in 9608u32..9632 {
            self.encrypted_symbols.push(char::from_u32(n).unwrap().to_string());
        }
        for n in 9472u32..9599 {
            self.encrypted_symbols.push(char::from_u32(n).unwrap().to_string());
        }
        for n in 174u32..452 {
            self.encrypted_symbols.push(char::from_u32(n).unwrap().to_string());
        }
    }

    /// DecryptIterator.make_decrypting_animation_scenes.
    fn make_decrypting_animation_scenes(&mut self, ctx: &mut EngineCtx, id: CharId) -> Result<(), EngineError> {
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let (input_symbol, input_fg, input_bg, uses_pre) = {
            let ch = &ctx.terminal.arena[id.0 as usize];
            (
                ch.input_symbol.clone(),
                ch.animation.input_fg_color.clone(),
                ch.animation.input_bg_color.clone(),
                ch.uses_input_preexisting_colors,
            )
        };
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation.new_scene(false, None, None, "fast_decrypt", uses_pre);
        }
        let color = ctx.rng.choice(&self.config.ciphertext_colors).clone();
        for _ in 0..80 {
            let symbol = ctx.rng.choice(&self.encrypted_symbols).clone();
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation
                .scenes
                .get_mut("fast_decrypt")
                .unwrap()
                .add_frame(
                    &symbol,
                    2,
                    VisualParams {
                        colors: Some(ColorPair::new(Some(color.clone()), None)),
                        ..Default::default()
                    },
                )
                .map_err(EngineError::Other)?;
        }
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation.new_scene(false, None, None, "slow_decrypt", uses_pre);
        }
        for _ in 0..ctx.rng.randint(1, 15) {
            // 1-15 longer duration units
            let symbol = ctx.rng.choice(&self.encrypted_symbols).clone();
            // 30% chance of extra long duration
            // wide duration range reduces 'waves' in the animation
            // shorter duration creates flipping effect
            let duration = if ctx.rng.randint(0, 100) <= 30 {
                ctx.rng.randrange(35, 60)
            } else {
                ctx.rng.randrange(3, 6)
            };
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation
                .scenes
                .get_mut("slow_decrypt")
                .unwrap()
                .add_frame(
                    &symbol,
                    duration,
                    VisualParams {
                        colors: Some(ColorPair::new(Some(color.clone()), None)),
                        ..Default::default()
                    },
                )
                .map_err(EngineError::Other)?;
        }
        {
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation.new_scene(false, None, None, "discovered", uses_pre);
        }
        let white = Color::from_hex("ffffff").unwrap();
        if dynamic {
            let fg_gradient = match &input_fg {
                Some(fg) => Some(
                    Gradient::with_steps(&[white.clone(), fg.clone()], 10, false).map_err(EngineError::Other)?,
                ),
                None => None,
            };
            let bg_gradient = match &input_bg {
                Some(bg) => Some(
                    Gradient::with_steps(&[white.clone(), bg.clone()], 10, false).map_err(EngineError::Other)?,
                ),
                None => None,
            };
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            let scene = ch.animation.scenes.get_mut("discovered").unwrap();
            if fg_gradient.is_some() || bg_gradient.is_some() {
                scene
                    .apply_gradient_to_symbols(
                        &[input_symbol.clone()],
                        5,
                        fg_gradient.as_ref(),
                        bg_gradient.as_ref(),
                    )
                    .map_err(EngineError::Other)?;
            } else {
                scene
                    .add_frame(
                        &input_symbol,
                        5,
                        VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
        } else {
            let final_fg = self
                .character_final_color_map
                .get(&id)
                .unwrap()
                .fg_color
                .clone()
                .expect("gradient mapping fg");
            let discovered_gradient =
                Gradient::with_steps(&[white, final_fg], 10, false).map_err(EngineError::Other)?;
            let ch = &mut ctx.terminal.arena[id.0 as usize];
            ch.animation
                .scenes
                .get_mut("discovered")
                .unwrap()
                .apply_gradient_to_symbols(&[input_symbol.clone()], 5, Some(&discovered_gradient), None)
                .map_err(EngineError::Other)?;
        }
        Ok(())
    }

    /// DecryptIterator.prepare_data_for_type_effect.
    fn prepare_data_for_type_effect(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            let uses_pre = ctx.terminal.arena[id.0 as usize].uses_input_preexisting_colors;
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "typing", uses_pre);
            }
            for block_char in ["▉", "▓", "▒", "░"] {
                let color = ctx.rng.choice(&self.config.ciphertext_colors).clone();
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("typing")
                    .unwrap()
                    .add_frame(
                        block_char,
                        2,
                        VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
            let symbol = ctx.rng.choice(&self.encrypted_symbols).clone();
            let color = ctx.rng.choice(&self.config.ciphertext_colors).clone();
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("typing")
                    .unwrap()
                    .add_frame(
                        &symbol,
                        1,
                        VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
            self.typing_pending_chars.push(id);
        }
        Ok(())
    }

    /// DecryptIterator.prepare_data_for_decrypt_effect.
    fn prepare_data_for_decrypt_effect(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            self.make_decrypting_animation_scenes(ctx, id)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("fast_decrypt".to_string()),
                EventAction::ActivateScene("slow_decrypt".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("slow_decrypt".to_string()),
                EventAction::ActivateScene("discovered".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.activate_scene(self, id, "fast_decrypt");
            self.decrypting_pending_chars.push(id);
        }
        Ok(())
    }
}

impl EffectHooks for Decrypt {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Decrypt {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &characters {
            let final_colors = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                if dynamic {
                    ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone())
                } else {
                    ColorPair::new(Some(final_gradient_mapping.get(&ch.input_coord).unwrap().clone()), None)
                }
            };
            self.character_final_color_map.insert(id, final_colors);
        }
        self.prepare_data_for_type_effect(ctx)?;
        self.prepare_data_for_decrypt_effect(ctx)?;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.phase == Phase::Typing {
            if !self.typing_pending_chars.is_empty() || !ctx.active_characters.is_empty() {
                if !self.typing_pending_chars.is_empty() && ctx.rng.randint(0, 100) <= 75 {
                    for _ in 0..self.config.typing_speed {
                        if !self.typing_pending_chars.is_empty() {
                            let next_character = self.typing_pending_chars.remove(0);
                            ctx.terminal.set_character_visibility(next_character, true);
                            ctx.activate_scene(self, next_character, "typing");
                            ctx.active_characters.insert(next_character);
                        }
                    }
                }
                ctx.update(self);
                return Some(ctx.frame());
            }
            // Upstream iterates the decrypting_pending_chars set here to
            // activate "fast_decrypt" (effect_decrypt.py:263) — activation
            // only mutates each character itself (no handlers registered for
            // SCENE_ACTIVATED), so order is unobservable; ttfx iterates the
            // canonical ascending-id order.
            ctx.active_characters.clear();
            ctx.active_characters.extend(self.decrypting_pending_chars.iter().copied());
            let active: Vec<CharId> = ctx.active_characters.iter().collect();
            for id in active {
                ctx.activate_scene(self, id, "fast_decrypt");
            }
            self.phase = Phase::Decrypting;
        }

        if self.phase == Phase::Decrypting {
            if !ctx.active_characters.is_empty() {
                ctx.update(self);
                return Some(ctx.frame());
            }
            return None;
        }
        None
    }
}
