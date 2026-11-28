//! waves on the fx engine (old engine: effects/waves.rs).
//!
//! Every character gets an eased wave scene (auto id 0) and a final scene
//! (auto id 1), activated by the wave's SCENE_COMPLETE. The wave scene is the
//! same frame list for every character: the first one whose scene has no
//! preexisting colors builds it with apply_gradient, as the old engine does,
//! and the others copy it. No RNG is drawn, so the character order is free.

use std::collections::{HashMap, VecDeque};

use crate::effects::waves::WavesConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym, NONE};
use crate::utils::graphics::{Color, ColorPair, Gradient};

const FINAL_DURATION: i64 = 10;

pub struct Waves {
    config: WavesConfig,
    pending: VecDeque<Vec<u32>>,
}

impl Waves {
    pub fn new(config: WavesConfig) -> Self {
        Waves {
            config,
            pending: VecDeque::new(),
        }
    }
}

impl Hooks for Waves {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Waves {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
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
        let wave_gradient = Gradient::new(
            &config.wave_gradient_stops,
            &config.wave_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let wave_last = *wave_gradient.spectrum.last().unwrap();
        let wave_symbols: Vec<Sym> = config.wave_symbols.iter().map(|s| e.sym(s)).collect();
        // Gradient([wave last, color], final steps)
        let pair_spectrum = |color: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::new(
                &[wave_last, color],
                &config.final_gradient_steps,
                false,
                false,
            )
            .map_err(other)?
            .spectrum)
        };
        let handling = e.existing_color_handling();
        let dynamic = handling == ExistingColorHandling::Dynamic;
        let wave = Name::auto(0);
        let final_ = Name::auto(1);

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        let mut template = NONE;
        // the last final color, its index and spectrum; (input symbol, final
        // color index) -> the final frames of a plain scene
        let mut last_final: Option<(Color, u32, Vec<Color>)> = None;
        let mut final_index: HashMap<Color, u32, FxBuild> = HashMap::default();
        let mut final_memo: HashMap<(Sym, u32), Vec<Frame>, FxBuild> = HashMap::default();
        for slot in characters {
            let clone = template != NONE
                && !(handling == ExistingColorHandling::Always && e.uses_preexisting_colors(slot));
            let wave_scene = if clone {
                e.scene_copy(slot, template, wave)
            } else {
                let scene = e.scene_new(slot, wave, false, None, Some(config.wave_easing));
                for _ in 0..config.wave_count {
                    e.apply_gradient(
                        scene,
                        &wave_symbols,
                        config.wave_length,
                        Some(&wave_gradient.spectrum),
                        None,
                    )
                    .map_err(other)?;
                }
                if template == NONE && e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0
                {
                    template = scene;
                }
                scene
            };
            let final_scene = e.scene_new(slot, final_, false, None, None);
            let sym = e.input_sym(slot);
            if dynamic {
                let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                if fg.is_none() && bg.is_none() {
                    e.add_frame(
                        final_scene,
                        sym,
                        FINAL_DURATION,
                        Some(ColorPair::default()),
                        0,
                    )
                    .map_err(other)?;
                } else {
                    let fg_spectrum = fg.map(pair_spectrum).transpose()?;
                    let bg_spectrum = bg.map(pair_spectrum).transpose()?;
                    e.apply_gradient(
                        final_scene,
                        &[sym],
                        FINAL_DURATION,
                        fg_spectrum.as_deref(),
                        bg_spectrum.as_deref(),
                    )
                    .map_err(other)?;
                    if fg.is_none() {
                        e.add_frame(
                            final_scene,
                            sym,
                            FINAL_DURATION,
                            Some(ColorPair::new(None, bg)),
                            0,
                        )
                        .map_err(other)?;
                    }
                }
            } else {
                let final_fg = *final_gradient_mapping
                    .get(&e.input_coord(slot))
                    .expect("gradient mapping fg");
                if last_final.as_ref().is_none_or(|(c, _, _)| *c != final_fg) {
                    let next_index = final_index.len() as u32;
                    let index = *final_index.entry(final_fg).or_insert(next_index);
                    last_final = Some((final_fg, index, pair_spectrum(final_fg)?));
                }
                let (_, index, spectrum) = last_final.as_ref().unwrap();
                let plain = e.scene(final_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match final_memo.get(&(sym, *index)) {
                    Some(frames) if plain => e.append_frames(final_scene, frames),
                    _ => {
                        for &step in spectrum {
                            e.add_frame(
                                final_scene,
                                sym,
                                FINAL_DURATION,
                                Some(ColorPair::new(Some(step), None)),
                                0,
                            )
                            .map_err(other)?;
                        }
                        if plain {
                            final_memo
                                .insert((sym, *index), e.scenes.frames_of(final_scene).to_vec());
                        }
                    }
                }
            }
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(wave),
                Action::ActivateScene(final_),
            )
            .map_err(other)?;
            e.activate_scene(self, slot, wave_scene);
            if dynamic {
                let colors = ColorPair::new(e.input_fg(slot), e.input_bg(slot));
                e.set_appearance(slot, Some(sym), Some(colors));
            }
        }
        self.pending = e
            .get_characters_grouped(CharacterFilter::default(), config.wave_direction)
            .into();
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.pending.is_empty() && e.active_is_empty() {
            return false;
        }
        if let Some(group) = self.pending.pop_front() {
            for slot in group {
                e.set_visible(slot, true);
                e.active_insert(slot);
            }
        }
        e.update(self);
        true
    }
}
