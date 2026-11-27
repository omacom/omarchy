# Mga GUI

## Files

Ang Files (Folio) ang graphical na file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan ito ng `Super + Shift + Alt + F` sa direktoryo kung nasaan ang terminal mo, kaya malaki ang matitipid mo sa pag-click. Hinahayaan ka ng `Ctrl + L` na mag-type ng path, at ipinapakita ng pagpindot ng `Space` sa anumang file ang preview nito sa buong laki nang hindi ito binubuksan.

Isaksak mo ang USB stick o SD card at awtomatiko itong mai-mount, kaya lalabas na lang ito sa sidebar. Para sa mas masalimuot na gawain — pag-format ng drive, pagsuri sa SMART health, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Humihingi ng password ang isang naka-encrypt na drive kapag isinaksak ito. Para mag-unlock ito nang mag-isa, magdagdag ng keyfile dito gamit ang `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` at ilagay ang keyfile na iyon sa `~/.config/omarchy/drive-keys/<UUID>`, na pinangalanan ayon sa UUID na inilalabas ng `lsblk -dno UUID /dev/sdX1` para sa naka-encrypt na partition, at ikaw lang ang makakabasa (`chmod 600`). Kung nawawala o tinanggihan ang keyfile na iyon, hihingin sa iyo ang password gaya ng dati.

Sumusunod ang pag-double-click sa mga makatwirang default: bumubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, ang Markdown sa Omawrite, at ang plain text sa editor mo, Plain maliban kung pipili ka ng iba sa ilalim ng _Setup > Defaults > Editor_.

## Disktree

Kapag napuno ang drive at wala kang ideya kung ano ang lumalamon dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Ipinapakita nito ang graphical na treemap ng home directory mo. Mas maraming espasyong kinukuha ang mas malalaking block; pasukin ang mga direktoryo gamit ang keyboard o mouse, markahan ang dapat alisin, at suriin ang mga pinili mo bago magtanggal ng anuman. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubhang napapalawak na application para sa pagkuha ng tala na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [commercial add-on para sa pag-sync](https://obsidian.md/sync) sa mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para magamit ang theme syncing, kailangan mong piliin ang temang `Omarchy` sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ang sariling napakasimpleng Markdown writing app ng Omarchy. Walang vault, walang plugin, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang basic na tool sa pag-edit ng larawan na mahusay para sa pag-crop, pag-resize, at iba pang basic na manipulasyon. Huwag lang umasa ng alternatibo sa Photoshop. Pero may Magic Wand at mga layer pa rin ito!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na nakakakuha ng mga kulay mula sa isang background image at ginagawa itong isang kumpleto at magkakaugnay na tema. Ito ang pinakamadaling paraan para [gumawa ng sarili mong tema](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya makakapagpadala ka ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Mabubuksan mo ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa Omarchy menu. Apat na opsyon ang ibinibigay nito sa iyo:

- **Clipboard** ipinapadala ang anumang kinopya mo bilang text file. Mahusay ito para mailagay ang isang link o snippet sa telepono mo nang hindi nag-e-email sa sarili mo.
- **File** nagbubukas ng file picker kung saan makakapili ka ng marami nang sabay-sabay.
- **Folder** ipinapadala ang isang buong direktoryo.
- **Receive** binubuksan ang mismong LocalSend para makapagpadala sa iyo ang ibang device ng anuman.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwanan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Files at ibahagi ito gamit ang LocalSend.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, mga presentation, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga Word document na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ang sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang Markdown file kasama ang mga larawan at video nito sa tabi: isulat ang bawat slide sa ibaba ng live preview, i-drag ang mga slide sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinukuha pa nito ang tema mong Omarchy.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ang sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at sagutan ang mga ito. Ilagay ang na-save mong lagda, text, at petsa ngayon kahit saan sa isang pahina, pagkatapos ay mag-save ng nilagdaang kopya sa tabi ng orihinal. Tingnan ang [Pagsagot sa mga PDF](27-filling-out-pdfs.md) para malaman kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Game Vibes

Ang Game Vibes, sa application launcher (`Super + Space`), ang tahanan ng maliliit na laro ng Omarchy: Checkmate, isang 3D chess game laban sa kaibigan o sa built-in na kalaban; Cards, Klondike solitaire; Death Wish, isang pixel-precise na platformer ng sampung kuwartong puno ng spike at lagari; at Neon Swarm, isang arcade shooter. Bawat isa ay isang web page na sumusunod sa tema mo. Pumili ng isa gamit ang mga arrow at `Enter`, at bumalik sa listahan gamit ang `Esc` mula sa title screen ng laro o `Q` habang naka-pause ito. Bumubukas ito nang full screen: ginagawa itong window ng `Super + F`, at isinasara ito ng `Super + W`.

Ang mga larong ginagawa mo gamit ang isang agent ay lumalabas din dito: piliin ang _Make something cool → Game_ sa panel ng mga agent at ilarawan ang isa, o pangalanan ang isang larong nasa Game Vibes na para patuloy na gawin ito. Kinokopya ito ng agent sa `~/Games/vibes`, kung saan iyo itong babaguhin, at binubuksan ito kapag tapos na. Magagawa mo mismo ang kopyang iyon gamit ang `omarchy games vibes copy <game>`. Ang larong ibinabahagi ng iba ay ini-install tulad ng tema: piliin ang _Install > Gaming > Game Vibes_ at i-paste ang git address nito, o patakbuhin ang `omarchy games vibes install <git-repo-url>`. Inaalis ulit ng _Remove > Gaming_ ang isa, at kinukuha ng _Update > Game Vibes Games_ ang mga bagong bersyon. Naglo-load ang mga laro ng three.js mula sa web, kaya kailangan nila ng koneksyon para magsimula.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ang sariling napakasimpleng calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ang nanguna sa E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gustong hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang beses mong pindutin iyon, aalukin ka ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa Omarchy menu).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ang sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa mga larawan, video, at musika mo. Magbukas ng larawan at dadalhin ka ng mga arrow key sa iba pa sa folder nito, ginagawa ito ng `N` at `P` para sa anuman, at ipinapakita ng `Ctrl + M` ang buong folder bilang grid. Ipinapakita rin nito ang mga larawang HEIC, AVIF, at JPEG XL, at tinutuloy kung saan ka tumigil sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, `Ctrl + P` para mag-print ng larawan, at `Delete` para ilipat ang file sa Trash (ibinabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o i-double-click lang ang isang larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ang sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, tatalunin nito ang pagbukas ng isang buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ang sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang camera at mikropono mo nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live na microphone meter para masuri mo ang levels mo bago ka magsimula.

Itigil ang take at bubukas ito kaagad sa isang built-in na editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang MP4. Pinapanatili ang orihinal mong recording hanggang sa itapon mo ito, kaya maaari kang laging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
