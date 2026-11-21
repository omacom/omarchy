//! bubbles, ported from effects/effect_bubbles.py.

use std::collections::HashMap;

use clap::Args;

use crate::cli::parse_color;
use crate::effects::common::{
    parse_easing, parse_gradient_direction, parse_gradient_steps, parse_positive_float, parse_positive_int,
};
use crate::engine::animation::{ExistingColorHandling, VisualParams};
use crate::engine::character::CharId;
use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::effect::Effect;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, EffectCallback, Event, EventAction};
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

/// pop_condition choices.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PopCondition {
    Row,
    Bottom,
    Anywhere,
}

fn parse_pop_condition(s: &str) -> Result<PopCondition, String> {
    Ok(match s {
        "row" => PopCondition::Row,
        "bottom" => PopCondition::Bottom,
        "anywhere" => PopCondition::Anywhere,
        _ => return Err(format!("invalid choice: '{s}' (choose from 'row', 'bottom', 'anywhere')")),
    })
}

#[derive(Args, Debug, Clone)]
pub struct BubblesConfig {
    /// If set, the bubbles will be colored with a rotating rainbow gradient.
    #[arg(long = "rainbow", default_value_t = false)]
    pub rainbow: bool,

    /// Space separated, unquoted, list of colors for the bubbles. Ignored if --no-rainbow is left as default False.
    #[arg(long = "bubble-colors", num_args = 1.., value_parser = parse_color,
          default_values = ["d33aff", "7395c4", "43c2a7", "02ff7f"])]
    pub bubble_colors: Vec<Color>,

    /// Color for the spray emitted when a bubble pops.
    #[arg(long = "pop-color", default_value = "ffffff", value_parser = parse_color)]
    pub pop_color: Color,

    /// Speed of the floating bubbles.
    #[arg(long = "bubble-speed", default_value_t = 0.5, value_parser = parse_positive_float)]
    pub bubble_speed: f64,

    /// Number of frames between bubbles.
    #[arg(long = "bubble-delay", default_value_t = 20, value_parser = parse_positive_int)]
    pub bubble_delay: i64,

    /// Condition for a bubble to pop.
    #[arg(long = "pop-condition", default_value = "row", value_parser = parse_pop_condition)]
    pub pop_condition: PopCondition,

    /// Easing function to use for character movement after a bubble pops.
    #[arg(long = "movement-easing", default_value = "in_out_sine", value_parser = parse_easing)]
    pub movement_easing: Easing,

    /// Space separated, unquoted, list of colors for the final color gradient.
    #[arg(long = "final-gradient-stops", num_args = 1.., value_parser = parse_color,
          default_values = ["d33aff", "02ff7f"])]
    pub final_gradient_stops: Vec<Color>,

    /// Number of gradient steps to use.
    #[arg(long = "final-gradient-steps", num_args = 1.., value_parser = parse_gradient_steps,
          default_values = ["12"])]
    pub final_gradient_steps: Vec<i64>,

    /// Direction of the final gradient.
    #[arg(long = "final-gradient-direction", default_value = "diagonal", value_parser = parse_gradient_direction)]
    pub final_gradient_direction: GradientDirection,
}

/// BubblesIterator.Bubble state (methods live on Bubbles for hooks access).
struct Bubble {
    characters: Vec<CharId>,
    radius: i64,
    anchor_char: CharId,
    lowest_row: i64,
    landed: bool,
}

pub struct Bubbles {
    config: BubblesConfig,
    bubbles: Vec<Bubble>,
    animating_bubbles: Vec<Bubble>,
    rainbow_gradient: Gradient,
    character_final_color_map: HashMap<CharId, Color>,
    steps_since_last_bubble: i64,
}

impl Bubbles {
    pub fn new(config: BubblesConfig) -> Self {
        let rainbow_stops = [
            Color::from_hex("e81416").unwrap(), // red
            Color::from_hex("ffa500").unwrap(), // orange
            Color::from_hex("faeb36").unwrap(), // yellow
            Color::from_hex("79c314").unwrap(), // green
            Color::from_hex("487de7").unwrap(), // blue
            Color::from_hex("4b369d").unwrap(), // indigo
            Color::from_hex("70369d").unwrap(), // violet
        ];
        let rainbow_gradient = Gradient::with_steps(&rainbow_stops, 5, false).expect("rainbow gradient");
        Bubbles {
            config,
            bubbles: Vec::new(),
            animating_bubbles: Vec::new(),
            rainbow_gradient,
            character_final_color_map: HashMap::new(),
            steps_since_last_bubble: 0,
        }
    }

