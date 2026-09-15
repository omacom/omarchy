//! Private host/controller transport, never the worker's Wayland socket.
//! Each receive handles one bounded record; event loops must also bound their
//! per-tick work and treat invalid data as terminal. No internal message queue.
use rustix::net::{self, AddressFamily, SocketFlags, SocketType};
use std::{
  io::{self, IoSlice, IoSliceMut},
  mem::MaybeUninit,
  os::{
    fd::{AsFd, BorrowedFd, OwnedFd},
    unix::fs::MetadataExt,
  },
  path::Path,
};

pub const MAX_BYTES: usize = 4096;
pub const MAX_FDS: usize = 4;
const FLAGS: SocketFlags = SocketFlags::NONBLOCK.union(SocketFlags::CLOEXEC);

#[derive(Debug)]
pub struct Packet {
  pub bytes: Vec<u8>,
  pub fds: Vec<OwnedFd>,
}

#[derive(Debug)]
pub struct Channel(OwnedFd);
pub struct Listener(OwnedFd);

impl AsFd for Channel {
  fn as_fd(&self) -> BorrowedFd<'_> {
    self.0.as_fd()
  }
}

impl Listener {
  /// The caller owns the private directory and its lifetime; never unlink or
  /// replace a pre-existing socket here. Admission still requires peer checking.
  pub fn bind(path: &Path) -> io::Result<Self> {
    let parent = path
      .parent()
      .ok_or_else(|| invalid("missing socket directory"))?;
    let metadata = parent.metadata()?;
    if !path.is_absolute()
      || !metadata.is_dir()
      || metadata.mode() & 0o077 != 0
      || metadata.uid() != unsafe { libc::geteuid() }
    {
      return Err(invalid("host socket requires an owned private directory"));
    }
    let fd = socket()?;
    net::bind(&fd, &net::SocketAddrUnix::new(path)?)?;
    net::listen(&fd, 1)?;
    Ok(Self(fd))
  }

  pub fn accept(&self) -> io::Result<Channel> {
    Channel::new(net::accept_with(&self.0, FLAGS)?)
  }
}

impl Channel {
  fn new(fd: OwnedFd) -> io::Result<Self> {
    net::sockopt::set_socket_send_buffer_size(&fd, 16 * 1024)?;
    Ok(Self(fd))
  }

  pub fn connect(path: &Path) -> io::Result<Self> {
    let fd = socket()?;
    // A full Unix listen queue returns EAGAIN with NONBLOCK; no blocking retry.
    net::connect(&fd, &net::SocketAddrUnix::new(path)?)?;
    Self::new(fd)
  }

  pub fn pair() -> io::Result<(Self, Self)> {
    let (a, b) = net::socketpair(AddressFamily::UNIX, SocketType::SEQPACKET, FLAGS, None)?;
    Ok((Self::new(a)?, Self::new(b)?))
  }

