# Mga Monitor

Ipinapalagay ng Omarchy na gumagamit ka ng 2x-capable na retina-class na display bilang default. Ito ang kailangan mo para magkaroon ng magaganda at malilinaw na programmer font na iyon. Ito ang ino-optimize sa halos lahat ng bagong premium na laptop na may mga high-resolution na screen. Ito ang gugustuhin mong gamitin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero kung hindi ka gumagamit ng display na may PPI na 218 o mas mataas, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang gumamit ng fractional scaling sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` (sa pamamagitan ng _Setup > Monitors_ sa menu ng Omarchy) at paglipat sa rekomendasyon para sa kombinasyong iyon:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kung gumagamit ka ng 1080p o 1440p na display, malamang na gugustuhin mo lang gumamit ng 1x scaling, kaya maaari mong gamitin ang:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Nalalapat ang mga pagbabago sa `GDK_SCALE` sa mga application na sinimulan pagkatapos ng pagbabago (at mga buong numero lang ang iginagalang ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya tiyaking isara mo ang mga window na mayroon kang napakalaki pagkatapos ng pagbabago (o isara ang lahat ng window gamit ang `Ctrl + Alt + Del`!).

Maaari ka ring mabilis na lumipat-lipat sa mga pangunahing ratio ng monitor scaling (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba. Kung mayroon kang default na configuration, mananatili rin ang mga pagbabagong ito kahit mag-reboot.

### Pagpapalaki o pagpapaliit ng text

Binabago ng monitor scaling ang laki ng lahat. Kung ang gusto mo lang ay mas malaki o mas maliit na _text_, may iisang knob para diyan:

```
omarchy display text size 14
```

Tumatanggap iyon ng laki ng pixel sa pagitan ng 9 at 20, at sabay-sabay na inililipat ang shell ng Omarchy, mga GTK application, at terminal mo, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya pinapanatili ng mga tumatakbong terminal ang luma nilang laki hanggang magbukas ka ng bago.

### Pagpapalawak at pag-mirror ng mga display ng laptop

Kapag nagkonekta ka ng external na screen sa laptop mo, awtomatikong pinapalawak ang display. Pero maaari mong baguhin iyon para maging mirroring sa halip gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Alt + Delete`. Lalo itong nakakatulong kung projector ang external na screen na iyon, at may gusto kang ipakita habang nagtatrabaho.

Kapag nagpapalawak ka, ang pagsasara ng takip ng laptop ay awtomatikong magpapatay sa internal na screen. Ang pagbubukas ng takip ay muling magbubukas dito. Maaari mo rin itong kontrolin nang manu-mano gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Mahusay gumana ang Hyprland sa maraming screen. Magbasa pa tungkol sa kung paano ayusin ang mga ito sa [dokumentasyon ng monitor ng Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, inilalagay ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga entry na `hl.monitor` — may kasamang mga naka-comment na halimbawa ang file para sa pag-pin ng isang partikular na monitor sa isang resolution, posisyon, at rotation.

May sariling mga workspace 1 hanggang 10 ang bawat monitor, kaya ang `Super + 1` ay palaging nangangahulugang ang unang workspace ng monitor na kinaroroonan mo. Sa likod ng eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: nakukuha ng screen ng laptop mo (o unang monitor) ang 1–10, ng susunod na monitor ang 11–20, at iba pa, at pinapanatili ng bawat monitor ang block nito sa bawat pagkakataong ikinakabit mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [mga panuntunan sa workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o mga panuntunan sa window para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng pangalawang monitor mo. Inililista ng `~/.local/state/omarchy/monitor-workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa mga monitor na may magkasamang gilid sa layout mo. Ang mga screen na nagkakadikit lang sa isang sulok, o may pagitan sa pagitan ng mga ito, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makalipat sa pagitan ng mga ito.

| Hotkey | Sa pagitan ng mga monitor |
| --- | --- |
| `Super + Arrow` | Inililipat ang focus sa monitor sa gilid na iyon kapag wala nang natitirang window sa direksyong iyon |
| `Super + Shift + Arrow` | Nakikipagpalit sa isang window sa monitor sa gilid na iyon |
| `Super + Alt + Arrow` | Inililipat ang window sa isang grupo sa monitor sa gilid na iyon |
| `Super + Shift + Ctrl + Arrow` | Inililipat ang window sa monitor sa gilid na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Inililipat ang workspace sa monitor sa gilid na iyon, pinapanatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Inililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Nananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI na tutulong sa iyo sa pagpoposisyon ng maraming screen.

### Pagkontrol sa liwanag

Kinokontrol ang liwanag ng monitor ng mga nakalaang function key para sa pagpapataas/pagpapababa ng liwanag. Kung pipindutin nang matagal ang shift habang pinipindot ang mga ito, mapupunta ka sa pinakamataas o pinakamababang liwanag. Kinokontrol ng mga key ang display na pinagtutuunan mo, kaya ang mga external na monitor na nagsasalita ng DDC/CI ay inaayos sa parehong paraan tulad ng screen ng laptop.

### Mga Display ng Apple

Kung gumagamit ka ng display ng Apple, awtomatiko ring gagana ang mga regular na keyboard key para sa liwanag, kung nakatuon ka sa display ng Apple. Ginagawa ito sa pamamagitan ng command na `asdcontrol`.

Tandaan na kung gumagamit ka ng Apple 6K XDR na display, maaaring makakita ka ng phantom na screen sa listahan ng `hyprctl monitors` mo. Maaari mo itong patayin gamit ang isang bagay tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa pamamagitan ng _Setup > Monitors_.

Sa mga Intel na machine, dapat kang kumokonekta sa mga display ng Apple gamit ang isang regular na Thunderbolt na kable. Sa ibang mga machine na walang Thunderbolt, karaniwang kailangan mong gumamit ng [kable na DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para mapagana ito.
