//! The run loop (engine/effect.rs run_effect and dump_effect) for effects on
//! the fx engine: frames are handed to the kernel as one iovec per row.
//!
//! An unpaced run (no real-clock pacing) with two or more CPUs renders on a
//! thread of its own: the main thread computes frame N+1 while the renderer
//! replays frame N's change log, formats and writes it. Frames pass through
//! a ring of RING packets; each side spins briefly, then parks only when
//! idle. Every frame handed over is written before the teardown bytes.
//! TTFX_THREADS=1 keeps every run on one thread.

use std::cell::UnsafeCell;
use std::io::Write;
use std::sync::atomic::{AtomicBool, AtomicU32, Ordering::*};
use std::thread::{self, Thread};

use crate::engine::ctx::Clock;
use crate::engine::effect::{io_err, output_closed, RunOutcome};
use crate::engine::error::EngineError;

use super::render::{pool_delta, pool_room, write_all_vectored, IoSlice, RawStdout, Render};
use super::visual::{Span, COPY_BLOCK};
use super::{Engine, Hooks};

/// One effect: build() once, then next_frame() until it returns false. Every
/// effect is also the Hooks for its registered callbacks.
pub trait Effect: Hooks {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError>;
    /// Advance one frame; false when the effect is done.
    fn next_frame(&mut self, e: &mut Engine) -> bool;
}

impl Engine {
    /// BaseEffectIterator.frame: enforce the frame rate (real clock only) and
    /// advance the virtual clock.
    fn frame(&mut self) {
        if self.paced() {
            self.terminal.enforce_framerate();
        }
        self.clock.advance_frame();
    }

    fn paced(&self) -> bool {
        matches!(self.clock, Clock::Real { .. }) && self.config.frame_rate != 0
    }

    fn requested_stop(&mut self, stop_on_resize: bool) -> Option<RunOutcome> {
        if crate::interrupted() {
            Some(RunOutcome::Interrupted)
        } else if crate::terminated() {
            Some(RunOutcome::Terminated)
        } else if stop_on_resize && self.terminal.resize_settled() {
            Some(RunOutcome::TerminalResized)
        } else {
            None
        }
    }
}

/// Render on a second thread, unless the run is paced, TTFX_THREADS is 0 or 1,
/// or there is only one CPU.
fn threaded(e: &Engine) -> bool {
    !e.paced()
        && std::env::var_os("TTFX_THREADS").is_none_or(|v| v != "1" && v != "0")
        && cpus() >= 2
}

/// The CPUs this thread may run on: its affinity mask on Linux (unlike
/// available_parallelism, cgroup quotas are ignored), else std's estimate.
fn cpus() -> usize {
    #[cfg(target_os = "linux")]
    {
        unsafe extern "C" {
            fn sched_getaffinity(pid: i32, size: usize, mask: *mut u64) -> i32;
        }
        let mut mask = [0u64; 16];
        // SAFETY: the mask holds size bytes.
        if unsafe { sched_getaffinity(0, std::mem::size_of_val(&mask), mask.as_mut_ptr()) } == 0 {
            return mask.iter().map(|w| w.count_ones() as usize).sum();
        }
    }
    thread::available_parallelism().map_or(1, |n| n.get())
}

