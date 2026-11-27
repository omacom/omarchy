# Dotfiles

Az Omarchy elsősorban az úgynevezett dotfile-okon keresztül konfigurálható, amelyek a `~/.config` mappában találhatók. Ezek a te fájljaidnak számítanak, a te módosításaidhoz. A `/usr/share/omarchy` mappában található fájlok magához az Omarchyhoz tartoznak, és azokba nem kellene belenyúlnod. Ha valamit meg kell változtatnod a `/usr/share/omarchy` mappában, ehelyett a `~/.config` mappában kellene felülírnod az értéket.

A legfontosabb konfigurációk közvetlenül az Omarchy menüből (`Super + Space`) szerkeszthetők, például a _Setup > Keyboard > Keybindings_, a _Setup > Input_ és a _Setup > Config > [file]_. Ha így csinálod, minden folyamat, amelyet a konfiguráció módosítása után újra kell indítani, automatikusan újraindul, miután kilépsz a szerkesztőből (alapértelmezés szerint a Neovim — `:wq`, ne feledd! —, de ezt a _Setup > Defaults > Editor_ útvonalon megváltoztathatod).

Íme a `~/.config` legfontosabb fájljainak listája, és hogy mit vezérelnek:

| Fájl | Cél |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A fő Hyprland-konfiguráció. Betölti az Omarchy alapértelmezéseit, plusz az alábbi felülíró fájljaidat. [Tudj meg többet a Hyprland-konfigurációkról](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | A saját billentyűkiosztásaid és az alapértelmezettek felülírásai. |
| `~/.config/hypr/monitors.lua` | Monitorbeállítások, amelyeket a monitorpanel nem fed le, például elforgatás, extra módok, vagy egy monitor kikapcsolva tartása. |
| `~/.config/hypr/input.lua` | A billentyűzetkiosztásodat, az egeredet és az érintőpad-beállításaidat vezérli. |
| `~/.config/hypr/looknfeel.lua` | A réseket, a kereteket, az animációkat és a megjelenés többi részét vezérli. |
| `~/.config/hypr/autostart.lua` | A munkamenettel együtt indított extra folyamatokat vezérli. |
| `~/.config/omarchy/shell.json` | Az Omarchy shellt vezérli: a sáv pozícióját, elrendezését és widgetjeit, plusz a képernyővédő, a zárolás és a tétlenségi időzítéseket. |
| `~/.config/foot/foot.ini` | A terminálodat vezérli (alapértelmezés szerint a foot). |
| `~/.XCompose` | A gyors elérésű emojikat és a név/e-mail automatikus kiegészítést határozza meg. A módosítások után mindenképp futtasd az `omarchy-restart-xcompose` parancsot. |

Ha végül sok módosítást végzel a saját beállításaid finomhangolásához, jó ötlet biztonsági másolatot készíteni ezekről a dotfile-okról. [A Stow remek módja ennek](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Saját alkalmazásaid indítása a munkamenettel

Ha azt szeretnéd, hogy valami minden bejelentkezéskor fusson — egy szinkronizáló démon, egy csevegőalkalmazás, a saját szkripted —, tedd a `~/.config/hypr/autostart.lua` fájlba:

```lua
o.launch_on_start("my-service")
```

Ez a munkamenet részeként indítja el a parancsot, így kijelentkezéskor megfelelően leáll.

### Szkriptek futtatása rendszereseményekre

Az Omarchy néhány pillanatban hookokat indít, és ezekre akaszthatod a saját szkriptjeidet. Ezek a `~/.config/omarchy/hooks/<event>.d/` mappában találhatók, eseményenként egy-egy könyvtárban, és az ott található minden fájl, amely nem `.sample` végződésű, bash-sel lefut, amikor az esemény bekövetkezik:

| Esemény | Mikor fut |
| ----- | ------------ |
| `post-boot` | Közvetlenül az asztal elindulása után |
| `post-update` | Az `omarchy update` vége felé, a csomagok, a migrációk és a szolgáltatások újraindítása után, a mise eszközök frissítése előtt |
| `pre-refresh-pacman` | Miután az `omarchy refresh pacman` újraszinkronizálja a csomagkonfigurációt, mielőtt frissítené a csomagokat; csatornaváltáskor ugyanabban a frissítési lépésben fut le |
| `theme-set` | Témaváltás után (a téma neve a `$1` paraméterben) |
| `font-set` | Betűtípus-váltás után (a betűtípus neve a `$1` paraméterben) |
| `battery-low` | Amikor az akkumulátor töltöttsége alacsony (a százalék a `$1` paraméterben) |

A `pre-refresh-pacman` hook az a hely, ahová az egyéni tárolóknak vagy `IgnorePkg` soroknak kerülniük kell, mivel a csomagtranzakció előtt fut. Mindkettő a te felhasználódként fut. A `post-update` akkor fut, amikor az `omarchy update` sudo jogosultsága még érvényes, így egy `sudo` parancsot használó hook nem fogja újra kérni a jelszavadat; a `pre-refresh-pacman` közvetlenül azután fut, hogy az `omarchy refresh pacman` maga használta a sudo-t.

Mindegyik ilyen könyvtárban már van egy `.sample` fájl, amely megmutatja egy hook formáját — vedd le a `.sample` részt a névből, hogy munkára fogd. Egy máshol megírt szkript telepítéséhez használd az `omarchy hook install post-boot ~/my-hook` parancsot, amely bemásolja és futtathatóvá teszi.

### Saját menübejegyzések hozzáadása

Az Omarchy menü (`Super + Space`) bővíthető saját sorokkal a `~/.config/omarchy/extensions/omarchy-menu.jsonc` szerkesztésével. A bejegyzések kulcsa egy pontokkal tagolt id, és az id helyezi el őket a fában, így a `personal` a gyökérmenüben jelenik meg, a `personal.notes` pedig azon belül:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ha egy meglévő id-t használsz újra, az adott sort írod felül, ahelyett, hogy újat adnál hozzá. A fájl az összes elérhető mezőt dokumentáló megjegyzésekkel érkezik.

### Saját shell exportok, függvények és aliasok hozzáadása

Az Omarchy egy csomó ergonomikus aliasszal és hasznos függvénnyel érkezik, de nagyon gyakori, hogy az ember sajátokat szeretne hozzáadni. Az aliasokat, a függvényeket és az exportokat egyaránt a `~/.bashrc` fájlba kell felvenned. Ezt a fájlt frissítésekkor nem írják felül. Ha az Omarchy alapértelmezései közül bármelyiket meg szeretnéd változtatni, azokat is nyugodtan felveheted ide.

### Környezeti változók beállítása az asztalhoz

Az asztali munkamenet exportjai a `~/.config/uwsm/env.d/` mappába tartoznak. Ezek a fájlok az asztal indulása előtt futnak le, így egy shellhiba visszadobhat a bejelentkezési képernyőre. Szerkesztésük közben tarts nyitva egy működő terminált. Egy felülírás letiltásához mozgasd ki az `env.d` mappából. Lásd a [bejelentkezési helyreállítást](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), ha egy módosítás megakadályozza a bejelentkezést.

### Belső Omarchy-fájlok módosítása

Nézd, ez a te számítógéped. Azt csinálsz vele, amit csak akarsz, de azt tanácsolom, ne módosítsd közvetlenül a `/usr/share/omarchy` mappában lévő fájlokat. Ezek az Omarchy pacman csomaghoz tartoznak, így a módosításaidat a következő frissítés egyszerűen felülírja. Jobban jársz, ha a nem tetsző alapértelmezett értékeket inkább a `~/.config/*` mappában írod felül.

Így szinte mindent megváltoztathatsz, például az alapértelmezett billentyűkiosztásokat. Csak szerkeszd a `~/.config/hypr/bindings.lua` fájlt, hogy mondjuk lecseréld az [Obsidian](https://obsidian.md/) alkalmazást a [Joplin](https://joplinapp.org/) alkalmazásra (telepítés ezzel: `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Az `o.rebind` eltávolítja a meglévő kiosztást, mielőtt hozzáadná a helyettesítését. Ugyanazokat az argumentumokat fogadja, mint az `o.bind`, beleértve az indító segédfüggvényeket és a kiosztási beállításokat is. Új kiosztás hozzáadásához használd az `o.bind` függvényt, vagy az `hl.unbind` függvényt, ha helyettesítés nélkül szeretnél eltávolítani egyet.

Ha ragaszkodsz a belső Omarchy-fájlok piszkálásához, válts a dev csatornára az _Update > Channel > Dev_ útvonalon. Ez az Omarchyt a forráskód egy git checkoutjához kapcsolja a `~/omarchy` mappában, amelyet szabadon módosíthatsz, amennyire csak szeretnéd. Itt aztán senki nem mondja meg neked, mit csinálj!

### Módosítások visszaállítása

Ha végül összezavarod a konfigurációkat, bármikor visszaállíthatod őket az alapértelmezettekre az Omarchy menü _Update > Config_ pontján keresztül. Vagy az `omarchy reinstall configs` futtatásával mindent visszaállíthatsz.
