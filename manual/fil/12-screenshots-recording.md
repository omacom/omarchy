# Mga Screenshot at Recording

Lahat ng makukuha mo mula sa screen ay nakabatay sa Print Screen key. Ang isang key na mag-isa ay kukuha ng larawan, at ang mga modifier ay kukuha ng recording, ng kulay, o ng teksto sa loob ng isang region. Kung wala talagang Print Screen key ang keyboard mo, ang `Super + Ctrl + Alt + C` ay kukuha ng parehong screenshot, at ang `Super + Ctrl + C` ay magbubukas ng buong set bilang menu.

| Hotkey | Gamit |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Screenrecord (o ihinto ang tumatakbo) |
| `Super + Print Screen` | Pampili ng kulay |
| `Super + Ctrl + Print Screen` | Kunin ang teksto mula sa isang region |
| `Super + Ctrl + C` | Capture menu |
| `Super + Ctrl + .` | I-transcode ang isang larawan o video |

## Mga Screenshot

Pindutin ang `Print Screen` (o `Super + Ctrl + Alt + C`) at kukunan ng Omasnap ang nakatuong monitor bago lumabas ang overlay nito, kaya walang gagalaw sa ilalim mo habang pumupuntirya ka. Mag-drag ng freeform na region, mag-click ng window para kunan ito, o mag-click sa bakanteng puwang para kunan ang buong monitor. Pindutin ang `S` bago gumuhit para kunan ang isang scrolling region. Nagbago ang isip mo? Pindutin ulit ang parehong key para i-dismiss ang Omasnap.

Pagkatapos mong pumili ng area, ise-save ng Omasnap ang capture, kokopyahin ito sa clipboard, at magpapakita ng preview sa loob ng 10 segundo. Gamitin ang pin button ng preview o ang `Ctrl + P` para manatili ito sa screen, o piliin ang Edit para lagyan ito ng annotation.

Ang annotation editor ay puwedeng gumuhit ng mga arrow, linya, hugis, highlight, may numerong marker, teksto, at secure na redaction; mag-crop o mag-cut out ng bahagi ng larawan; mag-OCR ng teksto nito; at magdagdag ng backdrop. Sa editor, pindutin ang `Enter` para kopyahin at i-save ang tapos na PNG, ang `Ctrl + C` para kopyahin ito nang hindi sine-save, o ang `Ctrl + S` para i-save ito nang hindi kinokopya.

Ang mga na-save na screenshot ay mapupunta sa `~/Pictures/Screenshots` bilang default, na may pangalang gaya ng `screenshot-2026-08-13_14-22-05-firefox.png`. Itakda ang `OMASNAP_SCREENSHOT_DIR` para gumamit ng ibang directory — tingnan ang [ang FAQ](46-faq.md) para sa kung saan ilalagay ang mga session environment variable. Ginagawa ng Omasnap ang directory kapag sine-save nito ang unang kuha. Itakda ang `[output] autosave = false` sa `~/.config/omasnap/omasnap.conf` para i-disable ang awtomatikong pag-save.

Mula sa terminal, bubuksan ng `omarchy screenshot` ang parehong overlay, at puwede mong piliin ang panimulang mode nito: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Ang pangalawang argument na `copy` o `save` ay lalaktaw sa preview at direktang ipapadala ang kuha sa destinasyong iyon. Para mag-edit bago ang output, gamitin ang `omarchy screenshot --editor=overlay` para sa fullscreen na editor o ang `omarchy screenshot --editor=window` para sa hiwalay na window.

### Pagkontrol sa picker gamit ang keyboard

Habang nakabukas ang selection, hindi mo na kailangang gamitin ang mouse:

| Key | Gamit |
| --- | -------- |
| `S` | I-toggle ang scrolling-region mode |
| `Super + Arrow keys` | Lumipat sa pagitan ng mga window sa Window mode |
| `Return` | Kunin ang naka-highlight na window |
| `Ctrl + A` | Kunin ang buong nakatuong monitor |
| `R` | Ibalik ang huling region na iginuhit sa session na ito |
| `Esc` | I-dismiss ang Omasnap |

Ang mga binding na ito ay umiiral lamang habang nakabukas ang Omasnap, kaya hindi sila makakabangga ng anuman sa sarili mong config.

## Pag-record ng Screen

Bubuksan ng `Alt + Print Screen` ang _Trigger > Capture > Screenrecord_, na magtatanong kung ano ang gusto mo sa soundtrack: walang audio, desktop audio, desktop plus microphone, o desktop plus microphone plus webcam. Ang huli ay lalabas lamang kung may camera kang talagang nakasaksak. Pumili ng isa at hahayaan ka ng recording picker ng Omarchy na mag-drag ng region o mag-click ng window o monitor.

Tumatakbo ang recording sa gpu-screen-recorder, na nag-e-encode sa GPU sa 60fps at bumabalik sa CPU kung kailangan. Ang resulta ay isang MP4 sa `~/Videos`, na pinangalanang `screenrecording-2026-08-13_14-22-05.mp4`. Itakda ang `OMARCHY_SCREENRECORD_DIR` para baguhin iyon — pero tandaan na hindi gaya ng screenshot directory, kailangang umiral na ang isang ito, kung hindi ay tatangging magsimula ang recording.

