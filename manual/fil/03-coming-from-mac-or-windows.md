# Galing sa Mac o Windows

Kung matagal kang gumamit ng macOS o Windows, alam na ng mga daliri mo ang isang daang bagay na nakalimutan na ng utak mo na natutuhan niya pala. Ang kabanatang ito ang layer ng pagsasalin: kung saan napupunta ang mga instinct na iyon sa Omarchy. Mas malalim na tinalakay sa ibang bahagi ang mismong mga feature — ito lang ang mapa.

### Super ang sentro ng lahat

Lahat ng muscle memory na nabuo mo sa paligid ng Cmd o ng Windows key ay maililipat sa iisang key: Super. Iyon ang Windows key sa isang PC keyboard, at ito ang angkla para sa halos bawat hotkey sa Omarchy.

Ang reflex mo sa Spotlight o Raycast o Start-menu ay magiging `Super + Space`. Binubuksan niyan ang menu ng Omarchy, na naglulunsad ng mga app, nagbabago ng mga setting, nag-i-install ng software, kumukuha ng larawan ng screen — halos lahat. Magsimulang mag-type para mag-filter. Ipinapakita ng `Super + Alt + Space` ang bawat app sa iisang grid, gaya ng ginagawa ng Launchpad. Tingnan ang [nabigasyon](04-navigation.md).

### Walang mga icon sa desktop, at ang dock ay hindi humahadlang

Walang mga icon na aayusin sa desktop, at nagtatago ang dock kapag may window na ang isang workspace, hanggang sa itulak mo ang pointer sa gilid nito ng screen, ang ibabang gilid maliban kung ililipat mo ito (tingnan ang [nabigasyon](04-navigation.md)). Nagsisimula ang mga app mula sa isang hotkey (`Super + Return` para sa terminal, `Super + Shift + Return` para sa browser, at `Super + K` para sa listahan ng lahat ng nakamapa) o mula sa menu. Ang nag-iisang permanenteng bahagi ng UI ay [ang top bar](05-the-top-bar.md), na sumasakop sa ginagawa noon para sa iyo ng menu bar, system tray, at Notification Center — at halos bawat widget dito ay may ginagawa sa left, right, at middle click.

### Ang mga window ay sila mismo ang pumupuwesto

Ang pinakamalaking pagbabago sa pag-iisip: hindi ka nagda-drag ng mga window sa paligid o nag-i-snap sa kanila sa kalahati ng screen. Magbukas ng isang window at sasakupin nito ang buong screen. Magbukas ng pangalawa at hahatiin nila ito. Hindi mo kailanman huhugutin ang isang window mula sa ilalim ng isa pa, dahil hindi nagpapatong-patong ang mga window.

Kapag talagang kailangan mo ng floating window, ino-toggle ng `Super + T` ang aktibong window palabas ng tiling (at pabalik). Pero bigyan mo muna ng tunay na pagkakataon ang tiling — ito ang puso ng lahat. Ipapaliwanag ito sa iyo ng [Nabigasyon](04-navigation.md).

Pamilyar ang pakiramdam ng mga workspace: para silang macOS Spaces o Windows virtual desktops, maliban sa talagang gagamitin mo sila, dahil diretso kang tumatalon sa isa gamit ang `Super + 1/2/3/4` at ipinapadala ng `Super + Shift + 1/2/3/4` doon ang aktibong window. Walang delay sa animation, instant na talon lang. Ibig sabihin, maaaring hindi mo na nga kailanganin ng maraming monitor, kung nakasanayan mo iyon noon.

### Gumagana lang ang copy at paste

Sa Mac, may Cmd + C ka kahit saan. Sa Windows, may Ctrl + C ka kahit saan — maliban sa terminal, kung saan pinapatay nito ang programa mo. Binibigyan ka ng Omarchy ng `Super + C`, `Super + X`, at `Super + V`, at gumagana sila kahit saan, kasama ang terminal. Walang hiwalay na reflex na kailangang matutuhan para sa shell.

Mga galing sa Windows: ang Win + V clipboard history mo ay nasa `Super + Ctrl + V`, at naglalaman ito ng mga larawan pati na rin ng teksto. Tingnan ang [pinag-isang clipboard at history](08-unified-clipboard-history.md).

### Ang talahanayan ng pagsasalin

| Ang hinahanap mo | Sa Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ang menu ng Omarchy |
| AirDrop | LocalSend, sa pamamagitan ng `Super + Ctrl + S` — tingnan ang [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — tingnan ang [mga screenshot at recording](12-screenshots-recording.md) |
| Notification Center | History ng mga notipikasyon sa `Super + Shift + Alt + ,` |
| Time Machine (para sa sistema) | Awtomatikong [mga snapshot ng sistema](47-system-snapshots.md) sa bawat update |
| App Store / pag-download ng installer | _Install_ sa menu, o `omarchy pkg add` — tingnan ang [iba pang mga package](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ sa menu, na nag-e-edit ng mga simpleng config file — tingnan ang [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, sa `Super + Shift + F` — tingnan ang [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome sa `Super + Shift + Return`; pumili ng iba sa ilalim ng _Setup > Defaults > Browser_ — tingnan ang [mga browser](23-browsers.md) |
| Preview / Photos | Omaview para sa mga larawan, video at musika, Document Viewer para sa mga PDF — tingnan ang [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, sa `Super + Shift + N`; pumili ng iba sa ilalim ng _Setup > Defaults > Editor_ |

### Talagang iba ang ilang bagay

Maraming setting ang nasa mga text file na ine-edit mo, hindi sa mga panel na kini-click mo. Mukhang primitive iyon hanggang sa mapagtanto mong ibig sabihin niyon, bawat tweak ay makikita, makokopya sa susunod mong makina, at mailalagay sa version control. Diretso kang dinadala ng _Setup_ menu sa tamang file at nire-restart nito ang anumang kailangang i-restart kapag tapos ka na.

Dumarating ang mga update sa pamamagitan ng iisang command — _Update > Omarchy_ — na nag-a-update sa Omarchy mismo at sa bawat package sa sistema, at kumukuha muna ng snapshot. Walang mga per-app updater na nang-iistorbo sa iyo nang biglaan. Tingnan ang [mga update](30-updates.md).

Nagmumula ang software sa isang package manager, hindi sa mga na-download na installer.

At kapag nagsara ka ng window, talagang nagku-quit ang app. Walang macOS limbo kung saan patuloy na tumatakbo ang programa nang walang mga window. Ang `Super + W` — o `Super + Q`, kung iyon ang finger memory na dala mo pagdating — ay nangangahulugang wala na.

### Sa Mac hardware

Mahusay tumakbo ang Omarchy sa mga Intel Mac, at sa mga M1, M2 at M3 Mac gamit ang Omarchy for Apple Silicon. Tingnan ang [suporta sa Mac](44-mac-support.md). At mabait sa iyo ang keyboard: walang anumang nire-remap ang Omarchy, at itinuturing ng Linux ang Command key bilang Super, kaya ang Super ay nasa mismong lugar kung saan palaging naroon ang Cmd. Hindi mapapansin ng hinlalaki mo ang paglipat.

### Bigyan mo ito ng dalawang linggo

Mas mabilis mailipat ang mga instinct kaysa sa inaakala mo. Silipin nang isang beses ang kabanata tungkol sa [mga hotkey](07-hotkeys.md), at tuwing mabablangko ka sa isang binding, pindutin ang `Super + K` — ipinapakita nito sa iyo ang lahat ng mga iyon. Iyon lang ang hotkey na talagang kailangan mong kabisaduhin.
