# Mga Monitor

Ipinapalagay ng Omarchy bilang default na tumatakbo ka sa isang display na pang-retina at may kakayahang 2x. Ito ang kailangan mo para makuha ang maganda at malinaw na mga programmer font na iyon. Ito ang pinag-optimize-an ng halos lahat ng bagong premium na laptop na may mga high-resolution screen. Ito ang gugustuhin mong patakbuhin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ngunit kung hindi ka tumatakbo sa isang display na may PPI na 218 o mas mataas pa, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang pumili ng fractional scale para rito mula sa monitor panel sa top bar, o itakda ang default para sa bawat monitor sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` at paglipat sa rekomendasyon para sa combo na iyon:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kung gumagamit ka ng 1080p o 1440p display, malamang na gugustuhin mo lang gumamit ng 1x scaling, at ganoon din para sa mga GTK at X11 app, kaya maaari mong gamitin ang:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Nalalapat ang mga pagbabago sa `GDK_SCALE` sa mga application na sinimulan pagkatapos ng pagbabago (at buong numero lamang ang tinatanggap ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya tiyaking isasara mo ang mga window na mayroon kang napakalaki pagkatapos ng pagbabago (o isara ang lahat ng window gamit ang `Ctrl + Alt + Del`!).

Mabilis ka ring makakahakbang sa mga pangunahing ratio ng monitor scaling (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba, o pumili ng isa mula sa monitor panel sa top bar. Binabago lamang ng mga ito ang monitor na pinagtutuunan mo, kaya maaaring magkaroon ng sariling scale ang screen ng laptop at ang isang external display. Itinatakda rin ng panel ang resolution, refresh rate at rotation ng bawat monitor. Sine-save ang mga pinili mo para sa pisikal na monitor na iyon sa `~/.local/state/omarchy/monitors/settings`, kaya mananatili ang mga ito pagkatapos mag-reboot at susundan ang monitor sa anumang port o dock na susunod itong isaksak. Nauuna ang mga ito kaysa sa anumang panuntunan para sa parehong monitor sa `~/.config/hypr/monitors.lua`, na hindi kailanman ine-edit ng Omarchy. Kung mas gugustuhin mong itakda ang iyong mga monitor nang buo sa file na iyon, idagdag ang `omarchy_monitor_panel_settings = false` rito, at tatagal lamang ang mga pagbabago ng panel hanggang mag-reload ang Hyprland. Dahil ang `GDK_SCALE` ay isang value para sa lahat ng screen, itinatakda ito ng napiling scale mula sa monitor na may pinakamababang scale, kaya lumalabas na medyo maliit ang mga X11 app sa mas siksik na screen sa halip na napakalaki sa kabila.

### Pagpapalaki o pagpapaliit ng teksto

Binabago ng monitor scaling ang laki ng lahat. Kung ang gusto mo lang ay mas malaki o mas maliit na _teksto_, may isang knob lang para roon:

```
omarchy display text size 14
```

Tumatanggap iyan ng laki sa pixel sa pagitan ng 9 at 20, at sabay nitong ginagalaw ang Omarchy shell, mga GTK application, at ang iyong terminal, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya pinapanatili ng mga tumatakbong terminal ang lumang laki hanggang magbukas ka ng bago.

### Pag-extend at pag-mirror ng mga display ng laptop

Kapag ikinonekta mo ang isang external screen sa laptop mo, awtomatikong naka-extend ang display. Ngunit maaari mong baguhin iyan sa pag-mirror sa halip gamit ang _Extend_ | _Mirror_ sa monitor panel sa top bar, _Trigger > Hardware_ sa menu ng Omarchy, o `Super + Ctrl + Alt + Delete`. Lalo itong kapaki-pakinabang kung projector ang external screen na iyan, at gusto mong may ipakita habang nagtatrabaho.

Kapag nag-e-extend ka, ang pagsasara ng takip ng laptop ay awtomatikong papatay sa internal screen. Ang pagbubukas ng takip ay bubuksan itong muli. Maaari mo rin itong kontrolin nang mano-mano gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Mahusay gumana ang Hyprland sa maraming screen. Iginuguhit sila ng monitor panel sa top bar kung saan sila nakaupo: i-drag ang isa laban sa gilid ng isa pa para ilipat ito roon, at sine-save ang ayos kasama ng iba pang setting ng bawat monitor. Para sa anumang hindi saklaw ng panel, magbasa pa tungkol sa kung paano ayusin ang mga ito sa [dokumentasyon sa monitor ng Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, napupunta ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga entry na `hl.monitor` — kasama sa file ang mga naka-comment na halimbawa para sa pananatiling naka-off ng isang monitor, mga mode na hindi inaalok ng panel, 10-bit color, at variable refresh rate.

May sariling mga workspace 1 hanggang 10 ang bawat monitor, kaya ang `Super + 1` ay palaging nangangahulugang unang workspace ng monitor na kinaroroonan mo. Sa likod ng eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: nakukuha ng screen ng laptop mo (o unang monitor) ang 1–10, ang susunod na monitor ang 11–20, at iba pa, at pinapanatili ng bawat monitor ang block nito sa tuwing ikakabit mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [mga panuntunan sa workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o mga panuntunan sa window para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng pangalawang monitor mo. Inililista ng `~/.local/state/omarchy/monitors/workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa mga monitor na may magkasamang gilid sa layout mo. Ang mga screen na nagkakadikit lamang sa isang sulok, o may puwang sa pagitan, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makapunta sa pagitan ng mga ito.

| Hotkey | Sa iba't ibang monitor |
| --- | --- |
| `Super + Arrow` | Ililipat ang focus sa monitor sa panig na iyon kapag wala nang window na natitira sa direksyong iyon |
| `Super + Shift + Arrow` | Makikipagpalit sa isang window sa monitor sa panig na iyon |
| `Super + Alt + Arrow` | Ililipat ang window sa isang grupo sa monitor sa panig na iyon |
| `Super + Shift + Ctrl + Arrow` | Ililipat ang window sa monitor sa panig na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Ililipat ang workspace sa monitor sa panig na iyon, pinapanatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Ililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Mananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI na tutulong sa iyo sa pagpoposisyon ng maraming screen.

### Pagkontrol sa liwanag

Kinokontrol ang liwanag ng monitor ng mga nakalaang function key para sa pagpapataas/pagpapababa ng liwanag. Kung pipindutin mo ang shift habang pinipindot ang mga ito, pupunta ka sa pinakamataas o pinakamababang liwanag. Kinokontrol ng mga key ang display na pinagtutuunan mo, kaya ina-adjust ang mga external monitor na nakikipag-usap ng DDC/CI sa parehong paraan tulad ng screen ng laptop.

### Mga Apple Display

Kung gumagamit ka ng Apple display, awtomatiko ring gagana ang mga regular na keyboard brightness key, kung nakatuon ka sa Apple display. Ginagawa ito sa pamamagitan ng utos na `asdcontrol`.

Tandaan na kung gumagamit ka ng Apple 6K XDR display, maaaring makakita ka ng phantom screen sa listahan ng `hyprctl monitors` mo. Maaari mo itong i-off gamit ang tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa `~/.config/hypr/monitors.lua`.

Sa mga Intel machine, dapat kang kumonekta sa mga Apple display gamit ang regular na Thunderbolt cable. Sa ibang machine na walang Thunderbolt, karaniwan mong kakailanganing gumamit ng [DP + USB-A -> USB-C na kable](https://www.amazon.com/dp/B0BNX7MS6N) para mapagana ito.
