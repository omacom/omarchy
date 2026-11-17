# Mga Screenshot at Pagre-record

Lahat ng puwede mong kunin mula sa screen ay nakasabit sa Print Screen key. Ang isang key nang mag-isa ay kumukuha ng larawan, at ang mga modifier ay kumukuha ng recording, ng kulay, o ng tekstong nasa loob ng isang rehiyon. Kung wala talagang Print Screen key ang keyboard mo, kinukuha ng `Super + Ctrl + Alt + C` ang parehong screenshot, at binubuksan ng `Super + Ctrl + C` ang buong set bilang isang menu.

| Hotkey | Gamit |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Screenrecord (o ihinto ang tumatakbong isa) |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Kunin ang teksto mula sa isang rehiyon |
| `Super + Ctrl + C` | Menu ng capture |
| `Super + Ctrl + .` | I-transcode ang isang larawan o video |

## Mga Screenshot

Pindutin ang `Print Screen` (o `Super + Ctrl + Alt + C`) at kukunan ng Omasnap ang nakatutok na monitor bago lumabas ang overlay nito, kaya walang gagalaw sa ilalim mo habang pumupuntirya ka. I-drag ang isang freeform na rehiyon, i-click ang isang window para kunan ito, o i-click ang bakanteng puwang para kunan ang buong monitor. Pindutin ang `S` bago gumuhit para kunan ang isang scrolling na rehiyon. Nagbago ang isip mo? Pindutin ulit ang parehong key para i-dismiss ang Omasnap.

Pagkatapos mong pumili ng isang area, ise-save ng Omasnap ang capture, kokopyahin ito sa clipboard, at magpapakita ng notification na may thumbnail nito, tulad ng ginagawa ng isang naka-save na screen recording. Piliin ang Open para tingnan ang naka-save na shot sa iyong image viewer, o ang Edit para lagyan ito ng anotasyon.

Kayang gumuhit ng editor ng anotasyon ng mga arrow, linya, hugis, highlight, may numerong marker, teksto, at secure na redaction; mag-crop o mag-cut out ng bahagi ng larawan; mag-OCR ng teksto nito; at magdagdag ng backdrop. Sa editor, pindutin ang `Enter` para kopyahin at i-save ang tapos nang PNG, `Ctrl + C` para kopyahin ito nang hindi sine-save, o `Ctrl + S` para i-save ito nang hindi kinokopya.

Napupunta ang mga naka-save na screenshot sa `~/Pictures/Screenshots` bilang default, na may pangalang gaya ng `screenshot-2026-08-13_14-22-05-firefox.png`. Itakda ang `OMASNAP_SCREENSHOT_DIR` para gumamit ng ibang directory — tingnan ang [FAQ](46-faq.md) para sa kung saan ilalagay ang mga session environment variable. Ginagawa ng Omasnap ang directory kapag sine-save nito ang unang shot. Itakda ang `[output] autosave = false` sa `~/.config/omasnap/omasnap.conf` para i-disable ang awtomatikong pag-save; kokopyahin na lang ang mga capture, at ipapakita sa isang preview nang 10 segundo na puwede mong panatilihin sa screen gamit ang pin button nito o ang `Ctrl + P`.

Mula sa terminal, bubuksan ng `omarchy screenshot` ang parehong overlay, at puwede mong piliin ang panimulang mode nito: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Ang pangalawang argument na `copy` o `save` ay direktang magpapadala ng shot sa destinasyong iyon. Para mag-edit bago ang output, gamitin ang `omarchy screenshot --editor=overlay` para sa isang fullscreen na editor o ang `omarchy screenshot --editor=window` para sa isang hiwalay na window.

### Pagmamaneho sa picker gamit ang keyboard

Habang nakataas ang selection, hindi mo na kailangang gumamit ng mouse kahit kailan:

| Key | Gamit |
| --- | -------- |
| `S` | I-toggle ang scrolling-region mode |
| `Super + Arrow keys` | Gumalaw sa pagitan ng mga window sa Window mode |
| `Return` | Kunan ang naka-highlight na window |
| `Ctrl + A` | Kunan ang buong nakatutok na monitor |
| `R` | Ibalik ang huling rehiyong iginuhit sa session na ito |
| `Esc` | I-dismiss ang Omasnap |

Umiiral lang ang mga binding na ito habang bukas ang Omasnap, kaya hindi sila makakabangga ng kahit ano sa sarili mong config.

## Pagre-record ng screen

Bubuksan ng `Alt + Print Screen` ang _Trigger > Capture > Screenrecord_, na magtatanong kung ano ang gusto mo sa soundtrack: walang audio, desktop audio, desktop plus microphone, o desktop plus microphone plus webcam. Lumalabas lang ang huling iyon kung may camera ka talagang nakasaksak. Pumili ng isa at hahayaan ka ng recording picker ng Omarchy na mag-drag ng rehiyon o mag-click ng window o monitor.

