//! thunderstorm, ported from effects/effect_thunderstorm.py.
//!
//! Two ParticlePools (rain + sparks) plus a manually managed strike-character
//! pool (available/pending/active lists). The storm budget reads the injected
//! monotonic clock at exactly the upstream points (__init__:203, fade_complete
//! :390, __next__:719 — plan.md §4.7). Upstream's three character color maps
//! (character_final/visible/storm_color_map) are written but never read, so
//! they are not stored here. `self.flashing` is likewise write-only upstream.
//! No observable set iteration beyond the engine-canonical active_characters
//! (docs/ordering-inventory.md).

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps, parse_positive_int, parse_symbol};
use crate::engine::animation::{Animation, ExistingColorHandling, Scene, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx, NoopHooks};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::particles::{ParticlePool, ParticleReset};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::floor_div;

/// fade_complete (effect_thunderstorm.py:388): phase -> storm, restart clock.
const CB_FADE_COMPLETE: u32 = 0;
/// ThunderstormIterator.hide_character.
const CB_HIDE_CHARACTER: u32 = 1;
/// ThunderstormIterator.make_char_glow.
const CB_MAKE_CHAR_GLOW: u32 = 2;
/// ThunderstormIterator.return_strike_to_pool.
const CB_RETURN_STRIKE_TO_POOL: u32 = 3;
/// ThunderstormIterator.set_strike_in_progress_false.
const CB_SET_STRIKE_IN_PROGRESS_FALSE: u32 = 4;
/// rain_pool.reclaim_on_event closure (particles.py reclaim).
const CB_RECLAIM_RAIN: u32 = 5;
/// spark_pool.reclaim_on_event closure.
const CB_RECLAIM_SPARK: u32 = 6;

#[derive(Args, Debug, Clone)]
pub struct ThunderstormConfig {
    /// Color for the lightning strike.
    #[arg(long = "lightning-color", default_value = "68A3E8", value_parser = parse_color)]
    pub lightning_color: Color,

    /// Color for the text when glowing after a lightning strike.
    #[arg(long = "glowing-text-color", default_value = "EF5411", value_parser = parse_color)]
    pub glowing_text_color: Color,

    /// Number of frames to display each color in the post-lightning text glow cooling gradient. Increase to slow down the cooling animation.
    #[arg(long = "text-glow-time", default_value_t = 6, value_parser = parse_positive_int)]
    pub text_glow_time: i64,

    /// Symbols to use for the raindrops.
    #[arg(long = "raindrop-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["\\", ".", ","])]
    pub raindrop_symbols: Vec<String>,

    /// Symbols to use for the lightning impact sparks.
    #[arg(long = "spark-symbols", num_args = 1.., value_parser = parse_symbol,
          default_values = ["*", ".", "'"])]
    pub spark_symbols: Vec<String>,

    /// Color for the spark glow after a lightning strike.
    #[arg(long = "spark-glow-color", default_value = "ff4d00", value_parser = parse_color)]
    pub spark_glow_color: Color,

    /// Number of frames to display each color in the post-lightning spark cooling gradient. Increase to slow down the cooling animation.
    #[arg(long = "spark-glow-time", default_value_t = 18, value_parser = parse_positive_int)]
    pub spark_glow_time: i64,

    /// Duration, in seconds, the storm will occur.
    #[arg(long = "storm-time", default_value_t = 12, value_parser = parse_positive_int)]
    pub storm_time: i64,

    /// Space separated, unquoted, list of colors for the character gradient (applied across the canvas).
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["8A008A", "00D1FF", "FFFFFF"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Number of frames to display each gradient step. Increase to slow down the gradient animation.
    #[arg(long = "final-gradient-frames", default_value_t = 3, value_parser = parse_positive_int)]
    pub final_gradient_frames: i64,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// self.phase string states.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    PreStorm,
    Waiting,
    Storm,
    Complete,
}

