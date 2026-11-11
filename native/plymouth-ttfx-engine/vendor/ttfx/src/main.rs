use std::io::{IsTerminal, Read};
use std::process::ExitCode;

use clap::Parser;

use ttfx::engine::terminal::Terminal;
use ttfx::{cli, engine};

fn get_piped_input() -> String {
    let stdin = std::io::stdin();
    if stdin.is_terminal() {
        return String::new();
    }
    let mut buf: Vec<u8> = Vec::new();
    if stdin.lock().read_to_end(&mut buf).is_err() {
        return String::new();
    }
    // strict UTF-8, like Python's text-mode stdin (plan.md §8)
    match String::from_utf8(buf) {
        Ok(s) => s,
        Err(e) => {
            ttfx::outln!("Error decoding input: {e}");
            std::process::exit(1);
        }
    }
}

/// Skip the arena teardown on the way out. Output is already flushed and
/// nothing in the engine has a Drop impl that does work, so freeing tens of
/// thousands of characters — each with its own scenes, paths and frames — one
/// by one is pure exit latency; on binarypath it is ~4% of the run.
///
/// Only the exit paths come through here. A resize rebuild drops its engine
/// normally, so a long session of resizes does not accumulate them.
fn forget_engine<E, C>(effect: E, ctx: C) {
    std::mem::forget(effect);
    std::mem::forget(ctx);
}

