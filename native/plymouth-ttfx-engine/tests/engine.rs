use clap::CommandFactory;
use ttfx::cli::Cli;
use ttfx_plymouth::{Engine, StepOutcome};

#[test]
fn embedded_dependency_is_ttfx_0_5_1() {
    assert!(include_str!("../vendor/ttfx/Cargo.toml").contains("version = \"0.5.1\""));
}

#[test]
fn creates_real_print_effect_with_a_full_structured_frame() {
    let engine = Engine::create("print", 0x1234, "Héllo", 12, 3, 60).unwrap();

    assert_eq!(engine.dimensions(), (12, 3));
    assert_eq!(engine.cells().len(), 36);
    assert!(engine
        .cells()
        .iter()
        .any(|cell| cell.codepoint != u32::from(' ')));
}

#[test]
fn completion_keeps_the_terminal_frame_until_explicit_reset() {
    let mut engine = Engine::create("print", 0x55aa, "Loop me", 12, 2, 60).unwrap();
    let first = engine.cells().to_vec();
    assert_eq!(engine.step().unwrap(), StepOutcome::Frame);
    assert_ne!(engine.cells(), first);

    for _ in 0..10_000 {
        if engine.step().unwrap() == StepOutcome::Completed {
            let terminal = engine.cells().to_vec();
            assert_ne!(terminal, first);
            assert_eq!(engine.step().unwrap(), StepOutcome::Completed);
            assert_eq!(engine.cells(), terminal);
            engine.reset().unwrap();
            assert_eq!(engine.cells(), first);
            return;
        }
    }
    panic!("print effect did not complete within the safety bound");
}

#[test]
fn explicit_reset_reconstructs_the_deterministic_first_frame() {
    let mut engine = Engine::create("print", 0x55aa, "Reset me", 12, 2, 60).unwrap();
    let first = engine.cells().to_vec();
    assert_eq!(engine.step().unwrap(), StepOutcome::Frame);
    assert_ne!(engine.cells(), first);

    engine.reset().unwrap();

    assert_eq!(engine.cells(), first);
}

#[test]
fn rejects_unknown_effects_and_out_of_bounds_configuration() {
    assert_eq!(
        Engine::create("not-an-effect", 1, "x", 10, 2, 60).err(),
        Some(ttfx_plymouth::EngineError::InvalidEffect)
    );
    assert_eq!(
        Engine::create("print", 1, "x", 0, 2, 60).err(),
        Some(ttfx_plymouth::EngineError::InvalidDimensions)
    );
    assert_eq!(
        Engine::create("print", 1, "x", 163, 2, 60).err(),
        Some(ttfx_plymouth::EngineError::InvalidDimensions)
    );
    assert_eq!(
        Engine::create("print", 1, "x", 162, 30, 60).err(),
        Some(ttfx_plymouth::EngineError::InvalidDimensions)
    );
    assert_eq!(
        Engine::create("print", 1, "x", 10, 2, 241).err(),
        Some(ttfx_plymouth::EngineError::InvalidFrameRate)
    );
}

#[test]
fn accepts_subdivided_logo_without_loosening_the_cell_budget() {
    let logo = include_str!("../../plymouth-ttfx-plugin/embedded-logo-v2.txt");
    let engine = Engine::create("decrypt", 7, logo, 162, 20, 240).unwrap();

    assert_eq!(engine.dimensions(), (162, 20));
    assert_eq!(engine.cells().len(), 3240);
    assert_eq!(
        ttfx_plymouth::validate_canvas(162, 30),
        Err(ttfx_plymouth::EngineError::InvalidDimensions)
    );
}

#[test]
fn terminal_decrypt_frame_matches_the_pr29_field_bands() {
    let logo = include_str!("../../plymouth-ttfx-plugin/embedded-logo-v2.txt");
    let mut engine = Engine::create("decrypt", 7, logo, 162, 20, 240).unwrap();

    for _ in 0..10_000 {
        if engine.step().unwrap() == StepOutcome::Completed {
            let (width, height) = engine.dimensions();
            let colors_by_nonempty_row: Vec<u32> = (0..height)
                .filter_map(|row| {
                    let colors: std::collections::BTreeSet<u32> = engine.cells()
                        [row * width..(row + 1) * width]
                        .iter()
                        .filter(|cell| cell.codepoint != u32::from(' '))
                        .map(|cell| cell.fg_rgba)
                        .collect();
                    assert!(
                        colors.len() <= 1,
                        "row {row} is not one discrete band: {colors:?}"
                    );
                    colors.into_iter().next()
                })
                .collect();
            let expected: Vec<u32> = [
                (0xd0fdd9ff, 4usize),
                (0xa8fcbaff, 3),
                (0x82fb9cff, 4),
                (0x539e65ff, 3),
                (0x2b5037ff, 5),
            ]
            .into_iter()
            .flat_map(|(color, rows)| std::iter::repeat_n(color, rows))
            .collect();
            assert_eq!(colors_by_nonempty_row, expected);
            return;
        }
    }
    panic!("decrypt effect did not complete within the safety bound");
}

