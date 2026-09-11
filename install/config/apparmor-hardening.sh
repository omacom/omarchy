sudo mkdir -p /etc/apparmor.d

sudo tee /etc/apparmor.d/usr.sbin.sshd >/dev/null <<'EOF'
#include <tunables/global>

/usr/sbin/sshd {
  #include <abstractions/base>
  #include <abstractions/nameservice>

  capability dac_override,
  capability dac_read_search,
  capability setuid,
  capability setgid,
  capability net_bind_service,

  /etc/ssh/** r,
  /etc/ssh/sshd_config.d/** r,
  /var/log/* w,
  /var/run/sshd/ rw,
  /run/sshd/ rw,
  /proc/sys/net/ipv4/tcp_max_syn_backlog r,
  /proc/sys/net/core/somaxconn r,
  /dev/log w,
  /run/nscd.pid rw,
  /run/systemd/notify rw,

  deny /home/** w,
  deny /root/** w,
  deny /tmp/** rw,
  deny /var/tmp/** rw,
}
EOF

sudo tee /etc/apparmor.d/usr.sbin.sudo >/dev/null <<'EOF'
#include <tunables/global>

/usr/bin/sudo {
  #include <abstractions/base>

  capability setuid,
  capability setgid,

  /etc/sudoers r,
  /etc/sudoers.d/** r,
  /var/log/sudo/** rw,
  /dev/log w,

  deny /home/** w,
  deny /root/** w,
  deny /tmp/** rw,
}
EOF

sudo tee /etc/apparmor.d/usr.sbin.useradd >/dev/null <<'EOF'
#include <tunables/global>

/usr/sbin/useradd {
  #include <abstractions/base>

  /etc/passwd rw,
  /etc/shadow rw,
  /etc/group rw,
  /etc/gshadow rw,
  /etc/login.defs r,
  /etc/skel/** r,
  /home/** rw,
  /var/spool/mail/** rw,
}
EOF

sudo tee /etc/apparmor.d/usr.bin.curl >/dev/null <<'EOF'
#include <tunables/global>

/usr/bin/curl {
  #include <abstractions/base>
  #include <abstractions/ssl_certs>

  network inet stream,
  network inet6 stream,
  network unix stream,

  /etc/ssl/** r,
  /etc/ca-certificates/** r,
  /etc/resolv.conf r,
  /etc/hosts r,
  /dev/null rw,
  /dev/urandom r,
  /tmp/** rw,

  deny /etc/shadow r,
  deny /etc/gshadow r,
  deny /etc/sudoers r,
  deny /etc/ssh/sshd_config r,
}
EOF

sudo tee /etc/apparmor.d/usr.bin.wget >/dev/null <<'EOF'
#include <tunables/global>

/usr/bin/wget {
  #include <abstractions/base>
  #include <abstractions/ssl_certs>

  network inet stream,
  network inet6 stream,

  /etc/ssl/** r,
  /etc/ca-certificates/** r,
  /etc/resolv.conf r,
  /etc/hosts r,
  /dev/null rw,
  /dev/urandom r,
  /tmp/** rw,

  deny /etc/shadow r,
  deny /etc/gshadow r,
  deny /etc/sudoers r,
  deny /etc/ssh/sshd_config r,
}
EOF

if pacman -Q apparmor &>/dev/null; then
    sudo systemctl enable apparmor.service
    sudo aa-enforce /usr/sbin/sshd 2>/dev/null || true
    sudo aa-enforce /usr/bin/sudo 2>/dev/null || true
    sudo aa-enforce /usr/sbin/useradd 2>/dev/null || true
    sudo aa-enforce /usr/bin/curl 2>/dev/null || true
    sudo aa-enforce /usr/bin/wget 2>/dev/null || true
fi
