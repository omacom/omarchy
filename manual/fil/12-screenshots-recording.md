# Mga Screenshot at Pagre-record

Lahat ng maaari mong kunin mula sa screen ay nakasabit sa Print Screen key. Ang isang key na mag-isa ay kumukuha ng larawan, at ang mga modifier ay kumukuha ng recording, ng kulay, o ng teksto sa loob ng isang rehiyon. Kung wala talagang Print Screen key ang keyboard mo, kinukuha ng `Super + Ctrl + Alt + C` ang parehong screenshot, at binubuksan ng `Super + Ctrl + C` ang buong set bilang isang menu.

| Hotkey | Tungkulin |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Screenrecord (o ihinto ang tumatakbo) |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Kunin ang teksto mula sa isang rehiyon |
| `Super + Ctrl + C` | Menu ng capture |
| `Super + Ctrl + .` | I-transcode ang isang larawan o video |

## Mga Screenshot

Pindutin ang `Print Screen` (o `Super + Ctrl + Alt + C`) at kukunan ng Omasnap ang nakatuong monitor bago lumitaw ang overlay nito, kaya walang gagalaw sa ilalim mo habang pumupuntirya ka. Mag-drag ng freeform na rehiyon, mag-click ng window para kunan ito, o mag-click sa bakanteng espasyo para kunan ang buong monitor. Pindutin ang `S` bago gumuhit para kunan ang isang scrolling na rehiyon. Nagbago ang isip mo? Pindutin ulit ang parehong key para i-dismiss ang Omasnap.

Pagkatapos mong pumili ng lugar, ise-save ng Omasnap ang capture, kokopyahin ito sa clipboard, at magpapakita ng notification kasama ang thumbnail nito, tulad ng ginagawa ng isang naka-save na screen recording. Piliin ang Open para tingnan ang naka-save na shot sa image viewer mo, o ang Edit para i-annotate ito.

Ang annotation editor ay maaaring gumuhit ng mga arrow, linya, hugis, highlight, may numerong marker, teksto, at mga secure na redaction; mag-crop o mag-cut out ng bahagi ng larawan; mag-OCR ng teksto nito; at magdagdag ng backdrop. Sa editor, pindutin ang `Enter` para kopyahin at i-save ang natapos na PNG, ang `Ctrl + C` para kopyahin ito nang hindi sine-save, o ang `Ctrl + S` para i-save ito nang hindi kinokopya.

Ang mga naka-save na screenshot ay napupunta sa `~/Pictures/Screenshots` bilang default, na may pangalang tulad ng `screenshot-2026-08-13_14-22-05-firefox.png`. Itakda ang `OMASNAP_SCREENSHOT_DIR` para gumamit ng ibang directory — tingnan ang [FAQ](46-faq.md) kung saan ilalagay ang mga session environment variable. Ginagawa ng Omasnap ang directory kapag sine-save nito ang unang shot. Itakda ang `[output] autosave = false` sa `~/.config/omasnap/omasnap.conf` para i-disable ang awtomatikong pag-save; ang mga capture ay kokopyahin na lang, at ipapakita sa isang preview sa loob ng 10 segundo na maaari mong panatilihin sa screen gamit ang pin button nito o ang `Ctrl + P`.

Mula sa terminal, binubuksan ng `omarchy screenshot` ang parehong overlay, at maaari mong piliin ang panimulang mode nito: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Ang pangalawang argument na `copy` o `save` ay direktang nagpapadala sa shot sa destinasyong iyon. Para mag-edit bago ang output, gamitin ang `omarchy screenshot --editor=overlay` para sa isang fullscreen na editor o ang `omarchy screenshot --editor=window` para sa isang hiwalay na window.

### Pagpapatakbo sa picker gamit ang keyboard

Habang nakabukas ang selection, hindi mo na kailangang gamitin ang mouse kahit kailan:

| Key | Tungkulin |
| --- | -------- |
| `S` | I-toggle ang mode na scrolling-region |
| `Super + Arrow keys` | Lumipat-lipat sa mga window sa Window mode |
| `Return` | Kunan ang naka-highlight na window |
| `Ctrl + A` | Kunan ang buong nakatuong monitor |
| `R` | Ibalik ang huling rehiyong iginuhit sa session na ito |
| `Esc` | I-dismiss ang Omasnap |

Ang mga binding na ito ay umiiral lamang habang nakabukas ang Omasnap, kaya hindi sila maaaring sumalungat sa kahit ano sa sarili mong config.

## Pagre-record ng screen

Binubuksan ng `Alt + Print Screen` ang _Trigger > Capture > Screenrecord_, na nagtatanong kung ano ang gusto mo sa soundtrack: walang audio, audio ng desktop, desktop plus microphone, o desktop plus microphone plus webcam. Ang huling iyon ay lumilitaw lamang kung mayroon ka talagang nakasaksak na camera. Pumili ng isa at hahayaan ka ng recording picker ng Omarchy na mag-drag ng rehiyon o mag-click ng window o monitor.

