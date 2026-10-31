# Monitori

Omarchy pēc noklusējuma pieņem, ka izmantojat 2x spējīgu retina klases displeju. Tas ir tas, kas jums nepieciešams, lai iegūtu tos jaukos, asus programmētāju fontus. Tam ir optimizēti gandrīz visi jaunie premium klēpjdatori ar augstas izšķirtspējas ekrāniem. To jūs vēlētos izmantot ar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet, ja neizmantojat displeju ar PPI 218 vai augstāku, jūs vēlēsieties mainīt monitora iestatījumus. Piemēram, ja jums ir 27" vai 32" 4K, varat izvēlēties tam daļēju mērogu monitora panelī augšējā joslā vai iestatīt noklusējumu katram monitoram, atverot `~/.config/hypr/monitors.lua` un pārslēdzoties uz ieteikumu šai kombinācijai:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ja izmantojat 1080p vai 1440p displeju, jūs, visticamāk, vēlēsieties izmantot 1x mērogošanu, un to pašu arī GTK un X11 lietotnēm, tāpēc varat izmantot:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` izmaiņas attiecas uz lietotnēm, kas palaistas pēc izmaiņām (un GTK ņem vērā tikai veselus skaitļus, tāpēc turiet to pie jūsu monitora mērogam tuvākā veselā skaitļa). Tāpēc pēc izmaiņām noteikti aizveriet tos logus, kas jums ir pārāk lieli (vai aizveriet visus logus ar `Ctrl + Alt + Del`!).

Varat arī ātri pārslēgties cauri galvenajām monitora mērogošanas attiecībām (1x, 1.25x, 1.6x, 2x, 3x, 4x), izmantojot `Super + /`, lai palielinātu, un `Super + Alt + /`, lai samazinātu, vai izvēlēties vienu monitora panelī augšējā joslā. Tās maina tikai monitoru, uz kura esat fokusēts, tāpēc klēpjdatora ekrānam un ārējam displejam katram var būt savs mērogs. Panelis iestata arī katra monitora izšķirtspēju. Jūsu izvēles šim fiziskajam monitoram tiek saglabātas `~/.local/state/omarchy/monitors/settings`, tāpēc tās saglabājas pēc pārstartēšanas un seko monitoram uz jebkuru portu vai doku, kuram tas nākamreiz tiek pievienots. Tām ir priekšroka pār jebkuru noteikumu tam pašam monitoram failā `~/.config/hypr/monitors.lua`, kuru Omarchy nekad nerediģē. Ja drīzāk vēlaties savus monitorus pilnībā iestatīt šajā failā, pievienojiet tam `omarchy_monitor_panel_settings = false`, un paneļa izmaiņas būs spēkā tikai līdz Hyprland pārlādēšanai. Tā kā `GDK_SCALE` ir viena vērtība visiem ekrāniem, izvēlēts mērogs to iestata pēc monitora ar zemāko mērogu, tāpēc X11 lietotnes blīvākajā ekrānā iznāk nedaudz par mazu, nevis pārāk lielas otrā.

### Teksta padarīšana lielāku vai mazāku

Monitora mērogošana maina visa izmēru. Ja viss, ko vēlaties, ir lielāks vai mazāks _teksts_, tam ir viens vienīgs regulētājs:

```
omarchy display text size 14
```

Tas pieņem pikseļu izmēru no 9 līdz 20 un vienlaikus pārvieto Omarchy apvalku, GTK lietotnes un jūsu termināli, tāpēc visa darbvirsma saglabā proporcijas. Palaidiet to bez argumenta, lai redzētu, kur pašlaik esat, un `omarchy display text size reset`, lai atgrieztos pie noklusējuma. Foot ir vienīgais atpalicējs: tam nav veida, kā pārlādēt savu konfigurāciju, tāpēc darbojošies termināļi saglabā veco izmēru, līdz atverat jaunu.

### Klēpjdatora displeju paplašināšana un spoguļošana

Kad klēpjdatoram pievienojat ārēju ekrānu, displejs tiek automātiski paplašināts. Bet tā vietā varat to mainīt uz spoguļošanu, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Alt + Delete`. Tas ir īpaši noderīgi, ja šis ārējais ekrāns ir projektors un vēlaties kaut ko rādīt, kamēr strādājat.

