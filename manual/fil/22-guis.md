# GUIs

## Files

Ang Files (Folio) ay ang graphical file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan ito ng `Super + Shift + Alt + F` sa directory kung nasaan ang terminal mo, na nakakatipid sa maraming pag-click. Hinahayaan ka ng `Ctrl + L` na mag-type ng path, at ang pagpindot ng `Space` sa anumang file ay nagpapakita nito nang buong laki nang hindi ito binubuksan.

Magsaksak ka ng USB stick o SD card at awtomatikong ma-mount ito, kaya lalabas na lang ito sa sidebar. Para sa anumang mas maselan — pag-format ng drive, pag-check ng SMART health, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang double-clicking sa mga makatwirang default: nagbubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, ang Markdown sa Omawrite, at ang plain text sa editor mo, Plain maliban kung pipili ka ng iba sa ilalim ng _Setup > Defaults > Editor_.

## Disktree

Kapag napupuno ang drive at wala kang ideya kung ano ang kumakain dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical treemap ng home directory mo. Mas maraming space ang sinasakop ng mas malalaking block; pasukin ang mga directory gamit ang keyboard o mouse, markahan ang dapat alisin, at suriin ang mga pinili mo bago mag-alis ng anuman. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubos na napapalawak na note taking application na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [commercial add-on para sa syncing](https://obsidian.md/sync) sa mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para magamit ang theme syncing, dapat mong piliin ang `Omarchy` theme sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay ang sariling napakasimpleng Markdown writing app ng Omarchy. Walang vaults, walang plugins, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang pangunahing image editing tool na mahusay para sa cropping, resizing, at iba pang pangunahing pagmamanipula. Huwag ka lang umasa ng alternatibo sa Photoshop. Pero mayroon pa rin itong Magic Wand at layers!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na theme ang mga ito. Ito ang pinakamadaling paraan para [gumawa ng sarili mong theme](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya maaari kang magpadala ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Maaari mong buksan ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa Omarchy menu. Nagbibigay ito sa iyo ng apat na opsyon:

- Ipinapadala ng **Clipboard** ang anumang kinopya mo bilang text file. Mahusay para mailagay ang isang link o snippet sa telepono mo nang hindi nag-e-email sa sarili mo.
- Nagbubukas ang **File** ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- Ipinapadala ng **Folder** ang isang buong directory.
- Binubukas ng **Receive** ang LocalSend mismo para makapagpadala sa iyo ang isa pang device ng isang bagay.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Files at ibahagi ito gamit ang LocalSend.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa isang bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, presentations, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya ito ay isang mahusay na paraan para mabuksan ang mga Word document na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay ang sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang solong Markdown file na katabi ang mga image at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinukuha pa nito ang Omarchy theme mo.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay ang sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at punan ang mga ito. Ilagay ang na-save mong signature, text, at petsa ngayon kahit saan sa isang page, pagkatapos ay mag-save ng signed copy sa tabi ng orihinal. Tingnan ang [Pagpupuno ng mga PDF](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Game Vibes

Ang Game Vibes, sa application launcher (`Super + Space`), ay kung saan naroon ang maliliit na laro ng Omarchy: Checkmate, isang 3D chess game laban sa isang kaibigan o sa built-in na kalaban; Cards, Klondike solitaire; Death Wish, isang pixel-precise platformer ng sampung kuwartong puno ng spikes at saws; at Neon Swarm, isang arcade shooter. Ang bawat isa ay isang solong web page na sumusunod sa theme mo. Pumili ng isa gamit ang mga arrow at `Enter`, at bumalik sa listahan gamit ang `Esc` mula sa title screen ng isang laro o `Q` habang naka-pause ito. Nagbubukas ito nang full screen: ginagawa itong window ng `Super + F`, at isinasara ito ng `Super + W`.

Lumilitaw din dito ang mga larong ginagawa mo gamit ang isang agent: piliin ang _Make something cool → Game_ sa agents panel at ilarawan ang isa, o pangalanan ang isang larong nasa Game Vibes na para patuloy na pagtrabahuhan ito. Kinokopya ito ng agent sa `~/Games/vibes`, kung saan sa iyo na itong baguhin, at binubuksan ito kapag tapos na. Magagawa mo mismo ang kopyang iyon gamit ang `omarchy games vibes copy <game>`. Ang isang larong ibinabahagi ng ibang tao ay nag-i-install tulad ng isang theme: piliin ang _Install > Gaming > Game Vibes_ at i-paste ang git address nito, o patakbuhin ang `omarchy games vibes install <git-repo-url>`. Inaalis ulit ng _Remove > Gaming_ ang isa, at kumukuha ang _Update > Game Vibes Games_ ng mga bagong version. Naglo-load ang mga laro ng three.js mula sa web, kaya kailangan nila ng koneksyon para magsimula.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay ang sariling napakasimpleng calculator ng Omarchy, na nagbubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang tagapanguna ng E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gugustuhing hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang pagkakataong pindutin mo iyon, aalukin ka ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa Omarchy menu).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ay ang sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa mga photo, video, at musika mo. Magbukas ng isang photo at hahakbang ang mga arrow key sa natitira sa folder nito, ginagawa ito ng `N` at `P` para sa anuman, at ipinapakita ng `Ctrl + M` ang buong folder bilang isang grid. Ipinapakita rin nito ang mga HEIC, AVIF, at JPEG XL photo, at nagpapatuloy kung saan ka tumigil sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, `Ctrl + P` para mag-print ng larawan, at `Delete` para ilipat ang isang file sa Trash (ibinabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o mag-double-click na lang ng isang larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay ang sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, tinatalo nito ang pagbukas ng isang buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay ang sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang camera at microphone mo nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para mag-pause at magpatuloy sa parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live microphone meter para ma-check mo ang levels mo bago ka magsimula.

Itigil ang take at magbubukas ito kaagad sa isang built-in editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging hindi mo gusto. Pagkatapos ay i-save ito bilang MP4. Pinapanatili ang orihinal mong recording hanggang sa itapon mo ito, kaya maaari kang laging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