/// engine::effect::run_effect on the fx engine.
pub fn run_effect(
    effect: &mut dyn Effect,
    e: &mut Engine,
    tty_output: bool,
) -> Result<RunOutcome, EngineError> {
    effect.build(e)?;
    let mut out = RawStdout;
    let mut outcome = RunOutcome::Complete;
    let move_to_top = e.terminal.move_cursor_to_top().as_bytes().to_vec();
    let differential = tty_output && !e.config.ignore_terminal_dimensions;
    let result = (|| -> std::io::Result<()> {
        let mut prep = Vec::new();
        e.terminal.prep_canvas(&mut prep)?;
        out.write_all(&prep)?;
        if threaded(e) {
            return run_threaded(effect, e, tty_output, &move_to_top, &mut outcome);
        }
        let mut parts: Vec<IoSlice<'static>> = Vec::new();
        let mut output = crate::utils::differential::DifferentialOutput::default();
        loop {
            if let Some(stop) = e.requested_stop(tty_output) {
                outcome = stop;
                break;
            }
            if !effect.next_frame(e) {
                break;
            }
            e.frame();
            if let Some(stop) = e.requested_stop(tty_output) {
                outcome = stop;
                break;
            }
            e.render_here();
            if differential {
                if e.terminal.take_repaint() {
                    output.invalidate();
                } else if let Some(bytes) = e.renderer().differential_frame(&mut output, &move_to_top) {
                    out.write_all(bytes)?;
                    continue;
                }
            }
            let mut frame = reuse(std::mem::take(&mut parts));
            e.renderer().frame_parts(&move_to_top, &[], &mut frame);
            write_all_vectored(&mut frame)?;
            parts = reuse(frame);
        }
        Ok(())
    })();
    let mut tail = Vec::new();
    let teardown = if outcome == RunOutcome::TerminalResized {
        // Leave the cursor hidden and parked at the top of the wiped area: the
        // rebuild redraws in place.
        e.terminal.reset_canvas_area(&mut tail)
    } else {
        e.terminal.restore_cursor(&mut tail, "\n")
    }
    .and_then(|()| out.write_all(&tail));
    match result.and(teardown) {
        Ok(()) => Ok(outcome),
        Err(err) if tty_output && output_closed(&err) => Ok(RunOutcome::OutputClosed),
        Err(err) => Err(io_err(err)),
    }
}

/// engine::effect::dump_effect on the fx engine: length-prefixed frames.
pub fn dump_effect(
    effect: &mut dyn Effect,
    e: &mut Engine,
    max_frames: Option<u64>,
) -> Result<u64, EngineError> {
    effect.build(e)?;
    let mut count: u64 = 0;
    let mut parts: Vec<IoSlice<'static>> = Vec::new();
    while effect.next_frame(e) {
        e.frame();
        e.render_here();
        let r = e.renderer();
        let header = format!("{}\n", r.frame_len());
        let mut frame = reuse(std::mem::take(&mut parts));
        r.frame_parts(header.as_bytes(), b"\n", &mut frame);
        write_all_vectored(&mut frame).map_err(io_err)?;
        parts = reuse(frame);
        count += 1;
        if max_frames.is_some_and(|m| count >= m) {
            break;
        }
    }
    crate::errln!("frames={count}");
    Ok(count)
}

