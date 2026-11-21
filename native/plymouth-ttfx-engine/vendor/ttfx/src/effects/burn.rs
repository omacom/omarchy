//! burn, ported from effects/effect_burn.py.
//!
//! RNG order mirrors BurnIterator.__init__: PrimsSimple construction (random
//! starting coord) first, then the smoke ParticlePool preallocation (2000
//! symbol choice() draws), then the build() body (algo run to completion),
//! then per-frame randint(2, 4) + smoke emission draws.
//!
//! No new observable set iterations: char_link_order and the pool's available
//! deque are ordered upstream lists; BreadthFirst is not used here
//! (docs/ordering-inventory.md unchanged).

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{parse_gradient_direction, parse_gradient_steps, parse_non_negative_ratio};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallbackValue, CallerKey, EffectCallback, Event, EventAction};
use crate::engine::particles::{ParticlePool, ParticleReset};
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::spanning_tree::PrimsSimple;

/// Callback id: EventHandler.Callback(lambda c: self._emit_smoke(c.input_coord, ...)).
const CB_EMIT_SMOKE: u32 = 0;
/// Callback id: ParticlePool.reclaim_on_event's reclaim closure.
const CB_RECLAIM_SMOKE: u32 = 1;

#[derive(Args, Debug, Clone)]
pub struct BurnConfig {
    /// Color of the characters before they start to burn.
    #[arg(long = "starting-color", default_value = "837373", value_parser = parse_color)]
    pub starting_color: Color,

    /// Colors transitioned through as the characters burn.
    #[arg(long = "burn-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["ffffff", "fff75d", "fe650d", "8A003C", "510100"])]
    pub burn_colors: Vec<Color>,

