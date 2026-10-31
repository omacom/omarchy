# Dotfiles

Omarchyt seadistatakse peamiselt nn dotfiles-failide kaudu, mis asuvad kaustas `~/.config`. Neid peetakse sinu failideks sinu muudatuste jaoks. Failid, mis asuvad kaustas `/usr/share/omarchy`, kuuluvad Omarchyle endale ja sa ei peaks nendega jändama. Kui sul on vaja midagi muuta kaustas `/usr/share/omarchy`, peaksid selle väärtuse hoopis üle kirjutama kaustas `~/.config`.

Põhikonfiguratsioone saab redigeerida otse Omarchy menüüst (`Super + Space`), näiteks _Setup > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kui teed seda nii, käivitatakse iga protsess, mis vajab pärast konfiguratsioonimuudatusi taaskäivitamist, automaatselt taaskäivitatud pärast redaktorist väljumist (vaikimisi Neovim — `:wq`, pea meeles! — kuid seda saab muuta valiku _Setup > Defaults > Editor_ kaudu).

Siin on loend kausta `~/.config` põhifailidest ja sellest, mida need juhivad:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprlandi põhikonfiguratsioon. Laadib Omarchy vaikeväärtused ja sinu alltoodud ülekirjutusfailid. [Lisateave Hyprlandi konfiguratsioonide kohta](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Sinu enda klahviseosed ja vaikeväärtuste ülekirjutused. |
| `~/.config/hypr/monitors.lua` | Monitori seaded, mida monitori paneel ei kata, nagu pööramine, lisarežiimid või monitori väljalülitatuna hoidmine. |
| `~/.config/hypr/input.lua` | Juhib sinu klaviatuuripaigutust, hiirt ja puuteplaadi seadeid. |
| `~/.config/hypr/looknfeel.lua` | Juhib vahesid, ääriseid, animatsioone ja ülejäänud välimust. |
| `~/.config/hypr/autostart.lua` | Juhib seansiga käivitatavaid lisaprotsesse. |
| `~/.config/omarchy/shell.json` | Juhib Omarchy kesta: riba asukohta, paigutust ja vidinaid ning ekraanisäästja, lukustamise ja jõudeoleku ajastusi. |
| `~/.config/foot/foot.ini` | Juhib sinu terminali (vaikimisi on foot). |
| `~/.XCompose` | Määrab sinu kiirpääsu emotikonid ja nime/e-posti automaatse täitmise. Pärast muudatuste tegemist käivita kindlasti `omarchy-restart-xcompose`. |

Kui teed lõpuks oma seadistuse kohandamiseks palju muudatusi, on hea mõte kõik need dotfiles-failid varundada. [Stow on selleks suurepärane vahend](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Oma rakenduste käivitamine koos seansiga

Kui soovid, et midagi käivituks iga kord, kui sisse logid — sünkroonimisdeemon, vestlusrakendus, sinu enda skript — pane see kausta `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

See käivitab käsu seansi osana, nii et see koristatakse korralikult ära, kui uuesti välja logid.

### Skriptide käivitamine süsteemisündmuste korral

Omarchy käivitab konkse käputäiel hetkedel ja saad nende külge riputada oma skripte. Need asuvad kaustas `~/.config/omarchy/hooks/<event>.d/`, iga sündmuse jaoks üks kataloog, ja iga sealne käivitatav fail käivitatakse sündmuse toimumisel:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Kohe pärast töölaua käivitumist |
| `post-update` | `omarchy update` lõpu lähedal, pärast pakette, migratsioone ja teenuste taaskäivitusi, enne mise tööriistade värskendamist |
| `pre-refresh-pacman` | Pärast seda, kui `omarchy refresh pacman` sünkroonib paketi konfiguratsiooni uuesti, enne pakettide värskendamist; kanali vahetus käivitab selle sama värskendusetapi ajal |
| `theme-set` | Pärast teema muutmist (teema nimi asukohas `$1`) |
| `font-set` | Pärast fondi muutmist (fondi nimi asukohas `$1`) |
| `battery-low` | Kui aku hakkab tühjaks saama (protsent asukohas `$1`) |

Konks `pre-refresh-pacman` on koht, kuhu kuuluvad kohandatud hoidlad või `IgnorePkg` read, kuna see käivitatakse enne paketi tehingut. Mõlemad värskendustega seotud konksud käivitatakse sinu kasutajana pärast seda, kui Omarchy on oma vahemällu salvestatud sudo loa tühistanud, nii et konks, mis kasutab käsku `sudo`, vajab oma luba ja võib küsida sinu parooli.

Igas neist kataloogidest on juba `.sample` fail, mis näitab konksu kuju — eemalda nimest `.sample`, et see tööle panna. Mujal kirjutatud skripti installimiseks kasuta käsku `omarchy hook install post-boot ~/my-hook`, mis kopeerib selle sisse ja teeb selle käivitatavaks.

### Oma menüükirjete lisamine

Omarchy menüüd (`Super + Space`) saab laiendada oma ridadega, redigeerides faili `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Kirjed on võtmestatud punktidega eraldatud id-ga ja just id paigutab need puusse, nii et `personal` kuvatakse juurmenüüs ja `personal.notes` kuvatakse selle sees:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Kasuta olemasolevat id-d uuesti ja kirjutad selle rea uue lisamise asemel üle. Fail tarnitakse koos kõigi saadaolevate väljadega, mis on dokumenteeritud kommentaaridena.

### Oma kesta ekspordide, funktsioonide ja aliastete lisamine

Omarchy tarnitakse koos hulga ergonoomiliste aliastete ja kasulike funktsioonidega, kuid väga tavaline on soov lisada oma. Peaksid lisama nii aliased, funktsioonid kui ka ekspordid faili `~/.bashrc`. Seda faili värskenduste ajal üle ei kirjutata. Kui soovid muuta mõnda Omarchy vaikeväärtust, saad need ka siia ohutult lisada.

### Omarchy sisemiste failide muutmine

Kuule, see on sinu arvuti. Saad sellega teha, mida iganes soovid, kuid soovitaksin mitte muuta otse kaustas `/usr/share/omarchy` olevaid faile. Need kuuluvad Omarchy pacman paketti, nii et sinu muudatused kirjutatakse järgmise värskendusega lihtsalt üle. Sul on parem kirjutada kõik vaikeväärtused, mis sulle ei meeldi, üle hoopis kaustas `~/.config/*`.

Nii saad muuta peaaegu kõike, näiteks vaikeklahviseoseid. Redigeeri lihtsalt faili `~/.config/hypr/bindings.lua`, et näiteks asendada [Obsidian](https://obsidian.md/) rakendusega [Joplin](https://joplinapp.org/) (installi käsuga `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` eemaldab olemasoleva seose enne selle asenduse lisamist. See võtab samad argumendid kui `o.bind`, sealhulgas käivitusabilised ja sidumisvalikud. Seose lisamiseks kasuta funktsiooni `o.bind` või selle ilma asendamata eemaldamiseks funktsiooni `hl.unbind`.

Kui nõuad Omarchy sisemiste failide häkkimist, lülitu dev-kanalile valiku _Update > Channel > Dev_ kaudu. See seob Omarchy lähtekoodi git-varundusega kaustas `~/omarchy`, mida saad südamerahuga muuta. Keegi siin ei ütle sulle, mida teha!

### Kõigi muudatuste lähtestamine

Kui ajad konfiguratsioonid lõpuks sassi, saad need alati vaikeväärtustele tagasi keerata Omarchy menüü valiku _Update > Config_ kaudu. Või käivitades käsu `omarchy reinstall configs`, et kõik lähtestada.
