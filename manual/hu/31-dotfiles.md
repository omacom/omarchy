# Dotfiles

Az Omarchy elsősorban az úgynevezett dotfile-okon keresztül konfigurálható, amelyek a `~/.config` alatt találhatók. Ezek a te fájljaidnak számítanak, a saját módosításaidhoz. A `/usr/share/omarchy` alatt található fájlok magához az Omarchyhoz tartoznak, és azokba nem kellene belenyúlnod. Ha valamit a `/usr/share/omarchy` alatt kellene megváltoztatnod, ehelyett a `~/.config` alatt kell felülírnod az értéket.

A legfontosabb konfigurációk közvetlenül az Omarchy menüből (`Super + Space`) szerkeszthetők, például a _Setup > Keyboard > Keybindings_, a _Setup > Input_ és a _Setup > Config > [file]_. Ha így jársz el, minden olyan folyamat, amelyet a konfiguráció szerkesztése után újra kell indítani, automatikusan újraindul, miután kilépsz a szerkesztőből (alapértelmezés szerint a Neovim — `:wq`, ne feledd! — de ezt a _Setup > Defaults > Editor_ alatt megváltoztathatod).

Íme a `~/.config` legfontosabb fájljainak listája, és hogy mit vezérelnek:

| Fájl                  | Rendeltetés              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A fő Hyprland-konfiguráció. Betölti az Omarchy alapértelmezéseit és az alábbi felülíró fájljaidat. [További információ a Hyprland-konfigurációkról](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | A saját billentyűkiosztásaid és az alapértelmezések felülírásai. |
| `~/.config/hypr/monitors.lua` | Olyan monitorbeállítások, amelyeket a monitorpanel nem fed le, például elforgatás, extra módok, vagy egy monitor kikapcsolva tartása. |
| `~/.config/hypr/input.lua` | A billentyűzetkiosztást, az egeret és az érintőpad beállításait vezérli. |
| `~/.config/hypr/looknfeel.lua` | A réseket, kereteket, animációkat és a megjelenés többi részét vezérli. |
| `~/.config/hypr/autostart.lua` | A munkamenettel együtt indított további folyamatokat vezérli. |
| `~/.config/omarchy/shell.json` | Az Omarchy shellt vezérli: a sáv helyzetét, elrendezését és widgetjeit, valamint a képernyővédő, a zárolás és a tétlenségi időzítéseket. |
| `~/.config/foot/foot.ini` | A terminálodat vezérli (alapértelmezés szerint a foot). |
| `~/.XCompose` | A gyors elérést biztosító emojikat és a név/e-mail automatikus kiegészítést határozza meg. A módosítások után mindenképpen futtasd az `omarchy-restart-xcompose` parancsot. |

Ha végül sok változtatást végzel a saját beállításod finomhangolásához, érdemes biztonsági másolatot készítened az összes ilyen dotfile-ról. [A Stow nagyszerű módja ennek](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Saját alkalmazások indítása a munkamenettel

Ha azt szeretnéd, hogy valami minden bejelentkezéskor fusson — egy szinkronizálódémon, egy csevegőalkalmazás, a saját scripted — tedd a `~/.config/hypr/autostart.lua` fájlba:

```lua
o.launch_on_start("my-service")
```

Ez a munkamenet részeként indítja el a parancsot, így kijelentkezéskor megfelelően le is áll.

### Scriptek futtatása rendszereseményekkor

Az Omarchy néhány pillanatban hookokat indít, amelyekre a saját scriptjeidet is ráakaszthatod. Ezek a `~/.config/omarchy/hooks/<event>.d/` alatt találhatók, eseményenként egy könyvtárban, és az ott lévő minden futtatható fájl lefut, amikor az esemény bekövetkezik:

| Esemény | Mikor fut |
| ----- | ------------ |
| `post-boot` | Közvetlenül az asztal elindulása után |
| `post-update` | Az `omarchy update` vége felé, a csomagok, migrációk és szolgáltatás-újraindítások után, mielőtt a mise eszközei frissülnének |
| `pre-refresh-pacman` | Miután az `omarchy refresh pacman` újraszinkronizálja a csomagkonfigurációt, mielőtt frissítené a csomagokat; csatornaváltáskor ugyanezen frissítési lépés során fut |
| `theme-set` | Témaváltás után (a téma neve a `$1` értékében) |
| `font-set` | Betűtípusváltás után (a betűtípus neve a `$1` értékében) |
| `battery-low` | Amikor az akkumulátor töltöttsége alacsony lesz (a százalék a `$1` értékében) |

A `pre-refresh-pacman` hook az a hely, ahová az egyéni tárolók vagy `IgnorePkg` sorok valók, mivel a csomagtranzakció előtt fut. Mindkét frissítéssel kapcsolatos hook a te felhasználódként fut, miután az Omarchy törli a gyorsítótárazott sudo-jogosultságát, ezért egy `sudo` parancsot használó hooknak saját jogosultságra van szüksége, és elkérheti a jelszavadat.

Ezeknek a könyvtáraknak mindegyikében már van egy `.sample` fájl, amely megmutatja egy hook alakját — hagyd el a `.sample` részt a nevéből, hogy működésbe hozd. Egy máshol megírt script telepítéséhez használd az `omarchy hook install post-boot ~/my-hook` parancsot, amely bemásolja és futtathatóvá teszi.

### Saját menübejegyzések hozzáadása

Az Omarchy menü (`Super + Space`) bővíthető saját sorokkal a `~/.config/omarchy/extensions/omarchy-menu.jsonc` szerkesztésével. A bejegyzések kulcsa egy pontos azonosító, és ez az azonosító helyezi el őket a fában, így a `personal` a gyökérmenüben jelenik meg, a `personal.notes` pedig azon belül:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Egy meglévő azonosító újrafelhasználásával új sor hozzáadása helyett felülírod azt a sort. A fájl az összes elérhető mezőt dokumentáló megjegyzésekkel érkezik.

### Saját shell-exportok, függvények és aliasok hozzáadása

Az Omarchy egy csomó ergonomikus aliasszal és hasznos függvénnyel érkezik, de nagyon gyakori, hogy az ember sajátokat is szeretne hozzáadni. Az aliasokat, függvényeket és exportokat is a `~/.bashrc` fájlba érdemes hozzáadnod. Ez a fájl frissítésekkor nem íródik felül. Ha az Omarchy bármelyik alapértelmezését meg szeretnéd változtatni, azokat is nyugodtan hozzáadhatod ide.

### Környezeti változók beállítása az asztali környezethez

Az asztali munkamenet exportjai a `~/.config/uwsm/env.d/` alá valók. Ezek a fájlok az asztal elindulása előtt futnak, így egy shellhiba visszadobhat a bejelentkezési képernyőre. Szerkesztés közben tarts nyitva egy működő terminált. Egy felülírás letiltásához helyezd ki az `env.d` könyvtárból. Ha egy változtatás megakadályozza a bejelentkezést, lásd a [bejelentkezés helyreállítása](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) részt.

### Az Omarchy belső fájljainak módosítása

Nézd, ez a te számítógéped. Azt csinálsz vele, amit akarsz, de azt tanácsolnám, ne módosítsd közvetlenül a `/usr/share/omarchy` fájljait. Ezek az Omarchy pacman-csomaghoz tartoznak, így a változtatásaid a következő frissítéskor egyszerűen felülíródnak. Jobban jársz, ha ehelyett a `~/.config/*` mappában írod felül azokat az alapértelmezett értékeket, amelyek nem tetszenek.

Így szinte mindent megváltoztathatsz, például az alapértelmezett billentyűkiosztásokat is. Csak szerkeszd a `~/.config/hypr/bindings.lua` fájlt, hogy mondjuk lecseréld az [Obsidian](https://obsidian.md/) alkalmazást a [Joplin](https://joplinapp.org/) alkalmazásra (telepítés az `omarchy-pkg-add joplin-bin` paranccsal):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` eltávolítja a meglévő kiosztást, mielőtt hozzáadná a helyettesítését. Ugyanazokat az argumentumokat fogadja, mint az `o.bind`, beleértve az indító segédfüggvényeket és a kiosztási beállításokat is. Használd az `o.bind` parancsot kiosztás hozzáadásához, vagy a `hl.unbind` parancsot egy kiosztás helyettesítés nélküli eltávolításához.

Ha ragaszkodsz az Omarchy belső fájljainak bütyköléséhez, válts a dev csatornára az _Update > Channel > Dev_ alatt. Ez összekapcsolja az Omarchyt a forráskód egy git-checkoutjával a `~/omarchy` alatt, amelyet kedvedre változtathatsz. Itt senki nem fogja megmondani neked, mit csinálj!

### Változtatások visszaállítása

Ha végül összekutyulod a konfigurációkat, az Omarchy menü _Update > Config_ pontján keresztül bármikor visszaállíthatod őket az alapértelmezésekre. Vagy az `omarchy reinstall configs` futtatásával mindent visszaállíthatsz.
