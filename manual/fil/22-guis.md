# Mga GUI

## Files

Ang Files (Nautilus) ang graphical na file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan naman ito ng `Super + Shift + Alt + F` sa directory kung nasaan ang terminal mo, kaya malaki ang matitipid mo sa pag-click. Sa `Ctrl + L`, makapagta-type ka ng path, at kapag pinindot mo ang `Space` sa anumang file, makakakuha ka ng mabilis na preview nang hindi nagbubukas ng kahit ano.

Isaksak mo ang isang USB stick o isang SD card at awtomatiko itong mai-mount, kaya lalabas na lang ito sa sidebar. Para sa anumang mas masalimuot — pag-format ng drive, pagsuri sa SMART health, paglikha ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Makatuwiran ang sinusunod na mga default ng pag-double-click: bumubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, ang Markdown sa Omawrite, at ang plain text sa editor na pinili sa ilalim ng _Setup > Default > Editor_.

## Disktree

Kapag napuno ang drive at wala kang ideya kung ano ang kumakain dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Nagpapakita ito ng graphical na treemap ng home directory mo. Mas maraming espasyo ang kinukuha ng mas malalaking block; pumasok sa mga directory gamit ang keyboard o mouse, markahan kung ano ang dapat alisin, at suriin ang mga pinili mo bago mag-alis ng kahit ano. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubos na napapalawak na application sa pagkuha ng tala na gumagamit ng mga simpleng Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, komersyal, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [komersyal na add-on para sa pag-sync](https://obsidian.md/sync) sa mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para magamit ang theme syncing, kailangan mong piliin ang `Omarchy` theme sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ang sariling napakasimpleng Markdown writing app ng Omarchy. Walang mga vault, walang mga plugin, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang pangunahing tool sa pag-edit ng larawan na mahusay para sa pag-crop, pag-resize, at iba pang pangunahing pagmamanipula. Huwag ka lang umasa ng alternatibo sa Photoshop. Pero mayroon pa rin itong Magic Wand at mga layer!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawing kumpleto at magkakaugnay na theme ang mga ito. Ito ang pinakamadaling paraan para [gumawa ng sarili mong theme](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa iba pang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya makapagpapadala ka ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre sa Linux.

Mabubuksan mo ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa menu ng Omarchy. Binibigyan ka nito ng apat na opsyon:

- Ipinapadala ng **Clipboard** bilang text file ang anumang kinopya mo. Mahusay ito para mailagay ang isang link o snippet sa telepono mo nang hindi nag-e-email sa sarili mo.
- Binubuksan ng **File** ang isang file picker kung saan makakapili ka ng ilan nang sabay-sabay.
- Ipinapadala ng **Folder** ang isang buong directory.
- Binubuksan ng **Receive** ang LocalSend mismo para makapagpadala sa iyo ang ibang device ng isang bagay.

Gumagana rin ang parehong bagay mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwanan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Nautilus at piliin ang _Send via LocalSend_.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa isang bagong install. Tingnan ang [security](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, mga presentation, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga dokumentong Word na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ang sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang Markdown file na nasa tabi nito ang mga larawan at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide ayon sa pagkakasunod-sunod, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinukuha pa nito ang Omarchy theme mo.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ang sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at sagutan ang mga ito. Ilagay ang na-save mong signature, text, at petsa ngayon kahit saan sa isang page, pagkatapos ay mag-save ng pinirmahang kopya sa tabi ng orihinal. Tingnan ang [Filling out PDFs](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Checkmate

Ang [Checkmate](https://github.com/omacom/checkmate) ang sariling 3D chess game ng Omarchy. Laruin ang isang kaibigan sa parehong computer o ang built-in na kalaban sa tatlong antas, sa apat na inukit na set na bawat isa ay gumagalaw sa sarili nitong paraan: orbital craft, inukit na kahoy at ivory, mga nilalang sa kakahuyan, at candy. Walang orasan ang mga laro at nagse-save pagkatapos ng bawat galaw.

Sinisimulan mo ang Checkmate sa pamamagitan ng application launcher (`Super + Space`), kung saan nakalista ito bilang Chess. Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Cards

Ang [Cards](https://github.com/omacom/cards) ang sariling Klondike solitaire ng Omarchy. Bumunot ng tatlo, nang walang limitasyon sa mga pass, sa apat na serye ng baraha: isa ang iginuhit sa mga kulay ng theme mo, at tatlo ang may sariling hitsura. I-click ang isang baraha at pagkatapos ay kung saan ito pupunta, i-drag ito, o i-double-click para ipadala ito sa pinakamagandang lugar. Nagse-save ang mga laro pagkatapos ng bawat galaw.

Sinisimulan mo ang Cards sa pamamagitan ng application launcher (`Super + Space`). I-click ang pangalan nito, o pindutin ang `?`, para makita ang bawat shortcut.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ang sariling napakasimpleng calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ang nanguna sa E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gugustuhing hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang beses na pindutin mo iyon, aalukin ka ng Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa menu ng Omarchy).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ang sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa mga larawan, video, at musika mo. Magbukas ng larawan at ang mga arrow key ang magpapalipat-lipat sa natitira sa folder nito, ginagawa ito ng `N` at `P` para sa anumang bagay, at ipinapakita ng `Ctrl + M` ang buong folder bilang grid. Ipinapakita rin nito ang mga larawang HEIC, AVIF, at JPEG XL, at itinutuloy kung saan ka huminto sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, ang `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, ang `Ctrl + P` para mag-print ng larawan, at ang `Delete` para ilipat ang isang file sa Trash (ibabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o mag-double-click na lang ng larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ang sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, tatalunin nito ang pagbubukas ng isang buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ang sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang camera at microphone mo nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng camera mo, na may live na microphone meter para masuri mo ang levels mo bago ka magsimula.

Itigil ang take at bubuksan ito agad sa isang built-in na editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang MP4. Mananatili ang orihinal mong recording hanggang sa itapon mo ito, kaya palagi kang makakabalik at makakaputol nito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
