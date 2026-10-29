# Mga Monitor

Ipinapalagay ng Omarchy na gumagamit ka ng 2x-capable na retina-class na display bilang default. Ito ang kailangan mo para makuha ang magaganda at malilinaw na programmer font na iyon. Dito naka-optimize ang halos lahat ng bagong premium na laptop na may high-resolution na screen. Ito ang gusto mong gamitin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero kung hindi ka gumagamit ng display na may PPI na 218 o mas mataas, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang gumamit ng fractional scaling sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` (sa pamamagitan ng _Setup > Monitors_ sa menu ng Omarchy) at paglipat sa rekomendasyon para sa kombinasyong iyon:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kung gumagamit ka ng 1080p o 1440p na display, malamang na gusto mo lang gumamit ng 1x scaling, kaya maaari mong gamitin ang:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Nalalapat ang mga pagbabago sa `GDK_SCALE` sa mga application na sinimulan pagkatapos ng pagbabago (at buong numero lang ang tinatanggap ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya siguraduhing isara ang mga window na mayroon kang napakalaki pagkatapos ng pagbabago (o isara lahat ng window gamit ang `Ctrl + Alt + Del`!).

Maaari ka ring mabilis na lumipat-lipat sa mga pangunahing ratio ng scaling ng monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba, o pumili ng isa mula sa monitor panel sa top bar. Binabago lang ng mga ito ang monitor na kasalukuyang naka-focus sa iyo, kaya maaaring magkaroon ng sariling scale ang screen ng laptop at ang external display. Sine-save ang pinili sa `~/.config/hypr/monitors.lua` bilang isang `hl.monitor` rule para sa monitor na iyon, kaya mananatili ito kahit mag-reboot at mas mauuna ito kaysa sa `omarchy_monitor_scale`, na mananatiling scale para sa bawat monitor na walang sariling rule. Dahil iisa lang ang `GDK_SCALE` para sa lahat ng screen, itinatakda ito ng mga pagbabagong ito mula sa monitor na may pinakamababang scale, kaya medyo lumiliit ang X11 apps sa mas siksik na screen sa halip na lumaki nang sobra sa kabila.

### Pagpapalaki o pagpapaliit ng teksto

Binabago ng scaling ng monitor ang laki ng lahat. Kung ang gusto mo lang ay mas malaki o mas maliit na _teksto_, may iisang knob para diyan:

```
omarchy display text size 14
```

Tumatanggap iyan ng pixel size sa pagitan ng 9 at 20, at sabay-sabay nitong ginagalaw ang Omarchy shell, mga GTK application, at ang terminal mo, kaya mananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya mananatili ang lumang laki sa mga tumatakbong terminal hanggang magbukas ka ng bago.

### Pag-extend at pag-mirror ng mga display ng laptop

Kapag nagkonekta ka ng external screen sa laptop mo, awtomatikong mae-extend ang display. Pero maaari mong baguhin iyon at gawing mirroring sa halip gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Alt + Delete`. Lalo itong nakakatulong kung projector ang external screen na iyon, at gusto mong may ipakita habang nagtatrabaho.

Kapag naka-extend ka, awtomatikong mamamatay ang internal screen kapag isinara mo ang takip ng laptop. Bubukas ulit ito kapag binuksan mo ang takip. Maaari mo rin itong kontrolin nang mano-mano gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Mahusay gumana ang Hyprland sa maraming screen. Magbasa pa tungkol sa kung paano i-layout ang mga ito sa [dokumentasyon sa monitor ng Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, napupunta ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga `hl.monitor` entry — may kasama nang mga naka-comment na halimbawa ang file para sa pag-pin ng isang partikular na monitor sa isang resolution, posisyon, at rotation.

May sariling workspace 1 hanggang 10 ang bawat monitor, kaya ang `Super + 1` ay palaging nangangahulugang ang unang workspace ng monitor na kinaroroonan mo. Sa likod ng eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: nakukuha ng screen ng laptop mo (o unang monitor) ang 1–10, ng susunod na monitor ang 11–20, at iba pa, at pinapanatili ng bawat monitor ang block nito sa tuwing isasaksak mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [mga panuntunan sa workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o mga panuntunan sa window para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng pangalawa mong monitor. Inililista ng `~/.local/state/omarchy/monitor-workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa pagitan ng mga monitor na may magkasamang gilid sa layout mo. Ang mga screen na nagkakadikit lang sa isang sulok, o may puwang sa pagitan, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makalipat sa pagitan ng mga ito.

| Hotkey | Sa pagitan ng mga monitor |
| --- | --- |
| `Super + Arrow` | Inililipat ang focus sa monitor sa gilid na iyon kapag wala nang window na natitira sa direksyong iyon |
| `Super + Shift + Arrow` | Nakikipagpalit sa isang window sa monitor sa gilid na iyon |
| `Super + Alt + Arrow` | Inililipat ang window sa isang grupo sa monitor sa gilid na iyon |
| `Super + Shift + Ctrl + Arrow` | Inililipat ang window sa monitor sa gilid na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Inililipat ang workspace sa monitor sa gilid na iyon, pinapanatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Inililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Mananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI na tutulong sa iyo sa pagpoposisyon ng maraming screen.

### Pagkontrol sa brightness

Kinokontrol ang brightness ng monitor ng mga nakalaang function key para sa pagtaas/pagbaba ng brightness. Kung pipigilan mo ang shift habang pinipindot ang mga ito, mapupunta ka sa maximum o minimum na brightness. Kinokontrol ng mga key ang display na naka-focus sa iyo, kaya ang mga external monitor na nagsasalita ng DDC/CI ay ina-adjust sa parehong paraan tulad ng screen ng laptop.

### Mga Apple Display

Kung gumagamit ka ng Apple display, awtomatikong gagana rin ang mga regular na brightness key sa keyboard, kung naka-focus ka sa Apple display. Ginagawa ito sa pamamagitan ng `asdcontrol` command.

Tandaan na kung gumagamit ka ng Apple 6K XDR display, maaari kang makakita ng phantom screen sa listing ng `hyprctl monitors` mo. Maaari mo itong patayin gamit ang isang bagay tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa pamamagitan ng _Setup > Monitors_.

Sa mga Intel machine, dapat kang kumonekta sa mga Apple display gamit ang regular na Thunderbolt cable. Sa ibang machine na walang Thunderbolt, karaniwang kailangan mong gumamit ng [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) para mapagana ito.
