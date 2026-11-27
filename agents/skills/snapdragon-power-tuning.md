# Snapdragon Power and Sleep Tuning

Read this before tuning active/idle wattage or deep sleep (`s2idle` / `deep`) on any Qualcomm Snapdragon laptop (`aarch64-qualcomm`: X1 Hamoa/Purwa and X2 Glymur/Mahua/Kalambo).

## Where Changes Live

Tuning work splits cleanly across `omacom/omarchy-pkgs` and `omacom/omarchy`:

- **`omacom/omarchy-pkgs`**: device-tree patches in `pkgbuilds/linux-omarchy-dtbs/` (for `switch-lid`, idle states, PHY clocks) and board support packages in `pkgbuilds/<board>-support/` when a board needs a `systemd-sleep` hook and unit tests (`test.sh`). Every package PR must bump `pkgver`/`pkgrel`, keep `b2sums`/`sha256sums` aligned, and apply DTB patches with `patch --fuzz=0`.
- **`omacom/omarchy`**: kernel cmdline knobs (`omarchy-boot-cmdline set` + `omarchy-boot-rebuild`), NetworkManager Wi-Fi power-save overrides, DMI-guarded udev rules (when no `-support` package exists), `/etc/systemd/sleep.conf.d/` drop-ins, and `migrations/`. Register every new hardware script in both `install/hardware/all.sh` and `install/helpers/logging.sh` under `aarch64-qualcomm`.

## Baseline Inventory and Measurement Rules

Gather a complete hardware snapshot before changing any setting:

- **Identity**: `/sys/class/dmi/id/{sys_vendor,product_name,product_family,board_name}` and `/sys/firmware/devicetree/base/compatible`.
- **Sleep & power baseline**: `/sys/power/mem_sleep`, `/sys/class/power_supply/qcom-battmgr-bat/{status,power_now,energy_now,capacity}`, `/sys/kernel/debug/qcom_stats/{apss,cxsd,aosd,ddr,adsp,cdsp}`, `/sys/kernel/debug/pm_genpd/pm_genpd_summary`, and `/sys/kernel/debug/clk/clk_summary`.
- **Radios & panel**: `iw dev <iface> get power_save`, `iw dev <iface> link`, and eDP DPCD register `0x0070` on `/dev/drm_dp_aux*` (`dd if=/dev/drm_dp_auxN bs=1 skip=112 count=1 2>/dev/null | od -An -tx1`).
- **Wait for `qcom_battmgr` to settle.** `power_now` averages over ~15–30 s. After toggling any power knob, wait 25–45 s on a static desktop before recording settled wattage, and compare A/B back to back at fixed display brightness.
- **Measure real sleep drain properly.** `qcom_stats` ticks run at 19.2 MHz (`duration_s = delta_ticks / 19200000`). Measure battery drain from `energy_now` across at least 2–5 minutes of sleep (short sleeps are skewed by open-circuit voltage recovery).
- **Use `pm_test=platform` before real sleeps.** Snapdragon `rtc_pm8xxx` has no RTC wakeup (`/sys/class/rtc/rtc0/device/power/wakeup` is absent), so real sleeps require a manual keypress or lid open. Dry-run suspend/resume callbacks non-interactively with `echo platform >/sys/power/pm_test && echo <freeze|mem> >/sys/power/state && echo none >/sys/power/pm_test` (~5 s) to catch driver hangs or NOC resets before asking a human to wake the laptop. Remember `pm_test=platform` stops before PSCI entry and will never increment `qcom_stats`.
- **Beware asynchronous `systemctl suspend`.** When running sleep tests over SSH, `systemctl suspend` can return before `systemd-sleep` enters the kernel. Never place post-wake restore commands immediately after `systemctl suspend` in a test wrapper; use synchronous `echo mem >/sys/power/state` for raw kernel tests or inspect `journalctl -b -u systemd-suspend.service` after wake.

## Active and Idle Power Checklist

Test each lever independently, measure settled wattage and latency, and ship only what yields a clear win without regressions:

### 1. Display Panel Self Refresh (`msm.psr_enabled=1`)

- Probe DPCD `0x0070` on the panel's `/dev/drm_dp_aux*` device before touching the cmdline:
  - `0x00` means the panel lacks hardware PSR (e.g., Zenbook 14 `ATNA40KW01-0`) — do not set `msm.psr_enabled=1`.
  - Non-zero (`0x01`–`0x04`, e.g., Anduril BlueChip `ATNA40HQ08-0` reports `0x04` PSR2+ET) means hardware PSR is supported.
- Boot with `msm.psr_enabled=1`, verify `ae01000.display-controller` enters `runtime_status=suspended` on a static screen, check for flicker/stutter, and measure settled idle savings (saved ~2.1 W on Anduril BlueChip: 5.77 W -> 3.66 W).
- Ship via `omarchy-boot-cmdline set <board> msm.psr_enabled=1` (and `omarchy-boot-rebuild` in the migration). Never edit Limine files directly.

### 2. Wi-Fi Power Save (`wifi.powersave = 3`)

