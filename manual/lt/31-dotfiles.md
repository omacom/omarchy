# Dotfiles

Omarchy pirmiausia konfigūruojama per vadinamuosius dotfiles, esančius `~/.config`. Tai laikoma jūsų failais, skirtais jūsų pakeitimams. Failai, esantys `/usr/share/omarchy`, priklauso pačiai Omarchy, ir jums nereikėtų su jais žaisti. Jei reikia ką nors keisti `/usr/share/omarchy`, vietoj to turėtumėte perrašyti reikšmę `~/.config`.

Pagrindines konfigūracijas galima redaguoti tiesiai iš Omarchy meniu (`Super + Space`), pavyzdžiui, _Setup > Keyboard > Keybindings_, _Setup > Input_ ir _Setup > Config > [file]_. Kai tai darote šiuo būdu, bet kuris procesas, kurį reikia paleisti iš naujo po konfigūracijos redagavimo, bus automatiškai paleistas iš naujo, kai uždarysite redaktorių (pagal numatytuosius nustatymus Neovim — `:wq`, nepamirškite! — bet tai galite pakeisti per _Setup > Defaults > Editor_).

Štai pagrindinių failų `~/.config` sąrašas ir tai, ką jie valdo:

| Failas | Paskirtis |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Pagrindinė Hyprland konfigūracija. Įkelia numatytuosius Omarchy nustatymus ir jūsų toliau nurodytus perrašymo failus. [Sužinokite daugiau apie Hyprland konfigūracijas](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Jūsų paties klavišų susiejimai ir numatytųjų nustatymų perrašymai. |
| `~/.config/hypr/monitors.lua` | Monitoriaus nustatymai, kurių neapima monitoriaus skydelis, pavyzdžiui, pasukimas, papildomi režimai arba monitoriaus palikimas išjungto. |
| `~/.config/hypr/input.lua` | Valdo jūsų klaviatūros išdėstymą, pelės ir jutiklinio kilimėlio nustatymus. |
| `~/.config/hypr/looknfeel.lua` | Valdo tarpus, kraštines, animacijas ir likusią išvaizdą. |
| `~/.config/hypr/autostart.lua` | Valdo papildomus procesus, paleidžiamus kartu su sesija. |
| `~/.config/omarchy/shell.json` | Valdo Omarchy apvalkalą: juostos padėtį, išdėstymą ir valdiklius, taip pat ekrano užsklandos, užrakto ir neveiklumo trukmes. |
| `~/.config/foot/foot.ini` | Valdo jūsų terminalą (foot yra numatytasis). |
| `~/.XCompose` | Apibrėžia jūsų sparčiosios prieigos jaustukus ir vardo / el. pašto automatinį užbaigimą. Atlikę pakeitimų būtinai paleiskite `omarchy-restart-xcompose`. |

Jei galiausiai atliksite daug pakeitimų, kad pritaikytumėte savo sąranką, verta pasidaryti visų šių dotfiles atsarginę kopiją. [Stow yra puikus būdas tai padaryti](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savo programų paleidimas kartu su sesija

Jei norite, kad kas nors būtų vykdoma kiekvieną kartą prisijungus — sinchronizavimo demonas, pokalbių programa, jūsų paties scenarijus — įdėkite tai į `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tai paleidžia komandą kaip sesijos dalį, todėl atsijungus ji bus tinkamai išvalyta.

### Scenarijų vykdymas sistemos įvykių metu

Omarchy keliomis progomis suaktyvina „hooks“, o prie jų galite prikabinti savo scenarijus. Jie yra `~/.config/omarchy/hooks/<event>.d/`, po vieną katalogą kiekvienam įvykiui, ir kiekvienas ten esantis vykdomasis failas paleidžiamas, kai įvyksta įvykis:

| Įvykis | Kada vykdoma |
| ----- | ------------ |
| `post-boot` | Iškart po to, kai paleidžiama darbalaukio aplinka |
| `post-update` | Netoli `omarchy update` pabaigos, po paketų, migracijų ir paslaugų paleidimo iš naujo, prieš atnaujinant mise įrankius |
| `pre-refresh-pacman` | Po to, kai `omarchy refresh pacman` iš naujo sinchronizuoja paketų konfigūraciją, prieš atnaujindama paketus; kanalo perjungimas ją paleidžia to paties atnaujinimo veiksmo metu |
| `theme-set` | Po temos pakeitimo (temos pavadinimas `$1`) |
| `font-set` | Po šrifto pakeitimo (šrifto pavadinimas `$1`) |
| `battery-low` | Kai akumuliatoriaus įkrova tampa maža (procentinė dalis `$1`) |

`pre-refresh-pacman` „hook“ yra vieta, kuriai priklauso pasirinktinės saugyklos arba `IgnorePkg` eilutės, nes jis vykdomas prieš paketų operaciją. Abu su atnaujinimu susiję „hooks“ vykdomi kaip jūsų naudotojas po to, kai Omarchy išvalo savo talpykloje saugomą sudo autorizaciją, todėl „hook“, naudojančiam `sudo`, reikia savo autorizacijos ir jis gali paprašyti jūsų slaptažodžio.

Kiekviename iš tų katalogų jau yra `.sample` failas, rodantis „hook“ formą — pašalinkite `.sample` iš pavadinimo, kad jis pradėtų veikti. Norėdami įdiegti scenarijų, kurį parašėte kitur, naudokite `omarchy hook install post-boot ~/my-hook` — tai jį nukopijuos ir padarys vykdomąjį.

### Savo meniu įrašų pridėjimas

Omarchy meniu (`Super + Space`) galima išplėsti savo eilutėmis redaguojant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Įrašai žymimi taškiniu id, ir būtent id nulemia jų vietą medyje, todėl `personal` rodomas šakniniame meniu, o `personal.notes` rodomas jo viduje:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Pakartotinai panaudoję esamą id, perrašysite tą eilutę, o ne pridėsite naują. Faile visi galimi laukai pateikiami dokumentuoti kaip komentarai.

### Savo apvalkalo eksportų, funkcijų ir slapyvardžių pridėjimas

Omarchy pateikiama su daugybe ergonomiškų slapyvardžių ir naudingų funkcijų, bet labai įprasta norėti pridėti savų. Slapyvardžius, funkcijas ir eksportus turėtumėte pridėti į `~/.bashrc`. Šis failas atnaujinant nebus perrašytas. Jei norite pakeisti bet kuriuos numatytuosius Omarchy nustatymus, juos taip pat galite saugiai pridėti čia.

### Aplinkos kintamųjų nustatymas darbalaukiui

Darbalaukio sesijos eksportai priklauso `~/.config/uwsm/env.d/`. Šie failai vykdomi prieš paleidžiant jūsų darbalaukį, todėl apvalkalo klaida gali grąžinti jus į prisijungimo ekraną. Redaguodami juos laikykite atidarytą veikiantį terminalą. Norėdami išjungti perrašymą, perkelkite jį iš `env.d`. Žr. [prisijungimo atkūrimą](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jei pakeitimas neleidžia prisijungti.

### Vidinių Omarchy failų keitimas

Žiūrėkite, tai jūsų kompiuteris. Galite su juo daryti ką tik norite, bet patarčiau tiesiogiai nekeisti failų `/usr/share/omarchy`. Jie priklauso Omarchy pacman paketui, todėl kito atnaujinimo metu jūsų pakeitimai bus tiesiog perrašyti. Verčiau tiesiog perrašykite visas numatytąsias reikšmes, kurios jums nepatinka, `~/.config/*` aplanke.

Tokiu būdu galite pakeisti beveik viską, pavyzdžiui, numatytuosius klavišų susiejimus. Tiesiog redaguokite `~/.config/hypr/bindings.lua`, kad, tarkime, [Obsidian](https://obsidian.md/) pakeistumėte į [Joplin](https://joplinapp.org/) (įdiekite su `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` pašalina esamą susiejimą prieš pridėdama jo pakaitalą. Ji priima tuos pačius argumentus kaip `o.bind`, įskaitant paleidimo pagalbines priemones ir susiejimo parinktis. Naudokite `o.bind`, norėdami pridėti susiejimą, arba `hl.unbind`, norėdami jį pašalinti nepakeisdami.

Jei primygtinai norite knaisiotis vidiniuose Omarchy failuose, perjunkite į dev kanalą per _Update > Channel > Dev_. Tai susies Omarchy su git išgauta šaltinio kodo kopija `~/omarchy`, kurią galite keisti kiek tik širdis geidžia. Niekas čia jums nenurodinės, ką daryti!

### Bet kokių pakeitimų atstatymas

Jei galiausiai sujauksite konfigūracijas, visada galite jas grąžinti į numatytąsias per _Update > Config_ Omarchy meniu. Arba paleisdami `omarchy reinstall configs`, kad atstatytumėte viską.
