# GUIs

## Mga File

Ang Files (Nautilus) ay ang graphical na file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan ito ng `Super + Shift + Alt + F` sa directory na kinaroroonan ng terminal mo, kaya makakatipid ka sa maraming pag-click. Hinahayaan ka ng `Ctrl + L` na mag-type ng path, at ang pagpindot ng `Space` sa anumang file ay nagbibigay sa iyo ng mabilis na preview nang hindi nagbubukas ng kahit ano.

Isaksak mo ang isang USB stick o isang SD card at awtomatiko itong mai-mount, kaya lalabas na lang ito sa sidebar. Para sa anumang mas masalimuot — pag-format ng drive, pagsuri ng SMART health, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang double-click sa mga makatwirang default: bumubukas ang mga image sa imv, ang video sa mpv, ang mga PDF sa Document Viewer, at ang plain text sa Neovim.

## Disktree

Kapag napuno ang drive at wala kang ideya kung ano ang kumakain nito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical na treemap ng home directory mo. Mas maraming space ang sinasakop ng mas malalaking block; pasukin ang mga directory gamit ang keyboard o mouse, markahan ang dapat alisin, at suriin ang mga napili mo bago mag-alis ng kahit ano. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubos na napapalawak na note taking application na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [commercial add-on para sa pag-sync](https://obsidian.md/sync) sa mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para gamitin ang theme syncing, kailangan mong piliin ang `Omarchy` theme sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay sariling napakasimpleng Markdown writing app ng Omarchy. Walang mga vault, walang mga plugin, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang basic na image editing tool na mahusay para sa pag-crop, pag-resize, at iba pang basic na manipulation. Huwag lang umasa ng alternatibo sa Photoshop. Pero mayroon pa rin itong Magic Wand at mga layer!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na theme ang mga ito. Ito ang pinakamadaling paraan para [gumawa ng sarili mong theme](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya makakapagpadala ka ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Maaari mong buksan ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa Omarchy menu. Nagbibigay ito sa iyo ng apat na opsyon:

- **Clipboard** ang nagpapadala ng anumang kinopya mo bilang isang text file. Mahusay para mailagay ang isang link o isang snippet sa telepono mo nang hindi nag-e-email sa sarili mo.
- **File** ang nagbubukas ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- **Folder** ang nagpapadala ng buong directory.
- **Receive** ang nagbubukas mismo ng LocalSend para makapagpadala sa iyo ang ibang device ng isang bagay.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwanan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang direkta mula sa file manager: i-right-click ang anumang napili sa Nautilus at piliin ang _Send via LocalSend_.

Nakasara ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, presentations, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga Word document na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang solong Markdown file na katabi ang mga image at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinukuha pa nito ang Omarchy theme mo.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at sagutan ang mga ito. Ilagay ang naka-save mong signature, text, at petsa ngayon kahit saan sa isang page, pagkatapos ay mag-save ng nilagdaang kopya katabi ng orihinal. Tingnan ang [Pagsagot sa mga PDF](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay sariling napakasimpleng calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang nanguna sa E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gustong hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang beses na pindutin mo iyon, aalukin ka ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa Omarchy menu).

## mpv

Ang [mpv](https://mpv.io/) ay isang simple at mabilis na media player na magpe-play ng halos kahit ano mula sa anumang source. Mahusay para sa panonood ng mga video.

Sinisimulan mo ang mpv sa pamamagitan ng application launcher (`Super + Space`) o mag-double-click lang ng isang video sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, mas mahusay ito kaysa magbukas ng buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang camera at microphone mo nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live microphone meter para masuri mo ang mga level mo bago ka magsimula.

Itigil ang take at bubukas ito kaagad sa isang built-in editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang isang MP4. Mananatili ang orihinal mong recording hanggang sa itapon mo ito, kaya maaari kang bumalik palagi at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