#[test]
fn representative_effects_use_the_same_five_final_text_bands() {
    let logo = include_str!("../../plymouth-ttfx-plugin/embedded-logo-v2.txt");
    // print covers the ordinary final-gradient path; matrix and rain had
    // separate paths that the audio-background implementation did not wire.
    for effect in ["print", "matrix", "rain"] {
        let mut engine = Engine::create(effect, 7, logo, 162, 20, 240).unwrap();
        let mut completed = false;
        for _ in 0..10_000 {
            if engine.step().unwrap() != StepOutcome::Completed {
                continue;
            }
            completed = true;
            let (width, height) = engine.dimensions();
            let logo_rows: Vec<Vec<char>> =
                logo.lines().map(|line| line.chars().collect()).collect();
            let colors_by_nonempty_row: Vec<u32> = (0..height)
                .filter_map(|row| {
                    let colors: std::collections::BTreeSet<u32> = engine.cells()
                        [row * width..(row + 1) * width]
                        .iter()
                        .zip(&logo_rows[row])
                        .filter(|(_, input)| **input != ' ')
                        .map(|(cell, _)| cell.fg_rgba)
                        .collect();
                    if colors.is_empty() {
                        return None;
                    }
                    assert_eq!(colors.len(), 1, "{effect} row {row} is not one solid band");
                    colors.into_iter().next()
                })
                .collect();
            let run_lengths = colors_by_nonempty_row
                .chunk_by(|left, right| left == right)
                .map(<[u32]>::len)
                .collect::<Vec<_>>();
            assert_eq!(run_lengths, [4, 3, 4, 3, 5], "{effect}");
            break;
        }
        assert!(
            completed,
            "{effect} did not complete within the safety bound"
        );
    }
}

#[test]
fn allocation_overflow_is_detected_before_engine_construction() {
    assert_eq!(
        ttfx_plymouth::validate_canvas(usize::MAX, 2),
        Err(ttfx_plymouth::EngineError::Overflow)
    );
}

#[test]
fn every_exposed_effect_builds_and_steps_at_the_early_boot_limit() {
    let effects: Vec<&str> = include_str!("../effects.txt").lines().collect();
    assert!(!effects.is_empty());
    assert!(effects.windows(2).all(|pair| pair[0] < pair[1]));
    assert!(effects.iter().all(|effect| {
        !effect.is_empty()
            && effect.len() <= 127
            && effect.bytes().enumerate().all(|(index, byte)| {
                byte.is_ascii_lowercase() || (index > 0 && (byte.is_ascii_digit() || byte == b'-'))
            })
    }));

    let mut registry: Vec<String> = Cli::command()
        .get_subcommands()
        .filter(|command| command.get_name() != "help")
        .map(|command| command.get_name().to_owned())
        .collect();
    registry.sort();
    assert_eq!(
        registry, effects,
        "effects.txt must exactly match the vendored registry"
    );

    let input = include_str!("../../plymouth-ttfx-plugin/embedded-logo-v2.txt");
    for effect in effects {
        let mut engine = Engine::create(effect, 7, input, 162, 20, 240)
            .unwrap_or_else(|error| panic!("{effect} failed to build: {error:?}"));
        assert_eq!(engine.cells().len(), 162 * 20, "{effect}");
        let first = engine.cells().to_vec();
        for _ in 0..3 {
            engine
                .step()
                .unwrap_or_else(|error| panic!("{effect} failed to step: {error:?}"));
            assert_eq!(engine.cells().len(), 162 * 20, "{effect}");
        }
        engine.reset().unwrap();
        assert_eq!(
            engine.cells(),
            first,
            "{effect} reset must be deterministic"
        );
    }
}

const LOGO: &str = include_str!("../../plymouth-ttfx-plugin/embedded-logo-v2.txt");
const PLUGIN_SEED: u64 = 22321466108495961;
/// The plugin's history bounds and default outro budget (700 ms at 240 Hz).
const HISTORY_FRAMES: usize = 128;
const HISTORY_BYTES: usize = 4 * 1024 * 1024;
const OUTRO_CALLS: u32 = 168;

fn blank(cells: &[ttfx_plymouth::Cell]) -> bool {
    cells.iter().all(|cell| {
        *cell
            == ttfx_plymouth::Cell {
                codepoint: 0x20,
                fg_rgba: 0,
                bg_rgba: 0,
                flags: 0,
            }
    })
}

