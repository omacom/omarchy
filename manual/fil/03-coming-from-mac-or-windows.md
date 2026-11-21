# Kung Galing Ka sa Mac o Windows

Kung gumugol ka ng maraming taon sa macOS o Windows, alam ng iyong mga daliri ang daang bagay na nakalimutan na ng iyong utak na natutunan nito. Ang kabanatang ito ang layer ng pagsasalin: kung saan mapupunta ang mga instinct na iyon sa Omarchy. Saklaw nang malaliman ang mismong mga feature sa ibang bahagi — ito lang ang mapa.

### Super ang sentro ng lahat

Lahat ng muscle memory na nabuo mo sa paligid ng Cmd o ng Windows key ay maililipat sa iisang key: Super. Iyon ang Windows key sa isang PC keyboard, at ito ang angkla para sa halos bawat hotkey sa Omarchy.

Ang reflex mo sa Spotlight o Raycast o Start menu ay magiging `Super + Space`. Binubuksan niyon ang menu ng Omarchy, na naglulunsad ng mga app, nagbabago ng mga setting, nag-i-install ng software, kumukuha ng screen — halos lahat. Magsimulang mag-type para mag-filter. Ipinapakita ng `Super + Alt + Space` ang bawat app sa iisang grid, gaya ng ginagawa ng Launchpad. Tingnan ang [nabigasyon](04-navigation.md).

### Walang mga icon sa desktop, at lumalabas lang ang dock kapag nag-float ka

Walang mga icon na aayusin sa desktop, at walang dock sa isang tiling workspace — lumalabas lang ang dock sa isang floating workspace (tingnan ang [nabigasyon](04-navigation.md)). Nagsisimula ang mga app mula sa isang hotkey (`Super + Return` para sa terminal, `Super + Shift + Return` para sa browser, at `Super + K` para sa listahan ng lahat ng naka-map) o mula sa menu. Ang iisang persistent na bahagi ng UI ay [ang top bar](05-the-top-bar.md), na sumasaklaw sa dating ginagawa para sa iyo ng menu bar, system tray, at Notification Center — at halos bawat widget dito ay may ginagawa sa left, right, at middle click.

### Kusa ang puwesto ng mga window

Ang pinakamalaking pagbabago sa pag-iisip: hindi mo kinakaladkad ang mga window o ini-snap sa kalahati ng screen. Magbukas ng isang window at sasakupin nito ang buong screen. Magbukas ng pangalawa at hahatiin nila ito. Hindi mo kailanman huhukayin ang isang window mula sa ilalim ng isa pa, dahil hindi nagpapatong-patong ang mga window.

Kapag talagang kailangan mo ng floating window, ini-toggle ng `Super + T` ang aktibo palabas ng tiling (at pabalik). Pero bigyan mo muna ng tunay na pagkakataon ang tiling — ito ang puso ng buong bagay. Gagabayan ka ng [Nabigasyon](04-navigation.md) dito.

Pamilyar ang pakiramdam ng mga workspace: para silang macOS Spaces o Windows virtual desktops, maliban na talagang gagamitin mo sila, dahil dumidiretso ang `Super + 1/2/3/4` sa isa at ipinapadala ng `Super + Shift + 1/2/3/4` ang aktibong window doon. Walang delay sa animation, instant na pagtalon lang. Ibig sabihin nito, baka hindi mo na kailangan ng maraming monitor, kung nakasanayan mo iyon noon.

### Gumagana lang ang copy at paste

Sa Mac, may Cmd + C ka kahit saan. Sa Windows, may Ctrl + C ka kahit saan — maliban sa terminal, kung saan pinapatay nito ang iyong program. Bibigyan ka ng Omarchy ng `Super + C`, `Super + X`, at `Super + V`, at gumagana ang mga ito kahit saan, kasama ang terminal. Walang hiwalay na reflex na kailangang matutunan para sa shell.

Mga taga-Windows: nasa `Super + Ctrl + V` ang iyong Win + V clipboard history, at naglalaman ito ng mga larawan pati teksto. Tingnan ang [pinag-isang clipboard at history](08-unified-clipboard-history.md).

### Ang talahanayan ng pagsasalin

| Ang hinahanap mo | Sa Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ang menu ng Omarchy |
| AirDrop | LocalSend, sa pamamagitan ng `Super + Ctrl + S` — tingnan ang [mga GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — tingnan ang [mga screenshot at recording](12-screenshots-recording.md) |
| Notification Center | History ng notification sa `Super + Shift + Alt + ,` |
| Time Machine (para sa system) | Awtomatikong [mga system snapshot](47-system-snapshots.md) sa bawat update |
| App Store / pag-download ng installer | _Install_ sa menu, o `omarchy pkg add` — tingnan ang [iba pang mga package](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ sa menu, na nag-e-edit ng mga plain na config file — tingnan ang [mga dotfile](31-dotfiles.md) |
| Finder / File Explorer | Files, sa `Super + Shift + F` — tingnan ang [mga GUI](22-guis.md) |
| Safari / Edge | Google Chrome sa `Super + Shift + Return`; pumili ng iba sa ilalim ng _Setup > Defaults > Browser_ — tingnan ang [mga browser](23-browsers.md) |
| Preview / Photos | Omaview para sa mga larawan, video at musika, Document Viewer para sa mga PDF — tingnan ang [mga GUI](22-guis.md) |
| TextEdit / Notepad | Plain, sa `Super + Shift + N`; pumili ng iba sa ilalim ng _Setup > Defaults > Editor_ |

### Talagang iba ang ilang bagay

Maraming setting ang nasa mga text file na ini-edit mo, hindi sa mga panel na kini-click mo. Parang primitive iyon hanggang sa mapagtanto mong ibig sabihin niyon, bawat tweak ay makikita, makokopya sa susunod mong machine, at mailalagay sa version control. Dadalhin ka ng menu na _Setup_ diretso sa tamang file at iri-restart ang anumang kailangang i-restart kapag tapos ka na.

Dumarating ang mga update sa pamamagitan ng iisang command — _Update > Omarchy_ — na nag-a-update sa Omarchy mismo at sa bawat package sa system, na kumukuha muna ng snapshot. Walang mga per-app updater na nangungulit sa iyo nang random. Tingnan ang [mga update](30-updates.md).

Nagmumula ang software sa isang package manager, hindi sa mga na-download na installer.

At kapag nagsara ka ng window, talagang nagku-quit ang app. Walang macOS limbo kung saan patuloy na tumatakbo ang program nang walang window. Ang `Super + W` — o `Super + Q`, kung iyon ang finger memory na dala mo pagdating — ay nangangahulugang wala na.

### Sa Mac hardware

Mahusay tumakbo ang Omarchy sa mga Intel Mac — tingnan ang [suporta sa Mac](44-mac-support.md). At mabait sa iyo ang keyboard: walang nire-remap ang Omarchy, at itinuturing ng Linux ang Command key bilang Super, kaya nasa mismong kinalalagyan lagi ng Cmd ang Super. Hindi mapapansin ng iyong hinlalaki ang paglipat.

### Bigyan mo ito ng dalawang linggo

Mas mabilis maililipat ang mga instinct kaysa iniisip mo. Basahin nang mabilis ang kabanata ng [mga hotkey](07-hotkeys.md) nang isang beses, at tuwing mabablangko ka sa isang binding, pindutin ang `Super + K` — ipinapakita nito sa iyo ang lahat. Iyon lang ang hotkey na talagang kailangan mong kabisaduhin.