- Omarchy disables Wi-Fi power save globally in `omarchy-wifi-powersave.conf`. Measure both settled idle wattage (wait 40–50 s) and idle-link ping latency with `iw dev <iface> set power_save on` vs `off`.
- **Never enable blindly** — savings depend heavily on chip and firmware:
  - `QCC2072` (`ath12k_wifi7_pci`, Zenbook A16, 6 GHz 160 MHz): **-0.73 W**, 3.6–5.3 ms ping — enable.
  - `WCN6855` (`ath11k_pci`, Zenbook 14, 6 GHz 160 MHz): **-0.45 to -0.48 W** (2.37 W -> 1.92 W), 4.9–14.1 ms ping — enable.
  - `WCN7850` (`ath12k`, Anduril BlueChip, 6 GHz 160 MHz): only **~0.07 W** (5.33 W -> 5.26 W) — skip.
- Ship via `/etc/NetworkManager/conf.d/zz-<board>-wifi-powersave.conf` with `[connection]` and `wifi.powersave = 3`.
- In migrations, reload NetworkManager (`nmcli general reload conf`) and apply live `iw dev "$iface" set power_save on` only after looking up the active profile by **`GENERAL.CON-UUID`** (`nmcli -g 802-11-wireless.powersave con show uuid "$uuid"`). Never look up by `GENERAL.CONNECTION` display name (`nmcli -g` escapes characters like `:`), and skip the live toggle if reading the profile fails or if the profile explicitly sets `1` (ignore) or `2` (disable). Follow `migrations/1795775500.sh`.

### 3. USB Controllers, xHCI, and QMP PHYs Runtime PM

- The kernel defaults `dwc3-qcom`, `xhci-hcd`, `qcom-qmp-combo-phy`, and `qcom-qmp-usb-phy` to `power/control=on`, pinning 4–6 USB/PHY GDSCs (`gcc_usb20_prim_gdsc`, `gcc_usb30_*_gdsc`, `gcc_usb3_mp_ss*_phy_gdsc`) on at idle and holding CX at nominal.
- Add a positively DMI-guarded udev rule (`ATTR{[dmi/id]sys_vendor}==...`, `ATTR{[dmi/id]board_name}==...` with `GOTO`/`LABEL` so machines without DMI or with another board skip all rules) matching `ACTION=="add|bind|change"` and setting `ATTR{power/control}="auto"` on all four drivers (plus `ATTR{power/autosuspend_delay_ms}="200"` on `dwc3-qcom`).
- Verify in `pm_genpd_summary` that unused USB/PHY GDSCs transition to `off-0`. If a controller stays `active`, inspect its USB children (`/sys/bus/usb/devices/*`): e.g., an internal Realtek SD card reader (`0bda:0329` on Zenbook A16) needs USB/SCSI autosuspend plus `events_poll_msecs=15000`.
- When a hardware setup script writes udev rules directly under `install/hardware/`, reload and trigger matching platform devices (`udevadm control --reload` + `udevadm trigger --action=change`) inside the script whenever `[[ $udev_rules_dir == "/etc/udev/rules.d" && -d /run/udev ]]` so first-boot sessions activate the rules immediately without requiring a second reboot.

### 4. Other Idle Consumers

- Inspect `pm_genpd_summary` and `clk_summary` for active clocks or power domains on idle peripherals: SoundWire/LPASS audio codecs (`*.soundwire`, `*.codec`), cameras, and `devfreq` (`ddr`, `ddr-qos`, `llcc` polling storms on kernels before `7.3.6-6`).

## Deep Sleep Diagnosis (`Glymur` vs `X1 Hamoa/Purwa`)

Target **99%+ residency** across `qcom_stats/{apss,cxsd,aosd,ddr}` (`Count: 1` for an unbroken sleep, ~0.2–0.3 W drain), zero spurious open-lid wakes, and clean resume of Wi-Fi, Bluetooth, audio, webcam, display, and keyboard backlight.

### Choose the Right Sleep Mode

- **Glymur (Snapdragon X2 — Zenbook A16, Anduril BlueChip, Surface Laptop 8)**: only `[s2idle]` is exposed (`MemorySleepMode=s2idle`). Full collapse requires:
  - `cluster_cl5` kept attached with `min-residency-us = <1000000000>` (already fixed SoC-wide in `linux-omarchy-dtbs` patch `0072` so runtime `Usage=0` avoids `#19916` hard freezes while `s2idle` enters `cluster_cl5` + `domain_ss3` cleanly instead of spinning on `PSCI_RET_DENIED`).
  - A board-guarded `systemd-sleep` hook (`<board>-sleep` in `omarchy-pkgs`) that drops `bi_tcxo` blockers before sleep and restores exact prior state on resume: soft-block only currently unblocked Bluetooth `rfkill` adapters (track per-adapter IDs so pre-blocked adapters stay blocked), disable `a{2,4,6,8}00000.usb` `power/wakeup`, and if WSA SoundWire controllers hold `mclk`/`wsa2-mclk` active, switch their `power/control` to `auto` across sleep and restore afterward.
  - A udev rule disabling `power/wakeup` on both the PCIe4 Wi-Fi root port (`0004:00:00.0`) and endpoint (`0004:01:00.0`) so `dw_pcie_suspend_noirq()` power-cycles `WL_EN` via `pci_pwrctrl` across CX collapse (otherwise `skip_pwrctrl_off=true` leaves `ath12k` unable to start MHI on resume, `-110`).
