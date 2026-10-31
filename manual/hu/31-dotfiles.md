# Dotfiles

Az Omarchy elsősorban az úgynevezett dotfile-okon keresztül konfigurálható, amelyek a `~/.config` könyvtárban találhatók. Ezek a te fájljaidnak számítanak, a te módosításaidhoz. A `/usr/share/omarchy` könyvtárban lévő fájlok magához az Omarchyhoz tartoznak, és azokba nem kellene belenyúlnod. Ha valamit meg kell változtatnod a `/usr/share/omarchy` könyvtárban, ehelyett inkább a `~/.config` könyvtárban írd felül az értékét.

A legfontosabb konfigurációk közvetlenül az Omarchy menüből (`Super + Space`) szerkeszthetők, például _Setup > Keybindings_, _Setup > Input_ és _Setup > Config > [file]_. Ha így csinálod, minden folyamat, amelyet a konfiguráció szerkesztése után újra kell indítani, automatikusan újraindul, miután kiléptél a szerkesztőből (alapértelmezetten a Neovim — `:wq`, ne feledd! — de ezt megváltoztathatod a _Setup > Defaults > Editor_ menüpontban).

Íme a `~/.config` legfontosabb fájljainak listája, és hogy mit szabályoznak:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A fő Hyprland konfiguráció. Betölti az Omarchy alapértelmezéseit, plusz az alábbi felülíró fájljaidat. [Tudj meg többet a Hyprland konfigurációkról](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Saját billentyűkiosztásaid és az alapértelmezések felülírásai. |
| `~/.config/hypr/monitors.lua` | Azok a monitorbeállítások, amelyeket a monitorpanel nem fed le, például elforgatás, extra módok, vagy egy monitor kikapcsolva tartása. |
| `~/.config/hypr/input.lua` | A billentyűzetkiosztásodat, az egeredet és az érintőpadod beállításait szabályozza. |
| `~/.config/hypr/looknfeel.lua` | A hézagokat, szegélyeket, animációkat és a megjelenés többi részét szabályozza. |
| `~/.config/hypr/autostart.lua` | A munkamenettel indított extra folyamatokat szabályozza. |
| `~/.config/omarchy/shell.json` | Az Omarchy shellt szabályozza: a sáv helyzetét, elrendezését és widgetjeit, plusz a képernyővédő, a zárolás és a tétlenségi időzítéseket. |
| `~/.config/foot/foot.ini` | A terminálodat szabályozza (alapértelmezetten a foot). |
| `~/.XCompose` | A gyorselérésű emojijaidat és a név/e-mail automatikus kiegészítést határozza meg. A módosítások után mindenképp futtasd az `omarchy-restart-xcompose` parancsot. |

Ha végül sok módosítást végzel a saját beállításod finomhangolásához, jó ötlet biztonsági másolatot készíteni az összes ilyen dotfile-ról. [A Stow remek módja ennek](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Saját alkalmazásaid indítása a munkamenettel

Ha azt szeretnéd, hogy valami minden bejelentkezéskor fusson — egy szinkronizáló démon, egy csevegőalkalmazás, a saját szkripted — tedd be a `~/.config/hypr/autostart.lua` fájlba:

```lua
o.launch_on_start("my-service")
```

Ez a munkamenet részeként indítja el a parancsot, így kijelentkezéskor rendesen leáll.

### Szkriptek futtatása rendszereseményeken

Az Omarchy néhány pillanatban hookokat indít, amelyekre saját szkripteket akaszthatsz. Ezek a `~/.config/omarchy/hooks/<event>.d/` könyvtárban élnek, eseményenként egy könyvtárban, és minden ott lévő végrehajtható fájl lefut, amikor az esemény bekövetkezik:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Közvetlenül az asztali környezet elindulása után |
| `post-update` | Az `omarchy update` vége felé, a csomagok, migrációk és szolgáltatás-újraindítások után, a mise eszközök frissítése előtt |
| `pre-refresh-pacman` | Miután az `omarchy refresh pacman` újraszinkronizálja a csomagkonfigurációt, mielőtt frissítené a csomagokat; csatornaváltáskor ugyanebben a frissítési lépésben fut le |
| `theme-set` | Témaváltás után (a téma neve a `$1` értékben) |
| `font-set` | Betűtípus-váltás után (a betűtípus neve a `$1` értékben) |
| `battery-low` | Amikor az akkumulátor töltöttsége alacsony lesz (a százalék a `$1` értékben) |

A `pre-refresh-pacman` hook az a hely, ahová az egyéni tárolók vagy `IgnorePkg` sorok tartoznak, mivel a csomagtranzakció előtt fut. Mindkét frissítéssel kapcsolatos hook a te felhasználódként fut, miután az Omarchy törölte a gyorsítótárazott sudo jogosultságát, így egy `sudo` parancsot használó hooknak saját jogosultságra van szüksége, és kérheti a jelszavadat.

Ezen könyvtárak mindegyikében már van egy `.sample` fájl, amely megmutatja egy hook alakját — dobd el a `.sample` részt a névből, hogy munkára fogd. Egy máshol megírt szkript telepítéséhez használd az `omarchy hook install post-boot ~/my-hook` parancsot, amely bemásolja és végrehajthatóvá teszi.

### Saját menübejegyzések hozzáadása

Az Omarchy menü (`Super + Space`) bővíthető saját sorokkal a `~/.config/omarchy/extensions/omarchy-menu.jsonc` fájl szerkesztésével. A bejegyzések kulcsa egy pontokkal tagolt azonosító, és ez az azonosító helyezi el őket a fában, így a `personal` a gyökérmenüben jelenik meg, a `personal.notes` pedig azon belül:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Egy meglévő azonosító újrafelhasználásával az adott sort írod felül, ahelyett, hogy újat adnál hozzá. A fájl az összes elérhető mezőt dokumentáló megjegyzésekkel érkezik.

### Saját shell exportok, függvények és aliasok hozzáadása

Az Omarchy számos ergonomikus aliasszal és hasznos függvénnyel érkezik, de nagyon gyakori, hogy sajátokat szeretnél hozzáadni. Az aliasokat, függvényeket és exportokat egyaránt a `~/.bashrc` fájlba kell felvenned. Ezt a fájlt frissítésekkor nem írják felül. Ha bármelyik Omarchy alapértelmezést meg szeretnéd változtatni, azokat is biztonságosan hozzáadhatod ide.

### Belső Omarchy fájlok módosítása

Nézd, ez a te számítógéped. Azt csinálsz vele, amit akarsz, de azt tanácsolom, ne módosítsd közvetlenül a `/usr/share/omarchy` könyvtárban lévő fájlokat. Ezek az Omarchy pacman csomaghoz tartoznak, így a módosításaidat a következő frissítés egyszerűen felülírja. Jobban jársz, ha a nem tetsző alapértelmezett értékeket inkább a `~/.config/*` mappában írod felül.

Így szinte mindent megváltoztathatsz, például az alapértelmezett billentyűkiosztásokat. Csak szerkeszd a `~/.config/hypr/bindings.lua` fájlt, mondjuk, hogy az [Obsidian](https://obsidian.md/) alkalmazást a [Joplin](https://joplinapp.org/) alkalmazásra cseréld (telepítés: `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Az `o.rebind` eltávolítja a meglévő kiosztást, mielőtt hozzáadná a helyettesítését. Ugyanazokat az argumentumokat fogadja, mint az `o.bind`, beleértve az indító segédfüggvényeket és a kiosztási beállításokat. Használd az `o.bind` függvényt egy kiosztás hozzáadásához, vagy a `hl.unbind` függvényt egy kiosztás csere nélküli eltávolításához.

Ha ragaszkodsz a belső Omarchy fájlok hekkeléséhez, válts a dev csatornára az _Update > Channel > Dev_ menüpontban. Ez az Omarchy-t a forráskód egy git checkoutjához kapcsolja a `~/omarchy` könyvtárban, amelyet szabadon módosíthatsz, amennyire csak kedved tartja. Itt senki nem fogja megmondani, mit csinálj!

### Módosítások visszaállítása

Ha végül összekutyulod a konfigurációkat, bármikor visszaállíthatod őket az alapértelmezésekre az Omarchy menü _Update > Config_ menüpontjával. Vagy az `omarchy reinstall configs` parancs futtatásával mindent visszaállíthatsz.
