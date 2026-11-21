use clap::Parser;
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::ptr;
use ttfx::cli::Cli;
use ttfx::engine::animation::CharacterVisual;
use ttfx::engine::ctx::{Clock, EngineCtx};
use ttfx::engine::effect::Effect;
use ttfx::utils::rng::Rng;

pub const CELL_FLAG_FG: u32 = 1 << 0;
pub const CELL_FLAG_BG: u32 = 1 << 1;
pub const CELL_FLAG_BOLD: u32 = 1 << 2;
pub const CELL_FLAG_DIM: u32 = 1 << 3;
pub const CELL_FLAG_ITALIC: u32 = 1 << 4;
pub const CELL_FLAG_UNDERLINE: u32 = 1 << 5;
pub const CELL_FLAG_BLINK: u32 = 1 << 6;
pub const CELL_FLAG_REVERSE: u32 = 1 << 7;
pub const CELL_FLAG_HIDDEN: u32 = 1 << 8;
pub const CELL_FLAG_STRIKE: u32 = 1 << 9;
pub const MAX_WIDTH: usize = 162;
pub const MAX_HEIGHT: usize = 40;
pub const MAX_CELLS: usize = 4_800;
pub const MAX_FPS: u32 = 240;
pub const MAX_EFFECT_NAME_BYTES: usize = 128;
pub const MAX_INPUT_BYTES: usize = 64 * 1024;
pub const TTFX_STATUS_OK: i32 = 0;
pub const TTFX_STATUS_INVALID_ARGUMENT: i32 = 1;
pub const TTFX_STATUS_INVALID_EFFECT: i32 = 2;
pub const TTFX_STATUS_INVALID_DIMENSIONS: i32 = 3;
pub const TTFX_STATUS_INVALID_FRAME_RATE: i32 = 4;
pub const TTFX_STATUS_INVALID_UTF8: i32 = 5;
pub const TTFX_STATUS_OVERFLOW: i32 = 6;
pub const TTFX_STATUS_ENGINE_ERROR: i32 = 7;
pub const TTFX_STATUS_PANIC: i32 = 8;
pub const TTFX_STATUS_INPUT_TOO_LARGE: i32 = 9;
pub const TTFX_STATUS_POISONED: i32 = 10;
pub const TTFX_STATUS_UNAVAILABLE: i32 = 11;
pub const TTFX_STATUS_INVALID_STATE: i32 = 12;
/// Upper bound for [`Engine::record_history`] keyframes.
pub const MAX_HISTORY_FRAMES: usize = 4_096;
/// Upper bound for the draw calls of one reverse playback.
pub const MAX_REVERSE_CALLS: u32 = 100_000;
const DISSOLVE_MIN_CELLS_PER_CALL: usize = 8;
const BLANK_CELL: Cell = Cell {
    codepoint: 0x20,
    fg_rgba: 0,
    bg_rgba: 0,
    flags: 0,
};

#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Cell {
    pub codepoint: u32,
    pub fg_rgba: u32,
    pub bg_rgba: u32,
    pub flags: u32,
}

#[derive(Debug, PartialEq, Eq)]
pub enum EngineError {
    InvalidEffect,
    InvalidDimensions,
    InvalidFrameRate,
    Overflow,
    Build,
    InputTooLarge,
    /// An argument is outside its documented range.
    InvalidArgument,
    /// The call does not apply to the engine's current playback state.
    InvalidState,
    /// Reverse playback was requested without a usable recorded history.
    Unavailable,
}

pub fn validate_canvas(width: usize, height: usize) -> Result<usize, EngineError> {
    let cells = width.checked_mul(height).ok_or(EngineError::Overflow)?;
    if width == 0 || height == 0 || width > MAX_WIDTH || height > MAX_HEIGHT || cells > MAX_CELLS {
        return Err(EngineError::InvalidDimensions);
    }
    Ok(cells)
}

#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum StepOutcome {
    Frame = 0,
    Completed = 1,
}

struct Parameters {
    effect_name: String,
    seed: u64,
    input: String,
    width: u32,
    height: u32,
    fps: u32,
    background_rgb: u32,
}

/// One recorded frame, stored run-length encoded unless that is larger.
enum FrameData {
    Raw(Box<[Cell]>),
    Runs(Box<[Run]>),
}

#[derive(Clone, Copy)]
struct Run {
    length: u32,
    cell: Cell,
}

struct Keyframe {
    index: u64,
    data: FrameData,
}

impl Keyframe {
    fn bytes(&self) -> usize {
        match &self.data {
            FrameData::Raw(cells) => std::mem::size_of_val(&cells[..]),
            FrameData::Runs(runs) => std::mem::size_of_val(&runs[..]),
        }
    }

    fn decode_into(&self, cells: &mut [Cell]) {
        match &self.data {
            FrameData::Raw(raw) => cells.copy_from_slice(raw),
            FrameData::Runs(runs) => {
                let mut offset = 0;
                for run in runs.iter() {
                    let end = offset + run.length as usize;
                    cells[offset..end].fill(run.cell);
                    offset = end;
                }
                debug_assert_eq!(offset, cells.len());
            }
        }
    }
}

/// Bounded, decimating record of the forward playback of the current cycle:
/// frames whose index (relative to the first recorded one) is a multiple of
/// `stride`. When a limit is exceeded every other keyframe is dropped and the
/// stride doubles, so the record always spans the whole cycle evenly.
struct History {
    max_frames: usize,
    max_bytes: usize,
    base: u64,
    stride: u64,
    bytes: usize,
    frames: Vec<Keyframe>,
}

