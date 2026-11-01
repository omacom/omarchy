# Dotfailid

Omarchy on peamiselt seadistatav niinimetatud dotfailide kaudu, mis asuvad kaustas `~/.config`. Neid peetakse sinu failideks sinu muudatuste jaoks. Failid, mis asuvad kaustas `/usr/share/omarchy`, kuuluvad Omarchyle endale ja sa ei peaks nendega jamama. Kui sul on vaja midagi muuta kaustas `/usr/share/omarchy`, peaksid selle väärtuse hoopis üle kirjutama kaustas `~/.config`.

Peamisi seadistusi saab muuta otse Omarchy menüüst (`Super + Space`), näiteks _Setup > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kui teed seda nii, käivitatakse iga protsess, mis pärast seadistuste muutmist taaskäivitamist vajab, automaatselt uuesti, kui oled redaktori sulgenud (vaikimisi Neovim — `:wq`, pea meeles! — aga saad seda muuta valiku _Setup > Defaults > Editor_ kaudu).

Siin on loetelu peamistest failidest kaustas `~/.config` ja sellest, mida need juhivad:

| Fail | Otstarve |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Peamine Hyprland seadistusfail. Laadib Omarchy vaikeväärtused ja sinu allpool olevad ülekirjutusfailid. [Lisateave Hyprland seadistuste kohta](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Sinu enda klahviseosed ja vaikeväärtuste ülekirjutused. |
| `~/.config/hypr/monitors.lua` | Monitori seaded, mida monitori paneel ei kata, näiteks pööramine, lisarežiimid või monitori väljalülitatuna hoidmine. |
| `~/.config/hypr/input.lua` | Juhib sinu klaviatuuripaigutust, hiire ja puuteplaadi seadeid. |
| `~/.config/hypr/looknfeel.lua` | Juhib vahesid, ääriseid, animatsioone ja ülejäänud välimust. |
| `~/.config/hypr/autostart.lua` | Juhib seansiga käivitatavaid lisaprotsesse. |
| `~/.config/omarchy/shell.json` | Juhib Omarchy kesta: riba asukohta, paigutust ja vidinaid ning ekraanisäästja, lukustuse ja jõudeoleku ajastusi. |
| `~/.config/foot/foot.ini` | Juhib sinu terminali (vaikimisi on foot). |
| `~/.XCompose` | Määrab sinu kiire juurdepääsu emotikonid ning nime/e-posti automaatse täitmise. Pärast muudatuste tegemist käivita kindlasti `omarchy-restart-xcompose`. |

Kui teed lõpuks oma seadistuse kohandamiseks palju muudatusi, on hea mõte kõik need dotfailid varundada. [Stow on selleks suurepärane viis](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Oma rakenduste käivitamine koos seansiga

Kui soovid, et midagi töötaks iga kord, kui sisse logid — sünkroonimisdeemon, vestlusrakendus, sinu enda skript — pane see faili `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

See käivitab käsu seansi osana, nii et see puhastatakse korralikult ära, kui uuesti välja logid.

### Skriptide käivitamine süsteemisündmuste korral

Omarchy vallandab konksud käputäiel hetkedel ja saad nende külge oma skripte riputada. Need asuvad kaustas `~/.config/omarchy/hooks/<event>.d/`, iga sündmuse jaoks üks kaust, ja iga sealne käivitatav fail käivitatakse sündmuse toimumisel:

| Sündmus | Millal see käivitatakse |
| ----- | ------------ |
| `post-boot` | Kohe pärast töölaua käivitumist |
| `post-update` | `omarchy update` lõpu lähedal, pärast pakette, migratsioone ja teenuste taaskäivitusi, enne mise tööriistade värskendamist |
| `pre-refresh-pacman` | Pärast seda, kui `omarchy refresh pacman` paketi seadistuse uuesti sünkroonib, enne pakettide värskendamist; kanali vahetus käivitab selle sama värskendussammu ajal |
| `theme-set` | Pärast teema muutmist (teema nimi on `$1`) |
| `font-set` | Pärast fondi muutmist (fondi nimi on `$1`) |
| `battery-low` | Kui aku tühjeneb (protsent on `$1`) |

`pre-refresh-pacman` konks on koht, kuhu kuuluvad kohandatud hoidlad või `IgnorePkg` read, kuna see käivitatakse enne paketi tehingut. Mõlemad värskendusega seotud konksud käivitatakse sinu kasutajana pärast seda, kui Omarchy on oma vahemällu salvestatud sudo autoriseerimise tühjendanud, nii et konks, mis kasutab `sudo`, vajab oma autoriseerimist ja võib sinu parooli küsida.

Igas neist kaustadest on juba `.sample` fail, mis näitab konksu kuju — eemalda nimest `.sample`, et see tööle panna. Mujal kirjutatud skripti installimiseks kasuta käsku `omarchy hook install post-boot ~/my-hook`, mis kopeerib selle sisse ja teeb selle käivitatavaks.

### Oma menüükirjete lisamine

Omarchy menüüd (`Super + Space`) saab laiendada oma ridadega, muutes faili `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Kirjed on võtmetega varustatud punktidega eraldatud id järgi ja id paigutab need puusse, nii et `personal` ilmub juurmenüüsse ja `personal.notes` ilmub selle sisse:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Olemasoleva id uuesti kasutamine kirjutab selle rea üle, selle asemel et lisada uus. Failiga on kaasas kõik saadaolevad väljad, mis on dokumenteeritud kommentaaridena.

### Oma kesta eksportide, funktsioonide ja aliase lisamine

Omarchyga on kaasas hulk ergonoomilisi aliase ja kasulikke funktsioone, aga oma lisamine on väga tavaline soov. Peaksid lisama nii aliased, funktsioonid kui ka ekspordid faili `~/.bashrc`. Seda faili värskenduste ajal üle ei kirjutata. Kui soovid mõnda Omarchy vaikeväärtust muuta, võid ka need siia ohutult lisada.

### Keskkonnamuutujate seadmine töölaua jaoks

Töölauaseansi ekspordid kuuluvad kausta `~/.config/uwsm/env.d/`. Need failid käivitatakse enne töölaua käivitumist, nii et kesta viga võib su tagasi sisselogimisekraanile saata. Hoia nende muutmisel töötav terminal avatuna. Ülekirjutuse keelamiseks liiguta see kaustast `env.d` välja. Vaata [sisselogimise taastamine](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), kui muudatus takistab sisselogimist.

### Omarchy sisemiste failide muutmine

Kuule, see on sinu arvuti. Võid sellega teha, mida tahad, aga soovitaksin mitte muuta faile otse kaustas `/usr/share/omarchy`. Need kuuluvad Omarchy pacman paketti, nii et sinu muudatused kirjutatakse järgmisel värskendusel lihtsalt üle. Sul on parem kirjutada kõik vaikeväärtused, mis sulle ei meeldi, hoopis üle kaustas `~/.config/*`.

Nii saad muuta peaaegu kõike, näiteks vaikimisi klahviseoseid. Muuda lihtsalt faili `~/.config/hypr/bindings.lua`, et asendada näiteks [Obsidian](https://obsidian.md/) rakendusega [Joplin](https://joplinapp.org/) (installi käsuga `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` eemaldab olemasoleva seose enne selle asenduse lisamist. See võtab samad argumendid nagu `o.bind`, sealhulgas käivitusabilised ja seose valikud. Kasuta `o.bind` seose lisamiseks või `hl.unbind` seose eemaldamiseks ilma seda asendamata.

Kui nõuad sisemiste Omarchy failide häkkimist, vaheta arenduskanalile valiku _Update > Channel > Dev_ kaudu. See lingib Omarchy lähtekoodi git-väljavõttega kaustas `~/omarchy`, mida võid vabalt oma südame järgi muuta. Siin pole kedagi, kes sulle ütleks, mida teha!

### Kõigi muudatuste lähtestamine

Kui ajad seadistused lõpuks sassi, saad need alati vaikeväärtustele tagasi pöörata Omarchy menüü valiku _Update > Config_ kaudu. Või käivitades `omarchy reinstall configs`, et kõik lähtestada.
