# Dotfaili

Omarchy galvenokārt tiek konfigurēts, izmantojot tā sauktos dotfailus, kas atrodas `~/.config`. Tie tiek uzskatīti par taviem failiem tavām izmaiņām. Faili, kas atrodas `/usr/share/omarchy`, pieder pašam Omarchy, un ar tiem tev nevajadzētu jaukties. Ja tev kaut kas jāmaina `/usr/share/omarchy`, tā vietā tev vajadzētu pārrakstīt vērtību `~/.config`.

Galvenās konfigurācijas var rediģēt tieši no Omarchy izvēlnes (`Super + Space`), piemēram, _Setup > Keybindings_, _Setup > Input_ un _Setup > Config > [file]_. Šādi rīkojoties, jebkurš process, kam pēc konfigurācijas labojumiem nepieciešama restartēšana, automātiski tiks restartēts, kad aizvērsi redaktoru (pēc noklusējuma Neovim — `:wq`, atceries! —, bet to vari mainīt sadaļā _Setup > Defaults > Editor_).

Šeit ir saraksts ar galvenajiem failiem `~/.config` un to, ko tie kontrolē:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Galvenā Hyprland konfigurācija. Ielādē Omarchy noklusējumus un tavus zemāk esošos pārrakstīšanas failus. [Uzzini vairāk par Hyprland konfigurācijām](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tavi paša taustiņu sasaistījumi un noklusējumu pārrakstījumi. |
| `~/.config/hypr/monitors.lua` | Monitora iestatījumi, ko monitora panelis neaptver, piemēram, pagriešana, papildu režīmi vai monitora izslēgta atstāšana. |
| `~/.config/hypr/input.lua` | Kontrolē tavu tastatūras izkārtojumu, peles un skārienpaliktņa iestatījumus. |
| `~/.config/hypr/looknfeel.lua` | Kontrolē atstarpes, apmales, animācijas un pārējo izskatu. |
| `~/.config/hypr/autostart.lua` | Kontrolē papildu procesus, kas tiek palaisti kopā ar sesiju. |
| `~/.config/omarchy/shell.json` | Kontrolē Omarchy čaulu: joslas novietojumu, izkārtojumu un logrīkus, kā arī ekrānsaudzētāja, bloķēšanas un dīkstāves laikus. |
| `~/.config/foot/foot.ini` | Kontrolē tavu termināli (pēc noklusējuma tas ir foot). |
| `~/.XCompose` | Definē tavu ātras piekļuves emoji un vārda/e-pasta automātisko pabeigšanu. Pēc izmaiņu veikšanas noteikti palaid `omarchy-restart-xcompose`. |

Ja galu galā veic daudz izmaiņu, lai pielāgotu savu iestatījumu, ir laba doma dublēt visus šos dotfailus. [Stow ir lielisks veids, kā to izdarīt](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savu lietotņu palaišana kopā ar sesiju

Ja gribi, lai kaut kas darbotos katru reizi, kad piesakies, — sinhronizācijas dēmons, tērzēšanas lietotne, tavs paša skripts — ieliec to `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tas palaiž komandu kā sesijas daļu, tāpēc tā tiek pienācīgi notīrīta, kad atkal izraksties.

### Skriptu palaišana pie sistēmas notikumiem

Omarchy palaiž āķus vairākos brīžos, un tu tiem vari piekabināt savus skriptus. Tie atrodas `~/.config/omarchy/hooks/<event>.d/`, pa vienai mapei katram notikumam, un katrs izpildāmais fails tajā tiek palaists, kad notikums notiek:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Tūlīt pēc darbvirsmas palaišanās |
| `post-update` | Tuvojoties `omarchy update` beigām, pēc pakotnēm, migrācijām un pakalpojumu restartēšanas, pirms mise rīku atjaunināšanas |
| `pre-refresh-pacman` | Pēc tam, kad `omarchy refresh pacman` atkārtoti sinhronizē pakotņu konfigurāciju, pirms tā atjaunina pakotnes; kanāla maiņa to palaiž tajā pašā atsvaidzināšanas solī |
| `theme-set` | Pēc motīva maiņas (motīva nosaukums `$1`) |
| `font-set` | Pēc fonta maiņas (fonta nosaukums `$1`) |
| `battery-low` | Kad akumulatora līmenis kļūst zems (procenti `$1`) |

`pre-refresh-pacman` āķis ir vieta, kur pieder pielāgoti repozitoriji vai `IgnorePkg` rindas, jo tas tiek palaists pirms pakotņu transakcijas. Abi ar atjaunināšanu saistītie āķi tiek palaisti kā tavs lietotājs pēc tam, kad Omarchy notīra savu kešoto sudo autorizāciju, tāpēc āķim, kas izmanto `sudo`, vajadzīga pašam sava autorizācija, un tas var prasīt tavu paroli.

Katrā no šīm mapēm jau atrodas `.sample` fails, kas parāda āķa formu — noņem `.sample` no nosaukuma, lai to iedarbinātu. Lai instalētu skriptu, ko esi uzrakstījis citur, izmanto `omarchy hook install post-boot ~/my-hook`, kas to iekopē iekšā un padara izpildāmu.

### Savu izvēlnes ierakstu pievienošana

Omarchy izvēlni (`Super + Space`) var paplašināt ar savām rindām, rediģējot `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Ieraksti tiek apzīmēti ar punktotu id, un tieši id tos ievieto kokā, tāpēc `personal` parādās saknes izvēlnē, bet `personal.notes` parādās tās iekšienē:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Izmantojot esošu id atkārtoti, tu pārraksti šo rindu, nevis pievieno jaunu. Failā visi pieejamie lauki ir dokumentēti kā komentāri.

### Savu čaulas eksportu, funkciju un aliasu pievienošana

Omarchy nāk ar kaudzi ergonomisku aliasu un noderīgu funkciju, bet ļoti bieži gribas pievienot savus. Gan aliasus, gan funkcijas, gan eksportus tev vajadzētu pievienot `~/.bashrc`. Šis fails atjaunināšanas laikā netiks pārrakstīts. Ja gribi mainīt kādu no Omarchy noklusējumiem, arī tos vari droši pievienot šeit.

### Iekšējo Omarchy failu mainīšana

Skaties, šis ir tavs dators. Tu ar to vari darīt, ko vien gribi, bet es neieteiktu tieši mainīt failus `/usr/share/omarchy`. Tie pieder Omarchy pacman pakotnei, tāpēc tavas izmaiņas nākamajā atjaunināšanā vienkārši tiks pārrakstītas. Labāk tā vietā vienkārši pārraksti visas noklusējuma vērtības, kas tev nepatīk, `~/.config/*` mapē.

Šādi vari mainīt gandrīz visu, piemēram, noklusējuma taustiņu sasaistījumus. Vienkārši rediģē `~/.config/hypr/bindings.lua`, lai, teiksim, aizstātu [Obsidian](https://obsidian.md/) ar [Joplin](https://joplinapp.org/) (instalē ar `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` noņem esošo sasaistījumu pirms tā aizstājēja pievienošanas. Tas pieņem tos pašus argumentus kā `o.bind`, ieskaitot palaišanas palīgfunkcijas un sasaistījumu opcijas. Izmanto `o.bind`, lai pievienotu sasaistījumu, vai `hl.unbind`, lai to noņemtu, neaizstājot.

Ja tomēr uzstāj uz rakņāšanos pa iekšējiem Omarchy failiem, pārslēdzies uz dev kanālu sadaļā _Update > Channel > Dev_. Tas saista Omarchy ar pirmkoda git izrakstīto kopiju `~/omarchy`, ko vari brīvi mainīt pēc sirds patikas. Šeit neviens tev neteiks, ko darīt!

### Visu izmaiņu atiestatīšana

Ja galu galā sajauc konfigurācijas haosā, tu tās vienmēr vari atgriezt pie noklusējumiem, izmantojot _Update > Config_ Omarchy izvēlnē. Vai arī palaižot `omarchy reinstall configs`, lai atiestatītu visu.