Habang nagre-record ka, may maliit na indicator na lalabas sa bar. I-click ito para huminto. Puwede ka ring huminto gamit ang `Alt + Print Screen` ulit, o gamit ang entry na _Stop Screenrecording_ sa ilalim ng _Trigger > Capture > Screenrecord_, na lalabas lamang habang may aktwal na nagre-record.

Ang paghinto ay may kaunting paglilinis bago ibigay sa iyo ang file: tini-trim ang unang frame, at kung may audio, nino-normalize ito sa -14 LUFS habang naka-mute ang pop ng PipeWire capture sa pinakasimula. Pagkatapos ay may lalabas na notification na may thumbnail mula sa recording. I-click ito para i-play ang file sa mpv.

### Ang webcam overlay

Kapag nag-record ka gamit ang webcam, lalabas ang camera bilang isang naka-pin, naka-crop na portrait window sa ibabang kanang sulok ng anumang nire-record mo. Kung nakapatong ito sa isang bagay na kailangan mo, i-resize ito habang tumatakbo:

| Hotkey | Gamit |
| ------ | -------- |
| `Super + Alt + [` | Paliitin ang webcam overlay |
| `Super + Alt + ]` | Palakihin ang webcam overlay |

Tatlo ang laki — maliit, katamtaman, at malaki — at ang mga hotkey ay humahakbang sa pagitan ng mga ito. Katamtaman ang default. Proporsyonal sila sa recording, kaya parehong bahagi ng frame ang kinukuha ng camera kahit nagre-record ka ng 1080p na monitor o ng 6K. At kung region ang ni-record mo sa halip na buong display, ang overlay ay naka-anchor sa sulok ng region na iyon sa halip na sa monitor, kaya nananatili ito sa loob ng kuha.

Puwede mo rin itong tawagin nang direkta gamit ang `omarchy-capture-webcam-resize small`, o `reset` para bumalik sa katamtaman.

## Teksto, mga QR code, at mga kulay

Pumipili ang `Super + Ctrl + Print Screen` ng region at ini-OCR ito papunta sa clipboard. Maayos itong tinalakay sa [Pagkuha ng Teksto at Pagdidikta](11-text-extraction-dictation.md).

Ginagawa ng _Trigger > Capture > QR Code_ ang parehong trick para sa mga QR code. Piliin ang region na may code, at ang na-decode na value ay mapupunta sa clipboard. Mga QR code lamang ang hinahanap nito — ang siksik na content ng screen ay may ugaling mag-false-positive bilang barcode kung hindi. Mahalagang malaman: ang na-decode na value ay mapupunta sa clipboard at wala nang iba. Hindi ito ini-print, wala ito sa notification, at minarkahan itong sensitive kaya hindi ito mananatili sa [kasaysayan ng clipboard](08-unified-clipboard-history.md). Karaniwang may dalang mga secret ang mga QR code — ang `otpauth://` URI sa likod ng isang 2FA setup code, halimbawa — at ayaw mong mapunta iyon sa isang log. Gumagana pa rin nang maayos ang pag-paste.

Ginagawa ng `Super + Print Screen` (o _Trigger > Capture > Color_) na eyedropper ang cursor. I-click ang kahit ano sa screen at mapupunta ang kulay sa clipboard. Pindutin ulit ang hotkey para umatras nang hindi pumipili.

## Pag-transcode bago mo ibahagi

Ang isang 4K na screen recording o isang raw na HEIC mula sa phone mo ay madalas masyadong malaki para basta ipadala lang. Inaayos iyan ng `Super + Ctrl + .` (o _Trigger > Transcode_). Bibigyan ka nito ng fuzzy file picker sa `~/Pictures` at `~/Videos`, pagkatapos ay magtatanong ng format at laki.

Ang mga larawan ay nagiging jpg o png sa high, medium, o low, na naglilimita sa lapad sa 3160, 2160, at 1080 pixels. Ang mga video ay nagiging mp4 o animated gif sa 4k, 1080p, o 720p. Isinusulat ang na-convert na file sa tabi ng orihinal na may resolution sa pangalan — `demo-1080p.mp4` — at kinokopya ang path sa clipboard bilang file URI, kaya puwede mo itong i-paste nang direkta sa isang app na tumatanggap ng mga file drop.

Gumagana rin ito mula sa terminal, kung alam mo na ang gusto mo: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Mayroon ding `omarchy transcode ascii`, na ginagawang ASCII art ang isang larawan — iyon ay para karaniwan sa [pagba-brand](41-branding.md).

## Pagpapadala nito kung saan

Kapag nakuha mo na ang file, bubuksan ng `Super + Ctrl + S` ang Share menu at ipapadala ito sa ibang device sa network mo sa pamamagitan ng LocalSend. Tingnan ang [GUIs](22-guis.md) para roon.