pub struct Thunderstorm {
    config: ThunderstormConfig,
    delay: i64,
    strike_progression_delay: i64,
    rain_pool: ParticlePool,
    pending_strike_chars: Vec<CharId>,
    available_strike_chars: Vec<CharId>,
    active_strike_chars: Vec<CharId>,
    spark_pool: ParticlePool,
    /// Gradient captured by the spark initializer closure (build_spark_pool).
    spark_gradient: Gradient,
    pending_glow_chars: Vec<CharId>,
    strike_in_progress: bool,
    strike_branch_chance: f64,
    phase: Phase,
    storm_start_time: f64,
}

/// ThunderstormIterator._adjust_color_pair_brightness.
fn adjust_color_pair_brightness(colors: &ColorPair, brightness: f64) -> ColorPair {
    ColorPair::new(
        colors.fg_color.as_ref().map(|c| Animation::adjust_color_brightness(c, brightness)),
        colors.bg_color.as_ref().map(|c| Animation::adjust_color_brightness(c, brightness)),
    )
}

/// ThunderstormIterator._add_color_pair_gradient_frames. Faithful quirk: when
/// both endpoint colors exist the gradient list has steps+1 entries but only
/// `range(steps)` of them are emitted as frames.
fn add_color_pair_gradient_frames(
    scene: &mut Scene,
    symbol: &str,
    start_colors: &ColorPair,
    end_colors: &ColorPair,
    steps: i64,
    duration: i64,
) -> Result<(), String> {
    let fg_steps: Vec<Option<Color>> = if start_colors.fg_color.is_some() && end_colors.fg_color.is_some() {
        Gradient::with_steps(
            &[start_colors.fg_color.clone().unwrap(), end_colors.fg_color.clone().unwrap()],
            steps,
            false,
        )?
        .spectrum
        .into_iter()
        .map(Some)
        .collect()
    } else {
        let filler = if end_colors.fg_color.is_some() {
            end_colors.fg_color.clone()
        } else {
            start_colors.fg_color.clone()
        };
        vec![filler; steps as usize]
    };
    let bg_steps: Vec<Option<Color>> = if start_colors.bg_color.is_some() && end_colors.bg_color.is_some() {
        Gradient::with_steps(
            &[start_colors.bg_color.clone().unwrap(), end_colors.bg_color.clone().unwrap()],
            steps,
            false,
        )?
        .spectrum
        .into_iter()
        .map(Some)
        .collect()
    } else {
        let filler = if end_colors.bg_color.is_some() {
            end_colors.bg_color.clone()
        } else {
            start_colors.bg_color.clone()
        };
        vec![filler; steps as usize]
    };
    for index in 0..steps as usize {
        scene.add_frame(
            symbol,
            duration,
            VisualParams {
                colors: Some(ColorPair::new(fg_steps[index].clone(), bg_steps[index].clone())),
                ..Default::default()
            },
        )?;
    }
    Ok(())
}

/// build_rain_pool's initialize_raindrop.
fn initialize_raindrop(ctx: &mut EngineCtx, id: CharId) {
    let ch = &mut ctx.terminal.arena[id.0 as usize];
    ch.layer = 1;
    let input_symbol = ch.input_symbol.clone();
    let uses_pre = ch.uses_input_preexisting_colors;
    ch.animation.set_appearance(
        &input_symbol,
        uses_pre,
        Some(&input_symbol),
        Some(ColorPair::new(Some(Color::from_hex("aaaaff").unwrap()), None)),
    );
}

/// build_spark_pool's _build_spark_characters.
fn initialize_spark(ctx: &mut EngineCtx, id: CharId, spark_gradient: &Gradient, spark_glow_time: i64) {
    let ch = &mut ctx.terminal.arena[id.0 as usize];
    ch.layer = 2;
    let input_symbol = ch.input_symbol.clone();
    let uses_pre = ch.uses_input_preexisting_colors;
    let spark_scn = ch.animation.new_scene(false, None, Some(Easing::InCirc), "glow", uses_pre);
    let scene = ch.animation.scenes.get_mut(&spark_scn).unwrap();
    for color in &spark_gradient.spectrum {
        scene
            .add_frame(
                &input_symbol,
                spark_glow_time,
                VisualParams { colors: Some(ColorPair::new(Some(color.clone()), None)), ..Default::default() },
            )
            .expect("spark glow frame failed");
    }
}