Tumatakbo ang pagre-record sa gpu-screen-recorder, na nag-e-encode sa GPU sa 60fps at bumabalik sa CPU kung kailangan. Ang resulta ay isang MP4 sa `~/Videos`, na pinangalanang `screenrecording-2026-08-13_14-22-05.mp4`. Itakda ang `OMARCHY_SCREENRECORD_DIR` para baguhin iyon — pero tandaan na hindi tulad ng screenshot directory, kailangan nang umiral ito, kung hindi ay tatangging magsimula ang recording.

Habang nagre-record ka, may maliit na indicator na lalabas sa bar. I-click ito para huminto. Puwede ka ring huminto gamit ulit ang `Alt + Print Screen`, o gamit ang entry na _Stop Screenrecording_ sa ilalim ng _Trigger > Capture > Screenrecord_, na lumalabas lang habang may aktwal na nagre-record.

May kaunting paglilinis ang paghinto bago nito ibigay sa iyo ang file: tini-trim ang unang frame, at kung may audio, nino-normalize ito sa -14 LUFS habang naka-mute ang pop ng PipeWire capture sa pinakasimula. Pagkatapos ay lalabas ang isang notification na may thumbnail mula sa recording. I-click ito para i-play ang file sa Omaview.

### Ang webcam overlay

Kapag nag-record ka gamit ang isang webcam, lalabas ang camera bilang isang naka-pin, naka-crop na portrait window sa ibabang-kanang sulok ng anumang nire-record mo. Kung nakapatong ito sa isang bagay na kailangan mo, i-resize ito habang tumatakbo:

| Hotkey | Gamit |
| ------ | -------- |
| `Super + Alt + [` | Paliitin ang webcam overlay |
| `Super + Alt + ]` | Palakihin ang webcam overlay |

May tatlong laki — maliit, katamtaman, at malaki — at humahakbang ang mga hotkey sa pagitan nila. Katamtaman ang default. Proporsyonal sila sa recording, kaya sinasakop ng camera ang parehong bahagi ng frame kahit nagre-record ka ng 1080p na monitor o ng 6K. At kung nag-record ka ng isang rehiyon sa halip na buong display, naka-anchor ang overlay sa sulok ng rehiyong iyon sa halip na sa monitor, kaya nananatili ito sa loob ng shot.

Puwede mo rin itong tawagin nang direkta gamit ang `omarchy-capture-webcam-resize small`, o `reset` para bumalik sa katamtaman.

## Teksto, mga QR code, at mga kulay

Pumipili ang `Super + Ctrl + Print Screen` ng isang rehiyon at ini-OCR ito papunta sa clipboard. Maayos iyong tinalakay sa [Pagkuha ng Teksto at Diktasyon](11-text-extraction-dictation.md).

Ginagawa ng _Trigger > Capture > QR Code_ ang parehong trick para sa mga QR code. Piliin ang rehiyong may code, at mapupunta ang na-decode na value sa clipboard. Mga QR code lang ang hinahanap nito — may ugali ang dense na screen content na mag-false-positive bilang barcode kung hindi. Mahalagang malaman: mapupunta ang na-decode na value sa clipboard at wala nang iba pa. Hindi ito nipi-print, hindi ito nasa notification, at minarkahan itong sensitive kaya hindi ito mananatili sa [kasaysayan ng clipboard](08-unified-clipboard-history.md). Karaniwang may dalang mga secret ang mga QR code — halimbawa, ang `otpauth://` URI sa likod ng isang 2FA setup code — at ayaw mong mapunta iyon sa isang log. Gumagana pa rin nang maayos ang pag-paste.

Ginagawa ng `Super + Print Screen` (o _Trigger > Capture > Color_) na eyedropper ang cursor. I-click ang kahit ano sa screen at mapupunta ang kulay sa clipboard. Pindutin ulit ang hotkey para umatras nang hindi pumipili.

## Pag-transcode bago ka magbahagi

Madalas na masyadong malaki para basta na lang ipadala ang isang 4K na screen recording o isang raw na HEIC mula sa phone mo. Inaayos iyan ng `Super + Ctrl + .` (o _Trigger > Transcode_). Bibigyan ka nito ng isang fuzzy file picker sa `~/Pictures` at `~/Videos`, pagkatapos ay magtatanong ng format at laki.

Napupunta ang mga larawan sa jpg o png sa high, medium, o low, na naglilimita sa lapad sa 3160, 2160, at 1080 pixels. Napupunta ang mga video sa mp4 o isang animated gif sa 4k, 1080p, o 720p. Isinusulat ang na-convert na file sa tabi ng orihinal na may resolution sa pangalan — `demo-1080p.mp4` — at kinokopya ang path sa clipboard bilang isang file URI, kaya puwede mo itong i-paste nang direkta sa isang app na tumatanggap ng mga file drop.

Gumagana rin ito mula sa terminal, kung alam mo na kung ano ang gusto mo: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Mayroon ding `omarchy transcode ascii`, na ginagawang ASCII art ang isang larawan — pangunahin iyon para sa [branding](41-branding.md).

## Pagpapadala nito kung saan

Kapag nakuha mo na ang file, bubuksan ng `Super + Ctrl + S` ang Share menu at ipapadala ito sa ibang device sa network mo sa pamamagitan ng LocalSend. Tingnan ang [mga GUI](22-guis.md) para doon.
