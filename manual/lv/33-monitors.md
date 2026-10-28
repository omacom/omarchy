# Monitori

Omarchy pēc noklusējuma pieņem, ka izmantojat 2x spējīgu retina klases displeju. Tas ir nepieciešams, lai iegūtu tos patīkamos, asus programmētāju fontus. Tam ir optimizēti gandrīz visi jaunie premium klases klēpjdatori ar augstas izšķirtspējas ekrāniem. To jūs vēlētos izmantot 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet, ja neizmantojat displeju ar PPI 218 vai augstāku, jums būs jāmaina monitora iestatījumi. Piemēram, ja jums ir 27" vai 32" 4K, varat izmantot daļēju mērogošanu, atverot `~/.config/hypr/monitors.lua` (izmantojot _Setup > Monitors_ Omarchy izvēlnē) un pārslēdzoties uz šai kombinācijai ieteicamo variantu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ja izmantojat 1080p vai 1440p displeju, visticamāk, vienkārši vēlēsieties izmantot 1x mērogošanu, tāpēc varat izmantot:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` izmaiņas attiecas uz lietotnēm, kas palaistas pēc izmaiņām (un GTK ņem vērā tikai veselus skaitļus, tāpēc turiet to pie jūsu monitora mērogam tuvākā veselā skaitļa). Tāpēc pēc izmaiņām noteikti aizveriet tos logus, kas ir pārāk lieli (vai aizveriet visus logus ar `Ctrl + Alt + Del`!).

Varat arī ātri pārslēgties starp galvenajiem monitora mērogošanas koeficientiem (1x, 1.25x, 1.6x, 2x, 3x, 4x), izmantojot `Super + /`, lai palielinātu, un `Super + Alt + /`, lai samazinātu, vai izvēlēties vienu no monitora paneļa augšējā joslā. Tie maina tikai to monitoru, uz kura esat fokusējies, tāpēc klēpjdatora ekrānam un ārējam displejam katram var būt savs mērogs. Izvēle tiek saglabāta `~/.config/hypr/monitors.lua` kā `hl.monitor` noteikums šim monitoram, tāpēc tā saglabājas pēc pārstartēšanas un ir prioritāra pār `omarchy_monitor_scale`, kas paliek mērogs katram monitoram, kuram nav sava noteikuma.

### Teksta palielināšana vai samazināšana

Monitora mērogošana maina visa izmēru. Ja vēlaties tikai lielāku vai mazāku _tekstu_, tam ir viens iestatījums:

```
omarchy display text size 14
```

Tas pieņem pikseļu izmēru no 9 līdz 20 un vienlaikus maina Omarchy apvalku, GTK lietotnes un jūsu termināli, tāpēc visa darbvirsma paliek proporcionāla. Palaidiet to bez argumenta, lai redzētu pašreizējo vērtību, un `omarchy display text size reset`, lai atgrieztos pie noklusējuma. Foot ir vienīgais atpalicējs: tam nav veida, kā pārlādēt savu konfigurāciju, tāpēc jau atvērtie termināļi saglabā veco izmēru, līdz atverat jaunu.

### Klēpjdatora displeju paplašināšana un spoguļošana

Kad pievienojat klēpjdatoram ārēju ekrānu, displejs tiek automātiski paplašināts. Bet to varat mainīt uz spoguļošanu, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Alt + Delete`. Tas ir īpaši noderīgi, ja šis ārējais ekrāns ir projektors un vēlaties kaut ko rādīt, kamēr strādājat.

Kad paplašināt, klēpjdatora vāka aizvēršana automātiski izslēgs iekšējo ekrānu. Vāka atvēršana to atkal ieslēgs. To varat arī vadīt manuāli, izmantojot _Trigger > Hardware_ Omarchy izvēlnē vai `Super + Ctrl + Delete`.

### Vairāku ekrānu izkārtošana