Tumatakbo ang pagre-record sa gpu-screen-recorder, na nag-e-encode sa GPU sa 60fps at bumabalik sa CPU kung kailangan. Ang resulta ay isang MP4 sa `~/Videos`, na pinangalanang `screenrecording-2026-08-13_14-22-05.mp4`. Itakda ang `OMARCHY_SCREENRECORD_DIR` para baguhin iyon — pero tandaan na hindi tulad ng directory ng screenshot, kailangang umiiral na ito, o tatangging magsimula ang recording.

Habang nagre-record ka, lumilitaw ang isang maliit na indicator sa bar. I-click ito para huminto. Maaari ka ring huminto gamit ang `Alt + Print Screen` ulit, o gamit ang entry na _Stop Screenrecording_ sa ilalim ng _Trigger > Capture > Screenrecord_, na lumilitaw lamang habang may aktwal na nagre-record.

Ang paghinto ay gumagawa ng kaunting paglilinis bago nito ibigay sa iyo ang file: tina-trim ang unang frame, at kung may audio, nino-normalize ito sa -14 LUFS habang naka-mute ang pop ng PipeWire capture sa pinakasimula. Pagkatapos ay lilitaw ang isang notification na may thumbnail mula sa recording. I-click ito para i-play ang file sa mpv.

### Ang webcam overlay

Kapag nag-record ka gamit ang isang webcam, lumilitaw ang camera bilang isang naka-pin, naka-crop na portrait window sa kanang sulok sa ibaba ng anumang nire-record mo. Kung nakapatong ito sa isang bagay na kailangan mo, baguhin ang laki nito habang tumatakbo:

| Hotkey | Tungkulin |
| ------ | -------- |
| `Super + Alt + [` | Paliitin ang webcam overlay |
| `Super + Alt + ]` | Palakihin ang webcam overlay |

May tatlong laki — small, medium, at large — at ang mga hotkey ay humahakbang sa pagitan ng mga ito. Medium ang default. Proporsyonal ang mga ito sa recording, kaya sinasakop ng camera ang parehong bahagi ng frame kahit nagre-record ka ng 1080p na monitor o ng 6K na monitor. At kung rehiyon ang ni-record mo sa halip na buong display, naka-anchor ang overlay sa sulok ng rehiyong iyon sa halip na sa sulok ng monitor, kaya nananatili ito sa loob ng shot.

Maaari mo rin itong tawagin nang direkta gamit ang `omarchy-capture-webcam-resize small`, o ang `reset` para bumalik sa medium.

## Teksto, mga QR code, at mga kulay

Ang `Super + Ctrl + Print Screen` ay pumipili ng rehiyon at ino-OCR ito papunta sa clipboard. Maayos itong tinalakay sa [Pagkuha ng Teksto at Diktasyon](11-text-extraction-dictation.md).

Ginagawa ng _Trigger > Capture > QR Code_ ang parehong trick para sa mga QR code. Piliin ang rehiyon na may code, at mapupunta ang na-decode na value sa clipboard. Mga QR code lang ang hinahanap nito — ang siksik na content sa screen ay may ugaling mag-false-positive bilang barcode kung hindi. Mahalagang malaman: ang na-decode na value ay napupunta sa clipboard at wala nang iba pa. Hindi ito ini-print, hindi ito nasa notification, at minarkahan itong sensitive kaya hindi ito mananatili sa [kasaysayan ng clipboard](08-unified-clipboard-history.md). Karaniwang may dalang mga secret ang mga QR code — ang `otpauth://` URI sa likod ng isang 2FA setup code, halimbawa — at ayaw mong mapunta iyon sa isang log. Gumagana pa rin nang maayos ang pag-paste.

Ginagawa ng `Super + Print Screen` (o _Trigger > Capture > Color_) na eyedropper ang cursor. Mag-click ng kahit ano sa screen at mapupunta ang kulay sa clipboard. Pindutin ulit ang hotkey para umatras nang hindi pumipili.

## Pag-transcode bago mo ibahagi

Ang isang 4K na screen recording o isang raw na HEIC mula sa phone mo ay kadalasang masyadong malaki para basta na lang ipadala. Inaayos iyan ng `Super + Ctrl + .` (o _Trigger > Transcode_). Nag-aalok ito sa iyo ng isang fuzzy file picker sa `~/Pictures` at `~/Videos`, pagkatapos ay nagtatanong ng format at laki.

Ang mga larawan ay napupunta sa jpg o png sa high, medium, o low, na naglilimita sa lapad sa 3160, 2160, at 1080 pixel. Ang mga video ay napupunta sa mp4 o isang animated gif sa 4k, 1080p, o 720p. Ang na-convert na file ay isinusulat sa tabi ng orihinal na may resolution sa pangalan — `demo-1080p.mp4` — at ang path ay kinokopya sa clipboard bilang isang file URI, kaya maaari mo itong i-paste nang direkta sa isang app na tumatanggap ng mga file drop.

Gumagana rin ito mula sa terminal, kung alam mo na kung ano ang gusto mo: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Mayroon ding `omarchy transcode ascii`, na ginagawang ASCII art ang isang larawan — iyon ay karaniwan para sa [branding](41-branding.md).

## Pagpapadala nito kung saan

Kapag nakuha mo na ang file, binubuksan ng `Super + Ctrl + S` ang Share menu at ipinapadala ito sa ibang device sa network mo sa pamamagitan ng LocalSend. Tingnan ang [GUIs](22-guis.md) para roon.
