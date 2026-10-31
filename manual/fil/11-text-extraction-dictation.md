# Pagkuha ng Teksto at Diktasyon

### Pagkuha ng Teksto

Pindutin ang `Super + Ctrl + PrtScr` para pumili ng rehiyon sa screen para sa pagkuha ng teksto. Mabilis na iko-convert ng tesseract open source OCR model ang pinili mo sa teksto at ilalagay ito sa clipboard. Pagkatapos, pindutin lang ang `Super + V` para i-paste.

Napakakatulong nito para kumuha ng mga address mula sa mga footer ng larawan o mga numero ng telepono na naka-embed sa mga headline ng website.

 ![text-extraction](images/text-extraction.webp)

### Diktasyon

Sa mga bagong install, ang [Superwhisper](https://superwhisper.com/) ang default na dictation backend, na gumagamit ng cloud processing nang walang offline model downloads. Piliin ang Superwhisper o ang [Voxtype](https://voxtype.io/) sa pamamagitan ng _Setup > Defaults > Dictation_ sa menu ng Omarchy. Ang pagpili ng backend ay mag-i-install nito kung kailangan at gagawin itong default para sa diktasyon. Naglo-load ang Voxtype ng base English model na kumukuha ng 150MB; palitan ang model gamit ang `voxtype setup model` at ang iba pang settings sa pamamagitan ng `~/.config/voxtype/config.toml`. Binubuksan ng Superwhisper ang settings nito para pumili ng cloud o local processing, at pinapanatiling updated ng OPR ang application.

Magdidikta ka sa pamamagitan ng pagpindot nang matagal sa `Right Alt`, o sa pag-toggle gamit ang `Alt + Space`, at lilitaw ang idinikta mong teksto sa nakatuong input area. Ginagamit ng mga shortcut na ito ang napiling backend. Sinisimulan din ng Right Alt ang diktasyon kapag ginamit sa isang modifier chord; gamitin ang Left Alt para sa mga chord na iyon. Sa mga keyboard layout kung saan ang Right Alt ay AltGr, gamitin ang `Alt + Space` para manatiling available ang AltGr para sa pag-type. Ang mga install mula bago naging default ang Alt + Space ay pinapanatili ang `F9` para sa push-to-talk at `Super + Ctrl + X` para mag-toggle, na idinagdag sa `~/.config/hypr/bindings.lua`; alisin ang mga ito doon para maibalik ang mga key na iyon sa mga application.

Gumagana ang parehong mga shortcut sa alinmang backend. Piliin ang iyong backend sa pamamagitan ng Setup > Defaults > Dictation. Kino-configure ito ng installer ng backend at sine-save ang pinili. Patakbuhin ang `omarchy default dictation` para makita kung alin ang napili. Nakasave ang pinili sa `~/.config/omarchy/defaults/dictation`. Awtomatikong pinipili ng mga bagong install ang Superwhisper.

Awtomatikong nilo-load ng Omarchy ang desktop integration ng napiling backend. Walang kailangang configuration ng Superwhisper sa `~/.config/hypr/`.

Maaaring gumamit ang mga custom binding at script ng `omarchy dictation start`, `omarchy dictation stop`, at `omarchy dictation toggle`. Ang napiling backend ang humahawak sa recording at transcription. Ang pagpili sa Superwhisper ay nagdi-disable sa native hold shortcut nito at nagse-set sa native toggle nito sa `Ctrl + Alt + Space`, para manatili itong hiwalay sa mga recording key ng Omarchy. Nangangailangan ang Superwhisper ng hindi bababa sa isang native recording shortcut, at mananatiling available ang cancellation shortcut nito.

Maaaring mag-integrate ang mga karagdagang backend nang hindi binabago ang Omarchy. Magbigay ng executable na pinangalanang `omarchy-dictation-<backend>` sa PATH na tumatanggap ng `start`, `stop`, at `toggle` at agad na bumabalik, na may nonzero status kapag nabigo. Kino-configure ng installer nito ang provider at tinatawag ang `omarchy-dictation-use <backend>` pagkatapos ng matagumpay na setup. Ihihinto nito ang nakaraang backend at sine-save nang atomically ang pinili; dapat magtagumpay ang `stop` kapag idle o hindi available ang provider. Gumagamit ang mga pangalan ng backend ng maliliit na letra, mga digit, at mga gitling. Magbigay ng `omarchy-install-dictation-<backend>` para sa setup; inilulunsad ito ng `omarchy default dictation <backend>`. Magdagdag ng entry sa menu ng Defaults sa pamamagitan ng extension ng menu ng Omarchy para tawagin ang selector na iyon. Maaaring nasa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` ang opsyonal na desktop integration.
