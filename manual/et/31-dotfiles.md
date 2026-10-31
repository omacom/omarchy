# Dotfile'id

Omarchy konfigureeritakse peamiselt niinimetatud dotfile'ide kaudu, mis elavad kaustas `~/.config`. Neid peetakse sinu failideks sinu muudatuste jaoks. Failid, mis elavad kaustas `/usr/share/omarchy`, kuuluvad Omarchyle endale ja sa ei peaks nendega jändama. Kui pead midagi kaustas `/usr/share/omarchy` muutma, peaksid selle asemel väärtuse kaustas `~/.config` üle kirjutama.

Peamisi konfiguratsioone saab redigeerida otse Omarchy menüüst (`Super + Space`), nagu _Seaded > Kuvarid_, _Seaded > Kiirklahvid_, _Seaded > Sisend_ ja _Seaded > Config > [file]_. Kui teed seda sel viisil, taaskäivitub iga protsess, mis vajab pärast konfiguratsiooni redigeerimist taaskäivitamist, automaatselt pärast redaktorist väljumist (vaikimisi Neovim — `:wq`, pea meeles! — kuid saad seda muuta jaotise _Seaded > Defaults > Editor_ kaudu).

Siin on kausta `~/.config` peamiste failide loend ja see, mida nad juhivad:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Peamine Hyprlandi konfiguratsioon. Laeb Omarchy vaikeväärtused pluss sinu allolevad ülekirjutamisfailid. [Lisateave Hyprlandi konfiguratsioonide kohta](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Sinu enda kiirklahvid ja vaikeväärtuste ülekirjutamised. |
| `~/.config/hypr/monitors.lua` | Juhib sinu kuvareid, eraldusvõimet ja asendit. |
| `~/.config/hypr/input.lua` | Juhib sinu klaviatuuri paigutust, hiire ja puuteplaadi seadeid. |
| `~/.config/hypr/looknfeel.lua` | Juhib vahesid, ääriseid, animatsioone ja ülejäänud välimust. |
| `~/.config/hypr/autostart.lua` | Juhib seansiga käivitatud lisaprotsesse. |
| `~/.config/omarchy/shell.json` | Juhib Omarchy kesta: riba asendit, paigutust ja vidinaid, pluss ekraanisäästja, lukustuse ja jõudeoleku ajastused. |
| `~/.config/foot/foot.ini` | Juhib sinu terminali (foot on vaikeseade). |
| `~/.XCompose` | Määratleb sinu kiirjuurdepääsu emojid ja nime/e-posti automaatse täitmise. Veendu, et käivitad pärast muudatuste tegemist `omarchy-restart-xcompose`. |

Kui teed lõpuks oma seadistuse kohandamiseks palju muudatusi, on hea mõte kõik need dotfile'id varundada. [Stow on suurepärane viis selle tegemiseks](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Oma rakenduste käivitamine koos seansiga

Kui soovid, et midagi töötaks iga kord sisselogimisel — sünkroonimisdeemon, vestlusrakendus, sinu oma skript — pane see faili `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

See käivitab käsu seansi osana, nii et see koristatakse korralikult, kui uuesti välja logid.

### Skriptide käivitamine süsteemisündmustel

Omarchy käivitab konkse käputäiel hetkedel ja saad oma skripte nende külge riputada. Nad elavad kaustas `~/.config/omarchy/hooks/<event>.d/`, üks kaust sündmuse kohta, ja iga sealne käivitatav fail töötab, kui sündmus toimub:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Kohe pärast töölaua käivitumist |
| `post-update` | Käsu `omarchy update` lõpu poole, pärast pakette, migratsioone ja teenuste taaskäivitusi, enne mise tööriistade uuendamist |
| `pre-refresh-pacman` | Pärast seda, kui `omarchy refresh pacman` sünkroniseerib uuesti paketi konfiguratsiooni, enne pakettide uuendamist; kanali vahetus käivitab selle sama värskendussammu ajal |
| `theme-set` | Pärast teema muutmist (teema nimi on `$1`-s) |
| `font-set` | Pärast kirjatüübi muutmist (kirjatüübi nimi on `$1`-s) |
| `battery-low` | Kui aku saab tühjaks (protsent on `$1`-s) |

Konks `pre-refresh-pacman` on koht, kuhu kohandatud repod või `IgnorePkg` read kuuluvad, kuna see töötab enne paketi tehingut. Mõlemad uuendusega seotud konksud töötavad sinu kasutajana pärast seda, kui Omarchy tühjendab oma vahemälu salvestatud sudo autoriseerimise, nii et konks, mis kasutab `sudo`, vajab oma autoriseerimist ja võib küsida sinu parooli.

Kõik need kaustad sisaldavad juba `.sample` faili, mis näitab konksu kuju — eemalda nimest `.sample`, et see tööle panna. Kuskil mujal kirjutatud skripti paigaldamiseks kasuta `omarchy hook install post-boot ~/my-hook`, mis kopeerib selle sisse ja muudab selle käivitatavaks.

### Oma menüükirjete lisamine

Omarchy menüüd (`Super + Space`) saab laiendada oma ridadega, redigeerides faili `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Kirjed on võtmega punktiiritud ID järgi ja ID paigutab need puusse, nii et `personal` ilmub juurmenüüsse ja `personal.notes` ilmub selle sisse:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Kasuta olemasolevat ID-d uuesti ja kirjutad selle rea üle, mitte ei lisa uut. Fail tuleb koos kõigi saadaolevate väljadega, mis on dokumenteeritud kommentaaridena.

### Oma kesta eksportide, funktsioonide ja aliaste lisamine

Omarchy tuleb hulga ergonoomiliste aliaste ja kasulike funktsioonidega, kuid väga tavaline on soovida lisada oma. Sa peaksid lisama nii aliased, funktsioonid kui ka ekspordid faili `~/.bashrc`. Seda faili uuenduste korral üle ei kirjutata. Kui soovid mõnda Omarchy vaikeväärtust muuta, saad need ka siia turvaliselt lisada.

### Sisemiste Omarchy failide muutmine

Kuule, see on sinu arvuti. Sa saad sellega teha, mida tahad, kuid ma soovitaksin mitte tehdä muudatusi otse kausta `/usr/share/omarchy` failides. Need kuuluvad Omarchy pacmani paketile, nii et sinu muudatused kirjutatakse järgmise uuendusega lihtsalt üle. Parem on lihtsalt kirjutada üle kõik vaikeväärtused, mis sulle kaustas `~/.config/*` ei meeldi.

Peaaegu kõike saad sel viisil muuta, näiteks vaikekiirklahve. Redigeeri lihtsalt faili `~/.config/hypr/bindings.lua`, et näiteks asendada [Obsidian](https://obsidian.md/) rakendusega [Joplin](https://joplinapp.org/) (paigalda käsuga `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` eemaldab olemasoleva sidumise enne selle asenduse lisamist. See võtab samad argumendid nagu `o.bind`, sealhulgas käivitusabilised ja sidumisvõimalused. Kasuta sidumise lisamiseks `o.bind` või selle asendamata eemaldamiseks `hl.unbind`.

Kui nõuad sisemiste Omarchy failide kallal nokitsemist, vaheta dev kanalile jaotise _Uuenda > Channel > Dev_ kaudu. See lingib Omarchy lähtekoodi giti checkoutiga kaustas `~/omarchy`, mida saad vabalt südamepõhjani muuta. Siin pole kedagi, kes sulle ütleks, mida teha!

### Muudatuste lähtestamine

Kui teed konfiguratsioonidest lõpuks segaduse, saad need alati vaikeväärtustele tagasi viia Omarchy menüü jaotise _Uuenda > Config_ kaudu. Või käivitades `omarchy reinstall configs`, et kõik lähtestada.
