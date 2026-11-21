//! unstable, ported from effects/effect_unstable.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::EffectCallback;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

#[derive(Args, Debug, Clone)]
pub struct UnstableConfig {
    /// Color transitioned to as the characters become unstable.
    #[arg(long = "unstable-color", default_value = "ff9200", value_parser = parse_color)]
    pub unstable_color: Color,

    /// Easing function to use for character movement during the explosion.
    #[arg(long = "explosion-ease", default_value = "out_expo", value_parser = parse_easing)]
    pub explosion_ease: Easing,

    /// Speed of characters during explosion.
    #[arg(long = "explosion-speed", default_value_t = 1.0, value_parser = parse_positive_float)]
    pub explosion_speed: f64,

    /// Easing function to use for character reassembly.
    #[arg(long = "reassembly-ease", default_value = "out_expo", value_parser = parse_easing)]
    pub reassembly_ease: Easing,

    /// Speed of characters during reassembly.
    #[arg(long = "reassembly-speed", default_value_t = 1.0, value_parser = parse_positive_float)]
    pub reassembly_speed: f64,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
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
    Rumble,
    Explosion,
    Reassembly,
}

const DYNAMIC_NEUTRAL_GRAY: &str = "808080";

pub struct Unstable {
    config: UnstableConfig,
    jumbled_coords: HashMap<CharId, Coord>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    character_start_color_map: HashMap<CharId, ColorPair>,
    explosion_hold_time: i64,
    phase: Phase,
    max_rumble_steps: i64,
    current_rumble_steps: i64,
    rumble_mod_delay: i64,
}

impl Unstable {
    pub fn new(config: UnstableConfig) -> Self {
        Unstable {
            config,
            jumbled_coords: HashMap::new(),
            character_final_color_map: HashMap::new(),
            character_start_color_map: HashMap::new(),
            explosion_hold_time: 30,
            phase: Phase::Rumble,
            max_rumble_steps: 150,
            current_rumble_steps: 0,
            rumble_mod_delay: 18,
        }
    }
}

fn neutral_gray() -> Color {
    Color::from_hex(DYNAMIC_NEUTRAL_GRAY).unwrap()
}

