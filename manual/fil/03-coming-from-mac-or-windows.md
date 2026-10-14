# Galing sa Mac o Windows

Kung gumugol ka ng maraming taon sa macOS o Windows, alam ng iyong mga daliri ang isang daang bagay na nakalimutan na ng iyong utak na natutunan nito. Ang kabanatang ito ang layer ng pagsasalin: kung saan napupunta ang mga instinto na iyon sa Omarchy. Ang mga feature mismo ay tinatalakay nang mas malalim sa ibang bahagi — mapa lang ito.

### Ang Super ang sentro ng lahat

Ang lahat ng muscle memory na nabuo mo sa paligid ng Cmd o ng Windows key ay nalilipat sa isang key: Super. Iyan ang Windows key sa isang PC keyboard, at iyan ang anchor para sa halos bawat hotkey sa Omarchy.

Ang iyong reflex para sa Spotlight o Raycast o Start menu ay nagiging `Super + Space`. Binubuksan niyon ang menu ng Omarchy, na naglulunsad ng mga app, nagbabago ng mga setting, nag-i-install ng software, kumukuha ng screen — halos lahat ng bagay. Simulan ang pag-type para mag-filter. Ipinapakita ng `Super + Alt + Space` ang bawat app sa isang grid, tulad ng ginagawa ng Launchpad. Tingnan ang [nabigasyon](04-navigation.md).

### Walang dock at walang desktop icon

Walang iki-click para maglunsad ng mga bagay, walang mga icon na aayusin sa desktop. Nagsisimula ang mga app mula sa isang hotkey (`Super + Return` para sa terminal, `Super + Shift + Return` para sa browser, at `Super + K` para sa listahan ng lahat ng naka-map) o mula sa menu. Ang tanging permanenteng bahagi ng UI ay [ang top bar](05-the-top-bar.md), na sumasaklaw sa ginagawa sa iyo dati ng menu bar, system tray, at Notification Center — at halos bawat widget dito ay may ginagawa sa kaliwa, kanan, at gitnang click.

### Ang mga bintana mismo ang pumupuwesto

Ang pinakamalaking pagbabago sa pag-iisip: hindi mo idina-drag ang mga bintana o ini-snap ang mga ito sa kalahati ng screen. Magbukas ng bintana at sasakupin nito ang buong screen. Magbukas ng pangalawa at hahatiin nila ito. Hindi mo kailanman kukunin ang isang bintana mula sa ilalim ng isa pa, dahil hindi nagpapatong-patong ang mga bintana.

Kapag talagang kailangan mo ng isang lumulutang na bintana, ini-toggle ng `Super + T` ang aktibo palabas ng tiling (at pabalik). Pero bigyan mo muna ng totoong pagkakataon ang tiling — iyan ang puso ng buong bagay. Gagabayan ka ng [Nabigasyon](04-navigation.md) dito.

Pamilyar ang pakiramdam ng mga workspace: sila ang mga Spaces ng macOS o mga virtual desktop ng Windows, maliban sa talagang gagamitin mo sila, dahil direktang tumatalon ang `Super + 1/2/3/4` sa isa at ipinapadala ng `Super + Shift + 1/2/3/4` ang aktibong bintana roon. Walang pagkaantala sa animation, instant na talon lang. Ibig sabihin, maaaring hindi mo na nga kailanganin ng maraming monitor, kung sanay ka na roon dati.

### Gumagana lang ang copy at paste

Sa Mac, mayroon kang Cmd + C kahit saan. Sa Windows, mayroon kang Ctrl + C kahit saan — maliban sa terminal, kung saan pinapatay nito ang iyong programa. Binibigyan ka ng Omarchy ng `Super + C`, `Super + X`, at `Super + V`, at gumagana ang mga ito kahit saan, kasama na ang terminal. Walang hiwalay na reflex na kailangang matutunan para sa shell.

Mga taga-Windows: ang iyong kasaysayan ng clipboard na Win + V ay nasa `Super + Ctrl + V`, at naglalaman ito ng mga larawan pati na rin ng teksto. Tingnan ang [pinag-isang clipboard at kasaysayan](08-unified-clipboard-history.md).

### Ang talahanayan ng pagsasalin

| Hinahanap mo | Sa Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ang menu ng Omarchy |
| AirDrop | LocalSend, sa pamamagitan ng `Super + Ctrl + S` — tingnan ang [mga GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — tingnan ang [mga screenshot at pag-record](12-screenshots-recording.md) |
| Notification Center | Kasaysayan ng notipikasyon sa `Super + Shift + Alt + ,` |
| Time Machine (para sa sistema) | Awtomatikong [mga snapshot ng sistema](47-system-snapshots.md) sa bawat update |
| App Store / pag-download ng installer | _I-install_ sa menu, o `omarchy pkg add` — tingnan ang [iba pang mga package](29-other-packages.md) |
| System Settings / Control Panel | _Pag-setup_ sa menu, na nag-e-edit ng mga plain na config file — tingnan ang [mga dotfile](31-dotfiles.md) |

### May ilang bagay na talagang iba

Maraming setting ang nasa mga text file na ini-edit mo, hindi sa mga panel na iki-click mo. Mukhang primitive iyon hanggang sa mapagtanto mong nangangahulugan itong ang bawat tweak ay maaaring makita, makopya sa susunod mong makina, at mailagay sa version control. Dadalhin ka ng menu ng _Pag-setup_ nang diretso sa tamang file at ire-restart ang anumang kailangang i-restart kapag tapos ka na.

Dumarating ang mga update sa pamamagitan ng isang command — _I-update > Omarchy_ — na nag-a-update sa Omarchy mismo at sa bawat package sa sistema, na kumukuha muna ng snapshot. Walang mga updater bawat app na nanggugulo sa iyo nang random. Tingnan ang [mga update](30-updates.md).

Nagmumula ang software sa isang package manager, hindi sa mga na-download na installer.

At kapag isinara mo ang isang bintana, talagang nagsasara ang app. Walang limbo ng macOS kung saan patuloy na tumatakbo ang programa nang walang mga bintana. Ang `Super + W` — o `Super + Q`, kung iyan ang finger memory na dala mo — ay nangangahulugang wala na.

### Sa Mac hardware

Mahusay na tumatakbo ang Omarchy sa mga Intel Mac — tingnan ang [suporta sa Mac](44-mac-support.md). At mabait sa iyo ang keyboard: walang nire-remap ang Omarchy, at itinuturing ng Linux ang Command key bilang Super, kaya nakaupo ang Super kung saan palaging naroon ang Cmd. Hindi mapapansin ng iyong hinlalaki ang paglipat.

### Bigyan ito ng dalawang linggo

Mas mabilis lumipat ang mga instinto kaysa sa iniisip mo. Silipin ang kabanata ng [mga hotkey](07-hotkeys.md) nang isang beses, at tuwing mablangko ka sa isang binding, pindutin ang `Super + K` — ipinapakita nito ang lahat sa iyo. Iyan ang tanging hotkey na talagang kailangan mong kabisaduhin.
