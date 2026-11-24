# Dotfiles

Omarchy on peamiselt konfigureeritud nn dotfiles-failide kaudu, mis asuvad kaustas `~/.config`. Neid peetakse sinu failideks sinu muudatuste jaoks. Failid, mis asuvad kaustas `/usr/share/omarchy`, kuuluvad Omarchy enda juurde ja nendega ei peaks sa jamama. Kui sul on vaja midagi muuta kaustas `/usr/share/omarchy`, peaksid selle väärtuse hoopis kaustas `~/.config` alistama.

Peamisi konfiguratsioone saab redigeerida otse Omarchy menüüst (`Super + Space`), näiteks _Setup > Keyboard > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kui teed seda sel viisil, taaskäivitatakse iga protsess, mis vajab pärast konfiguratsiooni muudatusi taaskäivitamist, automaatselt pärast redaktorist väljumist (vaikimisi Neovim — `:wq`, pea meeles! — aga saad seda muuta valiku _Setup > Defaults > Editor_ kaudu).

Siin on loend peamistest failidest kaustas `~/.config` ja sellest, mida need juhivad:

| Fail | Eesmärk |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Peamine Hyprlandi konfiguratsioon. Laadib Omarchy vaikesätted pluss sinu allolevad alistusfailid. [Lisateave Hyprlandi konfiguratsioonide kohta](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Sinu enda klahviseosed ja vaikesätete alistused. |
| `~/.config/hypr/monitors.lua` | Monitori sätted, mida monitori paneel ei kata, näiteks pööramine, lisarežiimid või monitori väljalülitatuna hoidmine. |
| `~/.config/hypr/input.lua` | Juhib sinu klaviatuuripaigutust, hiire ja puuteplaadi sätteid. |
| `~/.config/hypr/looknfeel.lua` | Juhib vahesid, ääriseid, animatsioone ja ülejäänud välimust. |
| `~/.config/hypr/autostart.lua` | Juhib seansiga käivitatavaid lisaprotsesse. |
| `~/.config/omarchy/shell.json` | Juhib Omarchy shelli: riba asukohta, paigutust ja vidinaid, pluss ekraanisäästja, lukustuse ja jõudeoleku ajastusi. |
| `~/.config/foot/foot.ini` | Juhib sinu terminali (foot on vaikimisi). |
| `~/.XCompose` | Määrab sinu kiirpääsu emoji ja nime/e-posti automaatse täitmise. Pärast muudatuste tegemist käivita kindlasti `omarchy-restart-xcompose`. |

Kui teed lõpuks oma seadistuse kohandamiseks palju muudatusi, on hea mõte kõik need dotfiles-failid varundada. [Stow on selleks suurepärane viis](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Enda rakenduste käivitamine koos seansiga

Kui soovid, et midagi käivituks iga kord, kui sisse logid — sünkroonimisdeemon, vestlusrakendus, sinu enda skript —, pane see faili `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

See käivitab käsu seansi osana, nii et see puhastatakse korralikult ära, kui uuesti välja logid.

### Skriptide käitamine süsteemisündmuste korral

Omarchy käivitab mõnel hetkel hooke ja saad nende külge oma skripte riputada. Need asuvad kaustas `~/.config/omarchy/hooks/<event>.d/`, iga sündmuse jaoks üks kataloog, ja iga fail seal, mille nimi ei lõpe laiendiga `.sample`, käivitatakse sündmuse toimumisel bashiga:

| Sündmus | Millal see käivitub |
| ----- | ------------ |
| `post-boot` | Kohe pärast töölaua käivitumist |
| `post-update` | `omarchy update` lõpu lähedal, pärast pakette, migratsioone ja teenuste taaskäivitusi, enne mise tööriistade värskendamist |
| `pre-refresh-pacman` | Pärast seda, kui `omarchy refresh pacman` paketi konfiguratsiooni uuesti sünkroonib, enne pakettide värskendamist; kanali vahetus käivitab selle sama värskendussammu ajal |
| `theme-set` | Pärast teema vahetust (teema nimi asub muutujas `$1`) |
| `font-set` | Pärast fondi vahetust (fondi nimi asub muutujas `$1`) |
| `battery-low` | Kui aku hakkab tühjaks saama (protsent asub muutujas `$1`) |

Hook `pre-refresh-pacman` on koht, kuhu kuuluvad kohandatud repositooriumid või `IgnorePkg` read, kuna see käivitub enne paketi tehingut. Mõlemad käivituvad sinu kasutajana. `post-update` käivitub ajal, mil `omarchy update` sudo autoriseerimine on veel värske, nii et hook, mis kasutab käsku `sudo`, ei küsi sinu parooli uuesti; `pre-refresh-pacman` käivitub kohe pärast seda, kui `omarchy refresh pacman` on ise sudo't kasutanud.

Kõigis neis kataloogides on juba `.sample` fail, mis näitab hooki kuju — eemalda nimest `.sample`, et see tööle panna. Mujal kirjutatud skripti installimiseks kasuta käsku `omarchy hook install post-boot ~/my-hook`, mis kopeerib selle sisse ja teeb käivitatavaks.

### Enda menüükirjete lisamine

Omarchy menüüd (`Super + Space`) saab laiendada oma ridadega, redigeerides faili `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Kirjed on võtmestatud punktidega id-ga ja id paigutab need puusse, nii et `personal` ilmub juurmenüüsse ja `personal.notes` selle sisse:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Olemasoleva id uuesti kasutamisel alistad selle rea, selle asemel et lisada uus. Failiga on kaasas kõik saadaolevad väljad, dokumenteeritud kommentaaridena.

### Enda shelli ekspordide, funktsioonide ja aliaste lisamine

Omarchyga on kaasas hulk ergonoomilisi aliaseid ja kasulikke funktsioone, aga väga tavaline on tahta lisada oma omi. Nii aliased, funktsioonid kui ka ekspordid peaksid lisama faili `~/.bashrc`. Seda faili värskenduste ajal üle ei kirjutata. Kui soovid mõnda Omarchy vaikesätet muuta, saad need samuti siia turvaliselt lisada.

### Keskkonnamuutujate seadmine töölaua jaoks

Töölauaseansi ekspordid kuuluvad kausta `~/.config/uwsm/env.d/`. Need failid käivituvad enne töölaua käivitumist, nii et shelli viga võib su sisselogimiskuvale tagasi saata. Hoia nende redigeerimise ajal töötav terminal avatuna. Alistuse keelamiseks liiguta see kaustast `env.d` välja. Vaata [sisselogimise taastamist](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), kui muudatus takistab sisselogimist.

### Sisemiste Omarchy failide muutmine

Kuule, see on sinu arvuti. Võid sellega teha, mida iganes tahad, aga soovitaksin failides kaustas `/usr/share/omarchy` otse muudatusi mitte teha. Need kuuluvad Omarchy pacmani paketi juurde, nii et sinu muudatused kirjutatakse järgmise värskendusega lihtsalt üle. Sul on parem lihtsalt alistada kõik vaikesätted, mis sulle ei meeldi, hoopis kaustas `~/.config/*`.

Sel viisil saad muuta peaaegu kõike, näiteks vaikeklahviseoseid. Lihtsalt redigeeri faili `~/.config/hypr/bindings.lua`, et näiteks asendada [Obsidian](https://obsidian.md/) rakendusega [Joplin](https://joplinapp.org/) (installi käsuga `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` eemaldab olemasoleva seose enne selle asenduse lisamist. See võtab samu argumente mis `o.bind`, sealhulgas käivitusabivahendeid ja sidumisvalikuid. Seose lisamiseks kasuta käsku `o.bind` või seose eemaldamiseks ilma seda asendamata käsku `hl.unbind`.

Kui nõuad sisemiste Omarchy failide häkkimist, lülitu dev-kanalile valiku _Update > Channel > Dev_ kaudu. See seob Omarchy lähtekoodi git-väljatõmbega kaustas `~/omarchy`, mida võid vabalt oma südame rahuks muuta. Keegi siin ei ütle sulle, mida teha!

### Kõigi muudatuste lähtestamine

Kui teed konfiguratsioonides lõpuks segaduse, saad need alati vaikeväärtustele tagasi pöörata Omarchy menüüs valiku _Update > Config_ kaudu. Või käivitades kõike lähtestamiseks käsu `omarchy reinstall configs`.
