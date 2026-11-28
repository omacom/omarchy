# Mga Monitor

Ipinagpapalagay ng Omarchy na gumagamit ka ng 2x-capable na retina-class na display bilang default. Ito ang kailangan mo para makuha ang magaganda at malilinaw na programmer fonts na iyon. Ito ang pinag-optimize-an ng halos lahat ng bagong premium na laptop na may high-resolution na mga screen. Ito ang gugustuhin mong gamitin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero kung hindi ka gumagamit ng display na may PPI na 218 o mas mataas, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" na 4K, maaari kang pumili ng fractional scale para dito mula sa monitor panel sa top bar, o itakda ang default para sa bawat monitor sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` at paglipat sa rekomendasyon para sa combo na iyon:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kung gumagamit ka ng 1080p o 1440p na display, malamang na gugustuhin mo lang gumamit ng 1x scaling, at ganoon din para sa GTK at X11 apps, kaya maaari mong gamitin ang:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Ang mga pagbabago sa `GDK_SCALE` ay nalalapat sa mga application na sinimulan pagkatapos ng pagbabago (at buong numero lang ang iginagalang ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya siguraduhing isara mo ang mga window na mayroon ka na masyadong malaki pagkatapos ng pagbabago (o isara ang lahat ng window gamit ang `Ctrl + Alt + Del`!).