/// ThunderstormIterator._setup_raindrop.
fn setup_raindrop(ctx: &mut EngineCtx, id: CharId) {
    let origin = ctx.terminal.arena[id.0 as usize].motion.current_coord;
    let speed = ctx.rng.uniform(0.5, 1.5);
    let canvas_top = ctx.terminal.canvas.top;
    let canvas_bottom = ctx.terminal.canvas.bottom;
    let fall_path = {
        let ch = &mut ctx.terminal.arena[id.0 as usize];
        let path_id = ch.motion.new_path(speed, None, None, 0, false, "").expect("rain new_path failed");
        ch.motion
            .paths
            .get_mut(&path_id)
            .unwrap()
            .new_waypoint(Coord::new(origin.column + canvas_top + 1, canvas_bottom - 1), None, "")
            .expect("rain new_waypoint failed");
        path_id
    };
    // rain_pool.reclaim_on_event(rain_char, fall_path, event=PATH_COMPLETE)
    ctx.register_event(
        id,
        Event::PathComplete,
        CallerKey::Path(fall_path.clone()),
        EventAction::Callback(EffectCallback { id: CB_RECLAIM_RAIN, args: Vec::new() }),
    )
    .expect("rain reclaim registration failed");
    // PATH_ACTIVATED has no registered handlers on the raindrop (events were
    // cleared this emit; only PATH_COMPLETE is registered), so NoopHooks is
    // observably identical to dispatching through the effect.
    ctx.activate_path(&mut NoopHooks, id, &fall_path);
}

/// ThunderstormIterator._setup_sparks_for_impact.
fn setup_sparks_for_impact(ctx: &mut EngineCtx, id: CharId) {
    let impact_coord = ctx.terminal.arena[id.0 as usize].motion.current_coord;
    let speed = ctx.rng.uniform(0.1, 0.25);
    let spark_path = ctx.terminal.arena[id.0 as usize]
        .motion
        .new_path(speed, Some(Easing::OutQuint), None, 30, false, "")
        .expect("spark new_path failed");
    let offset = ctx.rng.randint(4, 20) * *ctx.rng.choice(&[1i64, -1]);
    let spark_target = Coord::new(impact_coord.column + offset, ctx.terminal.canvas.bottom);
    let bezier_column = impact_coord.column - floor_div(impact_coord.column - spark_target.column, 2);
    let bezier_row = ctx.rng.randint(1, ctx.terminal.canvas.top);
    ctx.terminal.arena[id.0 as usize]
        .motion
        .paths
        .get_mut(&spark_path)
        .unwrap()
        .new_waypoint(spark_target, Some(vec![Coord::new(bezier_column, bezier_row)]), "")
        .expect("spark new_waypoint failed");
    // spark_pool.reclaim_on_event(spark_char, "glow", event=SCENE_COMPLETE)
    ctx.register_event(
        id,
        Event::SceneComplete,
        CallerKey::Scene("glow".to_string()),
        EventAction::Callback(EffectCallback { id: CB_RECLAIM_SPARK, args: Vec::new() }),
    )
    .expect("spark reclaim registration failed");
    // SCENE_ACTIVATED / PATH_ACTIVATED have no registered handlers here
    // (events were cleared this emit; only SCENE_COMPLETE is registered).
    ctx.activate_scene(&mut NoopHooks, id, "glow");
    ctx.activate_path(&mut NoopHooks, id, &spark_path);
}