Hyprland lieliski darbojas ar vairākiem ekrāniem. Lasiet vairāk par to, kā tos izkārtot, [Hyprland monitoru dokumentācijā](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistēmā tie atrodas `~/.config/hypr/monitors.lua` kā `hl.monitor` ieraksti — failā ir iekļauti komentēti piemēri, kā konkrētu monitoru piesaistīt izšķirtspējai, pozīcijai un pagriešanai.

Katram monitoram ir savas darbvietas no 1 līdz 10, tāpēc `Super + 1` vienmēr nozīmē tā monitora pirmo darbvietu, uz kura atrodaties. Aizkulisēs Hyprland joprojām numurē darbvietas visos monitoros: jūsu klēpjdatora ekrāns (vai pirmais monitors) saņem 1–10, nākamais monitors 11–20 un tā tālāk, un katrs monitors saglabā savu bloku katru reizi, kad to pievienojat. Izmantojiet šos numurus, ja rakstāt [darbvietu noteikumus](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vai logu noteikumus konkrētam monitoram, tāpēc darbvieta 12 ir jūsu otrā monitora otrā darbvieta. `~/.local/state/omarchy/monitor-workspaces` uzskaita, kurš bloks ir katram monitoram.

Bulttaustiņi darbojas starp monitoriem, kuriem jūsu izkārtojumā ir kopīga mala. Ekrāni, kas saskaras tikai stūrī vai starp kuriem ir atstarpe, nav kaimiņi, tāpēc izmantojiet `Ctrl + Alt + Tab`, lai pārvietotos starp tiem.

| Karstais taustiņš | Starp monitoriem |
| --- | --- |
| `Super + Arrow` | Pārvieto fokusu uz monitoru tajā pusē, kad tajā virzienā vairs nav neviena loga |
| `Super + Shift + Arrow` | Apmaina ar logu monitorā tajā pusē |
| `Super + Alt + Arrow` | Pārvieto logu grupā monitorā tajā pusē |
| `Super + Shift + Ctrl + Arrow` | Pārvieto logu uz monitoru tajā pusē, uz darbvietu, ko tas rāda |
| `Super + Shift + Alt + Arrow` | Pārvieto darbvietu uz monitoru tajā pusē, saglabājot tās numuru, ja tas ir brīvs |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Pārvieto fokusu uz nākamo vai iepriekšējo monitoru neatkarīgi no izkārtojuma |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Paliek monitorā, kurā atrodaties |

Varat arī apskatīt [Hyprmon](https://github.com/erans/hyprmon/), ja vēlaties TUI, kas palīdzētu ar vairāku ekrānu pozicionēšanu.

### Spilgtuma regulēšana

Monitora spilgtumu regulē ar tam paredzētajiem funkciju taustiņiem spilgtuma palielināšanai/samazināšanai. Ja, nospiežot tos, turat nospiestu shift, jūs dosieties uz maksimālo vai minimālo spilgtumu. Taustiņi regulē displeju, uz kura esat fokusējies, tāpēc ārējie monitori, kas atbalsta DDC/CI, tiek regulēti tāpat kā klēpjdatora ekrāns.

### Apple displeji

Ja izmantojat Apple displeju, arī parastie tastatūras spilgtuma taustiņi automātiski darbosies, ja esat fokusējies uz Apple displeju. Tas tiek darīts ar `asdcontrol` komandu.

Ņemiet vērā, ka, ja izmantojat Apple 6K XDR displeju, `hyprctl monitors` sarakstā varat redzēt fantoma ekrānu. To varat izslēgt ar kaut ko līdzīgu `hl.monitor({ output = "DP-2", disabled = true })`, izmantojot _Setup > Monitors_.

Intel datoros Apple displejus vajadzētu pievienot ar parastu Thunderbolt kabeli. Citos datoros bez Thunderbolt parasti būs jāizmanto [DP + USB-A -> USB-C kabelis](https://www.amazon.com/dp/B0BNX7MS6N), lai tas darbotos.
