//! smoke on the fx engine (old engine: effects/smoke.rs).
//!
//! RNG order is SmokeIterator.__init__'s: PrimsWeighted (random starting
//! coord, then one randint(0, 99) weight per input and fill character from
//! top to bottom, left to right), the BreadthFirst starting coord, then
//! build() runs PrimsWeighted to completion. next_frame draws nothing; the
//! flood follows BreadthFirst layers over the generated tree.
//!
//! Scenes depend only on symbol and colors, so later plain characters copy
//! the first equivalent character's scene record (sharing its frames).

use std::collections::HashMap;

use crate::effects::smoke::SmokeConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::{At, Engine, FxBuild, Hooks, Sym, NONE};
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Smoke {
    config: SmokeConfig,
    /// Per slot: the "smoke" scene (NONE for characters without one).
    smoke_scene: Vec<u32>,
    links: Links,
    fill: BreadthFirst,
}

impl Smoke {
    pub fn new(config: SmokeConfig) -> Self {
        Smoke {
            config,
            smoke_scene: Vec::new(),
            links: Links(Vec::new()),
            fill: BreadthFirst::default(),
        }
    }
}

impl Hooks for Smoke {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// EffectCharacter.links: up to four linked slots per character (it only
/// links to its grid neighbors), ascending with NONE after the last, so
/// iteration is the canonical ascending character_id order.
struct Links(Vec<[u32; 4]>);

impl Links {
    #[inline]
    fn has_links(&self, slot: u32) -> bool {
        self.0[slot as usize][0] != NONE
    }

    fn insert(&mut self, slot: u32, other: u32) {
        let links = &mut self.0[slot as usize];
        let mut value = other;
        for link in links.iter_mut() {
            if *link == value {
                return;
            }
            if *link > value {
                std::mem::swap(link, &mut value);
            }
        }
    }

    /// EffectCharacter._link.
    fn link(&mut self, a: u32, b: u32) {
        self.insert(a, b);
        self.insert(b, a);
    }
}

/// SpanningTreeGenerator.get_neighbors(unlinked_only=True, limit): north,
/// east, south, west.
#[inline]
fn unlinked_neighbors(
    e: &Engine,
    links: &Links,
    limit: bool,
    slot: u32,
    out: &mut [u32; 4],
) -> usize {
    let n = e.neighbors(slot);
    let mut count = 0;
    for neighbor in [n.north, n.east, n.south, n.west] {
        if neighbor != NONE
            && (!limit || e.canvas.coord_is_in_text(e.input_coord(neighbor)))
            && !links.has_links(neighbor)
        {
            out[count] = neighbor;
            count += 1;
        }
    }
    count
}

const WEIGHTS: usize = 100;

/// algo/primsweighted.py PrimsWeighted: pending links bucketed by weight
/// (links_at_weight in insertion order), with a bitmask of the nonempty
/// buckets for the lowest weight.
struct PrimsWeighted {
    limit: bool,
    weights: Vec<u8>,
    /// (char_a, char_b) packed as char_a | char_b << 32.
    buckets: Vec<Vec<u64>>,
    nonempty: u128,
}

impl PrimsWeighted {
    /// add_weighted_links.
    fn add_links(&mut self, e: &Engine, links: &Links, slot: u32) {
        let mut neighbors = [NONE; 4];
        let count = unlinked_neighbors(e, links, self.limit, slot, &mut neighbors);
        for &neighbor in &neighbors[..count] {
            let weight = self.weights[neighbor as usize] as usize;
            self.buckets[weight].push(slot as u64 | (neighbor as u64) << 32);
            self.nonempty |= 1 << weight;
        }
    }

