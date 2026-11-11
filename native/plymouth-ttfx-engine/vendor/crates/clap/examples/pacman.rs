use clap::{Arg, ArgAction, Command};

fn cli() -> Command {
    Command::new("pacman")
        .about("package manager utility")
        .version("5.2.1")
        .subcommand_required(true)
        .arg_required_else_help(true)
        // Query subcommand
        //
        // Only a few of its arguments are implemented below.
        .subcommand(
            Command::new("query")
                .short_flag('Q')
                .long_flag("query")
                .about("Query the package database.")
                .arg(
                    Arg::new("search")
                        .short('s')
                        .long("search")
                        .help("search locally installed packages for matching strings")
                        .conflicts_with("info")
                        .action(ArgAction::Set)
                        .num_args(1..),
                )
                .arg(
                    Arg::new("info")
                        .long("info")
                        .short('i')
                        .conflicts_with("search")
                        .help("view package information")
                        .action(ArgAction::Set)
                        .num_args(1..),
                ),
        )
        // Sync subcommand
        //
        // Only a few of its arguments are implemented below.
        .subcommand(
            Command::new("sync")
                .short_flag('S')
                .long_flag("sync")
                .about("Synchronize packages.")
                .arg(
                    Arg::new("search")
                        .short('s')
                        .long("search")
                        .conflicts_with("info")
                        .action(ArgAction::Set)
                        .num_args(1..)
                        .help("search remote repositories for matching strings"),
                )
                .arg(
                    Arg::new("info")
                        .long("info")
                        .conflicts_with("search")
                        .short('i')
                        .action(ArgAction::SetTrue)
                        .help("view package information"),
                )
                .arg(
                    Arg::new("package")
                        .help("packages")
                        .required_unless_present("search")
                        .action(ArgAction::Set)
                        .num_args(1..),
                ),
        )
}

fn main() {
    let matches = cli().get_matches();

    match matches.subcommand() {
        Some(("sync", sync_matches)) => {
            if sync_matches.contains_id("search") {
                let packages: Vec<_> = sync_matches
                    .get_many::<String>("search")
                    .expect("contains_id")
                    .map(|s| s.as_str())
                    .collect();
                let values = packages.join(", ");
                println!("Searching for {values}...");
                return;
            }

            let packages: Vec<_> = sync_matches
                .get_many::<String>("package")
                .expect("is present")
                .map(|s| s.as_str())
                .collect();
            let values = packages.join(", ");

            if sync_matches.get_flag("info") {
                println!("Retrieving info for {values}...");
            } else {
                println!("Installing {values}...");
            }
        }
        Some(("query", query_matches)) => {
            if let Some(packages) = query_matches.get_many::<String>("info") {
                let comma_sep = packages.map(|s| s.as_str()).collect::<Vec<_>>().join(", ");
                println!("Retrieving info for {comma_sep}...");
            } else if let Some(queries) = query_matches.get_many::<String>("search") {
                let comma_sep = queries.map(|s| s.as_str()).collect::<Vec<_>>().join(", ");
                println!("Searching Locally for {comma_sep}...");
            } else {
                println!("Displaying all locally installed packages...");
            }
        }
        _ => unreachable!(), // If all subcommands are defined above, anything else is unreachable
    }
}

#[cfg(all(test, feature = "help", feature = "usage"))]
mod tests {
    use super::*;

    #[test]
    fn help_output_is_stable() {
        snapbox::assert_data_eq!(
            render_reference(cli()),
            snapbox::file!["snapshots/pacman.txt"].raw()
        );
    }

    fn render_reference(mut command: Command) -> String {
        command = command.term_width(0);
        command.build();

        let mut buffer = String::new();
        write_help(&mut buffer, &mut command, String::new());

        buffer
    }

    fn write_help(buffer: &mut String, cmd: &mut Command, mut path: String) {
        let header = if path.is_empty() { "#" } else { "##" };
        path.push(' ');
        path.push_str(cmd.get_name());

        buffer.push_str(header);
        buffer.push_str(&path);
        buffer.push_str("\n\n");
        buffer.push_str(&cmd.render_long_help().to_string());

        let has_generated_help = !cmd.is_disable_help_subcommand_set();
        for subcommand in cmd.get_subcommands_mut() {
            // Generated `help` nodes proxy other commands.
            if has_generated_help && subcommand.get_name() == "help" {
                continue;
            }

            buffer.push('\n');
            write_help(buffer, subcommand, path.clone());
        }
    }
}
