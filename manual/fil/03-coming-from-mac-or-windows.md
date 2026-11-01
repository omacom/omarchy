# Galing sa Mac o Windows

Kung gumugol ka ng maraming taon sa macOS o Windows, alam ng mga daliri mo ang isang daang bagay na nakalimutan na ng utak mo na natutunan niya pala. Ang kabanatang ito ang layer ng pagsasalin: kung saan napupunta ang mga instinct na iyon sa Omarchy. Malalimang tinalakay sa ibang bahagi ang mga feature mismo — ito ay mapa lamang.

### Ang Super ang sentro ng lahat

Lahat ng muscle memory na nabuo mo sa paligid ng Cmd o ng Windows key ay maililipat sa isang key: Super. Iyon ang Windows key sa PC keyboard, at ito ang angkla ng halos bawat hotkey sa Omarchy.

Ang reflex mo sa Spotlight o Raycast o Start menu ay magiging `Super + Space`. Binubuksan niyan ang menu ng Omarchy, na naglulunsad ng mga app, nagbabago ng mga setting, nag-i-install ng software, kumukuha ng screen — halos lahat ng bagay. Magsimulang mag-type para mag-filter. Ipinapakita ng `Super + Alt + Space` ang bawat app sa iisang grid, gaya ng ginagawa ng Launchpad. Tingnan ang [nabigasyon](04-navigation.md).

### Walang dock at walang desktop icons

Walang maiki-click para maglunsad ng mga bagay, walang mga icon na aayusin sa desktop. Nagsisimula ang mga app mula sa isang hotkey (`Super + Return` para sa terminal, `Super + Shift + Return` para sa browser, at `Super + K` para sa listahan ng lahat ng naka-map) o mula sa menu. Ang nag-iisang permanenteng piraso ng UI ay [ang bar sa itaas](05-the-top-bar.md), na sumasaklaw sa dating ginagawa para sa iyo ng menu bar, system tray, at Notification Center — at halos bawat widget dito ay may ginagawa sa left, right, at middle click.

### Ang mga window ang naglalagay ng sarili nila

Ang pinakamalaking pagbabago sa pag-iisip: hindi ka nagda-drag ng mga window kung saan-saan o nag-i-snap sa kanila sa kalahati ng screen. Magbukas ka ng isang window at sakupin nito ang buong screen. Magbukas ka ng pangalawa at hahatiin nila ito. Hindi ka kailanman manghahalungkat ng window mula sa ilalim ng isa pa, dahil hindi nagpapatong-patong ang mga window.

Kapag talagang kailangan mo ng lumulutang na window, inilalabas ng `Super + T` ang aktibo mula sa tiling (at ibinabalik ito). Pero bigyan mo muna ng tunay na pagkakataon ang tiling — iyon ang puso ng buong bagay. Gagabayan ka ng [Nabigasyon](04-navigation.md) dito.

Pamilyar ang pakiramdam ng mga workspace: para silang macOS Spaces o Windows virtual desktops, maliban na talagang gagamitin mo sila, dahil dumidiretso ka sa isa gamit ang `Super + 1/2/3/4` at ipinapadala ng `Super + Shift + 1/2/3/4` ang aktibong window doon. Walang delay sa animation, instant na pagtalon lang. Ibig sabihin nito, baka hindi mo na kailangan ng maraming monitor, kung iyon ang nakasanayan mo noon.

### Gumagana lang ang copy at paste

Sa Mac, mayroon kang Cmd + C sa lahat ng lugar. Sa Windows, mayroon kang Ctrl + C sa lahat ng lugar — maliban sa terminal, kung saan pinapatay nito ang programa mo. Binibigyan ka ng Omarchy ng `Super + C`, `Super + X`, at `Super + V`, at gumagana ang mga ito sa lahat ng lugar, pati sa terminal. Walang hiwalay na reflex na kailangang matutunan para sa shell.

Mga taga-Windows: ang Win + V clipboard history mo ay nasa `Super + Ctrl + V`, at naglalaman ito ng mga larawan pati na rin ng teksto. Tingnan ang [pinag-isang clipboard at history](08-unified-clipboard-history.md).

### Ang talahanayan ng pagsasalin

| Ang hinahanap mo | Sa Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ang menu ng Omarchy |
| AirDrop | LocalSend, sa pamamagitan ng `Super + Ctrl + S` — tingnan ang [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — tingnan ang [mga screenshot at recording](12-screenshots-recording.md) |
| Notification Center | History ng notification sa `Super + Shift + Alt + ,` |
| Time Machine (para sa system) | Awtomatikong [mga snapshot ng system](47-system-snapshots.md) sa bawat update |
| App Store / pag-download ng installer | _Install_ sa menu, o `omarchy pkg add` — tingnan ang [iba pang mga package](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ sa menu, na nag-e-edit ng mga plain na config file — tingnan ang [dotfiles](31-dotfiles.md) |

### Talagang magkaiba ang ilang bagay

Maraming setting ang nasa mga text file na ine-edit mo, hindi sa mga panel na kini-click mo. Mukhang primitive iyon hanggang sa mapagtanto mo na ibig sabihin niyon, bawat tweak ay makikita, makokopya sa susunod mong machine, at mailalagay sa version control. Ididiretso ka ng menu na _Setup_ sa tamang file at ire-restart nito ang anumang kailangang i-restart kapag tapos ka na.

Dumarating ang mga update sa pamamagitan ng iisang command — _Update > Omarchy_ — na nag-a-update sa Omarchy mismo at sa bawat package sa system, at kumukuha muna ng snapshot. Walang mga per-app updater na nangungulit sa iyo nang random. Tingnan ang [mga update](30-updates.md).

Nagmumula ang software sa isang package manager, hindi sa mga na-download na installer.

At kapag nagsara ka ng window, talagang nagsasara ang app. Walang macOS limbo kung saan patuloy na tumatakbo ang programa nang walang mga window. Ang `Super + W` — o `Super + Q`, kung iyon ang finger memory na dala mo pagdating — ay nangangahulugang wala na.

### Sa Mac hardware

Maganda ang takbo ng Omarchy sa mga Intel Mac — tingnan ang [suporta sa Mac](44-mac-support.md). At mabait ang keyboard sa iyo: walang nire-remap ang Omarchy, at itinuturing ng Linux ang Command key bilang Super, kaya ang Super ay nasa eksaktong kinalalagyan ng Cmd dati. Hindi mapapansin ng hinlalaki mo ang paglipat.

### Bigyan mo ito ng dalawang linggo

Mas mabilis mailipat ang mga instinct kaysa sa inaakala mo. Basahin nang mabilis ang kabanata tungkol sa [mga hotkey](07-hotkeys.md) nang isang beses, at tuwing mabablangko ka sa isang binding, pindutin ang `Super + K` — ipinapakita nito ang lahat ng mga iyon sa iyo. Iyon lang ang hotkey na talagang kailangan mong kabisaduhin.