    /// step() until complete, with get_lowest_weight_link inlined: pop a
    /// random link of the lowest weight until one reaches an unlinked
    /// character.
    fn run(&mut self, e: &mut Engine, links: &mut Links) {
        while self.nonempty != 0 {
            let weight = self.nonempty.trailing_zeros() as usize;
            let bucket = &mut self.buckets[weight];
            let link = bucket.remove(e.rng.randrange(0, bucket.len() as i64) as usize);
            if bucket.is_empty() {
                self.nonempty &= !(1 << weight);
            }
            let (a, b) = (link as u32, (link >> 32) as u32);
            if !links.has_links(b) {
                links.link(a, b);
                self.add_links(e, links, b);
            }
        }
    }
}

/// algo/breadthfirst.py BreadthFirst. The frontier and every later layer
/// live in one queue: the frontier is `queue[head..]`. Anything in the
/// frontier or in new_edges is already explored, so the explored test
/// covers upstream's three membership checks.
#[derive(Default)]
struct BreadthFirst {
    queue: Vec<u32>,
    explored: Vec<bool>,
    head: usize,
    complete: bool,
}

impl BreadthFirst {
    fn new(start: u32, char_count: usize) -> Self {
        let mut queue = Vec::with_capacity(char_count);
        queue.push(start);
        let mut explored = vec![false; char_count];
        explored[start as usize] = true;
        BreadthFirst {
            queue,
            explored,
            head: 0,
            complete: false,
        }
    }

    /// step(): the explored_last_step range of `queue`.
    fn step(&mut self, links: &Links) -> std::ops::Range<usize> {
        let (head, tail) = (self.head, self.queue.len());
        if head == tail {
            self.complete = true;
            return tail..tail;
        }
        for i in head..tail {
            // in bounds: tail is the queue's length
            let position = *self.queue.at(i);
            // the slots are checked: once per character, not a hot path
            for &link in &links.0[position as usize] {
                if link == NONE {
                    break;
                }
                let explored = &mut self.explored[link as usize];
                if !*explored {
                    *explored = true;
                    self.queue.push(link);
                }
            }
        }
        self.head = tail;
        tail..self.queue.len()
    }
}

impl Effect for Smoke {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let limit = !config.use_whole_canvas;
        let char_count = e.char_count();
        let filter = CharacterFilter {
            input_chars: true,
            inner_fill_chars: true,
            outer_fill_chars: true,
            added_chars: false,
        };
        let characters = e.get_characters(filter, CharacterSort::TopToBottomLeftToRight);

        // PrimsWeighted::new: the starting character, then the weights
        let start_coord = e.canvas.random_coord(&mut e.rng, false, limit);
        let start = e
            .char_at_input_coord(start_coord)
            .ok_or_else(|| other("Unable to find a starting character.".into()))?;
        let mut draws = vec![0u16; characters.len()];
        e.rng.fill_below(WEIGHTS as u64, &mut draws);
        let mut weights = vec![0u8; char_count];
        for (&slot, &w) in characters.iter().zip(&draws) {
            weights[slot as usize] = w as u8;
        }
        let mut links = Links(vec![[NONE; 4]; char_count]);
        let mut gen = PrimsWeighted {
            limit,
            weights,
            buckets: vec![Vec::new(); WEIGHTS],
            nonempty: 0,
        };
        gen.add_links(e, &links, start);

        // the fill start: a random coord's character, else BreadthFirst's own
        // draw
        let fill_coord = e.canvas.random_coord(&mut e.rng, false, limit);
        let fill_start = match e.char_at_input_coord(fill_coord) {
            Some(slot) => slot,
            None => {
                let coord = e.canvas.random_coord(&mut e.rng, false, limit);
                e.char_at_input_coord(coord)
                    .ok_or_else(|| other("Unable to find a starting character.".into()))?
            }
        };

        // SmokeIterator.build()
        let canvas = e.canvas.clone();
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
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
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let blk = Color::from_hex("000000").unwrap();
        // Gradient(*smoke_gradient_stops, *final_gradient_stops[::-1], steps=(3, 4))
        let smoke_stops: Vec<Color> = config
            .smoke_gradient_stops
            .iter()
            .chain(config.final_gradient_stops.iter().rev())
            .copied()
            .collect();
        let smoke_spectrum = Gradient::new(&smoke_stops, &[3, 4], false, false)
            .map_err(other)?
            .spectrum;
        let smoke_syms: Vec<Sym> = config.smoke_symbols.iter().map(|s| e.sym(s)).collect();
        let mut paint_stops: Vec<Color> = config.final_gradient_stops.clone();
        paint_stops.push(blk);