    /// Bubble.set_character_coordinates.
    fn bubble_set_character_coordinates(&mut self, ctx: &mut EngineCtx, bubble: &mut Bubble) {
        let anchor_coord = ctx.terminal.arena[bubble.anchor_char.0 as usize].motion.current_coord;
        let points = geometry::find_coords_on_circle(
            anchor_coord,
            bubble.radius,
            bubble.characters.len() as i64,
            false,
        );
        for (i, &id) in bubble.characters.iter().enumerate() {
            let point = points[i];
            ctx.terminal.arena[id.0 as usize].motion.set_coordinate(point);
            if point.row == bubble.lowest_row {
                bubble.landed = true;
            }
        }
        if self.config.pop_condition == PopCondition::Anywhere && ctx.rng.random() < 0.002 {
            bubble.landed = true;
        }
    }

    /// Bubble.__init__ (+ make_waypoints + make_gradients).
    fn make_bubble(
        &mut self,
        ctx: &mut EngineCtx,
        origin: Coord,
        characters: Vec<CharId>,
    ) -> Result<Bubble, EngineError> {
        let radius = std::cmp::max(characters.len() as i64 / 5, 1);
        let anchor_char = ctx.terminal.add_character(" ", origin);
        let lowest_row = if self.config.pop_condition == PopCondition::Row {
            characters.iter().map(|&id| ctx.terminal.arena[id.0 as usize].input_coord.row).min().unwrap()
        } else {
            ctx.terminal.canvas.bottom
        };
        let mut bubble = Bubble { characters, radius, anchor_char, lowest_row, landed: false };
        self.bubble_set_character_coordinates(ctx, &mut bubble);
        bubble.landed = false;
        // make_waypoints
        let waypoint_column = ctx.rng.randint(ctx.terminal.canvas.left, ctx.terminal.canvas.right);
        let floor_path = {
            let ch = &mut ctx.terminal.arena[bubble.anchor_char.0 as usize];
            let path_id = ch
                .motion
                .new_path(self.config.bubble_speed, None, None, 0, false, "")
                .map_err(EngineError::Other)?;
            ch.motion
                .paths
                .get_mut(&path_id)
                .unwrap()
                .new_waypoint(Coord::new(waypoint_column, bubble.lowest_row), None, "")
                .map_err(EngineError::Other)?;
            path_id
        };
        ctx.activate_path(self, bubble.anchor_char, &floor_path);
        // make_gradients
        if self.config.rainbow {
            let mut rainbow_gradient: Vec<Color> = self.rainbow_gradient.spectrum.clone();
            let mut gradient_offset: usize = 0;
            for &id in &bubble.characters {
                let (input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                let sheen_scene = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                    let scene = ch.animation.scenes.get_mut(&scene_id).unwrap();
                    for step in &rainbow_gradient {
                        scene
                            .add_frame(
                                &input_symbol,
                                4,
                                VisualParams {
                                    colors: Some(ColorPair::new(Some(step.clone()), None)),
                                    ..Default::default()
                                },
                            )
                            .map_err(EngineError::Other)?;
                    }
                    scene_id
                };
                gradient_offset += 2;
                gradient_offset %= rainbow_gradient.len();
                let mut rotated = rainbow_gradient[gradient_offset..].to_vec();
                rotated.extend_from_slice(&rainbow_gradient[..gradient_offset]);
                rainbow_gradient = rotated;
                ctx.activate_scene(self, id, &sheen_scene);
                let active_scene = ctx.terminal.arena[id.0 as usize].animation.active_scene.clone();
                if let Some(scene_id) = active_scene {
                    ctx.terminal.arena[id.0 as usize]
                        .animation
                        .scenes
                        .get_mut(&scene_id)
                        .unwrap()
                        .is_looping = true;
                }
            }
        } else {
            let bubble_color = ctx.rng.choice(&self.config.bubble_colors).clone();
            for &id in &bubble.characters {
                let (input_symbol, uses_pre) = {
                    let ch = &ctx.terminal.arena[id.0 as usize];
                    (ch.input_symbol.clone(), ch.uses_input_preexisting_colors)
                };
                let sheen_scene = {
                    let ch = &mut ctx.terminal.arena[id.0 as usize];
                    let scene_id = ch.animation.new_scene(false, None, None, "", uses_pre);
                    ch.animation
                        .scenes
                        .get_mut(&scene_id)
                        .unwrap()
                        .add_frame(
                            &input_symbol,
                            1,
                            VisualParams {
                                colors: Some(ColorPair::new(Some(bubble_color.clone()), None)),
                                ..Default::default()
                            },
                        )
                        .map_err(EngineError::Other)?;
                    scene_id
                };
                ctx.activate_scene(self, id, &sheen_scene);
            }
        }
        Ok(bubble)
    }

