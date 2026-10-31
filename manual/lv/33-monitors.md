# Monitori

Omarchy pēc noklusējuma pieņem, ka izmantojat 2x spējīgu retina klases displeju. Tas ir tas, kas nepieciešams, lai iegūtu tos skaistos, asus programmētāju fontus. Tas ir tas, kam ir optimizēti gandrīz visi jaunie premium klases klēpjdatori ar augstas izšķirtspējas ekrāniem. Tas ir tas, ko jūs vēlētos izmantot ar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet, ja neizmantojat displeju ar PPI 218 vai augstāku, jūs vēlēsities mainīt monitora iestatījumus. Piemēram, ja jums ir 27" vai 32" 4K, varat tam izvēlēties daļēju mērogu augšējās joslas monitora panelī vai iestatīt noklusējumu katram monitoram, atverot `~/.config/hypr/monitors.lua` un pārslēdzoties uz ieteikumu šai kombinācijai:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ja izmantojat 1080p vai 1440p displeju, jūs, iespējams, vēlēsities izmantot vienkārši 1x mērogošanu, un to pašu arī GTK un X11 lietotnēm, tāpēc varat izmantot:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` izmaiņas attiecas uz lietotnēm, kas palaistas pēc izmaiņām (un GTK atbalsta tikai veselus skaitļus, tāpēc turiet to pie sava monitora mēroga tuvākā veselā skaitļa). Tāpēc pēc izmaiņām noteikti aizveriet logus, kas jums ir pārāk lieli (vai aizveriet visus logus ar `Ctrl + Alt + Del`!).

Varat arī ātri iziet cauri galvenajām monitora mērogošanas attiecībām (1x, 1.25x, 1.6x, 2x, 3x, 4x), izmantojot `Super + /`, lai palielinātu, un `Super + Alt + /`, lai samazinātu, vai izvēlēties vienu augšējās joslas monitora panelī. Tās maina tikai to monitoru, uz kura esat fokusējies, tāpēc klēpjdatora ekrānam un ārējam displejam katram var būt savs mērogs. Panelis iestata arī katra monitora izšķirtspēju. Jūsu izvēles šim fiziskajam monitoram tiek saglabātas `~/.local/state/omarchy/monitors/settings`, tāpēc tās saglabājas pēc pārstartēšanas un seko monitoram uz jebkuru portu vai doku, kuram tas nākamreiz tiks pievienots. Tām ir priekšroka pār jebkuru noteikumu tam pašam monitoram failā `~/.config/hypr/monitors.lua`, kuru Omarchy nekad nerediģē. Tā kā `GDK_SCALE` ir viena vērtība visiem ekrāniem, izvēlēts mērogs to iestata no monitora ar mazāko mērogu, tāpēc X11 lietotnes blīvākajā ekrānā iznāk nedaudz mazākas, nevis pārāk lielas otrā.

### Teksta palielināšana vai samazināšana

Monitora mērogošana maina visa izmēru. Ja viss, ko vēlaties, ir lielāks vai mazāks _teksts_, tam ir viens vienīgs regulētājs:

```
omarchy display text size 14
```

Tas pieņem pikseļu izmēru no 9 līdz 20 un kopā pārvieto Omarchy čaulu, GTK lietotnes un jūsu termināli, tāpēc visa darbvirsma paliek proporcionāla. Palaidiet to bez argumenta, lai redzētu, kur pašlaik atrodaties, un `omarchy display text size reset`, lai atgrieztos pie noklusējuma. Foot ir vienīgais atpalicējs: tam nav veida, kā pārlādēt savu konfigurāciju, tāpēc darbojošies termināļi saglabā veco izmēru, līdz atverat jaunu.

### Klēpjdatora displeju paplašināšana un spoguļošana

Kad klēpjdatoram pievienojat ārēju ekrānu, displejs tiek automātiski paplašināts. Bet Omarchy izvēlnē varat to tā vietā mainīt uz spoguļošanu, izmantojot _Trigger > Hardware_ vai `Super + Ctrl + Alt + Delete`. Tas ir īpaši noderīgi, ja tas ārējais ekrāns ir projektors un vēlaties kaut ko parādīt darba laikā.

Kad paplašināt, klēpjdatora vāka aizvēršana automātiski izslēgs iekšējo ekrānu. Vāka atvēršana to atkal ieslēgs. To varat vadīt arī manuāli, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Delete`.

