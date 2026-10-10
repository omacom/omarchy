# Memory fix for the 128 GB NVIDIA N1x laptops: the ASUS ProArt P14 H7407BA and
# the Dell XPS 16 DX16263.
#
# The firmware reserves 62.5 GiB as EfiReservedMemoryType: the integrated GPU's
# dedicated memory under Windows. Linux's NVIDIA driver runs the GPU from system
# memory and never touches it, so the laptop boots with half its RAM, and the
# BIOS has no setting to shrink it. linux-omarchy-n1x's efi_reclaim_reserved=
# hands the idle part to the kernel: the 58 GiB from 8 GiB up. It leaves
# reserved the 48 MiB below it, the 32 KiB the firmware writes while training
# DRAM at 0x1080000000 (with the rest of its 128 MiB block), and the 4.4 GiB
# above that, where the GPU's firmware runs.
#
# The firmware's use of that top block grows downward with the displays it
# drives: 80 MiB with the XPS 16's own panel, 230 MiB once a 5120x2160@120
# monitor was added, and in one session with that monitor attached from boot
# it wrote display pixels about 190 MiB below the top 512 MiB, into memory the
# kernel had been given, and corrupted it. So the 3.9 GiB under the top 512
# MiB stay reserved as room for it.
#
# The ranges were measured on the ProArt's reservation and hold on the XPS 16
# (BIOS 1.2.0), whose firmware reserves the same block: only the same 48 MiB
# and top 512 MiB hold data, a pattern in the reclaimed ranges survived 18 GB of
# GPU work and suspend to idle, and with them reclaimed 90 GiB of RAM held a
# pattern through the same GPU work. Its firmware zeroes the block at boot and
# rewrites the whole 128 MiB training block. So only add the ranges when the
# firmware still reserves exactly that block. The kernel also ignores a range
# that is no longer all reserved memory, so a BIOS update that moves the
# reservation turns this off rather than handing out memory the GPU uses.

if { omarchy-hw-match "H7407BA" || omarchy-hw-match "DX16263"; } &&
  grep -qx '1fd000000-119fffffff : reserved' /proc/iomem; then
  mkdir -p /etc/limine-entry-tool.d
  cat > /etc/limine-entry-tool.d/omarchy-n1x-gpu-memory.conf <<'CONF'
# NVIDIA N1x: use the idle part of the firmware's Windows GPU memory as RAM; see
# install/hardware/fix-n1x-gpu-memory.sh.
KERNEL_CMDLINE[default]+=" efi_reclaim_reserved=58G@8G"
CONF
fi