fn main() -> ExitCode {
    ttfx::tune_allocator();
    ttfx::restore_sigpipe();
    let cli = cli::Cli::parse();

    // upstream prints the completion script and returns before any input handling
    if let Some(shell) = &cli.print_completion {
        use clap::CommandFactory;
        let generator = match shell.as_str() {
            "bash" => clap_complete::Shell::Bash,
            _ => clap_complete::Shell::Zsh,
        };
        let mut command = cli::Cli::command();
        clap_complete::generate(generator, &mut command, "ttfx", &mut std::io::stdout());
        return ExitCode::SUCCESS;
    }

    let input_data = match &cli.input_file {
        Some(path) => match std::fs::read(path) {
            Ok(bytes) => match String::from_utf8(bytes) {
                Ok(s) => s,
                Err(e) => {
                    // upstream prints runtime file errors to STDOUT and exits 1
                    ttfx::outln!("Error reading input file: {e}");
                    return ExitCode::from(1);
                }
            },
            Err(e) => {
                ttfx::outln!("Error reading input file: {e}");
                return ExitCode::from(1);
            }
        },
        None => get_piped_input(),
    };

    if input_data.trim().is_empty() {
        ttfx::outln!("NO INPUT.");
        return ExitCode::from(1);
    }

    if cli.m0_dump {
        return m0_dump(&input_data, &cli);
    }

    let mut rng = match cli.seed {
        Some(seed) => ttfx::utils::rng::Rng::seeded(seed),
        None => ttfx::utils::rng::Rng::from_entropy(),
    };

    // --random-effect: pick from the registry (filtered), run with pure
    // default effect config — upstream ignores effect CLI args here too.
    let chosen_effect;
    let effect_command = if cli.random_effect {
        use clap::CommandFactory;
        let mut names: Vec<String> = cli::Cli::command()
            .get_subcommands()
            .map(|c| c.get_name().to_string())
            .collect();
        if !cli.include_effects.is_empty() {
            names.retain(|n| cli.include_effects.contains(n));
        }
        names.retain(|n| !cli.exclude_effects.contains(n));
        if names.is_empty() {
            ttfx::errln!("Error: No effects available after filtering.");
            return ExitCode::from(1);
        }
        let name = names[rng.choice_index(names.len())].clone();
        chosen_effect = match clap::Parser::try_parse_from::<_, &str>(["ttfx", &name]) {
            Ok(cli::Cli {
                effect: Some(effect),
                ..
            }) => effect,
            _ => {
                ttfx::errln!("Error: failed to build effect '{name}'.");
                return ExitCode::from(1);
            }
        };
        &chosen_effect
    } else {
        match &cli.effect {
            Some(effect) => effect,
            None => {
                ttfx::errln!("Error: No effect specified.");
                return ExitCode::from(1);
            }
        }
    };

    let mut config = cli.terminal_config();
    // SIGWINCH is delivered to every process in the terminal's foreground group,
    // whatever its stdout points at. Reacting to it when the animation is being
    // redirected would leave a truncated first run followed by a complete second
    // one in the file. SIGTERM teardown is tty-only for the same reason: a
    // redirected stream must not gain teardown bytes. Only the teardown differs
    // — the tty run re-raises afterwards, so both die from the signal.
    let tty_output = !cli.parity_dump && std::io::stdout().is_terminal();
    if !cli.parity_dump {
        ttfx::install_sigint_handler();
    }
    if tty_output {
        ttfx::install_sigterm_handler();
        ttfx::install_sigwinch_handler();
    }

    // The engines in the order they are offered the run: fx, then the
    // original engine, which takes what fx declines (out-of-range duration
    // options) and every run under TTFX_FX=0. The original engine is also the
    // reference fx is checked against.
    let result = loop {
        let clock = if cli.parity_dump || cli.virtual_clock {
            ttfx::engine::ctx::Clock::virtual_with_frame_rate(config.frame_rate)
        } else {
            ttfx::engine::ctx::Clock::real()
        };
        if let Some(mut effect) = ttfx::fx::effects::build(effect_command) {
            let mut engine = match ttfx::fx::Engine::new(&input_data, config.clone(), rng, clock) {
                Ok(engine) => engine,
                Err(engine::error::EngineError::UnsupportedAnsiSequence(seq)) => {
                    ttfx::errln!("Error: Unsupported ANSI sequence in input data: {seq:?}");
                    return ExitCode::from(1);
                }
                Err(e) => {
                    ttfx::errln!("Error: {e}");
                    return ExitCode::from(1);
                }
            };
            let outcome = if cli.parity_dump {
                ttfx::fx::run::dump_effect(effect.as_mut(), &mut engine, cli.max_frames)
                    .map(|_| ttfx::engine::effect::RunOutcome::Complete)
            } else {
                ttfx::fx::run::run_effect(effect.as_mut(), &mut engine, tty_output)
            };
            match outcome {
                Ok(ttfx::engine::effect::RunOutcome::TerminalResized) => {
                    config.reuse_canvas = false;
                    rng = engine.rng;
                    continue;
                }
                done => {
                    forget_engine(effect, engine);
                    break done.map(|_| ());
                }
            }
        }
        // TTFX_FX=force: a run fx declines is an error, so comparisons can't
        // quietly check the original engine against itself.
        if std::env::var_os("TTFX_FX").is_some_and(|v| v == "force") {
            ttfx::errln!("ttfx: TTFX_FX=force, but the fx engine declined this run");
            return ExitCode::from(3);
        }
        let mut ctx =
            match ttfx::engine::ctx::EngineCtx::new(&input_data, config.clone(), rng, clock) {
                Ok(ctx) => ctx,
                Err(engine::error::EngineError::UnsupportedAnsiSequence(seq)) => {
                    ttfx::errln!("Error: Unsupported ANSI sequence in input data: {seq:?}");
                    return ExitCode::from(1);
                }
                Err(e) => {
                    ttfx::errln!("Error: {e}");
                    return ExitCode::from(1);
                }
            };
        let mut effect = effect_command.build_effect();

        let outcome = if cli.parity_dump {
            ttfx::engine::effect::dump_effect(effect.as_mut(), &mut ctx, cli.max_frames)
                .map(|_| ttfx::engine::effect::RunOutcome::Complete)
        } else {
            ttfx::engine::effect::run_effect(effect.as_mut(), &mut ctx, tty_output)
        };
        match outcome {
            Ok(ttfx::engine::effect::RunOutcome::TerminalResized) => {
                // run_effect wiped the old area and left the cursor at its top,
                // so the rebuild lays out from here. --reuse-canvas would send
                // prep_canvas to a DEC anchor that no longer applies, so it only
                // governs the first run. Dropping this engine normally is what
                // keeps a long session of resizes from accumulating them.
                config.reuse_canvas = false;
                rng = ctx.rng;
            }
            done => {
                forget_engine(effect, ctx);
                break done.map(|_| ());
            }
        }
    };
    std::mem::forget(input_data);

    match result {
        Ok(()) => {
            if ttfx::terminated() {
                ttfx::die_from_sigterm();
            }
            if ttfx::interrupted() {
                ExitCode::from(1)
            } else {
                ExitCode::SUCCESS
            }
        }
        Err(e) => {
            ttfx::errln!("Error: {e}");
            ExitCode::from(1)
        }
    }
}

/// M0 parity path: build the Terminal, make every character in
/// character_by_input_coord visible, print the first frame to stdout.
fn m0_dump(input_data: &str, cli: &cli::Cli) -> ExitCode {
    let config = cli.terminal_config();
    let mut terminal = match Terminal::new(input_data, config) {
        Ok(t) => t,
        Err(engine::error::EngineError::UnsupportedAnsiSequence(seq)) => {
            ttfx::errln!("Error: Unsupported ANSI sequence in input data: {seq:?}");
            return ExitCode::from(1);
        }
        Err(e) => {
            ttfx::errln!("Error: {e}");
            return ExitCode::from(1);
        }
    };
    let ids: Vec<_> = terminal
        .character_by_input_coord
        .values()
        .copied()
        .collect();
    for id in ids {
        terminal.set_character_visibility(id, true);
    }
    print!("{}", terminal.get_formatted_output_string());
    println!();
    ExitCode::SUCCESS
}