  pub fn send(&self, bytes: &[u8], fds: &[BorrowedFd<'_>]) -> io::Result<()> {
    if bytes.is_empty() || bytes.len() > MAX_BYTES || fds.len() > MAX_FDS {
      return Err(invalid("host packet exceeds limits"));
    }
    let mut space = [MaybeUninit::uninit(); rustix::cmsg_space!(ScmRights(MAX_FDS))];
    let mut control = net::SendAncillaryBuffer::new(&mut space);
    if !fds.is_empty() && !control.push(net::SendAncillaryMessage::ScmRights(fds)) {
      return Err(invalid("ancillary buffer overflow"));
    }
    let sent = net::sendmsg(
      self,
      &[IoSlice::new(bytes)],
      &mut control,
      net::SendFlags::NOSIGNAL,
    )?;
    if sent != bytes.len() {
      return Err(io::Error::other("partial host record"));
    }
    Ok(())
  }

  pub fn receive(&self) -> io::Result<Packet> {
    let mut bytes = [0u8; MAX_BYTES];
    let mut space = [MaybeUninit::uninit(); rustix::cmsg_space!(ScmRights(MAX_FDS))];
    let mut control = net::RecvAncillaryBuffer::new(&mut space);
    let message = net::recvmsg(
      self,
      &mut [IoSliceMut::new(&mut bytes)],
      &mut control,
      net::RecvFlags::CMSG_CLOEXEC,
    )?;
    // RecvAncillaryBuffer owns (and closes on Drop) all unconsumed descriptors,
    // including when rejecting a truncated/oversized packet below.
    if message
      .flags
      .intersects(net::ReturnFlags::TRUNC | net::ReturnFlags::CTRUNC)
    {
      return Err(invalid("truncated host packet"));
    }
    if message.bytes == 0 {
      return Err(io::Error::new(
        io::ErrorKind::UnexpectedEof,
        "host connection closed",
      ));
    }
    let mut fds = Vec::with_capacity(MAX_FDS);
    for message in control.drain() {
      match message {
        net::RecvAncillaryMessage::ScmRights(rights) => fds.extend(rights),
        _ => return Err(invalid("unexpected host ancillary data")),
      }
    }
    if fds.len() > MAX_FDS {
      return Err(invalid("too many host descriptors"));
    }
    Ok(Packet {
      bytes: bytes[..message.bytes].to_vec(),
      fds,
    })
  }
}

fn socket() -> io::Result<OwnedFd> {
  Ok(net::socket_with(
    AddressFamily::UNIX,
    SocketType::SEQPACKET,
    FLAGS,
    None,
  )?)
}

fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::{fs, os::fd::AsRawFd};

  #[test]
  fn records_are_bounded_nonblocking_and_close_descriptors_on_errors() {
    let (a, b) = Channel::pair().unwrap();
    assert_eq!(b.receive().unwrap_err().kind(), io::ErrorKind::WouldBlock);
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("transferred");
    let file = fs::File::create(&path).unwrap();
    let count = || {
      fs::read_dir("/proc/self/fd")
        .unwrap()
        .filter(|entry| {
          fs::read_link(entry.as_ref().unwrap().path()).is_ok_and(|target| target == path)
        })
        .count()
    };
    let initial = count();
    a.send(b"record", &[file.as_fd()]).unwrap();
    let packet = b.receive().unwrap();
    assert_eq!(packet.bytes, b"record");
    assert_eq!(packet.fds.len(), 1);
    assert_ne!(
      unsafe { libc::fcntl(packet.fds[0].as_raw_fd(), libc::F_GETFD) } & libc::FD_CLOEXEC,
      0
    );
    drop(packet);
    assert_eq!(count(), initial);
    assert!(a.send(&[], &[]).is_err());
    assert!(a.send(&[0; MAX_BYTES + 1], &[]).is_err());
    assert!(a.send(b"x", &[file.as_fd(); MAX_FDS + 1]).is_err());
    for (bytes, descriptors) in [(MAX_BYTES + 1, 1), (1, MAX_FDS + 1)] {
      let mut space = [MaybeUninit::uninit(); rustix::cmsg_space!(ScmRights(MAX_FDS + 1))];
      let mut control = net::SendAncillaryBuffer::new(&mut space);
      let fds = vec![file.as_fd(); descriptors];
      assert!(control.push(net::SendAncillaryMessage::ScmRights(&fds)));
      net::sendmsg(
        &a,
        &[IoSlice::new(&vec![0; bytes])],
        &mut control,
        net::SendFlags::NOSIGNAL,
      )
      .unwrap();
      assert_eq!(b.receive().unwrap_err().kind(), io::ErrorKind::InvalidData);
      assert_eq!(count(), initial, "rejected record leaked descriptors");
    }
    for number in 0..128 {
      match a.send(&[0; MAX_BYTES], &[]) {
        Ok(()) => assert!(number < 127, "send queue is not bounded"),
        Err(error) => {
          assert_eq!(error.kind(), io::ErrorKind::WouldBlock);
          break;
        }
      }
    }
    drop(b);
    assert!(a.send(b"closed", &[]).is_err());
    let (a, b) = Channel::pair().unwrap();
    drop(a);
    assert_eq!(
      b.receive().unwrap_err().kind(),
      io::ErrorKind::UnexpectedEof
    );
  }
}
