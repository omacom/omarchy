//! blackhole on the fx engine (old engine: effects/blackhole.rs).
//!
//! Everything is created in exactly the old engine's order, so every RNG draw
//! and every auto-numbered scene and path name lines up. The starfield's
//! visuals (7 symbols x 7 colors, each with its 12-frame fade) are made once
//! and reused, and a cooling scene's frames are memoized by (symbol, star
//! color, final color).

use std::collections::HashMap;

use crate::effects::blackhole::BlackholeConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym, Visual, NONE};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::{floor_div, round_half_even};

const STAR_SYMBOLS: [&str; 7] = ["*", "'", "`", "¤", "•", "°", "·"];
const UNSTABLE_SYMBOLS: [&str; 7] = ["◦", "◎", "◉", "●", "◉", "◎", "◦"];
const STARFIELD_COLORS: usize = 7;
/// A consumed scene: the star color's fade to black, then " ".
const FADE_FRAMES: usize = 12;
const EXPLODE_COLORS: [&str; 6] = [
    "#ffcc0d", "#ff7326", "#ff194d", "#bf2669", "#702a8c", "#049dbf",
];

#[derive(Debug, Clone, Copy, PartialEq)]
enum Phase {
    Forming,
    Consuming,
    Collapsing,
    Exploding,
    Complete,
}

