# Shell-bővítmények

Az Omarchy asztal egyetlen hosszú életű Quickshell-folyamatként fut, az `omarchy-shell` néven, és szinte minden, amit a képernyőn látsz, annak egy bővítménye. A sáv bővítmény. Ugyanúgy a róla lenyíló panelek, a teljes képernyős rátakarások, mint az emoji-választó és a vágólapkezelő, az Omarchy menü maga, a zárolási képernyő, a polkit párbeszédablaka és a fejnélküli szolgáltatások, amelyek figyelik az akkumulátorod, és éjszaka felmelegítik a képernyődet.

Ez nem csak egy implementációs részlet. Ez azt jelenti, hogy az asztal egyes részeit kikapcsolhatod, kicserélheted, vagy írhatsz sajátokat, anélkül, hogy az Omarchy forráskódjának egyetlen sorát is megérintenéd.

Az első fél bővítményei az Omarchyval érkeznek, és a `$OMARCHY_PATH/shell/plugins/` helyen élnek. Bármi, amit magad adsz hozzá — saját kísérleteid, vagy valami, amit a GitHubon találtál — a `~/.config/omarchy/plugins/` helyen él. Mindkettő ugyanazon a módon fedeződik fel induláskor, de a beépítettek megbízható shell-felületeket kapnak, míg a harmadik felek korlátozott felületet kapnak, saját szolgáltatásuk és életciklusuk megkötve. A beépítettek klónjai csak az eredeti viselkedéshez szükséges forrásspecifikus konfigurációt és felületi hívásokat őrzik meg.

## Megnézni, hogy mi van

```
omarchy plugin list
```

Ez kiír minden felismert bővítményt azonosítójával, azzal együtt, hogy engedélyezett-e, első vagy harmadik fél, típusaival és megjelenítési nevével. Add hozzá a `--json` lehetőséget, ha valami másnak eteted.

