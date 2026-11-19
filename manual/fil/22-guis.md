# Mga GUI

## Files

Ang Files (Nautilus) ang graphical na file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan ito ng `Super + Shift + Alt + F` sa directory na kinaroroonan ng terminal mo, na nakakatipid ng maraming pag-click. Hinahayaan ka ng `Ctrl + L` na mag-type ng path, at ang pagpindot ng `Space` sa anumang file ay nagbibigay sa iyo ng mabilis na preview nang hindi nagbubukas ng kahit ano.

Isaksak mo ang isang USB stick o SD card at awtomatikong mai-mount ito, kaya lalabas lang ito sa sidebar. Para sa anumang mas masalimuot — pag-format ng drive, pagsuri sa kalusugan ng SMART, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang pag-double-click sa mga makatwirang default: bumubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, ang Markdown sa Omawrite, at ang plain text sa editor na pinili sa ilalim ng _Setup > Default > Editor_.

## Disktree

Kapag napuno na ang drive at wala kang ideya kung ano ang kumakain dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical na treemap ng home directory mo. Mas malalaking bloke ang sumasakop ng mas maraming espasyo; pumasok sa mga directory gamit ang keyboard o mouse, markahan kung ano ang dapat alisin, at suriin ang mga pinili mo bago mag-alis ng kahit ano. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubos na napapalawak na application para sa pagkuha ng tala na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng isang [komersyal na add-on para sa pag-sync](https://obsidian.md/sync) kasama ang mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para gamitin ang theme syncing, dapat mong piliin ang temang `Omarchy` sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay sariling napakasimpleng Markdown writing app ng Omarchy. Walang vaults, walang plugins, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang pangunahing tool para sa pag-edit ng larawan na mahusay para sa pag-crop, pag-resize, at iba pang pangunahing pagmamanipula. Huwag lang umasa ng alternatibo sa Photoshop. Pero mayroon pa rin itong Magic Wand at layers!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na tema ang mga ito. Ito ang pinakamadaling paraan para [gumawa ng sarili mong tema](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya maaari kang magpadala ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Maaari mong buksan ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa menu ng Omarchy. Nagbibigay ito sa iyo ng apat na opsyon:

- Nagpapadala ang **Clipboard** ng anumang kinopya mo bilang text file. Mahusay para mailagay ang isang link o snippet sa telepono mo nang hindi nag-e-email sa sarili mo.
- Nagbubukas ang **File** ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- Nagpapadala ang **Folder** ng buong directory.
- Binubuksan ng **Receive** ang LocalSend mismo para makapagpadala sa iyo ang ibang device ng isang bagay.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Alisin ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Nautilus at piliin ang _Send via LocalSend_.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa isang bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, presentations, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga dokumentong Word na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang Markdown file na kasama sa tabi nito ang mga larawan at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide ayon sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Nakukuha pa nito ang tema mong Omarchy.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at sagutan ang mga ito. Ilagay ang na-save mong lagda, teksto, at petsa ngayon kahit saan sa isang pahina, pagkatapos ay mag-save ng pinirmahang kopya sa tabi ng orihinal. Tingnan ang [Pagsagot sa mga PDF](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Game Vibes

Ang Game Vibes, sa application launcher (`Super + Space`), ay kung saan naroon ang maliliit na laro ng Omarchy: Checkmate, isang 3D na larong chess laban sa isang kaibigan o sa built-in na kalaban; Cards, Klondike solitaire; at Neon Swarm, isang arcade shooter. Bawat isa ay isang web page na sumusunod sa tema mo. Pumili ng isa gamit ang mga arrow at `Enter`, at bumalik sa listahan gamit ang `Esc` mula sa title screen ng isang laro o `Q` habang naka-pause ito. Bumubukas ito nang full screen: ginagawa itong window ng `Super + F`, at isinasara ito ng `Super + W`.

Lumilitaw rin dito ang mga larong ginagawa mo kasama ang isang agent: piliin ang _Make something cool → Game_ sa agents panel at ilarawan ang isa, o pangalanan ang isang larong nasa Game Vibes na para patuloy na gawin ito. Kinokopya ito ng agent sa `~/Games/vibes`, kung saan sa iyo ito para baguhin, at binubuksan ito kapag tapos na. Maaari mong gawin ang kopyang iyon nang mag-isa gamit ang `omarchy games vibes copy <game>`. Ang larong ibinahagi ng ibang tao ay nag-i-install tulad ng isang tema: piliin ang _Install > Gaming > Game Vibes_ at i-paste ang git address nito, o patakbuhin ang `omarchy games vibes install <git-repo-url>`. Inaalis ulit ng _Remove > Gaming_ ang isa, at kumukuha ng mga bagong bersyon ang _Update > Game Vibes Games_. Naglo-load ang mga laro ng three.js mula sa web, kaya kailangan nila ng koneksyon para magsimula.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay sariling napakasimpleng calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang nanguna sa E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gustong hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang pagkakataong pindutin mo iyon, aalukin ka ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa menu ng Omarchy).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ay sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa mga larawan, video, at musika mo. Magbukas ng larawan at hahakbang ang mga arrow key sa natitira sa folder nito, ginagawa ito ng `N` at `P` para sa kahit ano, at ipinapakita ng `Ctrl + M` ang buong folder bilang grid. Ipinapakita rin nito ang mga larawang HEIC, AVIF, at JPEG XL, at nagpapatuloy kung saan ka tumigil sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, `Ctrl + P` para mag-print ng larawan, at `Delete` para ilipat ang isang file sa Trash (ibabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o i-double-click lang ang isang larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, mas mahusay ito kaysa magbukas ng buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang camera at microphone mo nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at ulit para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live na microphone meter para masuri mo ang levels mo bago ka magsimula.

Itigil ang take at agad itong bumubukas sa isang built-in na editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang MP4. Pananatilihin ang orihinal mong recording hanggang sa itapon mo ito, kaya maaari kang palaging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
