# Monitori

Omarchy pēc noklusējuma pieņem, ka izmantojat displeju, kas spēj strādāt 2x režīmā un pieder retina klasei. Tas ir tas, kas vajadzīgs, lai iegūtu tos skaistos, asus programmētāju fontus. Tam ir optimizēti gandrīz visi jaunie premium klases klēpjdatori ar augstas izšķirtspējas ekrāniem. To jūs gribētu izmantot 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) gadījumā.

Bet, ja neizmantojat displeju ar PPI 218 vai augstāku, jūs gribēsiet mainīt monitora iestatījumus. Piemēram, ja jums ir 27" vai 32" 4K, varat izmantot daļēju mērogošanu, atverot `~/.config/hypr/monitors.lua` (izmantojot _Setup > Monitors_ Omarchy izvēlnē) un pārslēdzoties uz ieteikumu šai kombinācijai:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ja izmantojat 1080p vai 1440p displeju, jūs, visticamāk, vienkārši gribēsiet izmantot 1x mērogošanu, tāpēc varat izmantot:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Izmaiņas `GDK_SCALE` attiecas uz lietotnēm, kas palaistas pēc izmaiņu veikšanas (un GTK ievēro tikai veselus skaitļus, tāpēc turiet to pie jūsu monitora mērogam tuvākā veselā skaitļa). Tāpēc noteikti aizveriet tos logus, kas pēc izmaiņām ir pārāk lieli (vai aizveriet visus logus ar `Ctrl + Alt + Del`!).

Varat arī ātri pārslēgties starp galvenajām monitora mērogošanas attiecībām (1x, 1.25x, 1.6x, 2x, 3x, 4x), izmantojot `Super + /`, lai pārietu uz lielāku, un `Super + Alt + /`, lai pārietu uz mazāku. Ja jums ir noklusējuma konfigurācija, šīs izmaiņas saglabāsies arī pēc pārstartēšanas.

### Teksta palielināšana vai samazināšana

Monitora mērogošana maina visa izmēru. Ja viss, ko vēlaties, ir lielāks vai mazāks _teksts_, tam ir viens vienīgs regulators:

```
omarchy display text size 14
```

Tas pieņem pikseļu izmēru no 9 līdz 20 un kopā pārvieto Omarchy čaulu, GTK lietotnes un jūsu termināli, tāpēc visa darbvirsma saglabā proporcijas. Palaidiet to bez argumenta, lai redzētu, kāds iestatījums jums pašlaik ir, un `omarchy display text size reset`, lai atgrieztos pie noklusējuma. Foot ir vienīgais atpalicējs: tam nav veida, kā pārlādēt savu konfigurāciju, tāpēc jau palaistie termināļi saglabā veco izmēru, līdz atverat jaunu.

### Klēpjdatora displeju paplašināšana un spoguļošana

Kad klēpjdatoram pievienojat ārēju ekrānu, displejs tiek automātiski paplašināts. Bet to varat mainīt uz spoguļošanu, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Alt + Delete`. Tas ir īpaši noderīgi, ja tas ārējais ekrāns ir projektors un vēlaties kaut ko parādīt, kamēr strādājat.

Kad izmantojat paplašināšanu, klēpjdatora vāka aizvēršana automātiski izslēgs iekšējo ekrānu. Vāka atvēršana to atkal ieslēgs. Varat to kontrolēt arī manuāli, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Delete`.

### Vairāku ekrānu izkārtošana

Hyprland lieliski darbojas ar vairākiem ekrāniem. Lasiet vairāk par to, kā tos izkārtot, [Hyprland monitoru dokumentācijā](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy vidē tie tiek ievietoti `~/.config/hypr/monitors.lua` kā `hl.monitor` ieraksti — failā jau ir komentēti piemēri, kā piesaistīt konkrētu monitoru izšķirtspējai, pozīcijai un rotācijai.

Katram monitoram ir savas darbvietas no 1 līdz 10, tāpēc `Super + 1` vienmēr nozīmē tā monitora pirmo darbvietu, uz kura atrodaties. Aizkulisēs Hyprland joprojām numurē darbvietas visos monitoros: jūsu klēpjdatora ekrāns (vai pirmais monitors) iegūst 1–10, nākamais monitors 11–20 un tā tālāk, un katrs monitors saglabā savu bloku katru reizi, kad to pievienojat. Izmantojiet šos numurus, ja rakstāt [darbvietu noteikumus](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vai logu noteikumus konkrētam monitoram, tāpēc darbvieta 12 ir jūsu otrā monitora otrā darbvieta. `~/.local/state/omarchy/monitor-workspaces` uzskaita, kurš bloks ir katram monitoram.

Bulttaustiņi darbojas starp monitoriem, kuriem jūsu izkārtojumā ir kopīga mala. Ekrāni, kas saskaras tikai stūrī vai starp kuriem ir atstarpe, nav kaimiņi, tāpēc, lai pārvietotos starp tiem, izmantojiet `Ctrl + Alt + Tab`.

| Karstais taustiņš | Starp monitoriem |
| --- | --- |
| `Super + Arrow` | Pārvieto fokusu uz monitoru tajā pusē, tiklīdz tajā virzienā vairs nav neviena loga |
| `Super + Shift + Arrow` | Apmainās vietām ar logu uz monitora tajā pusē |
| `Super + Alt + Arrow` | Pārvieto logu grupā uz monitora tajā pusē |
| `Super + Shift + Ctrl + Arrow` | Pārvieto logu uz monitoru tajā pusē, uz darbvietu, ko tas rāda |
| `Super + Shift + Alt + Arrow` | Pārvieto darbvietu uz monitoru tajā pusē, saglabājot tās numuru, ja tas ir brīvs |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pārvieto fokusu uz nākamo vai iepriekšējo monitoru neatkarīgi no izkārtojuma |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Paliek uz monitora, uz kura atrodaties |

Varat arī apskatīt [Hyprmon](https://github.com/erans/hyprmon/), ja vēlaties TUI, kas palīdzētu ar vairāku ekrānu pozicionēšanu.

### Spilgtuma kontrole

Monitora spilgtumu kontrolē ar īpašajiem funkciju taustiņiem spilgtuma palielināšanai/samazināšanai. Ja, nospiežot šos taustiņus, turat nospiestu shift, jūs pāriesiet uz maksimālo vai minimālo spilgtumu. Taustiņi kontrolē displeju, uz kura atrodaties fokusā, tāpēc ārējie monitori, kas runā DDC/CI, tiek regulēti tāpat kā klēpjdatora ekrāns.

### Apple displeji

Ja izmantojat Apple displeju, parastie tastatūras spilgtuma taustiņi arī automātiski darbosies, ja būsiet fokusā uz Apple displeja. Tas tiek darīts ar `asdcontrol` komandu.

Ņemiet vērā, ka, ja izmantojat Apple 6K XDR displeju, savā `hyprctl monitors` sarakstā varat redzēt fantoma ekrānu. Varat to izslēgt ar kaut ko līdzīgu `hl.monitor({ output = "DP-2", disabled = true })`, izmantojot _Setup > Monitors_.

Intel datoros Apple displejiem vajadzētu pieslēgties, izmantojot parastu Thunderbolt kabeli. Citos datoros bez Thunderbolt parasti nāksies izmantot [DP + USB-A -> USB-C kabeli](https://www.amazon.com/dp/B0BNX7MS6N), lai tas darbotos.
