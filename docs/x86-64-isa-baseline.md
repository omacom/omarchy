# x86-64 ISA baseline

Omarchy supports 64-bit x86 CPUs at the x86-64-v2 microarchitecture level and above, meaning SSE4.2 and POPCNT. The level does not include AVX2 or AVX-512, so a CPU without those flags is a supported machine. Shipped binaries must run on every v2 machine, so build at or below the floor by default and never with `-march=native` or the toolchain equivalent (`-C target-cpu=native`, `-mcpu=native`): a build that assumes AVX2 or AVX-512 by default breaks it (SIGILL), and only an explicit, gated variant may use the higher level.

The end-user side of this is the Hardware requirements section of the manual (`manual/02-getting-started.md`): the floor, the flag check a user runs before installing a prebuilt package, and the third-party builds known to break it. This page is the contract for anyone packaging or gating software above the floor.

## Packages built above the floor

A package that needs AVX2 (the v3 level) or AVX-512 (v4) must do one of two things:

- Ship a baseline build for x86-64-v2 as the default, and select an AVX2 or AVX-512 variant only when the CPU carries every flag the variant is built for. Gate on every flag the build needs. A build targeting x86-64-v4 needs the whole v2 and v3 sets plus `avx512f`, `avx512dq`, `avx512cd`, `avx512bw` and `avx512vl`; a build using individual AVX-512 extensions may have different requirements. `omarchy-cpu-isa --atleast v3` / `--atleast v4` checks the whole level; it ships with the `omarchy-cpu-isa` change (#20010), and until it is installed, check the flags yourself as the manual's Hardware requirements section shows. Knights Landing has `avx512f` and `avx512cd` (plus `avx512er`/`avx512pf`) but no `avx512dq`/`avx512bw`/`avx512vl`, so it crashes on a v4 binary. `voxtype-bin` is the shape of the pattern (baseline default, `voxtype-avx2` and `voxtype-avx512` selected from cpuinfo flags) but its probes still check single flags (`avx2`, `avx512f`), so compare those probes with each variant's actual build requirements before using this pattern.
- Mark the package as requiring the higher level and skip or warn on machines that cannot run it.

An ungated build that assumes AVX2 breaks the floor: the binary dies with SIGILL at first use on a v2 machine, so the gate belongs at install time, not first use.
