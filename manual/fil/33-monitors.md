# Mga Monitor

Ipinagpapalagay ng Omarchy na gumagamit ka ng display na may kakayahang 2x at kasing-antas ng retina bilang default. Ito ang kailangan mo para makuha ang magaganda at malilinaw na font para sa programmer. Ito ang ino-optimize para sa halos lahat ng bagong premium na laptop na may mga screen na mataas ang resolution. Ito ang gugustuhin mong gamitin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ngunit kung hindi ka gumagamit ng display na may PPI na 218 o mas mataas, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang pumili ng fractional scale para dito mula sa panel ng monitor sa top bar, o itakda ang default para sa bawat monitor sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` at paglipat sa rekomendasyon para sa kombinasyong iyon:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kung gumagamit ka ng display na 1080p o 1440p, malamang na gugustuhin mo lang gumamit ng 1x scaling, at ganoon din para sa mga GTK at X11 app, kaya maaari mong gamitin ang:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Nalalapat ang mga pagbabago sa `GDK_SCALE` sa mga application na sinimulan pagkatapos ng pagbabago (at buong numero lang ang tinatanggap ng GTK, kaya panatilihin ito sa pinakamalapit na integer ng scale ng monitor mo). Kaya siguraduhing isara mo ang mga window na mayroon kang napakalaki pagkatapos ng pagbabago (o isara lahat ng window gamit ang `Ctrl + Alt + Del`!).

Maaari mo ring mabilis na pagpalit-palitin ang mga pangunahing ratio ng scaling ng monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para tumaas at `Super + Alt + /` para bumaba, o pumili ng isa mula sa panel ng monitor sa top bar. Binabago lang nito ang monitor na naka-focus sa iyo, kaya maaaring magkaroon ng sariling scale ang screen ng laptop at ang external na display. Itinatakda rin ng panel ang resolution ng bawat monitor. Sine-save ang mga pinili mo para sa pisikal na monitor na iyon sa `~/.local/state/omarchy/monitors/settings`, kaya nananatili ang mga ito pagkatapos mag-reboot at sumusunod sa monitor sa anumang port o dock na pagsasaksakan mo dito sa susunod. Mas mahalaga ang mga ito kaysa sa anumang rule para sa parehong monitor sa `~/.config/hypr/monitors.lua`, na hindi kailanman ine-edit ng Omarchy. Dahil iisang value lang ang `GDK_SCALE` para sa lahat ng screen, itinatakda ito ng napiling scale mula sa monitor na may pinakamababang scale, kaya medyo lumiliit ang mga X11 app sa mas siksik na screen sa halip na lumaki nang sobra sa kabila.

### Pagpapalaki o pagpapaliit ng text

Binabago ng scaling ng monitor ang laki ng lahat. Kung ang gusto mo lang ay mas malaki o mas maliit na _text_, may iisang knob para diyan:

```
omarchy display text size 14
```

Tumatanggap iyon ng laki ng pixel sa pagitan ng 9 at 20, at sabay na inililipat ang shell ng Omarchy, mga GTK application, at ang terminal mo, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argument para makita kung nasaan ka na, at `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya pinapanatili ng mga tumatakbong terminal ang lumang laki nila hanggang magbukas ka ng bago.

### Pagpapalawak at pag-mirror ng mga display ng laptop

