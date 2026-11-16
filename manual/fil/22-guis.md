# Mga GUI

## Files

Ang Files (Nautilus) ay ang graphical na file manager. Binubuksan ito ng `Super + Shift + F`, at binubuksan naman ito ng `Super + Shift + Alt + F` sa directory kung nasaan ang terminal mo, na nakakatipid sa maraming pag-click. Sa `Ctrl + L`, makakapag-type ka ng path, at ang pagpindot ng `Space` sa anumang file ay magbibigay sa iyo ng mabilis na preview nang hindi nagbubukas ng kahit ano.

Mag-plug ka ng USB stick o SD card at awtomatiko itong mai-mount, kaya lalabas na lang ito sa sidebar. Para sa anumang mas komplikado — pag-format ng drive, pagsuri sa SMART health, paggawa ng mga partition — ilunsad ang _Disks_ mula sa app launcher (`Super + Space`).

Sumusunod ang pag-double-click sa mga makatwirang default: bumubukas ang mga larawan, video, at musika sa Omaview, ang mga PDF sa Document Viewer, ang Markdown sa Omawrite, at ang plain text sa editor na pinili sa ilalim ng _Setup > Default > Editor_.

## Disktree

Kapag napuno ang drive at wala kang ideya kung ano ang kumakain dito, ilunsad ang [Disktree](https://github.com/tobi/disktree) mula sa app launcher (`Super + Space`). Ipinapakita nito ang isang graphical na treemap ng iyong home directory. Mas maraming space ang sinasakop ng mas malalaking block; pasukin ang mga directory gamit ang keyboard o mouse, markahan kung ano ang dapat alisin, at suriin ang iyong mga pinili bago mag-alis ng kahit ano. Patakbuhin ang `disktree --disk` para i-scan ang buong disk.

## Obsidian

Ang [Obsidian](https://obsidian.md/) ay isang libre at lubos na extensible na note taking application na gumagamit ng simpleng mga Markdown file para sa storage.

Libre ang Obsidian para sa lahat ng layunin, kabilang ang personal, commercial, at non-profit na paggamit.

Nag-aalok din ang Obsidian ng [commercial na add-on para sa pag-sync](https://obsidian.md/sync) kasama ng mga mobile app sa iOS at Android. (https://obsidian.md/pricing).

Sinisimulan mo ang Obsidian gamit ang `Super + Shift + O`. Para magamit ang theme syncing, dapat mong piliin ang `Omarchy` theme sa ilalim ng settings.

## Omawrite

Ang [Omawrite](https://github.com/omacom-io/omawrite) ay ang sariling napakasimpleng Markdown writing app ng Omarchy. Walang vaults, walang plugins, ikaw lang at ang mga salita.

Sinisimulan mo ang Omawrite gamit ang `Super + Shift + W`.

## Pinta

Ang [Pinta](https://www.pinta-project.com/) ay isang basic na image editing tool na mahusay para sa pag-crop, pag-resize, at iba pang basic na manipulasyon. Huwag ka lang umasa ng kapalit ng Photoshop. Pero may Magic Wand at layers pa rin ito!

Sinisimulan mo ang Pinta sa pamamagitan ng application launcher (`Super + Space`).

## Aether

Ang [Aether](https://github.com/bjarneo/aether) ay isang theming application na maaaring kumuha ng mga kulay mula sa isang background image at gawin silang isang kumpleto at magkakaugnay na theme. Ito ang pinakamadaling paraan para [gumawa ng sarili mong theme](43-making-your-own-theme.md).

Sinisimulan mo ang Aether sa pamamagitan ng application launcher (`Super + Space`).

## LocalSend

Hinahayaan ka ng [LocalSend](https://localsend.org/) na magpadala ng mga file sa ibang device sa parehong network na nagpapatakbo ng app, tulad ng AirDrop ng Apple. Cross-platform nga lang ito, kaya maaari kang magpadala ng mga file papunta at mula sa Windows, macOS, Android, iOS, at siyempre Linux.

Maaari mong buksan ang Share menu sa `Super + Ctrl + S` o sa ilalim ng _Trigger > Share_ sa Omarchy menu. Nagbibigay ito sa iyo ng apat na opsyon:

- **Clipboard** ipinapadala kung ano mang kinopya mo bilang isang text file. Mahusay para mailagay ang isang link o snippet sa iyong telepono nang hindi nag-e-email sa sarili mo.
- **File** nagbubukas ng file picker kung saan maaari kang pumili ng marami nang sabay-sabay.
- **Folder** nagpapadala ng buong directory.
- **Receive** binubuksan ang LocalSend mismo para makapagpadala sa iyo ang ibang device.

Pareho rin itong gumagana mula sa terminal gamit ang `omarchy share clipboard`, `omarchy share file [path]`, at `omarchy share folder [path]`. Iwanan ang path at makukuha mo ang picker.

Maaari ka ring magpadala nang diretso mula sa file manager: i-right-click ang anumang pinili sa Nautilus at piliin ang _Send via LocalSend_.

Sarado ang firewall ng Omarchy bilang default maliban sa port ng LocalSend, kaya gumagana ito agad sa bagong install. Tingnan ang [seguridad](48-security.md).

## LibreOffice

Ang [LibreOffice](https://www.libreoffice.org/) ay isang kumpletong office package na may word processor, spreadsheet, presentations, drawing application, at marami pa. Compatible ito sa mga file mula sa Microsoft Office, kaya mahusay itong paraan para mabuksan ang mga Word document na iyon.

Sinisimulan mo ang LibreOffice sa pamamagitan ng application launcher (`Super + Space`).

## Hype

Ang [Hype](https://github.com/omacom/hype) ay ang sariling napakasimpleng presentation app ng Omarchy. Ang deck mo ay isang solong Markdown file na katabi ang mga image at video nito: isulat ang bawat slide sa ibaba ng isang live preview, i-drag ang mga slide sa tamang ayos, pagkatapos ay mag-present nang fullscreen o mag-export sa PDF at PowerPoint. Kinuha pa nito ang iyong Omarchy theme.

Sinisimulan mo ang Hype sa pamamagitan ng application launcher (`Super + Space`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

## Signed

Ang [Signed](https://github.com/omacom/signed) ay ang sariling napakasimpleng paraan ng Omarchy para pumirma ng mga PDF at punan ang mga ito. Ilagay ang iyong naka-save na signature, text, at petsa ngayon kahit saan sa isang page, pagkatapos ay mag-save ng signed na kopya sa tabi ng original. Tingnan ang [Pagpuno sa mga PDF](27-filling-out-pdfs.md) para sa kung paano.

Sinisimulan mo ang Signed sa pamamagitan ng application launcher (`Super + Space`), o magbukas ng PDF gamit ito mula sa file manager.

## Omacalc

Ang [Omacalc](https://github.com/omacom-io/omacalc) ay ang sariling napakasimpleng calculator ng Omarchy, na bumubukas sa isang floating window.

Sinisimulan mo ang Omacalc gamit ang `Super + Shift + Q` (o ang calculator key, kung mayroon ang keyboard mo).

## Signal

Ang [Signal](https://signal.org/) ay ang pioneer ng E2E encrypted messaging, at isang mahusay na opsyon sa komunikasyon para sa sinumang mas gustong hindi dumaan sa isa sa malalaking tech conglomerate.

Sinisimulan mo ang Signal gamit ang `Super + Shift + G`. Hindi ito bahagi ng base install, kaya sa unang pagkakataong pindutin mo iyon, mag-aalok ang Omarchy na i-install ito para sa iyo (nasa ilalim din ito ng _Install > Service_ sa Omarchy menu).

## Omaview

Ang [Omaview](https://github.com/omacom/omaview) ay ang sariling napakasimpleng picture viewer at media player ng Omarchy: isang window para sa iyong mga larawan, video, at musika. Magbukas ng larawan at dadalhin ka ng mga arrow key sa iba pa sa folder nito, ginagawa ito ng `N` at `P` para sa kahit ano, at ipinapakita ng `Ctrl + M` ang buong folder bilang isang grid. Ipinapakita rin nito ang mga HEIC, AVIF, at JPEG XL na larawan, at itutuloy kung saan ka tumigil sa anumang mahaba.

Pindutin ang `F` para sa fullscreen, `E` para mag-edit ng larawan sa Omasnap o mag-trim ng video sa Omacut, `Ctrl + P` para mag-print ng larawan, at `Delete` para ilipat ang isang file sa Trash (ibabalik ito ng `Ctrl + Z`). Pindutin ang `?` sa loob nito para makita ang bawat shortcut.

Sinisimulan mo ang Omaview bilang _Media Viewer_ sa pamamagitan ng application launcher (`Super + Space`), o mag-double-click lang ng larawan, video, o kanta sa file manager.

## Omacut

Ang [Omacut](https://github.com/omacom-io/omacut) ay ang sariling napakasimpleng video trimmer ng Omarchy. Kapag ang kailangan mo lang ay putulin ang simula at dulo ng isang clip, mas mahusay ito kaysa magbukas ng buong video editor.

Sinisimulan mo ang Omacut sa pamamagitan ng application launcher (`Super + Space`).

## Monologue

Ang [Monologue](https://github.com/omacom/monologue) ay ang sariling napakasimpleng webcam recorder ng Omarchy. Piliin ang iyong camera at microphone nang isang beses, pagkatapos ay pindutin ang `Space` para mag-record, at muli para i-pause at ipagpatuloy ang parehong take. Palagi itong nagre-record sa pinakamataas na resolution ng iyong camera, na may live na microphone meter para masuri mo ang iyong levels bago ka magsimula.

Itigil ang take at bubukas ito kaagad sa isang built-in na editor. I-double-click ang isang clip para hatiin ito, i-drag ang mga handle para i-trim ang bawat piraso, at alisin ang mga bahaging ayaw mo. Pagkatapos ay i-save ito bilang isang MP4. Mananatili ang iyong original na recording hanggang sa i-discard mo ito, kaya maaari kang laging bumalik at putulin ito nang iba.

Sinisimulan mo ang Monologue sa pamamagitan ng application launcher (`Super + Space`).
