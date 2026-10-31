# Mga Monitor

Ipinapalagay ng Omarchy bilang default na gumagamit ka ng retina-class na display na may kakayahang 2x. Ito ang kailangan mo para makuha ang magaganda at malilinaw na programmer fonts na iyon. Ito ang ino-optimize para sa halos lahat ng bagong premium laptops na may high-resolution screens. Ito ang gugustuhin mong gamitin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ngunit kung hindi ka gumagamit ng display na may PPI na 218 o mas mataas, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang pumili ng fractional scale para dito mula sa monitor panel sa top bar, o itakda ang default para sa bawat monitor sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` at paglipat sa rekomendasyon para sa combo na iyon:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kung gumagamit ka ng 1080p o 1440p display, malamang na gugustuhin mo lang gumamit ng 1x scaling, at ganoon din para sa GTK at X11 apps, kaya maaari mong gamitin ang:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Ang mga pagbabago sa `GDK_SCALE` ay naaangkop sa mga application na sinimulan pagkatapos ng pagbabago (at buong numero lamang ang sinusunod ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya siguraduhing isara ang mga window na mayroon kang napakalaki pagkatapos ng pagbabago (o isara ang lahat ng window gamit ang `Ctrl + Alt + Del`!).

Mabilis ka ring makakapagpalipat-lipat sa mga pangunahing ratio ng monitor scaling (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba, o pumili ng isa mula sa monitor panel sa top bar. Binabago lamang nito ang monitor na kasalukuyang naka-focus sa iyo, kaya maaaring magkaroon ng sariling scale ang isang laptop screen at isang external display. Itinatakda rin ng panel ang resolution ng bawat monitor. Naka-save ang mga pinili mo para sa pisikal na monitor na iyon sa `~/.local/state/omarchy/monitors/settings`, kaya mananatili ang mga ito kahit mag-reboot at susundan nila ang monitor sa anumang port o dock na susunod itong isaksak. Mas nananaig ang mga ito kaysa anumang panuntunan para sa parehong monitor sa `~/.config/hypr/monitors.lua`, na hindi kailanman ine-edit ng Omarchy. Kung mas gusto mong itakda nang buo ang iyong mga monitor sa file na iyon, idagdag ang `omarchy_monitor_panel_settings = false` dito, at ang mga pagbabago ng panel ay tatagal lamang hanggang mag-reload ang Hyprland. Dahil iisang halaga ang `GDK_SCALE` para sa lahat ng screen, itinatakda ito ng isang piniling scale mula sa monitor na may pinakamababang scale, kaya medyo maliit ang lalabas na X11 apps sa mas siksik na screen sa halip na napakalaki sa kabila.

### Pagpapalaki o pagpapaliit ng text

Binabago ng monitor scaling ang laki ng lahat. Kung ang gusto mo lang ay mas malaki o mas maliit na _text_, iisa lang ang knob para diyan:

```
omarchy display text size 14
```

Tumatanggap ito ng pixel size sa pagitan ng 9 at 20, at sabay-sabay nitong ginagalaw ang Omarchy shell, mga GTK application, at ang iyong terminal, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya mananatili ang lumang laki ng mga tumatakbong terminal hanggang magbukas ka ng bago.

### Pagpapalawak at pag-mirror ng mga display ng laptop

Kapag ikinonekta mo ang isang external screen sa iyong laptop, awtomatikong pinapalawak ang display. Ngunit maaari mong baguhin iyon at gawing mirroring sa halip gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Alt + Delete`. Lalo itong kapaki-pakinabang kung projector ang external screen na iyon, at gusto mong may ipakita habang nagtatrabaho.

Kapag nagpapalawak ka, ang pagsasara ng takip ng laptop ay awtomatikong magpapatay sa internal screen. Ang pagbubukas ng takip ay magbubukas ulit nito. Maaari mo rin itong kontrolin nang manu-mano gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Napakahusay ng Hyprland sa maraming screen. Iginuguhit sila ng monitor panel sa top bar kung saan sila nakaupo: i-drag ang isa sa gilid ng isa pa para ilipat ito doon, at mase-save ang pagkakaayos kasama ng iba pang mga setting ng bawat monitor. Para sa anumang hindi sakop ng panel, magbasa pa tungkol sa kung paano ayusin ang mga ito sa [dokumentasyon ng Hyprland tungkol sa mga monitor](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, napupunta ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga entry na `hl.monitor` — may kasamang mga halimbawang naka-comment ang file para sa pag-pin ng isang partikular na monitor sa isang resolution, position, at rotation.

Ang bawat monitor ay may sariling workspaces 1 hanggang 10, kaya ang `Super + 1` ay palaging nangangahulugang ang unang workspace ng monitor na kinaroroonan mo. Sa likod ng eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: makakakuha ang iyong laptop screen (o unang monitor) ng 1–10, ang susunod na monitor ng 11–20, at iba pa, at pananatilihin ng bawat monitor ang block nito sa tuwing isasaksak mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [mga panuntunan sa workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o mga panuntunan sa window para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng iyong pangalawang monitor. Inililista ng `~/.local/state/omarchy/monitors/workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa mga monitor na magkatabi ang isang edge sa iyong layout. Ang mga screen na nagdidikit lang sa isang sulok, o may puwang sa pagitan nila, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makapunta sa pagitan nila.

| Hotkey | Sa iba't ibang monitor |
| --- | --- |
| `Super + Arrow` | Inililipat ang focus sa monitor sa panig na iyon kapag wala nang natitirang window sa direksyong iyon |
| `Super + Shift + Arrow` | Nakikipagpalit sa isang window sa monitor sa panig na iyon |
| `Super + Alt + Arrow` | Inililipat ang window sa isang group sa monitor sa panig na iyon |
| `Super + Shift + Ctrl + Arrow` | Inililipat ang window sa monitor sa panig na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Inililipat ang workspace sa monitor sa panig na iyon, pinananatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Inililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Mananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng isang TUI na tutulong sa iyo sa pagpoposisyon ng maraming screen.

### Pagkontrol sa liwanag

Kinokontrol ang liwanag ng monitor ng mga nakalaang function key para sa pagtaas/pagbaba ng liwanag. Kung pipindutin nang matagal ang shift habang pinipindot ang mga ito, mapupunta ka sa maximum o minimum na liwanag. Kinokontrol ng mga key ang display na naka-focus sa iyo, kaya ang mga external monitor na nakikipag-usap sa DDC/CI ay inaayos sa parehong paraan tulad ng laptop screen.

### Mga Display ng Apple

Kung gumagamit ka ng Apple display, awtomatikong gagana rin ang mga regular na keyboard brightness key, kung naka-focus ka sa Apple display. Ginagawa ito sa pamamagitan ng command na `asdcontrol`.

Tandaan na kung gumagamit ka ng Apple 6K XDR display, maaari kang makakita ng phantom screen sa iyong listahan ng `hyprctl monitors`. Maaari mo itong i-off gamit ang tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa `~/.config/hypr/monitors.lua`.

Sa mga Intel machine, dapat kang kumonekta sa mga Apple display gamit ang isang regular na Thunderbolt cable. Sa iba pang mga machine na walang Thunderbolt, karaniwang kailangan mong gumamit ng [kable na DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para gumana ito.
