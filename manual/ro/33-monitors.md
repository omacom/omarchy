# Monitoare

Omarchy presupune că rulezi implicit pe un ecran de clasă retina, capabil de 2x. De asta ai nevoie ca să obții acele fonturi de programator frumoase și clare. Pentru asta sunt optimizate aproape toate laptopurile premium noi cu ecrane de înaltă rezoluție. Asta ai vrea să rulezi pe un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K sau pe un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Dar dacă nu rulezi un ecran cu un PPI de 218 sau mai mare, vei vrea să schimbi setările monitorului. De exemplu, dacă ai un 4K de 27" sau 32", poți alege o scară fracționară pentru el din panoul pentru monitor din bara de sus sau poți seta valoarea implicită pentru fiecare monitor deschizând `~/.config/hypr/monitors.lua` și trecând la recomandarea pentru combinația respectivă:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Dacă folosești un ecran 1080p sau 1440p, probabil vei vrea pur și simplu să folosești scalarea 1x, și la fel pentru aplicațiile GTK și X11, așa că poți folosi:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Modificările aduse `GDK_SCALE` se aplică aplicațiilor pornite după modificare (iar GTK acceptă doar numere întregi, așa că păstrează-l la cel mai apropiat număr întreg de scara monitorului tău). Așa că asigură-te că închizi ferestrele pe care le ai și care sunt supradimensionate după modificare (sau închide toate ferestrele cu `Ctrl + Alt + Del`!).

De asemenea, poți parcurge rapid rapoartele majore de scalare a monitorului (1x, 1.25x, 1.6x, 2x, 3x, 4x) folosind `Super + /` ca să urci și `Super + Alt + /` ca să cobori sau poți alege unul din panoul pentru monitor din bara de sus. Acestea schimbă doar monitorul pe care ești concentrat, așa că ecranul unui laptop și un ecran extern pot avea fiecare scara proprie. Panoul setează și rezoluția fiecărui monitor. Alegerile tale sunt salvate pentru acel monitor fizic în `~/.local/state/omarchy/monitors/settings`, așa că persistă după repornire și urmează monitorul la orice port sau dock la care este conectat data viitoare. Ele au prioritate față de orice regulă pentru același monitor din `~/.config/hypr/monitors.lua`, pe care Omarchy nu îl editează niciodată. Dacă preferi să-ți setezi monitoarele în întregime în acel fișier, adaugă `omarchy_monitor_panel_settings = false` în el, iar modificările din panou vor dura doar până când Hyprland se reîncarcă. Deoarece `GDK_SCALE` este o singură valoare pentru toate ecranele, o scară aleasă o setează de la monitorul cu cea mai mică scară, așa că aplicațiile X11 ies puțin mici pe ecranul mai dens, mai degrabă decât supradimensionate pe celălalt.

### Cum mărești sau micșorezi textul

Scalarea monitorului schimbă dimensiunea tuturor lucrurilor. Dacă tot ce vrei este un _text_ mai mare sau mai mic, există un singur buton pentru asta:

```
omarchy display text size 14
```

Acesta acceptă o dimensiune în pixeli între 9 și 20 și mută împreună shell-ul Omarchy, aplicațiile GTK și terminalul tău, așa că întregul desktop rămâne proporțional. Rulează-l fără argument ca să vezi unde ești și `omarchy display text size reset` ca să revii la valoarea implicită. Foot este singurul rămas în urmă: nu are nicio modalitate de a-și reîncărca configurația, așa că terminalele care rulează își păstrează dimensiunea veche până când deschizi unul nou.

### Extinderea și oglindirea ecranelor de laptop

Când conectezi un ecran extern la laptop, ecranul este extins automat. Dar poți schimba asta în oglindire folosind _Trigger > Hardware_ din meniul Omarchy sau `Super + Ctrl + Alt + Delete`. Acest lucru este deosebit de util dacă acel ecran extern este un proiector și vrei să arăți ceva în timp ce lucrezi.

Când extinzi, închiderea capacului laptopului va opri automat ecranul intern. Deschiderea capacului îl va porni la loc. De asemenea, poți controla acest lucru manual folosind _Trigger > Hardware_ din meniul Omarchy sau `Super + Ctrl + Delete`.

