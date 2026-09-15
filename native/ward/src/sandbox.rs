use std::{
  io,
  mem::size_of,
  os::fd::{AsRawFd, BorrowedFd, FromRawFd, OwnedFd},
};

const RESOLVE_UNIX: u64 = 1 << 16;
const LANDLOCK_TSYNC: u32 = 1 << 3;
const ALLOW: u32 = 0x7fff_0000;
const ERRNO: u32 = 0x0005_0000;
const KILL_PROCESS: u32 = 0x8000_0000;

#[cfg(target_arch = "x86_64")]
const AUDIT_ARCH: u32 = 0xc000_003e;
#[cfg(target_arch = "aarch64")]
const AUDIT_ARCH: u32 = 0xc000_00b7;
#[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
compile_error!("worker syscall restrictions require an audited target architecture");

#[repr(C)]
struct Ruleset {
  handled_fs: u64,
  handled_net: u64,
  scoped: u64,
}

#[repr(C, packed)]
struct PathRule {
  allowed: u64,
  parent_fd: i32,
}

fn checked(value: libc::c_long) -> io::Result<libc::c_long> {
  if value < 0 {
    Err(io::Error::last_os_error())
  } else {
    Ok(value)
  }
}

pub fn landlock_abi() -> io::Result<u32> {
  // VERSION queries do not install or alter a ruleset.
  checked(unsafe {
    libc::syscall(
      libc::SYS_landlock_create_ruleset,
      std::ptr::null::<Ruleset>(),
      0,
      1,
    )
  })
  .map(|abi| abi as u32)
}

fn require_abi(abi: u32) -> io::Result<()> {
  if abi < 9 {
    Err(io::Error::new(
      io::ErrorKind::Unsupported,
      "plugin isolation requires Landlock ABI 9 (pathname Unix socket restrictions)",
    ))
  } else {
    Ok(())
  }
}

