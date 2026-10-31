# Dotfiles

Omarchy se prvenstveno konfigurira putem takozvanih dotfiles datoteka koje se nalaze u `~/.config`. One se smatraju vašim datotekama za vaše izmjene. Datoteke koje se nalaze u `/usr/share/omarchy` pripadaju samom Omarchyju i ne biste trebali prčkati po njima. Ako trebate promijeniti bilo što u `/usr/share/omarchy`, umjesto toga trebali biste pregaziti vrijednost u `~/.config`.

Ključne konfiguracije mogu se uređivati izravno iz izbornika Omarchy (`Super + Space`), poput _Setup > Keybindings_, _Setup > Input_ i _Setup > Config > [file]_. Kada to radite na ovaj način, svaki proces koji se treba ponovno pokrenuti nakon izmjena konfiguracije automatski će se ponovno pokrenuti nakon što izađete iz uređivača (prema zadanim postavkama Neovim — `:wq`, zapamtite! — ali to možete promijeniti putem _Setup > Defaults > Editor_).

Evo popisa ključnih datoteka u `~/.config` i čime upravljaju:

| Datoteka                  | Namjena              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna Hyprland konfiguracija. Učitava zadane postavke Omarchyja plus vaše datoteke za pregažavanje u nastavku. [Saznajte više o Hyprland konfiguracijama](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaši vlastiti tipkovnički prečaci i pregažavanja zadanih vrijednosti. |
| `~/.config/hypr/monitors.lua` | Postavke monitora koje ploča za monitore ne pokriva, poput rotacije, dodatnih načina rada ili držanja monitora isključenim. |
| `~/.config/hypr/input.lua` | Upravlja rasporedom tipkovnice, postavkama miša i dodirne plohe. |
| `~/.config/hypr/looknfeel.lua` | Upravlja razmacima, obrubima, animacijama i ostatkom izgleda. |
| `~/.config/hypr/autostart.lua` | Upravlja dodatnim procesima koji se pokreću sa sesijom. |
| `~/.config/omarchy/shell.json` | Upravlja ljuskom Omarchy: položajem trake, rasporedom i widgetima, plus čuvarom zaslona, zaključavanjem i vremenima mirovanja. |
| `~/.config/foot/foot.ini` | Upravlja vašim terminalom (foot je zadani). |
| `~/.XCompose` | Definira vaše emojije za brzi pristup i automatsko dovršavanje imena/e-pošte. Obavezno pokrenite `omarchy-restart-xcompose` nakon izmjena. |

Ako na kraju napravite mnogo izmjena kako biste prilagodili vlastitu postavku, dobra je ideja napraviti sigurnosnu kopiju svih tih dotfiles datoteka. [Stow je odličan način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pokretanje vlastitih aplikacija sa sesijom

Ako želite da se nešto pokreće svaki put kada se prijavite — daemon za sinkronizaciju, aplikacija za razgovor, vlastita skripta — stavite to u `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Time se naredba pokreće kao dio sesije, pa se pravilno čisti kada se ponovno odjavite.

### Pokretanje skripti pri događajima sustava

Omarchy pokreće hookove u nekoliko trenutaka, a na njih možete objesiti vlastite skripte. Nalaze se u `~/.config/omarchy/hooks/<event>.d/`, po jedan direktorij za svaki događaj, a svaka izvršna datoteka u njemu pokreće se kada se događaj dogodi:

| Događaj | Kada se pokreće |
| ----- | ------------ |
| `post-boot` | Odmah nakon što se radna površina pokrene |
| `post-update` | Pred kraj `omarchy update`, nakon paketa, migracija i ponovnih pokretanja usluga, prije ažuriranja mise alata |
| `pre-refresh-pacman` | Nakon što `omarchy refresh pacman` ponovno sinkronizira konfiguraciju paketa, prije nego što ažurira pakete; promjena kanala pokreće ga tijekom istog koraka osvježavanja |
| `theme-set` | Nakon promjene teme (naziv teme u `$1`) |
| `font-set` | Nakon promjene fonta (naziv fonta u `$1`) |
| `battery-low` | Kada je baterija niska (postotak u `$1`) |

Hook `pre-refresh-pacman` mjesto je gdje pripadaju prilagođeni repozitoriji ili retci `IgnorePkg`, budući da se pokreće prije transakcije paketa. Oba hooka povezana s ažuriranjem pokreću se kao vaš korisnik nakon što Omarchy očisti svoju predmemoriranu sudo autorizaciju, pa hook koji koristi `sudo` treba vlastitu autorizaciju i može zatražiti vašu lozinku.

Svaki od tih direktorija već sadrži datoteku `.sample` koja pokazuje oblik hooka — uklonite `.sample` iz naziva da biste ga aktivirali. Za instaliranje skripte koju ste napisali drugdje upotrijebite `omarchy hook install post-boot ~/my-hook`, što je kopira unutra i čini izvršnom.

### Dodavanje vlastitih stavki izbornika

Izbornik Omarchy (`Super + Space`) može se proširiti vlastitim retcima uređivanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Stavke su ključirane točkastim id-jem, a id je ono što ih smješta u stablo, pa se `personal` pojavljuje u korijenskom izborniku, a `personal.notes` pojavljuje unutar njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponovno upotrijebite postojeći id i pregazit ćete taj redak umjesto da dodate novi. Datoteka dolazi sa svim dostupnim poljima dokumentiranima kao komentari.

### Dodavanje vlastitih izvoza ljuske, funkcija i aliasa

Omarchy dolazi s hrpom ergonomskih aliasa i korisnih funkcija, ali vrlo je uobičajeno htjeti dodati vlastite. I aliase, funkcije i izvoze trebali biste dodati u `~/.bashrc`. Ova datoteka neće biti pregažena pri ažuriranjima. Ako želite promijeniti bilo koju od zadanih postavki Omarchyja, možete ih sigurno dodati i ovdje.

### Mijenjanje internih datoteka Omarchyja

Gle, ovo je vaše računalo. S njim možete raditi što god želite, ali savjetovao bih vam da izravno ne mijenjate datoteke u `/usr/share/omarchy`. One pripadaju pacman paketu Omarchy, pa će vaše izmjene jednostavno biti pregažene pri sljedećem ažuriranju. Umjesto toga, bolje vam je samo pregaziti sve zadane vrijednosti koje vam se ne sviđaju u mapi `~/.config/*`.

Na taj način možete promijeniti gotovo sve, poput zadanih tipkovničkih prečaca. Samo uredite `~/.config/hypr/bindings.lua` da, recimo, zamijenite [Obsidian](https://obsidian.md/) s [Joplin](https://joplinapp.org/) (instalirajte s `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` uklanja postojeći prečac prije dodavanja njegove zamjene. Prima iste argumente kao `o.bind`, uključujući pomoćnike za pokretanje i opcije vezanja. Upotrijebite `o.bind` za dodavanje prečaca ili `hl.unbind` za uklanjanje jednog bez zamjene.

Ako inzistirate na prčkanju po internim datotekama Omarchyja, prebacite se na dev kanal putem _Update > Channel > Dev_. To povezuje Omarchy s git checkoutom izvornog koda u `~/omarchy`, koji slobodno možete mijenjati do mile volje. Nitko ovdje nije da vam govori što da radite!

### Vraćanje svih izmjena

Ako na kraju napravite nered u konfiguracijama, uvijek ih možete vratiti na zadane vrijednosti putem _Update > Config_ u izborniku Omarchy. Ili pokretanjem `omarchy reinstall configs` za resetiranje svega.
