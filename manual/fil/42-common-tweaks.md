# Mga karaniwang tweak

Ito ay isang koleksyon ng mga karaniwang pagsasaayos sa setup ng Omarchy. Alamin na kung minsan ay maaaring kailanganin ng mga update ng sistema na ibalik ang ilang config sa kanilang orihinal na kondisyon. Kung mangyari ito, hindi mawawala ang mga pagbabago mo, kundi ilalagay ang mga ito sa isang file na `.bak` sa parehong direktoryo.

Kung may masira ka, maaari mong ibalik ang mga indibidwal na config sa kanilang orihinal na setup sa pamamagitan ng _I-update > Konfig_ sa menu ng Omarchy. Kung _talagang_ masira mo ang lahat, maaari mong i-reset ang lahat ng config sa pamamagitan ng `omarchy-reinstall`.

### Ilantad ang lahat ng icon sa tray sa lahat ng oras

Bilang default, ang mga icon sa tray, tulad ng Dropbox, 1password, o Steam, ay nakatago sa likod ng arrow ng tray expander, na naglalantad sa kanila kapag ini-hover mo ito. Kung gusto mong nakalantad ang mga ito sa lahat ng oras, i-right-click ang arrow ng expander para buksan ang tagapamahala ng icon sa tray, pagkatapos ay i-pin ang mga icon na gusto mong manatiling nakikita (maaari mo ring itago ang mga icon na ayaw mong makita kailanman).

### Mga bilugan na sulok ng bintana

Ang default na disenyo ng Omarchy ay mga parisukat na sulok, pero kung gusto mong palambutin iyon nang kaunti, maaari mong baguhin ang `~/.config/hypr/looknfeel.lua` para hindi na naka-comment out ang rounding:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Alisin ang mga agwat ng bintana

Sa mga display ng laptop, mas gusto ng ilang tao na huwag magsayang ng anumang pixel sa mga agwat ng bintana (o maging sa bar sa itaas, na maaari mong i-toggle off gamit ang `Super + Shift + Space`). Maaari mong i-toggle off ang lahat ng agwat at hangganan gamit ang `Super + Shift + Backspace`, o alisin ang mga ito nang permanente sa pamamagitan ng pag-aalis ng mga komento sa seksyong ito ng `~/.config/hypr/looknfeel.lua`:

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
