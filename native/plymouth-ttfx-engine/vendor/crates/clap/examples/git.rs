use std::collections::HashMap;
use std::ffi::OsString;
use std::path::PathBuf;

use clap::{ArgMatches, Command, arg};

fn cli() -> Command {
    Command::new("git")
        .about("A fictional versioning CLI")
        .subcommand_required(true)
        .arg_required_else_help(true)
        .allow_external_subcommands(true)
        .subcommand(
            Command::new("clone")
                .about("Clones repos")
                .arg(arg!(<REMOTE> "The remote to clone"))
                .arg_required_else_help(true),
        )
        .subcommand(
            Command::new("diff")
                .about("Compare two commits")
                .arg(arg!(base: [COMMIT]))
                .arg(arg!(head: [COMMIT]))
                .arg(arg!(path: [PATH]).last(true))
                .arg(
                    arg!(--color <WHEN>)
                        .value_parser(["always", "auto", "never"])
                        .num_args(0..=1)
                        .require_equals(true)
                        .default_value("auto")
                        .default_missing_value("always"),
                ),
        )
        .subcommand(
            Command::new("push")
                .about("pushes things")
                .arg(arg!(<REMOTE> "The remote to target"))
                .arg_required_else_help(true),
        )
        .subcommand(
            Command::new("add")
                .about("adds things")
                .arg_required_else_help(true)
                .arg(arg!(<PATH> ... "Stuff to add").value_parser(clap::value_parser!(PathBuf))),
        )
        .subcommand(
            Command::new("stash")
                .args_conflicts_with_subcommands(true)
                .flatten_help(true)
                .args(push_args())
                .subcommand(Command::new("push").args(push_args()))
                .subcommand(Command::new("pop").arg(arg!([STASH])))
                .subcommand(Command::new("apply").arg(arg!([STASH]))),
        )
}

fn push_args() -> Vec<clap::Arg> {
    vec![arg!(-m --message <MESSAGE>)]
}

fn aliases() -> HashMap<&'static str, Vec<&'static str>> {
    HashMap::from([
        ("last", vec!["diff", "HEAD~", "HEAD", "--"]),
        ("stage", vec!["add"]),
    ])
}

fn parse_aliases() -> Result<ArgMatches, clap::Error> {
    let matches = cli().try_get_matches()?;
    expand_aliases(matches, Vec::new())
}

fn expand_aliases(
    matches: ArgMatches,
    mut expanded: Vec<String>,
) -> Result<ArgMatches, clap::Error> {
    let Some((name, sub_matches)) = matches.subcommand() else {
        return Ok(matches);
    };
    if cli().find_subcommand(name).is_some() {
        return Ok(matches);
    }

    let aliases = aliases();
    let Some(alias) = aliases.get(name) else {
        return Ok(matches);
    };
    let mut args = alias.iter().map(OsString::from).collect::<Vec<_>>();
    args.extend(
        sub_matches
            .get_many::<OsString>("")
            .into_iter()
            .flatten()
            .cloned(),
    );
    let matches = cli().no_binary_name(true).try_get_matches_from(args)?;
    let new_name = matches.subcommand_name().expect("subcommand required");
    expanded.push(name.to_owned());
    if expanded.iter().any(|name| name == new_name) {
        return Err(clap::Error::raw(
            clap::error::ErrorKind::InvalidSubcommand,
            format!("recursive alias `{}`", expanded[0]),
        ));
    }

    expand_aliases(matches, expanded)
}

fn main() {
    let matches = parse_aliases().unwrap_or_else(|error| error.exit());

    match matches.subcommand() {
        Some(("clone", sub_matches)) => {
            println!(
                "Cloning {}",
                sub_matches.get_one::<String>("REMOTE").expect("required")
            );
        }
        Some(("diff", sub_matches)) => {
            let color = sub_matches
                .get_one::<String>("color")
                .map(|s| s.as_str())
                .expect("defaulted in clap");

            let mut base = sub_matches.get_one::<String>("base").map(|s| s.as_str());
            let mut head = sub_matches.get_one::<String>("head").map(|s| s.as_str());
            let mut path = sub_matches.get_one::<String>("path").map(|s| s.as_str());
            if path.is_none() {
                path = head;
                head = None;
                if path.is_none() {
                    path = base;
                    base = None;
                }
            }
            let base = base.unwrap_or("stage");
            let head = head.unwrap_or("worktree");
            let path = path.unwrap_or("");
            println!("Diffing {base}..{head} {path} (color={color})");
        }
        Some(("push", sub_matches)) => {
            println!(
                "Pushing to {}",
                sub_matches.get_one::<String>("REMOTE").expect("required")
            );
        }
        Some(("add", sub_matches)) => {
            let paths = sub_matches
                .get_many::<PathBuf>("PATH")
                .into_iter()
                .flatten()
                .collect::<Vec<_>>();
            println!("Adding {paths:?}");
        }
        Some(("stash", sub_matches)) => {
            let stash_command = sub_matches.subcommand().unwrap_or(("push", sub_matches));
            match stash_command {
                ("apply", sub_matches) => {
                    let stash = sub_matches.get_one::<String>("STASH");
                    println!("Applying {stash:?}");
                }
                ("pop", sub_matches) => {
                    let stash = sub_matches.get_one::<String>("STASH");
                    println!("Popping {stash:?}");
                }
                ("push", sub_matches) => {
                    let message = sub_matches.get_one::<String>("message");
                    println!("Pushing {message:?}");
                }
                (name, _) => {
                    unreachable!("Unsupported subcommand `{name}`")
                }
            }
        }
        Some((ext, sub_matches)) => {
            let args = sub_matches
                .get_many::<OsString>("")
                .into_iter()
                .flatten()
                .collect::<Vec<_>>();
            println!("Calling out to {ext:?} with {args:?}");
        }
        _ => unreachable!(), // If all subcommands are defined above, anything else is unreachable!()
    }

    // Continued program logic goes here...
}