pub struct Blackhole {
    config: BlackholeConfig,
    phase: Phase,
    radius: i64,
    /// The blackhole characters in selection order, and their membership
    /// bitmap over slots.
    chars: Vec<u32>,
    bits: Vec<u64>,
    /// Characters awaiting consumption (shuffled).
    consume: Vec<u32>,
    formation_delay: i64,
    f_delay: i64,
    form_pos: usize,
    /// Per slot: the index of its final gradient color in `final_colors`.
    final_index: Vec<u32>,
    final_colors: Vec<Color>,
    blackhole: Name,
    rotation: Name,
    singularity: Name,
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Blackhole {
    pub fn new(config: BlackholeConfig) -> Self {
        Blackhole {
            config,
            phase: Phase::Forming,
            radius: 0,
            chars: Vec::new(),
            bits: Vec::new(),
            consume: Vec::new(),
            formation_delay: 0,
            f_delay: 0,
            form_pos: 0,
            final_index: Vec::new(),
            final_colors: Vec::new(),
            blackhole: Name::NONE,
            rotation: Name::NONE,
            singularity: Name::NONE,
        }
    }

    /// BlackholeIterator.prepare_blackhole.
    fn prepare(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let hex = |h: &str| Color::from_hex(h).unwrap();
        let starfield = Gradient::with_steps(&[hex("#4a4a4d"), hex("#ffffff")], 6, false)
            .map_err(other)?
            .spectrum;
        assert_eq!(starfield.len(), STARFIELD_COLORS);
        // star visuals by symbol * 7 + color, and each one's consumed frames
        let space = e.sym(" ");
        let space_visual = e.visuals.make(
            &e.symbols,
            VisualInfo {
                sym: space,
                fg: None,
                bg: None,
                attrs: 0,
            },
        );
        let mut star_visual = [Visual(NONE); STAR_SYMBOLS.len() * STARFIELD_COLORS];
        let mut fade_frames = vec![
            [Frame {
                visual: space_visual,
                duration: 1
            }; FADE_FRAMES];
            star_visual.len()
        ];
        for (c, &color) in starfield.iter().enumerate() {
            let fade = Gradient::with_steps(&[color, hex("#000000")], 10, false)
                .map_err(other)?
                .spectrum;
            assert_eq!(fade.len(), FADE_FRAMES - 1);
            for (s, symbol) in STAR_SYMBOLS.iter().enumerate() {
                let sym = e.sym(symbol);
                let visual = |e: &mut Engine, fg: Color| {
                    e.visuals.make(
                        &e.symbols,
                        VisualInfo {
                            sym,
                            fg: Some(fg),
                            bg: None,
                            attrs: HAS_COLORS,
                        },
                    )
                };
                let k = s * STARFIELD_COLORS + c;
                star_visual[k] = visual(e, color);
                for (frame, &step) in fade_frames[k].iter_mut().zip(&fade) {
                    frame.visual = visual(e, step);
                }
            }
        }

        // take radius * 3 input characters at random
        let mut available = e.input_chars.clone();
        while (self.chars.len() as i64) < self.radius * 3 && !available.is_empty() {
            let index = e.rng.randrange(0, available.len() as i64) as usize;
            self.chars.push(available.remove(index));
        }
        self.bits = vec![0; e.char_count().div_ceil(64)];
        for &slot in &self.chars {
            self.bits[(slot >> 6) as usize] |= 1 << (slot & 63);
        }
        let center = e.canvas.center;
        let ring =
            geometry::find_coords_on_circle(center, self.radius, self.chars.len() as i64, true);
        let blackhole_colors = Some(ColorPair::new(Some(self.config.blackhole_color), None));
        let star = e.sym("*");
        let count = self.chars.len();
        for (position, &slot) in self.chars.iter().enumerate() {
            let path = e
                .path_new(
                    slot,
                    0.7,
                    Some(Easing::InOutSine),
                    None,
                    0,
                    false,
                    self.blackhole,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, ring[position], None, Name::NONE)
                .map_err(other)?;
            let scene = e.scene_new(slot, self.blackhole, false, None, None);
            e.add_frame(scene, star, 1, blackhole_colors, 0)
                .map_err(other)?;
            e.register_event(
                slot,
                Event::PathActivated,
                Caller::Path(self.blackhole),
                Action::SetLayer(1),
            )
            .map_err(other)?;
            // the ring from this position on
            let rotation = e
                .path_new(slot, 0.45, None, None, 0, true, self.rotation)
                .map_err(other)?;
            for k in 0..count {
                let at = if position + k < count {
                    position + k
                } else {
                    position + k - count
                };
                e.path_new_waypoint(rotation, ring[at], None, Name::NONE)
                    .map_err(other)?;
            }
        }

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        e.scenes
            .reserve(characters.len() * 2, characters.len() * (1 + FADE_FRAMES));
        for slot in characters {
            e.set_visible(slot, true);
            let symbol = e.rng.choice_index(STAR_SYMBOLS.len());
            let color = e.rng.choice_index(STARFIELD_COLORS);
            let k = symbol * STARFIELD_COLORS + color;
            let starting = e.scene_new(slot, Name::NONE, false, None, None);
            e.add_frame_visual(starting, star_visual[k], 1)
                .map_err(other)?;
            e.activate_scene(self, slot, starting);
            if self.bits[(slot >> 6) as usize] & (1 << (slot & 63)) != 0 {
                continue;
            }
            let starfield_coord = e.canvas.random_coord(&mut e.rng, false, false);
            let speed = e.rng.uniform(0.17, 0.30);
            e.set_coordinate(slot, starfield_coord);
            let path = e
                .path_new(
                    slot,
                    speed,
                    Some(Easing::InExpo),
                    None,
                    0,
                    false,
                    self.singularity,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, center, None, Name::NONE)
                .map_err(other)?;
            let consumed = e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Distance), None);
            e.add_frames_visual(consumed, &fade_frames[k])
                .map_err(other)?;
            let consumed = e.scene_name(consumed);
            e.register_event(
                slot,
                Event::PathActivated,
                Caller::Path(self.singularity),
                Action::SetLayer(2),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::PathActivated,
                Caller::Path(self.singularity),
                Action::ActivateScene(consumed),
            )
            .map_err(other)?;
            self.consume.push(slot);
        }
        e.rng.shuffle(&mut self.consume);
        Ok(())
    }

    /// BlackholeIterator.collapse_blackhole.
    fn collapse(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let center = e.canvas.center;
        let ring =
            geometry::find_coords_on_circle(center, self.radius + 3, self.chars.len() as i64, true);
        let unstable: Vec<Sym> = UNSTABLE_SYMBOLS.iter().map(|s| e.sym(s)).collect();
        let chars = std::mem::take(&mut self.chars);
        for (k, &slot) in chars.iter().enumerate() {
            let expand = e
                .path_new(slot, 0.2, Some(Easing::InExpo), None, 0, false, Name::NONE)
                .map_err(other)?;
            e.path_new_waypoint(expand, ring[k], None, Name::NONE)
                .map_err(other)?;
            let collapse = e
                .path_new(slot, 0.3, Some(Easing::InExpo), None, 0, false, Name::NONE)
                .map_err(other)?;
            e.path_new_waypoint(collapse, center, None, Name::NONE)
                .map_err(other)?;
            let (expand_name, collapse_name) = (
                e.paths.recs[expand as usize].name,
                e.paths.recs[collapse as usize].name,
            );
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(expand_name),
                Action::ActivatePath(collapse_name),
            )
            .map_err(other)?;
            if k == 0 {
                // the point character: 3 x 7 unstable symbols in random star colors
                let point = e.scene_new(slot, Name::NONE, false, None, None);
                for _ in 0..3 {
                    for &symbol in &unstable {
                        let color = *e.rng.choice(&self.config.star_colors);
                        e.add_frame(point, symbol, 3, Some(ColorPair::new(Some(color), None)), 0)
                            .map_err(other)?;
                    }
                }
                let point = e.scene_name(point);
                e.register_event(
                    slot,
                    Event::PathComplete,
                    Caller::Path(collapse_name),
                    Action::ActivateScene(point),
                )
                .map_err(other)?;
                e.register_event(
                    slot,
                    Event::PathComplete,
                    Caller::Path(collapse_name),
                    Action::SetLayer(3),
                )
                .map_err(other)?;
            }
            e.activate_path(self, slot, expand);
            e.active_insert(slot);
        }
        self.chars = chars;
        Ok(())
    }

    /// BlackholeIterator.explode_singularity.
    fn explode(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let explode_colors: Vec<Color> = EXPLODE_COLORS
            .iter()
            .map(|h| Color::from_hex(h).unwrap())
            .collect();
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic
            && e.preexisting_colors_present;
        // find_coords_on_circle(input_coord, 3, 5) is the same five offsets
        // around every integer origin (none is near a rounding boundary)
        let offsets = geometry::find_coords_on_circle(Coord::new(0, 0), 3, 5, true);
        assert_eq!(offsets.len(), 5);
        // (symbol, star color, final color) -> the cooling frames of a plain scene
        let mut memo: HashMap<(Sym, u32), Vec<Frame>, FxBuild> = HashMap::default();
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        e.scenes
            .reserve(characters.len() * 2, characters.len() * 12);
        for slot in characters {
            let input = e.input_coord(slot);
            let sym = e.input_sym(slot);
            let offset = offsets[e.rng.randrange(0, 5) as usize];
            let nearby_coord = Coord::new(input.column + offset.column, input.row + offset.row);
            let nearby_speed = e.rng.randint(3, 4) as f64 / 10.0;
            let nearby = e
                .path_new(
                    slot,
                    nearby_speed,
                    Some(Easing::OutExpo),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(nearby, nearby_coord, None, Name::NONE)
                .map_err(other)?;
            let input_speed = e.rng.randint(4, 6) as f64 / 100.0;
            let home = e
                .path_new(
                    slot,
                    input_speed,
                    Some(Easing::InCubic),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(home, input, None, Name::NONE)
                .map_err(other)?;
            let star = e.rng.choice_index(explode_colors.len());
            let star_color = explode_colors[star];
            let explode = e.scene_new(slot, Name::NONE, false, None, None);
            e.add_frame(
                explode,
                sym,
                1,
                Some(ColorPair::new(Some(star_color), None)),
                0,
            )
            .map_err(other)?;
            let cooling = e.scene_new(slot, Name::NONE, false, None, None);
            let spectrum = |to: Color| -> Result<Vec<Color>, EngineError> {
                Ok(Gradient::with_steps(&[star_color, to], 10, false)
                    .map_err(other)?
                    .spectrum)
            };
            if dynamic {
                let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                if fg.is_none() && bg.is_none() {
                    e.add_frame(cooling, sym, 1, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                } else {
                    let fg = fg.map(spectrum).transpose()?;
                    let bg = bg.map(spectrum).transpose()?;
                    e.apply_gradient(cooling, &[sym], 20, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                }
            } else {
                let index = self.final_index[slot as usize];
                let key = (sym, index * explode_colors.len() as u32 + star as u32);
                let plain = e.scene(cooling).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match memo.get(&key) {
                    Some(frames) if plain => e.append_frames(cooling, frames),
                    _ => {
                        let spectrum = spectrum(self.final_colors[index as usize])?;
                        e.apply_gradient(cooling, &[sym], 20, Some(&spectrum), None)
                            .map_err(other)?;
                        if plain {
                            memo.insert(key, e.scenes.frames_of(cooling).to_vec());
                        }
                    }
                }
            }
            let (nearby_name, home_name) = (
                e.paths.recs[nearby as usize].name,
                e.paths.recs[home as usize].name,
            );
            let cooling = e.scene_name(cooling);
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(nearby_name),
                Action::ActivatePath(home_name),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(nearby_name),
                Action::ActivateScene(cooling),
            )
            .map_err(other)?;
            e.activate_scene(self, slot, explode);
            e.activate_path(self, slot, nearby);
            e.active_insert(slot);
        }
        Ok(())
    }

    /// Every active character belongs to the blackhole.
    fn only_blackhole_active(&self, e: &Engine) -> bool {
        e.active
            .bits
            .iter()
            .zip(&self.bits)
            .all(|(&active, &bits)| active & !bits == 0)
    }
}

impl Hooks for Blackhole {}

impl Effect for Blackhole {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        // BlackholeIterator.__init__
        let canvas = e.canvas.clone();
        self.radius = round_half_even(canvas.width as f64 * 0.3)
            .min(round_half_even(canvas.height as f64 * 0.20))
            .max(3);
        self.blackhole = e.name("blackhole");
        self.rotation = e.name("blackhole_rotation");
        self.singularity = e.name("singularity");
        let final_gradient = Gradient::new(
            &self.config.final_gradient_stops,
            &self.config.final_gradient_steps,
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
                self.config.final_gradient_direction,
            )
            .map_err(other)?;
        let mut index_of: HashMap<Color, u32, FxBuild> = HashMap::default();
        self.final_index = vec![NONE; e.char_count()];
        for slot in e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        ) {
            let color = *final_gradient_mapping.get(&e.input_coord(slot)).unwrap();
            let next = index_of.len() as u32;
            let index = *index_of.entry(color).or_insert_with(|| {
                self.final_colors.push(color);
                next
            });
            self.final_index[slot as usize] = index;
        }
        self.prepare(e)?;
        self.formation_delay = floor_div(100, self.chars.len() as i64).max(6);
        self.f_delay = self.formation_delay;
        self.phase = Phase::Forming;
        self.form_pos = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        match self.phase {
            Phase::Complete => {
                if e.active_is_empty() {
                    return false;
                }
            }
            Phase::Forming => {
                if self.form_pos < self.chars.len() {
                    if self.f_delay == 0 {
                        let slot = self.chars[self.form_pos];
                        self.form_pos += 1;
                        let name = self.blackhole;
                        e.activate_path_name(self, slot, name);
                        e.activate_scene_name(self, slot, name);
                        e.active_insert(slot);
                        self.f_delay = self.formation_delay;
                    } else {
                        self.f_delay -= 1;
                    }
                } else if e.active_is_empty() {
                    // rotate_blackhole
                    let name = self.rotation;
                    for k in 0..self.chars.len() {
                        let slot = self.chars[k];
                        e.activate_path_name(self, slot, name);
                        e.active_insert(slot);
                    }
                    self.phase = Phase::Consuming;
                }
            }
            Phase::Consuming => {
                if !self.consume.is_empty() {
                    let (consume, name) = (std::mem::take(&mut self.consume), self.singularity);
                    for &slot in &consume {
                        e.activate_path_name(self, slot, name);
                        e.active_insert(slot);
                    }
                } else if self.only_blackhole_active(e) {
                    self.phase = Phase::Collapsing;
                }
            }
            Phase::Collapsing => {
                self.collapse(e).expect("collapse_blackhole failed");
                self.phase = Phase::Exploding;
            }
            Phase::Exploding => {
                if self.chars.iter().all(|&slot| {
                    e.ch.path[slot as usize] == NONE && e.ch.scene[slot as usize] == NONE
                }) {
                    self.explode(e).expect("explode_singularity failed");
                    self.phase = Phase::Complete;
                }
            }
        }
        e.update(self);
        true
    }
}
