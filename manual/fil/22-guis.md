# Mga GUI

## Files

Ang Files (Nautilus) ay ang graphical na tagapamahala ng file. Binubuksan ito ng `Super + Shift + F`, at binubuksan naman ito ng `Super + Shift + Alt + F` sa direktoryong kinaroroonan ng terminal mo, kaya malaki ang matitipid mong pag-click. Hinahayaan ka ng `Ctrl + L` na mag-type ng path, at ang pagpindot ng `Space` sa anumang file ay magbibigay sa iyo ng mabilis na preview nang hindi nagbubukas ng kahit ano.

Isaksak mo ang isang USB stick o SD card at awtomatiko itong mai-mount, kaya lilitaw na lang ito sa sidebar. Para sa anumang mas masalimuot — pag-format ng drive, pagsuri sa kalusugan ng SMART, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang pag-double-click sa mga makatwirang default: bumubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, ang Markdown sa Omawrite, at ang plain text sa editor na pinili sa ilalim ng _Setup > Default > Editor_.

## Disktree

Kapag napuno ang drive at wala kang ideya kung ano ang kumakain dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical na treemap ng home directory mo. Mas malaking espasyo ang kinukuha ng mas malalaking block; pumasok sa mga direktoryo gamit ang keyboard o mouse, markahan kung ano ang dapat alisin, at suriin ang mga pinili mo bago mag-alis ng kahit ano. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubhang napapalawak na application para sa pagkuha ng tala na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [komersyal na add-on para sa pag-sync](https://obsidian.md/sync) sa mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para magamit ang pag-sync ng tema, dapat mong piliin ang temang `Omarchy` sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay ang sariling napakasimpleng Markdown writing app ng Omarchy. Walang vault, walang plugin, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang pangunahing tool para sa pag-edit ng larawan na mahusay para sa pag-crop, pag-resize, at iba pang pangunahing pagmamanipula. Huwag ka lang umasa ng alternatibo sa Photoshop. Pero mayroon pa rin itong Magic Wand at mga layer!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na tema ang mga ito. Ito ang pinakamadaling paraan para [gumawa ng sarili mong tema](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya makakapagpadala ka ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Maaari mong buksan ang menu na Share sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa menu ng Omarchy. Nagbibigay ito sa iyo ng apat na opsyon:

- **Clipboard** ipinapadala ang anumang kinopya mo bilang isang text file. Mahusay ito para mailagay ang isang link o snippet sa telepono mo nang hindi nagpapadala ng email sa sarili mo.
- **File** nagbubukas ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- **Folder** ipinapadala ang isang buong direktoryo.
- **Receive** binubuksan ang LocalSend mismo para makapagpadala sa iyo ang ibang device ng isang bagay.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwanan mo ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Nautilus at piliin ang _Send via LocalSend_.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa isang bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, mga presentation, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga dokumentong Word na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay ang sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang solong Markdown file na katabi ang mga larawan at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide ayon sa pagkakasunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinukuha pa nito ang tema mong Omarchy.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay ang sariling napakasimpleng paraan ng Omarchy para lumagda sa mga PDF at punan ang mga ito. Ilagay ang iyong naka-save na pirma, teksto, at petsa ngayon kahit saan sa isang pahina, pagkatapos ay mag-save ng nilagdaang kopya sa tabi ng orihinal. Tingnan ang [Pagpupuno ng mga PDF](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Checkmate

Ang [Checkmate](https://github.com/omacom/checkmate) ay ang sariling 3D chess game ng Omarchy. Laruin ang isang kaibigan sa parehong computer o ang built-in na kalaban sa tatlong antas, sa apat na inukit na set na bawat isa ay gumagalaw sa sarili nitong paraan: orbital craft, inukit na kahoy at ivory, mga nilalang sa kakahuyan, at candy. Walang orasan ang mga laro at nagse-save pagkatapos ng bawat galaw.

Sinisimulan mo ang Checkmate sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay ang sariling napakasimpleng calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang tagapanguna ng E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gustong hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang pagkakataong pindutin mo iyon, iaalok sa iyo ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa menu ng Omarchy).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ay ang sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa mga larawan, video, at musika mo. Magbukas ng larawan at dadaan ang mga arrow key sa natitira sa folder nito, ginagawa ito ng `N` at `P` para sa anumang bagay, at ipinapakita ng `Ctrl + M` ang buong folder bilang isang grid. Ipinapakita rin nito ang mga larawang HEIC, AVIF, at JPEG XL, at ipinagpapatuloy kung saan ka tumigil sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, `Ctrl + P` para mag-print ng larawan, at `Delete` para ilipat ang isang file sa Trash (ibinabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o i-double-click lang ang isang larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay ang sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, mas mahusay ito kaysa magbukas ng buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay ang sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang camera at mikropono mo nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live na microphone meter para masuri mo ang mga level mo bago ka magsimula.

Itigil ang take at bubukas ito kaagad sa isang built-in na editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang isang MP4. Mananatili ang orihinal mong recording hanggang sa itapon mo ito, kaya maaari kang laging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
