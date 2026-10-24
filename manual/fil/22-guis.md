# Mga GUI

## Files

Ang Files (Nautilus) ay ang graphical file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan ito ng `Super + Shift + Alt + F` sa direktoryong kinaroroonan ng terminal mo, na nakakatipid ng maraming pag-click. Nagbibigay-daan sa iyo ang `Ctrl + L` na mag-type ng path, at ang pagpindot ng `Space` sa anumang file ay nagbibigay sa iyo ng mabilis na preview nang hindi nagbubukas ng anuman.

Magsaksak ng USB stick o SD card at awtomatiko itong ima-mount, kaya lalabas na lang ito sa sidebar. Para sa anumang mas masalimuot — pag-format ng drive, pagsuri ng SMART health, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang double-clicking sa mga makatwirang default: ang mga larawan ay bumubukas sa imv, ang video sa mpv, ang mga PDF sa Document Viewer, at ang plain text sa Neovim.

## Disktree

Kapag napuno ang drive at wala kang ideya kung ano ang kumakain nito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical treemap ng iyong home directory. Mas maraming espasyo ang kinukuha ng mas malalaking block; pumasok sa mga direktoryo gamit ang keyboard o mouse, markahan kung ano ang dapat alisin, at suriin ang iyong mga pinili bago magtanggal ng anuman. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at napaka-extensible na note taking application na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kasama ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [komersyal na add-on para sa pag-sync](https://obsidian.md/sync) gamit ang mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para gamitin ang theme syncing, dapat mong piliin ang `Omarchy` theme sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay sariling dead-simple na Markdown writing app ng Omarchy. Walang vault, walang plugin, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang basic na image editing tool na mahusay para sa cropping, resizing, at iba pang basic na manipulasyon. Huwag lang umasa ng alternatibo sa Photoshop. Pero may Magic Wand at mga layer pa rin ito!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na tema. Ito ang pinakamadaling paraan para [gumawa ng sarili mong tema](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Nagbibigay-daan sa iyo ang [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform ito, gayunpaman, kaya maaari kang magpadala ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Maaari mong buksan ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa Omarchy menu. Binibigyan ka nito ng apat na pagpipilian:

- **Clipboard** ay nagpapadala ng anumang kinopya mo bilang text file. Mahusay para makuha ang isang link o snippet sa telepono mo nang hindi nag-e-email sa sarili mo.
- **File** ay nagbubukas ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- **Folder** ay nagpapadala ng isang buong direktoryo.
- **Receive** ay nagbubukas ng LocalSend mismo para makapagpadala sa iyo ang isa pang device ng isang bagay.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang direkta mula sa file manager: i-right-click ang anumang pinili sa Nautilus at piliin ang _Send via LocalSend_.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito kaagad sa isang bagong install. Tingnan ang [security](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, mga presentasyon, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya ito ay isang mahusay na paraan para mabuksan ang mga Word document na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay sariling dead-simple na presentation app ng Omarchy. Ang deck mo ay isang solong Markdown file na may mga larawan at video nito sa tabi: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o i-export sa PDF at PowerPoint. Kinukuha pa nito ang tema ng Omarchy mo.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay sariling dead-simple na paraan ng Omarchy para pirmahan ang mga PDF at punan ang mga ito. Ilagay ang iyong na-save na lagda, teksto, at petsa ngayon saanman sa isang pahina, pagkatapos ay i-save ang isang pinirmahang kopya sa tabi ng orihinal. Tingnan ang [Filling out PDFs](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o buksan ang isang PDF gamit ito mula sa file manager.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay sariling dead-simple na calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Ctrl + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang pioneer ng E2E encrypted messaging, at isang mahusay na pagpipilian sa komunikasyon para sa sinumang mas gustong hindi dumaan sa isa sa mga malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang pagkakataong pindutin mo iyon, aalukin ka ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa Omarchy menu).

## mpv

Ang [mpv](https://mpv.io/) ay isang simple at mabilis na media player na magpapatugtog ng halos anumang bagay mula sa anumang source. Mahusay para sa panonood ng mga video.

Sinisimulan mo ang mpv sa pamamagitan ng application launcher (`Super + Space`) o i-double-click na lang ang isang video sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay sariling dead-simple na video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, mas mahusay ito kaysa magbukas ng isang buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay sariling dead-simple na webcam recorder ng Omarchy. Piliin ang iyong camera at mikropono nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at ulit para i-pause at ipagpatuloy ang parehong take. Lagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live microphone meter para masuri mo ang iyong mga level bago ka magsimula.

Itigil ang take at bumubukas ito kaagad sa isang built-in na editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging hindi mo gusto. Pagkatapos ay i-save ito bilang MP4. Pinapanatili ang orihinal mong recording hanggang sa itapon mo ito, kaya maaari kang laging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
