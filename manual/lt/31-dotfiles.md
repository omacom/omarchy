# Dotfiles

Omarchy iš esmės konfigūruojama per vadinamuosius dotfiles, kurie yra `~/.config`. Jie laikomi jūsų failais, skirtais jūsų pakeitimams. Failai, kurie yra `/usr/share/omarchy`, priklauso pačiai Omarchy, ir jų neturėtumėte liesti. Jei reikia ką nors keisti `/usr/share/omarchy`, vietoj to turėtumėte perrašyti reikšmę `~/.config`.

Pagrindines konfigūracijas galima redaguoti tiesiai iš Omarchy meniu (`Super + Space`), pavyzdžiui, _Setup > Keyboard > Keybindings_, _Setup > Input_ ir _Setup > Config > [file]_. Kai redaguojate šiuo būdu, visi procesai, kuriuos po konfigūracijos pakeitimų reikia paleisti iš naujo, bus automatiškai paleisti iš naujo, kai uždarysite redaktorių (pagal numatytuosius nustatymus Neovim — `:wq`, atsimenate! — bet tai galite pakeisti per _Setup > Defaults > Editor_).

Štai pagrindinių failų, esančių `~/.config`, sąrašas ir tai, ką jie valdo:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Pagrindinė Hyprland konfigūracija. Įkelia Omarchy numatytąsias reikšmes ir toliau nurodytus jūsų perrašymo failus. [Sužinokite daugiau apie Hyprland konfigūracijas](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Jūsų klavišų susiejimai ir numatytųjų reikšmių perrašymai. |
| `~/.config/hypr/monitors.lua` | Monitoriaus nustatymai, kurių neapima monitoriaus skydelis, pavyzdžiui, pasukimas, papildomi režimai arba monitoriaus išjungimas. |
| `~/.config/hypr/input.lua` | Valdo jūsų klaviatūros išdėstymą, pelės ir jutiklinės planšetės nustatymus. |
| `~/.config/hypr/looknfeel.lua` | Valdo tarpus, rėmelius, animacijas ir likusią išvaizdos dalį. |
| `~/.config/hypr/autostart.lua` | Valdo papildomus procesus, paleidžiamus kartu su sesija. |
| `~/.config/omarchy/shell.json` | Valdo Omarchy apvalkalą: juostos padėtį, išdėstymą ir valdiklius, taip pat ekrano užsklandos, užrakto ir tuščiosios eigos laiką. |
| `~/.config/foot/foot.ini` | Valdo jūsų terminalą (pagal numatytuosius nustatymus — foot). |
| `~/.XCompose` | Apibrėžia jūsų greitosios prieigos emoji ir vardo / el. pašto automatinį užbaigimą. Atlikę pakeitimus būtinai paleiskite `omarchy-restart-xcompose`. |

Jei galiausiai atliksite daug pakeitimų, kad pritaikytumėte savo sąranką, pravartu pasidaryti visų šių dotfiles atsarginę kopiją. [Stow yra puikus būdas tai padaryti](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Savo programų paleidimas kartu su sesija

Jei norite, kad kas nors būtų paleidžiama kaskart prisijungus — sinchronizavimo demonas, pokalbių programa, jūsų pačių scenarijus — įrašykite tai į `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Taip komanda paleidžiama kaip sesijos dalis, todėl atsijungus ji bus tinkamai sustabdyta.

### Scenarijų paleidimas įvykus sistemos įvykiams

Omarchy tam tikrais momentais paleidžia hook'us, prie kurių galite prikabinti savo scenarijus. Jie yra `~/.config/omarchy/hooks/<event>.d/`, po vieną katalogą kiekvienam įvykiui, ir kiekvienas ten esantis failas, kurio pavadinimas nesibaigia `.sample`, įvykio metu paleidžiamas su bash:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Iškart po to, kai paleidžiama darbalaukio aplinka |
| `post-update` | Beveik `omarchy update` pabaigoje, po paketų, migracijų ir paslaugų paleidimo iš naujo, prieš atnaujinant mise įrankius |
| `pre-refresh-pacman` | Po to, kai `omarchy refresh pacman` iš naujo sinchronizuoja paketų konfigūraciją, prieš atnaujinant paketus; kanalo perjungimas jį paleidžia per tą patį atnaujinimo veiksmą |
| `theme-set` | Po temos pakeitimo (temos pavadinimas yra `$1`) |
| `font-set` | Po šrifto pakeitimo (šrifto pavadinimas yra `$1`) |
| `battery-low` | Kai akumuliatoriaus įkrova tampa maža (procentai yra `$1`) |

`pre-refresh-pacman` hook'as yra ta vieta, kuriai priklauso pasirinktinės saugyklos arba `IgnorePkg` eilutės, nes jis paleidžiamas prieš paketų transakciją. Abu paleidžiami jūsų naudotojo teisėmis. `post-update` paleidžiamas, kol `omarchy update` sudo autorizacija vis dar galioja, todėl hook'as, naudojantis `sudo`, jūsų slaptažodžio dar kartą neprašys; `pre-refresh-pacman` paleidžiamas iškart po to, kai `omarchy refresh pacman` pati panaudoja sudo.

Kiekviename iš šių katalogų jau yra `.sample` failas, rodantis hook'o formą — pašalinkite `.sample` iš pavadinimo, kad jis pradėtų veikti. Norėdami įdiegti scenarijų, kurį parašėte kitur, naudokite `omarchy hook install post-boot ~/my-hook`, kuris jį nukopijuos ir padarys vykdomąjį.

### Savo meniu įrašų pridėjimas

Omarchy meniu (`Super + Space`) galima praplėsti savo eilutėmis redaguojant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Įrašai yra raktuojami pagal taškinį id, ir būtent id nulemia jų vietą medyje, todėl `personal` rodomas pagrindiniame meniu, o `personal.notes` — jo viduje:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Pakartotinai naudodami esamą id, perrašysite tą eilutę, o ne pridėsite naują. Faile visi galimi laukai aprašyti komentaruose.

### Savo apvalkalo eksportų, funkcijų ir aliasų pridėjimas

Omarchy pateikiama su daugybe ergonomiškų aliasų ir naudingų funkcijų, bet labai dažnai norisi pridėti savų. Aliasus, funkcijas ir eksportus turėtumėte pridėti į `~/.bashrc`. Šis failas atnaujinant nebus perrašytas. Jei norite pakeisti kurias nors Omarchy numatytąsias reikšmes, jas taip pat galite saugiai pridėti čia.

### Darbalaukio aplinkos kintamųjų nustatymas

Darbalaukio sesijos eksportai priklauso `~/.config/uwsm/env.d/`. Šie failai paleidžiami prieš paleidžiant darbalaukį, todėl apvalkalo klaida gali grąžinti jus į prisijungimo ekraną. Redaguodami juos laikykite atidarytą veikiantį terminalą. Norėdami išjungti perrašymą, perkelkite jį iš `env.d`. Jei pakeitimas neleidžia prisijungti, žr. [prisijungimo atkūrimą](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Vidinių Omarchy failų keitimas

Klausykite, tai jūsų kompiuteris. Galite su juo daryti ką tik norite, bet patarčiau tiesiogiai nekeisti failų, esančių `/usr/share/omarchy`. Jie priklauso Omarchy pacman paketui, todėl jūsų pakeitimai per kitą atnaujinimą bus tiesiog perrašyti. Verčiau tiesiog perrašykite visas numatytąsias reikšmes, kurios jums nepatinka, `~/.config/*` aplanke.

Taip galite pakeisti beveik viską, pavyzdžiui, numatytuosius klavišų susiejimus. Tiesiog redaguokite `~/.config/hypr/bindings.lua`, kad, tarkime, [Obsidian](https://obsidian.md/) pakeistumėte į [Joplin](https://joplinapp.org/) (įdiekite su `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` pašalina esamą susiejimą prieš pridėdamas jo pakaitalą. Jis priima tuos pačius argumentus kaip `o.bind`, įskaitant paleidimo pagalbines priemones ir susiejimo parinktis. Norėdami pridėti susiejimą, naudokite `o.bind`, o norėdami jį pašalinti nepakeisdami — `hl.unbind`.

Jei primygtinai norite knaisiotis vidiniuose Omarchy failuose, perjunkite į kūrėjų kanalą per _Update > Channel > Dev_. Taip Omarchy bus susieta su git išeities kodo kopija `~/omarchy`, kurią galite keisti kiek tik širdis geidžia. Niekas čia jums nenurodinės, ką daryti!

### Visų pakeitimų atstatymas

Jei galiausiai konfigūracijose pridarysite netvarkos, visada galite jas atstatyti į numatytąsias reikšmes per Omarchy meniu _Update > Config_. Arba paleisdami `omarchy reinstall configs`, kad atstatytumėte viską.
