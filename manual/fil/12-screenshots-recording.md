# Mga Screenshot at Recording

Lahat ng makukuha mo mula sa screen ay nakasabit sa Print Screen key. Isang key lang ang kukuha ng larawan, at ang mga modifier ang kukuha ng recording, ng kulay, o ng text sa loob ng isang region. Kung wala talagang Print Screen key ang keyboard mo, `Super + Ctrl + Alt + C` ang kukuha ng parehong screenshot, at `Super + Ctrl + C` ang magbubukas ng buong set bilang menu.

| Hotkey | Gamit |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Screenrecord (o ihinto ang tumatakbong iyon) |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Kunin ang text mula sa isang region |
| `Super + Ctrl + C` | Menu ng capture |
| `Super + Ctrl + .` | I-transcode ang isang larawan o video |

## Mga Screenshot

Pindutin ang `Print Screen` (o `Super + Ctrl + Alt + C`) at kukunan ng Omasnap ang naka-focus na monitor bago lumabas ang overlay nito, kaya walang gagalaw sa ilalim mo habang pumupuntirya ka. Mag-drag ng freeform na region, mag-click ng window para kunan ito, o mag-click sa bakanteng espasyo para kunan ang buong monitor. Pindutin ang `S` bago gumuhit para kunan ang isang scrolling na region. Nagbago ang isip mo? Pindutin ulit ang parehong key para i-dismiss ang Omasnap.

Pagkatapos mong pumili ng area, ise-save ng Omasnap ang capture, kokopyahin ito sa clipboard, at magpapakita ng notification kasama ang thumbnail nito, tulad ng ginagawa ng isang naka-save na screen recording. Piliin ang Open para tingnan ang naka-save na shot sa image viewer mo, o ang Edit para lagyan ito ng annotation.

Makakaguhit ang annotation editor ng mga arrow, linya, hugis, highlight, may numerong marker, text, at secure na redaction; mag-crop o mag-cut out ng bahagi ng larawan; mag-OCR ng text nito; at magdagdag ng backdrop. Sa editor, pindutin ang `Enter` para kopyahin at i-save ang tapos na PNG, `Ctrl + C` para kopyahin ito nang hindi sine-save, o `Ctrl + S` para i-save ito nang hindi kinokopya.

Sa `~/Pictures/Screenshots` napupunta ang mga naka-save na screenshot bilang default, na may pangalang tulad ng `screenshot-2026-08-13_14-22-05-firefox.png`. Itakda ang `OMASNAP_SCREENSHOT_DIR` para gumamit ng ibang directory — tingnan [ang FAQ](46-faq.md) para sa kung saan ilalagay ang mga session environment variable. Ginagawa ng Omasnap ang directory kapag sine-save nito ang unang shot. Itakda ang `[output] autosave = false` sa `~/.config/omasnap/omasnap.conf` para i-disable ang awtomatikong pag-save; kokopyahin na lang ang mga capture, at ipapakita sa isang preview sa loob ng 7 segundo na maaari mong panatilihin sa screen gamit ang pin button nito o ang `Ctrl + P`.

Mula sa terminal, bubuksan ng `omarchy screenshot` ang parehong overlay, at maaari mong piliin ang panimulang mode nito: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Ang pangalawang argument na `copy` o `save` ay direktang magpapadala ng shot sa destinasyong iyon. Para mag-edit bago ang output, gamitin ang `omarchy screenshot --editor=overlay` para sa isang fullscreen na editor o `omarchy screenshot --editor=window` para sa isang hiwalay na window.

### Pagpapatakbo sa picker gamit ang keyboard

Habang nakataas ang selection, hindi mo na kailangang gumamit ng mouse kahit kailan:

| Key | Gamit |
| --- | -------- |
| `S` | I-toggle ang scrolling-region mode |
| `Super + Arrow keys` | Maglipat-lipat sa mga window sa Window mode |
| `Return` | Kunan ang naka-highlight na window |
| `Ctrl + A` | Kunan ang buong naka-focus na monitor |
| `R` | Ibalik ang huling region na ginuhit sa session na ito |
| `Esc` | I-dismiss ang Omasnap |

Umiiral lang ang mga binding na ito habang bukas ang Omasnap, kaya hindi sila magbabanggaan sa kahit ano sa sarili mong config.

## Pag-record ng screen

Binubuksan ng `Alt + Print Screen` ang _Trigger > Capture > Screenrecord_, na magtatanong kung ano ang gusto mo sa soundtrack: walang audio, desktop audio, desktop plus microphone, o desktop plus microphone plus webcam. Lalabas lang ang huli kung may camera ka talagang nakasaksak. Pumili ng isa at hahayaan ka ng recording picker ng Omarchy na mag-drag ng region o mag-click ng window o monitor.

Tumatakbo ang recording sa gpu-screen-recorder, na nag-e-encode sa GPU sa 60fps at bumabalik sa CPU kung kailangan; sa mga GPU na hindi nito sinusuportahan, tulad ng sa Apple Silicon, nagre-record ang Omarchy gamit ang wf-recorder sa halip. Ang resulta ay isang MP4 sa `~/Videos`, na pinangalanang `screenrecording-2026-08-13_14-22-05.mp4`. Itakda ang `OMARCHY_SCREENRECORD_DIR` para baguhin iyon — pero tandaan na hindi tulad ng directory ng screenshot, kailangang umiiral na ang isang ito, kung hindi ay tatangging magsimula ang recording.

