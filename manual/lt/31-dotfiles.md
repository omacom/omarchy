# Taškiniai failai (dotfiles)

Omarchy pirmiausia konfigūruojama per vadinamuosius dotfiles, esančius `~/.config`. Tie laikomi jūsų failais, skirtais jūsų pakeitimams. Failai, esantys `/usr/share/omarchy`, priklauso pačiai Omarchy, ir neturėtumėte su jais terliotis. Jei reikia ką nors keisti `/usr/share/omarchy`, vietoj to turėtumėte perrašyti reikšmę `~/.config`.

Pagrindines konfigūracijas galima redaguoti tiesiai iš Omarchy meniu (`Super + Space`), pvz., _Setup > Keybindings_, _Setup > Input_ ir _Setup > Config > [file]_. Kai tai darote šiuo būdu, bet kuris procesas, kurį reikia paleisti iš naujo redagavus konfigūraciją, bus automatiškai paleistas iš naujo, kai uždarysite redaktorių (pagal numatytuosius nustatymus Neovim — `:wq`, atsiminkite! — bet tai galite pakeisti per _Setup > Defaults > Editor_).

Štai pagrindinių failų `~/.config` sąrašas ir tai, ką jie valdo:

| Failas | Paskirtis |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Pagrindinė Hyprland konfigūracija. Įkelia Omarchy numatytuosius nustatymus ir jūsų toliau nurodytus perrašymo failus. [Sužinokite daugiau apie Hyprland konfigūracijas](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Jūsų pačių klavišų susiejimai ir numatytųjų perrašymai. |
| `~/.config/hypr/monitors.lua` | Monitoriaus nustatymai, kurių neapima monitoriaus skydelis, pvz., pasukimas, papildomi režimai arba monitoriaus išjungimas. |
| `~/.config/hypr/input.lua` | Valdo klaviatūros išdėstymą, pelės ir jutiklinio kilimėlio nustatymus. |
| `~/.config/hypr/looknfeel.lua` | Valdo tarpus, rėmelius, animacijas ir likusią išvaizdą. |
| `~/.config/hypr/autostart.lua` | Valdo papildomus procesus, paleidžiamus kartu su sesija. |
| `~/.config/omarchy/shell.json` | Valdo Omarchy shell: juostos padėtį, išdėstymą ir valdiklius, taip pat ekrano užsklandos, užrakto ir neveiklumo laikus. |
| `~/.config/foot/foot.ini` | Valdo jūsų terminalą (foot yra numatytasis). |
| `~/.XCompose` | Apibrėžia jūsų greitosios prieigos emoji ir vardo / el. pašto automatinį užbaigimą. Būtinai paleiskite `omarchy-restart-xcompose` atlikę pakeitimus. |

Jei galiausiai atliksite daug pakeitimų, kad pritaikytumėte savo sąranką, gera mintis pasidaryti visų šių dotfiles atsarginę kopiją. [Stow yra puikus būdas tai padaryti](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savo programų paleidimas kartu su sesija

Jei norite, kad kažkas veiktų kiekvieną kartą prisijungus — sinchronizavimo demonas, pokalbių programa, jūsų pačių scenarijus — įdėkite tai į `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tai paleidžia komandą kaip sesijos dalį, todėl, kai vėl atsijungsite, ji bus tinkamai išvalyta.

### Scenarijų paleidimas įvykus sistemos įvykiams

Omarchy tam tikrais momentais sužadina kabliukus, prie kurių galite prikabinti savo scenarijus. Jie yra `~/.config/omarchy/hooks/<event>.d/`, po vieną katalogą kiekvienam įvykiui, ir kiekvienas vykdomasis failas ten paleidžiamas, kai įvykis nutinka:

| Įvykis | Kada paleidžiamas |
| ----- | ------------ |
| `post-boot` | Iškart po to, kai darbalaukis paleidžiamas |
| `post-update` | Netoli `omarchy update` pabaigos, po paketų, migracijų ir paslaugų paleidimo iš naujo, prieš atnaujinant mise įrankius |
| `pre-refresh-pacman` | Po to, kai `omarchy refresh pacman` iš naujo sinchronizuoja paketų konfigūraciją, prieš atnaujinant paketus; kanalo perjungimas jį paleidžia per tą patį atnaujinimo veiksmą |
| `theme-set` | Po temos pakeitimo (temos pavadinimas `$1`) |
| `font-set` | Po šrifto pakeitimo (šrifto pavadinimas `$1`) |
| `battery-low` | Kai baterijos įkrova tampa maža (procentinė dalis `$1`) |

Kablys `pre-refresh-pacman` yra vieta, kur priklauso pasirinktinės saugyklos arba `IgnorePkg` eilutės, nes jis paleidžiamas prieš paketų operaciją. Abu su atnaujinimu susiję kabliukai paleidžiami kaip jūsų naudotojas po to, kai Omarchy išvalo savo talpykloje saugomą sudo autorizaciją, todėl kabliukui, naudojančiam `sudo`, reikia savo autorizacijos ir jis gali paprašyti jūsų slaptažodžio.

Kiekviename iš tų katalogų jau yra `.sample` failas, rodantis kabliuko formą — nuimkite `.sample` iš pavadinimo, kad jį paleistumėte į darbą. Norėdami įdiegti scenarijų, kurį parašėte kitur, naudokite `omarchy hook install post-boot ~/my-hook`, kuris jį nukopijuoja ir padaro vykdomąjį.

### Savo meniu įrašų pridėjimas

Omarchy meniu (`Super + Space`) galima išplėsti savo eilutėmis redaguojant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Įrašai identifikuojami punktyriniu id, ir id nustato jų vietą medyje, todėl `personal` rodomas šakniniame meniu, o `personal.notes` rodomas jo viduje:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Pakartotinai panaudoję esamą id, perrašysite tą eilutę, o ne pridėsite naują. Faile visi galimi laukai pateikti ir dokumentuoti kaip komentarai.

### Savo apvalkalo eksportų, funkcijų ir slapyvardžių pridėjimas

Omarchy pateikiama su daugybe ergonomiškų slapyvardžių ir naudingų funkcijų, bet labai įprasta norėti pridėti savų. Tiek slapyvardžius, funkcijas, tiek eksportus turėtumėte pridėti į `~/.bashrc`. Šis failas nebus perrašytas atnaujinant. Jei norite pakeisti bet kuriuos Omarchy numatytuosius nustatymus, taip pat galite juos saugiai pridėti čia.

### Aplinkos kintamųjų nustatymas darbalaukiui

Darbalaukio sesijos eksportai priklauso `~/.config/uwsm/env.d/`. Šie failai paleidžiami prieš paleidžiant darbalaukį, todėl apvalkalo klaida gali grąžinti jus į prisijungimo ekraną. Redaguodami juos laikykite atidarytą veikiantį terminalą. Norėdami išjungti perrašymą, perkelkite jį iš `env.d`. Žr. [prisijungimo atkūrimą](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jei pakeitimas neleidžia prisijungti.

### Vidinių Omarchy failų keitimas

Žiūrėkite, tai jūsų kompiuteris. Galite su juo daryti ką tik norite, bet patarčiau tiesiogiai nekeisti failų `/usr/share/omarchy`. Jie priklauso Omarchy pacman paketui, todėl jūsų pakeitimai tiesiog bus perrašyti kito atnaujinimo metu. Geriau tiesiog perrašykite bet kurias numatytąsias reikšmes, kurios jums nepatinka, `~/.config/*` aplanke.

Taip galite pakeisti beveik viską, pvz., numatytuosius klavišų susiejimus. Tiesiog redaguokite `~/.config/hypr/bindings.lua`, kad, tarkime, pakeistumėte [Obsidian](https://obsidian.md/) į [Joplin](https://joplinapp.org/) (įdiekite su `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` pašalina esamą susiejimą prieš pridėdamas jo pakaitalą. Jis priima tuos pačius argumentus kaip `o.bind`, įskaitant paleidimo pagalbines funkcijas ir susiejimo parinktis. Naudokite `o.bind`, norėdami pridėti susiejimą, arba `hl.unbind`, norėdami pašalinti susiejimą jo nepakeisdami.

Jei primygtinai norite kibti į vidinius Omarchy failus, perjunkite į dev kanalą per _Update > Channel > Dev_. Tai susieja Omarchy su šaltinio kodo git kopija `~/omarchy`, kurią galite laisvai keisti kiek širdis geidžia. Niekas čia jums nenurodinės, ką daryti!

### Bet kokių pakeitimų atstatymas

Jei galiausiai sujauksite konfigūracijas, visada galite jas grąžinti į numatytąsias per _Update > Config_ Omarchy meniu. Arba paleisdami `omarchy reinstall configs`, kad viską atstatytumėte.
