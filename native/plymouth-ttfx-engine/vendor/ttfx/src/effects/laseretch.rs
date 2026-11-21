//! laseretch, ported from effects/effect_laseretch.py.
//!
//! The inner LaserEtchIterator.Laser class is the `Laser` struct; its methods
//! live on `LaserEtch` (they need &mut self for event hooks). Sparks are a
//! ParticlePool; reclaim-on-event is an EventAction::Callback dispatched in
//! dispatch_callback (plan.md §4.2).
//!
//! Upstream quirk (effect_laseretch.py:404): `--etch-pattern <group>` parses to
//! a CharacterGroup enum member, but build() tests membership against the
//! enum's NAME strings (`CharacterGroup._member_names_`), which never matches a
//! member — the grouped-etch branch is dead code, pending_chars stays empty,
//! and the effect emits exactly one frame. Verified against the pinned
//! reference (`laseretch --etch-pattern row_top_to_bottom` -> frames=1).
//! Reproduced faithfully; only "algorithm" (the default) etches.
//!
//! No observable set iteration beyond the engine-canonical active_characters
//! (docs/ordering-inventory.md): `color_shifted_chars` is created but never
//! used upstream, and the pool's available queue is a deque.

use std::collections::{HashMap, VecDeque};

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_non_negative_int, parse_positive_int,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::particles::{ParticlePool, ParticleReset};
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::spanning_tree::RecursiveBacktracker;

/// Callback id: sparks_pool.reclaim(spark, hide=True, deactivate=True).
const CB_RECLAIM_SPARK: u32 = 0;

/// --etch-pattern accepts either a CharacterGroup name or the literal
/// "algorithm" (upstream `_etch_pattern_type_parser` dual-type parser).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EtchPattern {
    Group(CharacterGroup),
    Algorithm,
}

fn parse_etch_pattern(s: &str) -> Result<EtchPattern, String> {
    if s == "algorithm" {
        return Ok(EtchPattern::Algorithm);
    }
    crate::effects::common::parse_character_group(s).map(EtchPattern::Group)
}

#[derive(Args, Debug, Clone)]
pub struct LaserEtchConfig {
    /// Pattern used to etch the text.
    #[arg(long = "etch-pattern", default_value = "algorithm", value_parser = parse_etch_pattern)]
    pub etch_pattern: EtchPattern,

    /// Along with etch_delay, determines the speed at which the characters are etched onto the terminal. This value specifies the number of characters to etch simultaneously.
    #[arg(long = "etch-speed", default_value_t = 1, value_parser = parse_positive_int)]
    pub etch_speed: i64,

    /// Along with etch_speed, determines the speed at which the characters are etched onto the terminal. This values specifies the number of frames to wait before etching the next set of characters.
    #[arg(long = "etch-delay", default_value_t = 1, value_parser = parse_non_negative_int)]
    pub etch_delay: i64,

    /// Space separated, unquoted, list of colors for the gradient used to cool the characters after etching.
    #[arg(long = "cool-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ffe680", "ff7b00"])]
    pub cool_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, list of colors for the laser gradient.
    #[arg(long = "laser-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ffffff", "376cff"])]
    pub laser_gradient_stops: Vec<Color>,

    /// Space separated, unquoted, list of colors for the spark cooling gradient.
    #[arg(long = "spark-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ffffff", "ffe680", "ff7b00", "1a0900"])]
    pub spark_gradient_stops: Vec<Color>,

    /// Number of frames to display each spark cooling gradient step. Increase to slow down the rate of cooling.
    #[arg(long = "spark-cooling-frames", default_value_t = 7, value_parser = parse_positive_int)]
    pub spark_cooling_frames: i64,

