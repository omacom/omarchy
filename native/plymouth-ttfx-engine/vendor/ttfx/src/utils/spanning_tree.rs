//! Spanning-tree generators, ported from utils/spanningtree/. AldousBroder is
//! deliberately not ported: no shipped effect uses it (plan.md §5 divergences).
//!
//! Canonical ordering note (plan.md §4.3): `EffectCharacter.links` is a Python
//! set; BreadthFirst iterates it. Our canonical order is ascending
//! character_id — links are kept sorted-by-id on insert, and the parity shim
//! patches the Python side to `sorted(links, key=character_id)`.

use std::collections::BTreeMap;

use crate::engine::character::CharId;
use crate::engine::ctx::EngineCtx;

/// EffectCharacter._link: bidirectional set-add (id-sorted, see module note).
pub fn link_characters(ctx: &mut EngineCtx, a: CharId, b: CharId) {
    let insert_sorted = |links: &mut Vec<CharId>, id: CharId| {
        if let Err(pos) = links.binary_search(&id) {
            links.insert(pos, id);
        }
    };
    insert_sorted(&mut ctx.terminal.arena[a.0 as usize].links, b);
    insert_sorted(&mut ctx.terminal.arena[b.0 as usize].links, a);
}

/// SpanningTreeGenerator.get_neighbors: neighbors in dict order (north, east,
/// south, west), optional text-boundary and unlinked filters.
fn get_neighbors(ctx: &EngineCtx, id: CharId, unlinked_only: bool, limit_to_text_boundary: bool) -> Vec<CharId> {
    let ch = &ctx.terminal.arena[id.0 as usize];
    let mut neighbors: Vec<CharId> = [ch.neighbors.north, ch.neighbors.east, ch.neighbors.south, ch.neighbors.west]
        .into_iter()
        .flatten()
        .collect();
    if limit_to_text_boundary {
        neighbors.retain(|&n| ctx.terminal.canvas.coord_is_in_text(ctx.terminal.arena[n.0 as usize].input_coord));
    }
    if unlinked_only {
        neighbors.retain(|&n| ctx.terminal.arena[n.0 as usize].links.is_empty());
    }
    neighbors
}

fn default_starting_char(ctx: &mut EngineCtx, within_text_boundary: bool) -> Result<CharId, String> {
    let coord = ctx.terminal.canvas.random_coord(&mut ctx.rng, false, within_text_boundary);
    ctx.terminal
        .get_character_by_input_coord(coord)
        .ok_or_else(|| "Unable to find a starting character.".to_string())
}

/// algo/primssimple.py PrimsSimple.
pub struct PrimsSimple {
    pub limit_to_text_boundary: bool,
    current_char: CharId,
    pub char_last_linked: Option<CharId>,
    pub char_link_order: Vec<CharId>,
    pub edge_chars: Vec<CharId>,
    pub edge_last_added: Option<CharId>,
    pub edge_last_popped: Option<CharId>,
    pub complete: bool,
}

impl PrimsSimple {
    pub fn new(
        ctx: &mut EngineCtx,
        starting_char: Option<CharId>,
        limit_to_text_boundary: bool,
    ) -> Result<Self, String> {
        let starting_char = match starting_char {
            Some(c) => c,
            None => default_starting_char(ctx, limit_to_text_boundary)?,
        };
        Ok(PrimsSimple {
            limit_to_text_boundary,
            current_char: starting_char,
            char_last_linked: Some(starting_char),
            char_link_order: vec![starting_char],
            edge_chars: vec![starting_char],
            edge_last_added: Some(starting_char),
            edge_last_popped: None,
            complete: false,
        })
    }