        let paint_name = e.name("paint");
        let smoke_name = e.name("smoke");
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let always = e.existing_color_handling() == ExistingColorHandling::Always;
        let starting = ColorPair::new(Some(config.starting_color), None);
        let dynamic_base = ColorPair::new(Some(blk), None);
        // (symbol, final colors) -> a plain paint scene; final colors -> a
        // plain smoke scene
        let mut paint_memo: HashMap<(Sym, ColorPair), u32, FxBuild> = HashMap::default();
        let mut smoke_memo: HashMap<ColorPair, u32, FxBuild> = HashMap::default();
        let mut spectrum_memo: HashMap<Color, Vec<Color>, FxBuild> = HashMap::default();
        e.scenes.reserve(2 * characters.len(), 0);
        self.smoke_scene = vec![NONE; char_count];
        for &slot in &characters {
            e.set_visible(slot, true);
            let sym = e.input_sym(slot);
            let plain = !(always && e.uses_preexisting_colors(slot));
            let (final_colors, base) = if dynamic {
                (
                    ColorPair::new(e.input_fg(slot), e.input_bg(slot)),
                    dynamic_base,
                )
            } else {
                let color = final_gradient_mapping
                    .get(&e.input_coord(slot))
                    .copied()
                    .unwrap_or(blk);
                (ColorPair::new(Some(color), None), starting)
            };

            match paint_memo.get(&(sym, final_colors)) {
                Some(&template) if plain => {
                    e.scene_copy(slot, template, paint_name);
                }
                _ => {
                    let scene = e.scene_new(slot, paint_name, false, None, None);
                    if dynamic {
                        e.add_frame(scene, sym, 5, Some(final_colors), 0)
                            .map_err(other)?;
                    } else {
                        // Gradient(*final_gradient_stops, final_fg_color, steps=5)
                        let final_color = final_colors.fg_color.unwrap();
                        let spectrum = match spectrum_memo.get(&final_color) {
                            Some(spectrum) => spectrum,
                            None => {
                                *paint_stops.last_mut().unwrap() = final_color;
                                let spectrum = Gradient::with_steps(&paint_stops, 5, false)
                                    .map_err(other)?
                                    .spectrum;
                                spectrum_memo.entry(final_color).or_insert(spectrum)
                            }
                        };
                        e.apply_gradient(scene, &[sym], 5, Some(spectrum), None)
                            .map_err(other)?;
                    }
                    if plain {
                        paint_memo.insert((sym, final_colors), scene);
                    }
                }
            }

            // outside dynamic the smoke scene ignores the final colors
            let smoke_key = if dynamic { final_colors } else { starting };
            let smoke = match smoke_memo.get(&smoke_key) {
                Some(&template) if plain => e.scene_copy(slot, template, smoke_name),
                _ => {
                    let scene = e.scene_new(slot, smoke_name, false, None, None);
                    if dynamic {
                        for &smoke_sym in &smoke_syms {
                            e.add_frame(scene, smoke_sym, 10, Some(final_colors), 0)
                                .map_err(other)?;
                        }
                    } else {
                        e.apply_gradient(scene, &smoke_syms, 3, Some(&smoke_spectrum), None)
                            .map_err(other)?;
                    }
                    if plain {
                        smoke_memo.insert(smoke_key, scene);
                    }
                    scene
                }
            };
            self.smoke_scene[slot as usize] = smoke;
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(smoke_name),
                Action::ActivateScene(paint_name),
            )
            .map_err(other)?;
            e.set_appearance(slot, Some(sym), Some(base));
        }

        gen.run(e, &mut links);
        self.fill = BreadthFirst::new(fill_start, char_count);
        self.links = links;

        // the starting character is never 'explored': start it by hand
        let scene = self.smoke_scene[fill_start as usize];
        e.activate_scene(self, fill_start, scene);
        e.active_insert(fill_start);
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.fill.complete && e.active_is_empty() {
            return false;
        }
        if !self.fill.complete {
            let explored = self.fill.step(&self.links);
            for i in explored {
                // in bounds: step returns a range of the queue
                let slot = *self.fill.queue.at(i);
                let scene = self.smoke_scene[slot as usize];
                e.activate_scene(self, slot, scene);
                e.active_insert(slot);
            }
        }
        e.update(self);
        true
    }
}