Habang nagre-record ka, may maliit na indicator na lalabas sa bar. I-click ito para huminto. Maaari ka ring huminto gamit ulit ang `Alt + Print Screen`, o gamit ang _Stop Screenrecording_ na entry sa ilalim ng _Trigger > Capture > Screenrecord_, na lalabas lang habang may aktwal na nagre-record.

May kaunting paglilinis ang paghinto bago nito ibigay sa iyo ang file: tini-trim ang unang frame, at kung may audio, nino-normalize ito sa -14 LUFS habang naka-mute ang pop ng PipeWire capture sa pinakasimula. Pagkatapos ay lalabas ang isang notification na may thumbnail mula sa recording. Piliin ang _Open_ para i-play ang file sa Omaview, o ang _Cut_ para i-trim ito sa Omacut.

### Ang webcam overlay

Kapag nag-record ka gamit ang webcam, lalabas ang camera bilang isang naka-pin, naka-crop na portrait window sa ibabang-kanang sulok ng anumang nire-record mo. Kung nakapatong ito sa isang bagay na kailangan mo, i-resize ito agad-agad:

| Hotkey | Gamit |
| ------ | -------- |
| `Super + Alt + [` | Paliitin ang webcam overlay |
| `Super + Alt + ]` | Palakihin ang webcam overlay |

May tatlong laki — maliit, katamtaman, at malaki — at ang mga hotkey ang humahakbang sa pagitan ng mga ito. Katamtaman ang default. Proporsyonal sila sa recording, kaya parehong bahagi ng frame ang sakop ng camera kahit nagre-record ka ng 1080p na monitor o ng 6K na monitor. At kung region ang ni-record mo sa halip na buong display, naka-anchor ang overlay sa sulok ng region na iyon sa halip na sa sulok ng monitor, kaya nananatili ito sa loob ng shot.

Maaari mo rin itong tawagin nang direkta gamit ang `omarchy-capture-webcam-resize small`, o `reset` para bumalik sa katamtaman.

## Text, mga QR code, at mga kulay

Pumipili ang `Super + Ctrl + Print Screen` ng region at ino-OCR ito papunta sa clipboard. Maayos itong tinalakay sa [Pagkuha ng Text at Dictation](11-text-extraction-dictation.md).

Ginagawa ng _Trigger > Capture > QR Code_ ang parehong trick para sa mga QR code. Piliin ang region na may code, at mapupunta sa clipboard ang na-decode na value. Mga QR code lang ang hinahanap nito — ang siksik na content ng screen ay may ugaling mag-false positive bilang barcode kung hindi. Dapat mong malaman: sa clipboard lang napupunta ang na-decode na value at wala nang iba. Hindi ito nipi-print, wala ito sa notification, at minarkahan itong sensitive kaya hindi ito mananatili sa [kasaysayan ng clipboard](08-unified-clipboard-history.md). Karaniwang may dalang mga secret ang mga QR code — ang `otpauth://` URI sa likod ng isang 2FA setup code, halimbawa — at ayaw mong mapunta iyon sa isang log. Gumagana pa rin nang maayos ang pag-paste.

Ginagawang eyedropper ng `Super + Print Screen` (o _Trigger > Capture > Color_) ang cursor. I-click ang kahit ano sa screen at mapupunta ang kulay sa clipboard. Pindutin ulit ang hotkey para umatras nang hindi pumipili.

## Pag-transcode bago ka magbahagi

Madalas na masyadong malaki para ipadala na lang ang isang 4K na screen recording o isang raw na HEIC mula sa telepono mo. Inaayos iyan ng `Super + Ctrl + .` (o _Trigger > Transcode_). Bibigyan ka nito ng fuzzy file picker sa `~/Pictures` at `~/Videos`, pagkatapos ay magtatanong ng format at laki.

Napupunta ang mga larawan sa jpg o png sa high, medium, o low, na naglilimita sa lapad sa 3160, 2160, at 1080 pixels. Napupunta ang mga video sa mp4 o animated na gif sa 4k, 1080p, o 720p. Isinusulat ang na-convert na file katabi ng orihinal na may resolution sa pangalan — `demo-1080p.mp4` — at kinokopya ang path sa clipboard bilang file URI, kaya maaari mo itong i-paste nang direkta sa isang app na tumatanggap ng file drops.

Gumagana rin ito mula sa terminal, kung alam mo na kung ano ang gusto mo: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Mayroon ding `omarchy transcode ascii`, na ginagawang ASCII art ang isang larawan — pang-[branding](41-branding.md) lang iyon kadalasan.

## Pagpapadala nito kung saan

Kapag nakuha mo na ang file, bubuksan ng `Super + Ctrl + S` ang Share menu at ipapadala ito sa isa pang device sa network mo sa pamamagitan ng LocalSend. Tingnan ang [GUIs](22-guis.md) para roon.