A bővítmény-azonosítók névtérbe tartoznak. A beépítettek mindegyike `omarchy.` előtaggal kezdődik — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` —, és ez a névtér fenntartott, így harmadik fél bővítménye soha nem követelheti magának.

## Be- és kikapcsolásuk

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Vagy használd a menüt: a _Setup > Plugins_ menüpontban van Enable, Disable, Add, Clone és Remove, mindegyik olyan választóval, amely csak az akcióhoz értelmes bővítményeket kínálja.

Az engedélyezési állapot a `~/.config/omarchy/shell.json` fájlban tárolódik, és a szabály egyaránt különbözik a kétféle bővítményre. Egy harmadik fél bővítménye éppen akkor engedélyezett, ha az azonosítója valahol megjelenik abban a fájlban — sáv-kialakítási bejegyzésként, a `plugins[]` listában bejegyzésként, vagy `bar.id`-ként. Azok az első fél bővítmények, amelyek nem sáv-widgetek, ellentétes irányúak: alapértelmezetten be vannak kapcsolva, és csak akkor kapcsolnak ki, ha a `disabledPlugins[]` listában vannak.

Egy teljes sáv-bővítménynek egyáltalán nincs kikapcsolt állapota. Mindig pontosan egy sáv van, így egy másik engedélyezésével tudod az eredetit helyettesíteni. A sávwidget-elhelyezésről [a felső sáv](05-the-top-bar.md) rész szól.

## Bővítmény hozzáadása gitből

Egy harmadik fél bővítménye éppen egy git-repo, amelynek gyökerében van egy `manifest.json` fájl.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Mielőtt bármit tenne, őszintén megmondja, hogy a bővítmények tetszőleges, nem szandált kódként futnak a hosszú élettartamú shell-folyamatodban, megmutatja a címcím URL-jét, és megerősítést kér. Ezt vedd komolyan. A harmadik felek bővítmény-felülete közvetlenül nem fed fel hitelesítési szolgáltatásokat, és egy helyettesítő sáv is csak korlátozott képességeket kap a konfigurált nem-hitelesítési felülethez. A vizuális bővítmények továbbra is ugyanabban a shell-QML jelenetben élnek, és mindennapi szülő objektumokat járhatnak be, miközben minden bővítménykód a felhasználói fiókoddal elérhető mindennél fut. A hitelesítési állapotot külön védjük azáltal, hogy ezeket a szolgáltatásokat kívül tartjuk az elérhető gazdaobjektum-gráfon. Csak olyan repókat adj hozzá, amelyeket hajlandó vagy futni, és előtte először olvass utána.

Egy helyettesítő sáv megjelenítheti a telepített widgeteket, de ott a szolgáltatási támogatású harmadik fél widgetek csökkentett funkcionalitással rendelkezhetnek, mert a sávnak nem szabad másik bővítmény élő szolgáltatás-objektumát kérni. Válts vissza a beépített `omarchy.bar` sávra, ha az adott widget a kísérő szolgáltatást igényli.

Ezután klónozza a repót egy előkészítési könyvtárba, érvényesíti a manifest tényét, megtagadja a telepítést, ha másik bővítmény már követeli az azonosítót, és átmásolja a `~/.config/omarchy/plugins/<id>/` helyre. A `--enable` nélkül megkérdezi, szeretnéd-e most bekapcsolni, és nemmel válaszolhatsz, és először elolvashatod a kódot. A bővítményből semmit sem futtat, soha nem futtat telepítési hookot, és soha nem kér sudo felhatalmazást — fájlokat klónoz, ellenőrzi a manifestet, és egy bitet billent az IPC-n keresztül.

A frissítés ugyanannak a checkoutnak egy gyorsítómásolás (fast-forward) levonása:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Azonosító nélkül frissíti minden git által kezelt bővítményedet. Megmutatja a különbséget az alkalmazás előtt, megtagadja a frissítést, ha olyan helyi módosításokat tartalmaz, amelyeket nem tud gyorsítómásolni, és visszavonja, ha az új revízió hibásan érvényesül.

```
omarchy plugin remove acme.weather
```

Az eltávolítás először letiltja a bővítményt, majd törli, ha git-checkout (a repo még mindig upstream), vagy leválasztja, ha szimbolikus hivatkozás. Egy kézzel készült bővítmény-mappa git-repo nélkül egy időbélyegzővel ellátott biztonsági másolatba kerül a bővítmények könyvtárán belül, anélkül, hogy egyenesen törölnék.

## Beépített klónozása módosításhoz

Ez a kedvenc részem. Ha meg akarod változtatni egy beépített widget viselkedését, ne szerkeszd a `$OMARCHY_PATH` alatti fájlokat — azok a csomaghoz tartoznak, és a következő frissítés felülírja őket. Klónozd őket helyette:

```
omarchy plugin clone omarchy.clock
```

Ez az egész bővítményt átmásolja a `~/.config/omarchy/plugins/dhh.clock` helyre (a te felhasználóneved, nem az enyém), átnevezi „My Clock"-ra, engedélyezi, és átkapcsolja a shellt a beépítettől a saját példányodra — megtartva egy meglévő sávwidget helyét és beállításait. Add hozzá a `--edit` lehetőséget, ha rögtön meg akarod nyitni az új könyvtárat a `$EDITOR`-ban, és ehhez a menü _Setup > Plugins > Clone Plugin_ pontja is hasonlóképpen tesz.

A felhasználónévi előtag megtartja a klón azonosítódat a tiédként, így a megosztás nem ütközik senki máséval. Az eredeti beépített azonosítóhoz intézett hívások az Ön klónjaihoz kerülnek irányításra, így semmi, ami az `omarchy.clock` azonosítóra hivatkozott, nem igényel frissítést. És ha nem jössz belőle össze, az `omarchy plugin remove dhh.clock` parancs visszaállítja a beépítettet.

Ha ment egy fájlt bárhol a `~/.config/omarchy/plugins/` helyen, akkor a bővítménykód automatikusan újratöltődik, így nyitva hagyhatod a szerkesztőt, és figyelheted a változások beérkezését.

## Saját bővítmény írása

Egy bővítmény egyetlen könyvtár, benne egy `manifest.json` fájllal és némi QML-lel. A manifest kinyilvánítja a `schemaVersion: 1` értékét, egy `id`, `name`, `version`, egy vagy több `kinds` és egy `entryPoints` objektumot, amely minden típus QML-fájljára mutat:

| Típus | Micsoda |
|------|------------|
| `bar-widget` | Egy komponens, amelyet az aktív sáv egy szakaszba ejthet |
| `panel` | Egy tartós vagy meginvitált úszó ablak |
| `overlay` | Egy teljes képernyős rátakarás |
| `menu` | Egy meginvitált menüfelület |
| `service` | Fejnélküli singleton felület nélkül |
| `bar` | Egy teljes sáv, ami a beépítettet váltja |

Egy bővítmény egyszerre több típust is kijelenthet — a média-bővítmény egyszerre `service` és `bar-widget`. A sávwidgetek egy extra `barWidget` blokkot kapnak megjelenítési névvel, kategóriával, egy opcionális `defaultSection` lehetőséggel, és az `allowMultiple` beállítással, ami megmondja, van-e értelme többet tenni a sávra. A legtöbb widget `false`-ra állítja; a térköz-változtatók és a jelzők `true`-ra állítják.

Mielőtt bármit közzétennél, ellenőrizd őt:

```
omarchy plugin validate ./my-plugin
```

Ez ugyanazokat az ellenőrzéseket futtatja, mint a shell betöltés közben: a séma-verziót, a szükséges mezőket, egy olyan azonosítót, ami nincs fenntartva, belépési pontokat, amelyek biztonságos, relatív utak, és ténylegesen léteznek, belépési pontot minden deklarált típushoz, és az abszolút szimbolikus hivatkozások hiányát a mappán belül bárhol.

Bővítményfejlesztéshez lásd a [shell-hivatkozást](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) és az [első fél bővítmény-katalógust](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## A sajátodd megosztása a világgal

Ha egyszer készítettél valamit, amit szeretsz, tedd egy nyilvános git-repóba. Ez az egész terjesztési mechanizmus — bárki futtathat egy `omarchy plugin add` parancsot az URL-jénél, és másodperceken belül működik.

Hogy az emberek megtalálják, tedd fel a [plugins.omarchy.org](https://plugins.omarchy.org) oldalra. Ez az Omarchy-shellbővítmények piaca, és ez az első hely, amelyet nézni érdemes, amikor azon töprengsz, vajon valaki már megépítette-e azt a widgetet, amelyet éppen írni készülsz. Böngéssz rajta, mielőtt elindulnál!