impl Thunderstorm {
    pub fn new(config: ThunderstormConfig) -> Self {
        // build_rain_pool / build_spark_pool construction (preallocation runs
        // in build(), where ctx is available, in upstream __init__ order).
        let rain_pool =
            ParticlePool::new(config.raindrop_symbols.clone(), None, None).expect("raindrop symbols validated by clap");
        let spark_pool = ParticlePool::new(config.spark_symbols.clone(), Some(2000), None)
            .expect("spark symbols validated by clap");
        Thunderstorm {
            config,
            delay: 0,
            strike_progression_delay: 0,
            rain_pool,
            pending_strike_chars: Vec::new(),
            available_strike_chars: Vec::new(),
            active_strike_chars: Vec::new(),
            spark_pool,
            spark_gradient: Gradient { spectrum: Vec::new() },
            pending_glow_chars: Vec::new(),
            strike_in_progress: false,
            strike_branch_chance: 0.05,
            phase: Phase::PreStorm,
            storm_start_time: 0.0,
        }
    }

    /// ThunderstormIterator.build_strike_characters.
    fn build_strike_characters(&mut self, ctx: &mut EngineCtx, count: usize) {
        for _ in 0..count {
            let strike_char = ctx.terminal.add_character("|", Coord::new(1, 1));
            self.available_strike_chars.push(strike_char);
        }
    }

    /// ThunderstormIterator.get_next_strike_char.
    fn get_next_strike_char(&mut self, ctx: &mut EngineCtx) -> CharId {
        if self.available_strike_chars.is_empty() {
            self.build_strike_characters(ctx, 20);
        }
        let strike_char = self.available_strike_chars.pop().unwrap();
        let ch = &mut ctx.terminal.arena[strike_char.0 as usize];
        ch.animation.scenes.clear();
        ch.event_handler.clear();
        strike_char
    }

    /// ThunderstormIterator.setup_lightning_strike (recursive branching).
    fn setup_lightning_strike(&mut self, ctx: &mut EngineCtx, branch_neighbor: Option<CharId>) {
        let mut branch_neighbor = branch_neighbor;
        let (mut column, mut row);
        if let Some(neighbor) = branch_neighbor {
            let coord = ctx.terminal.arena[neighbor.0 as usize].motion.current_coord;
            column = coord.column;
            row = coord.row;
        } else {
            column = ctx.rng.randint(1, ctx.terminal.canvas.right);
            row = ctx.terminal.canvas.top;
        }

        while row >= ctx.terminal.canvas.bottom {
            if self.available_strike_chars.is_empty() {
                self.build_strike_characters(ctx, 20);
            }
            let symbol: &str;
            if let Some(neighbor) = branch_neighbor {
                // Strike characters are all created with input_symbol "|", so
                // the "/" and "\\" arms are unreachable upstream too —
                // transcribed faithfully anyway.
                let neighbor_symbol = ctx.terminal.arena[neighbor.0 as usize].input_symbol.clone();
                if neighbor_symbol == "/" {
                    column += 1;
                    symbol = *ctx.rng.choice(&["|", "\\"]);
                } else if neighbor_symbol == "\\" {
                    column -= 1;
                    symbol = *ctx.rng.choice(&["|", "/"]);
                } else {
                    let delta = *ctx.rng.choice(&[-1i64, 1]);
                    column += delta;
                    symbol = if delta == 1 { "\\" } else { "/" };
                }
            } else {
                symbol = *ctx.rng.choice(&["\\", "/", "|"]);
            }

            let strike_char = self.get_next_strike_char(ctx);
            {
                let ch = &mut ctx.terminal.arena[strike_char.0 as usize];
                ch.motion.set_coordinate(Coord::new(column, row));
                let input_symbol = ch.input_symbol.clone();
                let uses_pre = ch.uses_input_preexisting_colors;
                ch.animation.set_appearance(
                    &input_symbol,
                    uses_pre,
                    Some(symbol),
                    Some(ColorPair::new(Some(self.config.lightning_color.clone()), None)),
                );
            }
            row -= 1;
            if symbol == "\\" {
                column += 1;
            } else if symbol == "/" {
                column -= 1;
            }

            self.pending_strike_chars.push(strike_char);
            // random.random() is always drawn (left operand of `and`).
            if ctx.rng.random() < self.strike_branch_chance && branch_neighbor.is_none() {
                self.strike_branch_chance -= 0.01;
                self.setup_lightning_strike(ctx, Some(strike_char));
            }
            branch_neighbor = None;
        }
        self.strike_branch_chance = 0.05;
    }

