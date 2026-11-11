//! vhstape, ported from effects/effect_vhstape.py.
//!
//! The inner VHSTapeIterator.Line class is the `Line` struct; lines live in a
//! Vec indexed by row_index (the upstream `lines` dict has keys 0..n-1 in
//! insertion order), and the wave/glitch line lists hold indices (upstream
//! holds Line objects compared by identity). The glitch budget counts frames
//! (`_glitching_steps_elapsed`) — no clock reads. No observable set iteration
//! beyond the engine-canonical active_characters (docs/ordering-inventory.md).

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_gradient_direction, parse_gradient_steps, parse_non_negative_ratio, parse_positive_int,
};
use crate::engine::animation::{ExistingColorHandling, SyncMetric, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};
use crate::utils::pycompat::round_half_even;

#[derive(Args, Debug, Clone)]
pub struct VhsTapeConfig {
    /// Space separated, unquoted, list of colors for the characters when a single line is glitching. Colors are applied in order as an animation.
    #[arg(long = "glitch-line-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["ffffff", "ff0000", "00ff00", "0000ff", "ffffff"])]
    pub glitch_line_colors: Vec<Color>,

    /// Space separated, unquoted, list of colors for the characters in lines that are part of the glitch wave. Colors are applied in order as an animation.
    #[arg(long = "glitch-wave-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["ffffff", "ff0000", "00ff00", "0000ff", "ffffff"])]
    pub glitch_wave_colors: Vec<Color>,

    /// Space separated, unquoted, list of colors for the characters during the noise phase.
    #[arg(long = "noise-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["1e1e1f", "3c3b3d", "6d6c70", "a2a1a6", "cbc9cf", "ffffff"])]
    pub noise_colors: Vec<Color>,

    /// Chance that a line will glitch on any given frame.
    #[arg(long = "glitch-line-chance", default_value_t = 0.05, value_parser = parse_non_negative_ratio)]
    pub glitch_line_chance: f64,

    /// Chance that all characters will experience noise on any given frame.
    #[arg(long = "noise-chance", default_value_t = 0.004, value_parser = parse_non_negative_ratio)]
    pub noise_chance: f64,

    /// Total time, frames, that the glitching phase will last.
    #[arg(long = "total-glitch-time", default_value_t = 600, value_parser = parse_positive_int)]
    pub total_glitch_time: i64,

    /// Space separated, unquoted, list of colors for the final color gradient. If only one color is provided, the characters will be displayed in that color.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["ab48ff", "e7b2b2", "fffebd"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "vertical", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// VHSTapeIterator.Line state (methods live on VhsTape for hooks access).
struct Line {
    characters: Vec<CharId>,
}

/// __next__ phase strings.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Glitching,
    Noise,
    Redraw,
    Complete,
}

pub struct VhsTape {
    config: VhsTapeConfig,
    lines: Vec<Line>,
    /// Upstream `active_glitch_wave_top: int | None`.
    active_glitch_wave_top: Option<i64>,
    /// Indices into `lines` (upstream holds Line objects, identity-compared).
    active_glitch_wave_lines: Vec<usize>,
    active_glitch_lines: Vec<usize>,
    character_stable_color_map: HashMap<CharId, ColorPair>,
    character_final_color_map: HashMap<CharId, ColorPair>,
    glitching_steps_elapsed: i64,
    phase: Phase,
    to_redraw: Vec<usize>,
    redrawing: bool,
}

impl VhsTape {
    pub fn new(config: VhsTapeConfig) -> Self {
        VhsTape {
            config,
            lines: Vec::new(),
            active_glitch_wave_top: None,
            active_glitch_wave_lines: Vec::new(),
            active_glitch_lines: Vec::new(),
            character_stable_color_map: HashMap::new(),
            character_final_color_map: HashMap::new(),
            glitching_steps_elapsed: 0,
            phase: Phase::Glitching,
            to_redraw: Vec::new(),
            redrawing: false,
        }
    }

