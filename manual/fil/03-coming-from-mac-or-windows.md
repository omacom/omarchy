# Galing sa Mac o Windows

Kung gumugol ka ng maraming taon sa macOS o Windows, alam ng mga daliri mo ang sandaan na bagay na nakalimutan na ng utak mo na natutunan niya pala. Ang kabanatang ito ang layer ng pagsasalin: kung saan napupunta ang mga instinct na iyon sa Omarchy. Malalim na tinalakay sa ibang bahagi ang mga feature mismo — mapa lang ito.

### Super ang sentro ng lahat

Lahat ng muscle memory na nabuo mo sa paligid ng Cmd o ng Windows key ay lilipat sa iisang key: Super. Iyon ang Windows key sa PC keyboard, at ito ang angkla para sa halos lahat ng hotkey sa Omarchy.

Ang reflex mo sa Spotlight o Raycast o Start menu ay magiging `Super + Space`. Binubuksan niyan ang menu ng Omarchy, na naglulunsad ng mga app, nagbabago ng mga setting, nag-i-install ng software, kumukuha ng screen — halos lahat. Magsimulang mag-type para mag-filter. Ipinapakita ng `Super + Alt + Space` ang bawat app sa iisang grid, gaya ng ginagawa ng Launchpad. Tingnan ang [nabigasyon](04-navigation.md).

### Walang mga icon sa desktop, at lumalabas lang ang dock kapag lumulutang ka

Walang mga icon na aayusin sa desktop, at walang dock sa tiling workspace — lumalabas lang ang dock sa floating workspace (tingnan ang [nabigasyon](04-navigation.md)). Nagsisimula ang mga app mula sa hotkey (`Super + Return` para sa terminal, `Super + Shift + Return` para sa browser, at `Super + K` para sa listahan ng lahat ng naka-map) o mula sa menu. Ang iisang piraso ng UI na palaging nandoon ay [ang top bar](05-the-top-bar.md), na sumasaklaw sa ginagawa noon para sa iyo ng menu bar, system tray, at Notification Center — at halos bawat widget dito ay may ginagawa sa left click, right click, at middle click.

### Ang mga window ay kusang pumupuwesto

Ang pinakamalaking pagbabago sa pag-iisip: hindi mo kinakaladkad ang mga window sa paligid o ini-snap ang mga ito sa kalahati ng screen. Magbukas ka ng window at sasakupin nito ang buong screen. Magbukas ka ng pangalawa at hahatiin nila ito. Hindi mo kailanman kailangang manghuli ng window mula sa ilalim ng isa pa, dahil hindi nagpapatong-patong ang mga window.

Kapag talagang kailangan mo ng floating window, ino-toggle ng `Super + T` ang aktibo palabas ng tiling (at pabalik). Pero bigyan mo muna ng tunay na pagkakataon ang tiling — iyon ang puso ng buong bagay. Gagabayan ka ng [Nabigasyon](04-navigation.md) dito.

Magiging pamilyar ang pakiramdam ng mga workspace: para silang macOS Spaces o Windows virtual desktops, maliban na talagang gagamitin mo sila, dahil diretso kang tumatalon sa isa gamit ang `Super + 1/2/3/4` at ipinapadala ng `Super + Shift + 1/2/3/4` ang aktibong window doon. Walang delay sa animation, instant na talon lang. Ibig sabihin nito, baka hindi mo na nga kailangan ng maraming monitor, kung nakasanayan mo iyon noon.

### Gumagana lang ang copy at paste

Sa Mac mayroon kang Cmd + C kahit saan. Sa Windows mayroon kang Ctrl + C kahit saan — maliban sa terminal, kung saan pinapatay nito ang program mo. Binibigyan ka ng Omarchy ng `Super + C`, `Super + X`, at `Super + V`, at gumagana sila kahit saan, kasama ang terminal. Walang hiwalay na reflex na kailangang matutunan para sa shell.

Mga taga-Windows: ang Win + V clipboard history ninyo ay nasa `Super + Ctrl + V`, at naglalaman ito ng mga larawan pati teksto. Tingnan ang [pinag-isang clipboard at history](08-unified-clipboard-history.md).

### Ang talahanayan ng pagsasalin

| Ang hinahanap mo | Sa Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ang menu ng Omarchy |
| AirDrop | LocalSend, sa pamamagitan ng `Super + Ctrl + S` — tingnan ang [mga GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — tingnan ang [mga screenshot at recording](12-screenshots-recording.md) |
| Notification Center | Kasaysayan ng notification sa `Super + Shift + Alt + ,` |
| Time Machine (para sa system) | Awtomatikong [mga snapshot ng system](47-system-snapshots.md) sa bawat update |
| App Store / pagda-download ng installer | _Install_ sa menu, o `omarchy pkg add` — tingnan ang [iba pang mga package](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ sa menu, na nag-e-edit ng mga plain na config file — tingnan ang [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, sa `Super + Shift + F` — tingnan ang [mga GUI](22-guis.md) |
| Safari / Edge | Google Chrome sa `Super + Shift + Return`; pumili ng iba sa ilalim ng _Setup > Defaults > Browser_ — tingnan ang [mga browser](23-browsers.md) |
| Preview / Photos | Omaview para sa mga larawan, video at musika, Document Viewer para sa mga PDF — tingnan ang [mga GUI](22-guis.md) |
| TextEdit / Notepad | Plain, sa `Super + Shift + N`; pumili ng iba sa ilalim ng _Setup > Defaults > Editor_ |

### Talagang iba ang ilang bagay

Maraming setting ang nasa mga text file na ine-edit mo, hindi sa mga panel na kini-click mo lang. Mukhang primitive iyon hanggang sa mapagtanto mong ibig sabihin niyon ay bawat tweak ay makikita, makokopya sa susunod mong machine, at mailalagay sa version control. Diretso kang dadalhin ng _Setup_ menu sa tamang file at ire-restart nito ang anumang kailangang i-restart kapag tapos ka na.

Dumarating ang mga update sa pamamagitan ng iisang command — _Update > Omarchy_ — na nag-a-update sa Omarchy mismo at sa bawat package sa system, na kumukuha muna ng snapshot. Walang mga updater ng bawat app na nangungulit sa iyo nang wala sa oras. Tingnan ang [mga update](30-updates.md).

Nagmumula ang software sa package manager, hindi sa mga na-download na installer.

At kapag nagsara ka ng window, talagang nagsasara ang app. Walang limbo ng macOS kung saan patuloy na tumatakbo ang program nang walang mga window. Ang `Super + W` — o `Super + Q`, kung iyon ang finger memory na dala mo pagdating — ay nangangahulugang wala na.

### Sa Mac hardware

Mahusay na tumatakbo ang Omarchy sa mga Intel Mac, at sa mga M1, M2 at M3 Mac gamit ang Omarchy for Apple Silicon. Tingnan ang [suporta sa Mac](44-mac-support.md). At mabait sa iyo ang keyboard: walang nire-remap ang Omarchy, at itinuturing ng Linux ang Command key bilang Super, kaya nakaupo ang Super eksakto kung nasaan lagi ang Cmd. Hindi mapapansin ng hinlalaki mo ang paglipat.

### Bigyan mo ito ng dalawang linggo

Mas mabilis lumipat ang mga instinct kaysa sa inaakala mo. Silipin mo nang isang beses ang kabanata ng [mga hotkey](07-hotkeys.md), at tuwing mabablangko ka sa isang binding, pindutin mo ang `Super + K` — ipinapakita nito sa iyo ang lahat ng mga iyon. Iyon lang ang hotkey na talagang kailangan mong kabisaduhin.
