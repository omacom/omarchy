//! Effect trait and run loop (base_effect.py equivalents).

use std::io::Write;

use crate::engine::ctx::{EffectHooks, EngineCtx};
use crate::engine::error::EngineError;

/// One effect: build() once (upstream iterator __init__/build), then
/// next_frame() until None (upstream __next__/StopIteration). Every effect
/// also implements EffectHooks for its registered callbacks.
pub trait Effect: EffectHooks {
    fn build(&mut self, ctx: &mut EngineCtx) -> Result<(), EngineError>;
    fn next_frame(&mut self, ctx: &mut EngineCtx) -> Option<String>;
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RunOutcome {
    Complete,
    Interrupted,
    Terminated,
    TerminalResized,
    /// The terminal went away mid-run — see [`output_closed`].
    OutputClosed,
}

/// __main__ run loop with terminal_output(): prep canvas, stream frames,
/// always restore the cursor (even on error — RAII would not run on a raw
/// process exit, so this is explicit).
///
/// On a tty a settled terminal resize also ends the pass, wiped and parked at
/// the top of the area so the caller can rebuild in place, and a terminal that
/// goes away ends the run. A redirected stream gets neither: SIGWINCH there is
/// not about our output, and a write that fails to a file is a real failure.
pub fn run_effect(
    effect: &mut dyn Effect,
    ctx: &mut EngineCtx,
    tty_output: bool,
) -> Result<RunOutcome, EngineError> {
    effect.build(ctx)?;
    let stdout = std::io::stdout();
    let mut out = stdout.lock();
    let mut outcome = RunOutcome::Complete;
    let result = (|| -> std::io::Result<()> {
        ctx.terminal.prep_canvas(&mut out)?;
        loop {
            if let Some(stop) = requested_stop(ctx, tty_output) {
                outcome = stop;
                break;
            }
            let Some(frame) = effect.next_frame(ctx) else {
                break;
            };
            if let Some(stop) = requested_stop(ctx, tty_output) {
                outcome = stop;
                ctx.terminal.recycle_output_string(frame);
                break;
            }
            if tty_output && !ctx.terminal.config.ignore_terminal_dimensions {
                ctx.terminal.print_differential_frame(&mut out, &frame)?;
            } else {
                ctx.terminal.print_frame(&mut out, &frame)?;
            }
            ctx.terminal.recycle_output_string(frame);
        }
        Ok(())
    })();
    let teardown = if outcome == RunOutcome::TerminalResized {
        // Leave the cursor hidden and parked at the top of the wiped area: the
        // rebuild redraws in place, and showing the cursor here would strobe it
        // dozens of times a second through a window drag.
        ctx.terminal.reset_canvas_area(&mut out)
    } else {
        ctx.terminal.restore_cursor(&mut out, "\n")
    };
    out.flush().ok();
    match result.and(teardown) {
        Ok(()) => Ok(outcome),
        Err(e) if tty_output && output_closed(&e) => Ok(RunOutcome::OutputClosed),
        Err(e) => Err(io_err(e)),
    }
}

/// The terminal an animation is drawing on can go away mid-frame: the
/// screensaver's window is killed at lock, an emulator exits, a reader closes
/// the pipe. Every write after that fails, teardown included, and there is no
/// cursor left to restore — so this ends the run instead of raising an error
/// nobody can be told about (basecamp/omarchy#6762).
///
/// EIO is the pty slave outliving its master; EPIPE only surfaces here when
/// SIGPIPE was ignored by whoever started us, since we restore its default.
/// Both mean the same thing, and neither is a failure of this run.
pub(crate) fn output_closed(e: &std::io::Error) -> bool {
    const EIO: i32 = 5;
    e.kind() == std::io::ErrorKind::BrokenPipe || e.raw_os_error() == Some(EIO)
}

fn requested_stop(ctx: &mut EngineCtx, stop_on_resize: bool) -> Option<RunOutcome> {
    if crate::interrupted() {
        Some(RunOutcome::Interrupted)
    } else if crate::terminated() {
        Some(RunOutcome::Terminated)
    } else if stop_on_resize && ctx.terminal.resize_settled() {
        Some(RunOutcome::TerminalResized)
    } else {
        None
    }
}

/// Parity mode: write length-prefixed frames to stdout, no tty escapes.
pub fn dump_effect(
    effect: &mut dyn Effect,
    ctx: &mut EngineCtx,
    max_frames: Option<u64>,
) -> Result<u64, EngineError> {
    effect.build(ctx)?;
    let stdout = std::io::stdout();
    let mut out = stdout.lock();
    let mut count: u64 = 0;
    while let Some(frame) = effect.next_frame(ctx) {
        let data = frame.as_bytes();
        writeln!(out, "{}", data.len()).map_err(io_err)?;
        out.write_all(data).map_err(io_err)?;
        out.write_all(b"\n").map_err(io_err)?;
        ctx.terminal.recycle_output_string(frame);
        count += 1;
        if max_frames.is_some_and(|m| count >= m) {
            break;
        }
    }
    out.flush().ok();
    crate::errln!("frames={count}");
    Ok(count)
}

pub(crate) fn io_err(e: std::io::Error) -> EngineError {
    EngineError::Other(format!("io error: {e}"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::{Error, ErrorKind};

    #[test]
    fn a_lost_output_stream_is_not_an_error() {
        assert!(output_closed(&Error::from_raw_os_error(5)));
        assert!(output_closed(&Error::from(ErrorKind::BrokenPipe)));
        // A full disk or a revoked device still deserves a report.
        assert!(!output_closed(&Error::from_raw_os_error(28)));
        assert!(!output_closed(&Error::from(ErrorKind::PermissionDenied)));
    }
}