impl History {
    fn new(max_frames: usize, max_bytes: usize) -> Option<Self> {
        let mut frames = Vec::new();
        frames.try_reserve_exact(max_frames.min(256) + 1).ok()?;
        Some(Self {
            max_frames,
            max_bytes,
            base: 0,
            stride: 1,
            bytes: 0,
            frames,
        })
    }

    fn restart(&mut self, base: u64) {
        self.frames.clear();
        self.base = base;
        self.stride = 1;
        self.bytes = 0;
    }

    /// Records `cells` as frame `index`. Err only on allocation failure.
    fn record(&mut self, index: u64, cells: &[Cell]) -> Result<(), ()> {
        if self.frames.is_empty() {
            self.base = index;
        }
        let relative = index.wrapping_sub(self.base);
        if index < self.base || !relative.is_multiple_of(self.stride) {
            return Ok(());
        }
        let keyframe = Keyframe {
            index,
            data: encode(cells)?,
        };
        self.frames.try_reserve(1).map_err(|_| ())?;
        self.bytes += keyframe.bytes();
        self.frames.push(keyframe);
        while (self.frames.len() > self.max_frames || self.bytes > self.max_bytes)
            && self.stride <= u64::MAX / 2
        {
            let stride = self.stride * 2;
            let base = self.base;
            self.frames
                .retain(|frame| (frame.index - base).is_multiple_of(stride));
            self.stride = stride;
            self.bytes = self.frames.iter().map(Keyframe::bytes).sum();
        }
        Ok(())
    }

    /// The latest keyframe at or before relative frame `relative`.
    fn at_or_before(&self, relative: u64) -> Option<&Keyframe> {
        let index = self.base.saturating_add(relative);
        let position = self.frames.partition_point(|frame| frame.index <= index);
        position.checked_sub(1).map(|position| &self.frames[position])
    }
}

fn encode(cells: &[Cell]) -> Result<FrameData, ()> {
    let mut run_count = 0usize;
    let mut previous: Option<Cell> = None;
    for cell in cells {
        if previous != Some(*cell) {
            run_count += 1;
            previous = Some(*cell);
        }
    }
    if run_count * std::mem::size_of::<Run>() < std::mem::size_of_val(cells) {
        let mut runs: Vec<Run> = Vec::new();
        runs.try_reserve_exact(run_count).map_err(|_| ())?;
        for cell in cells {
            match runs.last_mut() {
                Some(run) if run.cell == *cell => run.length += 1,
                _ => runs.push(Run {
                    length: 1,
                    cell: *cell,
                }),
            }
        }
        Ok(FrameData::Runs(runs.into_boxed_slice()))
    } else {
        let mut raw: Vec<Cell> = Vec::new();
        raw.try_reserve_exact(cells.len()).map_err(|_| ())?;
        raw.extend_from_slice(cells);
        Ok(FrameData::Raw(raw.into_boxed_slice()))
    }
}

/// True when the plugin's renderer would paint anything for this cell.
pub fn cell_is_visible(cell: &Cell) -> bool {
    cell.flags & (CELL_FLAG_BG | CELL_FLAG_REVERSE) != 0
        || (cell.flags & CELL_FLAG_FG != 0
            && cell.flags & CELL_FLAG_HIDDEN == 0
            && cell.codepoint != 0
            && cell.codepoint != u32::from(' '))
}

/// What one reverse draw call exposes.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ReverseFrame {
    /// A recorded forward frame, by its index in the current cycle.
    History(u64),
    /// The first recorded frame with this many of its visible cells cleared.
    Dissolve(usize),
    /// The blank canvas: only the embedding background remains.
    Blank,
}

/// Position of an active reverse playback, for diagnostics and tests.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ReversePosition {
    /// Draw calls made so far (0 right after `begin_reverse`).
    pub call: u32,
    /// Total draw calls; the last one exposes the blank canvas.
    pub calls: u32,
    /// Calls that walk back through the recorded frames.
    pub history_calls: u32,
    /// Calls that dissolve what the first recorded frame still shows.
    pub dissolve_calls: u32,
    /// The frame exposed by the latest call, if any.
    pub frame: Option<ReverseFrame>,
}

struct Reverse {
    span: u64,
    calls: u32,
    history_calls: u32,
    dissolve_calls: u32,
    done: u32,
    first: Vec<Cell>,
    order: Vec<u16>,
    frame: Option<ReverseFrame>,
}

pub struct Engine {
    parameters: Parameters,
    effect: Box<dyn Effect>,
    ctx: EngineCtx,
    cells: Vec<Cell>,
    width: usize,
    height: usize,
    completed: bool,
    /// Index of the exposed forward frame in the current cycle.
    frame_index: u64,
    history: Option<History>,
    reverse: Option<Reverse>,
}

/// Opaque C handle. It must be used and freed on the creating thread.
pub struct TtfxEngine {
    inner: Engine,
    poisoned: bool,
}

/// Playback mode for [`Engine::draw_logo`].
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum LogoMode {
    /// Plays the animation endlessly, seamlessly restarting at the end.
    Loop,
    /// Plays the animation exactly once. Once playback completes, the final
    /// frame stays exposed through `cells()` and the outcome reports
    /// `StepOutcome::Completed` on every subsequent call.
    OneTime,
    /// Plays the recorded playback backwards after [`Engine::begin_reverse`],
    /// ending on the blank canvas. Returns `StepOutcome::Completed` once the
    /// blank canvas is exposed and on every later call.
    Reverse,
}

impl Engine {
    pub fn create(
        effect_name: &str,
        seed: u64,
        input: &str,
        width: u32,
        height: u32,
        fps: u32,
    ) -> Result<Self, EngineError> {
        Self::create_with_background(effect_name, seed, input, width, height, fps, 0x000000)
    }

