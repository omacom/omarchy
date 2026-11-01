# Dotfiles

Omarchy on peamiselt seadistatud nn dotfile'ide kaudu, mis asuvad kaustas `~/.config`. Neid peetakse sinu failideks sinu muudatuste jaoks. Kaustas `/usr/share/omarchy` asuvad failid kuuluvad Omarchy enda juurde ja sa ei peaks nendega jamama. Kui sul on vaja midagi kaustas `/usr/share/omarchy` muuta, peaksid selle väärtuse hoopis kaustas `~/.config` üle kirjutama.

Põhiseadeid saab muuta otse Omarchy menüüst (`Super + Space`), näiteks _Setup > Keyboard > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kui teed seda nii, käivitatakse iga protsess, mis tuleb pärast seadete muutmist taaskäivitada, automaatselt uuesti, kui oled redaktorist väljunud (vaikimisi Neovim — `:wq`, pane meelde! — aga saad seda muuta valiku _Setup > Defaults > Editor_ kaudu).

Siin on loend kausta `~/.config` põhifailidest ja sellest, mida need juhivad:

| Fail                  | Otstarve              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Peamine Hyprland konfiguratsioon. Laadib Omarchy vaikeväärtused ja lisaks sinu alltoodud ülekirjutusfailid. [Lisateave Hyprland konfiguratsioonide kohta](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Sinu enda klahviseosed ja vaikeväärtuste ülekirjutused. |
| `~/.config/hypr/monitors.lua` | Monitori seaded, mida monitori paneel ei kata, näiteks pööramine, lisarežiimid või monitori väljalülitatuna hoidmine. |
| `~/.config/hypr/input.lua` | Juhib sinu klaviatuuripaigutust, hiire ja puuteplaadi seadeid. |
| `~/.config/hypr/looknfeel.lua` | Juhib vahesid, ääriseid, animatsioone ja ülejäänud välimust. |
| `~/.config/hypr/autostart.lua` | Juhib seansiga koos käivitatavaid lisaprotsesse. |
| `~/.config/omarchy/shell.json` | Juhib Omarchy shelli: riba asukohta, paigutust ja vidinaid, lisaks ekraanisäästja, lukustamise ja jõudeoleku ajastusi. |
| `~/.config/foot/foot.ini` | Juhib sinu terminali (foot on vaikeseade). |
| `~/.XCompose` | Määrab sinu kiire juurdepääsu emotikonid ning nime/e-posti automaatse täitmise. Pärast muudatuste tegemist käivita kindlasti `omarchy-restart-xcompose`. |

Kui teed lõpuks oma seadistuse kohandamiseks palju muudatusi, on hea mõte kõik need dotfile'id varundada. [Stow on selleks suurepärane võimalus](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Oma rakenduste käivitamine koos seansiga

Kui soovid, et midagi töötaks iga kord, kui sisse logid — sünkroonimisdeemon, vestlusrakendus, sinu enda skript — pane see faili `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

See käivitab käsu seansi osana, nii et välja logides koristatakse see korralikult ära.

### Skriptide käitamine süsteemisündmuste korral

Omarchy vallandab hook'id käputäiel juhtudel ja saad nende külge oma skripte riputada. Need asuvad kaustas `~/.config/omarchy/hooks/<event>.d/`, iga sündmuse jaoks üks kataloog, ja iga seal asuv käivitatav fail käivitatakse sündmuse toimumisel:

| Sündmus | Millal see käivitatakse |
| ----- | ------------ |
| `post-boot` | Kohe pärast töölaua käivitumist |
| `post-update` | Käskluse `omarchy update` lõpu lähedal, pärast pakette, migratsioone ja teenuste taaskäivitusi, enne mise tööriistade värskendamist |
| `pre-refresh-pacman` | Pärast seda, kui `omarchy refresh pacman` pakettide konfiguratsiooni uuesti sünkroonib, enne pakettide värskendamist; kanali vahetus käivitab selle sama värskendussammu ajal |
| `theme-set` | Pärast teema muutmist (teema nimi on `$1`) |
| `font-set` | Pärast fondi muutmist (fondi nimi on `$1`) |
| `battery-low` | Kui aku hakkab tühjaks saama (protsent on `$1`) |

Hook `pre-refresh-pacman` on koht, kuhu kuuluvad kohandatud hoidlad või `IgnorePkg` read, sest see käivitatakse enne paketitehingut. Mõlemad värskendamisega seotud hook'id käivitatakse sinu kasutajana pärast seda, kui Omarchy on oma vahemällu salvestatud sudo autoriseerimise tühjendanud, seega vajab `sudo` käsku kasutav hook oma autoriseerimist ja võib sinu parooli küsida.

Kõigis neis kataloogides on juba `.sample` fail, mis näitab hook'i kuju — eemalda nimest `.sample`, et see tööle panna. Enda mujal kirjutatud skripti installimiseks kasuta käsku `omarchy hook install post-boot ~/my-hook`, mis kopeerib selle sisse ja muudab käivitatavaks.

### Oma menüükirjete lisamine

Omarchy menüüd (`Super + Space`) saab laiendada oma ridadega, muutes faili `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Kirjed on võtmetega varustatud punktidega id abil ja id määrab nende koha puus, nii et `personal` kuvatakse juurmenüüs ja `personal.notes` selle sees:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Olemasoleva id taaskasutamisel kirjutad selle rea uue lisamise asemel üle. Failiga on kaasas kõik saadaolevad väljad, mis on kommentaaridena dokumenteeritud.

### Oma shelli eksportide, funktsioonide ja aliase lisamine

Omarchyga on kaasas hulk ergonoomilisi aliaseid ja kasulikke funktsioone, kuid väga tavaline on soov lisada oma. Aliased, funktsioonid ja ekspordid peaksid lisama faili `~/.bashrc`. Seda faili värskenduste ajal üle ei kirjutata. Kui soovid mõnda Omarchy vaikeväärtust muuta, saad need ka siia ohutult lisada.

### Töölaua keskkonnamuutujate määramine

Töölauaseansi ekspordid kuuluvad kausta `~/.config/uwsm/env.d/`. Need failid käivitatakse enne töölaua käivitumist, nii et shelli viga võib sind sisselogimisekraanile tagasi saata. Hoia nende muutmise ajal töötav terminal avatuna. Ülekirjutuse keelamiseks vii see kaustast `env.d` välja. Vaata [sisselogimise taastamine](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), kui muudatus takistab sisselogimist.

### Sisemiste Omarchy failide muutmine

Kuule, see on sinu arvuti. Võid sellega teha, mida iganes soovid, aga soovitaksin sul kaustas `/usr/share/omarchy` asuvaid faile otse mitte muuta. Need kuuluvad Omarchy pacmani paketi juurde, nii et sinu muudatused kirjutatakse järgmise värskenduse ajal lihtsalt üle. Sul on parem hoopis kõik vaikeväärtused, mis sulle ei meeldi, kaustas `~/.config/*` üle kirjutada.

Nii saad muuta peaaegu kõike, näiteks vaikeklahviseoseid. Muuda lihtsalt faili `~/.config/hypr/bindings.lua`, et näiteks asendada [Obsidian](https://obsidian.md/) rakendusega [Joplin](https://joplinapp.org/) (installi käsuga `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` eemaldab olemasoleva seose enne selle asenduse lisamist. See võtab samad argumendid mis `o.bind`, sealhulgas käivitusabilised ja seose valikud. Seose lisamiseks kasuta käsku `o.bind` või selle eemaldamiseks ilma asendamata käsku `hl.unbind`.

Kui nõuad sisemiste Omarchy failidega häkkimist, lülitu dev-kanalile valiku _Update > Channel > Dev_ kaudu. See seob Omarchy lähtekoodi git-checkout'iga kaustas `~/omarchy`, mida võid vabalt oma südame järgi muuta. Siin ei keela sind keegi!

### Kõigi muudatuste lähtestamine

Kui ajad konfiguratsioonid lõpuks sassi, saad need alati Omarchy menüü valiku _Update > Config_ kaudu vaikeväärtustele tagasi keerata. Või käivitades käsu `omarchy reinstall configs`, et kõik lähtestada.
