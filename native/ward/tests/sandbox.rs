use omarchy_ward::sandbox::{landlock_abi, restrict_worker};
use std::{
  fs::{File, OpenOptions},
  io,
  os::{
    fd::AsFd,
    unix::{
      fs::OpenOptionsExt,
      net::{UnixListener, UnixStream},
    },
  },
  path::Path,
  process::Command,
};

fn path_fd(path: &Path) -> File {
  OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open(path)
    .unwrap()
}

fn check_connections(root: &Path) {
  assert!(UnixStream::connect(root.join("allowed")).is_ok());
  assert_eq!(
    UnixStream::connect(root.join("denied")).unwrap_err().kind(),
    io::ErrorKind::PermissionDenied
  );
}

// Executed in a fresh process: never restrict the parent test runner.
#[test]
fn restricted_child() {
  let Some(root) = std::env::var_os("OMARCHY_SANDBOX_TEST_ROOT") else {
    return;
  };
  let root = Path::new(&root);
  let mode = std::env::var("OMARCHY_SANDBOX_TEST_MODE").unwrap();
  if mode == "directory" {
    let directory = path_fd(root);
    assert_eq!(
      restrict_worker(&[directory.as_fd()]).unwrap_err().kind(),
      io::ErrorKind::InvalidInput
    );
    println!("DIRECTORY_IS_NOT_IPC_AUTHORITY");
    return;
  }
  if mode == "helper" {
    check_connections(root);
    println!("HELPER_INHERITS_RESTRICTIONS");
    return;
  }
  let allowed = path_fd(&root.join("allowed"));
  restrict_worker(&[allowed.as_fd()]).unwrap();
  drop(allowed);
  check_connections(root);
  let thread_root = root.to_owned();
  std::thread::spawn(move || check_connections(&thread_root))
    .join()
    .unwrap();
  let own_path = root.join("private-child-socket");
  let _own = UnixListener::bind(&own_path).unwrap();
  assert!(UnixStream::connect(&own_path).is_ok());
  assert_eq!(
    unsafe { libc::syscall(libc::SYS_clone3, std::ptr::null::<u8>(), 0) },
    -1
  );
  assert_eq!(
    io::Error::last_os_error().raw_os_error(),
    Some(libc::ENOSYS)
  );
  assert_eq!(
    unsafe { libc::socket(libc::AF_VSOCK, libc::SOCK_STREAM, 0) },
    -1
  );
  assert_eq!(
    io::Error::last_os_error().raw_os_error(),
    Some(libc::EAFNOSUPPORT)
  );
  let helper = Command::new(std::env::current_exe().unwrap())
    .args(["--exact", "restricted_child", "--nocapture"])
    .env("OMARCHY_SANDBOX_TEST_MODE", "helper")
    .output()
    .unwrap();
  assert!(
    helper.status.success(),
    "helper failed: {}",
    String::from_utf8_lossy(&helper.stderr)
  );
  assert!(String::from_utf8_lossy(&helper.stdout).contains("HELPER_INHERITS_RESTRICTIONS"));
  println!("KERNEL_RESTRICTIONS_VERIFIED");
}

#[test]
fn kernel_enforces_socket_scope_and_helpers_still_work() {
  if !matches!(landlock_abi(), Ok(9..)) {
    assert!(restrict_worker(&[]).is_err());
    eprintln!(
      "Landlock ABI 9 unavailable: verified fail-closed behavior; kernel enforcement test skipped"
    );
    return;
  }
  let root = tempfile::tempdir().unwrap();
  let _allowed = UnixListener::bind(root.path().join("allowed")).unwrap();
  let _denied = UnixListener::bind(root.path().join("denied")).unwrap();
  for (mode, marker) in [
    ("directory", "DIRECTORY_IS_NOT_IPC_AUTHORITY"),
    ("worker", "KERNEL_RESTRICTIONS_VERIFIED"),
  ] {
    let child = Command::new(std::env::current_exe().unwrap())
      .args(["--exact", "restricted_child", "--nocapture"])
      .env("OMARCHY_SANDBOX_TEST_ROOT", root.path())
      .env("OMARCHY_SANDBOX_TEST_MODE", mode)
      .output()
      .unwrap();
    assert!(
      child.status.success(),
      "child failed: {}\n{}",
      String::from_utf8_lossy(&child.stdout),
      String::from_utf8_lossy(&child.stderr)
    );
    assert!(String::from_utf8_lossy(&child.stdout).contains(marker));
  }
}
