# Dotfiles

Omarchy galvenokārt tiek konfigurēts, izmantojot tā sauktos dotfailus, kas atrodas `~/.config`. Tie tiek uzskatīti par jūsu failiem jūsu izmaiņām. Faili, kas atrodas `/usr/share/omarchy`, pieder pašam Omarchy, un ar tiem jums nevajadzētu jaukties. Ja jums kaut kas jāmaina `/usr/share/omarchy`, tā vietā jums vajadzētu pārrakstīt vērtību `~/.config`.

Galvenās konfigurācijas var rediģēt tieši no Omarchy izvēlnes (`Super + Space`), piemēram, _Setup > Keyboard > Keybindings_, _Setup > Input_ un _Setup > Config > [file]_. Kad jūs to darāt šādā veidā, jebkurš process, kas pēc konfigurācijas rediģēšanas ir jārestartē, automātiski tiks restartēts pēc redaktora aizvēršanas (pēc noklusējuma Neovim — `:wq`, atcerieties! — bet to varat mainīt, izmantojot _Setup > Defaults > Editor_).

Šeit ir saraksts ar galvenajiem failiem `~/.config` un to, ko tie kontrolē:

| Fails | Nolūks |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Galvenā Hyprland konfigurācija. Ielādē Omarchy noklusējumus un jūsu tālāk norādītos pārrakstīšanas failus. [Uzziniet vairāk par Hyprland konfigurācijām](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Jūsu pašu taustiņu kombinācijas un noklusējumu pārrakstījumi. |
| `~/.config/hypr/monitors.lua` | Monitora iestatījumi, ko monitora panelis neaptver, piemēram, pagriešana, papildu režīmi vai monitora atstāšana izslēgtā stāvoklī. |
| `~/.config/hypr/input.lua` | Kontrolē jūsu tastatūras izkārtojumu, peles un skārienpaliktņa iestatījumus. |
| `~/.config/hypr/looknfeel.lua` | Kontrolē atstarpes, apmales, animācijas un pārējo izskatu. |
| `~/.config/hypr/autostart.lua` | Kontrolē papildu procesus, kas tiek startēti kopā ar sesiju. |
| `~/.config/omarchy/shell.json` | Kontrolē Omarchy čaulu: joslas novietojumu, izkārtojumu un logrīkus, kā arī ekrānsaudzētāja, bloķēšanas un dīkstāves laikus. |
| `~/.config/foot/foot.ini` | Kontrolē jūsu termināli (foot ir noklusējums). |
| `~/.XCompose` | Definē jūsu ātrās piekļuves emoji un vārda/e-pasta automātisko pabeigšanu. Pēc izmaiņu veikšanas noteikti palaidiet `omarchy-restart-xcompose`. |

Ja galu galā veicat daudz izmaiņu, lai pielāgotu savu iestatījumu, ir ieteicams dublēt visus šos dotfailus. [Stow ir lielisks veids, kā to izdarīt](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savu lietotņu startēšana kopā ar sesiju

Ja vēlaties, lai kaut kas darbotos katru reizi, kad piesakāties, — sinhronizācijas dēmons, tērzēšanas lietotne, jūsu pašu skripts — ielieciet to `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tas startē komandu kā daļu no sesijas, tāpēc, kad atkal izrakstīsieties, tā tiek pareizi notīrīta.

### Skriptu palaišana sistēmas notikumu gadījumā

Omarchy vairākos brīžos palaiž āķus, un jūs varat tiem piekabināt savus skriptus. Tie atrodas `~/.config/omarchy/hooks/<event>.d/`, viens katalogs katram notikumam, un katrs fails tur, kas nebeidzas ar `.sample`, notikuma brīdī tiek palaists ar bash:

| Notikums | Kad tas tiek palaists |
| ----- | ------------ |
| `post-boot` | Tūlīt pēc darbvirsmas startēšanas |
| `post-update` | Gandrīz `omarchy update` beigās, pēc pakotnēm, migrācijām un pakalpojumu restartēšanas, pirms tiek atjaunināti mise rīki |
| `pre-refresh-pacman` | Pēc tam, kad `omarchy refresh pacman` atkārtoti sinhronizē pakotņu konfigurāciju, pirms tas atjaunina pakotnes; kanāla maiņa to palaiž tajā pašā atsvaidzināšanas solī |
| `theme-set` | Pēc motīva maiņas (motīva nosaukums `$1`) |
| `font-set` | Pēc fonta maiņas (fonta nosaukums `$1`) |
| `battery-low` | Kad akumulatora uzlādes līmenis ir zems (procenti `$1`) |

`pre-refresh-pacman` āķis ir vieta, kur pieder pielāgotas krātuves vai `IgnorePkg` rindas, jo tas tiek palaists pirms pakotņu transakcijas. Abi tiek palaisti kā jūsu lietotājs. `post-update` tiek palaists, kamēr `omarchy update` sudo autorizācija vēl ir svaiga, tāpēc āķis, kas izmanto `sudo`, vēlreiz neprasīs jūsu paroli; `pre-refresh-pacman` tiek palaists tūlīt pēc tam, kad `omarchy refresh pacman` pats ir izmantojis sudo.

Katrā no šiem katalogiem jau ir `.sample` fails, kas parāda āķa formu, — noņemiet `.sample` no nosaukuma, lai to liktu lietā. Lai instalētu skriptu, ko esat uzrakstījis citur, izmantojiet `omarchy hook install post-boot ~/my-hook`, kas to iekopē un padara izpildāmu.

### Savu izvēlnes ierakstu pievienošana

Omarchy izvēlni (`Super + Space`) var paplašināt ar savām rindām, rediģējot `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Ierakstiem kā atslēga tiek izmantots punktots id, un id ir tas, kas tos ievieto kokā, tāpēc `personal` parādās saknes izvēlnē, bet `personal.notes` parādās tās iekšpusē:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ja atkārtoti izmantojat esošu id, jūs pārrakstāt šo rindu, nevis pievienojat jaunu. Fails tiek piegādāts ar visiem pieejamajiem laukiem, kas aprakstīti komentāros.

### Savu čaulas eksportu, funkciju un aizstājvārdu pievienošana

Omarchy tiek piegādāts ar kaudzi ergonomisku aizstājvārdu un noderīgu funkciju, bet ir ļoti ierasts vēlēties pievienot savus. Gan aizstājvārdus, gan funkcijas, gan eksportus jums vajadzētu pievienot `~/.bashrc`. Šis fails atjauninājumu laikā netiks pārrakstīts. Ja vēlaties mainīt kādu no Omarchy noklusējumiem, tos droši varat pievienot arī šeit.

### Vides mainīgo iestatīšana darbvirsmai

Darbvirsmas sesijas eksportiem jāatrodas `~/.config/uwsm/env.d/`. Šie faili tiek palaisti pirms jūsu darbvirsmas startēšanas, tāpēc čaulas kļūda var jūs nosūtīt atpakaļ uz pieteikšanās ekrānu. Rediģējot tos, turiet atvērtu darbojošos termināli. Lai atspējotu pārrakstījumu, pārvietojiet to ārā no `env.d`. Skatiet [pieteikšanās atkopšanu](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), ja izmaiņas liedz pieteikties.

### Iekšējo Omarchy failu mainīšana

Klausieties, šis ir jūsu dators. Jūs varat ar to darīt visu, ko vēlaties, bet es ieteiktu neveikt izmaiņas tieši failos `/usr/share/omarchy`. Tie pieder Omarchy pacman pakotnei, tāpēc jūsu izmaiņas nākamajā atjauninājumā vienkārši tiks pārrakstītas. Jums būs labāk tā vietā vienkārši pārrakstīt visas noklusējuma vērtības, kas jums nepatīk, mapē `~/.config/*`.

Jūs šādā veidā varat mainīt gandrīz visu, piemēram, noklusējuma taustiņu kombinācijas. Vienkārši rediģējiet `~/.config/hypr/bindings.lua`, lai, teiksim, aizstātu [Obsidian](https://obsidian.md/) ar [Joplin](https://joplinapp.org/) (instalējiet ar `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` noņem esošo saistījumu, pirms pievieno tā aizstājēju. Tas pieņem tos pašus argumentus kā `o.bind`, tostarp palaišanas palīgus un saistījuma opcijas. Izmantojiet `o.bind`, lai pievienotu saistījumu, vai `hl.unbind`, lai to noņemtu, neaizstājot.

Ja uzstājāt uz iekšējo Omarchy failu hakšanu, pārslēdzieties uz dev kanālu, izmantojot _Update > Channel > Dev_. Tas sasaista Omarchy ar avota koda git izrakstu `~/omarchy`, kuru jūs varat brīvi mainīt pēc sirds patikas. Šeit nav neviena, kas jums teiktu, ko darīt!

### Jebkuru izmaiņu atiestatīšana

Ja galu galā konfigurācijās radāt jucekli, jūs vienmēr varat tās atgriezt pie noklusējumiem, izmantojot _Update > Config_ Omarchy izvēlnē. Vai arī palaižot `omarchy reinstall configs`, lai visu atiestatītu.
