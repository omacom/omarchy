//! EngineCtx: the mutable engine world (terminal + arena + rng + clock +
//! active characters) and every stepping routine that can fire events.
//!
//! Python executes event actions synchronously at the emission point, deep in
//! the middle of Path.step / Motion.move / Animation.step_animation, and those
//! actions reentrantly mutate the same structures being stepped. To preserve
//! that observable ordering (plan.md §4.2), all stepping logic lives here as
//! EngineCtx methods that hold only short-lived borrows: state is re-fetched
//! by id after every emission point, and segment walks are index-based so
//! reentrant list mutation behaves like Python list iteration.

use std::rc::Rc;
use std::time::Instant;

use crate::engine::active_characters::ActiveCharacters;
use crate::engine::animation::SyncMetric;
use crate::engine::character::CharId;
use crate::engine::error::EngineError;
use crate::engine::events::{CallerKey, CallerRef, EffectCallback, Event, EventAction};
use crate::engine::motion::Waypoint;
use crate::engine::motion::{Path, Segment};
use crate::engine::terminal::{Terminal, TerminalConfig};
use crate::utils::geometry::{self, Coord};
use crate::utils::pycompat::round_half_even;
use crate::utils::rng::Rng;

thread_local! {
    /// The synthetic origin waypoint's id, shared by every activation.
    static ORIGIN_WAYPOINT_ID: Rc<str> = Rc::from("origin");
}

/// Virtual/real clock (plan.md §4.7). Matrix reads wall time, thunderstorm
/// reads monotonic time; the parity harness swaps in the virtual variant.
#[derive(Debug)]
pub enum Clock {
    Real {
        start: Instant,
        wall_start: f64,
    },
    /// Virtual time advancing a fixed dt per emitted frame.
    Virtual {
        now: f64,
        dt: f64,
    },
}

impl Clock {
    pub fn real() -> Self {
        let wall_start = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_secs_f64())
            .unwrap_or(0.0);
        Clock::Real {
            start: Instant::now(),
            wall_start,
        }
    }

    pub fn virtual_with_frame_rate(frame_rate: i64) -> Self {
        let dt = if frame_rate > 0 {
            1.0 / frame_rate as f64
        } else {
            1.0 / 60.0
        };
        Clock::Virtual { now: 0.0, dt }
    }

    /// time.time() analog.
    pub fn now_wall(&self) -> f64 {
        match self {
            Clock::Real { start, wall_start } => wall_start + start.elapsed().as_secs_f64(),
            Clock::Virtual { now, .. } => *now,
        }
    }

    /// time.monotonic() analog.
    pub fn now_monotonic(&self) -> f64 {
        match self {
            Clock::Real { start, .. } => start.elapsed().as_secs_f64(),
            Clock::Virtual { now, .. } => *now,
        }
    }

    /// Advance virtual time by one frame; no-op for the real clock.
    pub fn advance_frame(&mut self) {
        if let Clock::Virtual { now, dt } = self {
            *now += *dt;
        }
    }
}

/// Effect-side hook for CALLBACK actions. The effect struct and the EngineCtx
/// are disjoint ownership trees, so the callback may freely recurse into
/// engine calls with the provided ctx.
pub trait EffectHooks {
    fn dispatch_callback(
        &mut self,
        ctx: &mut EngineCtx,
        character: CharId,
        callback: &EffectCallback,
    );
}

/// Hooks implementation for engine-internal use (no effect callbacks registered).
pub struct NoopHooks;
impl EffectHooks for NoopHooks {
    fn dispatch_callback(
        &mut self,
        _ctx: &mut EngineCtx,
        _character: CharId,
        _callback: &EffectCallback,
    ) {
    }
}

pub struct EngineCtx {
    pub terminal: Terminal,
    pub rng: Rng,
    pub clock: Clock,
    /// BaseEffectIterator.active_characters — canonical ascending-id order
    /// (CharId order == character_id order by construction).
    pub active_characters: ActiveCharacters,
    active_character_scratch: Vec<CharId>,
    pub preexisting_colors_present: bool,
    /// Embedding-only final text layout; CLI gradients remain unchanged.
    pub final_text_bands: bool,
    structured_output: bool,
    /// When Some, every event emission appends a trace line (test harness).
    pub event_log: Option<Vec<String>>,
}