### Vairāku ekrānu izkārtošana

Hyprland lieliski darbojas ar vairākiem ekrāniem. Augšējās joslas monitora panelis tos zīmē tur, kur tie atrodas: velciet vienu pret cita sānu, lai to tur pārvietotu, un izkārtojums tiek saglabāts kopā ar katra monitora pārējiem iestatījumiem. Par visu, ko panelis neaptver, lasiet vairāk par to, kā tos izkārtot, [Hyprland monitoru dokumentācijā](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy vidē tie atrodas `~/.config/hypr/monitors.lua` kā `hl.monitor` ieraksti — fails tiek piegādāts ar komentētiem piemēriem konkrēta monitora piesaistīšanai izšķirtspējai, pozīcijai un pagriezienam.

Katram monitoram ir savas darbvietas no 1 līdz 10, tāpēc `Super + 1` vienmēr nozīmē tā monitora pirmo darbvietu, uz kura atrodaties. Aizkulisēs Hyprland joprojām numurē darbvietas visos monitoros: jūsu klēpjdatora ekrāns (vai pirmais monitors) saņem 1–10, nākamais monitors 11–20 un tā tālāk, un katrs monitors saglabā savu bloku katru reizi, kad to pievienojat. Izmantojiet šos numurus, ja rakstāt [darbvietu noteikumus](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vai logu noteikumus konkrētam monitoram, tāpēc darbvieta 12 ir jūsu otrā monitora otrā darbvieta. `~/.local/state/omarchy/monitors/workspaces` uzskaita, kurš bloks ir katram monitoram.

Bulttaustiņi darbojas starp monitoriem, kuriem jūsu izkārtojumā ir kopīga mala. Ekrāni, kas saskaras tikai stūrī vai starp kuriem ir atstarpe, nav kaimiņi, tāpēc izmantojiet `Ctrl + Alt + Tab`, lai tiktu starp tiem.

| Īsinājumtaustiņš | Starp monitoriem |
| --- | --- |
| `Super + Arrow` | Pārvieto fokusu uz monitoru tajā pusē, kad tajā virzienā vairs nav neviena loga |
| `Super + Shift + Arrow` | Apmainās vietām ar logu monitorā tajā pusē |
| `Super + Alt + Arrow` | Pārvieto logu grupā monitorā tajā pusē |
| `Super + Shift + Ctrl + Arrow` | Pārvieto logu uz monitoru tajā pusē, uz darbvietu, kuru tas rāda |
| `Super + Shift + Alt + Arrow` | Pārvieto darbvietu uz monitoru tajā pusē, saglabājot tās numuru, ja tas ir brīvs |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pārvieto fokusu uz nākamo vai iepriekšējo monitoru neatkarīgi no izkārtojuma |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Paliek monitorā, uz kura atrodaties |

Varat arī apskatīt [Hyprmon](https://github.com/erans/hyprmon/), ja vēlaties TUI, kas palīdzēs jums ar vairāku ekrānu pozicionēšanu.

### Spilgtuma regulēšana

Monitora spilgtums tiek regulēts ar īpašajiem funkciju taustiņiem spilgtuma palielināšanai/samazināšanai. Ja, nospiežot tos, turat nospiestu Shift, jūs nonāksiet līdz maksimālajam vai minimālajam spilgtumam. Taustiņi regulē displeju, uz kura esat fokusējies, tāpēc ārējie monitori, kas sazinās pa DDC/CI, tiek regulēti tāpat kā klēpjdatora ekrāns.

### Apple displeji

Ja izmantojat Apple displeju, parastie tastatūras spilgtuma taustiņi arī automātiski darbosies, ja esat fokusējies uz Apple displeju. Tas tiek darīts ar `asdcontrol` komandu.

Ņemiet vērā, ka, ja izmantojat Apple 6K XDR displeju, savā `hyprctl monitors` sarakstā varat redzēt fantoma ekrānu. To varat izslēgt ar kaut ko līdzīgu `hl.monitor({ output = "DP-2", disabled = true })` failā `~/.config/hypr/monitors.lua`.

Intel datoros Apple displejiem vajadzētu pieslēgties, izmantojot parastu Thunderbolt kabeli. Citos datoros bez Thunderbolt jums parasti nāksies izmantot [DP + USB-A -> USB-C kabeli](https://www.amazon.com/dp/B0BNX7MS6N), lai tas darbotos.
