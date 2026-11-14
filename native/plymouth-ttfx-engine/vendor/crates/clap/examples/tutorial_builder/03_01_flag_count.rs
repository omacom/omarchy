use clap::{Arg, ArgAction, command};

fn main() {
    let matches = command!() // requires `cargo` feature
        .arg(
            Arg::new("verbose")
                .short('v')
                .long("verbose")
                .action(ArgAction::Count),
        )
        .get_matches();

    println!("verbose: {:?}", matches.get_count("verbose"));
}