    pub fn create_with_background(
        effect_name: &str,
        seed: u64,
        input: &str,
        width: u32,
        height: u32,
        fps: u32,
        background_rgb: u32,
    ) -> Result<Self, EngineError> {
        if input.len() > MAX_INPUT_BYTES {
            return Err(EngineError::InputTooLarge);
        }
        if fps == 0 || fps > MAX_FPS {
            return Err(EngineError::InvalidFrameRate);
        }
        let cell_count = validate_canvas(width as usize, height as usize)?;
        let parameters = Parameters {
            effect_name: effect_name.to_owned(),
            seed,
            input: input.to_owned(),
            width,
            height,
            fps,
            background_rgb,
        };
        let (effect, ctx) = build_instance(&parameters)?;
        let mut engine = Self {
            parameters,
            effect,
            ctx,
            cells: Vec::with_capacity(cell_count),
            width: width as usize,
            height: height as usize,
            completed: false,
            frame_index: 0,
            history: None,
            reverse: None,
        };
        engine
            .effect
            .next_frame(&mut engine.ctx)
            .ok_or(EngineError::Build)?;
        engine.snapshot();
        Ok(engine)
    }

    pub fn step(&mut self) -> Result<StepOutcome, EngineError> {
        if self.reverse.is_some() {
            return Err(EngineError::InvalidState);
        }
        if self.completed {
            return Ok(StepOutcome::Completed);
        }
        if self.effect.next_frame(&mut self.ctx).is_some() {
            self.snapshot();
            self.frame_index = self.frame_index.saturating_add(1);
            self.record_frame();
            Ok(StepOutcome::Frame)
        } else {
            self.completed = true;
            Ok(StepOutcome::Completed)
        }
    }

    /// Draws the logo according to `mode`. Every caller keeps its playback
    /// state exclusively through this function; the current frame is always
    /// available through `cells()` after the call.
    ///
    /// - [`LogoMode::Loop`]: advances the animation and, exactly at the tape
    ///   boundary, reconstructs the next cycle deterministically. Returns
    ///   `StepOutcome::Completed` only for the call that wrapped, so callers
    ///   can count cycles.
    /// - [`LogoMode::OneTime`]: advances the animation until it completes and
    ///   then holds the final frame; returns `StepOutcome::Completed` once
    ///   playback has finished and on every later call.
    /// - [`LogoMode::Reverse`]: exposes the next frame of the reverse
    ///   playback prepared by [`Engine::begin_reverse`]; returns
    ///   `StepOutcome::Completed` once the blank canvas is exposed and on
    ///   every later call.
    pub fn draw_logo(&mut self, mode: LogoMode) -> Result<StepOutcome, EngineError> {
        match mode {
            LogoMode::Reverse => self.reverse_step(),
            LogoMode::OneTime => self.step(),
            LogoMode::Loop => match self.step()? {
                StepOutcome::Completed => {
                    self.reset()?;
                    Ok(StepOutcome::Completed)
                }
                StepOutcome::Frame => Ok(StepOutcome::Frame),
            },
        }
    }

    pub fn reset(&mut self) -> Result<(), EngineError> {
        self.restart()?;
        self.reverse = None;
        self.snapshot();
        self.completed = false;
        self.frame_index = 0;
        if let Some(history) = self.history.as_mut() {
            history.restart(0);
        }
        self.record_frame();
        Ok(())
    }

    /// Starts (or, with `max_frames == 0`, stops) recording the forward
    /// playback so it can later be played backwards. Recording only reads the
    /// exposed frames: forward playback stays byte-identical. The current
    /// frame is the first one recorded; each reset or loop restart begins a
    /// new record. `max_frames` (2..=MAX_HISTORY_FRAMES) and `max_bytes` (at
    /// least one uncompressed frame) bound the record; past either bound,
    /// every other keyframe is dropped. A later allocation failure silently
    /// drops the record, and `begin_reverse` then reports `Unavailable`.
    pub fn record_history(&mut self, max_frames: usize, max_bytes: usize) -> Result<(), EngineError> {
        if self.reverse.is_some() {
            return Err(EngineError::InvalidState);
        }
        if max_frames == 0 {
            self.history = None;
            return Ok(());
        }
        if !(2..=MAX_HISTORY_FRAMES).contains(&max_frames)
            || max_bytes < std::mem::size_of_val(&self.cells[..])
        {
            return Err(EngineError::InvalidArgument);
        }
        self.history = None;
        let mut history = History::new(max_frames, max_bytes).ok_or(EngineError::Unavailable)?;
        history.restart(self.frame_index);
        history
            .record(self.frame_index, &self.cells)
            .map_err(|_| EngineError::Unavailable)?;
        self.history = Some(history);
        Ok(())
    }

    /// Bytes currently held by the recorded history (0 without one).
    pub fn history_bytes(&self) -> usize {
        self.history.as_ref().map_or(0, |history| {
            history.bytes + history.frames.capacity() * std::mem::size_of::<Keyframe>()
        })
    }

    /// Number of recorded keyframes (0 without a history).
    pub fn history_frames(&self) -> usize {
        self.history.as_ref().map_or(0, |history| history.frames.len())
    }