    /// Bubble.pop.
    fn bubble_pop(&mut self, ctx: &mut EngineCtx, bubble: &Bubble) {
        let anchor_coord = ctx.terminal.arena[bubble.anchor_char.0 as usize].motion.current_coord;
        let points = geometry::find_coords_on_circle(
            anchor_coord,
            bubble.radius + 3,
            bubble.characters.len() as i64,
            true,
        );
        // zip(characters, points) — truncates at the shorter sequence
        for (&id, &point) in bubble.characters.iter().zip(points.iter()) {
            {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let pop_out_path = ch
                    .motion
                    .new_path(0.3, Some(Easing::OutExpo), None, 0, false, "pop_out")
                    .expect("pop_out path");
                ch.motion
                    .paths
                    .get_mut(&pop_out_path)
                    .unwrap()
                    .new_waypoint(point, None, "")
                    .expect("pop_out waypoint");
            }
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path("pop_out".to_string()),
                EventAction::ActivatePath("final".to_string()),
            )
            .expect("pop_out event");
        }
        for &id in &bubble.characters {
            ctx.activate_scene(self, id, "pop_1");
            ctx.activate_path(self, id, "pop_out");
        }
    }

    /// Bubble.move.
    fn bubble_move(&mut self, ctx: &mut EngineCtx, bubble: &mut Bubble) {
        ctx.motion_move(self, bubble.anchor_char);
        self.bubble_set_character_coordinates(ctx, bubble);
        for i in 0..bubble.characters.len() {
            let id = bubble.characters[i];
            ctx.step_animation(self, id);
        }
    }
}

impl EffectHooks for Bubbles {
    fn dispatch_callback(&mut self, _ctx: &mut EngineCtx, _character: CharId, _callback: &EffectCallback) {}
}

