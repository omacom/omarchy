# Pagkuha ng Teksto at Diktasyon

### Pagkuha ng Teksto

Pindutin ang `Super + Ctrl + PrtScr` upang pumili ng rehiyon sa screen para sa pagkuha ng teksto. Mabilis na gagawing teksto ng open source na OCR model na tesseract ang pinili mong iyon at ilalagay ito sa clipboard. Pagkatapos ay pindutin mo na lang ang `Super + V` upang i-paste.

Napakakatulong nito para kumuha ng mga address mula sa mga footer ng larawan o mga numero ng telepono na naka-embed sa mga headline ng website.

 ![text-extraction](images/text-extraction.webp)

### Diktasyon

Sa mga bagong install, ang [Superwhisper](https://superwhisper.com/) ang default na backend para sa diktasyon, na gumagamit ng cloud processing nang walang pag-download ng offline na modelo. Piliin ang Superwhisper, [Voxtype](https://voxtype.io/), o [Hex](https://anoma.ly/hex/) sa pamamagitan ng _Setup > Mga Default > Diktasyon_ sa menu ng Omarchy. Ang pagpili ng backend ay mag-i-install nito kung kailangan at gagawin itong default para sa diktasyon. Naglo-load ang Voxtype ng base na modelong English na umaabot sa 150MB; palitan ang modelo gamit ang `voxtype setup model` at ang iba pang mga setting sa pamamagitan ng `~/.config/voxtype/config.toml`. Binubuksan ng Superwhisper ang mga setting nito upang pumili ng cloud o lokal na processing, at pinapanatiling updated ng OPR ang application. Dina-download ng Hex ang on-device speech model nito habang sine-setup at tumatakbo bilang user service na `hex.service`; buksan ang window nito mula sa tray icon sa bar o sa pamamagitan ng pagpapatakbo ng `hex` upang palitan ang modelo at iba pang mga setting.

Magdidikta ka sa pamamagitan ng pagpindot nang matagal sa `Right Alt`, o sa pamamagitan ng pag-toggle gamit ang `Alt + Space`, at lalabas ang idinikta mong teksto sa naka-focus na input area. Ginagamit ng mga shortcut na ito ang napiling backend. Nagsisimula rin ang Right Alt ng diktasyon kapag ginamit sa isang modifier chord; gamitin ang Left Alt para sa mga chord na iyon. Sa mga keyboard layout kung saan ang Right Alt ay AltGr, gamitin ang `Alt + Space` upang manatiling available ang AltGr para sa pag-type. Pinapanatili ng mga install mula bago naging default ang Alt + Space ang `F9` para sa push-to-talk at `Super + Ctrl + X` para mag-toggle, na idinagdag sa `~/.config/hypr/bindings.lua`; alisin ang mga iyon doon upang maibalik ang mga key na iyon sa mga application.

Gumagana ang parehong mga shortcut sa bawat backend. Piliin ang iyong backend sa pamamagitan ng Setup > Mga Default > Diktasyon. Kino-configure ito ng installer ng backend at sine-save ang pinili. Patakbuhin ang `omarchy default dictation` upang makita kung alin ang napili. Sine-save ang pinili sa `~/.config/omarchy/defaults/dictation`. Awtomatikong pinipili ng mga bagong install ang Superwhisper.

Awtomatikong nalo-load ng Omarchy ang desktop integration ng napiling backend. Walang kailangang configuration ng Superwhisper sa `~/.config/hypr/`.

Maaaring gumamit ang mga custom na binding at script ng `omarchy dictation start`, `omarchy dictation stop`, at `omarchy dictation toggle`. Hinahawakan ng napiling backend ang pag-record at transcription. Ang pagpili sa Superwhisper ay nagdi-disable sa native hold shortcut nito at nagse-set sa native toggle nito sa `Ctrl + Alt + Space`, upang manatili itong hiwalay sa mga recording key ng Omarchy. Nangangailangan ang Superwhisper ng kahit isang native na recording shortcut, at nananatiling available ang cancellation shortcut nito.

Maaaring mag-integrate ang mga karagdagang backend nang hindi binabago ang Omarchy. Magbigay ng executable na pinangalanang `omarchy-dictation-<backend>` sa PATH na tumatanggap ng `start`, `stop`, at `toggle` at agad na bumabalik, na may nonzero na status kapag nabigo. Kino-configure ng installer nito ang provider at tinatawag ang `omarchy-dictation-use <backend>` pagkatapos ng matagumpay na setup. Iniistop nito ang nakaraang backend at sine-save nang atomiko ang pinili; dapat magtagumpay ang `stop` kapag idle o hindi available ang provider. Gumagamit ang mga pangalan ng backend ng maliliit na titik, mga digit, at mga gitling. Magbigay ng `omarchy-install-dictation-<backend>` para sa setup; inilulunsad ito ng `omarchy default dictation <backend>`. Magdagdag ng entry sa menu ng Mga Default sa pamamagitan ng extension ng menu ng Omarchy upang tawagin ang selector na iyon. Maaaring manirahan ang opsyonal na desktop integration sa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
