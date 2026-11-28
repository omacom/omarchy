# Monitoare

Omarchy presupune că rulezi implicit pe un ecran de clasă retina, capabil de 2x. De asta ai nevoie ca să obții acele fonturi de programator frumoase și clare. Pentru asta sunt optimizate aproape toate laptopurile premium noi, cu ecrane de înaltă rezoluție. Asta ai vrea să rulezi pe un ecran de 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) sau pe un ecran de 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Dar dacă nu rulezi pe un ecran cu un PPI de 218 sau mai mult, vei vrea să schimbi setările monitorului. De exemplu, dacă ai un ecran 4K de 27" sau 32", poți alege o scalare fracționară pentru el din panoul pentru monitoare din bara de sus sau poți seta valoarea implicită pentru fiecare monitor deschizând `~/.config/hypr/monitors.lua` și trecând la recomandarea pentru combinația respectivă:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Dacă folosești un ecran 1080p sau 1440p, probabil vei vrea pur și simplu să folosești scalarea 1x, și la fel și pentru aplicațiile GTK și X11, așa că poți folosi:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Schimbările aduse `GDK_SCALE` se aplică aplicațiilor pornite după schimbare (iar GTK acceptă doar numere întregi, așa că păstrează-l la cel mai apropiat număr întreg de scala monitorului tău). Așa că ai grijă să închizi ferestrele pe care le ai supradimensionate după schimbare (sau închide toate ferestrele cu `Ctrl + Alt + Del`!).

Poți, de asemenea, să treci rapid prin principalele raporturi de scalare ale monitorului (1x, 1.25x, 1.6x, 2x, 3x, 4x) folosind `Super + /` ca să urci și `Super + Alt + /` ca să cobori, sau să alegi unul din panoul pentru monitoare din bara de sus. Acestea schimbă doar monitorul pe care ești concentrat, așa că ecranul laptopului și un ecran extern pot avea fiecare scala proprie. Panoul setează, de asemenea, rezoluția, rata de reîmprospătare și rotația fiecărui monitor. Alegerile tale sunt salvate pentru acel monitor fizic în `~/.local/state/omarchy/monitors/settings`, așa că persistă după repornire și urmează monitorul la orice port sau dock la care îl conectezi data viitoare. Ele au prioritate față de orice regulă pentru același monitor din `~/.config/hypr/monitors.lua`, pe care Omarchy nu îl editează niciodată. Dacă preferi să îți setezi monitoarele în întregime în acel fișier, adaugă `omarchy_monitor_panel_settings = false` în el, iar schimbările din panou vor dura doar până când Hyprland se reîncarcă. Deoarece `GDK_SCALE` este o singură valoare pentru toate ecranele, o scală aleasă îl setează după monitorul cu cea mai mică scală, așa că aplicațiile X11 ies puțin cam mici pe ecranul mai dens, în loc să fie supradimensionate pe celălalt.

### Cum faci textul mai mare sau mai mic

Scalarea monitorului schimbă dimensiunea tuturor elementelor. Dacă tot ce vrei este un _text_ mai mare sau mai mic, există un singur buton pentru asta:

```
omarchy display text size 14
```

Acesta primește o dimensiune în pixeli între 9 și 20 și mișcă împreună shell-ul Omarchy, aplicațiile GTK și terminalul tău, așa că întregul desktop rămâne proporțional. Rulează-l fără argument ca să vezi unde ești, și `omarchy display text size reset` ca să revii la valoarea implicită. Foot este singurul rămas în urmă: nu are nicio modalitate de a-și reîncărca configurația, așa că terminalele care rulează își păstrează dimensiunea veche până când deschizi unul nou.

### Extinderea și oglindirea ecranelor laptopului

Când conectezi un ecran extern la laptop, ecranul este extins automat. Dar poți schimba asta în oglindire, în schimb, cu _Extend_ | _Mirror_ în panoul pentru monitoare din bara de sus, _Trigger > Hardware_ în meniul Omarchy sau `Super + Ctrl + Alt + Delete`. Acest lucru este deosebit de util dacă acel ecran extern este un proiector și vrei să arăți ceva în timp ce lucrezi.

Când extinzi, închiderea capacului laptopului va opri automat ecranul intern. Deschiderea capacului îl va porni la loc. Poți controla acest lucru și manual, folosind _Trigger > Hardware_ în meniul Omarchy sau `Super + Ctrl + Delete`.

