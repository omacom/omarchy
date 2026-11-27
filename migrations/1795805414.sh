echo "Drop obsolete Dell XPS 13 DX13260 audio workarounds"

# Linux 7.2+ includes commit efd80de2de9d (snd_soc_sof_sdw sidecar amps quirk
# for 1028:0e53) and linux-firmware-cirrus >= 20260910-2 ships the nine
# 10280e54 Panther Lake speaker firmware aliases natively.
modules_dir="${OMARCHY_MODULES_DIR:-/usr/lib/modules}"
to_drop=()

if omarchy-pkg-present dell-xps13-sidecar-amps; then
  shopt -s nullglob
  pkgbases=("$modules_dir"/*/pkgbase)
  shopt -u nullglob

  if (( ${#pkgbases[@]} > 0 )); then
    all_kernels_supported=1
    for pkgbase in "${pkgbases[@]}"; do
      kver=$(basename "$(dirname "$pkgbase")")
      if [[ $kver == *-rc* ]] || (( $(vercmp "${kver%%-*}" "7.2") < 0 )); then
        all_kernels_supported=0
        break
      fi
    done

    if (( all_kernels_supported )); then
      to_drop+=(dell-xps13-sidecar-amps)
    fi
  fi
fi

if omarchy-pkg-present linux-firmware-cirrus-dx13260; then
  cirrus_pkg=$(pacman -Q linux-firmware-cirrus 2>/dev/null || true)
  if [[ -n $cirrus_pkg ]] && (( $(vercmp "${cirrus_pkg#* }" "20260910-2") >= 0 )); then
    to_drop+=(linux-firmware-cirrus-dx13260)
  fi
fi

if (( ${#to_drop[@]} > 0 )); then
  omarchy-pkg-drop "${to_drop[@]}"
fi