    /// Prepares a reverse playback of at most `max_calls` draw calls from the
    /// exposed frame back to the first recorded frame of the current cycle,
    /// then dissolves whatever that frame still shows, and ends on the blank
    /// canvas with the last call. The recorded frames are walked at no less
    /// than `frames_per_call` frames per call, faster when the record does
    /// not fit. Returns the exact number of draw calls (1..=max_calls).
    pub fn begin_reverse(&mut self, max_calls: u32, frames_per_call: u32) -> Result<u32, EngineError> {
        if max_calls == 0 || max_calls > MAX_REVERSE_CALLS || frames_per_call == 0 {
            return Err(EngineError::InvalidArgument);
        }
        if self.reverse.is_some() {
            return Err(EngineError::InvalidState);
        }
        let history = self.history.as_ref().ok_or(EngineError::Unavailable)?;
        let earliest = history.frames.first().ok_or(EngineError::Unavailable)?;
        let span = self.frame_index.saturating_sub(earliest.index);
        let mut first: Vec<Cell> = Vec::new();
        first
            .try_reserve_exact(self.cells.len())
            .map_err(|_| EngineError::Unavailable)?;
        first.resize(self.cells.len(), BLANK_CELL);
        earliest.decode_into(&mut first);
        let visible_first = first.iter().filter(|cell| cell_is_visible(cell)).count();
        let visible_now = self.cells.iter().filter(|cell| cell_is_visible(cell)).count();
        let mut order: Vec<u16> = Vec::new();
        order
            .try_reserve_exact(visible_first)
            .map_err(|_| EngineError::Unavailable)?;
        order.extend(
            first
                .iter()
                .enumerate()
                .filter(|(_, cell)| cell_is_visible(cell))
                .map(|(index, _)| index as u16),
        );
        // Deterministic Fisher-Yates shuffle (splitmix64 on the effect seed):
        // the dissolve clears the remaining cells in a scattered order.
        let mut state = self.parameters.seed ^ 0x6f75_7472_6f5f_7474;
        for index in (1..order.len()).rev() {
            state = state.wrapping_add(0x9e37_79b9_7f4a_7c15);
            let mut mixed = state;
            mixed = (mixed ^ (mixed >> 30)).wrapping_mul(0xbf58_476d_1ce4_e5b9);
            mixed = (mixed ^ (mixed >> 27)).wrapping_mul(0x94d0_49bb_1331_11eb);
            mixed ^= mixed >> 31;
            order.swap(index, (mixed % (index as u64 + 1)) as usize);
        }

        let available = max_calls - 1;
        let dissolve_calls = if visible_first == 0 || available == 0 {
            0
        } else {
            // The dissolve's share of the calls follows how much of the
            // canvas the first frame still covers compared with the exposed
            // one, clearing at least DISSOLVE_MIN_CELLS_PER_CALL cells per
            // call so a nearly empty first frame takes no visible time.
            let share = u64::from(available) * visible_first as u64
                / (visible_first + visible_now) as u64;
            let paced = visible_first.div_ceil(DISSOLVE_MIN_CELLS_PER_CALL) as u64;
            (share.min(paced) as u32).clamp(1, available)
        };
        let wanted = span.div_ceil(u64::from(frames_per_call));
        let history_calls = wanted.min(u64::from(available - dissolve_calls)) as u32;
        let calls = history_calls + dissolve_calls + 1;
        self.reverse = Some(Reverse {
            span,
            calls,
            history_calls,
            dissolve_calls,
            done: 0,
            first,
            order,
            frame: None,
        });
        Ok(calls)
    }

    /// Position of the active reverse playback, if any.
    pub fn reverse_position(&self) -> Option<ReversePosition> {
        self.reverse.as_ref().map(|reverse| ReversePosition {
            call: reverse.done,
            calls: reverse.calls,
            history_calls: reverse.history_calls,
            dissolve_calls: reverse.dissolve_calls,
            frame: reverse.frame,
        })
    }

    fn reverse_step(&mut self) -> Result<StepOutcome, EngineError> {
        let reverse = self.reverse.as_mut().ok_or(EngineError::InvalidState)?;
        if reverse.done >= reverse.calls {
            return Ok(StepOutcome::Completed);
        }
        reverse.done += 1;
        let call = reverse.done;
        if call <= reverse.history_calls {
            let remaining = u64::from(reverse.history_calls - call);
            let target = (u128::from(reverse.span) * u128::from(remaining)
                / u128::from(reverse.history_calls)) as u64;
            let keyframe = self
                .history
                .as_ref()
                .and_then(|history| history.at_or_before(target))
                .ok_or(EngineError::Unavailable)?;
            let relative = keyframe.index - self.history.as_ref().map_or(0, |h| h.base);
            keyframe.decode_into(&mut self.cells);
            reverse.frame = Some(ReverseFrame::History(relative));
            Ok(StepOutcome::Frame)
        } else if call < reverse.calls {
            let step = call - reverse.history_calls;
            let cleared = reverse.order.len() * step as usize / (reverse.dissolve_calls as usize + 1);
            self.cells.copy_from_slice(&reverse.first);
            for &index in &reverse.order[..cleared] {
                self.cells[usize::from(index)] = BLANK_CELL;
            }
            reverse.frame = Some(ReverseFrame::Dissolve(cleared));
            Ok(StepOutcome::Frame)
        } else {
            self.cells.fill(BLANK_CELL);
            reverse.frame = Some(ReverseFrame::Blank);
            Ok(StepOutcome::Completed)
        }
    }

    fn record_frame(&mut self) {
        if let Some(history) = self.history.as_mut() {
            if history.record(self.frame_index, &self.cells).is_err() {
                self.history = None;
            }
        }
    }

    fn restart(&mut self) -> Result<(), EngineError> {
        let (effect, ctx) = build_instance(&self.parameters)?;
        self.effect = effect;
        self.ctx = ctx;
        self.effect
            .next_frame(&mut self.ctx)
            .ok_or(EngineError::Build)?;
        Ok(())
    }

    pub fn dimensions(&self) -> (usize, usize) {
        (self.width, self.height)
    }

    pub fn cells(&self) -> &[Cell] {
        &self.cells
    }