/// Irreversibly restrict this process and its threads before executing a worker.
///
/// `sockets` must be O_PATH descriptors for controller-authorized private socket
/// inodes, opened after Bubblewrap has established the worker's filesystem view.
/// A directory FD is rejected: a file grant must not also become an IPC grant.
/// Connected inherited FDs remain usable and must be audited by the caller.
/// Helpers inherit these restrictions. Any error is terminal for the bootstrap;
/// a partially restricted process must never proceed to execute plugin code.
pub fn restrict_worker(sockets: &[BorrowedFd<'_>]) -> io::Result<()> {
  restrict_private_worker(sockets, &[])
}

/// Private tmpfs directories created by the launcher, not host file grants.
/// This lets helpers use their own local sockets without granting host IPC.
pub(crate) fn restrict_private_worker(
  sockets: &[BorrowedFd<'_>],
  private_directories: &[BorrowedFd<'_>],
) -> io::Result<()> {
  require_abi(landlock_abi()?)?;
  if sockets.len() > 16 || private_directories.len() > 3 {
    return Err(io::Error::new(
      io::ErrorKind::InvalidInput,
      "too many private sockets",
    ));
  }
  let rules = Ruleset {
    handled_fs: RESOLVE_UNIX,
    handled_net: 0,
    scoped: 3,
  };
  let fd = checked(unsafe {
    libc::syscall(
      libc::SYS_landlock_create_ruleset,
      &rules,
      size_of::<Ruleset>(),
      0,
    )
  })? as i32;
  // The successful syscall created this owned FD; no other owner exists.
  let rules_fd = unsafe { OwnedFd::from_raw_fd(fd) };
  for socket in sockets {
    let mut stat: libc::stat = unsafe { std::mem::zeroed() };
    checked(unsafe { libc::fstat(socket.as_raw_fd(), &mut stat) } as libc::c_long)?;
    if stat.st_mode & libc::S_IFMT != libc::S_IFSOCK {
      return Err(io::Error::new(
        io::ErrorKind::InvalidInput,
        "IPC grants require socket inodes",
      ));
    }
    let rule = PathRule {
      allowed: RESOLVE_UNIX,
      parent_fd: socket.as_raw_fd(),
    };
    checked(unsafe {
      libc::syscall(
        libc::SYS_landlock_add_rule,
        rules_fd.as_raw_fd(),
        1,
        &rule,
        0,
      )
    })?;
  }
  for directory in private_directories {
    let mut stat: libc::stat = unsafe { std::mem::zeroed() };
    let mut filesystem: libc::statfs = unsafe { std::mem::zeroed() };
    checked(unsafe { libc::fstat(directory.as_raw_fd(), &mut stat) } as libc::c_long)?;
    checked(unsafe { libc::fstatfs(directory.as_raw_fd(), &mut filesystem) } as libc::c_long)?;
    if stat.st_mode & libc::S_IFMT != libc::S_IFDIR || filesystem.f_type != libc::TMPFS_MAGIC {
      return Err(io::Error::new(
        io::ErrorKind::InvalidInput,
        "private IPC roots must be launcher-created tmpfs directories",
      ));
    }
    let rule = PathRule {
      allowed: RESOLVE_UNIX,
      parent_fd: directory.as_raw_fd(),
    };
    checked(unsafe {
      libc::syscall(
        libc::SYS_landlock_add_rule,
        rules_fd.as_raw_fd(),
        1,
        &rule,
        0,
      )
    })?;
  }
  checked(unsafe { libc::prctl(libc::PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0) } as libc::c_long)?;
  checked(unsafe {
    libc::syscall(
      libc::SYS_landlock_restrict_self,
      rules_fd.as_raw_fd(),
      LANDLOCK_TSYNC,
    )
  })?;
  let filter = worker_filter();
  let program = libc::sock_fprog {
    len: filter.len() as u16,
    filter: filter.as_ptr().cast_mut(),
  };
  // Synchronize the seccomp filter across threads, just like the Landlock domain.
  let result = checked(unsafe { libc::syscall(libc::SYS_seccomp, 1, 1, &program) })?;
  if result != 0 {
    return Err(io::Error::other(
      "could not synchronize worker syscall restrictions",
    ));
  }
  Ok(())
}

fn instruction(code: u16, jt: u8, jf: u8, k: u32) -> libc::sock_filter {
  libc::sock_filter { code, jt, jf, k }
}

fn worker_filter() -> Vec<libc::sock_filter> {
  const LOAD: u16 = 0x20;
  const EQ: u16 = 0x15;
  const GE: u16 = 0x35;
  const BITS: u16 = 0x45;
  const RET: u16 = 0x06;
  let mut filter = vec![
    instruction(LOAD, 0, 0, 4), // seccomp_data.arch
    instruction(EQ, 1, 0, AUDIT_ARCH),
    instruction(RET, 0, 0, KILL_PROCESS),
    instruction(LOAD, 0, 0, 0), // seccomp_data.nr
    // Reject x32 and negative syscall numbers rather than allowing a second ABI.
    instruction(GE, 0, 1, 0x4000_0000),
    instruction(RET, 0, 0, KILL_PROCESS),
  ];
  for syscall in [
    libc::SYS_ptrace,
    libc::SYS_process_vm_readv,
    libc::SYS_process_vm_writev,
    libc::SYS_bpf,
    libc::SYS_perf_event_open,
    libc::SYS_userfaultfd,
    libc::SYS_keyctl,
    libc::SYS_add_key,
    libc::SYS_request_key,
    libc::SYS_open_by_handle_at,
    libc::SYS_mount,
    libc::SYS_umount2,
    libc::SYS_pivot_root,
    libc::SYS_setns,
    libc::SYS_unshare,
    libc::SYS_fsopen,
    libc::SYS_fsconfig,
    libc::SYS_fsmount,
    libc::SYS_open_tree,
    libc::SYS_move_mount,
    libc::SYS_mount_setattr,
    libc::SYS_io_uring_setup,
    libc::SYS_io_uring_enter,
    libc::SYS_io_uring_register,
  ] {
    filter.push(instruction(EQ, 0, 1, syscall as u32));
    filter.push(instruction(RET, 0, 0, ERRNO | libc::EPERM as u32));
  }
  // clone3's flags are behind a pointer. ENOSYS allows libc's ordinary thread /
  // process creation to fall back to clone, whose namespace flags we can inspect.
  filter.extend([
    instruction(EQ, 0, 1, libc::SYS_clone3 as u32),
    instruction(RET, 0, 0, ERRNO | libc::ENOSYS as u32),
    instruction(EQ, 0, 7, libc::SYS_socket as u32),
    instruction(LOAD, 0, 0, 16), // args[0], low 32 bits on supported targets
    instruction(EQ, 4, 0, libc::AF_UNIX as u32),
    instruction(EQ, 3, 0, libc::AF_INET as u32),
    instruction(EQ, 2, 0, libc::AF_INET6 as u32),
    instruction(EQ, 1, 0, libc::AF_NETLINK as u32),
    instruction(RET, 0, 0, ERRNO | libc::EAFNOSUPPORT as u32),
    instruction(RET, 0, 0, ALLOW),
    instruction(EQ, 0, 3, libc::SYS_clone as u32),
    instruction(LOAD, 0, 0, 16),
    instruction(
      BITS,
      0,
      1,
      (libc::CLONE_NEWUSER
        | libc::CLONE_NEWNS
        | libc::CLONE_NEWPID
        | libc::CLONE_NEWNET
        | libc::CLONE_NEWIPC
        | libc::CLONE_NEWUTS
        | libc::CLONE_NEWCGROUP) as u32,
    ),
    instruction(RET, 0, 0, ERRNO | libc::EPERM as u32),
    instruction(RET, 0, 0, ALLOW),
  ]);
  filter
}

#[cfg(test)]
mod tests {
  use super::*;

  fn decision(arch: u32, syscall: u32, arg: u32) -> u32 {
    let filter = worker_filter();
    let (mut pc, mut value) = (0, 0);
    loop {
      let op = filter[pc];
      match op.code {
        0x20 => {
          value = match op.k {
            0 => syscall,
            4 => arch,
            16 => arg,
            _ => panic!("invalid load"),
          }
        }
        0x15 => pc += if value == op.k { op.jt } else { op.jf } as usize,
        0x35 => pc += if value >= op.k { op.jt } else { op.jf } as usize,
        0x45 => pc += if value & op.k != 0 { op.jt } else { op.jf } as usize,
        0x06 => return op.k,
        _ => panic!("invalid instruction"),
      }
      pc += 1;
    }
  }

  #[test]
  fn rejects_unsupported_kernel_abis() {
    for abi in 0..9 {
      assert_eq!(
        require_abi(abi).unwrap_err().kind(),
        io::ErrorKind::Unsupported
      );
    }
    assert!(require_abi(9).is_ok());
  }

  #[test]
  fn syscall_filter_has_no_alternate_abi_or_namespace_path() {
    assert_eq!(
      decision(AUDIT_ARCH ^ 1, libc::SYS_read as u32, 0),
      KILL_PROCESS
    );
    assert_eq!(decision(AUDIT_ARCH, 0x4000_0000, 0), KILL_PROCESS);
    assert_eq!(
      decision(
        AUDIT_ARCH,
        libc::SYS_clone as u32,
        libc::CLONE_NEWUSER as u32
      ),
      ERRNO | libc::EPERM as u32
    );
    assert_eq!(
      decision(
        AUDIT_ARCH,
        libc::SYS_clone as u32,
        libc::CLONE_THREAD as u32
      ),
      ALLOW
    );
    assert_eq!(
      decision(AUDIT_ARCH, libc::SYS_clone3 as u32, 0),
      ERRNO | libc::ENOSYS as u32
    );
    for syscall in [
      libc::SYS_unshare,
      libc::SYS_setns,
      libc::SYS_bpf,
      libc::SYS_ptrace,
      libc::SYS_io_uring_setup,
    ] {
      assert_eq!(
        decision(AUDIT_ARCH, syscall as u32, 0),
        ERRNO | libc::EPERM as u32
      );
    }
    for syscall in [
      libc::SYS_read,
      libc::SYS_write,
      libc::SYS_execve,
      libc::SYS_futex,
    ] {
      assert_eq!(decision(AUDIT_ARCH, syscall as u32, 0), ALLOW);
    }
  }

  #[test]
  fn only_namespaced_or_landlock_controlled_socket_families_are_available() {
    for family in 0..64 {
      let expected = if [
        libc::AF_UNIX,
        libc::AF_INET,
        libc::AF_INET6,
        libc::AF_NETLINK,
      ]
      .contains(&family)
      {
        ALLOW
      } else {
        ERRNO | libc::EAFNOSUPPORT as u32
      };
      assert_eq!(
        decision(AUDIT_ARCH, libc::SYS_socket as u32, family as u32),
        expected
      );
    }
  }
}
