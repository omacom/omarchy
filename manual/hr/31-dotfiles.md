# Dotfiles

Omarchy se prvenstveno konfigurira putem takozvanih dotfiles datoteka koje se nalaze u `~/.config`. One se smatraju tvojim datotekama za tvoje izmjene. Datoteke koje se nalaze u `/usr/share/omarchy` pripadaju samom Omarchyju i s njima se ne bi trebao petljati. Ako trebaš promijeniti bilo što u `/usr/share/omarchy`, umjesto toga bi trebao prepisati vrijednost u `~/.config`.

Ključne konfiguracije mogu se uređivati izravno iz Omarchy izbornika (`Super + Space`), poput _Postavke > Tipkovnica > Tipkovni prečaci_, _Postavke > Unos_ i _Postavke > Konfiguracija > [datoteka]_. Kada to radiš na ovaj način, svaki proces koji se treba ponovno pokrenuti nakon izmjena konfiguracije automatski će se ponovno pokrenuti nakon što zatvoriš uređivač (Neovim je zadan — `:wq`, upamti! — ali to možeš promijeniti putem _Postavke > Zadano > Uređivač_).

Evo popisa ključnih datoteka u `~/.config` i čime upravljaju:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna Hyprland konfiguracija. Učitava Omarchy zadane vrijednosti plus tvoje datoteke s prepisivanjima u nastavku. [Saznaj više o Hyprland konfiguracijama](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tvoji vlastiti tipkovni prečaci i prepisivanja zadanih vrijednosti. |
| `~/.config/hypr/monitors.lua` | Postavke monitora koje panel za monitore ne pokriva, poput rotacije, dodatnih načina rada ili ostavljanja monitora isključenim. |
| `~/.config/hypr/input.lua` | Upravlja rasporedom tipkovnice, mišem i postavkama dodirne plohe. |
| `~/.config/hypr/looknfeel.lua` | Upravlja razmacima, obrubima, animacijama i ostatkom izgleda. |
| `~/.config/hypr/autostart.lua` | Upravlja dodatnim procesima koji se pokreću sa sesijom. |
| `~/.config/omarchy/shell.json` | Upravlja Omarchy ljuskom: položaj trake, raspored i widgeti, plus čuvar zaslona, zaključavanje i vremena neaktivnosti. |
| `~/.config/foot/foot.ini` | Upravlja tvojim terminalom (foot je zadani). |
| `~/.XCompose` | Definira tvoje emotikone za brzi pristup i automatsko dovršavanje imena/e-pošte. Obavezno pokreni `omarchy-restart-xcompose` nakon izmjena. |

Ako na kraju napraviš puno izmjena kako bi prilagodio vlastitu postavu, dobra je ideja napraviti sigurnosnu kopiju svih tih dotfiles datoteka. [Stow je izvrstan način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pokretanje vlastitih aplikacija sa sesijom

Ako želiš da se nešto pokreće svaki put kada se prijaviš — demon za sinkronizaciju, aplikacija za razgovor, tvoja vlastita skripta — stavi to u `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To pokreće naredbu kao dio sesije, pa se pravilno čisti kada se ponovno odjaviš.

### Pokretanje skripti na događaje sustava

Omarchy pokreće hookove u nekoliko trenutaka, a na njih možeš objesiti vlastite skripte. Nalaze se u `~/.config/omarchy/hooks/<event>.d/`, po jedan direktorij za svaki događaj, i svaka izvršna datoteka u njemu pokreće se kada se događaj dogodi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Odmah nakon pokretanja radne površine |
| `post-update` | Pri kraju `omarchy update`, nakon paketa, migracija i ponovnog pokretanja usluga, prije ažuriranja mise alata |
| `pre-refresh-pacman` | Nakon što `omarchy refresh pacman` ponovno sinkronizira konfiguraciju paketa, prije nego što ažurira pakete; promjena kanala pokreće ga tijekom istog koraka osvježavanja |
| `theme-set` | Nakon promjene teme (naziv teme u `$1`) |
| `font-set` | Nakon promjene fonta (naziv fonta u `$1`) |
| `battery-low` | Kada je baterija niska (postotak u `$1`) |

Hook `pre-refresh-pacman` mjesto je gdje pripadaju prilagođeni repozitoriji ili retci `IgnorePkg`, jer se pokreće prije transakcije paketa. Oba hooka povezana s ažuriranjem pokreću se kao tvoj korisnik nakon što Omarchy obriše svoju predmemoriranu sudo autorizaciju, pa hook koji koristi `sudo` treba vlastitu autorizaciju i može tražiti tvoju lozinku.

Svaki od tih direktorija već sadrži datoteku `.sample` koja pokazuje oblik hooka — ukloni `.sample` iz naziva da bi ga stavio u rad. Za instalaciju skripte koju si napisao drugdje koristi `omarchy hook install post-boot ~/my-hook`, što je kopira unutra i čini je izvršnom.

### Dodavanje vlastitih stavki izbornika

Omarchy izbornik (`Super + Space`) može se proširiti vlastitim retcima uređivanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Stavke su označene ključem u obliku točkastog id-a, a id je ono što ih smješta u stablo, pa se `personal` pojavljuje na korijenskom izborniku, a `personal.notes` unutar njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponovno upotrijebi postojeći id i prepisat ćeš taj redak umjesto da dodaš novi. Datoteka dolazi sa svim dostupnim poljima dokumentiranima kao komentari.

### Dodavanje vlastitih izvoza, funkcija i aliasa ljuske

Omarchy dolazi s hrpom ergonomskih aliasa i korisnih funkcija, ali vrlo je uobičajeno htjeti dodati vlastite. I aliase, i funkcije, i izvoze trebao bi dodavati u `~/.bashrc`. Ova datoteka neće biti prepisana pri ažuriranjima. Ako želiš promijeniti bilo koju Omarchy zadanu vrijednost, i njih ovdje možeš sigurno dodati.

### Postavljanje varijabli okruženja za radnu površinu

Izvozi sesije radne površine pripadaju u `~/.config/uwsm/env.d/`. Te se datoteke pokreću prije pokretanja radne površine, pa te pogreška ljuske može vratiti na zaslon za prijavu. Drži otvoren terminal koji radi dok ih uređuješ. Za onemogućavanje prepisivanja premjesti ga iz `env.d`. Pogledaj [oporavak prijave](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ako promjena sprječava prijavu.

### Mijenjanje internih Omarchy datoteka

Gle, ovo je tvoje računalo. Možeš s njim raditi što god želiš, ali savjetovao bih ti da ne mijenjaš izravno datoteke u `/usr/share/omarchy`. One pripadaju Omarchy pacman paketu, pa će tvoje izmjene jednostavno biti prepisane pri sljedećem ažuriranju. Bolje ti je umjesto toga samo prepisati sve zadane vrijednosti koje ti se ne sviđaju u mapi `~/.config/*`.

Na taj način možeš promijeniti gotovo sve, poput zadanih tipkovnih prečaca. Samo uredi `~/.config/hypr/bindings.lua` da, recimo, zamijeniš [Obsidian](https://obsidian.md/) s [Joplin](https://joplinapp.org/) (instaliraj s `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` uklanja postojeće povezivanje prije dodavanja zamjene. Prima iste argumente kao `o.bind`, uključujući pomoćne funkcije za pokretanje i opcije povezivanja. Koristi `o.bind` za dodavanje povezivanja ili `hl.unbind` za uklanjanje povezivanja bez zamjene.

Ako inzistiraš na hakiranju internih Omarchy datoteka, prebaci se na dev kanal putem _Ažuriranje > Kanal > Dev_. To povezuje Omarchy s git izvatkom izvornog koda u `~/omarchy`, koji slobodno možeš mijenjati koliko ti srce želi. Nitko ti ovdje neće govoriti što da radiš!

### Vraćanje svih promjena

Ako na kraju napraviš nered od konfiguracija, uvijek ih možeš vratiti na zadane vrijednosti putem _Ažuriranje > Konfiguracija_ u Omarchy izborniku. Ili pokretanjem `omarchy reinstall configs` za resetiranje svega.