    /// Chance a given character will produce smoke while burning. Use 0 for no smoke.
    #[arg(long = "smoke-chance", default_value_t = 0.5, value_parser = parse_non_negative_ratio)]
    pub smoke_chance: f64,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["00c3ff", "ffff1c"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

const BURN_CHAR_ORDER: [&str; 9] = ["'", ".", "▖", "▙", "█", "▜", "▀", "▝", "."];
const SMOKE_SYMBOLS: [&str; 6] = [".", ",", "'", "`", "#", "*"];

pub struct Burn {
    config: BurnConfig,
    character_final_color_map: HashMap<CharId, Color>,
    /// PrimsSimple.char_link_order, consumed FIFO in next_frame.
    char_link_order: Vec<CharId>,
    /// Option so _emit_smoke can move the pool out of self while the on_emit
    /// closure needs &mut self for event dispatch (see emit_smoke).
    smoke_particles: Option<ParticlePool>,
    /// Makes each reclaim Callback registration unique, mirroring Python's
    /// fresh closure object per reclaim_on_event call (identity inequality
    /// lets registrations accumulate upstream instead of raising
    /// DuplicateEventRegistrationError; firing reclaim repeatedly is
    /// idempotent, so behavior is identical).
    emission_counter: i64,
}

impl Burn {
    pub fn new(config: BurnConfig) -> Self {
        Burn {
            config,
            character_final_color_map: HashMap::new(),
            char_link_order: Vec::new(),
            smoke_particles: None,
            emission_counter: 0,
        }
    }

    /// BurnIterator._has_input_colors.
    fn has_input_colors(ctx: &EngineCtx, id: CharId) -> bool {
        let anim = &ctx.terminal.arena[id.0 as usize].animation;
        anim.input_fg_color.is_some() || anim.input_bg_color.is_some()
    }

    /// BurnIterator._is_burnable.
    fn is_burnable(&self, ctx: &EngineCtx, id: CharId) -> bool {
        ctx.terminal.arena[id.0 as usize].input_symbol != " "
            || (ctx.terminal.config.existing_color_handling != ExistingColorHandling::Ignore
                && Self::has_input_colors(ctx, id))
    }

    /// BurnIterator._make_smoke_pool's initialize_smoke: one reusable "smoke"
    /// scene (10-frame 504F4F->C7C7C7 fade) and layer 2. Passed to every pool
    /// call; runs only for newly created particles.
    fn initialize_smoke(ctx: &mut EngineCtx, id: CharId) {
        let (input_symbol, uses_pre) = {
            let ch = &ctx.terminal.arena[id.0 as usize];
            (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
        };
        let gradient = Gradient::with_steps(
            &[Color::from_hex("504F4F").unwrap(), Color::from_hex("C7C7C7").unwrap()],
            9,
            false,
        )
        .expect("smoke gradient");
        let ch = &mut ctx.terminal.arena[id.0 as usize];
        let smoke_scn = ch.animation.new_scene(false, None, None, "smoke", uses_pre);
        let scene = ch.animation.scenes.get_mut(&smoke_scn).unwrap();
        for color in &gradient.spectrum {
            scene
                .add_frame(
                    &input_symbol,
                    10,
                    VisualParams { colors: Some(ColorPair::new(Some(color.clone()), None)), ..Default::default() },
                )
                .expect("smoke frame");
        }
        ch.layer = 2;
    }

    /// BurnIterator._emit_smoke.
    fn emit_smoke(&mut self, ctx: &mut EngineCtx, origin: Coord) {
        if ctx.rng.random() > self.config.smoke_chance {
            return;
        }
        // ParticleReset(clear_paths=True, deactivate_path=True,
        // deactivate_scene=True) == the upstream defaults.
        let reset = ParticleReset::default();
        self.emission_counter += 1;
        let emission_id = self.emission_counter;
        // Move the pool out of self so the on_emit closure can borrow self as
        // EffectHooks. Safe: on_emit only fires PATH_ACTIVATED/SCENE_ACTIVATED,
        // for which smoke particles never register actions, so CB_RECLAIM_SMOKE
        // cannot dispatch while the pool is out.
        let mut pool = self.smoke_particles.take().expect("smoke pool");
        pool.emit(ctx, origin, None, true, reset, Self::initialize_smoke, |ctx, next_particle| {
            // on_emit_smoke
            ctx.terminal.arena[next_particle.0 as usize]
                .animation
                .scenes
                .get_mut("smoke")
                .expect("smoke scene")
                .reset_scene();
            let smoke_path = ctx.terminal.arena[next_particle.0 as usize]
                .motion
                .new_path(0.5, None, None, 0, false, "")
                .expect("smoke path");
            let rise_target_coord = Coord::new(
                ctx.rng.randint(origin.column - 4, origin.column + 4),
                ctx.terminal.canvas.top + 1,
            );
            ctx.terminal.arena[next_particle.0 as usize]
                .motion
                .paths
                .get_mut(&smoke_path)
                .unwrap()
                .new_waypoint(rise_target_coord, None, "")
                .expect("smoke waypoint");
            ctx.activate_path(self, next_particle, &smoke_path);
            ctx.activate_scene(self, next_particle, "smoke");
            // ParticlePool.reclaim_on_event(next_particle, caller="smoke")
            ctx.register_event(
                next_particle,
                Event::SceneComplete,
                CallerKey::Scene("smoke".to_string()),
                EventAction::Callback(EffectCallback {
                    id: CB_RECLAIM_SMOKE,
                    args: vec![CallbackValue::Int(emission_id)],
                }),
            )
            .expect("register reclaim");
        });
        self.smoke_particles = Some(pool);
    }
}

impl EffectHooks for Burn {
    fn dispatch_callback(&mut self, ctx: &mut EngineCtx, character: CharId, callback: &EffectCallback) {
        match callback.id {
            CB_EMIT_SMOKE => {
                let origin = ctx.terminal.arena[character.0 as usize].input_coord;
                self.emit_smoke(ctx, origin);
            }
            CB_RECLAIM_SMOKE => {
                // reclaim(completed_character, hide=True, deactivate=True)
                self.smoke_particles.as_mut().expect("smoke pool").reclaim(ctx, character, true, true);
            }
            _ => {}
        }
    }
}

impl Effect for Burn {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError> {
        // BurnIterator.__init__ order: PrimsSimple (random starting coord),
        // then the pool preallocation (2000 choice() draws + initializer each).
        let mut algo = PrimsSimple::new(ctx, None, true).map_err(EngineError::Other)?;
        let mut pool =
            ParticlePool::new(SMOKE_SYMBOLS.iter().map(|s| s.to_string()).collect(), Some(2000), None)
                .map_err(EngineError::Other)?;
        pool.preallocate(ctx, 2000, Self::initialize_smoke).map_err(EngineError::Other)?;
        self.smoke_particles = Some(pool);

        // BurnIterator.build()
        let burn_char_order: Vec<String> = BURN_CHAR_ORDER.iter().map(|s| s.to_string()).collect();
        let final_gradient =
            Gradient::new(&self.config.final_gradient_stops, &self.config.final_gradient_steps, false, false)
                .map_err(EngineError::Other)?;
        let final_gradient_mapping = ctx
            .final_gradient_mapping(&final_gradient, self.config.final_gradient_direction)
            .map_err(EngineError::Other)?;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &characters {
            let coord = ctx.terminal.arena[id.0 as usize].input_coord;
            self.character_final_color_map
                .insert(id, final_gradient_mapping.get(&coord).expect("gradient mapping").clone());
        }
        let fire_gradient = Gradient::with_steps(&self.config.burn_colors, 10, false).map_err(EngineError::Other)?;

        while !algo.complete {
            algo.step(ctx);
        }

        let dynamic = ctx.terminal.config.existing_color_handling == ExistingColorHandling::Dynamic;
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for &id in &characters {
            ctx.terminal.set_character_visibility(id, true);
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
                ch.animation.set_appearance(
                    &input_symbol,
                    uses_pre,
                    Some(&input_symbol),
                    Some(ColorPair::new(Some(self.config.starting_color.clone()), None)),
                );
            }
            let burn_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene_id = ch.animation.new_scene(false, None, None, "burn", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&scene_id)
                    .unwrap()
                    .apply_gradient_to_symbols(&burn_char_order, 4, Some(&fire_gradient), None)
                    .map_err(EngineError::Other)?;
                scene_id
            };
            let final_color_scn = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            let fire_last = fire_gradient.spectrum.last().expect("fire gradient spectrum").clone();
            if dynamic {
                let fg_gradient = match &input_fg {
                    Some(fg) => Some(
                        Gradient::with_steps(&[fire_last.clone(), fg.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &input_bg {
                    Some(bg) => Some(
                        Gradient::with_steps(&[fire_last.clone(), bg.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&final_color_scn).unwrap();
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            4,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            4,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                let char_gradient =
                    Gradient::with_steps(&[fire_last, final_color], 8, false).map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&final_color_scn).unwrap();
                for color in &char_gradient.spectrum {
                    scene
                        .add_frame(
                            &input_symbol,
                            4,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
            }
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(burn_scn.clone()),
                EventAction::ActivateScene(final_color_scn),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(burn_scn),
                EventAction::Callback(EffectCallback { id: CB_EMIT_SMOKE, args: Vec::new() }),
            )
            .map_err(EngineError::Other)?;
        }
        self.char_link_order = algo.char_link_order;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.char_link_order.is_empty() || !ctx.active_characters.is_empty() {
            for _ in 0..ctx.rng.randint(2, 4) {
                if !self.char_link_order.is_empty() {
                    let next_char = self.char_link_order.remove(0);
                    if !self.is_burnable(ctx, next_char) {
                        continue;
                    }
                    ctx.activate_scene(self, next_char, "burn");
                    ctx.active_characters.insert(next_char);
                }
            }
            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