    /// Faithful quirk: `complete` flips only when edge_chars is already empty
    /// at call entry.
    pub fn step(&mut self, ctx: &mut EngineCtx) {
        if !self.edge_chars.is_empty() {
            let idx = ctx.rng.randrange(0, self.edge_chars.len() as i64) as usize;
            self.current_char = self.edge_chars.remove(idx);
            self.edge_last_popped = Some(self.current_char);
            let mut unlinked_neighbors = get_neighbors(ctx, self.current_char, true, self.limit_to_text_boundary);
            if !unlinked_neighbors.is_empty() {
                let idx = ctx.rng.randrange(0, unlinked_neighbors.len() as i64) as usize;
                let next_char = unlinked_neighbors.remove(idx);
                link_characters(ctx, self.current_char, next_char);
                self.char_link_order.push(next_char);
                self.char_last_linked = Some(next_char);
                if !unlinked_neighbors.is_empty() {
                    self.edge_chars.push(self.current_char);
                }
                let next_neighbors = get_neighbors(ctx, next_char, true, self.limit_to_text_boundary);
                if !next_neighbors.is_empty() {
                    self.edge_chars.push(next_char);
                    self.edge_last_added = Some(next_char);
                }
            }
        } else {
            self.complete = true;
        }
    }
}

/// algo/primsweighted.py WeightedLink.
#[derive(Debug, Clone, Copy)]
pub struct WeightedLink {
    pub char_a: CharId,
    pub char_b: CharId,
    pub weight: i64,
}

/// algo/primsweighted.py PrimsWeighted.
pub struct PrimsWeighted {
    pub limit_to_text_boundary: bool,
    char_weights: std::collections::HashMap<CharId, i64>,
    pub char_last_linked: Option<CharId>,
    pub char_link_order: Vec<CharId>,
    pub neighbors_last_added: Vec<CharId>,
    pub complete: bool,
    pending_weighted_links: BTreeMap<i64, Vec<WeightedLink>>,
}

impl PrimsWeighted {
    pub fn new(
        ctx: &mut EngineCtx,
        starting_char: Option<CharId>,
        limit_to_text_boundary: bool,
    ) -> Result<Self, String> {
        let starting_char = match starting_char {
            Some(c) => c,
            None => default_starting_char(ctx, limit_to_text_boundary)?,
        };
        // weights assigned over get_characters(inner+outer fill, default sort)
        // — that ordering is the RNG consumption order, faithfully
        let filter = crate::engine::terminal::CharacterFilter {
            input_chars: true,
            inner_fill_chars: true,
            outer_fill_chars: true,
            added_chars: false,
        };
        let ordered = {
            let terminal = &ctx.terminal;
            let mut all = terminal.collect_characters(filter);
            all.sort_by_key(|&id| {
                let c = terminal.arena[id.0 as usize].input_coord;
                (-c.row, c.column)
            });
            all
        };
        let mut char_weights = std::collections::HashMap::new();
        for id in ordered {
            char_weights.insert(id, ctx.rng.randint(0, 99));
        }
        let mut generator = PrimsWeighted {
            limit_to_text_boundary,
            char_weights,
            char_last_linked: Some(starting_char),
            char_link_order: vec![starting_char],
            neighbors_last_added: Vec::new(),
            complete: false,
            pending_weighted_links: BTreeMap::new(),
        };
        generator.add_weighted_links(ctx, starting_char);
        Ok(generator)
    }

    fn add_weighted_links(&mut self, ctx: &EngineCtx, char_id: CharId) {
        self.neighbors_last_added.clear();
        for neighbor in get_neighbors(ctx, char_id, true, self.limit_to_text_boundary) {
            self.neighbors_last_added.push(neighbor);
            let weight = self.char_weights[&neighbor];
            self.pending_weighted_links
                .entry(weight)
                .or_default()
                .push(WeightedLink { char_a: char_id, char_b: neighbor, weight });
        }
    }

    fn get_lowest_weight_link(&mut self, ctx: &mut EngineCtx) -> Option<WeightedLink> {
        while !self.pending_weighted_links.is_empty() {
            let lowest_weight = *self.pending_weighted_links.keys().next().unwrap();
            let links_at_weight = self.pending_weighted_links.get_mut(&lowest_weight).unwrap();
            let idx = ctx.rng.randrange(0, links_at_weight.len() as i64) as usize;
            let link = links_at_weight.remove(idx);
            if links_at_weight.is_empty() {
                self.pending_weighted_links.remove(&lowest_weight);
            }
            if ctx.terminal.arena[link.char_b.0 as usize].links.is_empty() {
                return Some(link);
            }
        }
        None
    }