    fn snapshot(&mut self) {
        let mut bottom_up = Vec::with_capacity(self.width * self.height);
        self.ctx
            .terminal
            .visit_render_cells(|visual| bottom_up.push(cell_from_visual(visual)));
        self.cells = top_to_bottom(&bottom_up, self.width, self.height);
    }
}

fn top_to_bottom<T: Clone>(bottom_up: &[T], width: usize, height: usize) -> Vec<T> {
    debug_assert_eq!(bottom_up.len(), width * height);
    let mut result = Vec::with_capacity(bottom_up.len());
    for row in (0..height).rev() {
        result.extend_from_slice(&bottom_up[row * width..(row + 1) * width]);
    }
    result
}

fn build_instance(parameters: &Parameters) -> Result<(Box<dyn Effect>, EngineCtx), EngineError> {
    let mut arguments = vec!["ttfx", parameters.effect_name.as_str()];
    if parameters.effect_name == "decrypt" {
        arguments.extend([
            "--final-gradient-stops",
            // Canonical Omarchy field colors, top to bottom. The vendored
            // final-text mapper applies the shared 4:3:4:3:5 row bands.
            "d0fdd9",
            "a8fcba",
            "82fb9c",
            "539e65",
            "2b5037",
            "--final-gradient-steps",
            "1",
            "1",
            "1",
            "1",
            "--final-gradient-direction",
            "vertical",
        ]);
    }
    let cli = Cli::try_parse_from(arguments).map_err(|_| EngineError::InvalidEffect)?;
    let mut config = cli.terminal_config();
    let command = cli.effect.ok_or(EngineError::InvalidEffect)?;
    config.canvas_width = i64::from(parameters.width);
    config.canvas_height = i64::from(parameters.height);
    config.frame_rate = i64::from(parameters.fps);
    config.ignore_terminal_dimensions = true;
    config.terminal_background_color =
        ttfx::utils::graphics::Color::from_hex(&format!("{:06x}", parameters.background_rgb))
            .map_err(|_| EngineError::Build)?;
    let mut ctx = EngineCtx::new(
        &parameters.input,
        config,
        Rng::seeded(parameters.seed),
        Clock::virtual_with_frame_rate(i64::from(parameters.fps)),
    )
    .map_err(|_| EngineError::Build)?;
    ctx.set_structured_output(true);
    ctx.final_text_bands = true;
    let mut effect = command.build_effect();
    effect.build(&mut ctx).map_err(|_| EngineError::Build)?;
    Ok((effect, ctx))
}

fn cell_from_visual(visual: Option<&CharacterVisual>) -> Cell {
    let Some(visual) = visual else {
        return Cell {
            codepoint: u32::from(' '),
            fg_rgba: 0,
            bg_rgba: 0,
            flags: 0,
        };
    };
    let mut flags = 0;
    let (fg_rgba, bg_rgba) = visual.colors.map_or((0, 0), |colors| {
        let fg = colors.fg_color.map_or(0, |color| {
            flags |= CELL_FLAG_FG;
            rgba(color.rgb_ints())
        });
        let bg = colors.bg_color.map_or(0, |color| {
            flags |= CELL_FLAG_BG;
            rgba(color.rgb_ints())
        });
        (fg, bg)
    });
    flags |= u32::from(visual.bold) * CELL_FLAG_BOLD;
    flags |= u32::from(visual.dim) * CELL_FLAG_DIM;
    flags |= u32::from(visual.italic) * CELL_FLAG_ITALIC;
    flags |= u32::from(visual.underline) * CELL_FLAG_UNDERLINE;
    flags |= u32::from(visual.blink) * CELL_FLAG_BLINK;
    flags |= u32::from(visual.reverse) * CELL_FLAG_REVERSE;
    flags |= u32::from(visual.hidden) * CELL_FLAG_HIDDEN;
    flags |= u32::from(visual.strike) * CELL_FLAG_STRIKE;
    Cell {
        codepoint: visual
            .symbol
            .chars()
            .next()
            .map_or(u32::from(' '), u32::from),
        fg_rgba,
        bg_rgba,
        flags,
    }
}

fn rgba((r, g, b): (u8, u8, u8)) -> u32 {
    (u32::from(r) << 24) | (u32::from(g) << 16) | (u32::from(b) << 8) | 0xff
}

fn status(error: EngineError) -> i32 {
    match error {
        EngineError::InvalidEffect => TTFX_STATUS_INVALID_EFFECT,
        EngineError::InvalidDimensions => TTFX_STATUS_INVALID_DIMENSIONS,
        EngineError::InvalidFrameRate => TTFX_STATUS_INVALID_FRAME_RATE,
        EngineError::Overflow => TTFX_STATUS_OVERFLOW,
        EngineError::Build => TTFX_STATUS_ENGINE_ERROR,
        EngineError::InputTooLarge => TTFX_STATUS_INPUT_TOO_LARGE,
        EngineError::InvalidArgument => TTFX_STATUS_INVALID_ARGUMENT,
        EngineError::InvalidState => TTFX_STATUS_INVALID_STATE,
        EngineError::Unavailable => TTFX_STATUS_UNAVAILABLE,
    }
}

fn ffi_boundary(operation: impl FnOnce() -> i32) -> i32 {
    catch_unwind(AssertUnwindSafe(operation)).unwrap_or(TTFX_STATUS_PANIC)
}

unsafe fn ffi_mutating_boundary(
    engine: *mut TtfxEngine,
    operation: impl FnOnce(&mut TtfxEngine) -> i32,
) -> i32 {
    if engine.is_null() {
        return TTFX_STATUS_INVALID_ARGUMENT;
    }
    let engine = unsafe { &mut *engine };
    if engine.poisoned {
        return TTFX_STATUS_POISONED;
    }
    match catch_unwind(AssertUnwindSafe(|| operation(engine))) {
        Ok(status) => status,
        Err(_) => {
            engine.poisoned = true;
            TTFX_STATUS_PANIC
        }
    }
}

