# Monitori

Omarchy pēc noklusējuma paredz, ka izmantojat 2x spējīgu retina klases displeju. Tas jums vajadzīgs, lai iegūtu tos jaukos, asos programmētāju fontiem piemērotus fontus. Tam ir optimizēti gandrīz visi jaunie premium klases klēpjdatori ar augstas izšķirtspējas ekrāniem. To jūs gribētu darbināt 27 collu 5K monitorā [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vai 32 collu 6K monitorā [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Taču, ja neizmantojat displeju ar 218 vai lielāku PPI, jūs gribēsit nomainīt monitora iestatījumus. Piemēram, ja jums ir 27 collu vai 32 collu 4K monitors, daļveida mērogošanu var izmantot, atverot `~/.config/hypr/monitors.lua` (caur Omarchy izvēlnes sadaļu _Iestatīšana > Monitors_) un pārslēdzoties uz šai kombinācijai ieteikto:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ja izmantojat 1080p vai 1440p displeju, visticamāk vienkārši gribēsiet izmantot 1x mērogošanu, tāpēc varat izmantot:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Izmaiņas parametrā `GDK_SCALE` attiecas uz lietotnēm, kas palaistas pēc izmaiņas (un GTK ņem vērā tikai veselus skaitļus, tāpēc atstājiet to pie jūsu monitora mēroga tuvākā veselā skaitļa). Tāpēc pēc izmaiņas noteikti aizveriet tos esošos logus, kuri ir pārāk lieli (vai aizveriet visus logus ar `Ctrl + Alt + Del`!).

Varat arī ātri iziet cauri galvenajiem monitora mērogošanas koeficientiem (1x, 1.25x, 1.6x, 2x, 3x, 4x), izmantojot `Super + /`, lai virzītos augšup, un `Super + Alt + /`, lai virzītos lejup. Ja jums ir noklusējuma konfigurācija, šīs izmaiņas saglabāsies arī pēc pārstartēšanas.

### Teksta padarīšana lielāku vai mazāku

Monitora mērogošana maina visa izmēru. Ja viss, ko vēlaties, ir lielāks vai mazāks _teksts_, tam ir viena poga:

```
omarchy display text size 14
```

Tas pieņem pikseļa izmēru no 9 līdz 20 un kopā pavirza Omarchy čaulu, GTK lietotnes un jūsu termināli, tāpēc visa darbvirsma paliek proporcionāla. Palaidiet to bez argumenta, lai redzētu, kur atrodaties, bet `omarchy display text size reset`, lai atgrieztos pie noklusējuma. Foot ir vienīgais atpalicējs: tam nav veida, kā pārlādēt konfigurāciju, tāpēc darbojošie termināļi veco izmēru saglabā, līdz atverat jaunu.

### Klēpjdatora displeju paplašināšana un spoguļošana

Kad ārēju ekrānu pievienojat klēpjdatoram, displejs tiek automātiski paplašināts. Taču jūs to varat mainīt uz spoguļošanu, izmantojot Omarchy izvēlnes sadaļu _Palaist > Hardware_ vai `Super + Ctrl + Alt + Delete`. Tas it īpaši noder, ja šis ārējais ekrāns ir projektors un darba laikā vēlaties kaut ko parādīt.

Kad veicat paplašināšanu, klēpjdatora vāka aizvēršana iekšējo ekrānu automātiski izslēgs. Vāka atvēršana to atkal ieslēgs. To varat vadīt arī manuāli, izmantojot Omarchy izvēlnes sadaļu _Palaist > Hardware_ vai `Super + Ctrl + Delete`.

### Vairāku ekrānu izkārtošana

Hyprland lieliski darbojas ar vairākiem ekrāniem. Vairāk par to, kā tos izkārtot, lasiet [Hyprland monitoru dokumentācijā](https://wiki.hypr.land/Configuring/Basics/Monitors/). Varat [piesiet konkrētas darbvietas konkrētiem monitoriem](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arī. Omarchy vidē šie noteikumi atrodas failā `~/.config/hypr/monitors.lua` kā `hl.monitor` ieraksti — fails tiek piegādāts ar izkomentētiem piemēriem, kā piesaistīt konkrētu monitoru izšķirtspējai, novietojumam un pagriešanai.

Varat ieskatīties arī rīkā [Hyprmon](https://github.com/erans/hyprmon/), ja vēlaties termināļa saskarni, kas palīdzētu ar vairāku ekrānu novietošanu.

### Spilgtuma vadīšana

Monitora spilgtumu vada tam paredzētie funkciju taustiņi spilgtuma palielināšanai/samazinājumiem. Ja, tos nospiežot, turēsiet nospiestu Shift, nonāksiet līdz maksimālajam vai minimālajam spilgtumam. Taustiņi kontrolē to displeju, uz ko esat fokusēts, tāpēc ārēji monitori, kas runā DDC/CI valodā, tiek pielāgoti tieši tāpat kā klēpjdatora ekrāns.

### Apple displeji

Ja izmantojat Apple displeju, parastie tastatūras spilgtuma taustiņi arī darbosies automātiski, ja būsiet fokusēts uz Apple displeja. Tas tiek darīts ar komandu `asdcontrol`.

Ievērojiet, ka, ja izmantojat Apple 6K XDR displeju, sarakstā `hyprctl monitors` varat redzēt fantoma ekrānu. To var izslēgt, piemēram, ar `hl.monitor({ output = "DP-2", disabled = true })` caur _Iestatīšana > Monitors_.

Intel datoros Apple displejiem vajadzētu pievienoties, izmantojot parastu Thunderbolt kabeli. Citos datoros bez Thunderbolt jums parasti būs jāizmanto [DP + USB-A -> USB-C kabelis](https://www.amazon.com/dp/B0BNX7MS6N), lai to dabūtu darbā.