Cât timp laptopul este conectat la priză, închiderea capacului nu îl pune niciodată în repaus, așa că un laptop andocat rămâne treaz chiar dacă ecranul extern se deconectează scurt. Fără niciun ecran extern atașat, închiderea capacului când este la priză doar îl blochează. Pe baterie, închiderea capacului suspendă ca de obicei.

### Aranjarea mai multor ecrane

Hyprland funcționează grozav cu mai multe ecrane. Panoul pentru monitoare din bara de sus le desenează acolo unde stau: trage unul lipit de latura altuia ca să îl muți acolo, iar aranjamentul este salvat împreună cu celelalte setări ale fiecărui monitor. Pentru orice nu acoperă panoul, citește mai multe despre cum să le dispui în [documentația Hyprland despre monitoare](https://wiki.hypr.land/Configuring/Basics/Monitors/). În Omarchy, acestea merg în `~/.config/hypr/monitors.lua` ca intrări `hl.monitor` — fișierul vine cu exemple comentate pentru a ține un monitor oprit, moduri pe care panoul nu le oferă, culoare pe 10 biți și rată de reîmprospătare variabilă.

Fiecare monitor are propriile spații de lucru de la 1 la 10, așa că `Super + 1` înseamnă întotdeauna primul spațiu de lucru al monitorului pe care ești. În spate, Hyprland numerotează în continuare spațiile de lucru pe toate monitoarele: ecranul laptopului (sau primul monitor) primește 1–10, următorul monitor 11–20 și așa mai departe, iar fiecare monitor își păstrează blocul de fiecare dată când îl conectezi. Folosește acele numere dacă scrii [reguli pentru spațiile de lucru](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) sau reguli pentru ferestre pentru un monitor anume, astfel că spațiul de lucru 12 este al doilea spațiu de lucru al celui de-al doilea monitor. `~/.local/state/omarchy/monitors/workspaces` listează ce bloc are fiecare monitor.

Tastele săgeată funcționează între monitoarele care împart o margine în dispunerea ta. Ecranele care se ating doar la un colț sau care au un spațiu între ele nu sunt vecine, așa că folosește `Ctrl + Alt + Tab` ca să ajungi între ele.

| Tastă rapidă | Între monitoare |
| --- | --- |
| `Super + Arrow` | Mută focalizarea pe monitorul din acea parte, odată ce nu mai rămâne nicio fereastră în acea direcție |
| `Super + Shift + Arrow` | Schimbă cu o fereastră de pe monitorul din acea parte |
| `Super + Alt + Arrow` | Mută fereastra într-un grup de pe monitorul din acea parte |
| `Super + Shift + Ctrl + Arrow` | Mută fereastra pe monitorul din acea parte, pe spațiul de lucru pe care îl arată |
| `Super + Shift + Alt + Arrow` | Mută spațiul de lucru pe monitorul din acea parte, păstrându-i numărul dacă este liber |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mută focalizarea pe monitorul următor sau anterior, indiferent de dispunere |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Rămân pe monitorul pe care ești |

Poți, de asemenea, să arunci o privire la [Hyprmon](https://github.com/erans/hyprmon/), dacă ai vrea un TUI care să te ajute la poziționarea mai multor ecrane.

### Controlul luminozității

Luminozitatea monitorului este controlată de tastele funcționale dedicate pentru creșterea/reducerea luminozității. Dacă ții apăsată tasta shift în timp ce apeși aceste taste, vei ajunge la luminozitatea maximă sau minimă. Tastele controlează ecranul pe care ești concentrat, așa că monitoarele externe care vorbesc DDC/CI sunt reglate la fel ca ecranul laptopului.

### Ecrane Apple

Dacă folosești un ecran Apple, tastele obișnuite de luminozitate de pe tastatură vor funcționa, de asemenea, automat, dacă ești concentrat pe ecranul Apple. Acest lucru se face prin comanda `asdcontrol`.

Reține că, dacă folosești un ecran Apple 6K XDR, este posibil să vezi un ecran fantomă în lista ta `hyprctl monitors`. Poți opri acest lucru cu ceva de genul `hl.monitor({ output = "DP-2", disabled = true })` în `~/.config/hypr/monitors.lua`.

Pe mașinile Intel, ar trebui să te conectezi la ecranele Apple folosind un cablu Thunderbolt obișnuit. Pe alte mașini fără Thunderbolt, de obicei va trebui să folosești un [cablu DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ca să faci lucrurile să funcționeze.