/// Plays the prepared reverse to its end and checks that it walks the record
/// backwards, dissolves, and lands exactly on the blank canvas on the last call.
fn play_reverse(engine: &mut Engine, calls: u32, label: &str) {
    use ttfx_plymouth::{LogoMode, ReverseFrame};
    let mut last_history = u64::MAX;
    let mut last_dissolve = 0usize;
    let mut seen_dissolve = false;
    for call in 1..=calls {
        let outcome = engine.draw_logo(LogoMode::Reverse).unwrap();
        let position = engine.reverse_position().unwrap();
        assert_eq!(position.call, call, "{label}");
        match position.frame.unwrap() {
            ReverseFrame::History(index) => {
                assert!(!seen_dissolve, "{label}: history after dissolve");
                assert!(index <= last_history, "{label}: history must go backwards");
                last_history = index;
                assert_eq!(outcome, StepOutcome::Frame, "{label}");
            }
            ReverseFrame::Dissolve(cleared) => {
                seen_dissolve = true;
                assert!(cleared >= last_dissolve, "{label}: dissolve must not restore cells");
                last_dissolve = cleared;
                assert_eq!(outcome, StepOutcome::Frame, "{label}");
            }
            ReverseFrame::Blank => {
                assert_eq!(call, calls, "{label}: blank only on the last call");
                assert_eq!(outcome, StepOutcome::Completed, "{label}");
            }
        }
        if call < calls {
            assert_ne!(outcome, StepOutcome::Completed, "{label}: finished early");
        }
    }
    if last_history != u64::MAX && position_history_calls(engine) > 0 {
        assert_eq!(last_history, 0, "{label}: the walk must reach the first frame");
    }
    assert!(blank(engine.cells()), "{label}: must end on the blank canvas");
    for _ in 0..3 {
        assert_eq!(
            engine.draw_logo(LogoMode::Reverse).unwrap(),
            StepOutcome::Completed,
            "{label}"
        );
        assert!(blank(engine.cells()), "{label}");
    }
}

fn position_history_calls(engine: &Engine) -> u32 {
    engine.reverse_position().unwrap().history_calls
}

#[test]
fn recording_history_keeps_forward_playback_byte_identical() {
    use ttfx_plymouth::LogoMode;
    for effect in ["decrypt", "matrix", "burn", "vhstape"] {
        let mut plain = Engine::create_with_background(effect, PLUGIN_SEED, LOGO, 162, 20, 240, 0x0b0d10).unwrap();
        let mut recorded = Engine::create_with_background(effect, PLUGIN_SEED, LOGO, 162, 20, 240, 0x0b0d10).unwrap();
        recorded.record_history(HISTORY_FRAMES, HISTORY_BYTES).unwrap();
        assert_eq!(plain.cells(), recorded.cells(), "{effect}");
        let mut wraps = 0;
        for call in 0..20_000 {
            let a = plain.draw_logo(LogoMode::Loop).unwrap();
            let b = recorded.draw_logo(LogoMode::Loop).unwrap();
            assert_eq!(a, b, "{effect} call {call}");
            assert_eq!(plain.cells(), recorded.cells(), "{effect} call {call}");
            if a == StepOutcome::Completed {
                wraps += 1;
                if wraps == 2 {
                    break;
                }
            }
        }
        assert_eq!(wraps, 2, "{effect} must loop twice");
        assert!(recorded.history_frames() <= HISTORY_FRAMES, "{effect}");
        assert!(recorded.history_bytes() <= HISTORY_BYTES + 64 * 1024, "{effect}");
    }
}

#[test]
fn every_effect_reverses_from_its_final_frame_to_the_blank_canvas() {
    use ttfx_plymouth::LogoMode;
    for effect in include_str!("../effects.txt").lines() {
        let mut engine = Engine::create_with_background(effect, PLUGIN_SEED, LOGO, 162, 20, 240, 0x0b0d10).unwrap();
        engine.record_history(HISTORY_FRAMES, HISTORY_BYTES).unwrap();
        let mut frames = 0u64;
        while engine.draw_logo(LogoMode::OneTime).unwrap() == StepOutcome::Frame {
            frames += 1;
            assert!(frames < 50_000, "{effect} must finish");
        }
        assert!(engine.history_frames() >= 2.min(frames as usize + 1), "{effect}");
        assert!(engine.history_frames() <= HISTORY_FRAMES, "{effect}");
        assert!(engine.history_bytes() <= HISTORY_BYTES + 64 * 1024, "{effect}");
        let calls = engine.begin_reverse(OUTRO_CALLS, 2).unwrap();
        assert!((1..=OUTRO_CALLS).contains(&calls), "{effect}: {calls}");
        let position = engine.reverse_position().unwrap();
        assert_eq!(position.history_calls + position.dissolve_calls + 1, calls, "{effect}");
        assert!(position.history_calls > 0, "{effect} has frames to walk back");
        play_reverse(&mut engine, calls, effect);
    }
}