/// An empty iovec list keeps its allocation across frames of any lifetime.
fn reuse<'a, 'b>(mut parts: Vec<IoSlice<'a>>) -> Vec<IoSlice<'b>> {
    parts.clear();
    // SAFETY: the vector is empty, so no slice of lifetime 'a survives in it;
    // IoSlice's layout does not depend on its lifetime.
    unsafe { std::mem::transmute::<Vec<IoSlice<'a>>, Vec<IoSlice<'b>>>(parts) }
}

// ------------------------------------------------------------------ the frame ring

/// Frames in flight.
const RING: u32 = 32;
/// Frames waiting that wake a sleeping renderer (it is woken for fewer only
/// at the end of the run).
const WAKE: u32 = 4;
/// Checks before a waiting side sleeps.
const SPIN: u32 = 256;

/// One frame for the renderer: its change log, the visuals made since the
/// previous frame, and the character count.
#[derive(Default)]
struct Packet {
    log: Vec<u64>,
    spans: Vec<Span>,
    bytes: Vec<u8>,
    slots: usize,
    /// The pool's capacity (see Render::fit).
    room: (usize, usize),
    /// Write this frame whole (see Terminal::take_repaint).
    repaint: bool,
}

struct Ring {
    packets: Box<[UnsafeCell<Packet>]>,
    /// Frames handed over (written by the main thread) and done (by the
    /// renderer). The main thread fills packet `head % RING` only once
    /// `head - done < RING`, and the renderer reads packet `done % RING` only
    /// once `done < head`.
    head: AtomicU32,
    done: AtomicU32,
    /// No more frames (set after the last `head`).
    quit: AtomicBool,
    /// The renderer's write failed, or it panicked: the main thread stops.
    failed: AtomicBool,
    render_sleeping: AtomicBool,
    main_sleeping: AtomicBool,
}

// SAFETY: a packet is only touched by the side that owns it under the
// head/done protocol above; the counters are atomic, published with release
// stores and read with acquire loads (SeqCst where a side decides to sleep).
unsafe impl Sync for Ring {}

impl Ring {
    fn new() -> Self {
        Ring {
            packets: (0..RING)
                .map(|_| UnsafeCell::new(Packet::default()))
                .collect(),
            head: AtomicU32::new(0),
            done: AtomicU32::new(0),
            quit: AtomicBool::new(false),
            failed: AtomicBool::new(false),
            render_sleeping: AtomicBool::new(false),
            main_sleeping: AtomicBool::new(false),
        }
    }
}

/// The main thread's end of the ring.
struct Submitter<'a> {
    ring: &'a Ring,
    renderer: Thread,
    head: u32,
    /// The pool's spans and content bytes already handed over.
    spans: usize,
    bytes: usize,
}

impl Submitter<'_> {
    /// Hand the frame (the engine's open log) to the renderer; false when the
    /// renderer failed.
    fn submit(&mut self, e: &mut Engine) -> bool {
        let ring = self.ring;
        let mut spins = 0;
        while self.head.wrapping_sub(ring.done.load(Acquire)) >= RING {
            if ring.failed.load(Acquire) {
                return false;
            }
            if spins < SPIN {
                spins += 1;
                std::hint::spin_loop();
                continue;
            }
            ring.main_sleeping.store(true, SeqCst);
            if self.head.wrapping_sub(ring.done.load(SeqCst)) >= RING && !ring.failed.load(SeqCst) {
                thread::park();
            }
            ring.main_sleeping.store(false, Relaxed);
        }
        // SAFETY: head - done < RING, so the renderer is done with this
        // packet and does not touch it until head moves past it.
        let packet = unsafe { &mut *ring.packets[(self.head % RING) as usize].get() };
        std::mem::swap(&mut packet.log, &mut e.render.log);
        e.render.log.clear();
        let (spans, bytes) = pool_delta(&e.visuals, self.spans, self.bytes);
        packet.spans.clear();
        packet.spans.extend_from_slice(spans);
        packet.bytes.clear();
        packet.bytes.extend_from_slice(bytes);
        self.spans += spans.len();
        self.bytes += bytes.len();
        packet.slots = e.ch.len();
        packet.room = pool_room(&e.visuals);
        packet.repaint = e.terminal.take_repaint();
        self.head = self.head.wrapping_add(1);
        ring.head.store(self.head, SeqCst);
        if ring.render_sleeping.load(SeqCst)
            && self.head.wrapping_sub(ring.done.load(Relaxed)) >= WAKE
        {
            self.renderer.unpark();
        }
        !ring.failed.load(Relaxed)
    }
}

impl Drop for Submitter<'_> {
    /// No more frames: the renderer finishes the ones handed over. (Also
    /// when the effect panics: the scope waits for the renderer.)
    fn drop(&mut self) {
        self.ring.quit.store(true, SeqCst);
        self.renderer.unpark();
    }
}

/// Sets `failed` and wakes the main thread if the renderer unwinds.
struct PanicGuard<'a> {
    ring: &'a Ring,
    main: Thread,
}

impl Drop for PanicGuard<'_> {
    fn drop(&mut self) {
        if thread::panicking() {
            self.ring.failed.store(true, SeqCst);
            self.main.unpark();
        }
    }
}

