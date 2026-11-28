# Kung Galing Ka sa Mac o Windows

Kung gumugol ka na ng mga taon sa macOS o Windows, alam ng mga daliri mo ang isang daang bagay na nakalimutan na ng utak mo na natutunan niya pala ang mga ito. Ang kabanatang ito ang pansalin na layer: kung saan napupunta ang mga likas na gawi na iyon sa Omarchy. Malalimang tinalakay sa ibang bahagi ang mismong mga feature — ito lang ang mapa.

### Super ang sentro ng lahat

Lahat ng muscle memory na nabuo mo sa paligid ng Cmd o ng Windows key ay nalilipat sa iisang key: Super. Iyon ang Windows key sa isang PC keyboard, at ito ang angkla ng halos bawat hotkey sa Omarchy.

Ang reflex mo para sa Spotlight o Raycast o Start menu ay nagiging `Super + Space`. Binubuksan niyan ang menu ng Omarchy, na naglulunsad ng mga app, nagbabago ng mga setting, nag-i-install ng software, kumukuha ng larawan ng screen — halos lahat na. Magsimulang mag-type para mag-filter. Ipinapakita ng `Super + Alt + Space` ang bawat app sa iisang grid, gaya ng ginagawa ng Launchpad. Tingnan ang [nabigasyon](04-navigation.md).

### Walang mga icon sa desktop, at hindi nakaharang ang dock

Walang mga icon na aayusin sa desktop, at nagtatago ang dock kapag may window na ang isang workspace, hanggang sa itulak mo ang pointer sa gilid nito ng screen, sa kanang gilid maliban kung ilipat mo ito (tingnan ang [nabigasyon](04-navigation.md)). Nagsisimula ang mga app mula sa isang hotkey (`Super + Return` para sa terminal, `Super + Shift + Return` para sa browser, at `Super + K` para sa listahan ng lahat ng nakamapa) o mula sa menu. Ang iisang piraso ng UI na palaging nananatili ay [ang top bar](05-the-top-bar.md), na sumasaklaw sa dating ginagawa para sa iyo ng menu bar, system tray, at Notification Center — at halos bawat widget dito ay may ginagawa sa left, right, at middle click.

### Ang mga window ang kusang pumupuwesto sa sarili nila

Ang pinakamalaking pagbabago sa pag-iisip: hindi mo kinakaladkad ang mga window kung saan-saan o ini-snap sa kalahati ng screen. Magbukas ka ng isang window at sinasakop nito ang buong screen. Magbukas ka ng pangalawa at hahatiin nila ito. Hindi mo kailanman kailangang mangalkal ng isang window mula sa ilalim ng isa pa, dahil hindi nagpapatong-patong ang mga window.

Kapag talagang kailangan mo ng lumulutang na window, inilalabas ng `Super + T` ang aktibong window mula sa tiling (at ibinabalik ito). Pero bigyan mo muna ng tunay na pagkakataon ang tiling — iyon ang puso ng buong bagay. Gagabayan ka ng [Nabigasyon](04-navigation.md) dito.

Pamilyar ang pakiramdam ng mga workspace: para silang macOS Spaces o Windows virtual desktops, maliban na talagang gagamitin mo sila, dahil dumidiretso ang `Super + 1/2/3/4` sa isa sa kanila at ipinapadala ng `Super + Shift + 1/2/3/4` ang aktibong window doon. Walang pagkaantala dahil sa animation, mga agarang lipat lang. Ibig sabihin nito, baka hindi mo na nga kailanganin ng maraming monitor, kung nakasanayan mo iyon noon.

### Gumagana lang ang copy at paste

Sa Mac, mayroon kang Cmd + C kahit saan. Sa Windows, mayroon kang Ctrl + C kahit saan — maliban sa terminal, kung saan pinapatay nito ang programa mo. Binibigyan ka ng Omarchy ng `Super + C`, `Super + X`, at `Super + V`, at gumagana ang mga ito kahit saan, pati sa terminal. Walang hiwalay na reflex na kailangang matutunan para sa shell.

