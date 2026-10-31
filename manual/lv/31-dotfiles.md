# Dotfaili

Omarchy galvenokārt tiek konfigurēts, izmantojot tā sauktos dotfailus, kas atrodas `~/.config`. Tie tiek uzskatīti par jūsu failiem jūsu izmaiņām. Faili, kas atrodas `/usr/share/omarchy`, pieder pašam Omarchy, un ar tiem jums nevajadzētu jaukties. Ja jums kaut kas jāmaina `/usr/share/omarchy`, tā vietā jums vajadzētu pārrakstīt vērtību `~/.config`.

Galvenās konfigurācijas var rediģēt tieši no Omarchy izvēlnes (`Super + Space`), piemēram, _Setup > Keybindings_, _Setup > Input_ un _Setup > Config > [file]_. Kad jūs to darāt šādi, jebkurš process, kas pēc konfigurācijas rediģēšanas ir jārestartē, automātiski tiks restartēts pēc redaktora aizvēršanas (pēc noklusējuma Neovim — `:wq`, atcerieties! — bet to varat mainīt, izmantojot _Setup > Defaults > Editor_).

Šeit ir saraksts ar galvenajiem failiem `~/.config` un to, ko tie nosaka:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Galvenā Hyprland konfigurācija. Ielādē Omarchy noklusējumus un jūsu tālāk norādītos pārrakstīšanas failus. [Uzziniet vairāk par Hyprland konfigurācijām](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Jūsu pašu taustiņsaistījumi un noklusējumu pārrakstījumi. |
| `~/.config/hypr/monitors.lua` | Monitora iestatījumi, ko monitora panelis neaptver, piemēram, pagriešana, papildu režīmi vai monitora atstāšana izslēgtā stāvoklī. |
| `~/.config/hypr/input.lua` | Nosaka jūsu tastatūras izkārtojumu, peles un skārienpaliktņa iestatījumus. |
| `~/.config/hypr/looknfeel.lua` | Nosaka atstarpes, apmales, animācijas un pārējo izskatu. |
| `~/.config/hypr/autostart.lua` | Nosaka papildu procesus, kas tiek startēti kopā ar sesiju. |
| `~/.config/omarchy/shell.json` | Nosaka Omarchy čaulu: joslas novietojumu, izkārtojumu un logrīkus, kā arī ekrānsaudzētāja, bloķēšanas un dīkstāves laikus. |
| `~/.config/foot/foot.ini` | Nosaka jūsu termināli (foot ir noklusējums). |
| `~/.XCompose` | Definē jūsu ātrās piekļuves emoji un vārda/e-pasta automātisko pabeigšanu. Pēc izmaiņu veikšanas noteikti palaidiet `omarchy-restart-xcompose`. |

Ja galu galā veicat daudz izmaiņu, lai pielāgotu savu iestatījumu, ir laba doma dublēt visus šos dotfailus. [Stow ir lielisks veids, kā to izdarīt](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savu lietotņu startēšana kopā ar sesiju

Ja vēlaties, lai kaut kas darbotos katru reizi, kad piesakāties — sinhronizācijas dēmons, tērzēšanas lietotne, jūsu pašu skripts — ievietojiet to `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tas startē komandu kā sesijas daļu, tāpēc tā tiek pareizi apturēta, kad atkal izrakstāties.

### Skriptu palaišana pie sistēmas notikumiem

Omarchy aktivizē āķus dažos brīžos, un jūs varat tiem piekabināt savus skriptus. Tie atrodas `~/.config/omarchy/hooks/<event>.d/`, pa vienai direktorijai katram notikumam, un katrs izpildāmais fails tajā tiek palaists, kad notikums notiek:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Tieši pēc darbvirsmas startēšanas |
| `post-update` | Tuvojoties `omarchy update` beigām, pēc pakotnēm, migrācijām un pakalpojumu restartēšanas, pirms tiek atjaunināti mise rīki |
| `pre-refresh-pacman` | Pēc tam, kad `omarchy refresh pacman` atkārtoti sinhronizē pakotņu konfigurāciju, pirms tas atjaunina pakotnes; kanāla maiņa to palaiž tās pašas atsvaidzināšanas darbības laikā |
| `theme-set` | Pēc motīva maiņas (motīva nosaukums atrodas `$1`) |
| `font-set` | Pēc fonta maiņas (fonta nosaukums atrodas `$1`) |
| `battery-low` | Kad akumulatora līmenis kļūst zems (procenti atrodas `$1`) |

`pre-refresh-pacman` āķis ir vieta, kur pieder pielāgotas krātuves vai `IgnorePkg` rindas, jo tas tiek palaists pirms pakotņu transakcijas. Abi ar atjaunināšanu saistītie āķi darbojas kā jūsu lietotājs pēc tam, kad Omarchy ir notīrījis kešoto sudo autorizāciju, tāpēc āķim, kas izmanto `sudo`, nepieciešama sava autorizācija, un tas var prasīt jūsu paroli.

Katrā no šīm direktorijām jau ir `.sample` fails, kas parāda āķa formu — noņemiet `.sample` no nosaukuma, lai to liktu lietā. Lai instalētu skriptu, ko esat uzrakstījis citur, izmantojiet `omarchy hook install post-boot ~/my-hook`, kas to iekopē un padara izpildāmu.

### Savu izvēlnes ierakstu pievienošana

Omarchy izvēlni (`Super + Space`) var paplašināt ar savām rindām, rediģējot `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Ieraksti tiek apzīmēti ar punktotu id, un id nosaka to vietu kokā, tāpēc `personal` parādās saknes izvēlnē, bet `personal.notes` parādās tās iekšpusē:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Izmantojiet esošu id atkārtoti, un jūs pārrakstīsiet šo rindu, nevis pievienosiet jaunu. Fails tiek piegādāts ar visiem pieejamajiem laukiem, kas dokumentēti kā komentāri.

### Savu čaulas eksportu, funkciju un aizstājvārdu pievienošana

Omarchy komplektā ir virkne ergonomisku aizstājvārdu un noderīgu funkciju, bet ir ļoti ierasti vēlēties pievienot savus. Aizstājvārdi, funkcijas un eksporti jāpievieno `~/.bashrc`. Šis fails atjauninājumu laikā netiks pārrakstīts. Ja vēlaties mainīt kādu no Omarchy noklusējumiem, arī tos varat droši pievienot šeit.

### Vides mainīgo iestatīšana darbvirsmai

Darbvirsmas sesijas eksporti pieder `~/.config/uwsm/env.d/`. Šie faili darbojas pirms darbvirsmas startēšanas, tāpēc čaulas kļūda var jūs aizsūtīt atpakaļ uz pieteikšanās ekrānu. Rediģējot tos, turiet atvērtu darbojošos termināli. Lai atspējotu pārrakstījumu, pārvietojiet to ārā no `env.d`. Skatiet [pieteikšanās atkopšanu](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), ja izmaiņas liedz pieteikties.

### Iekšējo Omarchy failu mainīšana

Klausieties, šis ir jūsu dators. Jūs ar to varat darīt, ko vēlaties, bet es ieteiktu neveikt izmaiņas failos `/usr/share/omarchy` tieši. Tie pieder Omarchy pacman pakotnei, tāpēc jūsu izmaiņas nākamajā atjauninājumā vienkārši tiks pārrakstītas. Labāk tā vietā vienkārši pārrakstiet jebkuras noklusējuma vērtības, kas jums nepatīk, mapē `~/.config/*`.

Tādā veidā jūs varat mainīt gandrīz visu, piemēram, noklusējuma taustiņsaistījumus. Vienkārši rediģējiet `~/.config/hypr/bindings.lua`, lai, teiksim, aizstātu [Obsidian](https://obsidian.md/) ar [Joplin](https://joplinapp.org/) (instalējiet ar `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` noņem esošo saistījumu pirms tā aizstājēja pievienošanas. Tas pieņem tos pašus argumentus kā `o.bind`, ieskaitot palaišanas palīgus un saistījumu opcijas. Izmantojiet `o.bind`, lai pievienotu saistījumu, vai `hl.unbind`, lai to noņemtu, neaizstājot.

Ja uzstājat uz iekšējo Omarchy failu hakšanu, pārslēdzieties uz dev kanālu, izmantojot _Update > Channel > Dev_. Tas saista Omarchy ar pirmkoda git izrakstījumu `~/omarchy`, kuru varat brīvi mainīt, cik vien sirds kāro. Te nav neviena, kas jums teiks, ko darīt!

### Jebkuru izmaiņu atiestatīšana

Ja galu galā konfigurācijās ieviešat nekārtību, tās vienmēr varat atgriezt pie noklusējumiem, izmantojot _Update > Config_ Omarchy izvēlnē. Vai arī palaižot `omarchy reinstall configs`, lai visu atiestatītu.