    pub fn step(&mut self, ctx: &mut EngineCtx) {
        if !self.pending_weighted_links.is_empty() {
            let Some(next_link) = self.get_lowest_weight_link(ctx) else {
                self.complete = true;
                return;
            };
            link_characters(ctx, next_link.char_a, next_link.char_b);
            self.char_last_linked = Some(next_link.char_b);
            self.char_link_order.push(next_link.char_b);
            self.add_weighted_links(ctx, next_link.char_b);
        } else {
            self.complete = true;
            self.char_last_linked = None;
            self.neighbors_last_added.clear();
        }
    }
}

/// algo/recursivebacktracker.py RecursiveBacktracker.
pub struct RecursiveBacktracker {
    pub limit_to_text_boundary: bool,
    current_char: CharId,
    pub char_last_linked: Option<CharId>,
    pub char_link_order: Vec<CharId>,
    pub stack: Vec<CharId>,
    pub stack_last_popped: Option<CharId>,
    pub complete: bool,
}

impl RecursiveBacktracker {
    pub fn new(
        ctx: &mut EngineCtx,
        starting_char: Option<CharId>,
        limit_to_text_boundary: bool,
    ) -> Result<Self, String> {
        let starting_char = match starting_char {
            Some(c) => c,
            None => default_starting_char(ctx, limit_to_text_boundary)?,
        };
        Ok(RecursiveBacktracker {
            limit_to_text_boundary,
            current_char: starting_char,
            char_last_linked: Some(starting_char),
            char_link_order: vec![starting_char],
            stack: vec![starting_char],
            stack_last_popped: None,
            complete: false,
        })
    }

    pub fn step(&mut self, ctx: &mut EngineCtx) {
        self.char_last_linked = None;
        self.stack_last_popped = None;
        if !self.stack.is_empty() {
            let unvisited = get_neighbors(ctx, self.current_char, true, self.limit_to_text_boundary);
            if !unvisited.is_empty() {
                let next_char = *ctx.rng.choice(&unvisited);
                link_characters(ctx, self.current_char, next_char);
                self.char_link_order.push(next_char);
                self.char_last_linked = Some(next_char);
                self.stack.push(next_char);
                self.current_char = next_char;
            } else {
                self.stack_last_popped = self.stack.pop();
                if let Some(&top) = self.stack.last() {
                    self.current_char = top;
                }
            }
        } else {
            self.complete = true;
        }
    }
}

/// algo/breadthfirst.py BreadthFirst: traverses the linked graph layer by
/// layer. No randomness of its own; `links` iteration is ascending id (the
/// canonical order; shim-matched on the Python side).
pub struct BreadthFirst {
    pub starting_char: CharId,
    frontier: Vec<CharId>,
    explored: std::collections::HashSet<CharId>,
    pub explored_last_step: Vec<CharId>,
    pub char_explore_order: Vec<CharId>,
    pub complete: bool,
}

impl BreadthFirst {
    pub fn new(
        ctx: &mut EngineCtx,
        starting_char: Option<CharId>,
        limit_to_text_boundary: bool,
    ) -> Result<Self, String> {
        let starting_char = match starting_char {
            Some(c) => c,
            None => default_starting_char(ctx, limit_to_text_boundary)?,
        };
        Ok(BreadthFirst {
            starting_char,
            frontier: vec![starting_char],
            explored: std::collections::HashSet::from([starting_char]),
            explored_last_step: Vec::new(),
            char_explore_order: Vec::new(),
            complete: false,
        })
    }

    pub fn step(&mut self, ctx: &EngineCtx) {
        self.explored_last_step.clear();
        if self.frontier.is_empty() {
            self.complete = true;
            return;
        }
        let mut new_edges: Vec<CharId> = Vec::new();
        while !self.frontier.is_empty() {
            let position = self.frontier.remove(0);
            let links = ctx.terminal.arena[position.0 as usize].links.clone();
            let position_new_edges: Vec<CharId> = links
                .into_iter()
                .filter(|n| !self.explored.contains(n) && !self.frontier.contains(n) && !new_edges.contains(n))
                .collect();
            for &character in &position_new_edges {
                self.explored.insert(character);
                self.explored_last_step.push(character);
                self.char_explore_order.push(character);
            }
            new_edges.extend(position_new_edges);
        }
        self.frontier = new_edges;
    }
}
