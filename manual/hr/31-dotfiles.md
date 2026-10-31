# Dotfiles

Omarchy se prvenstveno konfigurira putem takozvanih dotfiles datoteka koje se nalaze u `~/.config`. One se smatraju vašim datotekama za vaše izmjene. Datoteke koje se nalaze u `/usr/share/omarchy` pripadaju samom Omarchyju i ne biste ih trebali dirati. Ako trebate promijeniti bilo što u `/usr/share/omarchy`, umjesto toga trebali biste pregaziti vrijednost u `~/.config`.

Ključne konfiguracije mogu se uređivati izravno iz Omarchy izbornika (`Super + Space`), poput _Setup > Keybindings_, _Setup > Input_ i _Setup > Config > [file]_. Kad to radite na taj način, svaki proces koji se treba ponovno pokrenuti nakon izmjena konfiguracije automatski će se ponovno pokrenuti nakon što zatvorite uređivač (Neovim prema zadanim postavkama — `:wq`, zapamtite! — ali to možete promijeniti putem _Setup > Defaults > Editor_).

Evo popisa ključnih datoteka u `~/.config` i onoga što kontroliraju:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Glavna Hyprland konfiguracija. Učitava zadane postavke Omarchyja plus vaše datoteke s pregazivanjima navedene u nastavku. [Saznajte više o Hyprland konfiguracijama](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaši vlastiti prečaci na tipkovnici i pregazivanja zadanih postavki. |
| `~/.config/hypr/monitors.lua` | Postavke monitora koje ploča za monitore ne pokriva, poput rotacije, dodatnih načina rada ili isključivanja monitora. |
| `~/.config/hypr/input.lua` | Kontrolira raspored tipkovnice, postavke miša i trackpada. |
| `~/.config/hypr/looknfeel.lua` | Kontrolira razmake, obrube, animacije i ostatak izgleda. |
| `~/.config/hypr/autostart.lua` | Kontrolira dodatne procese koji se pokreću sa sesijom. |
| `~/.config/omarchy/shell.json` | Kontrolira Omarchy ljusku: položaj trake, raspored i widgete, plus vremena za čuvar zaslona, zaključavanje i mirovanje. |
| `~/.config/foot/foot.ini` | Kontrolira vaš terminal (foot je zadani). |
| `~/.XCompose` | Definira vaše emojije za brzi pristup i automatsko dovršavanje imena/e-pošte. Obavezno pokrenite `omarchy-restart-xcompose` nakon izmjena. |

Ako na kraju napravite mnogo izmjena kako biste prilagodili vlastitu postavu, dobra je ideja napraviti sigurnosnu kopiju svih tih dotfiles datoteka. [Stow je izvrstan način za to](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pokretanje vlastitih aplikacija sa sesijom

Ako želite da se nešto pokreće svaki put kad se prijavite — demon za sinkronizaciju, aplikacija za razgovor, vlastita skripta — stavite to u `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

To pokreće naredbu kao dio sesije, pa se pravilno čisti kad se ponovno odjavite.

### Pokretanje skripti pri sistemskim događajima

Omarchy pokreće hookove u nekoliko trenutaka, a na njih možete objesiti vlastite skripte. Nalaze se u `~/.config/omarchy/hooks/<event>.d/`, po jedan direktorij za svaki događaj, a svaka izvršna datoteka u njemu pokreće se kad se događaj dogodi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Odmah nakon što se radna površina pokrene |
| `post-update` | Pred kraj `omarchy update`, nakon paketa, migracija i ponovnog pokretanja servisa, prije nego što se alati mise ažuriraju |
| `pre-refresh-pacman` | Nakon što `omarchy refresh pacman` ponovno sinkronizira konfiguraciju paketa, prije nego što ažurira pakete; promjena kanala pokreće ga tijekom istog koraka osvježavanja |
| `theme-set` | Nakon promjene teme (naziv teme u `$1`) |
| `font-set` | Nakon promjene fonta (naziv fonta u `$1`) |
| `battery-low` | Kad je baterija niska (postotak u `$1`) |

Hook `pre-refresh-pacman` mjesto je gdje pripadaju prilagođeni repozitoriji ili retci `IgnorePkg`, budući da se pokreće prije transakcije paketa. Oba hooka povezana s ažuriranjem pokreću se kao vaš korisnik nakon što Omarchy očisti svoju predmemoriranu sudo autorizaciju, pa hook koji koristi `sudo` treba vlastitu autorizaciju i može zatražiti vašu lozinku.

Svaki od tih direktorija već sadrži datoteku `.sample` koja pokazuje oblik hooka — uklonite `.sample` iz naziva da biste ga aktivirali. Za instalaciju skripte koju ste napisali negdje drugdje upotrijebite `omarchy hook install post-boot ~/my-hook`, što je kopira unutra i čini je izvršnom.

### Dodavanje vlastitih stavki izbornika

Omarchy izbornik (`Super + Space`) može se proširiti vlastitim retcima uređivanjem `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Stavke su ključane točkastim id-om, a id je ono što ih smješta u stablo, pa se `personal` pojavljuje u korijenskom izborniku, a `personal.notes` pojavljuje se unutar njega:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponovno upotrijebite postojeći id i pregazit ćete taj redak umjesto da dodate novi. Datoteka dolazi sa svim dostupnim poljima dokumentiranima kao komentari.

### Dodavanje vlastitih izvoza ljuske, funkcija i aliasa

Omarchy dolazi s hrpom ergonomskih aliasa i korisnih funkcija, ali vrlo je uobičajeno htjeti dodati vlastite. I aliase, i funkcije, i izvoze trebali biste dodavati u `~/.bashrc`. Ta datoteka neće biti pregazana pri ažuriranjima. Ako želite promijeniti bilo koju od zadanih postavki Omarchyja, možete ih sigurno dodati i ovdje.

### Postavljanje varijabli okruženja za radnu površinu

Izvozi sesije radne površine pripadaju u `~/.config/uwsm/env.d/`. Te se datoteke pokreću prije nego što se vaša radna površina pokrene, pa vas pogreška ljuske može vratiti na zaslon za prijavu. Držite otvoren ispravan terminal dok ih uređujete. Za onemogućavanje pregazivanja premjestite ga iz `env.d`. Pogledajte [oporavak prijave](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ako promjena sprječava prijavu.

### Mijenjanje internih datoteka Omarchyja

Gledajte, ovo je vaše računalo. S njim možete raditi što god želite, ali savjetovao bih da ne mijenjate izravno datoteke u `/usr/share/omarchy`. One pripadaju Omarchy pacman paketu, pa će vaše izmjene jednostavno biti pregazane pri sljedećem ažuriranju. Bolje vam je umjesto toga samo pregaziti sve zadane vrijednosti koje vam se ne sviđaju u mapi `~/.config/*`.

Na taj način možete promijeniti gotovo sve, poput zadanih prečaca na tipkovnici. Samo uredite `~/.config/hypr/bindings.lua` da, recimo, zamijenite [Obsidian](https://obsidian.md/) s [Joplin](https://joplinapp.org/) (instalirajte s `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` uklanja postojeće povezivanje prije dodavanja njegove zamjene. Prima iste argumente kao `o.bind`, uključujući pomoćnike za pokretanje i opcije povezivanja. Upotrijebite `o.bind` za dodavanje povezivanja ili `hl.unbind` za uklanjanje jednog bez zamjene.

Ako inzistirate na hakiranju internih datoteka Omarchyja, prebacite se na dev kanal putem _Update > Channel > Dev_. To povezuje Omarchy s git checkoutom izvornog koda u `~/omarchy`, koji slobodno možete mijenjati koliko god želite. Nema ovdje nikoga tko bi vam govorio što da radite!

### Vraćanje svih izmjena

Ako na kraju napravite zbrku od konfiguracija, uvijek ih možete vratiti na zadane postavke putem _Update > Config_ u Omarchy izborniku. Ili pokretanjem `omarchy reinstall configs` za resetiranje svega.