unsafe fn bounded_c_str<'a>(value: *const std::ffi::c_char) -> Result<&'a str, i32> {
    if value.is_null() {
        return Err(TTFX_STATUS_INVALID_ARGUMENT);
    }
    let mut length = None;
    for index in 0..MAX_EFFECT_NAME_BYTES {
        if unsafe { *value.add(index) } == 0 {
            length = Some(index);
            break;
        }
    }
    let length = length.ok_or(TTFX_STATUS_INVALID_ARGUMENT)?;
    let bytes = unsafe { std::slice::from_raw_parts(value.cast::<u8>(), length) };
    std::str::from_utf8(bytes).map_err(|_| TTFX_STATUS_INVALID_UTF8)
}

/// Create an engine and expose its deterministic first frame. `input` is a byte
/// buffer. `effect` must point to memory readable through a NUL byte within
/// `MAX_EFFECT_NAME_BYTES` bytes.
/// On every failure `*out_engine` is set to null.
///
/// # Safety
///
/// All non-null pointers must be valid for the documented reads or writes.
/// The returned handle must be used only on its creating thread and freed once.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_create(
    effect: *const std::ffi::c_char,
    seed: u64,
    input: *const u8,
    input_len: usize,
    width: u32,
    height: u32,
    fps: u32,
    out_engine: *mut *mut TtfxEngine,
) -> i32 {
    unsafe {
        ttfx_engine_create_with_background(
            effect, seed, input, input_len, width, height, fps, 0x000000, out_engine,
        )
    }
}

/// Create an embedded engine whose terminal background matches its host surface.
/// `background_rgb` is a 24-bit `0xRRGGBB` color.
///
/// # Safety
///
/// The pointer requirements are identical to [`ttfx_engine_create`].
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_create_with_background(
    effect: *const std::ffi::c_char,
    seed: u64,
    input: *const u8,
    input_len: usize,
    width: u32,
    height: u32,
    fps: u32,
    background_rgb: u32,
    out_engine: *mut *mut TtfxEngine,
) -> i32 {
    ffi_boundary(|| {
        if out_engine.is_null() {
            return TTFX_STATUS_INVALID_ARGUMENT;
        }
        unsafe { *out_engine = ptr::null_mut() };
        if input_len > MAX_INPUT_BYTES {
            return TTFX_STATUS_INPUT_TOO_LARGE;
        }
        if input.is_null() && input_len != 0 {
            return TTFX_STATUS_INVALID_ARGUMENT;
        }
        let effect = match unsafe { bounded_c_str(effect) } {
            Ok(effect) => effect,
            Err(error) => return error,
        };
        let input_bytes = if input_len == 0 {
            &[]
        } else {
            unsafe { std::slice::from_raw_parts(input, input_len) }
        };
        let input = match std::str::from_utf8(input_bytes) {
            Ok(input) => input,
            Err(_) => return TTFX_STATUS_INVALID_UTF8,
        };
        match Engine::create_with_background(
            effect,
            seed,
            input,
            width,
            height,
            fps,
            background_rgb,
        ) {
            Ok(inner) => {
                unsafe {
                    *out_engine = Box::into_raw(Box::new(TtfxEngine {
                        inner,
                        poisoned: false,
                    }))
                };
                TTFX_STATUS_OK
            }
            Err(error) => status(error),
        }
    })
}

/// Advance one live frame. The legacy `out_looped` output is 1 on completion.
/// The terminal snapshot is retained; subsequent steps return 1 unchanged until
/// an explicit [`ttfx_engine_reset`].
///
/// # Safety
///
/// `engine` must be a live handle created by this library on the current thread,
/// and `out_looped` must be valid for one byte of writable memory.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_step(engine: *mut TtfxEngine, out_looped: *mut u8) -> i32 {
    if out_looped.is_null() {
        return TTFX_STATUS_INVALID_ARGUMENT;
    }
    unsafe { *out_looped = 0 };
    unsafe {
        ffi_mutating_boundary(engine, |engine| match engine.inner.step() {
            Ok(outcome) => {
                *out_looped = u8::from(outcome == StepOutcome::Completed);
                TTFX_STATUS_OK
            }
            Err(error) => status(error),
        })
    }
}

/// Reconstruct the effect from its original parameters and expose its first frame.
///
/// # Safety
///
/// `engine` must be a live handle created by this library on the current thread.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_reset(engine: *mut TtfxEngine) -> i32 {
    unsafe {
        ffi_mutating_boundary(engine, |engine| match engine.inner.reset() {
            Ok(()) => TTFX_STATUS_OK,
            Err(error) => status(error),
        })
    }
}

