sudo tee /etc/sysctl.d/99-omarchy-lockdown.conf >/dev/null <<'EOF'
kernel.lockdown = 1
kernel.kexec_load_disabled = 1
kernel.perf_event_paranoid = 3
kernel.unprivileged_bpf_disabled = 1
net.core.bpf_jit_harden = 2
vm.mmap_rnd_bits = 32
vm.mmap_rnd_compat_bits = 16
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
EOF

sudo sysctl --system >/dev/null 2>&1

if pacman -Q linux-hardened &>/dev/null; then
    sudo tee /etc/kernel-lockdown.conf >/dev/null <<'EOF'
lockdown=confidentiality
EOF
fi
