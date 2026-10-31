# Dotfiles

Omarchy pirmiausia konfigūruojama per vadinamuosius dotfiles failus, esančius `~/.config`. Jie laikomi jūsų failais jūsų pakeitimams. Failai, esantys `/usr/share/omarchy`, priklauso pačiai Omarchy, ir neturėtumėte su jais žaisti. Jei reikia ką nors keisti `/usr/share/omarchy`, turėtumėte vietoj to perrašyti reikšmę `~/.config`.

Pagrindines konfigūracijas galima redaguoti tiesiai iš Omarchy meniu (`Super + Space`), pavyzdžiui, _Sąranka > Klavišų susiejimai_, _Sąranka > Įvestis_ ir _Sąranka > Konfigūracija > [file]_. Kai tai darote šiuo būdu, bet kuris procesas, kurį reikia paleisti iš naujo po konfigūracijos redagavimo, bus automatiškai paleistas iš naujo, kai uždarysite redaktorių (pagal numatytuosius nustatymus Neovim — `:wq`, prisiminkite! — bet tai galite pakeisti per _Sąranka > Numatytieji nustatymai > Redaktorius_).

Štai pagrindinių failų `~/.config` sąrašas ir tai, ką jie valdo:

| Failas                  | Paskirtis              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Pagrindinė Hyprland konfigūracija. Įkelia Omarchy numatytuosius nustatymus ir jūsų toliau nurodytus perrašymo failus. [Sužinokite daugiau apie Hyprland konfigūracijas](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Jūsų paties klavišų susiejimai ir numatytųjų perrašymai. |
| `~/.config/hypr/monitors.lua` | Monitoriaus nustatymai, kurių neapima monitoriaus skydelis, pavyzdžiui, pasukimas, papildomi režimai arba monitoriaus palikimas išjungto. |
| `~/.config/hypr/input.lua` | Valdo jūsų klaviatūros išdėstymą, pelės ir jutiklinio kilimėlio nustatymus. |
| `~/.config/hypr/looknfeel.lua` | Valdo tarpus, rėmelius, animacijas ir likusią išvaizdos dalį. |
| `~/.config/hypr/autostart.lua` | Valdo papildomus procesus, paleidžiamus su sesija. |
| `~/.config/omarchy/shell.json` | Valdo Omarchy apvalkalą: juostos padėtį, išdėstymą ir valdiklius, taip pat ekrano užsklandos, užrakto ir tuščiosios eigos laiką. |
| `~/.config/foot/foot.ini` | Valdo jūsų terminalą (foot yra numatytasis). |
| `~/.XCompose` | Apibrėžia jūsų sparčiąją prieigą prie jaustukų ir vardo / el. pašto automatinį užbaigimą. Atlikę pakeitimus nepamirškite paleisti `omarchy-restart-xcompose`. |

Jei galiausiai atliksite daug pakeitimų, kad pritaikytumėte savo sąranką, gera mintis yra pasidaryti visų šių dotfiles failų atsarginę kopiją. [Stow yra puikus būdas tai padaryti](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savo programų paleidimas su sesija

Jei norite, kad kas nors būtų paleidžiama kiekvieną kartą prisijungus — sinchronizavimo demonas, pokalbių programa, jūsų pačių scenarijus — įdėkite tai į `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Taip komanda paleidžiama kaip sesijos dalis, todėl atsijungus ji tinkamai išvaloma.

### Scenarijų paleidimas sistemos įvykių metu

Omarchy tam tikrais momentais paleidžia kabliukus, ir prie jų galite prikabinti savo scenarijus. Jie yra `~/.config/omarchy/hooks/<event>.d/`, po vieną katalogą kiekvienam įvykiui, ir kiekvienas ten esantis vykdomasis failas paleidžiamas, kai įvyksta įvykis:

| Įvykis | Kada paleidžiama |
| ----- | ------------ |
| `post-boot` | Iš karto po to, kai darbalaukis paleistas |
| `post-update` | Beveik `omarchy update` pabaigoje, po paketų, migracijų ir paslaugų paleidimo iš naujo, prieš atnaujinant mise įrankius |
| `pre-refresh-pacman` | Po to, kai `omarchy refresh pacman` iš naujo sinchronizuoja paketų konfigūraciją, prieš atnaujinant paketus; kanalo perjungimas jį paleidžia to paties atnaujinimo veiksmo metu |
| `theme-set` | Po temos pakeitimo (temos pavadinimas `$1`) |
| `font-set` | Po šrifto pakeitimo (šrifto pavadinimas `$1`) |
| `battery-low` | Kai akumuliatoriaus įkrova tampa maža (procentai `$1`) |

`pre-refresh-pacman` kabliukas yra vieta, kur priklauso pasirinktinės saugyklos arba `IgnorePkg` eilutės, nes jis paleidžiamas prieš paketų transakciją. Abu su atnaujinimu susiję kabliukai paleidžiami kaip jūsų naudotojas po to, kai Omarchy išvalo talpykloje saugomą sudo autorizaciją, todėl kabliukui, naudojančiam `sudo`, reikia savo autorizacijos ir jis gali paprašyti jūsų slaptažodžio.

Kiekviename iš šių katalogų jau yra `.sample` failas, rodantis kabliuko formą — pašalinkite `.sample` iš pavadinimo, kad jis pradėtų veikti. Norėdami įdiegti scenarijų, kurį parašėte kitur, naudokite `omarchy hook install post-boot ~/my-hook`, kuris jį nukopijuoja ir padaro vykdomuoju.

### Savo meniu įrašų pridėjimas

Omarchy meniu (`Super + Space`) galima išplėsti savo eilutėmis redaguojant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Įrašai raktuojami taškiniu id, ir id lemia jų vietą medyje, todėl `personal` rodomas šakniniame meniu, o `personal.notes` rodomas jo viduje:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Pakartotinai naudodami esamą id, perrašysite tą eilutę, o ne pridėsite naują. Faile visi galimi laukai aprašyti kaip komentarai.

### Savo apvalkalo eksportų, funkcijų ir slapyvardžių pridėjimas

Omarchy pateikiama su daugybe ergonomiškų slapyvardžių ir naudingų funkcijų, bet labai įprasta norėti pridėti savų. Tiek slapyvardžius, funkcijas, tiek eksportus turėtumėte pridėti į `~/.bashrc`. Šis failas nebus perrašytas atnaujinimų metu. Jei norite pakeisti bet kuriuos Omarchy numatytuosius nustatymus, juos taip pat galite saugiai pridėti čia.

### Vidinių Omarchy failų keitimas

Žiūrėkite, tai jūsų kompiuteris. Galite su juo daryti ką norite, bet patarčiau tiesiogiai nekeisti failų `/usr/share/omarchy`. Jie priklauso Omarchy pacman paketui, todėl jūsų pakeitimai tiesiog bus perrašyti kito atnaujinimo metu. Geriau tiesiog perrašykite bet kurias numatytąsias reikšmes, kurios jums nepatinka, `~/.config/*` aplanke.

Taip galite pakeisti beveik viską, pavyzdžiui, numatytuosius klavišų susiejimus. Tiesiog redaguokite `~/.config/hypr/bindings.lua`, kad, tarkime, [Obsidian](https://obsidian.md/) pakeistumėte į [Joplin](https://joplinapp.org/) (įdiekite su `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` pašalina esamą susiejimą prieš pridėdamas jo pakaitalą. Jis priima tuos pačius argumentus kaip `o.bind`, įskaitant paleidimo pagalbines priemones ir susiejimo parinktis. Naudokite `o.bind`, kad pridėtumėte susiejimą, arba `hl.unbind`, kad pašalintumėte jį jo nepakeisdami.

Jei primygtinai norite laužtis į vidinius Omarchy failus, perjunkite į dev kanalą per _Atnaujinimas > Kanalas > Dev_. Taip Omarchy susiejama su git esančia šaltinio kodo kopija `~/omarchy`, kurią galite laisvai keisti kiek širdis geidžia. Niekas čia jums nenurodinės, ką daryti!

### Bet kokių pakeitimų atstatymas

Jei galiausiai sugadinsite konfigūracijas, visada galite jas grąžinti į numatytąsias per _Atnaujinimas > Konfigūracija_ Omarchy meniu. Arba paleisdami `omarchy reinstall configs`, kad viską atstatytumėte.