    /// ThunderstormIterator.lightning_strike.
    fn lightning_strike(&mut self, ctx: &mut EngineCtx) {
        self.setup_lightning_strike(ctx, None);
        let strike_base_color = self.config.lightning_color.clone();
        let strike_flash_color = Animation::adjust_color_brightness(&strike_base_color, 1.7);
        let strike_gradient = Gradient::with_steps(&[strike_base_color.clone(), strike_flash_color], 7, true)
            .expect("strike gradient failed");
        let fade_gradient = Gradient::with_steps(
            &[strike_base_color, ctx.terminal.config.terminal_background_color.clone()],
            6,
            false,
        )
        .expect("strike fade gradient failed");
        let layer = 1;
        let flash_ease = Easing::CubicBezier(0.0, 1.6, 1.0, ctx.rng.uniform(-0.6, 0.4));
        for &strike_char in &self.pending_strike_chars {
            let symbol =
                ctx.terminal.arena[strike_char.0 as usize].animation.current_character_visual.symbol.clone();
            {
                let ch = &mut ctx.terminal.arena[strike_char.0 as usize];
                let uses_pre = ch.uses_input_preexisting_colors;
                let flash_scn = ch.animation.new_scene(false, None, Some(flash_ease), "flash", uses_pre);
                let scene = ch.animation.scenes.get_mut(&flash_scn).unwrap();
                for color in &strike_gradient.spectrum {
                    scene
                        .add_frame(
                            &symbol,
                            6,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .expect("flash frame failed");
                }
                let fade_scn = ch.animation.new_scene(false, None, None, "fade", uses_pre);
                let scene = ch.animation.scenes.get_mut(&fade_scn).unwrap();
                for color in &fade_gradient.spectrum {
                    scene
                        .add_frame(
                            &symbol,
                            2,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .expect("fade frame failed");
                }
                ch.layer = layer;
            }
            ctx.register_event(
                strike_char,
                Event::SceneComplete,
                CallerKey::Scene("flash".to_string()),
                EventAction::ActivateScene("fade".to_string()),
            )
            .expect("flash->fade registration failed");
            ctx.register_event(
                strike_char,
                Event::SceneComplete,
                CallerKey::Scene("fade".to_string()),
                EventAction::Callback(EffectCallback { id: CB_HIDE_CHARACTER, args: Vec::new() }),
            )
            .expect("hide registration failed");
            ctx.register_event(
                strike_char,
                Event::SceneComplete,
                CallerKey::Scene("fade".to_string()),
                EventAction::Callback(EffectCallback { id: CB_MAKE_CHAR_GLOW, args: Vec::new() }),
            )
            .expect("glow registration failed");
            ctx.register_event(
                strike_char,
                Event::SceneComplete,
                CallerKey::Scene("fade".to_string()),
                EventAction::Callback(EffectCallback { id: CB_RETURN_STRIKE_TO_POOL, args: Vec::new() }),
            )
            .expect("return registration failed");
        }

        let text_chars = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in text_chars {
            ctx.terminal.arena[id.0 as usize]
                .animation
                .scenes
                .get_mut("flash")
                .expect("text flash scene missing")
                .ease = Some(flash_ease);
        }
    }

    /// ThunderstormIterator.step_lightning_strike.
    fn step_lightning_strike(&mut self, ctx: &mut EngineCtx) {
        if self.strike_progression_delay != 0 {
            self.strike_progression_delay -= 1;
            return;
        }
        if !self.pending_strike_chars.is_empty() {
            let batch = ctx.rng.randint(1, 3);
            for _ in 0..batch {
                if self.pending_strike_chars.is_empty() {
                    break;
                }
                let next_strike_char = self.pending_strike_chars.remove(0);
                self.active_strike_chars.push(next_strike_char);
                ctx.terminal.set_character_visibility(next_strike_char, true);
                self.strike_progression_delay = 1;

                // if the last strike_char was activated, activate the sparks
                // and setup the post-fade callback to indicate the strike has
                // ended
                if self.pending_strike_chars.is_empty() {
                    let spark_gradient = self.spark_gradient.clone();
                    let spark_glow_time = self.config.spark_glow_time;
                    let spark_count = ctx.rng.randint(12, 18);
                    for _ in 0..spark_count {
                        let origin = ctx.terminal.arena[self.active_strike_chars.last().unwrap().0 as usize]
                            .motion
                            .current_coord;
                        let _ = self.spark_pool.emit(
                            ctx,
                            origin,
                            None,
                            true,
                            ParticleReset { clear_events: true, ..Default::default() },
                            |ctx, particle| initialize_spark(ctx, particle, &spark_gradient, spark_glow_time),
                            setup_sparks_for_impact,
                        );
                    }
                    ctx.register_event(
                        next_strike_char,
                        Event::SceneComplete,
                        CallerKey::Scene("fade".to_string()),
                        EventAction::Callback(EffectCallback {
                            id: CB_SET_STRIKE_IN_PROGRESS_FALSE,
                            args: Vec::new(),
                        }),
                    )
                    .expect("strike-done registration failed");

                    // activate the flash scene on all strike chars and text
                    let strikes = std::mem::take(&mut self.active_strike_chars);
                    for &strike_char in &strikes {
                        ctx.activate_scene(self, strike_char, "flash");
                        ctx.active_characters.insert(strike_char);
                    }
                    // (take() above already performed active_strike_chars.clear())

                    let text_chars = {
                        let filter = CharacterFilter::default();
                        ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                    };
                    for id in text_chars {
                        ctx.activate_scene(self, id, "flash");
                        ctx.active_characters.insert(id);
                    }
                }
            }
        }
    }

    /// ThunderstormIterator.rain.
    fn rain(&mut self, ctx: &mut EngineCtx) {
        if self.delay != 0 {
            self.delay -= 1;
            return;
        }
        let count = ctx.rng.randint(1, 6);
        for _ in 0..count {
            let spawn_column = ctx.rng.randint(1 - ctx.terminal.canvas.top, ctx.terminal.canvas.right);
            let origin = Coord::new(spawn_column - 1, ctx.terminal.canvas.top + 1);
            let _ = self.rain_pool.emit(
                ctx,
                origin,
                None,
                true,
                ParticleReset { clear_events: true, ..Default::default() },
                initialize_raindrop,
                setup_raindrop,
            );
        }
        self.delay = ctx.rng.randint(1, 7);
    }

    /// ThunderstormIterator.pre_storm_text_fade.
    fn pre_storm_text_fade(&mut self, ctx: &mut EngineCtx) {
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            ctx.activate_scene(self, id, "fade");
            ctx.active_characters.insert(id);
        }
    }

    /// ThunderstormIterator.post_storm_text_fade_in.
    fn post_storm_text_fade_in(&mut self, ctx: &mut EngineCtx) {
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            ctx.activate_scene(self, id, "unfade");
            ctx.active_characters.insert(id);
        }
    }
}

