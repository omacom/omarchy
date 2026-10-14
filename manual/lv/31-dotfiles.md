# Dotfiles

Omarchy galvenokārt konfigurē caur tā sauktajiem dotfailiem, kas dzīvo mapē `~/.config`. Tie tiek uzskatīti par jūsu failiem, kas paredzēti jūsu izmaiņām. Faili, kas dzīvo mapē `/usr/share/omarchy`, pieder pašam Omarchy, un jums ar tiem nevajadzētu rosīties. Ja mapē `/usr/share/omarchy` ir kaut kas jāmaina, tā vietā vērtība ir jāpārraksta mapē `~/.config`.

Galvenās konfigurācijas var rediģēt tieši no Omarchy izvēlnes (`Super + Space`), piemēram, _Iestatīšana > Monitors_, _Iestatīšana > Keybindings_, _Iestatīšana > Input_ un _Iestatīšana > Config > [file]_. Kad to darāt šādi, jebkurš process, kas jārestartē pēc konfigurācijas rediģējumiem, tiks restartēts automātiski, tiklīdz aizvērsiet redaktoru (pēc noklusējuma tas ir Neovim — `:wq`, atcerieties! — taču to var mainīt sadaļā _Iestatīšana > Defaults > Editor_).

Šeit ir galveno failu saraksts mapē `~/.config` un to, ko tie kontrolē:

| Fails                  | Mērķis              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Galvenā Hyprland konfigurācija. Ielādē Omarchy noklusējumus plus jūsu zemāk esošos pārrakstīšanas failus. [Uzziniet vairāk par Hyprland konfigurācijām](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Jūsu paša taustiņu saīsnes un noklusējumu pārrakstījumi. |
| `~/.config/hypr/monitors.lua` | Kontrolē jūsu monitorus, izšķirtspēju un novietojumu. |
| `~/.config/hypr/input.lua` | Kontrolē jūsu tastatūras izkārtojumu, peli un skārienpaliktņa iestatījumus. |
| `~/.config/hypr/looknfeel.lua` | Kontrolē atstarpes, apmales, animācijas un pārējo izskatu. |
| `~/.config/hypr/autostart.lua` | Kontrolē papildu procesus, kas sākas līdz ar sesiju. |
| `~/.config/omarchy/shell.json` | Kontrolē Omarchy čaulu: joslas novietojumu, izkārtojumu un logrīkus, plus ekrānsaudzētāja, bloķēšanas un dīkstāves laikus. |
| `~/.config/foot/foot.ini` | Kontrolē jūsu termināli (foot ir noklusējums). |
| `~/.XCompose` | Nosaka jūsu ātrpiekļuves emocijzīmes un vārda/e-pasta automātisko pabeigšanu. Pēc izmaiņu veikšanas noteikti palaidiet `omarchy-restart-xcompose`. |

Ja galarezultātā veicat ļoti daudz izmaiņu, lai pielāgotu savu iestatījumu, ir laba doma visus šos dotfailus dublēt. [Stow ir lielisks veids, kā to izdarīt](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savu lietotņu palaišana līdz ar sesiju

Ja vēlaties, lai kaut kas darbotos ikreiz, kad pierakstāties, — sinhronizācijas dēmons, tērzēšanas lietotne, jūsu paša skripts —, ielieciet to failā `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tas komandu palaiž kā sesijas daļu, tāpēc, atkal izrakstoties, tā tiek pienācīgi sakopta.

### Skriptu palaišana pie sistēmas notikumiem

Omarchy nedaudzos brīžos izšauj āķus (hooks), un jūs pie tiem varat piekabināt savus skriptus. Tie dzīvo mapē `~/.config/omarchy/hooks/<event>.d/`, viena direktorija katram notikumam, un katrs tur esošs izpildāms fails tiek palaists, kad notikums notiek:

| Notikums | Kad tas tiek palaists |
| ----- | ------------ |
| `post-boot` | Uzreiz pēc darbvirsmas palaišanās |
| `post-update` | Komandas `omarchy update` beigās, pēc pakotnēm, migrācijām un pakalpojumu restartēšanas, pirms mise rīku atjaunināšanas |
| `pre-refresh-pacman` | Pēc tam, kad `omarchy refresh pacman` atkārtoti sinhronizē pakotņu konfigurāciju, pirms pakotņu atjaunināšanas; kanāla maiņa to palaiž tajā pašā atsvaidzināšanas solī |
| `theme-set` | Pēc tēmas maiņas (tēmas nosaukums mainīgajā `$1`) |
| `font-set` | Pēc fonta maiņas (fonta nosaukums mainīgajā `$1`) |
| `battery-low` | Kad akumulatora līmenis kļūst zems (procenti mainīgajā `$1`) |

Āķis `pre-refresh-pacman` ir vieta, kur pieder pielāgoti repozitoriji vai `IgnorePkg` rindas, jo tas darbojas pirms pakotņu transakcijas. Abi ar atjaunināšanu saistītie āķi darbojas jūsu lietotāja vārdā pēc tam, kad Omarchy iztīra savu kešoto sudo autorizāciju, tāpēc āķim, kas izmanto `sudo`, vajadzīga sava autorizācija un tas var prasīt jūsu paroli.

Katrai no šīm direktorijām jau ir `.sample` fails, kas rāda āķa uzbūvi — noņemiet no nosaukuma `.sample`, lai to nolikti darbā. Lai instalētu skriptu, kuru esat uzrakstījis citviet, izmantojiet `omarchy hook install post-boot ~/my-hook`, kas to iekopē un padara izpildāmu.

### Savu izvēlnes ierakstu pievienošana

Omarchy izvēlni (`Super + Space`) ar jūsu paša rindām var paplašināt, rediģējot `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Ieraksti tiek atslēgoti ar punktotu identifikatoru, un identifikators ir tas, kas tos ievieto kokā, tāpēc `personal` parādās saknes izvēlnē, bet `personal.notes` parādās tās iekšienē:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Atkārtoti izmantojiet esošu identifikatoru, un jūs šīs rindas vietā to pārrakstāt, nevis pievienojat jaunu. Fails tiek piegādāts ar visiem pieejamajiem laukiem, kas dokumentēti kā komentāri.

### Savu čaulas eksportu, funkciju un aizstājvārdu pievienošana

Omarchy tiek piegādāts ar veselām daudzām ergonomiskiem aizstājvārdiem un noderīgām funkcijām, taču ir ļoti ierasti gribēt pievienot savējās. Gan aizstājvārdi, gan funkcijas, gan eksporti ir jāpievieno failā `~/.bashrc`. Šis fails atjauninājumos netiks pārrakstīts. Ja vēlaties mainīt kādu no Omarchy noklusējumiem, tos arī šeit varat droši pievienot.

### Iekšējo Omarchy failu mainīšana

Klau, šis ir jūsu dators. Jūs ar to varat darīt visu, ko vēlaties, taču es ieteiktu tiešā veidā nemainīt failus mapē `/usr/share/omarchy`. Tie pieder Omarchy pacman pakotnei, tāpēc jūsu izmaiņas nākamajā atjauninājumā vienkārši tiks pārrakstītas. Tā vietā jums būs labāk vienkārši pārrakstīt visas noklusējuma vērtības, kuras jums nepatīk, mapē `~/.config/*`.

Tādā veidā var nomainīt gandrīz jebko, piemēram, noklusējuma taustiņu saīsnes. Vienkārši rediģējiet `~/.config/hypr/bindings.lua`, lai, teiksim, [Obsidian](https://obsidian.md/) aizstātu ar [Joplin](https://joplinapp.org/) (instalējiet ar `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` esošo saīsni noņem pirms aizstāšanas pievienošanas. Tas pieņem tos pašus argumentus kā `o.bind`, ieskaitot palaišanas palīglīdzekļus un saīsnes iespējas. Izmantojiet `o.bind`, lai saīsni pievienotu, vai `hl.unbind`, lai to noņemtu bez aizstāšanas.

Ja uzstājat uz rosīšanos pa iekšējiem Omarchy failiem, pārslēdzieties uz dev kanālu caur _Atjaunināt > Channel > Dev_. Tas Omarchy savieno ar pirmkoda git izrakstīšanu mapē `~/omarchy`, kuru varat pēc sirds patikas mainīt. Šeit neviena nav, kas jums stāstītu, kā rīkoties!

### Jebkādu izmaiņu atiestatīšana

Ja galarezultātā konfigurācijās izveidojat jucekli, tās vienmēr var atgriezt pie noklusējumiem caur Omarchy izvēlnes sadaļu _Atjaunināt > Config_. Vai arī, palaižot `omarchy reinstall configs`, lai visu atiestatītu.
