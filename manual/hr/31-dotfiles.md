# Dotfiles

Omarchy se prvenstveno konfigurira putem takozvanih dotfiles datoteka koje se nalaze u `~/.config`. One se smatraju tvojim datotekama za tvoje izmjene. Datoteke koje se nalaze u `/usr/share/omarchy` pripadaju samom Omarchyju i ne bi se trebao petljati s njima. Ako trebaš promijeniti bilo što u `/usr/share/omarchy`, umjesto toga trebaš pregaziti vrijednost u `~/.config`.

Ključne konfiguracije mogu se uređivati izravno iz izbornika Omarchy (`Super + Space`), poput _Postavljanje > Tipkovnica > Tipkovnički prečaci_, _Postavljanje > Unos_ i _Postavljanje > Konfiguracija > [file]_. Kada to radiš na ovaj način, svaki proces koji se treba ponovno pokrenuti nakon uređivanja konfiguracije automatski će se ponovno pokrenuti nakon što zatvoriš uređivač (prema zadanim postavkama Neovim — `:wq`, zapamti! — ali to možeš promijeniti putem _Postavljanje > Zadane postavke > Uređivač_).

Evo popisa ključnih datoteka u `~/.config` i čime upravljaju:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna konfiguracija za Hyprland. Učitava zadane postavke Omarchyja plus tvoje datoteke s nadjačavanjima navedene u nastavku. [Saznaj više o konfiguracijama za Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tvoji vlastiti tipkovnički prečaci i nadjačavanja zadanih. |
| `~/.config/hypr/monitors.lua` | Postavke monitora koje ploča za monitore ne pokriva, poput rotacije, dodatnih načina rada ili držanja monitora isključenim. |
| `~/.config/hypr/input.lua` | Upravlja rasporedom tipkovnice, mišem i postavkama dodirne plohe. |
| `~/.config/hypr/looknfeel.lua` | Upravlja razmacima, obrubima, animacijama i ostatkom izgleda. |
| `~/.config/hypr/autostart.lua` | Upravlja dodatnim procesima koji se pokreću sa sesijom. |
| `~/.config/omarchy/shell.json` | Upravlja shellom Omarchyja: položajem trake, rasporedom i widgetima, plus čuvarom zaslona, zaključavanjem i vremenima mirovanja. |
| `~/.config/foot/foot.ini` | Upravlja tvojim terminalom (foot je zadani). |
| `~/.XCompose` | Definira tvoje emojije za brzi pristup i automatsko dovršavanje imena/e-pošte. Obavezno pokreni `omarchy-restart-xcompose` nakon izmjena. |

Ako na kraju napraviš puno izmjena kako bi prilagodio vlastitu postavu, dobra je ideja napraviti sigurnosnu kopiju svih tih dotfiles datoteka. [Stow je sjajan način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pokretanje vlastitih aplikacija sa sesijom

Ako želiš da se nešto pokreće svaki put kada se prijaviš — demon za sinkronizaciju, aplikacija za razgovor, vlastita skripta — stavi to u `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To pokreće naredbu kao dio sesije, pa se pravilno čisti kada se ponovno odjaviš.

### Pokretanje skripti na događaje sustava

Omarchy pokreće hookove u nekoliko trenutaka, a na njih možeš objesiti vlastite skripte. Nalaze se u `~/.config/omarchy/hooks/<event>.d/`, jedan direktorij po događaju, a svaka datoteka u njemu koja ne završava na `.sample` pokreće se s bash kada se događaj dogodi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Odmah nakon što se radna površina pokrenula |
| `post-update` | Pri kraju `omarchy update`, nakon paketa, migracija i ponovnog pokretanja usluga, prije nego što se mise alati ažuriraju |
| `pre-refresh-pacman` | Nakon što `omarchy refresh pacman` ponovno sinkronizira konfiguraciju paketa, prije nego što ažurira pakete; promjena kanala pokreće ga tijekom istog koraka osvježavanja |
| `theme-set` | Nakon promjene teme (naziv teme u `$1`) |
| `font-set` | Nakon promjene fonta (naziv fonta u `$1`) |
| `battery-low` | Kada je baterija niska (postotak u `$1`) |

Hook `pre-refresh-pacman` mjesto je gdje pripadaju prilagođeni repozitoriji ili retci `IgnorePkg`, jer se pokreće prije transakcije paketa. Oba se pokreću kao tvoj korisnik. `post-update` se pokreće dok je sudo autorizacija od `omarchy update` još svježa, pa hook koji koristi `sudo` neće ponovno tražiti tvoju lozinku; `pre-refresh-pacman` se pokreće odmah nakon što je `omarchy refresh pacman` sam upotrijebio sudo.

Svaki od tih direktorija već sadrži datoteku `.sample` koja pokazuje oblik hooka — ukloni `.sample` iz naziva da ga staviš u pogon. Za instalaciju skripte koju si napisao drugdje upotrijebi `omarchy hook install post-boot ~/my-hook`, što je kopira unutra i čini izvršnom.

### Dodavanje vlastitih stavki izbornika

Izbornik Omarchy (`Super + Space`) može se proširiti vlastitim retcima uređivanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Stavke se označavaju točkastim id-jem, a id je ono što ih smješta u stablo, pa se `personal` pojavljuje na korijenskom izborniku, a `personal.notes` unutar njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponovnom upotrebom postojećeg id-ja nadjačavaš taj redak umjesto da dodaš novi. Datoteka dolazi sa svim dostupnim poljima dokumentiranim kao komentari.

### Dodavanje vlastitih exporta, funkcija i aliasa za shell

Omarchy dolazi s hrpom ergonomskih aliasa i korisnih funkcija, ali vrlo je uobičajeno htjeti dodati vlastite. I aliase, i funkcije, i exporte trebaš dodavati u `~/.bashrc`. Ova datoteka neće biti pregažena pri ažuriranjima. Ako želiš promijeniti bilo koju od zadanih postavki Omarchyja, i njih možeš sigurno dodati ovdje.

### Postavljanje varijabli okruženja za radnu površinu

Exporti sesije radne površine pripadaju u `~/.config/uwsm/env.d/`. Te se datoteke pokreću prije pokretanja tvoje radne površine, pa te pogreška u shellu može vratiti na zaslon za prijavu. Drži otvoren ispravan terminal dok ih uređuješ. Za onemogućavanje nadjačavanja premjesti ga iz `env.d`. Pogledaj [oporavak prijave](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ako promjena sprječava prijavu.

### Mijenjanje internih datoteka Omarchyja

Gle, ovo je tvoje računalo. Možeš s njim raditi što god želiš, ali savjetovao bih ti da ne mijenjaš datoteke u `/usr/share/omarchy` izravno. One pripadaju pacman paketu Omarchy, pa će tvoje izmjene jednostavno biti pregažene pri sljedećem ažuriranju. Bolje ti je umjesto toga pregaziti u mapi `~/.config/*` sve zadane vrijednosti koje ti se ne sviđaju.

Na taj način možeš promijeniti gotovo sve, poput zadanih tipkovničkih prečaca. Samo uredi `~/.config/hypr/bindings.lua` da, recimo, zamijeniš [Obsidian](https://obsidian.md/) s [Joplin](https://joplinapp.org/) (instaliraj s `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` uklanja postojeći prečac prije dodavanja njegove zamjene. Prima iste argumente kao `o.bind`, uključujući pomoćne funkcije za pokretanje i opcije prečaca. Upotrijebi `o.bind` za dodavanje prečaca ili `hl.unbind` za uklanjanje prečaca bez zamjene.

Ako inzistiraš na hakiranju internih datoteka Omarchyja, prebaci se na dev kanal putem _Ažuriranje > Kanal > Dev_. To povezuje Omarchy s git checkoutom izvornog koda u `~/omarchy`, koji slobodno možeš mijenjati koliko god ti srce želi. Nitko ti ovdje neće govoriti što da radiš!

### Poništavanje svih izmjena

Ako na kraju napraviš nered u konfiguracijama, uvijek ih možeš vratiti na zadane postavke putem _Ažuriranje > Konfiguracija_ u izborniku Omarchy. Ili pokretanjem `omarchy reinstall configs` za resetiranje svega.
