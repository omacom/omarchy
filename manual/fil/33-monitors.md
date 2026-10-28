# Mga Monitor

Ipinapalagay ng Omarchy na gumagamit ka ng 2x-capable na retina-class display bilang default. Ito ang kailangan mo para makuha ang magaganda at malinaw na programmer fonts na iyon. Ito ang ino-optimize para sa halos lahat ng bagong premium laptops na may high-resolution screens. Ito ang gugustuhin mong gamitin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero kung hindi display na may PPI na 218 o mas mataas ang ginagamit mo, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang gumamit ng fractional scaling sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` (sa pamamagitan ng _Setup > Monitors_ sa menu ng Omarchy) at paglipat sa rekomendasyon para sa kombinasyong iyon:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kung 1080p o 1440p display ang ginagamit mo, malamang na 1x scaling lang ang gugustuhin mong gamitin, kaya maaari mong gamitin ang:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ang mga pagbabago sa `GDK_SCALE` ay naaangkop sa mga application na sinimulan pagkatapos ng pagbabago (at buong numero lang ang tinatanggap ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya siguraduhing isara mo ang mga window na mayroon kang napakalaki pagkatapos ng pagbabago (o isara ang lahat ng window gamit ang `Ctrl + Alt + Del`!).

Mabilis ka ring makakapagpalit-palit sa mga pangunahing ratio ng monitor scaling (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba, o pumili ng isa mula sa monitor panel sa top bar. Ang mga ito ay nagbabago lang sa monitor na kasalukuyang naka-focus sa iyo, kaya maaaring magkaroon ng sariling scale ang isang laptop screen at isang external display. Ang pinili ay sine-save sa `~/.config/hypr/monitors.lua` bilang isang `hl.monitor` rule para sa monitor na iyon, kaya nananatili ito kahit mag-reboot at mas nangunguna ito kaysa sa `omarchy_monitor_scale`, na nananatiling scale para sa bawat monitor na walang sariling rule.

### Pagpapalaki o pagpapaliit ng text

Binabago ng monitor scaling ang laki ng lahat. Kung _text_ lang ang gusto mong palakihin o paliitin, may iisang knob para doon:

```
omarchy display text size 14
```

Tumatanggap iyon ng pixel size sa pagitan ng 9 at 20, at sabay-sabay nitong ginagalaw ang Omarchy shell, mga GTK application, at ang terminal mo, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya pinapanatili ng mga tumatakbong terminal ang dati nilang laki hanggang magbukas ka ng bago.

### Pag-extend at pag-mirror ng mga laptop display

Kapag nagkonekta ka ng external screen sa laptop mo, awtomatikong ine-extend ang display. Pero maaari mong baguhin iyon at gawing mirroring sa halip gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Alt + Delete`. Lalo itong nakakatulong kung projector ang external screen na iyon, at may gusto kang ipakita habang nagtatrabaho.

Kapag nag-e-extend ka, ang pagsasara ng takip ng laptop ay awtomatikong papatay sa internal screen. Ang pagbubukas ng takip ay magbubukas ulit dito. Maaari mo rin itong kontrolin nang manu-mano gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Mahusay gumana ang Hyprland sa maraming screen. Magbasa pa tungkol sa kung paano ayusin ang mga ito sa [dokumentasyon ng monitor ng Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, napupunta ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga `hl.monitor` entry — may kasamang mga naka-comment na halimbawa ang file para sa pag-pin ng isang partikular na monitor sa isang resolution, position, at rotation.

Ang bawat monitor ay may sariling workspaces 1 hanggang 10, kaya ang `Super + 1` ay palaging nangangahulugang ang unang workspace ng monitor na kinaroroonan mo. Sa likod ng eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: ang laptop screen mo (o unang monitor) ay nakakakuha ng 1–10, ang susunod na monitor ay 11–20, at iba pa, at pinapanatili ng bawat monitor ang block nito sa tuwing ikokonekta mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o window rules para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng pangalawang monitor mo. Inililista ng `~/.local/state/omarchy/monitor-workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa mga monitor na may magkasamang gilid sa layout mo. Ang mga screen na nagdidikit lang sa isang sulok, o may pagitan sa pagitan nila, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makapunta sa pagitan nila.

| Hotkey | Sa iba't ibang monitor |
| --- | --- |
| `Super + Arrow` | Inililipat ang focus sa monitor sa gilid na iyon kapag wala nang window na natitira sa direksyong iyon |
| `Super + Shift + Arrow` | Nakikipagpalit sa isang window sa monitor sa gilid na iyon |
| `Super + Alt + Arrow` | Inililipat ang window sa isang group sa monitor sa gilid na iyon |
| `Super + Shift + Ctrl + Arrow` | Inililipat ang window sa monitor sa gilid na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Inililipat ang workspace sa monitor sa gilid na iyon, pinapanatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Inililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Nananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI na tutulong sa iyo sa pagpoposisyon ng maraming screen.

### Pagkontrol sa brightness

Kinokontrol ang brightness ng monitor ng mga nakalaang function key para sa brightness up/down. Kung pipindutin mo nang matagal ang shift habang pinipindot ang mga ito, pupunta ka sa maximum o minimum brightness. Kinokontrol ng mga key ang display na naka-focus sa iyo, kaya ang mga external monitor na nagsasalita ng DDC/CI ay ina-adjust sa parehong paraan tulad ng laptop screen.

### Mga Apple Display

Kung gumagamit ka ng Apple display, awtomatiko ring gagana ang mga regular na keyboard brightness key, kung naka-focus ka sa Apple display. Ginagawa ito sa pamamagitan ng `asdcontrol` command.

Tandaan na kung gumagamit ka ng Apple 6K XDR display, maaari kang makakita ng phantom screen sa listing ng `hyprctl monitors` mo. Maaari mo itong i-off gamit ang tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa pamamagitan ng _Setup > Monitors_.

Sa mga Intel machine, dapat kang kumonekta sa mga Apple display gamit ang isang regular na Thunderbolt cable. Sa ibang mga machine na walang Thunderbolt, karaniwang kailangan mong gumamit ng [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) para mapagana ito.
