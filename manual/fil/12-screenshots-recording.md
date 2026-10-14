# Mga Screenshot at Pag-record

Lahat ng maaari mong kunin mula sa screen ay nakakabit sa Print Screen key. Ang isang key nang mag-isa ay kumukuha ng larawan, at ang mga modifier ay kumukuha ng recording, isang kulay, o ang tekstong nasa loob ng isang rehiyon. Kung wala talagang Print Screen key ang iyong keyboard, binubuksan ng `Super + Ctrl + C` ang parehong set bilang isang menu.

| Hotkey | Tungkulin |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Alt + Print Screen` | Pag-record ng screen (o itigil ang tumatakbo) |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Kunin ang teksto mula sa isang rehiyon |
| `Super + Ctrl + C` | Menu ng kuha |
| `Super + Ctrl + .` | I-transcode ang isang larawan o video |

## Mga Screenshot

Pindutin ang `Print Screen` at kinukuha ng Omasnap ang naka-focus na monitor bago lumabas ang overlay nito, kaya walang gagalaw sa ilalim mo habang pumupuntirya ka. I-drag ang isang freeform na rehiyon, i-click ang isang bintana para kunin ito, o i-click ang bakanteng espasyo para kunin ang buong monitor. Pindutin ang `S` bago gumuhit para kumuha ng isang scrolling na rehiyon. Nagbago ang isip mo? Pindutin muli ang `Print Screen` para i-dismiss ang Omasnap.

Pagkatapos mong pumili ng isang lugar, sine-save ng Omasnap ang kuha, kinokopya ito sa clipboard, at nagpapakita ng preview sa loob ng 10 segundo. Gamitin ang pin button ng preview o ang `Ctrl + P` para panatilihin ito sa screen, o piliin ang Edit para i-annotate ito.

Ang annotation editor ay maaaring gumuhit ng mga arrow, linya, hugis, highlight, mga may bilang na marker, teksto, at mga secure na redaction; mag-crop o magputol ng bahagi ng larawan; mag-OCR ng teksto nito; at magdagdag ng backdrop. Sa editor, pindutin ang `Enter` para kopyahin at i-save ang natapos na PNG, ang `Ctrl + C` para kopyahin ito nang hindi sine-save, o ang `Ctrl + S` para i-save ito nang hindi kinokopya.

Ang mga na-save na screenshot ay napupunta sa `~/Pictures/Screenshots` bilang default, na may pangalan tulad ng `screenshot-2026-08-13_14-22-05-firefox.png`. Itakda ang `OMASNAP_SCREENSHOT_DIR` para gumamit ng ibang directory — tingnan ang [FAQ](46-faq.md) para sa kung saan ilalagay ang mga session environment variable. Ginagawa ng Omasnap ang directory kapag sine-save nito ang unang shot. Itakda ang `[output] autosave = false` sa `~/.config/omasnap/omasnap.conf` para i-disable ang awtomatikong pag-save.

Mula sa terminal, binubuksan ng `omarchy screenshot` ang parehong overlay, at maaari mong piliin ang panimulang mode nito: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Ang pangalawang argument na `copy` o `save` ay nilalampasan ang preview at ipinapadala ang shot nang diretso sa destinasyong iyon. Para mag-edit bago ang output, gamitin ang `omarchy screenshot --editor=overlay` para sa isang fullscreen editor o ang `omarchy screenshot --editor=window` para sa isang hiwalay na bintana.

### Pagmamaneho ng picker mula sa keyboard

Habang nakataas ang pagpili, hindi mo kailangang gumamit ng mouse:

| Key | Tungkulin |
| --- | -------- |
| `S` | I-toggle ang scrolling-region mode |
| `Super + Arrow keys` | Lumipat sa mga bintana sa Window mode |
| `Return` | Kunin ang naka-highlight na bintana |
| `Ctrl + A` | Kunin ang buong naka-focus na monitor |
| `R` | Ibalik ang huling rehiyong ginuhit sa session na ito |
| `Esc` | I-dismiss ang Omasnap |

Ang mga binding na ito ay umiiral lang habang bukas ang Omasnap, kaya hindi sila maaaring sumalungat sa anuman sa sarili mong config.

## Pag-record ng screen

Binubuksan ng `Alt + Print Screen` ang _Mag-trigger > Kuha > Pag-record ng Screen_, na nagtatanong kung ano ang gusto mo sa soundtrack: walang audio, audio ng desktop, desktop plus mikropono, o desktop plus mikropono plus webcam. Ang huli ay lumalabas lang kung talagang may nakasaksak kang camera. Pumili ng isa at hahayaan ka ng recording picker ng Omarchy na mag-drag ng isang rehiyon o mag-click ng isang bintana o monitor.

Ang pag-record ay tumatakbo sa gpu-screen-recorder, na nag-e-encode sa GPU sa 60fps at bumabalik sa CPU kung kinakailangan. Ang resulta ay isang MP4 sa `~/Videos`, na pinangalanang `screenrecording-2026-08-13_14-22-05.mp4`. Itakda ang `OMARCHY_SCREENRECORD_DIR` para baguhin iyon — ngunit tandaan na hindi tulad ng screenshot directory, kailangan nang umiiral ang isang ito, o tatangging magsimula ang pag-record.

Habang nagre-record ka, lumalabas ang isang maliit na indikator sa bar. I-click ito para itigil. Maaari mo ring itigil gamit ang `Alt + Print Screen` muli, o gamit ang entry na _Itigil ang Pag-record_ sa ilalim ng _Mag-trigger > Kuha > Pag-record ng Screen_, na lumalabas lang habang may talagang nagre-record.

Ang pagtigil ay gumagawa ng kaunting pag-aayos bago nito ibigay sa iyo ang file: tinatanggal ang unang frame, at kung may audio, nino-normalize ito sa -14 LUFS habang ang PipeWire capture pop sa pinakasimula ay naka-mute. Pagkatapos ay lalabas ang isang notipikasyon na may thumbnail mula sa recording. I-click ito para i-play ang file sa mpv.

### Ang overlay ng webcam

Kapag nagre-record ka gamit ang isang webcam, lumalabas ang camera bilang isang naka-pin, na-crop na portrait window sa ibabang kanang sulok ng anumang nire-record mo. Kung nakapatong ito sa ibabaw ng isang bagay na kailangan mo, i-resize ito on the fly:

| Hotkey | Tungkulin |
| ------ | -------- |
| `Super + Alt + [` | Paliitin ang overlay ng webcam |
| `Super + Alt + ]` | Palakihin ang overlay ng webcam |

May tatlong laki — maliit, katamtaman, at malaki — at ang mga hotkey ay humahakbang sa pagitan ng mga ito. Ang katamtaman ang default. Proporsyonal ang mga ito sa recording, kaya sinasakop ng camera ang parehong bahagi ng frame kung nagre-record ka man ng isang 1080p monitor o ng isang 6K. At kung nag-record ka ng isang rehiyon sa halip ng isang buong display, ang overlay ay naka-anchor sa sulok ng rehiyong iyon sa halip ng sa monitor, kaya nananatili ito sa loob ng shot.

Maaari mo rin itong tawagan nang diretso gamit ang `omarchy-capture-webcam-resize small`, o ang `reset` para bumalik sa katamtaman.

## Teksto, mga QR code, at mga kulay

Pumipili ang `Super + Ctrl + Print Screen` ng isang rehiyon at ini-OCR ito papunta sa clipboard. Tama itong tinatalakay sa [Pagkuha ng Teksto at Diktasyon](11-text-extraction-dictation.md).

Ginagawa ng _Mag-trigger > Kuha > QR Code_ ang parehong trick para sa mga QR code. Piliin ang rehiyon na may code, at ang na-decode na halaga ay mapupunta sa clipboard. Naghahanap lang ito ng mga QR code — ang siksik na nilalaman ng screen ay may ugaling mag-false-positive bilang barcode kung hindi. Sulit malaman: ang na-decode na halaga ay napupunta sa clipboard at wala nang iba pa. Hindi ito ini-print, wala ito sa notipikasyon, at minarkahan itong sensitibo kaya hindi ito nananatili sa [kasaysayan ng clipboard](08-unified-clipboard-history.md). Karaniwang nagdadala ang mga QR code ng mga sikreto — ang `otpauth://` URI sa likod ng isang 2FA setup code, halimbawa — at hindi mo gugustuhin iyon sa isang log. Gumagana pa rin nang maayos ang pag-paste.

