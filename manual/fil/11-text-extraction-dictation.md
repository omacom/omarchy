# Pagkuha ng Teksto at Diktasyon

### Pagkuha ng Teksto

Pindutin ang `Super + Ctrl + PrtScr` para pumili ng isang rehiyon sa screen para sa pagkuha ng teksto. Ang tesseract open source OCR model ay mabilis pagkatapos na iko-convert ang piniling iyon sa teksto at ilalagay ito sa clipboard. Pagkatapos ay pipindutin mo lang ang `Super + V` para i-paste.

Napakatulong nito para sa pagkuha ng mga address mula sa mga footer ng larawan o mga numero ng telepono na naka-embed sa mga headline ng website.

 ![text-extraction](images/text-extraction.webp)

### Diktasyon

Sa mga bagong pag-install, ang [Superwhisper](https://superwhisper.com/) ang default na backend ng diktasyon, na gumagamit ng cloud processing nang walang mga offline model download. Piliin ang Superwhisper o [Voxtype](https://voxtype.io/) sa pamamagitan ng _Pag-setup > Mga Default > Diktasyon_ sa menu ng Omarchy. Ang pagpili ng backend ay ini-install ito kung kinakailangan at ginagawa itong default para sa diktasyon. Naglo-load ang Voxtype ng isang base English model na umaabot ng 150MB; baguhin ang model gamit ang `voxtype setup model` at ang iba pang mga setting sa pamamagitan ng `~/.config/voxtype/config.toml`. Binubuksan ng Superwhisper ang mga setting nito para piliin ang cloud o local processing, at pinapanatili ng OPR na updated ang application.

Nagdidikta ka sa pamamagitan ng pagpindot nang matagal sa `Right Alt` o `F9`, o sa pamamagitan ng pag-toggle gamit ang `Super + Ctrl + X`, at ang diniktang teksto ay lalabas sa naka-focus na input area. Ginagamit ng mga shortcut na ito ang napiling backend. Sinisimulan din ng Right Alt ang diktasyon kapag ginamit sa isang modifier chord; gamitin ang Left Alt para sa mga chord na iyon. Sa mga layout ng keyboard kung saan ang Right Alt ay AltGr, gamitin ang `F9` para panatilihing available ang AltGr para sa pag-type.

Ang parehong mga shortcut ay gumagana sa alinmang backend. Piliin ang iyong backend sa pamamagitan ng Pag-setup > Mga Default > Diktasyon. Kinokonpigura ito ng backend installer at sine-save ang pinili. Patakbuhin ang `omarchy default dictation` para makita kung alin ang napili. Ang pinili ay sine-save sa `~/.config/omarchy/defaults/dictation`. Awtomatikong pinipili ng mga bagong pag-install ang Superwhisper.

Awtomatikong nilo-load ng Omarchy ang desktop integration ng napiling backend. Walang Superwhisper configuration na kinakailangan sa `~/.config/hypr/`.

Ang mga custom na binding at script ay maaaring gumamit ng `omarchy dictation start`, `omarchy dictation stop`, at `omarchy dictation toggle`. Pinangangasiwaan ng napiling backend ang pag-record at transcription. Ang pagpili sa Superwhisper ay hindi pinapagana ang native hold shortcut nito at itinatakda ang native toggle nito sa `Alt + Space`, na pinapanatili itong hiwalay mula sa mga recording key ng Omarchy. Nangangailangan ang Superwhisper ng hindi bababa sa isang native recording shortcut, at ang cancellation shortcut nito ay nananatiling available.

Maaaring mag-integrate ang mga karagdagang backend nang hindi binabago ang Omarchy. Magbigay ng isang executable na pinangalanang `omarchy-dictation-<backend>` sa PATH na tumatanggap ng `start`, `stop`, at `toggle` at bumabalik kaagad, na may nonzero status kapag nabigo. Kinokonpigura ng installer nito ang provider at tinatawag ang `omarchy-dictation-use <backend>` pagkatapos ng matagumpay na pag-setup. Pinahihinto nito ang nakaraang backend at sine-save ang pinili nang atomically; kailangang magtagumpay ang `stop` kapag ang provider ay idle o hindi available. Gumagamit ang mga pangalan ng backend ng maliliit na letra, mga digit, at mga hyphen. Magbigay ng `omarchy-install-dictation-<backend>` para sa pag-setup; inilulunsad ito ng `omarchy default dictation <backend>`. Magdagdag ng entry sa menu ng Mga Default sa pamamagitan ng isang Omarchy menu extension para tawagin ang tagapiling iyon. Ang opsyonal na desktop integration ay maaaring manirahan sa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