impl EffectHooks for Thunderstorm {
    fn dispatch_callback(&mut self, ctx: &mut EngineCtx, character: CharId, callback: &EffectCallback) {
        match callback.id {
            CB_FADE_COMPLETE => {
                self.phase = Phase::Storm;
                self.storm_start_time = ctx.clock.now_monotonic();
            }
            CB_HIDE_CHARACTER => ctx.terminal.set_character_visibility(character, false),
            CB_MAKE_CHAR_GLOW => {
                let coord = ctx.terminal.arena[character.0 as usize].motion.current_coord;
                if let Some(input_char) = ctx.terminal.get_character_by_input_coord(coord) {
                    if ctx.terminal.arena[input_char.0 as usize].is_visible {
                        ctx.activate_scene(self, input_char, "glow");
                        self.pending_glow_chars.push(input_char);
                    }
                }
            }
            CB_RETURN_STRIKE_TO_POOL => self.available_strike_chars.push(character),
            CB_SET_STRIKE_IN_PROGRESS_FALSE => self.strike_in_progress = false,
            CB_RECLAIM_RAIN => self.rain_pool.reclaim(ctx, character, true, true),
            CB_RECLAIM_SPARK => self.spark_pool.reclaim(ctx, character, true, true),
            _ => {}
        }
    }
}

