# Dotfile-ok

Az Omarchy elsősorban az úgynevezett dotfile-okon keresztül konfigurálható, amelyek a `~/.config` könyvtárban laknak. Ezek a te fájljaidnak számítanak, a te módosításaidhoz valóak. A `/usr/share/omarchy` alatt lévő fájlok magához az Omarchyhoz tartoznak, és ezekbe nem kellene belenyúlnod. Ha valamit meg kell változtatnod a `/usr/share/omarchy` alatt, akkor helyette a `~/.config` alatt kell felülírnod az értéket.

A legfontosabb konfigurációk közvetlenül az Omarchy menüből (`Super + Space`) szerkeszthetők, például a _Setup > Keybindings_, a _Setup > Input_ és a _Setup > Config > [file]_. Ha így csinálod, minden folyamat, amelyet a konfiguráció szerkesztése után újra kell indítani, automatikusan újraindul, miután kilépsz a szerkesztőből (alapértelmezés szerint a Neovim — `:wq`, ne feledd! — de ezt megváltoztathatod a _Setup > Defaults > Editor_ alatt).

Itt egy lista a `~/.config` legfontosabb fájljairól és arról, mit vezérelnek:

| Fájl                  | Cél              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A fő Hyprland-konfiguráció. Betölti az Omarchy alapértelmezéseit, plusz az alábbi felülíró fájljaidat. [Tudj meg többet a Hyprland-konfigurációkról](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | A saját billentyűkiosztásaid és az alapértelmezések felülírásai. |
| `~/.config/hypr/monitors.lua` | Azok a monitorbeállítások, amelyeket a monitorpanel nem fed le, például elforgatás, extra módok, vagy egy monitor kikapcsolva tartása. |
| `~/.config/hypr/input.lua` | A billentyűzetkiosztásodat, az egeret és az érintőpad beállításait vezérli. |
| `~/.config/hypr/looknfeel.lua` | A réseket, szegélyeket, animációkat és a megjelenés többi részét vezérli. |
| `~/.config/hypr/autostart.lua` | A munkamenettel együtt indított extra folyamatokat vezérli. |
| `~/.config/omarchy/shell.json` | Az Omarchy shellt vezérli: a sáv helyzetét, elrendezését és widgetjeit, plusz a képernyővédő, a zárolás és a tétlenségi időzítéseket. |
| `~/.config/foot/foot.ini` | A terminálodat vezérli (alapértelmezés szerint a foot). |
| `~/.XCompose` | A gyorselérésű emojikat és a név/e-mail automatikus kiegészítést határozza meg. A módosítások után mindenképp futtasd az `omarchy-restart-xcompose` parancsot. |

Ha végül sok módosítást végzel a saját beállításod finomhangolásához, jó ötlet biztonsági másolatot készíteni az összes ilyen dotfile-ról. [A Stow nagyszerű módja ennek](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### A saját alkalmazásaid indítása a munkamenettel

Ha azt akarod, hogy valami minden bejelentkezéskor fusson — egy szinkronizáló démon, egy csevegőalkalmazás, a saját szkripted — tedd be a `~/.config/hypr/autostart.lua` fájlba:

```lua
o.launch_on_start("my-service")
```

Ez a munkamenet részeként indítja el a parancsot, így kijelentkezéskor rendesen leáll.

### Szkriptek futtatása rendszereseményekre

Az Omarchy néhány pillanatban hookokat indít, és ezekre akaszthatod a saját szkriptjeidet. Ezek a `~/.config/omarchy/hooks/<event>.d/` alatt laknak, eseményenként egy könyvtárban, és minden ott lévő végrehajtható fájl lefut, amikor az esemény bekövetkezik:

| Esemény | Mikor fut |
| ----- | ------------ |
| `post-boot` | Közvetlenül az asztal elindulása után |
| `post-update` | Az `omarchy update` vége felé, a csomagok, a migrációk és a szolgáltatás-újraindítások után, a mise eszközök frissítése előtt |
| `pre-refresh-pacman` | Miután az `omarchy refresh pacman` újraszinkronizálja a csomagkonfigurációt, mielőtt frissítené a csomagokat; csatornaváltáskor ugyanezen frissítési lépés során fut |
| `theme-set` | Témaváltás után (a téma neve a `$1`-ben) |
| `font-set` | Betűtípusváltás után (a betűtípus neve a `$1`-ben) |
| `battery-low` | Amikor az akkumulátor töltöttsége alacsony lesz (a százalék a `$1`-ben) |

A `pre-refresh-pacman` hook az a hely, ahová az egyéni tárolók vagy `IgnorePkg` sorok valók, mivel a csomagtranzakció előtt fut. Mindkét frissítéshez kapcsolódó hook a te felhasználódként fut, miután az Omarchy törli a gyorsítótárazott sudo jogosultságát, így egy `sudo`-t használó hooknak saját jogosultságra van szüksége, és kérheti a jelszavadat.

E könyvtárak mindegyikében már van egy `.sample` fájl, amely megmutatja egy hook formáját — vedd le a `.sample` részt a névről, hogy működésbe hozd. Egy máshol megírt szkript telepítéséhez használd az `omarchy hook install post-boot ~/my-hook` parancsot, amely bemásolja és végrehajthatóvá teszi.

### Saját menübejegyzések hozzáadása

Az Omarchy menü (`Super + Space`) bővíthető saját sorokkal a `~/.config/omarchy/extensions/omarchy-menu.jsonc` szerkesztésével. A bejegyzések kulcsa egy pontokkal tagolt azonosító, és az azonosító helyezi el őket a fában, így a `personal` a gyökérmenüben jelenik meg, a `personal.notes` pedig azon belül:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Egy meglévő azonosító újrafelhasználásával felülírod az adott sort, ahelyett hogy újat adnál hozzá. A fájl az összes elérhető mezőt megjegyzések formájában dokumentálva tartalmazza.

### Saját shell exportok, függvények és aliasok hozzáadása

Az Omarchy egy csomó ergonomikus aliasszal és hasznos függvénnyel érkezik, de nagyon gyakori, hogy az ember sajátokat akar hozzáadni. Az aliasokat, függvényeket és exportokat is a `~/.bashrc` fájlba kell beírnod. Ezt a fájlt a frissítések nem írják felül. Ha bármelyik Omarchy-alapértelmezést meg akarod változtatni, azokat is nyugodtan ide veheted fel.

### Környezeti változók beállítása az asztalhoz

Az asztali munkamenet exportjai a `~/.config/uwsm/env.d/` alá tartoznak. Ezek a fájlok az asztalod indulása előtt futnak, így egy shellhiba visszadobhat a bejelentkezési képernyőre. Szerkesztés közben tarts nyitva egy működő terminált. Egy felülírás letiltásához mozdítsd ki az `env.d` könyvtárból. Lásd a [bejelentkezési helyreállítás](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) részt, ha egy módosítás megakadályozza a bejelentkezést.

### A belső Omarchy-fájlok módosítása

Nézd, ez a te számítógéped. Azt csinálsz vele, amit akarsz, de azt tanácsolnám, ne módosítsd közvetlenül a `/usr/share/omarchy` fájljait. Ezek az Omarchy pacman csomaghoz tartoznak, így a módosításaidat a következő frissítés egyszerűen felülírja. Jobban jársz, ha helyette csak felülírod a `~/.config/*` mappában azokat az alapértelmezett értékeket, amelyek nem tetszenek.

Így nagyjából mindent megváltoztathatsz, például az alapértelmezett billentyűkiosztásokat. Csak szerkeszd a `~/.config/hypr/bindings.lua` fájlt, hogy mondjuk lecseréld az [Obsidian](https://obsidian.md/) alkalmazást a [Joplin](https://joplinapp.org/) alkalmazásra (telepítés: `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Az `o.rebind` eltávolítja a meglévő kiosztást, mielőtt hozzáadná a helyettesítőjét. Ugyanazokat az argumentumokat fogadja, mint az `o.bind`, beleértve az indító segédfüggvényeket és a kiosztási opciókat is. Használd az `o.bind` parancsot egy kiosztás hozzáadásához, vagy a `hl.unbind` parancsot egy kiosztás eltávolításához anélkül, hogy lecserélnéd.

Ha ragaszkodsz hozzá, hogy a belső Omarchy-fájlokban turkálj, válts a dev csatornára az _Update > Channel > Dev_ alatt. Ez összekapcsolja az Omarchyt a forráskód egy git checkoutjával a `~/omarchy` könyvtárban, amelyet kedvedre módosíthatsz. Itt senki nem fogja megmondani neked, mit csinálj!

### Bármely módosítás visszaállítása

Ha végül összekutyulod a konfigurációkat, bármikor visszaállíthatod őket az alapértelmezésekre az Omarchy menü _Update > Config_ pontján keresztül. Vagy az `omarchy reinstall configs` futtatásával mindent visszaállíthatsz.