Kad paplašināt, klēpjdatora vāka aizvēršana automātiski izslēgs iekšējo ekrānu. Vāka atvēršana to ieslēgs atpakaļ. Varat to arī kontrolēt manuāli, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Delete`.

### Vairāku ekrānu sakārtošana

Hyprland lieliski darbojas ar vairākiem ekrāniem. Monitora panelis augšējā joslā zīmē tos tur, kur tie atrodas: velciet vienu pret otra sānu, lai to tur pārvietotu, un izkārtojums tiek saglabāts kopā ar katra monitora pārējiem iestatījumiem. Par visu, ko panelis neaptver, lasiet vairāk par to, kā tos izkārtot, [Hyprland monitoru dokumentācijā](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy vidē tie tiek ievietoti `~/.config/hypr/monitors.lua` kā `hl.monitor` ieraksti — failā jau ir komentēti piemēri, kā piesaistīt konkrētu monitoru izšķirtspējai, pozīcijai un rotācijai.

Katram monitoram ir savas darbvietas no 1 līdz 10, tāpēc `Super + 1` vienmēr nozīmē monitora, kurā atrodaties, pirmo darbvietu. Aizkulisēs Hyprland joprojām numurē darbvietas visos monitoros: jūsu klēpjdatora ekrāns (vai pirmais monitors) saņem 1–10, nākamais monitors 11–20 utt., un katrs monitors saglabā savu bloku katru reizi, kad to pievienojat. Izmantojiet šos numurus, ja rakstāt [darbvietu noteikumus](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vai logu noteikumus konkrētam monitoram, tāpēc darbvieta 12 ir jūsu otrā monitora otrā darbvieta. `~/.local/state/omarchy/monitors/workspaces` uzskaita, kurš bloks ir katram monitoram.

Bultiņu taustiņi darbojas starp monitoriem, kuriem jūsu izkārtojumā ir kopīga mala. Ekrāni, kas saskaras tikai stūrī vai starp kuriem ir atstarpe, nav kaimiņi, tāpēc izmantojiet `Ctrl + Alt + Tab`, lai tiktu starp tiem.

| Karstais taustiņš | Starp monitoriem |
| --- | --- |
| `Super + Arrow` | Pārvieto fokusu uz monitoru tajā pusē, kad tajā virzienā vairs nav neviena loga |
| `Super + Shift + Arrow` | Apmaina vietām ar logu monitorā tajā pusē |
| `Super + Alt + Arrow` | Pārvieto logu grupā monitorā tajā pusē |
| `Super + Shift + Ctrl + Arrow` | Pārvieto logu uz monitoru tajā pusē, uz darbvietu, ko tas rāda |
| `Super + Shift + Alt + Arrow` | Pārvieto darbvietu uz monitoru tajā pusē, saglabājot tās numuru, ja tas ir brīvs |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pārvieto fokusu uz nākamo vai iepriekšējo monitoru neatkarīgi no izkārtojuma |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Paliek monitorā, kurā atrodaties |

Varat arī apskatīt [Hyprmon](https://github.com/erans/hyprmon/), ja vēlaties TUI, kas palīdzētu jums ar vairāku ekrānu pozicionēšanu.

### Spilgtuma kontrole

Monitora spilgtumu kontrolē ar tam paredzētajiem funkciju taustiņiem spilgtuma palielināšanai/samazināšanai. Ja, nospiežot tos, turat nospiestu Shift, jūs pāriesiet uz maksimālo vai minimālo spilgtumu. Taustiņi kontrolē displeju, uz kura esat fokusēts, tāpēc ārējie monitori, kas sazinās ar DDC/CI, tiek regulēti tāpat kā klēpjdatora ekrāns.

### Apple displeji

Ja izmantojat Apple displeju, parastie tastatūras spilgtuma taustiņi automātiski darbosies arī tad, ja esat fokusēts uz Apple displeju. Tas tiek darīts ar `asdcontrol` komandu.

Ņemiet vērā, ka, ja izmantojat Apple 6K XDR displeju, savā `hyprctl monitors` sarakstā varat redzēt fantoma ekrānu. Varat to izslēgt ar kaut ko līdzīgu `hl.monitor({ output = "DP-2", disabled = true })` failā `~/.config/hypr/monitors.lua`.

Intel datoros Apple displejus vajadzētu pievienot, izmantojot parastu Thunderbolt kabeli. Citos datoros bez Thunderbolt parasti nāksies izmantot [DP + USB-A -> USB-C kabeli](https://www.amazon.com/dp/B0BNX7MS6N), lai tas darbotos.