impl Effect for Thunderstorm {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // __init__ preamble (effect_thunderstorm.py:188-204): pools are
        // preallocated before build() runs, and the storm clock is read once.
        self.rain_pool.preallocate(ctx, 50, initialize_raindrop).map_err(EngineError::Other)?;
        self.spark_gradient = Gradient::with_steps(
            &[self.config.spark_glow_color.clone(), ctx.terminal.config.terminal_background_color.clone()],
            7,
            false,
        )
        .map_err(EngineError::Other)?;
        {
            let spark_gradient = self.spark_gradient.clone();
            let spark_glow_time = self.config.spark_glow_time;
            self.spark_pool
                .preallocate(ctx, 200, |ctx, particle| {
                    initialize_spark(ctx, particle, &spark_gradient, spark_glow_time)
                })
                .map_err(EngineError::Other)?;
        }
        self.storm_start_time = ctx.clock.now_monotonic();

        // build() body
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        self.build_strike_characters(ctx, 200);

        // setup scenes on text characters
        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let dynamic_neutral_gray = Color::from_hex("808080").unwrap();
        let all_chars = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &all_chars {
            let (input_symbol, input_coord, uses_pre, input_fg, input_bg) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (
                    ch.input_symbol.clone(),
                    ch.input_coord,
                    ch.uses_input_preexisting_colors,
                    ch.animation.input_fg_color.clone(),
                    ch.animation.input_bg_color.clone(),
                )
            };
            let (visible_colors, restore_colors) = if dynamic {
                let visible = ColorPair::new(
                    Some(input_fg.clone().unwrap_or_else(|| dynamic_neutral_gray.clone())),
                    input_bg.clone(),
                );
                let restore = ColorPair::new(input_fg.clone(), input_bg.clone());
                (visible, restore)
            } else {
                let visible =
                    ColorPair::new(Some(final_gradient_mapping.get(&input_coord).unwrap().clone()), None);
                (visible.clone(), visible)
            };
            let storm_colors = adjust_color_pair_brightness(&visible_colors, 0.5);
            // upstream stores visible/storm/restore in three maps that are
            // never read back; not stored here.

