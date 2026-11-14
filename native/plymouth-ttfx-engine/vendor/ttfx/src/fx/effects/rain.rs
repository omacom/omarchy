//! rain on the fx engine (old engine: effects/rain.rs).
//!
//! Every character gets its rain scene (auto id 0), fade scene (auto id 1),
//! path (auto id 0) and PathComplete event in the old engine's order, so every
//! RNG draw lines up. Raindrop visuals are memoized by (color, symbol) and a
//! plain fade scene's frames by (symbol, raindrop color, final color).
//!
//! group_by_row is the TopToBottomLeftToRight character list walked backwards
//! one row at a time: the old stable sort by ascending row keeps each row's
//! left-to-right order, and its BTreeMap pops the lowest row first.

use std::collections::HashMap;
use std::ops::Range;

use crate::effects::rain::RainConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, Visual, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Rain {
    config: RainConfig,
    /// The TopToBottomLeftToRight characters; rows not yet pending are
    /// `chars[..group_end]`.
    chars: Vec<u32>,
    group_end: usize,
    pending: Vec<u32>,
}

impl Rain {
    pub fn new(config: RainConfig) -> Self {
        Rain {
            config,
            chars: Vec::new(),
            group_end: 0,
            pending: Vec::new(),
        }
    }
}

impl Hooks for Rain {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Rain {
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
        let canvas_top = canvas.top;
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let symbols: Vec<Sym> = config.rain_symbols.iter().map(|s| e.sym(s)).collect();
        let (color_count, symbol_count) = (config.rain_colors.len(), symbols.len());
        // (raindrop color, symbol) -> visual
        let mut drop_memo = vec![Visual(NONE); color_count * symbol_count];
        // (input symbol, raindrop color, final color) -> a plain fade scene's
        // frames in `fade_frames`
        let mut fade_memo: HashMap<(Sym, u32, Color), Range<usize>, FxBuild> = HashMap::default();
        let mut fade_frames: Vec<Frame> = Vec::new();
        let rain = Name::auto(0);
        let fade = Name::auto(1);

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        e.scenes.reserve(characters.len() * 2, characters.len() * 9);
        for &slot in &characters {
            let input = e.input_coord(slot);
            let sym = e.input_sym(slot);
            let color = e.rng.choice_index(color_count);
            let raindrop_color = config.rain_colors[color];
            let rain_scene = e.scene_new(slot, rain, false, None, None);
            let symbol = e.rng.choice_index(symbol_count);
            let entry = drop_memo.at_mut(color * symbol_count + symbol);
            if entry.0 == NONE {
                let info = VisualInfo {
                    sym: symbols[symbol],
                    fg: Some(raindrop_color),
                    bg: None,
                    attrs: HAS_COLORS,
                };
                *entry = e.visuals.make(&e.symbols, info);
            }
            e.add_frame_visual(rain_scene, *entry, 1).map_err(other)?;
            let fade_scene = e.scene_new(slot, fade, false, None, None);
            if dynamic {
                let spectrum = |c: Option<_>| -> Result<Option<Vec<_>>, EngineError> {
                    c.map(|c| {
                        Gradient::with_steps(&[raindrop_color, c], 7, false).map(|g| g.spectrum)
                    })
                    .transpose()
                    .map_err(other)
                };
                let fg = spectrum(e.input_fg(slot))?;
                let bg = spectrum(e.input_bg(slot))?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(fade_scene, &[sym], 3, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(fade_scene, sym, 3, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_fg = *final_gradient_mapping
                    .get(&input)
                    .expect("gradient mapping fg");
                let plain = e.scene(fade_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                let key = (sym, color as u32, final_fg);
                match fade_memo.get(&key) {
                    Some(range) if plain => {
                        e.append_frames(fade_scene, &fade_frames[range.clone()])
                    }
                    _ => {
                        let spectrum = Gradient::with_steps(&[raindrop_color, final_fg], 7, false)
                            .map_err(other)?
                            .spectrum;
                        e.apply_gradient(fade_scene, &[sym], 3, Some(&spectrum), None)
                            .map_err(other)?;
                        if plain {
                            let start = fade_frames.len();
                            fade_frames.extend_from_slice(e.scenes.frames_of(fade_scene));
                            fade_memo.insert(key, start..fade_frames.len());
                        }
                    }
                }
            }
            e.activate_scene(self, slot, rain_scene);
            let speed = e
                .rng
                .uniform(config.movement_speed.0, config.movement_speed.1);
            e.set_coordinate(slot, Coord::new(input.column, canvas_top));
            let path = e
                .path_new(
                    slot,
                    speed,
                    Some(config.movement_easing),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, input, None, Name::NONE)
                .map_err(other)?;
            let path_name = e.paths.recs[path as usize].name;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(path_name),
                Action::ActivateScene(fade),
            )
            .map_err(other)?;
            e.activate_path(self, slot, path);
        }
        self.group_end = characters.len();
        self.pending = Vec::with_capacity(characters.len());
        self.chars = characters;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.pending.is_empty() {
            if self.group_end == 0 {
                if e.active_is_empty() {
                    return false;
                }
            } else {
                // pending.extend(group_by_row.pop_first())
                let end = self.group_end;
                let row = e.input_coord(*self.chars.at(end - 1)).row;
                let mut start = end - 1;
                while start > 0 && e.input_coord(*self.chars.at(start - 1)).row == row {
                    start -= 1;
                }
                self.pending.extend_from_slice(&self.chars[start..end]);
                self.group_end = start;
            }
        }
        if !self.pending.is_empty() {
            for _ in 0..e.rng.randint(1, 2) {
                if self.pending.is_empty() {
                    break;
                }
                let index = e.rng.randint(0, self.pending.len() as i64 - 1) as usize;
                let slot = self.pending.remove(index);
                e.set_visible(slot, true);
                e.active_insert(slot);
            }
        }
        e.update(self);
        true
    }
}
