//! bubbles on the fx engine (old engine: effects/bubbles.rs).
//!
//! A bubble is a run of characters (rows bottom to top) around an invisible
//! anchor character whose path carries it to the floor; every move places the
//! characters on a circle around the anchor. A circle's offsets depend only on
//! (radius, count), so they are computed once: a point is then the same float
//! expression the old engine evaluates, without the trigonometry. A bubble
//! whose anchor did not move keeps its points (and whether one is on the
//! floor). The rainbow sheen scene is made looping up front: the old engine
//! sets is_looping right after activating it, and activation does not read the
//! flag.

use std::collections::HashMap;

use crate::effects::bubbles::{BubblesConfig, PopCondition};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, Visual};
use crate::utils::easing::Easing;
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::round_half_even;

const RAINBOW_STOPS: [&str; 7] = [
    "e81416", "ffa500", "faeb36", "79c314", "487de7", "4b369d", "70369d",
];
const POP_SPEED: f64 = 0.3;
const POP_CHANCE: f64 = 0.002;

/// BubblesIterator.Bubble.
struct Bubble {
    /// The characters: `chars[start..start + n]`.
    start: u32,
    n: u32,
    anchor: u32,
    lowest_row: i64,
    landed: bool,
    /// The circle's offsets in `Bubbles::circles`, and the pop circle's
    /// (radius + 3).
    circle: u32,
    pop_circle: u32,
    /// The anchor coordinate the characters were placed around last, and
    /// whether a point of that circle is on lowest_row.
    placed_at: Coord,
    on_floor: bool,
}

pub struct Bubbles {
    config: BubblesConfig,
    chars: Vec<u32>,
    bubbles: Vec<Bubble>,
    /// The next bubble to release, and the floating ones (indexes).
    next: usize,
    animating: Vec<u32>,
    steps_since_last_bubble: i64,
    /// Circle offsets (radius * cos, radius * sin) by angle; `circle_index`
    /// maps (radius, count) to the first.
    circles: Vec<(f64, f64)>,
    circle_index: HashMap<(i64, u32), u32, FxBuild>,
    pop_1: Name,
    pop_out: Name,
    final_: Name,
}

impl Bubbles {
    pub fn new(config: BubblesConfig) -> Self {
        Bubbles {
            config,
            chars: Vec::new(),
            bubbles: Vec::new(),
            next: 0,
            animating: Vec::new(),
            steps_since_last_bubble: 0,
            circles: Vec::new(),
            circle_index: HashMap::default(),
            pop_1: Name::NONE,
            pop_out: Name::NONE,
            final_: Name::NONE,
        }
    }

    /// The offsets of find_coords_on_circle(_, radius, count).
    fn circle(&mut self, radius: i64, count: u32) -> u32 {
        if let Some(&start) = self.circle_index.get(&(radius, count)) {
            return start;
        }
        let start = self.circles.len() as u32;
        let angle_step = 2.0 * std::f64::consts::PI / count as f64;
        for i in 0..count {
            let angle = angle_step * i as f64;
            self.circles
                .push((radius as f64 * angle.cos(), radius as f64 * angle.sin()));
        }
        self.circle_index.insert((radius, count), start);
        start
    }

    /// Bubble.set_character_coordinates.
    fn set_character_coordinates(&mut self, e: &mut Engine, b: u32) {
        let bubble = self.bubbles.at_mut(b);
        let anchor = *e.ch.coord.at(bubble.anchor);
        if anchor != bubble.placed_at {
            bubble.placed_at = anchor;
            let (column, row) = (anchor.column as f64, anchor.row as f64);
            let circle = &self.circles[bubble.circle as usize..(bubble.circle + bubble.n) as usize];
            let chars = &self.chars[bubble.start as usize..(bubble.start + bubble.n) as usize];
            let mut on_floor = false;
            for (&slot, &(dx, dy)) in chars.iter().zip(circle) {
                let mut x = column + dx;
                let x_diff = x - column;
                x += x_diff;
                let point = Coord::new(round_half_even(x), round_half_even(row + dy));
                if *e.ch.coord.at(slot) != point {
                    e.set_coordinate(slot, point);
                }
                on_floor |= point.row == bubble.lowest_row;
            }
            bubble.on_floor = on_floor;
        }
        if bubble.on_floor {
            bubble.landed = true;
        }
        if self.config.pop_condition == PopCondition::Anywhere && e.rng.random() < POP_CHANCE {
            bubble.landed = true;
        }
    }