/// Draws the logo according to `mode` (TTFX_LOGO_MODE_*). Every caller keeps
/// its playback state exclusively through this function; the current frame is
/// always available through `ttfx_engine_cells` after the call.
///
/// `out_looped` (may be NULL) is set to 1 only for the call in which a
/// TTFX_LOGO_MODE_LOOP playback wrapped to a fresh cycle. `out_finished`
/// (may be NULL) is set to 1 once a TTFX_LOGO_MODE_ONE_TIME playback has
/// completed and the final frame is being held, or once a
/// TTFX_LOGO_MODE_REVERSE playback exposes the blank canvas; it stays 1 on
/// later calls.
///
/// # Safety
///
/// `engine` must be a live handle created by this library on the current
/// thread, and each output pointer must be valid for one byte when non-NULL.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_draw_logo(
    engine: *mut TtfxEngine,
    mode: u32,
    out_looped: *mut u8,
    out_finished: *mut u8,
) -> i32 {
    if !out_looped.is_null() {
        unsafe { *out_looped = 0 };
    }
    if !out_finished.is_null() {
        unsafe { *out_finished = 0 };
    }
    let mode = match mode {
        x if x == LogoMode::Loop as u32 => LogoMode::Loop,
        x if x == LogoMode::OneTime as u32 => LogoMode::OneTime,
        x if x == LogoMode::Reverse as u32 => LogoMode::Reverse,
        _ => return TTFX_STATUS_INVALID_ARGUMENT,
    };
    unsafe {
        ffi_mutating_boundary(engine, |engine| match engine.inner.draw_logo(mode) {
            Ok(outcome) => {
                match mode {
                    LogoMode::Loop => {
                        if !out_looped.is_null() {
                            *out_looped = u8::from(outcome == StepOutcome::Completed);
                        }
                    }
                    LogoMode::OneTime | LogoMode::Reverse => {
                        if !out_finished.is_null() {
                            *out_finished = u8::from(outcome == StepOutcome::Completed);
                        }
                    }
                }
                TTFX_STATUS_OK
            }
            Err(error) => status(error),
        })
    }
}

/// Start (`max_frames` 2..=4096) or stop (`max_frames` 0) recording the
/// forward playback for a later reverse. `max_bytes` bounds the record and
/// must hold at least one uncompressed frame. Forward playback is unchanged.
///
/// # Safety
///
/// `engine` must be a live handle created by this library on the current thread.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_record_history(
    engine: *mut TtfxEngine,
    max_frames: u32,
    max_bytes: usize,
) -> i32 {
    unsafe {
        ffi_mutating_boundary(engine, |engine| {
            match engine.inner.record_history(max_frames as usize, max_bytes) {
                Ok(()) => TTFX_STATUS_OK,
                Err(error) => status(error),
            }
        })
    }
}

/// Prepare a reverse playback of at most `max_calls` TTFX_LOGO_MODE_REVERSE
/// draws ending on the blank canvas; `*out_calls` receives the exact count.
/// TTFX_STATUS_UNAVAILABLE means no usable history was recorded; the engine is
/// then unchanged.
///
/// # Safety
///
/// `engine` must be a live handle created by this library on the current
/// thread, and `out_calls` must be valid for one writable `u32`.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_begin_reverse(
    engine: *mut TtfxEngine,
    max_calls: u32,
    frames_per_call: u32,
    out_calls: *mut u32,
) -> i32 {
    if out_calls.is_null() {
        return TTFX_STATUS_INVALID_ARGUMENT;
    }
    unsafe { *out_calls = 0 };
    unsafe {
        ffi_mutating_boundary(engine, |engine| {
            match engine.inner.begin_reverse(max_calls, frames_per_call) {
                Ok(calls) => {
                    *out_calls = calls;
                    TTFX_STATUS_OK
                }
                Err(error) => status(error),
            }
        })
    }
}

/// Borrow the top-to-bottom row-major cell array. The pointer remains valid
/// until the next mutable call on this handle or until the handle is freed.
///
/// # Safety
///
/// `engine` must be a live handle, and every output pointer must be writable.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_cells(
    engine: *const TtfxEngine,
    out_cells: *mut *const Cell,
    out_count: *mut usize,
    out_width: *mut u32,
    out_height: *mut u32,
) -> i32 {
    ffi_boundary(|| {
        if !out_cells.is_null() {
            unsafe { *out_cells = ptr::null() };
        }
        if !out_count.is_null() {
            unsafe { *out_count = 0 };
        }
        if !out_width.is_null() {
            unsafe { *out_width = 0 };
        }
        if !out_height.is_null() {
            unsafe { *out_height = 0 };
        }
        if engine.is_null()
            || out_cells.is_null()
            || out_count.is_null()
            || out_width.is_null()
            || out_height.is_null()
        {
            return TTFX_STATUS_INVALID_ARGUMENT;
        }
        let handle = unsafe { &*engine };
        if handle.poisoned {
            return TTFX_STATUS_POISONED;
        }
        let engine = &handle.inner;
        unsafe {
            *out_cells = engine.cells().as_ptr();
            *out_count = engine.cells().len();
            *out_width = engine.width as u32;
            *out_height = engine.height as u32;
        }
        TTFX_STATUS_OK
    })
}