Maaari ka ring mabilis na dumaan sa mga pangunahing ratio ng monitor scaling (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba, o pumili ng isa mula sa monitor panel sa top bar. Binabago lang nito ang monitor na naka-focus sa iyo, kaya maaaring magkaroon ng sariling scale ang screen ng laptop at ang isang external display. Itinatakda rin ng panel ang resolution, refresh rate, at rotation ng bawat monitor. Sine-save ang mga pinili mo para sa pisikal na monitor na iyon sa `~/.local/state/omarchy/monitors/settings`, kaya nananatili ang mga ito pagkalipas ng reboot at sumusunod sa monitor sa anumang port o dock na isaksak mo dito sa susunod. Mas matimbang ang mga ito kaysa sa anumang rule para sa parehong monitor sa `~/.config/hypr/monitors.lua`, na hindi kailanman ine-edit ng Omarchy. Kung mas gusto mong itakda ang mga monitor mo nang buo sa file na iyon, idagdag ang `omarchy_monitor_panel_settings = false` dito, at ang mga pagbabago ng panel ay tatagal lang hanggang mag-reload ang Hyprland. Dahil iisang value lang ang `GDK_SCALE` para sa lahat ng screen, itinatakda ito ng isang napiling scale mula sa monitor na may pinakamababang scale, kaya medyo lumiliit ang X11 apps sa mas siksik na screen sa halip na lumaki nang sobra sa kabila.

### Pagpapalaki o pagpapaliit ng text

Binabago ng monitor scaling ang laki ng lahat ng bagay. Kung ang gusto mo lang ay mas malaki o mas maliit na _text_, may iisang knob lang para diyan:

```
omarchy display text size 14
```

Tumatanggap iyan ng pixel size sa pagitan ng 9 at 20, at sabay nitong ginagalaw ang Omarchy shell, mga GTK application, at ang terminal mo, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya pinapanatili ng mga tumatakbong terminal ang lumang laki nila hanggang magbukas ka ng bago.

### Pag-extend at pag-mirror ng mga display ng laptop

Kapag ikinonekta mo ang isang external screen sa laptop mo, awtomatikong ine-extend ang display. Pero maaari mong baguhin iyan at gawing mirroring sa halip gamit ang _Extend_ | _Mirror_ sa monitor panel sa top bar, _Trigger > Hardware_ sa Omarchy menu, o `Super + Ctrl + Alt + Delete`. Lalo itong kapaki-pakinabang kung projector ang external screen na iyon, at gusto mong may ipakita habang nagtatrabaho.

Kapag nag-e-extend ka, ang pagsasara ng takip ng laptop ay awtomatikong papatay sa internal screen. Ang pagbubukas ng takip ay bubuksan itong muli. Maaari mo rin itong kontrolin nang mano-mano gamit ang _Trigger > Hardware_ sa Omarchy menu o `Super + Ctrl + Delete`.

Habang nakasaksak ang laptop, hindi ito natutulog kapag isinara ang takip, kaya nananatiling gising ang isang naka-dock na laptop kahit pansamantalang madiskonekta ang external screen. Kapag walang external screen na nakakabit, ikinakandado lang ito ng pagsasara ng takip habang nasa kuryente. Kapag nasa baterya, nagsu-suspend ito gaya ng dati.

### Pag-aayos ng maraming screen

Magaling ang Hyprland sa maraming screen. Iginuguhit sila ng monitor panel sa top bar kung saan sila nakaupo: i-drag ang isa sa gilid ng isa pa para ilipat ito roon, at sine-save ang pagkakaayos kasama ng iba pang mga setting ng bawat monitor. Para sa anumang hindi saklaw ng panel, magbasa pa tungkol sa kung paano sila i-layout sa [dokumentasyon ng monitor ng Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, napupunta ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga `hl.monitor` entry — may kasamang naka-comment na mga halimbawa ang file para sa pagpapanatiling naka-off ng isang monitor, mga mode na hindi inaalok ng panel, 10-bit color, at variable refresh rate.

May sarili ang bawat monitor na workspaces 1 hanggang 10, kaya ang `Super + 1` ay palaging nangangahulugang ang unang workspace ng monitor na kinaroroonan mo. Sa likod ng mga eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: nakakakuha ang screen ng laptop mo (o unang monitor) ng 1–10, ang susunod na monitor ng 11–20, at iba pa, at pinapanatili ng bawat monitor ang block nito sa tuwing isasaksak mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [mga workspace rule](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o mga window rule para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng pangalawa mong monitor. Inililista ng `~/.local/state/omarchy/monitors/workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa mga monitor na may pinagsasaluhang gilid sa layout mo. Ang mga screen na nagdidikit lang sa isang sulok, o may pagitan sa pagitan nila, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makapunta sa pagitan nila.

| Hotkey | Sa pagitan ng mga monitor |
| --- | --- |
| `Super + Arrow` | Inililipat ang focus sa monitor sa panig na iyon kapag wala nang window na natitira sa direksyong iyon |
| `Super + Shift + Arrow` | Nagpapalit sa isang window sa monitor sa panig na iyon |
| `Super + Alt + Arrow` | Inililipat ang window sa isang grupo sa monitor sa panig na iyon |
| `Super + Shift + Ctrl + Arrow` | Inililipat ang window sa monitor sa panig na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Inililipat ang workspace sa monitor sa panig na iyon, pinapanatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Inililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Nananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI para tulungan ka sa pagpoposisyon ng maraming screen.

### Pagkontrol sa brightness

Kinokontrol ang brightness ng monitor ng mga nakalaang function key para sa brightness up/down. Kung pinipindot mo nang matagal ang shift habang pinipindot ang mga ito, pupunta ka sa maximum o minimum na brightness. Kinokontrol ng mga key ang display na naka-focus sa iyo, kaya ang mga external monitor na nakikipag-usap sa DDC/CI ay inaayos sa parehong paraan gaya ng screen ng laptop.

### Mga Apple Display

Kung gumagamit ka ng Apple display, awtomatiko ring gagana ang mga regular na keyboard brightness key, kung naka-focus ka sa Apple display. Ginagawa ito sa pamamagitan ng `asdcontrol` command.

Tandaan na kung gumagamit ka ng Apple 6K XDR display, maaari kang makakita ng phantom screen sa listahan mo ng `hyprctl monitors`. Maaari mo itong i-off gamit ang tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa `~/.config/hypr/monitors.lua`.

Sa mga Intel machine, dapat kang kumokonekta sa mga Apple display gamit ang regular na Thunderbolt cable. Sa ibang mga machine na walang Thunderbolt, karaniwang kailangan mong gumamit ng [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) para mapagana ito.