    /// Bubble.pop.
    fn pop(&mut self, e: &mut Engine, b: u32) {
        let bubble = self.bubbles.at(b);
        let (start, n) = (bubble.start as usize, bubble.n as usize);
        let anchor = e.coord(bubble.anchor);
        let circle = bubble.pop_circle as usize;
        // find_coords_on_circle(unique=True) zipped with the characters
        let (column, row) = (anchor.column as f64, anchor.row as f64);
        let mut points = [Coord::new(0, 0); 20];
        let mut unique = 0;
        for &(dx, dy) in &self.circles[circle..circle + n] {
            let mut x = column + dx;
            let x_diff = x - column;
            x += x_diff;
            let point = Coord::new(round_half_even(x), round_half_even(row + dy));
            if !points[..unique].contains(&point) {
                points[unique] = point;
                unique += 1;
            }
        }
        for (k, &point) in points[..unique].iter().enumerate() {
            let slot = self.chars[start + k];
            let path = e
                .path_new(
                    slot,
                    POP_SPEED,
                    Some(Easing::OutExpo),
                    None,
                    0,
                    false,
                    self.pop_out,
                )
                .expect("pop_out path");
            e.path_new_waypoint(path, point, None, Name::NONE)
                .expect("pop_out waypoint");
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(self.pop_out),
                Action::ActivatePath(self.final_),
            )
            .expect("pop_out event");
        }
        let (pop_1, pop_out) = (self.pop_1, self.pop_out);
        for k in start..start + n {
            let slot = self.chars[k];
            e.activate_scene_name(self, slot, pop_1);
            e.activate_path_name(self, slot, pop_out);
        }
        for k in start..start + n {
            e.active_insert(self.chars[k]);
        }
    }

    /// Bubble.move.
    fn move_bubble(&mut self, e: &mut Engine, b: u32) {
        let anchor = self.bubbles.at(b).anchor;
        e.motion_move(self, anchor);
        self.set_character_coordinates(e, b);
        let bubble = self.bubbles.at(b);
        for k in bubble.start..bubble.start + bubble.n {
            let slot = *self.chars.at(k);
            e.step_animation(self, slot);
        }
    }
}

