# GUIs

## Files

Ang Files (Nautilus) ang graphical file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan ito ng `Super + Shift + Alt + F` sa directory kung nasaan ang terminal mo, kaya malaki ang matitipid mo sa pag-click. Hinahayaan ka ng `Ctrl + L` na mag-type ng path, at ang pagpindot ng `Space` sa anumang file ay magbibigay sa iyo ng mabilis na preview nang hindi nagbubukas ng kahit ano.

Magsaksak ng USB stick o SD card at awtomatiko itong mai-mount, kaya lalabas na lang ito sa sidebar. Para sa anumang mas masalimuot — pag-format ng drive, pagsuri ng SMART health, paglikha ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang double-click sa mga makatwirang default: nagbubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, at ang plain text sa Neovim.

## Disktree

Kapag napuno na ang drive at wala kang ideya kung ano ang kumakain dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical treemap ng iyong home directory. Mas maraming espasyo ang kinukuha ng mas malalaking block; pumasok sa mga directory gamit ang keyboard o mouse, markahan ang dapat nang alisin, at suriin ang iyong mga pinili bago mag-alis ng kahit ano. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubhang napapalawak na application para sa pagkuha ng mga tala na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [komersyal na add-on para sa pag-sync](https://obsidian.md/sync) sa mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para magamit ang theme syncing, kailangan mong piliin ang temang `Omarchy` sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay ang sariling napakasimpleng Markdown writing app ng Omarchy. Walang mga vault, walang mga plugin, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang pangunahing tool sa pag-edit ng larawan na mahusay para sa pag-crop, pag-resize, at iba pang pangunahing manipulasyon. Huwag ka lang umasa ng alternatibo sa Photoshop. Pero mayroon pa rin itong Magic Wand at mga layer!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na tema ang mga ito. Ito ang pinakamadaling paraan para [gumawa ng sarili mong tema](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya maaari kang magpadala ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre sa Linux.

Maaari mong buksan ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa menu ng Omarchy. Binibigyan ka nito ng apat na opsyon:

- Nagpapadala ang **Clipboard** ng anumang kinopya mo bilang text file. Mahusay para mailagay ang isang link o snippet sa iyong telepono nang hindi nag-e-email sa sarili mo.
- Nagbubukas ang **File** ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- Nagpapadala ang **Folder** ng isang buong directory.
- Binubuksan ng **Receive** ang LocalSend mismo para makapagpadala sa iyo ng isang bagay ang isa pang device.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwanan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Nautilus at piliin ang _Send via LocalSend_.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad-agad sa isang bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, mga presentation, drawing application, at iba pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga Word document na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay ang sariling napakasimpleng presentation app ng Omarchy. Ang iyong deck ay isang solong Markdown file na katabi ang mga larawan at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinukuha pa nito ang tema mo sa Omarchy.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay ang sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at sagutan ang mga ito. Ilagay ang iyong naka-save na lagda, teksto, at petsa ngayon saanman sa isang pahina, pagkatapos ay mag-save ng nilagdaang kopya sa tabi ng orihinal. Tingnan ang [Pagsagot sa mga PDF](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay ang sariling napakasimpleng calculator ng Omarchy, na nagbubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang tagapanguna ng E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gugustuhing hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang pagkakataong pindutin mo iyon, iaalok sa iyo ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa menu ng Omarchy).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ay ang sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa iyong mga larawan, video, at musika. Magbukas ng larawan at dadaan ang mga arrow key sa iba pang nasa folder nito, ginagawa ito ng `N` at `P` para sa kahit ano, at ipinapakita ng `Ctrl + M` ang buong folder bilang isang grid. Ipinapakita rin nito ang mga larawang HEIC, AVIF, at JPEG XL, at nagpapatuloy kung saan ka huminto sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, ang `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, ang `Ctrl + P` para mag-print ng larawan, at ang `Delete` para ilipat ang isang file sa Trash (ibabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o i-double-click lang ang isang larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay ang sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, daig nito ang pagbubukas ng isang buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay ang sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang iyong camera at mikropono nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng iyong camera, na may live microphone meter para masuri mo ang iyong mga level bago ka magsimula.

Itigil ang take at magbubukas ito agad sa isang built-in editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang isang MP4. Mananatiling naka-save ang iyong orihinal na recording hanggang sa itapon mo ito, kaya maaari kang laging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