### Aranjarea mai multor ecrane

Hyprland funcționează excelent cu mai multe ecrane. Panoul pentru monitor din bara de sus le desenează acolo unde stau: trage unul lângă marginea altuia ca să-l muți acolo, iar aranjamentul este salvat împreună cu celelalte setări ale fiecărui monitor. Pentru orice nu acoperă panoul, citește mai multe despre cum să le dispui în [documentația Hyprland despre monitoare](https://wiki.hypr.land/Configuring/Basics/Monitors/). În Omarchy, acestea merg în `~/.config/hypr/monitors.lua` ca intrări `hl.monitor` — fișierul vine cu exemple comentate pentru fixarea unui anumit monitor la o rezoluție, poziție și rotație.

Fiecare monitor are propriile spații de lucru de la 1 la 10, așa că `Super + 1` înseamnă întotdeauna primul spațiu de lucru al monitorului pe care ești. În spate, Hyprland numerotează totuși spațiile de lucru pe toate monitoarele: ecranul laptopului tău (sau primul monitor) primește 1–10, următorul monitor 11–20 și așa mai departe, iar fiecare monitor își păstrează blocul de fiecare dată când îl conectezi. Folosește acele numere dacă scrii [reguli pentru spații de lucru](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) sau reguli pentru ferestre pentru un anumit monitor, așa că spațiul de lucru 12 este al doilea spațiu de lucru al celui de-al doilea monitor. `~/.local/state/omarchy/monitors/workspaces` listează ce bloc are fiecare monitor.

Tastele săgeată funcționează între monitoarele care împart o margine în dispunerea ta. Ecranele care se ating doar la un colț sau care au un spațiu între ele nu sunt vecine, așa că folosește `Ctrl + Alt + Tab` ca să ajungi între ele.

| Tastă rapidă | Între monitoare |
| --- | --- |
| `Super + Arrow` | Mută focalizarea pe monitorul din acea parte odată ce nu mai există nicio fereastră în acea direcție |
| `Super + Shift + Arrow` | Interschimbă cu o fereastră de pe monitorul din acea parte |
| `Super + Alt + Arrow` | Mută fereastra într-un grup de pe monitorul din acea parte |
| `Super + Shift + Ctrl + Arrow` | Mută fereastra pe monitorul din acea parte, pe spațiul de lucru pe care îl afișează |
| `Super + Shift + Alt + Arrow` | Mută spațiul de lucru pe monitorul din acea parte, păstrându-și numărul dacă este liber |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mută focalizarea pe monitorul următor sau anterior, indiferent de dispunere |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Rămân pe monitorul pe care ești |

De asemenea, poți consulta [Hyprmon](https://github.com/erans/hyprmon/), dacă ai vrea un TUI care să te ajute la poziționarea mai multor ecrane.

### Controlul luminozității

Luminozitatea monitorului este controlată de tastele funcționale dedicate pentru creșterea/reducerea luminozității. Dacă ții apăsat shift în timp ce apeși aceste taste, vei ajunge la luminozitatea maximă sau minimă. Tastele controlează ecranul pe care ești concentrat, așa că monitoarele externe care vorbesc DDC/CI sunt reglate la fel ca ecranul laptopului.

### Ecrane Apple

Dacă folosești un ecran Apple, tastele obișnuite de luminozitate de pe tastatură vor funcționa și ele automat, dacă ești concentrat pe ecranul Apple. Acest lucru se face prin comanda `asdcontrol`.

Reține că, dacă folosești un ecran Apple 6K XDR, este posibil să vezi un ecran fantomă în listarea ta `hyprctl monitors`. Poți dezactiva acest lucru cu ceva de genul `hl.monitor({ output = "DP-2", disabled = true })` în `~/.config/hypr/monitors.lua`.

Pe mașinile Intel, ar trebui să te conectezi la ecranele Apple folosind un cablu Thunderbolt obișnuit. Pe alte mașini fără Thunderbolt, de obicei va trebui să folosești un [cablu DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ca să funcționeze.
