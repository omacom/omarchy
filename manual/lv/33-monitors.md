# Monitori

Omarchy pēc noklusējuma pieņem, ka izmanto 2x spējīgu retina klases displeju. Tas ir tas, kas vajadzīgs, lai iegūtu tos skaistos, asus programmētāju fontus. Tam ir optimizēti gandrīz visi jaunie premium klases klēpjdatori ar augstas izšķirtspējas ekrāniem. To tu gribētu izmantot ar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet ja neizmanto displeju ar PPI 218 vai vairāk, vajadzēs mainīt monitora iestatījumus. Piemēram, ja tev ir 27" vai 32" 4K, tam vari izvēlēties daļēju mērogu monitora panelī augšējā joslā vai iestatīt noklusējumu katram monitoram, atverot `~/.config/hypr/monitors.lua` un pārslēdzoties uz ieteikumu šai kombinācijai:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ja izmanto 1080p vai 1440p displeju, visticamāk, vienkārši gribēsi izmantot 1x mērogošanu, un to pašu arī GTK un X11 lietotnēm, tāpēc vari izmantot:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` izmaiņas attiecas uz lietotnēm, kas palaistas pēc izmaiņām (un GTK ņem vērā tikai veselus skaitļus, tāpēc turi to sava monitora mērogam tuvākajā veselajā skaitlī). Tāpēc noteikti aizver esošos logus, kas pēc izmaiņām ir pārāk lieli (vai aizver visus logus ar `Ctrl + Alt + Del`!).

Vari arī ātri pārslēgties starp galvenajām monitora mērogošanas attiecībām (1x, 1.25x, 1.6x, 2x, 3x, 4x), izmantojot `Super + /`, lai palielinātu, un `Super + Alt + /`, lai samazinātu, vai izvēlēties kādu monitora panelī augšējā joslā. Tās maina tikai monitoru, uz kura esi fokusējies, tāpēc klēpjdatora ekrānam un ārējam displejam katram var būt savs mērogs. Panelis iestata arī katra monitora izšķirtspēju, atsvaidzes intensitāti un pagriešanu. Tavas izvēles šim fiziskajam monitoram tiek saglabātas `~/.local/state/omarchy/monitors/settings`, tāpēc tās saglabājas pēc pārstartēšanas un seko monitoram uz jebkuru portu vai doku, kuram to pieslēgsi nākamreiz. Tām ir prioritāte pār jebkuru kārtulu tam pašam monitoram `~/.config/hypr/monitors.lua`, ko Omarchy nekad neredigē. Ja labāk monitorus pilnībā iestatītu šajā failā, pievieno tam `omarchy_monitor_panel_settings = false`, un paneļa izmaiņas būs spēkā tikai līdz Hyprland pārlādējas. Tā kā `GDK_SCALE` ir viena vērtība visiem ekrāniem, izvēlēts mērogs to iestata pēc monitora ar mazāko mērogu, tāpēc X11 lietotnes uz blīvākā ekrāna iznāk mazliet par mazu, nevis pārāk lielas uz otra.

### Teksta palielināšana vai samazināšana

Monitora mērogošana maina visa izmēru. Ja viss, ko gribi, ir lielāks vai mazāks _teksts_, tam ir viens vienīgs regulētājs:

```
omarchy display text size 14
```

Tas pieņem pikseļu izmēru no 9 līdz 20 un kopā pārvieto Omarchy čaulu, GTK lietotnes un tavu termināli, tāpēc visa darbvirsma saglabā proporcijas. Palaid to bez argumenta, lai redzētu, kāds iestatījums tev ir pašlaik, un `omarchy display text size reset`, lai atgrieztos pie noklusējuma. Foot ir vienīgais atpalicējs: tam nav veida, kā pārlādēt savu konfigurāciju, tāpēc darbojošies termināļi saglabā veco izmēru, līdz atver jaunu.

### Klēpjdatora displeju paplašināšana un spoguļošana

Kad klēpjdatoram pieslēdz ārēju ekrānu, displejs tiek automātiski paplašināts. Bet tā vietā vari to mainīt uz spoguļošanu, Omarchy izvēlnē izmantojot _Trigger > Hardware_ vai `Super + Ctrl + Alt + Delete`. Tas ir īpaši noderīgi, ja šis ārējais ekrāns ir projektors un tu gribi kaut ko parādīt, kamēr strādā.

Kad paplašini, klēpjdatora vāka aizvēršana automātiski izslēgs iekšējo ekrānu. Vāka atvēršana to atkal ieslēgs. Vari to vadīt arī manuāli, Omarchy izvēlnē izmantojot _Trigger > Hardware_ vai `Super + Ctrl + Delete`.

### Vairāku ekrānu sakārtošana

Hyprland lieliski darbojas ar vairākiem ekrāniem. Monitora panelis augšējā joslā tos uzzīmē tur, kur tie atrodas: pavelc vienu pret otra sānu, lai pārvietotu to tur, un izkārtojums tiek saglabāts kopā ar katra monitora pārējiem iestatījumiem. Par visu, ko panelis neatrisina, vairāk par to izkārtošanu lasi [Hyprland monitoru dokumentācijā](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistēmā tās ievieto `~/.config/hypr/monitors.lua` kā `hl.monitor` ierakstus — failā ir iekļauti komentēti piemēri monitora izslēgtai turēšanai, režīmiem, ko panelis nepiedāvā, 10 bitu krāsai un mainīgai atsvaidzes intensitātei.

Katram monitoram ir savas darbvietas no 1 līdz 10, tāpēc `Super + 1` vienmēr nozīmē pirmo darbvietu monitorā, kurā esi. Aizkulisēs Hyprland joprojām numurē darbvietas visos monitoros: tavs klēpjdatora ekrāns (vai pirmais monitors) saņem 1–10, nākamais monitors 11–20 un tā tālāk, un katrs monitors saglabā savu bloku katru reizi, kad to pieslēdz. Izmanto šos numurus, ja raksti [darbvietu kārtulas](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vai logu kārtulas konkrētam monitoram, tāpēc darbvieta 12 ir tava otrā monitora otrā darbvieta. `~/.local/state/omarchy/monitors/workspaces` uzskaita, kurš bloks ir katram monitoram.

Bulttaustiņi darbojas starp monitoriem, kuriem tavā izkārtojumā ir kopīga mala. Ekrāni, kas saskaras tikai stūrī vai starp kuriem ir atstarpe, nav kaimiņi, tāpēc izmanto `Ctrl + Alt + Tab`, lai tiktu starp tiem.

| Karstais taustiņš | Starp monitoriem |
| --- | --- |
| `Super + Arrow` | Pārvieto fokusu uz monitoru tajā pusē, tiklīdz tajā virzienā vairs nav neviena loga |
| `Super + Shift + Arrow` | Apmainās vietām ar logu monitorā tajā pusē |
| `Super + Alt + Arrow` | Pārvieto logu grupā monitorā tajā pusē |
| `Super + Shift + Ctrl + Arrow` | Pārvieto logu uz monitoru tajā pusē, uz darbvietu, ko tas rāda |
| `Super + Shift + Alt + Arrow` | Pārvieto darbvietu uz monitoru tajā pusē, saglabājot tās numuru, ja tas ir brīvs |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pārvieto fokusu uz nākamo vai iepriekšējo monitoru neatkarīgi no izkārtojuma |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Paliek monitorā, kurā esi |

Vari arī apskatīt [Hyprmon](https://github.com/erans/hyprmon/), ja gribi TUI, kas palīdzēs tev ar vairāku ekrānu novietošanu.

### Spilgtuma regulēšana

Monitora spilgtumu regulē ar īpaši tam paredzētajiem funkciju taustiņiem spilgtuma palielināšanai/samazināšanai. Ja, spiežot tos, turi nospiestu Shift, nonāksi līdz maksimālajam vai minimālajam spilgtumam. Taustiņi regulē displeju, uz kura esi fokusējies, tāpēc ārējie monitori, kas runā DDC/CI, tiek regulēti tāpat kā klēpjdatora ekrāns.

### Apple displeji

Ja izmanto Apple displeju, parastie tastatūras spilgtuma taustiņi arī automātiski darbosies, ja esi fokusējies uz Apple displeju. Tas tiek darīts ar `asdcontrol` komandu.

Ņem vērā, ja izmanto Apple 6K XDR displeju, savā `hyprctl monitors` sarakstā vari redzēt fantoma ekrānu. Vari to izslēgt ar kaut ko līdzīgu `hl.monitor({ output = "DP-2", disabled = true })` failā `~/.config/hypr/monitors.lua`.

Intel iekārtās Apple displejiem jāpieslēdzas, izmantojot parastu Thunderbolt kabeli. Citās iekārtās bez Thunderbolt parasti nāksies izmantot [DP + USB-A -> USB-C kabeli](https://www.amazon.com/dp/B0BNX7MS6N), lai tas darbotos.