/// The renderer thread: replay, format and write every frame handed over.
/// After a failed write it keeps taking frames (so the main thread never
/// waits on a full ring) without writing them.
fn render_loop(
    ring: &Ring,
    r: &mut Render,
    prefix: &[u8],
    differential: bool,
    main: Thread,
) -> std::io::Result<()> {
    let _guard = PanicGuard {
        ring,
        main: main.clone(),
    };
    let mut result = Ok(());
    let mut parts: Vec<IoSlice<'static>> = Vec::new();
    let mut output = crate::utils::differential::DifferentialOutput::default();
    let mut done = 0u32;
    let mut spins = 0;
    loop {
        let quit = ring.quit.load(SeqCst);
        let head = ring.head.load(Acquire);
        if head == done {
            if quit {
                return result;
            }
            if spins < SPIN {
                spins += 1;
                std::hint::spin_loop();
                continue;
            }
            ring.render_sleeping.store(true, SeqCst);
            if ring.head.load(SeqCst) == done && !ring.quit.load(SeqCst) {
                thread::park();
            }
            ring.render_sleeping.store(false, Relaxed);
            continue;
        }
        spins = 0;
        while done != head {
            // SAFETY: done < head: the main thread filled this packet and
            // leaves it alone until done moves past it.
            let packet = unsafe { &mut *ring.packets[(done % RING) as usize].get() };
            if result.is_ok() {
                r.fit(packet.room);
                r.sync(&packet.spans, &packet.bytes, packet.slots);
                r.apply(&packet.log);
                r.render_rows();
                let bytes = if differential && packet.repaint {
                    output.invalidate();
                    None
                } else if differential {
                    r.differential_frame(&mut output, prefix)
                } else {
                    None
                };
                result = if let Some(bytes) = bytes {
                    RawStdout.write_all(bytes)
                } else {
                    let mut frame = reuse(std::mem::take(&mut parts));
                    r.frame_parts(prefix, &[], &mut frame);
                    let result = write_all_vectored(&mut frame);
                    parts = reuse(frame);
                    result
                };
                if result.is_err() {
                    ring.failed.store(true, SeqCst);
                }
            }
            done = done.wrapping_add(1);
            ring.done.store(done, SeqCst);
            if ring.main_sleeping.load(SeqCst) {
                main.unpark();
            }
        }
    }
}

fn run_threaded(
    effect: &mut dyn Effect,
    e: &mut Engine,
    tty_output: bool,
    prefix: &[u8],
    outcome: &mut RunOutcome,
) -> std::io::Result<()> {
    let differential = tty_output && !e.config.ignore_terminal_dimensions;
    let mut r = e
        .render
        .back
        .take()
        .expect("the renderer runs on another thread");
    r.sync_pool(&e.visuals);
    r.settle_late();
    let (spans, bytes) = (e.visuals.spans.len(), e.visuals.bytes.len() - COPY_BLOCK);
    let ring = Ring::new();
    let main = thread::current();
    let result = thread::scope(|s| {
        let render = s.spawn(|| render_loop(&ring, &mut r, prefix, differential, main));
        let mut submitter = Submitter {
            ring: &ring,
            renderer: render.thread().clone(),
            head: 0,
            spans,
            bytes,
        };
        loop {
            if let Some(stop) = e.requested_stop(tty_output) {
                *outcome = stop;
                break;
            }
            if !effect.next_frame(e) {
                break;
            }
            e.frame();
            if let Some(stop) = e.requested_stop(tty_output) {
                *outcome = stop;
                break;
            }
            if !submitter.submit(e) {
                break;
            }
        }
        drop(submitter);
        match render.join() {
            Ok(result) => result,
            Err(panic) => std::panic::resume_unwind(panic),
        }
    });
    // the frames not handed over are dropped: the renderer takes the log
    // from here on
    e.render.log.clear();
    r.sync_pool(&e.visuals);
    e.render.back = Some(r);
    result
}
