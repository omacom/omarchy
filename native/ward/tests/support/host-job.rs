// Standalone disposable executable: no account, session-bus or real user data.
use std::{
  env, fs,
  io::{self, Write},
  os::unix::net::UnixStream,
  path::Path,
  process::{self, Command},
  thread,
  time::Duration,
};

fn main() -> io::Result<()> {
  let args: Vec<String> = env::args().collect();
  match args.get(1).map(String::as_str) {
    Some("failure") => {
      io::stdout().write_all(b"domain failure\0\xff")?;
      io::stderr().write_all(b"fixture failed\n")?;
      process::exit(1);
    }
    Some("identity") => {
      println!("{}", args[0]);
      Ok(())
    }
    Some("echo") => {
      assert!(
        fs::read_to_string("/proc/self/status")?
          .lines()
          .any(|line| line.split_whitespace().collect::<Vec<_>>() == ["NoNewPrivs:", "1"])
      );
      // Drop the directory iterator before probing, so its own fd is closed.
      let descriptors = fs::read_dir("/proc/self/fd")?
        .map(|entry| entry.map(|entry| entry.path()))
        .collect::<io::Result<Vec<_>>>()?;
      for path in descriptors {
        let fd: u32 = path.file_name().unwrap().to_str().unwrap().parse().unwrap();
        assert!(
          fd <= 2 || !path.exists(),
          "inherited descriptor: {path:?} -> {:?}",
          fs::read_link(&path)
        );
      }
      let mut output = io::stdout().lock();
      for arg in &args[2..] {
        output.write_all(arg.as_bytes())?;
        output.write_all(&[0])?;
      }
      write!(
        output,
        "cwd={}\0HOME={}\0PATH={}\0UNSELECTED={}\0NOTIFY={}\0",
        env::current_dir()?.display(),
        env::var("HOME").unwrap(),
        env::var("PATH").unwrap(),
        if env::var_os("PRIVATE_MARKER").is_some() {
          "present"
        } else {
          "unset"
        },
        if env::var_os("NOTIFY_SOCKET").is_some() {
          "present"
        } else {
          "unset"
        }
      )?;
      // The running image is sealed; the installed path remains an ordinary
      // host file and is not a mount overlay in this process.
      let mutation = fs::OpenOptions::new()
        .write(true)
        .open("/proc/self/exe")
        .and_then(|mut file| file.write_all(b"mutate the running image"));
      assert!(mutation.is_err(), "executed bytes were writable");
      io::stderr().write_all(b"fixture stderr\0\xff")?;
      output.flush()?;
      process::exit(7);
    }
    Some(mode @ ("flood-out" | "flood-err")) => {
      let mut output: Box<dyn Write> = if mode == "flood-out" {
        Box::new(io::stdout().lock())
      } else {
        Box::new(io::stderr().lock())
      };
      loop {
        output.write_all(&[0; 8192])?;
      }
    }
    Some("tree") if args.len() == 4 => {
      assert!(
        Command::new("/usr/bin/setsid")
          .args(["--fork", &args[0], "descendant", &args[2]])
          .status()?
          .success()
      );
      while !Path::new(&args[3]).exists() {
        thread::sleep(Duration::from_millis(1));
      }
      process::exit(17); // The detached descendant remains until teardown.
    }
    Some("descendant") if args.len() == 3 => {
      let _connection = UnixStream::connect(&args[2])?;
      loop {
        thread::park();
      }
    }
    _ => panic!("unknown fixture invocation"),
  }
}
