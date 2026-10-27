# Dotfiles

Omarchy pirmiausia konfigūruojama per vadinamuosius dotfiles, kurie gyvena `~/.config`. Jie laikomi tavo failais tavo pakeitimams. Failai, gyvenantys `/usr/share/omarchy`, priklauso pačiai Omarchy, ir tau neturėtų jų knisti. Jei reikia ką nors pakeisti `/usr/share/omarchy`, vietoj to turėtum perrašyti reikšmę `~/.config`.

Svarbiausias konfigūracijas galima redaguoti tiesiai iš Omarchy meniu (`Super + Space`), pavyzdžiui, _Nuostatos > Monitoriai_, _Nuostatos > Spartieji klavišai_, _Nuostatos > Input_ ir _Nuostatos > Config > [file]_. Kai tai darai šiuo būdu, bet kuris procesas, kurį reikia paleisti iš naujo po konfigūracijos redagavimo, automatiškai bus paleistas po to, kai išeisi iš redaktoriaus (pagal nutylėjimą Neovim — `:wq`, atmink! — bet gali tai pakeisti per _Nuostatos > Defaults > Editor_).

Štai sąrašas svarbiausių failų `~/.config` ir ką jie kontroliuoja:

| Failas                  | Paskirtis              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Pagrindinė Hyprland konfigūracija. Įkelia Omarchy numatytuosius ir tavo perrašymo failus žemiau. [Sužinok daugiau apie Hyprland konfigūracijas](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tavo paties klavišų susiejimai ir numatytųjų perrašymai. |
| `~/.config/hypr/monitors.lua` | Kontroliuoja tavo monitorius, raišką ir padėtį. |
| `~/.config/hypr/input.lua` | Kontroliuoja tavo klaviatūros išdėstymą, pelės ir jutiklinio kilimėlio nuostatas. |
| `~/.config/hypr/looknfeel.lua` | Kontroliuoja tarpus, kraštines, animacijas ir likusią išvaizdą. |
| `~/.config/hypr/autostart.lua` | Kontroliuoja papildomus procesus, paleidžiamus kartu su sesija. |
| `~/.config/omarchy/shell.json` | Kontroliuoja Omarchy shell: juostos padėtį, išdėstymą ir valdiklius, plius ekrano užsklandos, užrakinimo ir veiklos nutraukimo laikus. |
| `~/.config/foot/foot.ini` | Kontroliuoja tavo terminalą (foot yra numatytasis). |
| `~/.XCompose` | Apibrėžia tavo greito priėjimo emoji ir vardo/el. pašto automatinį užbaigimą. Po pakeitimų būtinai paleisk `omarchy-restart-xcompose`. |

Jei galiausiai atliksi daug pakeitimų, kad pritaikytum savo sąranką, gera mintis sukurti atsargines visų šių dotfiles kopijas. [Stow yra puikus būdas tai padaryti](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savo programų paleidimas kartu su sesija

Jei nori, kad kažkas veiktų kiekvieną kartą prisijungus — sinchronizavimo daemonas, pokalbių programa, tavo paties scenarijus — įdėk tai į `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tai paleidžia komandą kaip sesijos dalį, tad ji tinkamai išvaloma vėl atsijungiant.

### Scenarijų vykdymas pagal sistemos įvykius

Omarchy sukelia kablį (hook) keletu momentų, o prie jų gali prikabinti savo scenarijus. Jie gyvena `~/.config/omarchy/hooks/<event>.d/`, po vieną katalogą kiekvienam įvykiui, ir kiekvienas ten esantis vykdomasis failas paleidžiamas, kai įvykis atsitinka:

| Įvykis | Kada veikia |
| ----- | ------------ |
| `post-boot` | Iškart po to, kai darbalaukis pasileido |
| `post-update` | Netoli `omarchy update` pabaigos, po paketų, migracijų ir paslaugų paleidimų iš naujo, prieš atnaujinant mise įrankius |
| `pre-refresh-pacman` | Po to, kai `omarchy refresh pacman` iš naujo sinchronizuoja paketų konfigūraciją, prieš jam atnaujinant paketus; kanalo perjungimas jį paleidžia per tą patį atnaujinimo žingsnį |
| `theme-set` | Po temos pakeitimo (temos pavadinimas `$1`) |
| `font-set` | Po šrifto pakeitimo (šrifto pavadinimas `$1`) |
| `battery-low` | Kai akumuliatorio įkrova sumažėja (procentai `$1`) |

Kablys `pre-refresh-pacman` yra ta vieta, kur priklauso pasirinktinių saugyklų arba `IgnorePkg` eilutės, kadangi jis veikia prieš paketų operaciją. Abu su atnaujinimu susiję kabliai veikia kaip tavo naudotojas, po to, kai Omarchy išvalo savo talpintą sudo leidimą, tad kabliui, kuris naudoja `sudo`, reikia savo leidimo ir gali paprašyti tavo slaptažodžio.

Kiekviename iš tų katalogų jau yra `.sample` failas, rodantis kablio formą — numesk `.sample` iš pavadinimo, kad jį priverstum dirbti. Kad įdiegtum scenarijų, kurį parašei kitur, naudok `omarchy hook install post-boot ~/my-hook`, kuris jį nukopijuos ir padarys vykdomuoju.

### Savo meniu įrašų pridėjimas

Omarchy meniu (`Super + Space`) gali būti išplėstas tavo paties eilutėmis redaguojant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Įrašai raktuojami taškiniu id, ir id yra tai, kas juos patalpina medyje, tad `personal` pasirodo šakniniame meniu, o `personal.notes` pasirodo jo viduje:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Naudok esamą id ir perrašysi tą eilutę, užuot pridėjęs naują. Failas pristatomas su visais prieinamais laukais, dokumentuotais kaip komentarais.

### Savo shell eksportų, funkcijų ir alias pridėjimas

Omarchy pristatoma su daugybe ergonomiškų alias ir naudingų funkcijų, bet labai įprasta norėti pridėti savųjų. Tiek alias, tiek funkcijas, tiek eksportus turėtum pridėti į `~/.bashrc`. Šis failas nebus perrašytas atnaujinimų metu. Jei nori pakeisti bet kuriuos Omarchy numatytuosius, taip pat gali juos saugiai pridėti čia.

### Vidinių Omarchy failų keitimas

Žiūrėk, tai tavo kompiuteris. Gali su juo daryti ką nori, bet patarčiau nekeisti failų `/usr/share/omarchy` tiesiogiai. Jie priklauso Omarchy pacman paketui, tad tavo pakeitimai tiesiog bus perrašyti kito atnaujinimo metu. Geriau tiesiog perrašyti bet kurias numatytąsias reikšmes, kurios nepatinka, aplanke `~/.config/*`.

Taip gali pakeisti beveik viską, pavyzdžiui, numatytuosius klavišų susiejimus. Tiesiog redaguok `~/.config/hypr/bindings.lua`, kad, tarkim, pakeistum [Obsidian](https://obsidian.md/) į [Joplin](https://joplinapp.org/) (įdiek su `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` pašalina esamą susiejimą prieš pridėdamas jo pakaitalą. Jis ima tuos pačius argumentus kaip `o.bind`, įskaitant paleidimo pagalbines ir susiejimo parinktis. Naudok `o.bind`, kad pridėtum susiejimą, arba `hl.unbind`, kad vieną pašalintum nepakeisdamas.

Jei primygtinai nori kapstytis vidiniuose Omarchy failuose, pereik prie dev kanalo per _Atnaujinti > Channel > Dev_. Tai susieja Omarchy su šaltinio kodo git kopija `~/omarchy`, kurią laisvai gali keisti kiek širdis geidžia. Čia niekas nesiruošia tau sakyti, ką daryti!

### Bet kokių pakeitimų atkūrimas

Jei galiausiai padarysi netvarką konfigūracijose, visada gali jas grąžinti prie numatytųjų per _Atnaujinti > Config_ Omarchy meniu. Arba paleidęs `omarchy reinstall configs`, kad atkurtum viską.
