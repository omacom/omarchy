# Dotfiles

Omarchy se primarno konfigurira putem takozvanih dotfiles datoteka koje se nalaze u `~/.config`. One se smatraju tvojim datotekama za tvoje promjene. Datoteke koje se nalaze u `/usr/share/omarchy` pripadaju samom Omarchyju i ne bi trebao dirati u njih. Ako trebaš promijeniti bilo što u `/usr/share/omarchy`, trebao bi umjesto toga prebrisati vrijednost u `~/.config`.

Ključne konfiguracije mogu se uređivati izravno iz izbornika Omarchy (`Super + Space`), poput _Postavke > Monitori_, _Postavke > Prečaci_, _Postavke > Unos_ i _Postavke > Config > [file]_. Kad to radiš na ovaj način, svaki proces koji treba ponovno pokretanje nakon uređivanja konfiguracije automatski će se ponovno pokrenuti nakon što izađeš iz uređivača (Neovim prema zadanim postavkama — `:wq`, zapamti! — ali to možeš promijeniti putem _Postavke > Defaults > Editor_).

Evo popisa ključnih datoteka u `~/.config` i što kontroliraju:

| Datoteka                  | Svrha              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna Hyprland konfiguracija. Učitava Omarchy zadane postavke plus tvoje override datoteke u nastavku. [Saznaj više o Hyprland konfiguracijama](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tvoji vlastiti prečaci i overridei zadanih postavki. |
| `~/.config/hypr/monitors.lua` | Kontrolira tvoje monitore, razlučivost i položaj. |
| `~/.config/hypr/input.lua` | Kontrolira raspored tipkovnice, miš i postavke dodirne plohe. |
| `~/.config/hypr/looknfeel.lua` | Kontrolira razmake, obrise, animacije i ostatak izgleda. |
| `~/.config/hypr/autostart.lua` | Kontrolira dodatne procese pokrenute sa sesijom. |
| `~/.config/omarchy/shell.json` | Kontrolira Omarchy ljusku: položaj trake, raspored i widgete, plus tajminge čuvara zaslona, zaključavanja i mirovanja. |
| `~/.config/foot/foot.ini` | Kontrolira tvoj terminal (foot je zadani). |
| `~/.XCompose` | Definira tvoje emojije za brzi pristup i autocomplete za ime/e-poštu. Obavezno pokreni `omarchy-restart-xcompose` nakon izmjena. |

Ako na kraju napraviš puno promjena kako bi ugodio vlastitu postavu, dobra je ideja napraviti sigurnosnu kopiju svih ovih dotfiles datoteka. [Stow je sjajan način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pokretanje vlastitih aplikacija sa sesijom

Ako želiš da se nešto pokreće svaki put kad se prijaviš — daemon za sinkronizaciju, aplikacija za chat, tvoja vlastita skripta — stavi to u `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To pokreće naredbu kao dio sesije, pa se ispravno čisti kad se ponovno odjaviš.

### Pokretanje skripta na događaje sustava

Omarchy pokreće hookove u nekoliko trenutaka i na njih možeš objesiti vlastite skripte. Nalaze se u `~/.config/omarchy/hooks/<event>.d/`, jedan direktorij po događaju, a svaka izvršna datoteka tamo pokreće se kad se događaj dogodi:

| Događaj | Kad se pokreće |
| ----- | ------------ |
| `post-boot` | Odmah nakon pokretanja radne površine |
| `post-update` | Pred kraj `omarchy update`, nakon paketa, migracija i ponovnog pokretanja usluga, prije ažuriranja mise alata |
| `pre-refresh-pacman` | Nakon što `omarchy refresh pacman` ponovno sinkronizira konfiguraciju paketa, prije ažuriranja paketa; prebacivanje kanala pokreće ga tijekom istog koraka osvježavanja |
| `theme-set` | Nakon promjene teme (naziv teme u `$1`) |
| `font-set` | Nakon promjene fonta (naziv fonta u `$1`) |
| `battery-low` | Kad je baterija niska (postotak u `$1`) |

Hook `pre-refresh-pacman` mjesto je gdje pripadaju prilagođeni repozitoriji ili retci `IgnorePkg`, budući da se pokreće prije transakcije paketa. Oba hooka povezana s ažuriranjem pokreću se kao tvoj korisnik nakon što Omarchy očisti svoju predmemoriranu sudo autorizaciju, pa hook koji koristi `sudo` treba vlastitu autorizaciju i može tražiti tvoju zaporku.

Svaki od tih direktorija već sadrži datoteku `.sample` koja pokazuje oblik hooka — ukloni `.sample` iz naziva da ga staviš u pogon. Za instalaciju skripte koju si napisao drugdje koristi `omarchy hook install post-boot ~/my-hook`, što je kopira i čini izvršnom.

### Dodavanje vlastitih unosa izbornika

Izbornik Omarchy (`Super + Space`) može se proširiti vlastitim retcima uređivanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Unosi su ključani točkastim id-em, a id je ono što ih smješta u stablo, pa se `personal` pojavljuje na korijenskom izborniku, a `personal.notes` unutar njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponovno upotrijebi postojeći id i prebrisuješ taj redak umjesto da dodaš novi. Datoteka dolazi sa svim dostupnim poljima dokumentiranim kao komentari.

### Dodavanje vlastitih exportova, funkcija i aliasa ljuske

Omarchy dolazi s hrpom ergonomskih aliasa i korisnih funkcija, ali vrlo je uobičajeno htjeti dodati vlastite. I aliase, funkcije i exporte trebao bi dodati u `~/.bashrc`. Ova datoteka neće biti prebrisana pri ažuriranjima. Ako želiš promijeniti bilo koju od Omarchy zadanih postavki, i njih ovdje možeš sigurno dodati.

### Mijenjanje internih Omarchy datoteka

Gle, ovo je tvoje računalo. S njim možeš raditi što god želiš, ali savjetovao bih protiv izravnog mijenjanja datoteka u `/usr/share/omarchy`. One pripadaju Omarchy pacman paketu, pa će tvoje promjene jednostavno biti prebrisane pri sljedećem ažuriranju. Bolje ti je samo prebrisati sve zadane vrijednosti koje ti se ne sviđaju u mapi `~/.config/*`.

Na taj način možeš promijeniti gotovo sve, poput zadanih prečaca. Samo uredi `~/.config/hypr/bindings.lua` da, recimo, zamijeniš [Obsidian](https://obsidian.md/) s [Joplin](https://joplinapp.org/) (instaliraj s `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` uklanja postojeće vezanje prije dodavanja zamjene. Uzima iste argumente kao `o.bind`, uključujući pomoćnike za pokretanje i opcije vezanja. Koristi `o.bind` za dodavanje vezanja ili `hl.unbind` za uklanjanje jednog bez zamjene.

Ako inzistiraš na hakiranju internih Omarchy datoteka, prebaci se na kanal dev putem _Ažuriraj > Channel > Dev_. To povezuje Omarchy s git checkoutom izvornog koda u `~/omarchy`, koji slobodno možeš mijenjati do mile volje. Ovdje nema nikoga da ti govori što da radiš!

### Resetiranje bilo kakvih promjena

Ako na kraju napraviš zbrku od konfiguracija, uvijek ih možeš vratiti na zadane postavke putem _Ažuriraj > Config_ u izborniku Omarchy. Ili pokretanjem `omarchy reinstall configs` za resetiranje svega.
