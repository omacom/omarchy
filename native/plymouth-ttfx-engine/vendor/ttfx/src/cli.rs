//! CLI root: the 15 TerminalConfig options (same names/defaults as upstream tte)
//! plus global args. Effect subcommands land in M3+.

use clap::Parser;

use crate::engine::animation::ExistingColorHandling;
use crate::engine::canvas::Anchor;
use crate::engine::terminal::TerminalConfig;
use crate::utils::graphics::Color;

fn parse_positive_int(s: &str) -> Result<i64, String> {
    let v: i64 = s.parse().map_err(|_| format!("invalid int value: '{s}'"))?;
    if v > 0 {
        Ok(v)
    } else {
        Err(format!("{v} is not > 0"))
    }
}

fn parse_non_negative_int(s: &str) -> Result<i64, String> {
    let v: i64 = s.parse().map_err(|_| format!("invalid int value: '{s}'"))?;
    if v >= 0 {
        Ok(v)
    } else {
        Err(format!("{v} is not >= 0"))
    }
}

fn parse_canvas_dimension(s: &str) -> Result<i64, String> {
    let v: i64 = s.parse().map_err(|_| format!("invalid int value: '{s}'"))?;
    if v >= -1 {
        Ok(v)
    } else {
        Err(format!("{v} is not >= -1"))
    }
}

/// argutils.ColorArg: <=3 chars -> xterm int 0-255, else hex.
pub fn parse_color(s: &str) -> Result<Color, String> {
    if s.len() <= 3 {
        let code: u8 = s.parse().map_err(|_| format!("invalid color value: '{s}'"))?;
        Ok(Color::from_xterm(code))
    } else {
        Color::from_hex(s)
    }
}

fn parse_anchor(s: &str) -> Result<Anchor, String> {
    Anchor::parse(s).ok_or_else(|| format!("invalid anchor: '{s}'"))
}

fn parse_existing_color_handling(s: &str) -> Result<ExistingColorHandling, String> {
    match s {
        "always" => Ok(ExistingColorHandling::Always),
        "dynamic" => Ok(ExistingColorHandling::Dynamic),
        "ignore" => Ok(ExistingColorHandling::Ignore),
        _ => Err(format!("invalid choice: '{s}' (choose from 'always', 'dynamic', 'ignore')")),
    }
}

#[derive(Parser, Debug)]
#[command(
    name = "ttfx",
    version,
    about = "Terminal text effects (Rust port of terminaltexteffects)",
    // upstream tte exposes --version/-v, so replace clap's default -V flag
    disable_version_flag = true
)]
pub struct Cli {
    /// Print the version and exit
    #[arg(short = 'v', long = "version", action = clap::ArgAction::Version)]
    pub version: Option<bool>,

    /// File to read input from
    #[arg(short = 'i', long = "input-file")]
    pub input_file: Option<std::path::PathBuf>,

    #[arg(long = "tab-width", default_value_t = 4, value_parser = parse_positive_int)]
    pub tab_width: i64,

    #[arg(long = "xterm-colors", default_value_t = false)]
    pub xterm_colors: bool,

    #[arg(long = "no-color", default_value_t = false)]
    pub no_color: bool,

    #[arg(long = "terminal-background-color", default_value = "#000000", value_parser = parse_color)]
    pub terminal_background_color: Color,

    #[arg(long = "existing-color-handling", default_value = "ignore", value_parser = parse_existing_color_handling)]
    pub existing_color_handling: ExistingColorHandling,

    #[arg(long = "wrap-text", default_value_t = false)]
    pub wrap_text: bool,

    #[arg(long = "frame-rate", default_value_t = 60, value_parser = parse_non_negative_int)]
    pub frame_rate: i64,

    #[arg(long = "canvas-width", default_value_t = -1, value_parser = parse_canvas_dimension, allow_negative_numbers = true)]
    pub canvas_width: i64,

    #[arg(long = "canvas-height", default_value_t = -1, value_parser = parse_canvas_dimension, allow_negative_numbers = true)]
    pub canvas_height: i64,

    #[arg(long = "anchor-canvas", default_value = "sw", value_parser = parse_anchor)]
    pub anchor_canvas: Anchor,

    #[arg(long = "anchor-text", default_value = "sw", value_parser = parse_anchor)]
    pub anchor_text: Anchor,

    #[arg(long = "ignore-terminal-dimensions", default_value_t = false)]
    pub ignore_terminal_dimensions: bool,

    #[arg(long = "reuse-canvas", default_value_t = false)]
    pub reuse_canvas: bool,

    #[arg(long = "no-eol", default_value_t = false)]
    pub no_eol: bool,

    #[arg(long = "no-restore-cursor", default_value_t = false)]
    pub no_restore_cursor: bool,

    /// Seed for the random number generator (deterministic within ttfx)
    #[arg(long = "seed")]
    pub seed: Option<u64>,

    /// Print a shell completion script and exit
    #[arg(long = "print-completion", value_name = "SHELL", value_parser = ["bash", "zsh"])]
    pub print_completion: Option<String>,

    /// Run a random effect
    #[arg(short = 'R', long = "random-effect", default_value_t = false)]
    pub random_effect: bool,

    /// Limit random-effect selection to these effects
    #[arg(long = "include-effects", num_args = 1.., conflicts_with = "exclude_effects")]
    pub include_effects: Vec<String>,

    /// Exclude these effects from random-effect selection
    #[arg(long = "exclude-effects", num_args = 1..)]
    pub exclude_effects: Vec<String>,

    /// M0 debug: make every canvas character visible and print the first frame
    /// (used by the parity harness; hidden from help)
    #[arg(long = "m0-dump", default_value_t = false, hide = true)]
    pub m0_dump: bool,

    /// Parity harness: dump length-prefixed frames deterministically (requires --seed)
    #[arg(long = "parity-dump", default_value_t = false, hide = true)]
    pub parity_dump: bool,

    /// Parity harness: stop after N frames
    #[arg(long = "max-frames", hide = true)]
    pub max_frames: Option<u64>,

    /// Parity harness: drive the clock virtually (1/frame_rate per frame) so
    /// clock-dependent effects (matrix, thunderstorm) are reproducible on the
    /// real tty output path. Implied by --parity-dump.
    #[arg(long = "virtual-clock", default_value_t = false, hide = true)]
    pub virtual_clock: bool,

    #[command(subcommand)]
    pub effect: Option<crate::effects::EffectCommand>,
}

impl Cli {
    pub fn terminal_config(&self) -> TerminalConfig {
        TerminalConfig {
            tab_width: self.tab_width,
            xterm_colors: self.xterm_colors,
            no_color: self.no_color,
            terminal_background_color: self.terminal_background_color.clone(),
            existing_color_handling: self.existing_color_handling,
            wrap_text: self.wrap_text,
            frame_rate: self.frame_rate,
            canvas_width: self.canvas_width,
            canvas_height: self.canvas_height,
            anchor_canvas: self.anchor_canvas,
            anchor_text: self.anchor_text,
            ignore_terminal_dimensions: self.ignore_terminal_dimensions,
            reuse_canvas: self.reuse_canvas,
            no_eol: self.no_eol,
            no_restore_cursor: self.no_restore_cursor,
        }
    }
}