impl EffectHooks for Unstable {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Unstable {
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
            let ch = &ctx.terminal.arena[id.0 as usize];
            let (start_colors, final_colors) = if dynamic {
                let start_fg_color =
                    ch.animation.input_fg_color.clone().unwrap_or_else(neutral_gray);
                (
                    ColorPair::new(Some(start_fg_color), ch.animation.input_bg_color.clone()),
                    ColorPair::new(ch.animation.input_fg_color.clone(), ch.animation.input_bg_color.clone()),
                )
            } else {
                let start = ColorPair::new(
                    Some(final_gradient_mapping.get(&ch.input_coord).unwrap().clone()),
                    None,
                );
                (start.clone(), start)
            };
            self.character_start_color_map.insert(id, start_colors);
            self.character_final_color_map.insert(id, final_colors);
        }
        let mut character_coords: Vec<Coord> =
            characters.iter().map(|&id| ctx.terminal.arena[id.0 as usize].input_coord).collect();
        for &id in &characters {
            let pos = ctx.rng.randint(0, 3);
            let (col, row) = match pos {
                0 => {
                    let col = ctx.terminal.canvas.left;
                    let row = ctx.terminal.canvas.random_row(&mut ctx.rng, false);
                    (col, row)
                }
                1 => {
                    let col = ctx.terminal.canvas.right;
                    let row = ctx.terminal.canvas.random_row(&mut ctx.rng, false);
                    (col, row)
                }
                2 => {
                    let col = ctx.terminal.canvas.random_column(&mut ctx.rng, false);
                    let row = ctx.terminal.canvas.bottom;
                    (col, row)
                }
                _ => {
                    let col = ctx.terminal.canvas.random_column(&mut ctx.rng, false);
                    let row = ctx.terminal.canvas.top;
                    (col, row)
                }
            };
            let jumbled_coord =
                character_coords.remove(ctx.rng.randint(0, character_coords.len() as i64 - 1) as usize);
            self.jumbled_coords.insert(id, jumbled_coord);
            let (input_symbol, input_coord, uses_pre) = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.set_coordinate(jumbled_coord);
                let explosion_path = ch
                    .motion
                    .new_path(
                        self.config.explosion_speed,
                        Some(self.config.explosion_ease),
                        None,
                        0,
                        false,
                        "explosion",
                    )
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&explosion_path)
                    .unwrap()
                    .new_waypoint(Coord::new(col, row), None, "")
                    .map_err(EngineError::Other)?;
                let reassembly_path = ch
                    .motion
                    .new_path(
                        self.config.reassembly_speed,
                        Some(self.config.reassembly_ease),
                        None,
                        0,
                        false,
                        "reassembly",
                    )
                    .map_err(EngineError::Other)?;
                let input_coord = ch.input_coord;
                ch.motion
                    .paths
                    .get_mut(&reassembly_path)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                ch.animation.new_scene(false, None, None, "rumble", uses_pre_of(ch));
                (ch.input_symbol.clone(), input_coord, uses_pre_of(ch))
            };
            let _ = input_coord;
            if dynamic {
                let start_pair = self.character_start_color_map.get(&id).unwrap().clone();
                let start_fg_color = start_pair.fg_color.clone().unwrap_or_else(neutral_gray);
                let start_bg_color = start_pair.bg_color.clone();
                let fg_gradient =
                    Gradient::with_steps(&[start_fg_color, self.config.unstable_color.clone()], 12, false)
                        .map_err(EngineError::Other)?;
                let bg_gradient = match start_bg_color {
                    Some(bg) => Some(
                        Gradient::with_steps(&[bg, self.config.unstable_color.clone()], 12, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("rumble")
                    .unwrap()
                    .apply_gradient_to_symbols(
                        &[input_symbol.clone()],
                        10,
                        Some(&fg_gradient),
                        bg_gradient.as_ref(),
                    )
                    .map_err(EngineError::Other)?;
            } else {
                let final_fg_color = self
                    .character_final_color_map
                    .get(&id)
                    .unwrap()
                    .fg_color
                    .clone()
                    .unwrap_or_else(neutral_gray);
                let unstable_gradient =
                    Gradient::with_steps(&[final_fg_color, self.config.unstable_color.clone()], 12, false)
                        .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("rumble")
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 10, Some(&unstable_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "final", uses_pre);
            }
            if dynamic {
                let final_pair = self.character_final_color_map.get(&id).unwrap().clone();
                let final_fg_color = final_pair.fg_color.clone();
                let final_bg_color = final_pair.bg_color.clone();
                if final_fg_color.is_none() && final_bg_color.is_none() {
                    let fg_gradient =
                        Gradient::with_steps(&[self.config.unstable_color.clone(), neutral_gray()], 12, false)
                            .map_err(EngineError::Other)?;
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut("final").unwrap();
                    scene
                        .apply_gradient_to_symbols(&[input_symbol.clone()], 3, Some(&fg_gradient), None)
                        .map_err(EngineError::Other)?;
                    scene
                        .add_frame(
                            &input_symbol,
                            3,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    let fg_gradient = match &final_fg_color {
                        Some(fg) => Some(
                            Gradient::with_steps(&[self.config.unstable_color.clone(), fg.clone()], 12, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let bg_gradient = match &final_bg_color {
                        Some(bg) => Some(
                            Gradient::with_steps(&[self.config.unstable_color.clone(), bg.clone()], 12, false)
                                .map_err(EngineError::Other)?,
                        ),
                        None => None,
                    };
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene = ch.animation.scenes.get_mut("final").unwrap();
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            3,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                    if final_fg_color.is_none() {
                        scene
                            .add_frame(
                                &input_symbol,
                                3,
                                VisualParams {
                                    colors: Some(ColorPair::new(None, final_bg_color)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
            } else {
                let final_fg_color = self
                    .character_final_color_map
                    .get(&id)
                    .unwrap()
                    .fg_color
                    .clone()
                    .unwrap_or_else(neutral_gray);
                let final_color =
                    Gradient::with_steps(&[self.config.unstable_color.clone(), final_fg_color], 12, false)
                        .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("final")
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 3, Some(&final_color), None)
                    .map_err(EngineError::Other)?;
            }
            ctx.activate_scene(self, id, "rumble");
            if dynamic {
                let start_pair = self.character_start_color_map.get(&id).unwrap().clone();
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let input_symbol = ch.input_symbol.clone();
                let uses = ch.uses_input_preexisting_colors;
                ch.animation.set_appearance(
                    &input_symbol,
                    uses,
                    Some(&input_symbol.clone()),
                    Some(start_pair),
                );
            }
            ctx.terminal.set_character_visibility(id, true);
        }
        self.explosion_hold_time = 30;
        self.phase = Phase::Rumble;
        self.max_rumble_steps = 150;
        self.current_rumble_steps = 0;
        self.rumble_mod_delay = 18;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        let mut next_frame: Option<String> = None;
        if self.phase == Phase::Rumble {
            if self.current_rumble_steps < self.max_rumble_steps {
                if self.current_rumble_steps > 30 && self.current_rumble_steps % self.rumble_mod_delay == 0 {
                    let row_offset = *ctx.rng.choice(&[-1i64, 0, 1]);
                    let column_offset = *ctx.rng.choice(&[-1i64, 0, 1]);
                    let characters = {
                        let filter = CharacterFilter::default();
                        ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                    };
                    for &id in &characters {
                        {
                            let motion = &mut ctx.terminal.arena[id.0 as usize].motion;
                            let current = motion.current_coord;
                            motion.set_coordinate(Coord::new(
                                current.column + column_offset,
                                current.row + row_offset,
                            ));
                        }
                        ctx.step_animation(self, id);
                    }
                    next_frame = Some(ctx.frame());
                    for &id in &characters {
                        let jumbled = *self.jumbled_coords.get(&id).unwrap();
                        ctx.terminal.arena[id.0 as usize].motion.set_coordinate(jumbled);
                    }
                    self.rumble_mod_delay -= 1;
                    self.rumble_mod_delay = self.rumble_mod_delay.max(1);
                } else {
                    let characters = {
                        let filter = CharacterFilter::default();
                        ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                    };
                    for &id in &characters {
                        ctx.step_animation(self, id);
                    }
                    next_frame = Some(ctx.frame());
                }
                self.current_rumble_steps += 1;
            } else {
                self.phase = Phase::Explosion;
                let characters = {
                    let filter = CharacterFilter::default();
                    ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                };
                for &id in &characters {
                    ctx.activate_path(self, id, "explosion");
                }
                ctx.active_characters.clear();
                ctx.active_characters.extend(characters);
            }
        }

        if self.phase == Phase::Explosion {
            if !ctx.active_characters.is_empty() {
                // Upstream iterates the active_characters set (effect_unstable.py:332);
                // canonical order is ascending character_id (shim patched to match).
                let snapshot: Vec<CharId> = ctx.active_characters.iter().collect();
                for id in snapshot {
                    ctx.tick(self, id);
                }
                let retained: Vec<CharId> = ctx
                    .active_characters
                    .iter()
                    .filter(|&id| {
                        let ch = &ctx.terminal.arena[id.0 as usize];
                        let explosion_target = ch.motion.paths.get("explosion").unwrap().waypoints[0].coord;
                        ch.motion.current_coord != explosion_target
                    })
                    .collect();
                ctx.active_characters.clear();
                ctx.active_characters.extend(retained);
                next_frame = Some(ctx.frame());
            } else if self.explosion_hold_time != 0 {
                // upstream ticks the (empty) active set here: no-op
                self.explosion_hold_time -= 1;
                next_frame = Some(ctx.frame());
            } else {
                self.phase = Phase::Reassembly;
                let characters = {
                    let filter = CharacterFilter::default();
                    ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                };
                for &id in &characters {
                    ctx.activate_scene(self, id, "final");
                    ctx.active_characters.insert(id);
                    ctx.activate_path(self, id, "reassembly");
                }
            }
        }

        if self.phase == Phase::Reassembly && !ctx.active_characters.is_empty() {
            // Upstream iterates the active_characters set (effect_unstable.py:354);
            // canonical order is ascending character_id (shim patched to match).
            let snapshot: Vec<CharId> = ctx.active_characters.iter().collect();
            for id in snapshot {
                ctx.tick(self, id);
            }
            let retained: Vec<CharId> = ctx
                .active_characters
                .iter()
                .filter(|&id| {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    let reassembly_target = ch.motion.paths.get("reassembly").unwrap().waypoints[0].coord;
                    ch.motion.current_coord != reassembly_target || !ch.animation.active_scene_is_complete()
                })
                .collect();
            ctx.active_characters.clear();
            ctx.active_characters.extend(retained);
            next_frame = Some(ctx.frame());
        }

        next_frame
    }
}

fn uses_pre_of(ch: &crate::engine::character::EffectCharacter) -> bool {
    ch.uses_input_preexisting_colors
}
