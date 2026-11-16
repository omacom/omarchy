# Dotfiles

Omarchy primāri tiek konfigurēts, izmantojot tā sauktos dotfailus, kas atrodas `~/.config`. Tos uzskata par taviem failiem tavām izmaiņām. Faili, kas atrodas `/usr/share/omarchy`, pieder pašam Omarchy, un tev nevajadzētu ar tiem ņemties. Ja tev nepieciešams kaut ko mainīt `/usr/share/omarchy`, tā vietā tev vajadzētu pārrakstīt vērtību `~/.config`.

Galvenās konfigurācijas var rediģēt tieši no Omarchy izvēlnes (`Super + Space`), piemēram, _Setup > Keyboard > Keybindings_, _Setup > Input_ un _Setup > Config > [file]_. Kad tu to dari šādā veidā, jebkurš process, kas pēc konfigurācijas rediģēšanas ir jārestartē, automātiski tiks restartēts pēc tam, kad aizvērsi redaktoru (pēc noklusējuma Neovim — `:wq`, atceries! — bet tu to vari mainīt, izmantojot _Setup > Defaults > Editor_).

Šeit ir saraksts ar galvenajiem failiem `~/.config` un to, ko tie kontrolē:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Galvenais Hyprland konfigurācijas fails. Ielādē Omarchy noklusējuma vērtības un tavus tālāk norādītos pārrakstīšanas failus. [Uzzini vairāk par Hyprland konfigurācijām](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tavi paša taustiņsaistījumi un noklusējuma vērtību pārrakstījumi. |
| `~/.config/hypr/monitors.lua` | Monitora iestatījumi, ko monitora panelis neaptver, piemēram, pagriešana, papildu režīmi vai monitora atstāšana izslēgtā stāvoklī. |
| `~/.config/hypr/input.lua` | Kontrolē tavu tastatūras izkārtojumu, peles un skārienpaliktņa iestatījumus. |
| `~/.config/hypr/looknfeel.lua` | Kontrolē atstarpes, apmales, animācijas un pārējo izskatu. |
| `~/.config/hypr/autostart.lua` | Kontrolē papildu procesus, kas tiek startēti kopā ar sesiju. |
| `~/.config/omarchy/shell.json` | Kontrolē Omarchy čaulu: joslas novietojumu, izkārtojumu un logrīkus, kā arī ekrānsaudzētāja, bloķēšanas un dīkstāves laikus. |
| `~/.config/foot/foot.ini` | Kontrolē tavu termināli (foot ir noklusējums). |
| `~/.XCompose` | Definē tavu ātrās piekļuves emoji un vārda/e-pasta automātisko pabeigšanu. Pēc izmaiņu veikšanas noteikti palaid `omarchy-restart-xcompose`. |

Ja tu galu galā veic daudz izmaiņu, lai pielāgotu savu iestatījumu, ir laba doma dublēt visus šos dotfailus. [Stow ir lielisks veids, kā to izdarīt](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savu lietotņu startēšana kopā ar sesiju

Ja tu vēlies, lai kaut kas darbotos katru reizi, kad tu piesakies — sinhronizācijas dēmons, tērzēšanas lietotne, tavs paša skripts —, ieliec to `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tas startē komandu kā daļu no sesijas, tāpēc, kad tu atkal izrakstīsies, tā tiks pareizi iztīrīta.

### Skriptu palaišana sistēmas notikumu laikā

Omarchy aktivizē āķus dažos mirkļos, un tu vari tiem piekabināt savus skriptus. Tie atrodas `~/.config/omarchy/hooks/<event>.d/` — viena direktorija katram notikumam —, un katrs tur esošais izpildāmais fails tiek palaists, kad notikums notiek:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Tūlīt pēc darbvirsmas startēšanas |
| `post-update` | Gandrīz `omarchy update` beigās, pēc pakotnēm, migrācijām un pakalpojumu restartēšanas, pirms tiek atjaunināti mise rīki |
| `pre-refresh-pacman` | Pēc tam, kad `omarchy refresh pacman` atkārtoti sinhronizē pakotņu konfigurāciju, pirms tas atjaunina pakotnes; kanāla maiņa to palaiž tā paša atsvaidzināšanas soļa laikā |
| `theme-set` | Pēc motīva maiņas (motīva nosaukums `$1`) |
| `font-set` | Pēc fonta maiņas (fonta nosaukums `$1`) |
| `battery-low` | Kad akumulators kļūst zems (procenti `$1`) |

`pre-refresh-pacman` āķis ir vieta, kur pieder pielāgotām krātuvēm vai `IgnorePkg` rindām, jo tas tiek palaists pirms pakotņu transakcijas. Abi ar atjaunināšanu saistītie āķi darbojas ar tavu lietotāju pēc tam, kad Omarchy notīra savu kešoto sudo autorizāciju, tāpēc āķim, kas izmanto `sudo`, ir nepieciešama sava autorizācija un tas var prasīt tavu paroli.

Katrā no šīm direktorijām jau ir `.sample` fails, kas parāda āķa formu — noņem `.sample` no nosaukuma, lai to liktu lietā. Lai instalētu skriptu, ko esi uzrakstījis citur, izmanto `omarchy hook install post-boot ~/my-hook`, kas to iekopē un padara izpildāmu.

### Savu izvēlnes ierakstu pievienošana

Omarchy izvēlni (`Super + Space`) var paplašināt ar savām rindām, rediģējot `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Ieraksti tiek atslēgoti ar punktētu id, un id ir tas, kas tos ievieto kokā, tāpēc `personal` parādās saknes izvēlnē, bet `personal.notes` parādās tās iekšpusē:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Izmanto esošu id vēlreiz, un tu pārrakstīsi šo rindu, nevis pievienosi jaunu. Fails tiek piegādāts ar visiem pieejamajiem laukiem, kas dokumentēti kā komentāri.

### Savu čaulas eksportu, funkciju un aizstājvārdu pievienošana

Omarchy tiek piegādāts ar virkni ergonomisku aizstājvārdu un noderīgu funkciju, bet ir ļoti ierasts vēlēties pievienot savējos. Gan aizstājvārdi, gan funkcijas, gan eksporti tev jāpievieno `~/.bashrc`. Šis fails atjaunināšanas laikā netiks pārrakstīts. Ja tu vēlies mainīt kādu no Omarchy noklusējuma vērtībām, tu tās vari droši pievienot arī šeit.

### Vides mainīgo iestatīšana darbvirsmai

Darbvirsmas sesijas eksporti pieder `~/.config/uwsm/env.d/`. Šie faili tiek palaisti pirms tavas darbvirsmas startēšanas, tāpēc čaulas kļūda var tevi aizsūtīt atpakaļ uz pieteikšanās ekrānu. Kamēr tos rediģē, turi atvērtu darbojošos termināli. Lai atspējotu pārrakstījumu, pārvieto to ārpus `env.d`. Skati [pieteikšanās atkopšanu](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), ja izmaiņas neļauj pieteikties.

### Iekšējo Omarchy failu mainīšana

Klausies, šis ir tavs dators. Tu ar to vari darīt, ko vien vēlies, bet es ieteiktu neveikt izmaiņas failos, kas atrodas `/usr/share/omarchy`, tieši. Tie pieder Omarchy pacman pakotnei, tāpēc tavas izmaiņas nākamajā atjaunināšanas reizē vienkārši tiks pārrakstītas. Tā vietā tev labāk vienkārši pārrakstīt visas noklusējuma vērtības, kas tev nepatīk, mapē `~/.config/*`.

Šādi tu vari mainīt gandrīz visu, piemēram, noklusējuma taustiņsaistījumus. Vienkārši rediģē `~/.config/hypr/bindings.lua`, lai, teiksim, aizstātu [Obsidian](https://obsidian.md/) ar [Joplin](https://joplinapp.org/) (instalē ar `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` noņem esošo saistījumu pirms tā aizstājēja pievienošanas. Tam ir tādi paši argumenti kā `o.bind`, ieskaitot palaišanas palīgus un saistījumu opcijas. Izmanto `o.bind`, lai pievienotu saistījumu, vai `hl.unbind`, lai to noņemtu, neaizstājot.

Ja tu uzstāj uz iekšējo Omarchy failu bakstīšanu, pārslēdzies uz dev kanālu, izmantojot _Update > Channel > Dev_. Tas saista Omarchy ar avota koda git izrakstu `~/omarchy`, ko tu vari brīvi mainīt, cik vien sirds kāro. Te nav neviena, kurš tev teiks, ko darīt!

### Jebkuru izmaiņu atiestatīšana

Ja tu galu galā savas konfigurācijas saved nekārtībā, tu tās vienmēr vari atgriezt pie noklusējuma vērtībām, izmantojot _Update > Config_ Omarchy izvēlnē. Vai arī palaižot `omarchy reinstall configs`, lai atiestatītu visu.
