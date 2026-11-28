# NVIDIA's 615 driver keeps the GPU memory a process frees in its own page
# pools, to hand it out faster next time, and returns it only under memory
# pressure. On GB10 the GPU's memory is the machine's RAM, so a stopped local
# model left 100+ GiB in the pools (KReclaimable in /proc/meminfo) until
# something squeezed it out. DGX OS's 580 driver has no pools and returns the
# memory as soon as the model stops; match that.
modprobe_dir=${OMARCHY_MODPROBE_DIR:-/etc/modprobe.d}

if omarchy-hw-aarch64-gb10; then
  mkdir -p "$modprobe_dir"
  cat >"$modprobe_dir/omarchy-gb10-nvidia-memory-pools.conf" <<'CONF'
# GB10: return freed GPU memory to the system at once instead of pooling it in
# the driver; see install/hardware/gb10/nvidia-memory-pools.sh.
options nvidia NVreg_EnableSystemMemoryPools=0
CONF
fi
