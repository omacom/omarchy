# Lenovo IdeaPad Slim 5x 14Q8X9 (83HL, Snapdragon X Plus X1P-42-100) board
# setup: the LCD and OLED models.

uki_config=${OMARCHY_IDEAPAD_SLIM5X_UKI_CONFIG:-/etc/kernel/uki.conf}
drm_root=${OMARCHY_IDEAPAD_SLIM5X_DRM_ROOT:-/sys/class/drm}
dtb_root=${OMARCHY_QUALCOMM_DTB_ROOT:-/boot/dtbs}

# The models share their SMBIOS identity, and systemd's hardware IDs for it
# came from an OLED unit, so systemd-stub boots the OLED tree on both. The LCD
# tree adds the panel's PWM backlight; on the OLED tree the LCD model's
# brightness never changes. Both trees drive the panel as a generic eDP one,
# which reads its EDID, so the panel tells the models apart: its manufacturer
# and product code, EDID bytes 8 to 11. An unknown panel keeps the OLED tree.
# - 0dae7614: CMN N140JCE-EL1, 1920x1200 LCD
if omarchy-hw-aarch64-qualcomm &&
  omarchy-hw-match-device-tree lenovo,ideapad-slim5x-oled lenovo,ideapad-slim5x-lcd; then
  echo "Detected Lenovo IdeaPad Slim 5x, applying board-specific support..."

  ideapad_slim5x_lcd=0
  # sysfs gives the EDID a size of 0, so a read tells whether it holds one.
  for edid in "$drm_root"/card*-eDP-*/edid; do
    if [[ -r $edid ]]; then
      case $(od -An -v -tx1 -j8 -N4 "$edid" | tr -d ' \n') in
        0dae7614) ideapad_slim5x_lcd=1 ;;
      esac
    fi
  done

  if (( ideapad_slim5x_lcd )); then
    # Embed the LCD tree instead of the list dtb-uki.sh writes, found the way
    # dtb-uki.sh finds it; without it the list stays and an earlier pin goes.
    ideapad_slim5x_dtb=""
    for dtb in "$dtb_root"/linux-omarchy/qcom/x1p42100-lenovo-ideapad-slim5x-lcd.dtb \
      "$dtb_root"/linux-omarchy*/qcom/x1p42100-lenovo-ideapad-slim5x-lcd.dtb; do
      if [[ -f $dtb ]]; then
        ideapad_slim5x_dtb=$dtb
        break
      fi
    done

    if [[ -n $ideapad_slim5x_dtb || -f $uki_config ]]; then
      mkdir -p "$(dirname "$uki_config")"
      uki_tmp=$(mktemp "${uki_config}.XXXXXX")

      if [[ -f $uki_config ]]; then
        cp -p "$uki_config" "$uki_tmp"
        awk -v pinned="${ideapad_slim5x_dtb:+1}" '
          $0 == "# BEGIN OMARCHY IDEAPAD SLIM 5X DEVICE TREE" || (pinned && $0 == "# BEGIN OMARCHY QUALCOMM DEVICE TREES") { managed = 1; next }
          managed && ($0 == "# END OMARCHY IDEAPAD SLIM 5X DEVICE TREE" || $0 == "# END OMARCHY QUALCOMM DEVICE TREES") { managed = 0; next }
          !managed { print }
        ' "$uki_config" >"$uki_tmp"
      else
        chmod 0644 "$uki_tmp"
      fi

      if [[ -n $ideapad_slim5x_dtb ]]; then
        {
          echo "# BEGIN OMARCHY IDEAPAD SLIM 5X DEVICE TREE"
          echo "[UKI]"
          echo "DeviceTree=$ideapad_slim5x_dtb"
          echo "# END OMARCHY IDEAPAD SLIM 5X DEVICE TREE"
        } >>"$uki_tmp"
      fi

      if [[ -f $uki_config ]] && cmp -s "$uki_tmp" "$uki_config"; then
        rm -f "$uki_tmp"
      else
        mv -f "$uki_tmp" "$uki_config"
        # As in dtb-uki.sh: an image's first boot rebuilds after its last step,
        # but does not watch this file.
        if [[ -n ${OMARCHY_IMAGE_BOOT_REBUILD:-} ]]; then
          : >"$OMARCHY_IMAGE_BOOT_REBUILD"
        fi
      fi
    fi
  fi
fi