impl EngineCtx {
    pub fn new(
        input_data: &str,
        config: TerminalConfig,
        rng: Rng,
        clock: Clock,
    ) -> Result<Self, EngineError> {
        let terminal = Terminal::new(input_data, config)?;
        let preexisting_colors_present = terminal.input_characters.iter().any(|&id| {
            let ch = &terminal.arena[id.0 as usize];
            ch.animation.input_fg_color.is_some() || ch.animation.input_bg_color.is_some()
        });
        Ok(EngineCtx {
            terminal,
            rng,
            clock,
            active_characters: ActiveCharacters::new(),
            active_character_scratch: Vec::new(),
            preexisting_colors_present,
            final_text_bands: false,
            structured_output: false,
            event_log: None,
        })
    }

    /// Select cell-only frame generation for in-process renderers.
    pub fn set_structured_output(&mut self, enabled: bool) {
        self.structured_output = enabled;
    }

    /// Map only an effect's final text palette, never its transient scene colors.
    pub fn final_gradient_mapping(
        &self,
        gradient: &crate::utils::graphics::Gradient,
        direction: crate::utils::graphics::GradientDirection,
    ) -> Result<crate::utils::graphics::CoordColorMap, String> {
        let canvas = &self.terminal.canvas;
        if self.final_text_bands {
            gradient.build_banded_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
            )
        } else {
            gradient.build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                direction,
            )
        }
    }

    // ------------------------------------------------------------------
    // event dispatch (EventHandler._handle_event)
    // ------------------------------------------------------------------

    /// Whether an emission of `event` on `id` can have any observable effect —
    /// false lets hot emission sites skip building the CallerKey entirely.
    #[inline]
    fn observes_event(&self, id: CharId, event: Event) -> bool {
        self.event_log.is_some()
            || self.terminal.arena[id.0 as usize]
                .event_handler
                .subscribes(event)
    }

    /// Execute all actions registered for (event, caller) on `id`, in
    /// registration order, inline and reentrantly. The action list is indexed
    /// per iteration because a callback may append more actions to it.
    pub fn handle_event(
        &mut self,
        hooks: &mut dyn EffectHooks,
        id: CharId,
        event: Event,
        caller: CallerRef<'_>,
    ) {
        if let Some(log) = self.event_log.as_mut() {
            let character_id = self.terminal.arena[id.0 as usize].character_id;
            let event_name = match event {
                Event::SegmentEntered => "SEGMENT_ENTERED",
                Event::SegmentExited => "SEGMENT_EXITED",
                Event::PathActivated => "PATH_ACTIVATED",
                Event::PathComplete => "PATH_COMPLETE",
                Event::PathHolding => "PATH_HOLDING",
                Event::SceneActivated => "SCENE_ACTIVATED",
                Event::SceneComplete => "SCENE_COMPLETE",
            };
            let caller_label = match caller {
                CallerRef::Path(pid) => format!("path:{pid}"),
                CallerRef::Waypoint(wp) => format!("wp:{}", wp.waypoint_id),
                CallerRef::Scene(sid) => format!("scene:{sid}"),
            };
            log.push(format!(
                "EVENT char={character_id} {event_name} caller={caller_label}"
            ));
        }
        let Some(entry_index) = self.terminal.arena[id.0 as usize]
            .event_handler
            .actions_index(event, caller)
        else {
            return;
        };
        let mut action_index = 0;
        loop {
            let action = {
                let handler = &self.terminal.arena[id.0 as usize].event_handler;
                let actions = handler.actions(entry_index);
                if action_index >= actions.len() {
                    break;
                }
                actions[action_index].clone()
            };
            match action {
                EventAction::ActivatePath(path_id) => self.activate_path(hooks, id, &path_id),
                EventAction::ActivateScene(scene_id) => self.activate_scene(hooks, id, &scene_id),
                EventAction::DeactivatePath(target) => {
                    self.terminal.arena[id.0 as usize]
                        .motion
                        .deactivate_path(target.as_deref());
                }
                EventAction::DeactivateScene(target) => {
                    self.deactivate_scene(id, target.as_deref());
                }
                EventAction::ResetAppearance => {
                    let ch = &mut self.terminal.arena[id.0 as usize];
                    let input_symbol = ch.input_symbol.clone();
                    let uses = ch.uses_input_preexisting_colors;
                    ch.animation.set_appearance(
                        &input_symbol,
                        uses,
                        Some(&input_symbol.clone()),
                        None,
                    );
                }
                EventAction::SetLayer(layer) => {
                    self.terminal.arena[id.0 as usize].layer = layer;
                }
                EventAction::SetCoordinate(coord) => {
                    self.terminal.arena[id.0 as usize].motion.current_coord = coord;
                }
                EventAction::Callback(cb) => {
                    hooks.dispatch_callback(self, id, &cb);
                }
            }
            action_index += 1;
        }
    }

    /// EventHandler.register_event: resolves/validates existence for id-based
    /// callers and targets, rejects duplicates.
    pub fn register_event(
        &mut self,
        id: CharId,
        event: Event,
        caller: CallerKey,
        action: EventAction,
    ) -> Result<(), String> {
        {
            let ch = &self.terminal.arena[id.0 as usize];
            match &caller {
                CallerKey::Path(pid) => {
                    if !ch.motion.paths.contains_key(pid) {
                        return Err(format!("path not found: {pid}"));
                    }
                }
                CallerKey::Scene(sid) => {
                    if !ch.animation.scenes.contains_key(sid) {
                        return Err(format!("scene not found: {sid}"));
                    }
                }
                CallerKey::Waypoint(_) => {}
            }
            match &action {
                EventAction::ActivatePath(pid) | EventAction::DeactivatePath(Some(pid)) => {
                    if !ch.motion.paths.contains_key(pid) {
                        return Err(format!("path not found: {pid}"));
                    }
                }
                EventAction::ActivateScene(sid) | EventAction::DeactivateScene(Some(sid)) => {
                    if !ch.animation.scenes.contains_key(sid) {
                        return Err(format!("scene not found: {sid}"));
                    }
                }
                _ => {}
            }
        }
        self.terminal.arena[id.0 as usize]
            .event_handler
            .push(event, caller, action)
    }

    // ------------------------------------------------------------------
    // motion (Motion.activate_path / Path.step / Motion.move)
    // ------------------------------------------------------------------

    /// Motion.activate_path.
    pub fn activate_path(&mut self, hooks: &mut dyn EffectHooks, id: CharId, path_id: &str) {
        let (current_coord, first_waypoint) = {
            let ch = &self.terminal.arena[id.0 as usize];
            let path = ch
                .motion
                .paths
                .get(path_id)
                .expect("activate_path: path not found");
            assert!(
                !path.waypoints.is_empty(),
                "activate_path: empty path {path_id}"
            );
            (ch.motion.current_coord, path.waypoints[0].clone())
        };
        let distance_to_first_waypoint = match &first_waypoint.bezier_control {
            Some(control) => {
                geometry::find_length_of_bezier_curve(current_coord, control, first_waypoint.coord)
            }
            None => geometry::find_length_of_line(current_coord, first_waypoint.coord, true),
        };
        let new_origin_segment = Segment::new(Path::ORIGIN, 0, distance_to_first_waypoint);
        let layer = {
            let ch = &mut self.terminal.arena[id.0 as usize];
            ch.motion.active_path = ch.motion.paths.shared_key(path_id);
            let path = ch.motion.paths.get_mut(path_id).unwrap();
            path.origin_waypoint = Some(Waypoint {
                waypoint_id: ORIGIN_WAYPOINT_ID.with(Rc::clone),
                coord: current_coord,
                bezier_control: None,
            });
            path.total_distance += distance_to_first_waypoint;
            if let Some(origin) = &path.origin_segment {
                path.total_distance -= origin.distance;
                path.segments[0] = new_origin_segment;
            } else {
                path.segments.insert(0, new_origin_segment);
            }
            path.origin_segment = Some(new_origin_segment);
            path.current_step = 0;
            path.hold_time_remaining = path.hold_time;
            path.max_steps = round_half_even(path.total_distance / path.speed);
            for segment in path.segments.iter_mut() {
                segment.enter_event_triggered = false;
                segment.exit_event_triggered = false;
            }
            path.layer
        };
        if let Some(layer) = layer {
            self.terminal.arena[id.0 as usize].layer = layer;
        }
        if self.observes_event(id, Event::PathActivated) {
            self.handle_event(hooks, id, Event::PathActivated, CallerRef::Path(path_id));
        }
    }

    /// Path.step on the given path of `id`. Index-based segment walk with
    /// re-borrow per access so reentrant mutation behaves like Python.
    ///
    /// The path's slot is resolved once and re-resolved after every emission,
    /// since only a reentrant action can move or drop it.
    fn path_step(&mut self, hooks: &mut dyn EffectHooks, id: CharId, path_id: &str) -> Coord {
        let mut slot = self.terminal.arena[id.0 as usize]
            .motion
            .paths
            .slot(path_id)
            .expect("path_step: path removed mid-step");
        macro_rules! path {
            () => {
                self.terminal.arena[id.0 as usize].motion.paths.at(slot)
            };
        }
        macro_rules! path_mut {
            () => {
                self.terminal.arena[id.0 as usize].motion.paths.at_mut(slot)
            };
        }
        macro_rules! resolve_slot {
            () => {
                slot = self.terminal.arena[id.0 as usize]
                    .motion
                    .paths
                    .slot(path_id)
                    .expect("path_step: path removed mid-step")
            };
        }

        let mut distance_to_travel = {
            let p = path_mut!();
            if p.max_steps == 0 || p.current_step >= p.max_steps || p.total_distance == 0.0 {
                return p
                    .waypoint_at(p.segments.last().expect("path has no segments").end)
                    .coord;
            }
            p.current_step += 1;
            let ratio = p.current_step as f64 / p.max_steps as f64;
            let distance_factor = match &p.ease {
                Some(ease) => ease.ease(ratio),
                None => ratio,
            };
            let distance = distance_factor * p.total_distance;
            p.last_distance_reached = distance;
            distance
        };

        let mut active_segment_index: Option<usize> = None;
        let mut i = 0usize;
        loop {
            let (seg_distance, enter_triggered, exit_triggered) = {
                let p = path!();
                if i >= p.segments.len() {
                    break;
                }
                let seg = &p.segments[i];
                (
                    seg.distance,
                    seg.enter_event_triggered,
                    seg.exit_event_triggered,
                )
            };
            if distance_to_travel <= seg_distance {
                active_segment_index = Some(i);
                if !enter_triggered {
                    if self.observes_event(id, Event::SegmentEntered) {
                        let seg_end_key = {
                            let p = path!();
                            p.waypoint_at(p.segments[i].end).key()
                        };
                        path_mut!().segments[i].enter_event_triggered = true;
                        self.handle_event(
                            hooks,
                            id,
                            Event::SegmentEntered,
                            CallerRef::Waypoint(&seg_end_key),
                        );
                        resolve_slot!();
                    } else {
                        path_mut!().segments[i].enter_event_triggered = true;
                    }
                }
                break;
            }
            distance_to_travel -= seg_distance;
            if !enter_triggered || !exit_triggered {
                let observes = self.observes_event(id, Event::SegmentEntered)
                    || self.observes_event(id, Event::SegmentExited);
                if !observes {
                    let seg = &mut path_mut!().segments[i];
                    seg.enter_event_triggered = true;
                    seg.exit_event_triggered = true;
                } else {
                    let seg_end_key = {
                        let p = path!();
                        p.waypoint_at(p.segments[i].end).key()
                    };
                    if !enter_triggered {
                        path_mut!().segments[i].enter_event_triggered = true;
                        self.handle_event(
                            hooks,
                            id,
                            Event::SegmentEntered,
                            CallerRef::Waypoint(&seg_end_key),
                        );
                        resolve_slot!();
                    }
                    if !exit_triggered {
                        path_mut!().segments[i].exit_event_triggered = true;
                        self.handle_event(
                            hooks,
                            id,
                            Event::SegmentExited,
                            CallerRef::Waypoint(&seg_end_key),
                        );
                        resolve_slot!();
                    }
                }
            }
            i += 1;
        }
        // Python for-else: overshoot past the last waypoint re-adds the final
        // segment's distance and travels beyond it (eased overshoot).
        let active_segment_index = match active_segment_index {
            Some(idx) => idx,
            None => {
                let p = path!();
                let idx = p.segments.len() - 1;
                distance_to_travel += p.segments[idx].distance;
                idx
            }
        };

        let p = path!();
        let seg = &p.segments[active_segment_index];
        let seg_distance = seg.distance;
        let t = if seg_distance == 0.0 {
            0.0
        } else if p.ease.is_some() {
            distance_to_travel / seg_distance // unclamped: eased overshoot goes past the waypoint
        } else {
            (distance_to_travel / seg_distance).min(1.0)
        };
        let start = p.waypoint_at(seg.start);
        let end = p.waypoint_at(seg.end);
        match &end.bezier_control {
            Some(control) => {
                geometry::find_coord_on_bezier_curve(start.coord, control, end.coord, t)
            }
            None => geometry::find_coord_on_line(start.coord, end.coord, t),
        }
    }

    /// Motion.move.
    pub fn motion_move(&mut self, hooks: &mut dyn EffectHooks, id: CharId) {
        {
            let motion = &mut self.terminal.arena[id.0 as usize].motion;
            motion.previous_coord = motion.current_coord;
        }
        let Some(path_id) = ({
            let motion = &self.terminal.arena[id.0 as usize].motion;
            match &motion.active_path {
                Some(pid) if !motion.paths.get(pid).is_none_or(|p| p.segments.is_empty()) => {
                    Some(pid.clone())
                }
                _ => None,
            }
        }) else {
            return;
        };
        let new_coord = self.path_step(hooks, id, &path_id);
        self.terminal.arena[id.0 as usize].motion.current_coord = new_coord;

        // Python re-reads self.active_path after step (a callback may have
        // swapped it); None here would be an upstream AttributeError.
        let active_path_id = self.terminal.arena[id.0 as usize]
            .motion
            .active_path
            .clone()
            .expect("active path cleared mid-move (would be an upstream crash)");
        let slot = self.terminal.arena[id.0 as usize]
            .motion
            .paths
            .slot(&active_path_id)
            .expect("active path missing");
        let (current_step, max_steps, hold_time, hold_time_remaining, loop_, segment_count) = {
            let p = self.terminal.arena[id.0 as usize].motion.paths.at(slot);
            (
                p.current_step,
                p.max_steps,
                p.hold_time,
                p.hold_time_remaining,
                p.loop_,
                p.segments.len(),
            )
        };
        if current_step == max_steps {
            if hold_time != 0 && hold_time_remaining == hold_time {
                if self.observes_event(id, Event::PathHolding) {
                    self.handle_event(
                        hooks,
                        id,
                        Event::PathHolding,
                        CallerRef::Path(&active_path_id),
                    );
                }
                self.terminal.arena[id.0 as usize]
                    .motion
                    .paths
                    .get_mut(&active_path_id)
                    .unwrap()
                    .hold_time_remaining -= 1;
                return;
            }
            if hold_time_remaining != 0 {
                self.terminal.arena[id.0 as usize]
                    .motion
                    .paths
                    .at_mut(slot)
                    .hold_time_remaining -= 1;
                return;
            }
            if loop_ && segment_count > 1 {
                self.terminal.arena[id.0 as usize]
                    .motion
                    .deactivate_path(Some(&active_path_id));
                self.activate_path(hooks, id, &active_path_id);
            } else {
                {
                    let motion = &mut self.terminal.arena[id.0 as usize].motion;
                    motion.completed_path = Some(active_path_id.clone());
                    motion.deactivate_path(Some(&active_path_id));
                }
                if self.observes_event(id, Event::PathComplete) {
                    self.handle_event(
                        hooks,
                        id,
                        Event::PathComplete,
                        CallerRef::Path(&active_path_id),
                    );
                }
            }
        }
    }

    /// Motion.chain_paths.
    pub fn chain_paths(&mut self, id: CharId, paths: &[String], loop_: bool) -> Result<(), String> {
        if paths.len() < 2 {
            return Ok(());
        }
        for i in 1..paths.len() {
            self.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(paths[i - 1].clone()),
                EventAction::ActivatePath(paths[i].clone()),
            )?;
        }
        if loop_ {
            self.register_event(
                id,
                Event::PathComplete,
                CallerKey::Path(paths[paths.len() - 1].clone()),
                EventAction::ActivatePath(paths[0].clone()),
            )?;
        }
        Ok(())
    }

    // ------------------------------------------------------------------
    // animation (Animation.activate_scene / step_animation)
    // ------------------------------------------------------------------

    /// Animation.activate_scene: does NOT reset playback (resume semantics).
    pub fn activate_scene(&mut self, hooks: &mut dyn EffectHooks, id: CharId, scene_id: &str) {
        {
            let ch = &mut self.terminal.arena[id.0 as usize];
            let visual = ch
                .animation
                .scenes
                .get(scene_id)
                .expect("activate_scene: scene not found")
                .activate()
                .expect("activate_scene: empty scene");
            ch.animation.active_scene = ch.animation.scenes.shared_key(scene_id);
            ch.animation.active_scene_current_step = 0;
            ch.animation.current_character_visual = visual;
        }
        if self.observes_event(id, Event::SceneActivated) {
            self.handle_event(hooks, id, Event::SceneActivated, CallerRef::Scene(scene_id));
        }
    }

    /// Animation.deactivate_scene.
    pub fn deactivate_scene(&mut self, id: CharId, scene_id: Option<&str>) {
        let animation = &mut self.terminal.arena[id.0 as usize].animation;
        match scene_id {
            None => animation.active_scene = None,
            Some(sid) => {
                if animation.active_scene.as_deref() == Some(sid) {
                    animation.active_scene = None;
                }
            }
        }
    }

    /// Animation.step_animation.
    ///
    /// Nothing between here and complete_scene_if_finished can add or remove a
    /// scene, so the active scene's slot is resolved once and reused instead of
    /// looking the id up again at every step.
    pub fn step_animation(&mut self, hooks: &mut dyn EffectHooks, id: CharId) {
        let Some(scene_slot) = ({
            let anim = &self.terminal.arena[id.0 as usize].animation;
            match &anim.active_scene {
                Some(sid) => {
                    let slot = anim.scenes.slot(sid).expect("active scene missing");
                    (!anim.scenes.at(slot).frames.is_empty()).then_some(slot)
                }
                None => None,
            }
        }) else {
            return;
        };

        let (sync, ease) = {
            let scene = self.terminal.arena[id.0 as usize]
                .animation
                .scenes
                .at(scene_slot);
            (scene.sync, scene.ease)
        };

        if let Some(sync) = sync {
            self.step_synced_scene(id, scene_slot, sync);
        } else if let Some(ease) = ease {
            self.step_eased_scene(id, scene_slot, ease);
        } else {
            let ch = &mut self.terminal.arena[id.0 as usize];
            let visual = ch.animation.scenes.at_mut(scene_slot).get_next_visual();
            ch.animation.current_character_visual = visual;
        }

        self.complete_scene_if_finished(hooks, id, scene_slot);
    }

    /// Animation._step_synced_scene + _synced_scene_frame_index.
    fn step_synced_scene(&mut self, id: CharId, scene_slot: usize, sync: SyncMetric) {
        let active_path_state = {
            let ch = &self.terminal.arena[id.0 as usize];
            ch.motion.active_path.as_ref().map(|pid| {
                let p = ch.motion.paths.get(pid).expect("active path missing");
                (
                    p.current_step,
                    p.max_steps,
                    p.total_distance,
                    p.last_distance_reached,
                )
            })
        };
        let ch = &mut self.terminal.arena[id.0 as usize];
        let scene = ch.animation.scenes.at_mut(scene_slot);
        match active_path_state {
            None => {
                // no active path: jump to final frame and force-complete
                let last = *scene.frames.back().unwrap();
                ch.animation.current_character_visual = scene.all_frames[last].character_visual;
                scene.played_frames.append(&mut scene.frames);
            }
            Some((current_step, max_steps, total_distance, last_distance_reached)) => {
                let final_frame_index = scene.frames.len() as i64 - 1;
                let progress_ratio = match sync {
                    SyncMetric::Step => current_step.max(1) as f64 / max_steps.max(1) as f64,
                    SyncMetric::Distance => {
                        let total = total_distance.max(1.0);
                        let remaining = (total_distance - last_distance_reached).max(1.0);
                        let reached = (total - remaining).max(1.0);
                        reached / total
                    }
                };
                let frame_index = round_half_even(final_frame_index as f64 * progress_ratio)
                    .min(final_frame_index)
                    .max(0);
                let frame = scene.frames[frame_index as usize];
                ch.animation.current_character_visual = scene.all_frames[frame].character_visual;
            }
        }
    }

    /// Animation._step_eased_scene (+ _ease_animation).
    fn step_eased_scene(
        &mut self,
        id: CharId,
        scene_slot: usize,
        ease: crate::utils::easing::Easing,
    ) {
        let ch = &mut self.terminal.arena[id.0 as usize];
        let scene = ch.animation.scenes.at_mut(scene_slot);
        let elapsed_step_ratio = scene.easing_current_step as f64 / scene.easing_total_steps as f64;
        let easing_factor = ease.ease(elapsed_step_ratio);
        let final_frame_index = (scene.easing_total_steps - 1).max(0);
        let frame_index = round_half_even(easing_factor * final_frame_index as f64)
            .min(final_frame_index)
            .max(0);
        let frame = scene.frame_index_map[frame_index as usize];
        ch.animation.current_character_visual = scene.all_frames[frame].character_visual;

        scene.easing_current_step += 1;
        if scene.easing_current_step == scene.easing_total_steps {
            if scene.is_looping {
                scene.easing_current_step = 0;
            } else {
                scene.played_frames.append(&mut scene.frames);
            }
        }
    }

    /// Animation._complete_scene_if_finished: fires SCENE_COMPLETE every tick
    /// for looping scenes, faithfully.
    fn complete_scene_if_finished(
        &mut self,
        hooks: &mut dyn EffectHooks,
        id: CharId,
        scene_slot: usize,
    ) {
        {
            // The stepping above cannot clear active_scene, so the slot still
            // holds it and active_scene_is_complete reduces to its scene test.
            let anim = &self.terminal.arena[id.0 as usize].animation;
            let scene = anim.scenes.at(scene_slot);
            if !(scene.frames.is_empty() || scene.is_looping) {
                return;
            }
        }
        {
            let anim = &mut self.terminal.arena[id.0 as usize].animation;
            let scene = anim.scenes.at_mut(scene_slot);
            if !scene.is_looping {
                scene.reset_scene();
                anim.active_scene = None;
            }
        }
        if self.observes_event(id, Event::SceneComplete) {
            let scene_id = Rc::clone(
                self.terminal.arena[id.0 as usize]
                    .animation
                    .scenes
                    .key_at(scene_slot),
            );
            self.handle_event(hooks, id, Event::SceneComplete, CallerRef::Scene(&scene_id));
        }
    }

    // ------------------------------------------------------------------
    // ticking (EffectCharacter.tick / BaseEffectIterator.update / frame)
    // ------------------------------------------------------------------

    /// EffectCharacter.tick: motion first, then animation.
    pub fn tick(&mut self, hooks: &mut dyn EffectHooks, id: CharId) {
        self.motion_move(hooks, id);
        self.step_animation(hooks, id);
    }

    /// BaseEffectIterator.update: tick a snapshot of active characters in
    /// canonical ascending-id order, then prune the not-is_active ones.
    pub fn update(&mut self, hooks: &mut dyn EffectHooks) {
        let mut snapshot = std::mem::take(&mut self.active_character_scratch);
        snapshot.clear();
        snapshot.extend(self.active_characters.iter());
        for &id in &snapshot {
            self.tick(hooks, id);
        }
        snapshot.clear();
        self.active_character_scratch = snapshot;

        let arena = &self.terminal.arena;
        self.active_characters
            .retain(|id| arena[id.0 as usize].is_active());
    }

    /// BaseEffectIterator.frame: enforce framerate (real clock only), then the
    /// formatted output string; advances the virtual clock by one frame.
    pub fn frame(&mut self) -> String {
        if matches!(self.clock, Clock::Real { .. }) && self.terminal.config.frame_rate != 0 {
            self.terminal.enforce_framerate();
        }
        self.clock.advance_frame();
        if self.structured_output {
            self.terminal.visit_render_cells(|_| {});
            String::new()
        } else {
            self.terminal.get_formatted_output_string()
        }
    }
}

#[cfg(test)]
mod structured_frame_tests {
    use super::*;

    #[test]
    fn structured_mode_refreshes_cells_without_building_ansi() {
        let config = TerminalConfig {
            canvas_width: 1,
            canvas_height: 1,
            ignore_terminal_dimensions: true,
            ..TerminalConfig::default()
        };
        let mut ctx = EngineCtx::new(
            "A",
            config,
            Rng::seeded(7),
            Clock::virtual_with_frame_rate(60),
        )
        .unwrap();
        let input = ctx.terminal.input_characters[0];
        ctx.terminal.set_character_visibility(input, true);
        ctx.set_structured_output(true);

        assert!(ctx.frame().is_empty());
        let mut symbol = None;
        ctx.terminal.visit_render_cells(|visual| {
            symbol = visual.and_then(|visual| visual.symbol.chars().next());
        });
        assert_eq!(symbol, Some('A'));
    }
}