    /// Space separated, unquoted, list of colors for the character gradient (applied across the canvas).
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "ffffff"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["8"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step. Increase to slow down the gradient animation.
    #[arg(long = "final-gradient-frames", default_value_t = 4, value_parser = parse_positive_int)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// LaserEtchIterator.Laser state (methods live on LaserEtch for hooks access).
struct Laser {
    position: Coord,
    beam_chars: Vec<CharId>,
    spark_gradient: Gradient,
    sparks_pool: ParticlePool,
}

/// Laser._make_sparks_pool initialize_sparks closure.
fn initialize_spark(ctx: &mut EngineCtx, spark: CharId, spark_colors: &[Color], cooling_frames: i64) {
    let ch = &mut ctx.terminal.arena[spark.0 as usize];
    ch.layer = 2;
    let input_symbol = ch.input_symbol.clone();
    let uses_pre = ch.uses_input_preexisting_colors;
    let spark_scn = ch.animation.new_scene(false, None, None, "spark", uses_pre);
    let scene = ch.animation.scenes.get_mut(&spark_scn).unwrap();
    for color in spark_colors {
        scene
            .add_frame(
                &input_symbol,
                cooling_frames,
                VisualParams { colors: Some(ColorPair::new(Some(color.clone()), None)), ..Default::default() },
            )
            .expect("spark frame");
    }
}

/// LaserEtchIterator._has_input_colors.
fn has_input_colors(ctx: &EngineCtx, id: CharId) -> bool {
    let anim = &ctx.terminal.arena[id.0 as usize].animation;
    anim.input_fg_color.is_some() || anim.input_bg_color.is_some()
}

pub struct LaserEtch {
    config: LaserEtchConfig,
    character_final_color_map: HashMap<CharId, ColorPair>,
    pending_chars: Vec<CharId>,
    char_delay: i64,
    laser: Option<Laser>,
}

impl LaserEtch {
    pub fn new(config: LaserEtchConfig) -> Self {
        LaserEtch {
            config,
            character_final_color_map: HashMap::new(),
            pending_chars: Vec::new(),
            char_delay: 0,
            laser: None,
        }
    }

    /// Laser.__init__ (+ _make_sparks_pool). The pool is created BEFORE the
    /// beam characters, matching upstream's character_id allocation order.
    fn make_laser(&mut self, ctx: &mut EngineCtx) -> Result<Laser, EngineError> {
        let mut laser_gradient: VecDeque<Color> =
            Gradient::new(&self.config.laser_gradient_stops, &[6], true, true)
                .map_err(EngineError::Other)?
                .spectrum
                .into();
        let spark_gradient = Gradient::new(&self.config.spark_gradient_stops, &[3, 8], false, false)
            .map_err(EngineError::Other)?;

        // Laser._make_sparks_pool
        let mut sparks_pool =
            ParticlePool::new(vec![".".to_string(), ",".to_string(), "*".to_string()], None, None)
                .map_err(EngineError::Other)?;
        let spark_colors = spark_gradient.spectrum.clone();
        let cooling_frames = self.config.spark_cooling_frames;
        sparks_pool
            .preallocate(ctx, 2000, |ctx, spark| initialize_spark(ctx, spark, &spark_colors, cooling_frames))
            .map_err(EngineError::Other)?;
        for &spark in &sparks_pool.particles {
            ctx.register_event(
                spark,
                Event::SceneComplete,
                CallerKey::Scene("spark".to_string()),
                EventAction::Callback(EffectCallback { id: CB_RECLAIM_SPARK, args: Vec::new() }),
            )
            .map_err(EngineError::Other)?;
        }

        // beam characters up the diagonal from (0, 0)
        let mut row: i64 = 0;
        let mut col: i64 = 0;
        let mut beam_chars: Vec<CharId> = Vec::new();
        while row <= ctx.terminal.canvas.top {
            let symbol = if beam_chars.is_empty() { "*" } else { "/" };
            let char_id = ctx.terminal.add_character(symbol, Coord::new(col, row));
            ctx.terminal.arena[char_id.0 as usize].layer = 2;
            ctx.terminal.set_character_visibility(char_id, true);
            row += 1;
            col += 1;
            beam_chars.push(char_id);
            {
                let ch = &mut ctx.terminal.arena[char_id.0 as usize];
                let input_symbol = ch.input_symbol.clone();
                let uses_pre = ch.uses_input_preexisting_colors;
                let laser_scn = ch.animation.new_scene(true, None, None, "laser", uses_pre);
                let scene = ch.animation.scenes.get_mut(&laser_scn).unwrap();
                for color in laser_gradient.iter() {
                    scene
                        .add_frame(
                            &input_symbol,
                            3,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
            // deque.rotate(-1)
            if let Some(front) = laser_gradient.pop_front() {
                laser_gradient.push_back(front);
            }
            ctx.activate_scene(self, char_id, "laser");
        }
        Ok(Laser { position: Coord::new(0, 0), beam_chars, spark_gradient, sparks_pool })
    }

    /// Laser.reposition.
    fn laser_reposition(&mut self, ctx: &mut EngineCtx, target: Coord) {
        let mut laser = self.laser.take().expect("laser missing");
        laser.position = target;
        let mut row = target.row;
        let mut col = target.column;
        for &char_id in &laser.beam_chars {
            ctx.terminal.arena[char_id.0 as usize].motion.set_coordinate(Coord::new(col, row));
            row += 1;
            col += 1;
        }
        self.laser_emit_sparks(ctx, &mut laser, 1);
        self.laser = Some(laser);
    }

    /// Laser.emit_sparks (+ its setup_spark_path closure).
    fn laser_emit_sparks(&mut self, ctx: &mut EngineCtx, laser: &mut Laser, spark_count: usize) {
        let spark_colors = laser.spark_gradient.spectrum.clone();
        let cooling_frames = self.config.spark_cooling_frames;
        let position = laser.position;
        let bottom = ctx.terminal.canvas.bottom;
        for _ in 0..spark_count {
            laser.sparks_pool.emit(
                ctx,
                position,
                None,
                true,
                ParticleReset::default(),
                |ctx, spark| initialize_spark(ctx, spark, &spark_colors, cooling_frames),
                |ctx, spark| {
                    // setup_spark_path
                    ctx.terminal.arena[spark.0 as usize].motion.set_coordinate(position);
                    let spark_path = ctx.terminal.arena[spark.0 as usize]
                        .motion
                        .new_path(0.3, Some(Easing::OutSine), None, 0, false, "")
                        .expect("spark path");
                    let fall_target_coord =
                        Coord::new(ctx.rng.randint(position.column - 20, position.column + 20), bottom);
                    let control = Coord::new(fall_target_coord.column, position.row + ctx.rng.randint(-10, 20));
                    ctx.terminal.arena[spark.0 as usize]
                        .motion
                        .paths
                        .get_mut(&spark_path)
                        .unwrap()
                        .new_waypoint(fall_target_coord, Some(vec![control]), "")
                        .expect("spark waypoint");
                    ctx.activate_path(self, spark, &spark_path);
                    ctx.activate_scene(self, spark, "spark");
                },
            );
        }
    }

    /// Laser.disable.
    fn laser_disable(&mut self, ctx: &mut EngineCtx) {
        let beam_chars = self.laser.as_ref().expect("laser missing").beam_chars.clone();
        for char_id in beam_chars {
            ctx.terminal.set_character_visibility(char_id, false);
        }
    }
}

impl EffectHooks for LaserEtch {
    fn dispatch_callback(&mut self, ctx: &mut EngineCtx, character: CharId, callback: &EffectCallback) {
        if callback.id == CB_RECLAIM_SPARK {
            if let Some(laser) = self.laser.as_mut() {
                laser.sparks_pool.reclaim(ctx, character, true, true);
            }
        }
    }
}

impl Effect for LaserEtch {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // LaserEtchIterator.build
        let final_fg_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_fg_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            let (input_coord, input_symbol, input_fg, input_bg, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (
                    ch.input_coord,
                    ch.input_symbol.clone(),
                    ch.animation.input_fg_color.clone(),
                    ch.animation.input_bg_color.clone(),
                    ch.uses_input_preexisting_colors,
                )
            };
            let (final_fg_color, final_bg_color, cool_gradient) = if dynamic {
                let pair = ColorPair::new(input_fg, input_bg);
                self.character_final_color_map.insert(id, pair.clone());
                let cool = Gradient::with_steps(&self.config.cool_gradient_stops, 8, false)
                    .map_err(EngineError::Other)?;
                (pair.fg_color, pair.bg_color, cool)
            } else {
                let mapped = final_gradient_mapping.get(&input_coord).unwrap().clone();
                let pair = ColorPair::new(Some(mapped.clone()), None);
                self.character_final_color_map.insert(id, pair.clone());
                let mut stops = self.config.cool_gradient_stops.clone();
                stops.push(mapped);
                let cool = Gradient::with_steps(&stops, 8, false).map_err(EngineError::Other)?;
                (pair.fg_color, pair.bg_color, cool)
            };
            // gradients for the dynamic tail, built before borrowing the scene
            let cool_last = cool_gradient.spectrum.last().unwrap().clone();
            let mut fg_gradient: Option<Gradient> = None;
            let mut bg_gradient: Option<Gradient> = None;
            let mut white_cooldown: Option<Gradient> = None;
            if dynamic {
                if final_fg_color.is_some() || final_bg_color.is_some() {
                    if let Some(fg) = &final_fg_color {
                        fg_gradient = Some(
                            Gradient::with_steps(&[cool_last.clone(), fg.clone()], 8, false)
                                .map_err(EngineError::Other)?,
                        );
                    }
                    if let Some(bg) = &final_bg_color {
                        bg_gradient = Some(
                            Gradient::with_steps(&[cool_last.clone(), bg.clone()], 8, false)
                                .map_err(EngineError::Other)?,
                        );
                    }
                } else {
                    white_cooldown = Some(
                        Gradient::with_steps(&[cool_last.clone(), Color::from_hex("ffffff").unwrap()], 8, false)
                            .map_err(EngineError::Other)?,
                    );
                }
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let spawn_scn = ch.animation.new_scene(false, None, None, "spawn", uses_pre);
                let scene = ch.animation.scenes.get_mut(&spawn_scn).unwrap();
                scene
                    .add_frame(
                        "^",
                        3,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(Color::from_hex("ffe680").unwrap()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                for color in &cool_gradient.spectrum {
                    scene
                        .add_frame(
                            &input_symbol,
                            3,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
                if dynamic {
                    if final_fg_color.is_some() || final_bg_color.is_some() {
                        scene
                            .apply_gradient_to_symbols(
                                &[input_symbol.clone()],
                                3,
                                fg_gradient.as_ref(),
                                bg_gradient.as_ref(),
                            )
                            .map_err(EngineError::Other)?;
                    } else {
                        scene
                            .apply_gradient_to_symbols(&[input_symbol.clone()], 3, white_cooldown.as_ref(), None)
                            .map_err(EngineError::Other)?;
                        scene
                            .add_frame(
                                &input_symbol,
                                3,
                                VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
            }
            ctx.activate_scene(self, id, "spawn");
        }
        match self.config.etch_pattern {
            EtchPattern::Group(_) => {
                // Dead upstream branch — see module docs. pending_chars stays empty.
            }
            EtchPattern::Algorithm => {
                let mut algo = RecursiveBacktracker::new(ctx, None, true).map_err(EngineError::Other)?;
                while !algo.complete {
                    algo.step(ctx);
                }
                self.pending_chars = algo.char_link_order;
            }
        }

        // LaserEtchIterator.__init__ tail
        self.char_delay = 0;
        let laser = self.make_laser(ctx)?;
        for &id in &laser.beam_chars {
            ctx.active_characters.insert(id);
        }
        self.laser = Some(laser);
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.pending_chars.is_empty() && ctx.active_characters.is_empty() {
            return None;
        }
        if self.char_delay == 0 {
            for _ in 0..self.config.etch_speed {
                if self.pending_chars.is_empty() {
                    break;
                }
                let mut next_char = self.pending_chars.remove(0);
                while ctx.terminal.arena[next_char.0 as usize].input_symbol == " "
                    && !has_input_colors(ctx, next_char)
                {
                    if !self.pending_chars.is_empty() {
                        next_char = self.pending_chars.remove(0);
                    } else {
                        break;
                    }
                }
                ctx.terminal.set_character_visibility(next_char, true);
                ctx.active_characters.insert(next_char);
                let target = ctx.terminal.arena[next_char.0 as usize].input_coord;
                self.laser_reposition(ctx, target);
            }
            self.char_delay = self.config.etch_delay;
        } else {
            self.char_delay -= 1;
        }
        if !self.pending_chars.is_empty() {
            let beam_chars = self.laser.as_ref().expect("laser missing").beam_chars.clone();
            for id in beam_chars {
                ctx.active_characters.insert(id);
            }
        } else {
            self.laser_disable(ctx);
        }
        ctx.update(self);
        Some(ctx.frame())
    }
}