Mga taga-Windows: ang clipboard history ng Win + V mo ay nasa `Super + Ctrl + V`, at naglalaman ito ng mga larawan pati na rin ng teksto. Tingnan ang [pinag-isang clipboard at kasaysayan](08-unified-clipboard-history.md).

### Ang talahanayan ng pagsasalin

| Ang hinahanap mo | Sa Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ang menu ng Omarchy |
| AirDrop | LocalSend, sa pamamagitan ng `Super + Ctrl + S` — tingnan ang [mga GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — tingnan ang [mga screenshot at pag-record](12-screenshots-recording.md) |
| Notification Center | Kasaysayan ng notification sa `Super + Shift + Alt + ,` |
| Time Machine (para sa system) | Awtomatikong [mga snapshot ng system](47-system-snapshots.md) sa bawat update |
| App Store / pag-download ng installer | _Install_ sa menu, o `omarchy pkg add` — tingnan ang [iba pang mga package](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ sa menu, na nag-e-edit ng mga simpleng config file — tingnan ang [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, sa `Super + Shift + F` — tingnan ang [mga GUI](22-guis.md) |
| Safari / Edge | Google Chrome sa `Super + Shift + Return`; pumili ng iba sa ilalim ng _Setup > Defaults > Browser_ — tingnan ang [mga browser](23-browsers.md) |
| Preview / Photos | Omaview para sa mga larawan, video at musika, Document Viewer para sa mga PDF — tingnan ang [mga GUI](22-guis.md) |
| TextEdit / Notepad | Plain, sa `Super + Shift + N`; pumili ng iba sa ilalim ng _Setup > Defaults > Editor_ |

### Talagang iba ang ilang bagay

Maraming setting ang nasa mga text file na ine-edit mo, hindi sa mga panel na kini-click mo. Mukhang primitibo iyon hanggang sa mapagtanto mo na ibig sabihin niyon, bawat pagbabago ay makikita, makokopya sa susunod mong makina, at mailalagay sa version control. Didiretso ka ng menu na _Setup_ sa tamang file at iri-restart nito ang anumang kailangang i-restart kapag tapos ka na.

Dumarating ang mga update sa pamamagitan ng iisang command — _Update > Omarchy_ — na nag-a-update sa mismong Omarchy at sa bawat package sa system, na kumukuha muna ng snapshot. Walang mga updater ng bawat app na nangungulit sa iyo nang walang pinipiling oras. Tingnan ang [mga update](30-updates.md).

Nagmumula ang software sa isang package manager, hindi sa mga na-download na installer.

At kapag isinara mo ang isang window, talagang nagsasara ang app. Walang limbo sa macOS kung saan patuloy na tumatakbo ang programa nang walang mga window. Ang `Super + W` — o `Super + Q`, kung iyon ang memorya ng daliri na dala mo pagdating — ay nangangahulugang wala na.

### Sa Mac hardware

Mahusay na tumatakbo ang Omarchy sa mga Intel Mac, at sa mga M1, M2 at M3 Mac gamit ang Omarchy for Apple Silicon. Tingnan ang [suporta para sa Mac](44-mac-support.md). At mabait sa iyo ang keyboard: walang nire-remap ang Omarchy, at itinuturing ng Linux ang Command key bilang Super, kaya nakaupo ang Super mismo kung saan palaging naroon ang Cmd. Hindi mapapansin ng hinlalaki mo ang paglipat.

### Bigyan mo ito ng dalawang linggo

Mas mabilis malipat ang mga likas na gawi kaysa sa inaakala mo. Silipin mo nang isang beses ang kabanata tungkol sa [mga hotkey](07-hotkeys.md), at tuwing nabablangko ka sa isang binding, pindutin ang `Super + K` — ipinapakita nito ang lahat ng mga ito sa iyo. Iyon lang ang hotkey na talagang kailangan mong kabisaduhin.