Kapag nagkonekta ka ng external na screen sa laptop mo, awtomatikong pinapalawak ang display. Ngunit maaari mong baguhin iyon at gawing pag-mirror sa halip gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Alt + Delete`. Lalo itong kapaki-pakinabang kung projector ang external na screen na iyon, at gusto mong may ipakita habang nagtatrabaho.

Kapag nagpapalawak ka, awtomatikong mamamatay ang internal na screen kapag isinara mo ang takip ng laptop. Bubukas itong muli kapag binuksan mo ang takip. Maaari mo rin itong kontrolin nang manu-mano gamit ang _Trigger > Hardware_ sa menu ng Omarchy o `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Mahusay gumana ang Hyprland sa maraming screen. Iginuguhit sila ng panel ng monitor sa top bar kung saan sila nakaupo: i-drag ang isa sa gilid ng isa pa para ilipat ito roon, at sine-save ang ayos kasama ng iba pang setting ng bawat monitor. Para sa anumang hindi sakop ng panel, magbasa pa tungkol sa kung paano ayusin ang mga ito sa [dokumentasyon ng Hyprland para sa mga monitor](https://wiki.hypr.land/Configuring/Basics/Monitors/). Sa Omarchy, napupunta ang mga ito sa `~/.config/hypr/monitors.lua` bilang mga entry na `hl.monitor` — may kasamang mga halimbawang naka-comment ang file para sa pag-pin ng isang partikular na monitor sa isang resolution, posisyon, at rotation.

May sariling workspace 1 hanggang 10 ang bawat monitor, kaya ang `Super + 1` ay palaging nangangahulugang unang workspace ng monitor na kinaroroonan mo. Sa likod ng eksena, binibilang pa rin ng Hyprland ang mga workspace sa lahat ng monitor: nakukuha ng screen ng laptop mo (o unang monitor) ang 1–10, ang susunod na monitor ang 11–20, at iba pa, at pinapanatili ng bawat monitor ang block nito sa tuwing isasaksak mo ito. Gamitin ang mga numerong iyon kung magsusulat ka ng [mga rule para sa workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o mga rule para sa window para sa isang partikular na monitor, kaya ang workspace 12 ay ang pangalawang workspace ng pangalawa mong monitor. Inililista ng `~/.local/state/omarchy/monitors/workspaces` kung aling block ang mayroon ang bawat monitor.

Gumagana ang mga arrow key sa mga monitor na may magkatabing gilid sa layout mo. Ang mga screen na nagkakadikit lang sa isang sulok, o may puwang sa pagitan, ay hindi magkapitbahay, kaya gamitin ang `Ctrl + Alt + Tab` para makapunta sa pagitan ng mga ito.

| Hotkey | Sa iba't ibang monitor |
| --- | --- |
| `Super + Arrow` | Inililipat ang focus sa monitor sa gilid na iyon kapag wala nang window na natitira sa direksyong iyon |
| `Super + Shift + Arrow` | Nakikipagpalit sa isang window sa monitor sa gilid na iyon |
| `Super + Alt + Arrow` | Inililipat ang window sa isang grupo sa monitor sa gilid na iyon |
| `Super + Shift + Ctrl + Arrow` | Inililipat ang window sa monitor sa gilid na iyon, sa workspace na ipinapakita nito |
| `Super + Shift + Alt + Arrow` | Inililipat ang workspace sa monitor sa gilid na iyon, pinapanatili ang numero nito kung libre ito |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Inililipat ang focus sa susunod o nakaraang monitor, anuman ang layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Nananatili sa monitor na kinaroroonan mo |

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI na tutulong sa iyo sa pagpoposisyon ng maraming screen.

### Pagkontrol sa liwanag

Kinokontrol ang liwanag ng monitor ng mga nakalaang function key para sa pagpapataas/pagpapababa ng liwanag. Kung pipindutin mo nang matagal ang shift habang pinipindot ang mga ito, mapupunta ka sa pinakamataas o pinakamababang liwanag. Kinokontrol ng mga key ang display na naka-focus sa iyo, kaya ina-adjust ang mga external na monitor na nagsasalita ng DDC/CI sa parehong paraan tulad ng screen ng laptop.

### Mga Display ng Apple

Kung gumagamit ka ng display ng Apple, awtomatiko ring gagana ang mga regular na key para sa liwanag sa keyboard, kung naka-focus ka sa display ng Apple. Ginagawa ito sa pamamagitan ng command na `asdcontrol`.

Tandaan na kung gumagamit ka ng display na Apple 6K XDR, maaaring makakita ka ng phantom na screen sa listahan ng `hyprctl monitors` mo. Maaari mo itong patayin gamit ang tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa `~/.config/hypr/monitors.lua`.

Sa mga makinang Intel, dapat kang kumonekta sa mga display ng Apple gamit ang regular na kableng Thunderbolt. Sa iba pang makinang walang Thunderbolt, karaniwang kailangan mong gumamit ng [kableng DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para mapagana ito.