/// Free a handle. Passing null is a no-op.
///
/// # Safety
///
/// A non-null `engine` must be a live handle returned by this library, on its
/// creating thread, and must not have been freed previously.
#[no_mangle]
pub unsafe extern "C" fn ttfx_engine_free(engine: *mut TtfxEngine) {
    if !engine.is_null() {
        let _ = catch_unwind(AssertUnwindSafe(|| unsafe { drop(Box::from_raw(engine)) }));
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use ttfx::engine::animation::VisualParams;
    use ttfx::utils::graphics::{Color, ColorPair};

    #[test]
    fn row_conversion_covers_full_canvas_top_to_bottom() {
        let bottom_up = [1, 2, 3, 4, 5, 6];
        assert_eq!(top_to_bottom(&bottom_up, 2, 3), [5, 6, 3, 4, 1, 2]);
    }

    #[test]
    fn visual_conversion_preserves_unicode_rgba_and_all_flags() {
        let visual = CharacterVisual::new(
            "λtail",
            VisualParams {
                bold: true,
                dim: true,
                italic: true,
                underline: true,
                blink: true,
                reverse: true,
                hidden: true,
                strike: true,
                colors: Some(ColorPair::new(
                    Some(Color::from_hex("123456").unwrap()),
                    Some(Color::from_hex("abcdef").unwrap()),
                )),
                ..VisualParams::default()
            },
        );

        assert_eq!(
            cell_from_visual(Some(&visual)),
            Cell {
                codepoint: u32::from('λ'),
                fg_rgba: 0x123456ff,
                bg_rgba: 0xabcdefff,
                flags: CELL_FLAG_FG
                    | CELL_FLAG_BG
                    | CELL_FLAG_BOLD
                    | CELL_FLAG_DIM
                    | CELL_FLAG_ITALIC
                    | CELL_FLAG_UNDERLINE
                    | CELL_FLAG_BLINK
                    | CELL_FLAG_REVERSE
                    | CELL_FLAG_HIDDEN
                    | CELL_FLAG_STRIKE,
            }
        );
        assert_eq!(cell_from_visual(None).codepoint, u32::from(' '));
        assert_eq!(
            cell_from_visual(Some(&CharacterVisual::plain(""))).codepoint,
            u32::from(' ')
        );
    }

    #[test]
    fn embedded_engine_uses_loader_background_color() {
        let engine =
            Engine::create_with_background("print", 7, "OMARCHY", 12, 2, 60, 0x1a1b26).unwrap();

        assert_eq!(
            engine
                .ctx
                .terminal
                .config
                .terminal_background_color
                .rgb_ints(),
            (0x1a, 0x1b, 0x26)
        );
    }

    #[test]
    fn draw_logo_loop_wraps_and_restarts_deterministically() {
        let mut engine = Engine::create("decrypt", 7, "", 162, 20, 240).unwrap();
        let first_frame = engine.cells().to_vec();

        let mut wrapped_at = None;
        for call in 1..=4096 {
            match engine.draw_logo(LogoMode::Loop) {
                Ok(StepOutcome::Completed) => {
                    wrapped_at = Some(call);
                    break;
                }
                Ok(StepOutcome::Frame) => {}
                Err(error) => panic!("loop draw failed: {error:?}"),
            }
        }
        let wrapped_at = wrapped_at.expect("decrypt must wrap within 4096 draws");
        assert_eq!(
            engine.cells().to_vec(),
            first_frame,
            "wrap must restart the tape"
        );

        // The loop keeps producing frames afterwards without a manual reset.
        assert!(matches!(
            engine.draw_logo(LogoMode::Loop),
            Ok(StepOutcome::Frame)
        ));
        assert!(wrapped_at > 0);
    }

    #[test]
    fn draw_logo_one_time_finishes_and_holds_the_final_frame() {
        let mut engine = Engine::create("decrypt", 7, "", 162, 20, 240).unwrap();

        let mut finished_at = None;
        for call in 1..=4096 {
            match engine.draw_logo(LogoMode::OneTime) {
                Ok(StepOutcome::Completed) => {
                    finished_at = Some(call);
                    break;
                }
                Ok(StepOutcome::Frame) => {}
                Err(error) => panic!("one_time draw failed: {error:?}"),
            }
        }
        assert!(
            finished_at.is_some(),
            "decrypt must finish within 4096 draws"
        );

        let final_frame = engine.cells().to_vec();
        // Once finished, every later call reports completion and keeps the
        // exact final frame: one_time holds the last frame forever.
        for _ in 0..8 {
            assert!(matches!(
                engine.draw_logo(LogoMode::OneTime),
                Ok(StepOutcome::Completed)
            ));
            assert_eq!(engine.cells().to_vec(), final_frame);
        }
        assert_ne!(
            final_frame,
            Engine::create("decrypt", 7, "", 162, 20, 240)
                .unwrap()
                .cells()
                .to_vec()
        );
    }

    #[test]
    fn draw_logo_mode_flag_reports_through_ffi() {
        let inner = Engine::create("decrypt", 7, "", 162, 20, 240).unwrap();
        let mut handle = TtfxEngine {
            inner,
            poisoned: false,
        };
        let raw = &mut handle as *mut TtfxEngine;

        assert_eq!(
            unsafe { ttfx_engine_draw_logo(raw, 3, ptr::null_mut(), ptr::null_mut()) },
            TTFX_STATUS_INVALID_ARGUMENT
        );
        assert_eq!(
            unsafe { ttfx_engine_draw_logo(raw, 2, ptr::null_mut(), ptr::null_mut()) },
            TTFX_STATUS_INVALID_STATE,
            "reverse needs begin_reverse first"
        );

        let mut looped = 0u8;
        let mut finished = 0u8;
        assert_eq!(
            unsafe { ttfx_engine_draw_logo(raw, 0, &mut looped, &mut finished) },
            TTFX_STATUS_OK
        );
        assert_eq!(looped, 0);
        assert_eq!(finished, 0);

        assert_eq!(
            unsafe { ttfx_engine_draw_logo(raw, 1, &mut looped, &mut finished) },
            TTFX_STATUS_OK
        );
        assert_eq!(finished, 0, "decrypt does not finish in two draws");
    }

    #[test]
    fn panic_boundary_maps_panics_to_status() {
        assert_eq!(
            ffi_boundary(|| panic!("containment probe")),
            TTFX_STATUS_PANIC
        );
    }

    #[test]
    fn mutating_panic_poisons_the_handle_until_it_is_freed() {
        let inner = Engine::create("print", 7, "OMARCHY", 12, 2, 60).unwrap();
        let mut handle = TtfxEngine {
            inner,
            poisoned: false,
        };
        let raw = &mut handle as *mut TtfxEngine;

        assert_eq!(
            unsafe {
                ffi_mutating_boundary(raw, |_engine| {
                    panic!("mutation panic probe");
                })
            },
            TTFX_STATUS_PANIC
        );
        assert!(handle.poisoned);
        assert_eq!(
            unsafe { ffi_mutating_boundary(raw, |_engine| TTFX_STATUS_OK) },
            TTFX_STATUS_POISONED
        );
    }
}