Ginagawang eyedropper ng `Super + Print Screen` (o _Mag-trigger > Kuha > Kulay_) ang cursor. I-click ang anumang bagay sa screen at ang kulay ay mapupunta sa clipboard. Pindutin ulit ang hotkey para umatras nang hindi pumipili.

## Pag-transcode bago mo ibahagi

Ang isang 4K na pag-record ng screen o isang raw na HEIC mula sa iyong telepono ay kadalasang masyadong malaki para ipadala lang. Inaayos iyon ng `Super + Ctrl + .` (o _Mag-trigger > I-transcode_). Nag-aalok ito sa iyo ng isang fuzzy file picker sa `~/Pictures` at `~/Videos`, pagkatapos ay nagtatanong ng format at laki.

Ang mga larawan ay napupunta sa jpg o png sa high, medium, o low, na naglilimita sa lapad sa 3160, 2160, at 1080 pixel. Ang mga video ay napupunta sa mp4 o isang animated gif sa 4k, 1080p, o 720p. Ang na-convert na file ay isusulat sa tabi ng orihinal na may resolution sa pangalan — `demo-1080p.mp4` — at ang path ay kinokopya sa clipboard bilang isang file URI, kaya maaari mo itong i-paste nang diretso sa isang app na tumatanggap ng mga file drop.

Gumagana rin ito mula sa terminal, kung alam mo na kung ano ang gusto mo: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Mayroon ding `omarchy transcode ascii`, na ginagawang ASCII art ang isang larawan — kadalasan iyon ay para sa [branding](41-branding.md).

## Pagpapadala nito kung saan

Kapag nakuha mo na ang file, binubuksan ng `Super + Ctrl + S` ang menu ng Ibahagi at ipinapadala ito sa ibang device sa iyong network sa pamamagitan ng LocalSend. Tingnan ang [mga GUI](22-guis.md) para roon.
