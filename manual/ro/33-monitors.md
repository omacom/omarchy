# Monitoare

Omarchy presupune că rulezi implicit pe un afișaj de clasă retina, capabil 2x. Aceasta este ce-ți trebuie ca să obții acele fonturi de programator plăcute și clare. Este pentru ce sunt optimizate aproape toate laptopurile premium noi, cu ecrane de rezoluție înaltă. Este ce ai vrea să rulezi pe un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K sau pe un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Dar dacă nu rulezi un afișaj cu un PPI de 218 sau mai mare, vei vrea să schimbi setările monitorului. De exemplu, dacă ai un 4K de 27" sau 32", poți folosi scalarea fracționară deschizând `~/.config/hypr/monitors.lua` (prin _Configurare > Monitoare_ în meniul Omarchy) și trecând la recomandarea pentru acea combinație:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Dacă folosești un afișaj 1080p sau 1440p, probabil vei vrea pur și simplu să folosești scalarea 1x, așa că poți folosi:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Schimbările la `GDK_SCALE` se aplică aplicațiilor pornite după schimbare (și GTK onorează doar numere întregi, așa că ține-l la cel mai apropiat întreg al scalei monitorului tău). Așadar, asigură-te că ieși din ferestrele pe care le ai supradimensionate după schimbare (sau închide toate ferestrele cu `Ctrl + Alt + Del`!).

Poți, de asemenea, să parcurgi rapid rapoartele majore de scalare ale monitorului (1x, 1,25x, 1,6x, 2x, 3x, 4x) folosind `Super + /` ca să mergi mai sus și `Super + Alt + /` ca să mergi mai jos. Dacă ai configurația implicită, aceste schimbări vor persista și după repornire.

### Cum faci textul mai mare sau mai mic

Scalarea monitorului schimbă mărimea tuturor lucrurilor. Dacă tot ce vrei este un _text_ mai mare sau mai mic, există un singur buton pentru asta:

```
omarchy display text size 14
```

Asta ia o mărime în pixeli între 9 și 20 și mișcă împreună shell-ul Omarchy, aplicațiile GTK și terminalul tău, astfel încât întregul desktop să rămână în proporție. Ruleaz-o fără argument ca să vezi unde ești și `omarchy display text size reset` ca să te întorci la implicit. Foot este singurul întârziat: nu are nicio cale să-și reîncarce configurația, așa că terminalele care rulează își păstrează mărimea veche până deschizi unul nou.

### Extinderea și oglindirea afișajelor de laptop

Când conectezi un ecran extern la laptopul tău, afișajul este extins automat. Dar poți schimba asta în oglindire folosind în schimb _Declanșator > Hardware_ în meniul Omarchy sau `Super + Ctrl + Alt + Delete`. Asta este deosebit de util dacă acel ecran extern este un proiector și vrei să arăți ceva în timp ce lucrezi.

Când extinzi, închiderea capacului laptopului va opri automat ecranul intern. Deschiderea capacului îl va porni din nou. Poți controla asta și manual folosind _Declanșator > Hardware_ în meniul Omarchy sau `Super + Ctrl + Delete`.

### Aranjarea mai multor ecrane

Hyprland funcționează excelent cu mai multe ecrane. Citește mai multe despre cum să le dispui în [documentația Hyprland despre monitoare](https://wiki.hypr.land/Configuring/Basics/Monitors/). Poți [lega și spații de lucru specifice de monitoare specifice](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). În Omarchy, aceste reguli merg în `~/.config/hypr/monitors.lua` ca intrări `hl.monitor` — fișierul vine cu exemple comentate pentru fixarea unui monitor specific la o rezoluție, o poziție și o rotație.

Poți verifica și [Hyprmon](https://github.com/erans/hyprmon/), dacă ai vrea o TUI care să te ajute cu poziționarea mai multor ecrane.

### Controlul luminozității

Luminozitatea monitorului este controlată de tastele funcționale dedicate pentru luminozitate mai sus/mai jos. Dacă ții Shift apăsat în timp ce le apeși pe acestea, vei merge la luminozitatea maximă sau minimă. Tastele controlează afișajul pe care ești focalizat, așa că monitoarele externe care vorbesc DDC/CI sunt ajustate în același fel ca ecranul laptopului.

### Afișaje Apple

Dacă folosești un afișaj Apple, tastele obișnuite de tastatură pentru luminozitate vor funcționa și ele automat, dacă ești focalizat pe afișajul Apple. Asta este făcut prin comanda `asdcontrol`.

Reține că, dacă folosești un afișaj Apple 6K XDR, ai putea vedea un ecran fantomă în listarea ta `hyprctl monitors`. Poți opri asta cu ceva precum `hl.monitor({ output = "DP-2", disabled = true })` prin _Configurare > Monitoare_.

Pe mașinile Intel, ar trebui să te conectezi la afișaje Apple folosind un cablu Thunderbolt obișnuit. Pe alte mașini fără Thunderbolt, va trebui de obicei să folosești un [cablu DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ca să funcționeze.