#[test]
fn reverse_starts_wherever_playback_is_and_respects_the_call_budget() {
    use ttfx_plymouth::LogoMode;
    // Mid-animation, in loop mode after a wrap, and right after creation.
    for (effect, forward_calls) in [("decrypt", 300u32), ("decrypt", 0), ("burn", 1500), ("matrix", 9000)] {
        let mut engine = Engine::create_with_background(effect, PLUGIN_SEED, LOGO, 162, 20, 240, 0x0b0d10).unwrap();
        engine.record_history(HISTORY_FRAMES, HISTORY_BYTES).unwrap();
        for _ in 0..forward_calls {
            engine.draw_logo(LogoMode::Loop).unwrap();
        }
        for budget in [1u32, 2, 40, OUTRO_CALLS] {
            let mut copy = Engine::create_with_background(effect, PLUGIN_SEED, LOGO, 162, 20, 240, 0x0b0d10).unwrap();
            copy.record_history(HISTORY_FRAMES, HISTORY_BYTES).unwrap();
            for _ in 0..forward_calls {
                copy.draw_logo(LogoMode::Loop).unwrap();
            }
            assert_eq!(copy.cells(), engine.cells());
            let calls = copy.begin_reverse(budget, 2).unwrap();
            assert!((1..=budget).contains(&calls), "{effect}/{forward_calls}/{budget}: {calls}");
            if budget == 1 {
                assert_eq!(calls, 1, "a single call goes straight to blank");
            }
            play_reverse(&mut copy, calls, &format!("{effect}/{forward_calls}/{budget}"));
        }
    }
    // A short span is walked at the forward pace (2 frames per call), not
    // stretched to the budget.
    let mut engine = Engine::create("decrypt", PLUGIN_SEED, LOGO, 162, 20, 240).unwrap();
    engine.record_history(HISTORY_FRAMES, HISTORY_BYTES).unwrap();
    for _ in 0..20 {
        engine.draw_logo(LogoMode::OneTime).unwrap();
    }
    let calls = engine.begin_reverse(OUTRO_CALLS, 2).unwrap();
    assert_eq!(engine.reverse_position().unwrap().history_calls, 10);
    assert!(calls <= 10 + 1 + 1, "decrypt's first frame is nearly empty: {calls}");
}

#[test]
fn reverse_requires_history_and_is_ended_only_by_reset() {
    use ttfx_plymouth::{EngineError, LogoMode};
    let mut engine = Engine::create("decrypt", PLUGIN_SEED, LOGO, 162, 20, 240).unwrap();
    let first = engine.cells().to_vec();
    assert_eq!(engine.begin_reverse(10, 2), Err(EngineError::Unavailable));
    assert_eq!(engine.draw_logo(LogoMode::Reverse), Err(EngineError::InvalidState));
    assert_eq!(engine.record_history(1, HISTORY_BYTES), Err(EngineError::InvalidArgument));
    assert_eq!(engine.record_history(4097, HISTORY_BYTES), Err(EngineError::InvalidArgument));
    assert_eq!(engine.record_history(8, 1024), Err(EngineError::InvalidArgument));
    engine.record_history(2, 162 * 20 * 16).unwrap();
    for _ in 0..500 {
        engine.draw_logo(LogoMode::OneTime).unwrap();
    }
    assert!(engine.history_frames() <= 2);
    assert_eq!(engine.begin_reverse(0, 2), Err(EngineError::InvalidArgument));
    assert_eq!(engine.begin_reverse(10, 0), Err(EngineError::InvalidArgument));
    let before = engine.cells().to_vec();
    let calls = engine.begin_reverse(10, 2).unwrap();
    assert_eq!(engine.cells(), before, "begin_reverse must not change the frame");
    assert_eq!(engine.begin_reverse(10, 2), Err(EngineError::InvalidState));
    assert_eq!(engine.draw_logo(LogoMode::OneTime), Err(EngineError::InvalidState));
    assert_eq!(engine.draw_logo(LogoMode::Loop), Err(EngineError::InvalidState));
    assert_eq!(engine.step(), Err(EngineError::InvalidState));
    assert_eq!(engine.record_history(8, HISTORY_BYTES), Err(EngineError::InvalidState));
    play_reverse(&mut engine, calls, "two-frame record");
    engine.reset().unwrap();
    assert!(engine.reverse_position().is_none());
    assert_eq!(engine.cells(), first, "reset restores the deterministic first frame");
    assert_eq!(engine.draw_logo(LogoMode::OneTime).unwrap(), StepOutcome::Frame);
    assert_eq!(engine.history_frames(), 2, "the record restarts at the reset");
    engine.record_history(0, 0).unwrap();
    assert_eq!(engine.history_frames(), 0);
    assert_eq!(engine.begin_reverse(10, 2), Err(EngineError::Unavailable));
}