            // post-strike glow and cool scene
            let glow_fg_gradient = Gradient::with_steps(
                &[self.config.glowing_text_color.clone(), storm_colors.fg_color.clone().expect("storm fg")],
                7,
                false,
            )
            .map_err(EngineError::Other)?;
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let glow_scn = ch.animation.new_scene(false, None, None, "glow", uses_pre);
                let scene = ch.animation.scenes.get_mut(&glow_scn).unwrap();
                for color in &glow_fg_gradient.spectrum {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.text_glow_time,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), storm_colors.bg_color.clone())),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
                if dynamic {
                    scene
                        .add_frame(
                            &input_symbol,
                            self.config.text_glow_time,
                            VisualParams { colors: Some(storm_colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            }

            // fade before storm scene
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let fade_scn = ch.animation.new_scene(false, None, None, "fade", uses_pre);
                if dynamic {
                    let scene = ch.animation.scenes.get_mut(&fade_scn).unwrap();
                    add_color_pair_gradient_frames(scene, &input_symbol, &visible_colors, &storm_colors, 7, 12)
                        .map_err(EngineError::Other)?;
                    scene
                        .add_frame(
                            &input_symbol,
                            12,
                            VisualParams { colors: Some(storm_colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    let fade_gradient = Gradient::with_steps(
                        &[
                            visible_colors.fg_color.clone().expect("visible fg"),
                            storm_colors.fg_color.clone().expect("storm fg"),
                        ],
                        7,
                        false,
                    )
                    .map_err(EngineError::Other)?;
                    let scene = ch.animation.scenes.get_mut(&fade_scn).unwrap();
                    for color in &fade_gradient.spectrum {
                        scene
                            .add_frame(
                                &input_symbol,
                                12,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(color.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
            }

            // unfade scene
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let unfade_scn = ch.animation.new_scene(false, None, None, "unfade", uses_pre);
                if dynamic {
                    let scene = ch.animation.scenes.get_mut(&unfade_scn).unwrap();
                    add_color_pair_gradient_frames(scene, &input_symbol, &storm_colors, &visible_colors, 7, 12)
                        .map_err(EngineError::Other)?;
                    scene
                        .add_frame(
                            &input_symbol,
                            12,
                            VisualParams { colors: Some(visible_colors.clone()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                    if restore_colors != visible_colors {
                        scene
                            .add_frame(
                                &input_symbol,
                                12,
                                VisualParams { colors: Some(restore_colors.clone()), ..Default::default() },
                            )
                            .map_err(EngineError::Other)?;
                    }
                } else {
                    let unfade_gradient: Vec<Color> = Gradient::with_steps(
                        &[
                            visible_colors.fg_color.clone().expect("visible fg"),
                            storm_colors.fg_color.clone().expect("storm fg"),
                        ],
                        7,
                        false,
                    )
                    .map_err(EngineError::Other)?
                    .spectrum
                    .into_iter()
                    .rev()
                    .collect();
                    let scene = ch.animation.scenes.get_mut(&unfade_scn).unwrap();
                    for color in &unfade_gradient {
                        scene
                            .add_frame(
                                &input_symbol,
                                12,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(color.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                }
            }

            // lightning flash scene
            let lightning_flash_color =
                Animation::adjust_color_brightness(visible_colors.fg_color.as_ref().expect("visible fg"), 1.7);
            let flash_gradient = Gradient::with_steps(
                &[storm_colors.fg_color.clone().expect("storm fg"), lightning_flash_color],
                7,
                true,
            )
            .map_err(EngineError::Other)?;
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let strike_scn = ch.animation.new_scene(false, None, None, "flash", uses_pre);
                let scene = ch.animation.scenes.get_mut(&strike_scn).unwrap();
                for color in &flash_gradient.spectrum {
                    scene
                        .add_frame(
                            &input_symbol,
                            6,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), storm_colors.bg_color.clone())),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }

            ctx.terminal.set_character_visibility(id, true);
        }

        // reference character callback: signals the pre-storm fade completed
        let reference_char = all_chars[0];
        ctx.register_event(
            reference_char,
            Event::SceneComplete,
            CallerKey::Scene("fade".to_string()),
            EventAction::Callback(EffectCallback { id: CB_FADE_COMPLETE, args: Vec::new() }),
        )
        .map_err(EngineError::Other)?;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if ctx.active_characters.is_empty() && self.phase == Phase::Complete {
            return None;
        }
        match self.phase {
            Phase::PreStorm => {
                self.pre_storm_text_fade(ctx);
                self.phase = Phase::Waiting;
            }
            Phase::Storm => {
                self.rain(ctx);
                if !self.strike_in_progress && ctx.rng.random() < 0.008 {
                    self.strike_in_progress = true;
                    self.lightning_strike(ctx);
                }
                if self.strike_in_progress {
                    self.step_lightning_strike(ctx);
                }

                for &glow_char in &self.pending_glow_chars {
                    ctx.active_characters.insert(glow_char);
                }
                self.pending_glow_chars.clear();
                if ctx.clock.now_monotonic() - self.storm_start_time >= self.config.storm_time as f64
                    && !self.strike_in_progress
                {
                    self.post_storm_text_fade_in(ctx);
                    self.phase = Phase::Complete;
                }
            }
            Phase::Waiting | Phase::Complete => {}
        }
        ctx.update(self);
        Some(ctx.frame())
    }
}
