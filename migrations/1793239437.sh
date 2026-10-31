echo "Add firmware, RDMA and hardware diagnostics tools to GB10 desktops"

if omarchy-hw-aarch64-gb10; then
  omarchy-pkg-add rdma-core fwupd ethtool

  # ConnectX-7 devices enumerated before rdma-core was installed need its
  # module loader now; its udev rules handle every later boot.
  sudo systemctl start rdma-load-modules@rdma.service
fi
