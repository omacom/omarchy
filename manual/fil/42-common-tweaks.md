# Mga karaniwang pag-aayos

Ito ay isang koleksyon ng mga karaniwang pag-aangkop sa setup ng Omarchy. Alamin na paminsan-minsan ay maaaring kailanganin ng mga update ng system na ibalik ang ilang config sa orihinal nilang kalagayan. Kung mangyari ito, hindi mawawala ang mga pagbabago mo, ngunit ilalagay ang mga ito sa isang `.bak.<timestamp>` file katabi ng orihinal.

Kung may masira ka, maaari mong ibalik ang mga indibidwal na config sa orihinal nilang setup sa pamamagitan ng _Update > Config_ sa menu ng Omarchy. Kung _talaga_ mong nasira ang lahat, maaari mong i-reset ang lahat ng config sa pamamagitan ng `omarchy reinstall configs`, o muling i-install ang bawat default na package at config gamit ang `omarchy reinstall`.

### Ipakita ang lahat ng tray icon sa lahat ng oras

Bilang default, ang mga tray icon, tulad ng Dropbox, 1password, o Steam, ay nakatago sa likod ng tray expander arrow, na nagpapakita sa mga ito kapag itinapat mo ang cursor dito. Kung gusto mong nakalantad ang mga ito sa lahat ng oras, i-right-click ang expander arrow upang buksan ang tray icon manager, pagkatapos ay i-pin ang mga icon na gusto mong manatiling nakikita (maaari mo ring itago ang mga ayaw mong makita kailanman).

### Mga bilugang sulok ng window

Ang default na disenyo ng Omarchy ay may mga parisukat na sulok, ngunit kung gusto mong palambutin iyon nang kaunti, piliin ang _Appearance > Windows > Window Corners > Rounded Corners_ sa menu ng Omarchy, o patakbuhin ang `omarchy hyprland corners rounded`. Ibinabalik ka ng _Theme Corners_ sa anumang ginagamit ng theme. Upang pumili ng sarili mong radius, manatili sa _Theme Corners_ (`omarchy hyprland corners theme`), dahil naglo-load ang Rounded at Sharp pagkatapos ng config mo at ino-override ito, at alisin ang comment sa rounding sa `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Alisin ang mga puwang sa window

Sa mga display ng laptop, mas gusto ng ilang tao na hindi magsayang ng anumang pixel sa mga puwang sa window (o kahit sa top bar, na maaari mong i-off gamit ang `Super + Shift + Space`). Maaari mong i-off ang lahat ng puwang at border gamit ang `Super + Shift + Backspace`, o permanenteng alisin ang mga ito sa pamamagitan ng pag-aalis ng mga comment sa bahaging ito ng `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