impl Effect for Bubbles {
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
            self.character_final_color_map
                .insert(id, final_gradient_mapping.get(&input_coord).unwrap().clone());
            ctx.terminal.arena[id.0 as usize].layer = 1;
            let (pop_1_scene, pop_2_scene) = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let pop_1 = ch.animation.new_scene(false, None, None, "pop_1", uses_pre);
                let pop_2 = ch.animation.new_scene(false, None, None, "", uses_pre);
                ch.animation
                    .scenes
                    .get_mut(&pop_1)
                    .unwrap()
                    .add_frame(
                        "*",
                        9,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(self.config.pop_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                ch.animation
                    .scenes
                    .get_mut(&pop_2)
                    .unwrap()
                    .add_frame(
                        "'",
                        9,
                        VisualParams {
                            colors: Some(ColorPair::new(Some(self.config.pop_color.clone()), None)),
                            ..Default::default()
                        },
                    )
                    .map_err(EngineError::Other)?;
                (pop_1, pop_2)
            };
            let final_scene = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation.new_scene(false, None, None, "", uses_pre)
            };
            if dynamic {
                let fg_gradient = match &input_fg {
                    Some(fg) => Some(
                        Gradient::with_steps(&[self.config.pop_color.clone(), fg.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let bg_gradient = match &input_bg {
                    Some(bg) => Some(
                        Gradient::with_steps(&[self.config.pop_color.clone(), bg.clone()], 8, false)
                            .map_err(EngineError::Other)?,
                    ),
                    None => None,
                };
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let scene = ch.animation.scenes.get_mut(&final_scene).unwrap();
                if fg_gradient.is_some() || bg_gradient.is_some() {
                    scene
                        .apply_gradient_to_symbols(
                            &[input_symbol.clone()],
                            6,
                            fg_gradient.as_ref(),
                            bg_gradient.as_ref(),
                        )
                        .map_err(EngineError::Other)?;
                } else {
                    scene
                        .add_frame(
                            &input_symbol,
                            6,
                            VisualParams { colors: Some(ColorPair::default()), ..Default::default() },
                        )
                        .map_err(EngineError::Other)?;
                }
            } else {
                let final_color = self.character_final_color_map.get(&id).unwrap().clone();
                let char_final_gradient =
                    Gradient::with_steps(&[self.config.pop_color.clone(), final_color], 8, false)
                        .map_err(EngineError::Other)?;
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                ch.animation
                    .scenes
                    .get_mut(&final_scene)
                    .unwrap()
                    .apply_gradient_to_symbols(&[input_symbol.clone()], 6, Some(&char_final_gradient), None)
                    .map_err(EngineError::Other)?;
            }
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(pop_1_scene),
                EventAction::ActivateScene(pop_2_scene.clone()),
            )
            .map_err(EngineError::Other)?;
            ctx.register_event(
                id,
                Event::SceneComplete,
                CallerKey::Scene(pop_2_scene),
                EventAction::ActivateScene(final_scene),
            )
            .map_err(EngineError::Other)?;
            let final_path = {
                let ch = &mut ctx.terminal.arena[id.0 as usize];
                let path_id = ch
                    .motion
                    .new_path(0.3, Some(Easing::InOutExpo), None, 0, false, "final")
                    .map_err(EngineError::Other)?;
                ch.motion
                    .paths
                    .get_mut(&path_id)
                    .unwrap()
                    .new_waypoint(input_coord, None, "")
                    .map_err(EngineError::Other)?;
                path_id
            };
            ctx.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(final_path),
                EventAction::SetLayer(0),
            )
            .map_err(EngineError::Other)?;
        }

        let mut unbubbled_chars: Vec<CharId> = Vec::new();
        for char_list in
            ctx.terminal.get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowBottomToTop)
        {
            unbubbled_chars.extend(char_list);
        }
        self.bubbles = Vec::new();
        while !unbubbled_chars.is_empty() {
            let mut bubble_group: Vec<CharId> = Vec::new();
            if unbubbled_chars.len() < 5 {
                bubble_group.append(&mut unbubbled_chars);
            } else {
                let count = ctx.rng.randint(5, std::cmp::min(unbubbled_chars.len() as i64, 20));
                for _ in 0..count {
                    bubble_group.push(unbubbled_chars.remove(0));
                }
            }
            let bubble_origin = Coord::new(
                ctx.rng.randint(ctx.terminal.canvas.left, ctx.terminal.canvas.right),
                ctx.terminal.canvas.top + 10,
            );
            let new_bubble = self.make_bubble(ctx, bubble_origin, bubble_group)?;
            self.bubbles.push(new_bubble);
        }
        self.animating_bubbles = Vec::new();
        self.steps_since_last_bubble = 0;
        Ok(())
    }

    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String> {
        if !self.animating_bubbles.is_empty() || !ctx.active_characters.is_empty() || !self.bubbles.is_empty() {
            if !self.bubbles.is_empty() && self.steps_since_last_bubble >= self.config.bubble_delay {
                let next_bubble = self.bubbles.remove(0);
                for &id in &next_bubble.characters {
                    ctx.terminal.set_character_visibility(id, true);
                }
                self.animating_bubbles.push(next_bubble);
                self.steps_since_last_bubble = 0;
            }
            self.steps_since_last_bubble += 1;

            let mut animating = std::mem::take(&mut self.animating_bubbles);
            for bubble in &animating {
                if bubble.landed {
                    self.bubble_pop(ctx, bubble);
                    for &id in &bubble.characters {
                        ctx.active_characters.insert(id);
                    }
                }
            }
            animating.retain(|bubble| !bubble.landed);
            for bubble in &mut animating {
                self.bubble_move(ctx, bubble);
            }
            self.animating_bubbles = animating;

            ctx.update(self);
            return Some(ctx.frame());
        }
        None
    }
}