impl Hooks for Bubbles {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Bubbles {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let rainbow_stops: Vec<Color> = RAINBOW_STOPS
            .iter()
            .map(|h| Color::from_hex(h).unwrap())
            .collect();
        let rainbow = Gradient::with_steps(&rainbow_stops, 5, false)
            .expect("rainbow gradient")
            .spectrum;
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let canvas = e.canvas.clone();
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
        self.pop_1 = e.name("pop_1");
        self.pop_out = e.name("pop_out");
        self.final_ = e.name("final");
        let pop_color = config.pop_color;
        let pop_visual = |e: &mut Engine, symbol: &str| {
            let sym = e.sym(symbol);
            e.visuals.make(
                &e.symbols,
                VisualInfo {
                    sym,
                    fg: Some(pop_color),
                    bg: None,
                    attrs: HAS_COLORS,
                },
            )
        };
        let star = pop_visual(e, "*");
        let tick = pop_visual(e, "'");
        let pop_spectrum = |color: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[pop_color, color], 8, false)
                .map_err(other)?
                .spectrum)
        };
        // (input symbol, final color) -> the final frames of a plain scene
        let mut final_memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();

        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for &slot in &characters {
            let input_coord = e.input_coord(slot);
            let sym = e.input_sym(slot);
            e.set_layer(slot, 1);
            let pop_1_scene = e.scene_new(slot, self.pop_1, false, None, None);
            let pop_2_scene = e.scene_new(slot, Name::NONE, false, None, None);
            e.add_frame_visual(pop_1_scene, star, 9).map_err(other)?;
            e.add_frame_visual(pop_2_scene, tick, 9).map_err(other)?;
            let final_scene = e.scene_new(slot, Name::NONE, false, None, None);
            if dynamic {
                let fg = e.input_fg(slot).map(pop_spectrum).transpose()?;
                let bg = e.input_bg(slot).map(pop_spectrum).transpose()?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(final_scene, &[sym], 6, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(final_scene, sym, 6, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_color = *final_gradient_mapping.get(&input_coord).unwrap();
                let plain = e.scene(final_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match final_memo.get(&(sym, final_color)) {
                    Some(frames) if plain => e.append_frames(final_scene, frames),
                    _ => {
                        let spectrum = pop_spectrum(final_color)?;
                        e.apply_gradient(final_scene, &[sym], 6, Some(&spectrum), None)
                            .map_err(other)?;
                        if plain {
                            final_memo.insert(
                                (sym, final_color),
                                e.scenes.frames_of(final_scene).to_vec(),
                            );
                        }
                    }
                }
            }
            let pop_2 = e.scene_name(pop_2_scene);
            let final_name = e.scene_name(final_scene);
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(self.pop_1),
                Action::ActivateScene(pop_2),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(pop_2),
                Action::ActivateScene(final_name),
            )
            .map_err(other)?;
            let path = e
                .path_new(
                    slot,
                    POP_SPEED,
                    Some(Easing::InOutExpo),
                    None,
                    0,
                    false,
                    self.final_,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, input_coord, None, Name::NONE)
                .map_err(other)?;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(self.final_),
                Action::SetLayer(0),
            )
            .map_err(other)?;
        }

        self.chars = e
            .get_characters_grouped(CharacterFilter::default(), CharacterGroup::RowBottomToTop)
            .into_iter()
            .flatten()
            .collect();
        // input symbol -> its visual in each rainbow color
        let mut rainbow_memo: HashMap<Sym, Vec<Visual>, FxBuild> = HashMap::default();
        let mut sheen = vec![
            Frame {
                visual: Visual(0),
                duration: 4
            };
            rainbow.len()
        ];
        let space = e.sym(" ");
        let total = self.chars.len();
        let mut taken = 0;
        while taken < total {
            let remaining = total - taken;
            let count = if remaining < 5 {
                remaining
            } else {
                e.rng.randint(5, remaining.min(20) as i64) as usize
            };
            let group = taken..taken + count;
            let origin = Coord::new(e.rng.randint(canvas.left, canvas.right), canvas.top + 10);
            // Bubble.__init__
            let radius = (count as i64 / 5).max(1);
            let anchor = e.add_character_sym(space, origin);
            let lowest_row = if config.pop_condition == PopCondition::Row {
                self.chars[group.clone()]
                    .iter()
                    .map(|&s| e.input_coord(s).row)
                    .min()
                    .unwrap()
            } else {
                canvas.bottom
            };
            let circle = self.circle(radius, count as u32);
            let pop_circle = self.circle(radius + 3, count as u32);
            let b = self.bubbles.len() as u32;
            self.bubbles.push(Bubble {
                start: taken as u32,
                n: count as u32,
                anchor,
                lowest_row,
                landed: false,
                circle,
                pop_circle,
                placed_at: Coord::new(i64::MIN, i64::MIN),
                on_floor: false,
            });
            self.set_character_coordinates(e, b);
            self.bubbles[b as usize].landed = false;
            // make_waypoints
            let waypoint_column = e.rng.randint(canvas.left, canvas.right);
            let path = e
                .path_new(
                    anchor,
                    config.bubble_speed,
                    None,
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(
                path,
                Coord::new(waypoint_column, lowest_row),
                None,
                Name::NONE,
            )
            .map_err(other)?;
            e.activate_path(self, anchor, path);
            // make_gradients
            if config.rainbow {
                // character k's frame j is rainbow[(rot + j) % len], rot
                // summing the growing offsets it was rotated by
                let len = rainbow.len();
                let (mut offset, mut rot) = (0, 0);
                for k in group {
                    let slot = self.chars[k];
                    let sym = e.input_sym(slot);
                    let visuals = rainbow_memo.entry(sym).or_insert_with(|| {
                        rainbow
                            .iter()
                            .map(|&c| {
                                e.visuals.make(
                                    &e.symbols,
                                    VisualInfo {
                                        sym,
                                        fg: Some(c),
                                        bg: None,
                                        attrs: HAS_COLORS,
                                    },
                                )
                            })
                            .collect()
                    });
                    for (j, frame) in sheen.iter_mut().enumerate() {
                        frame.visual = visuals[(rot + j) % len];
                    }
                    let scene = e.scene_new(slot, Name::NONE, true, None, None);
                    e.add_frames_visual(scene, &sheen).map_err(other)?;
                    offset = (offset + 2) % len;
                    rot = (rot + offset) % len;
                    e.activate_scene(self, slot, scene);
                }
            } else {
                let color = config.bubble_colors[e.rng.choice_index(config.bubble_colors.len())];
                for k in group {
                    let slot = self.chars[k];
                    let sym = e.input_sym(slot);
                    let scene = e.scene_new(slot, Name::NONE, false, None, None);
                    e.add_frame(scene, sym, 1, Some(ColorPair::new(Some(color), None)), 0)
                        .map_err(other)?;
                    e.activate_scene(self, slot, scene);
                }
            }
            taken += count;
        }
        self.animating = Vec::with_capacity(self.bubbles.len());
        self.next = 0;
        self.steps_since_last_bubble = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.animating.is_empty() && e.active_is_empty() && self.next == self.bubbles.len() {
            return false;
        }
        if self.next < self.bubbles.len()
            && self.steps_since_last_bubble >= self.config.bubble_delay
        {
            let bubble = &self.bubbles[self.next];
            for &slot in &self.chars[bubble.start as usize..(bubble.start + bubble.n) as usize] {
                e.set_visible(slot, true);
            }
            self.animating.push(self.next as u32);
            self.next += 1;
            self.steps_since_last_bubble = 0;
        }
        self.steps_since_last_bubble += 1;

        // landed bubbles pop, the rest float on
        let mut animating = std::mem::take(&mut self.animating);
        for &b in &animating {
            if self.bubbles.at(b).landed {
                self.pop(e, b);
            }
        }
        animating.retain(|&b| !self.bubbles.at(b).landed);
        for &b in &animating {
            self.move_bubble(e, b);
        }
        self.animating = animating;

        e.update(self);
        true
    }
}
