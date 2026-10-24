# Mga Monitor

Ipinapalagay ng Omarchy na tumatakbo ka sa isang 2x-capable na retina-class display bilang default. Ito ang kailangan mo para makuha ang maganda at malutong na mga programmer font. Ito ang ino-optimize ng halos lahat ng bagong premium laptop na may high-resolution screen. Ito ang gusto mong patakbuhin sa isang 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero kung hindi ka nagpapatakbo ng display na may PPI na 218 o higit pa, gugustuhin mong baguhin ang mga setting ng monitor. Halimbawa, kung mayroon kang 27" o 32" 4K, maaari kang gumamit ng fractional scaling sa pamamagitan ng pagbubukas ng `~/.config/hypr/monitors.lua` (sa pamamagitan ng _Setup > Monitors_ sa Omarchy menu) at paglipat sa rekomendasyon para sa combo na iyon:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kung gumagamit ka ng 1080p o 1440p display, malamang gusto mo lang gumamit ng 1x scaling, kaya maaari mong gamitin:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Nalalapat ang mga pagbabago sa `GDK_SCALE` sa mga application na sinimulan pagkatapos ng pagbabago (at tumatanggap lang ang GTK ng mga buong numero, kaya panatilihin ito sa pinakamalapit na integer ng sukat ng monitor mo). Kaya tiyakin na isara mo ang mga window na mayroon ka na masyadong malaki pagkatapos ng pagbabago (o isara ang lahat ng window gamit ang `Ctrl + Alt + Del`!).

Maaari ka ring mabilis na humakbang sa mga pangunahing ratio ng scaling ng monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) gamit ang `Super + /` para pumunta nang mas mataas at ang `Super + Alt + /` para pumunta nang mas mababa. Kung mayroon ka ng default na configuration, mananatili rin ang mga pagbabagong ito pagkatapos ng reboot.

### Pagpapalaki o pagpapaliit ng teksto

Binabago ng scaling ng monitor ang laki ng lahat. Kung ang gusto mo lang ay mas malaki o mas maliit na _teksto_, mayroong iisang knob para doon:

```
omarchy display text size 14
```

Kumukuha iyon ng pixel size sa pagitan ng 9 at 20, at inililipat ang Omarchy shell, mga GTK application, at ang terminal mo nang magkakasama, kaya nananatiling proporsyonal ang buong desktop. Patakbuhin ito nang walang argumento para makita kung nasaan ka, at ang `omarchy display text size reset` para bumalik sa default. Ang Foot ang nag-iisang nahuhuli: wala itong paraan para i-reload ang config nito, kaya pinapanatili ng mga tumatakbong terminal ang kanilang lumang laki hanggang sa magbukas ka ng bago.

### Pagpapalawak at pag-mirror ng mga display ng laptop

Kapag ikinonekta mo ang isang panlabas na screen sa laptop mo, awtomatikong pinapalawak ang display. Pero maaari mong baguhin iyon sa mirroring sa halip gamit ang _Trigger > Hardware_ sa Omarchy menu o ang `Super + Ctrl + Alt + Delete`. Lalo itong nakakatulong kung ang panlabas na screen na iyon ay isang projector, at gusto mong magpakita ng isang bagay habang nagtatrabaho.

Kapag nagpapalawak ka, ang pagsara ng takip ng laptop ay awtomatikong papatayin ang internal screen. Ang pagbubukas ng takip ay ibabalik ito. Maaari mo rin itong kontrolin nang mano-mano gamit ang _Trigger > Hardware_ sa Omarchy menu o ang `Super + Ctrl + Delete`.

### Pag-aayos ng maraming screen

Gumagana nang mahusay ang Hyprland sa maraming screen. Magbasa pa tungkol sa kung paano ila-layout ang mga ito sa [dokumentasyon ng monitor ng Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Maaari mo ring [i-bind ang mga partikular na workspace sa mga partikular na monitor](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Sa Omarchy, ang mga panuntunang ito ay napupunta sa `~/.config/hypr/monitors.lua` bilang mga `hl.monitor` entry — may kasama ang file na mga halimbawang naka-komento para sa pag-pin ng isang partikular na monitor sa isang resolution, posisyon, at rotation.

Maaari mo ring tingnan ang [Hyprmon](https://github.com/erans/hyprmon/), kung gusto mo ng TUI para tulungan ka sa pagpoposisyon ng maraming screen.

### Pagkontrol ng liwanag

Kinokontrol ang liwanag ng monitor ng mga nakatalagang function key para sa brightness up/down. Kung hahawakan mo ang shift habang pinipindot ang mga ito, pupunta ka sa maximum o minimum na liwanag. Kinokontrol ng mga key ang display na pinagtutuunan mo ng pansin, kaya ang mga panlabas na monitor na nagsasalita ng DDC/CI ay inaayos sa parehong paraan tulad ng screen ng laptop.

### Mga Apple Display

Kung gumagamit ka ng Apple display, gagana rin nang awtomatiko ang mga regular na keyboard brightness key, kung nakatuon ka sa Apple display. Ginagawa ito sa pamamagitan ng `asdcontrol` command.

Tandaan na kung gumagamit ka ng Apple 6K XDR display, maaari kang makakita ng phantom screen sa iyong `hyprctl monitors` listing. Maaari mong i-off ito gamit ang isang bagay tulad ng `hl.monitor({ output = "DP-2", disabled = true })` sa pamamagitan ng _Setup > Monitors_.

Sa mga Intel machine, dapat kang kumonekta sa mga Apple display gamit ang isang regular na Thunderbolt cable. Sa iba pang makina na walang Thunderbolt, karaniwang kakailanganin mong gumamit ng [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) para gumana ito.