- **Hamoa / Purwa (Snapdragon X1 — Zenbook 14 `UX3480QAB`, Surface Pro 11, Yoga Slim 7x, Galaxy Book4 Edge)**: `/sys/power/mem_sleep` exposes `s2idle [deep]`.
  - Check whether `s2idle` actually increments `apss`/`cxsd`/`aosd`/`ddr`. On `X1-26-100` Purwa (`UX3480QAB`), `s2idle` leaves all four at `0` (~0.94 W drain) even when all CPUs enter `s2idle`, whereas **`MemorySleepMode=deep` (`PSCI SYSTEM_SUSPEND`)** hits **99.99% APSS / CXSD / AOSD / DDR** with no Bluetooth `rfkill` hook, no PCIe wakeup hack, and no `hamoa.dtsi` `cluster_cl5` change (preserving kernel patch `2151`'s DC ZVA mitigation).
  - **Purwa (`x1p42100`) USB wakeup reset trap**: never disable `power/wakeup` on external USB3 `dwc3-qcom` controllers (`a400000.usb`, `a600000.usb`, `a800000.usb`) — doing so hard-resets Purwa in `suspend_noirq` (catchable via `pm_test=platform`). Disabling wakeup only on the internal USB2 webcam controller (`a200000.usb`, `PDC 50 dp_hs_phy_irq`) is safe and stops spurious wakes at ~5 minutes.
  - **ADSP power-limits timer**: verify `qcom_adsp_pwr_lmts` is bound to `APPS_ADSP_PWR_LMTS_GLINK_PORT` under `/sys/bus/rpmsg/drivers/qcom_adsp_pwr_lmts/`; without it the ADSP wakes ~100 times/sec during sleep.
  - **AOSD board quirks**: some X1 boards (e.g., Galaxy Book4 Edge 14 with UFS) lose storage on AOSD resume or power-cycle after 61 minutes; `qcom_aoss.prevent_aoss_sleep=1` keeps CXSD + DDR active while blocking AOSD. Only enable it when a board reproduces that failure.

### Fix Spurious Open-Lid Wakes (`switch-lid`)

- Check `/sys/firmware/devicetree/base/gpio-keys/switch-lid/wakeup-event-action`. Inherited `wakeup-event-action = <EV_ACT_DEASSERTED>` arms TLMM GPIO 92 for the rising edge only, causing lid hall-sensor glitches on CX collapse exit to wake open-lid suspend immediately.
- Add a patch in `omarchy-pkgs/pkgbuilds/linux-omarchy-dtbs/` deleting `wakeup-event-action` from `gpio-keys/switch-lid` in the board's `.dts` (see `0075`, `0076`, `0077`). Keeping `wakeup-source;` preserves lid-open wake from closed-lid sleep while open-lid suspend stays asleep.

### Isolate Remaining Blockers

- **Spurious wake**: read `/sys/power/pm_wakeup_irq` after resume and map it in `/proc/interrupts` (and `/proc/device-tree/soc@0/usb@*/interrupts-extended` for PDC IRQ numbers).
- **CX/XO collapse blocked**: read active consumers under `bi_tcxo` in `/sys/kernel/debug/clk/clk_summary` and non-`off-0` domains in `/sys/kernel/debug/pm_genpd/pm_genpd_summary`.

## Safe Rollout, Gating, and Tests

- **Gate both the setup leaf and the migration on DTB readiness.** Never switch a board to a sleep mode that depends on a new `linux-omarchy-dtbs` patch until BOTH the package version (`vercmp`) AND the running live device tree under `/sys/firmware/devicetree/base/` confirm the fix is active (e.g., `[[ -d $dt_root/gpio-keys/switch-lid && ! -e $dt_root/gpio-keys/switch-lid/wakeup-event-action ]]`). In the migration, call `omarchy-state set reboot-required` and `exit 75` until rebooted onto the new tree; in the `install/hardware/` leaf, fall back to the safe setting until both checks pass (so `omarchy-apply-hardware` before reboot cannot bypass the migration gate).
- **Use quoted heredocs for privileged writes.** Every heredoc writing under `/etc` or `/usr` in `install/hardware/` must quote its delimiter (`<<'CONF'`, `<<'RULES'`). `test/shell.d/privileged-heredoc-test.sh` rejects unquoted heredocs in privileged install scripts.
- **Verify before opening PRs.** Follow [`docs/testing.md`](../../docs/testing.md) (migrations get no suite test). Run `bash -n`, `test/shell.d/privileged-heredoc-test.sh`, `test/shell.d/hw-platform-test.sh`, `test/shell.d/platform-setup-test.sh`, and `test/shell.d/qualcomm-device-trees-test.sh` locally in `omarchy`, and test `makepkg -f` plus package `test.sh` in `omarchy-pkgs`. Always verify post-reboot defaults and a live multi-minute suspend/resume cycle on the target laptop before shipping.