    /// Line.build_line_effects — one offset/direction/hold_time draw per line,
    /// then paths, scenes (snow draws 25x2, final_snow 30x2), and events per
    /// character.
    fn build_line_effects(&mut self, ctx: &mut EngineCtx, characters: &[CharId]) -> Result<(), EngineError> {
        let glitch_line_colors = self.config.glitch_line_colors.clone();
        let snow_chars = ["#", "*", ".", ":"];
        let noise_colors = self.config.noise_colors.clone();
        let offset = ctx.rng.randint(4, 25);
        let direction = *ctx.rng.choice(&[-1i64, 1]);
        let hold_time = ctx.rng.randint(1, 50);
        for &id in characters {
            let (input_coord, input_symbol, uses_pre) = {
                let ch = &ctx.terminal.arena[id.0 as usize];
                (ch.input_coord, ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
            };
            let stable_colors = self.character_stable_color_map.get(&id).unwrap().clone();
            let final_colors = self.character_final_color_map.get(&id).unwrap().clone();
            // make glitch and restore waypoints + glitch wave waypoints
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let glitch_path =
                    ch.motion.new_path(2.0, None, None, hold_time, false, "glitch").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&glitch_path)
                    .unwrap()
                    .new_waypoint(
                        Coord::new(input_coord.column + offset * direction, input_coord.row),
                        None,
                        "glitch",
                    )
                    .map_err(EngineError::Other)?;
                let restore_path =
                    ch.motion.new_path(2.0, None, None, 0, false, "restore").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&restore_path)
                    .unwrap()
                    .new_waypoint(input_coord, None, "restore")
                    .map_err(EngineError::Other)?;
                let mid_path =
                    ch.motion.new_path(2.0, None, None, 0, false, "glitch_wave_mid").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&mid_path)
                    .unwrap()
                    .new_waypoint(Coord::new(input_coord.column + 8, input_coord.row), None, "glitch_wave_mid")
                    .map_err(EngineError::Other)?;
                let end_path =
                    ch.motion.new_path(2.0, None, None, 0, false, "glitch_wave_end").map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&end_path)
                    .unwrap()
                    .new_waypoint(Coord::new(input_coord.column + 14, input_coord.row), None, "glitch_wave_end")
                    .map_err(EngineError::Other)?;
            }
            // make glitch scenes
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let base_scn = ch.animation.new_scene(false, None, None, "base", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&base_scn)
                    .unwrap()
                    .add_frame(
                        &input_symbol,
                        1,
                        VisualParams { colors: Some(stable_colors.clone()), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
                let fwd_scn =
                    ch.animation.new_scene(false, Some(SyncMetric::Step), None, "rgb_glitch_fwd", uses_pre);
                let scene = ch.animation.scenes.get_mut(&fwd_scn).unwrap();
                for color in &glitch_line_colors {
                    scene
                        .add_frame(
                            &input_symbol,
                            1,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
                let bwd_scn =
                    ch.animation.new_scene(false, Some(SyncMetric::Step), None, "rgb_glitch_bwd", uses_pre);
                let scene = ch.animation.scenes.get_mut(&bwd_scn).unwrap();
                for color in glitch_line_colors.iter().rev() {
                    scene
                        .add_frame(
                            &input_symbol,
                            1,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                }
                ch.animation.new_scene(false, None, None, "snow", uses_pre);
            }
            for _ in 0..25 {
                let symbol = *ctx.rng.choice(&snow_chars);
                let color = ctx.rng.choice(&noise_colors).clone();
                ctx.terminal.arena[id.0 as usize]
                    .animation
                    .scenes
                    .get_mut("snow")
                    .unwrap()
                    .add_frame(
                        symbol,
                        2,
                        VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut("snow")
                    .unwrap()
                    .add_frame(
                        &input_symbol,
                        1,
                        VisualParams { colors: Some(stable_colors.clone()), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
                ch.animation.new_scene(false, None, None, "final_snow", uses_pre);
                let redraw_scn = ch.animation.new_scene(false, None, None, "final_redraw", uses_pre);
                let scene = ch.animation.scenes.get_mut(&redraw_scn).unwrap();
                scene
                    .add_frame(
                        "█",
                        6,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(Color::from_hex("ffffff").unwrap()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                scene
                    .add_frame(&input_symbol, 1, VisualParams { colors: Some(final_colors), ..Default::default() })
                    .map_err(EngineError::Other)?;
            }
            for _ in 0..30 {
                let symbol = *ctx.rng.choice(&snow_chars);
                let color = ctx.rng.choice(&noise_colors).clone();
                ctx.terminal.arena[id.0 as usize]
                    .animation
                    .scenes
                    .get_mut("final_snow")
                    .unwrap()
                    .add_frame(
                        symbol,
                        2,
                        VisualParams { colors: Some(ColorPair::new(Some(color), None)), ..Default::default() },
                    )
                    .map_err(EngineError::Other)?;
            }
            // register events
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("glitch".to_string()),
                EventAction::ActivatePath("restore".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathActivated,
                CallerKey::Path("glitch".to_string()),
                EventAction::ActivateScene("rgb_glitch_fwd".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathActivated,
                CallerKey::Path("restore".to_string()),
                EventAction::ActivateScene("rgb_glitch_bwd".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathActivated,
                CallerKey::Path("glitch_wave_mid".to_string()),
                EventAction::ActivateScene("rgb_glitch_fwd".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::PathActivated,
                CallerKey::Path("glitch_wave_end".to_string()),
                EventAction::ActivateScene("rgb_glitch_fwd".to_string()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene("rgb_glitch_bwd".to_string()),
                EventAction::ActivateScene("base".to_string()),
            )
            .map_err(EngineError::Other)?;
        }
        Ok(())
    }

    /// Line.snow.
    fn line_snow(&mut self, ctx: &mut EngineCtx, idx: usize) {
        let characters = self.lines[idx].characters.clone();
        for id in characters {
            ctx.activate_scene(self, id, "snow");
        }
    }

    /// Line.set_hold_time.
    fn line_set_hold_time(&mut self, ctx: &mut EngineCtx, idx: usize, hold_time: i64) {
        for &id in &self.lines[idx].characters {
            ctx.terminal.arena[id.0 as usize].motion.paths.get_mut("glitch").expect("glitch path").hold_time =
                hold_time;
        }
    }

    /// Line.glitch.
    fn line_glitch(&mut self, ctx: &mut EngineCtx, idx: usize, final_: bool) {
        let characters = self.lines[idx].characters.clone();
        for id in characters {
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                if final_ {
                    ch.motion.paths.get_mut("glitch").expect("glitch path").hold_time = 0;
                    ch.motion.paths.get_mut("restore").expect("restore path").hold_time = 0;
                }
            }
            let glitch_speed = 40.0 / ctx.rng.randint(20, 40) as f64;
            let restore_speed = 40.0 / ctx.rng.randint(20, 40) as f64;
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.motion.paths.get_mut("glitch").expect("glitch path").speed = glitch_speed;
                ch.motion.paths.get_mut("restore").expect("restore path").speed = restore_speed;
            }
            ctx.activate_path(self, id, "glitch");
        }
    }

    /// Line.restore.
    fn line_restore(&mut self, ctx: &mut EngineCtx, idx: usize) {
        let characters = self.lines[idx].characters.clone();
        for id in characters {
            let restore_speed = 40.0 / ctx.rng.randint(20, 40) as f64;
            ctx.terminal.arena[id.0 as usize].motion.paths.get_mut("restore").expect("restore path").speed =
                restore_speed;
            ctx.activate_path(self, id, "restore");
        }
    }

    /// Line.activate_path.
    fn line_activate_path(&mut self, ctx: &mut EngineCtx, idx: usize, path_id: &str) {
        let characters = self.lines[idx].characters.clone();
        for id in characters {
            ctx.activate_path(self, id, path_id);
        }
    }

    /// Line.line_movement_complete.
    fn line_movement_complete(&self, ctx: &EngineCtx, idx: usize) -> bool {
        self.lines[idx].characters.iter().all(|&id| ctx.terminal.arena[id.0 as usize].motion.movement_is_complete())
    }

    fn insert_line_characters(&self, ctx: &mut EngineCtx, idx: usize) {
        for &id in &self.lines[idx].characters {
            ctx.active_characters.insert(id);
        }
    }

    /// VHSTapeIterator.glitch_wave.
    fn glitch_wave(&mut self, ctx: &mut EngineCtx) {
        // Python falsy check: None (0 is unreachable after the max(2, ...) clamp
        // but kept falsy for exactness).
        if matches!(self.active_glitch_wave_top, None | Some(0)) {
            if ctx.terminal.canvas.text_height >= 3 {
                // choose a wave top index in the top half of the canvas or at least 3 rows up
                let lower = std::cmp::max(3, round_half_even(ctx.terminal.canvas.text_height as f64 * 0.5));
                self.active_glitch_wave_top = Some(
                    ctx.terminal.canvas.text_bottom + ctx.rng.randint(lower, ctx.terminal.canvas.text_height),
                );
            } else {
                // not enough room for a wave
                return;
            }
        }

        // if all lines have completed movement, proceed to move/restore wave
        let all_complete =
            self.active_glitch_wave_lines.iter().all(|&idx| self.line_movement_complete(ctx, idx));
        if all_complete {
            if !self.active_glitch_wave_lines.is_empty() {
                // only move 30% of the time — the OUTER conditional's condition is
                // evaluated first (second textual random() call in the source)
                let should_move = ctx.rng.random() < 0.3;
                let wave_top_delta =
                    if should_move { if ctx.rng.random() < 0.3 { 1 } else { -1 } } else { 0 };
                let mut top = self.active_glitch_wave_top.unwrap() + wave_top_delta;
                // clamp wave top to canvas
                top = std::cmp::max(2, std::cmp::min(top, ctx.terminal.canvas.text_top));
                self.active_glitch_wave_top = Some(top);
            }
            // get the lines for the wave
            let wave_top = self.active_glitch_wave_top.unwrap();
            let mut new_wave_lines: Vec<usize> = Vec::new();
            for line_index in (wave_top - 2)..=wave_top {
                let adjusted_line_index = line_index - (ctx.terminal.canvas.text_bottom - 1);
                if adjusted_line_index >= 0 && (adjusted_line_index as usize) < self.lines.len() {
                    new_wave_lines.push(adjusted_line_index as usize);
                }
            }

            // restore any lines that are no longer part of the wave
            let old_wave_lines = std::mem::take(&mut self.active_glitch_wave_lines);
            for &idx in &old_wave_lines {
                if !new_wave_lines.contains(&idx) {
                    self.line_restore(ctx, idx);
                    self.insert_line_characters(ctx, idx);
                }
            }
            self.active_glitch_wave_lines = new_wave_lines;

            if wave_top < ctx.terminal.canvas.text_bottom + 2 {
                // wave at bottom, restore lines
                let wave_lines = std::mem::take(&mut self.active_glitch_wave_lines);
                for &idx in &wave_lines {
                    self.line_restore(ctx, idx);
                    self.insert_line_characters(ctx, idx);
                }
                self.active_glitch_wave_top = None;
            } else {
                let path_ids = ["glitch_wave_mid", "glitch_wave_end", "glitch_wave_mid"];
                let wave_lines = self.active_glitch_wave_lines.clone();
                for (idx, path_id) in wave_lines.iter().zip(path_ids.iter()) {
                    self.line_activate_path(ctx, *idx, path_id);
                    self.insert_line_characters(ctx, *idx);
                }
            }
        }
    }
}

impl EffectHooks for VhsTape {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for VhsTape {
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
        for id in characters {
            let ch = &ctx.terminal.arena[id.0 as usize];
            if dynamic {
                let input_fg = ch.animation.input_fg_color.clone();
                let input_bg = ch.animation.input_bg_color.clone();
                // DYNAMIC_NEUTRAL_GRAY
                let stable_fg = input_fg.clone().or_else(|| Some(Color::from_hex("808080").unwrap()));
                self.character_stable_color_map.insert(id, ColorPair::new(stable_fg, input_bg.clone()));
                self.character_final_color_map.insert(id, ColorPair::new(input_fg, input_bg));
            } else {
                let gradient_color = final_gradient_mapping.get(&ch.input_coord).unwrap().clone();
                let stable_colors = ColorPair::new(Some(gradient_color), None);
                self.character_stable_color_map.insert(id, stable_colors.clone());
                self.character_final_color_map.insert(id, stable_colors);
            }
        }
        let rows = ctx
            .terminal
            .get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowBottomToTop);
        for characters in rows {
            self.build_line_effects(ctx, &characters)?;
            self.lines.push(Line { characters });
        }
        let characters = {
            let filter = CharacterFilter::default();
            ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
        };
        for id in characters {
            ctx.terminal.set_character_visibility(id, true);
            ctx.activate_scene(self, id, "base");
        }
        self.glitching_steps_elapsed = 0;
        self.phase = Phase::Glitching;
        self.to_redraw = (0..self.lines.len()).collect();
        self.redrawing = false;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if self.phase == Phase::Complete && ctx.active_characters.is_empty() {
            return None;
        }
        match self.phase {
            Phase::Glitching => {
                // Check if all active glitch wave lines have completed their movement, if so move the wave
                if self.active_glitch_wave_lines.is_empty()
                    || self.active_glitch_wave_lines.iter().all(|&idx| self.line_movement_complete(ctx, idx))
                {
                    self.glitch_wave(ctx);
                }
                // Remove completed glitch lines from active glitch lines
                let glitch_lines = std::mem::take(&mut self.active_glitch_lines);
                self.active_glitch_lines =
                    glitch_lines.into_iter().filter(|&idx| !self.line_movement_complete(ctx, idx)).collect();
                // Randomly add new glitch lines
                if ctx.rng.random() < self.config.glitch_line_chance && self.active_glitch_lines.len() < 3 {
                    let glitch_line = ctx.rng.choice_index(self.lines.len());
                    if !self.active_glitch_wave_lines.contains(&glitch_line)
                        && !self.active_glitch_lines.contains(&glitch_line)
                    {
                        let hold_time = ctx.rng.randint(20, 75);
                        self.line_set_hold_time(ctx, glitch_line, hold_time);
                        self.active_glitch_lines.push(glitch_line);
                        self.line_glitch(ctx, glitch_line, false);
                        self.insert_line_characters(ctx, glitch_line);
                    }
                }
                // Randomly add noise to all lines
                if ctx.rng.random() < self.config.noise_chance {
                    for idx in 0..self.lines.len() {
                        self.line_snow(ctx, idx);
                        if !self.active_glitch_wave_lines.contains(&idx)
                            && !self.active_glitch_lines.contains(&idx)
                        {
                            self.insert_line_characters(ctx, idx);
                        }
                    }
                }
                self.glitching_steps_elapsed += 1;
                // Check if glitching time has reached the total glitch time
                if self.glitching_steps_elapsed >= self.config.total_glitch_time {
                    // Restore glitch wave lines
                    let wave_lines = self.active_glitch_wave_lines.clone();
                    for idx in wave_lines {
                        self.line_restore(ctx, idx);
                    }
                    // Restore glitch lines
                    let glitch_lines = self.active_glitch_lines.clone();
                    for idx in glitch_lines {
                        self.line_restore(ctx, idx);
                    }
                    self.phase = Phase::Noise;
                }
            }
            Phase::Noise => {
                // Activate final snow animation for all characters
                if ctx.active_characters.is_empty() {
                    let characters = {
                        let filter = CharacterFilter::default();
                        ctx.terminal.get_characters(&mut ctx.rng, filter, CharacterSort::TopToBottomLeftToRight)
                    };
                    for id in characters {
                        ctx.activate_scene(self, id, "final_snow");
                        ctx.active_characters.insert(id);
                    }
                    self.phase = Phase::Redraw;
                }
            }
            Phase::Redraw => {
                // Redraw lines one by one
                if self.redrawing || ctx.active_characters.is_empty() {
                    self.redrawing = true;
                    if let Some(next_line) = self.to_redraw.pop() {
                        let characters = self.lines[next_line].characters.clone();
                        for id in characters {
                            ctx.activate_scene(self, id, "final_redraw");
                            ctx.active_characters.insert(id);
                        }
                    } else {
                        self.phase = Phase::Complete;
                    }
                }
            }
            Phase::Complete => {}
        }
        ctx.update(self);
        Some(ctx.frame())
    }
}
