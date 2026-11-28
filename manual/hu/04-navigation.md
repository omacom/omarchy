# Navigáció

Az Omarchyban minden billentyűzettel történik — _MINDEN!_ Amikor a rendszer először elindul, egérrel önmagában szó szerint semmit sem tudsz csinálni. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy Menu megjelenítéséhez, és innen szinte mindent megtehetsz.

De az Omarchy menünek a legtöbb esetben nem is az a rendeltetése, hogy ez legyen a rendszer kezelésének fő módja. Ennél gyorsabbak is tudunk lenni! Minden legfontosabb alkalmazás közvetlenül külön gyorsbillentyűkhöz van kötve. A terminált a `Super + Return`, a böngészőt pedig a `Super + Shift + Return` billentyűkombinációval indítod. Próbáld meg egymás után, és látni fogod a Hyprland csempézésének varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg ismét a `Super + J` billentyűkombinációt, hogy visszatérjenek egymás melletti helyzetükbe. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt, miközben a böngészőben vagy, hogy felcseréld az ablakokat.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity monitor elindításához. Ez lebegő ablakként jelenik meg, címsorral, amelynél fogva húzhatod, és gombokkal a minimalizálásához, maximalizálásához és bezárásához. Minden lebegő ablak kap egyet, bárhol is legyen. Csempézheted a `Super + T` billentyűkombinációval (és nyomd meg ismét, hogy újra lebegővé tedd). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép négyes elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` billentyűkombinációval navigálsz az aktiválni kívánt ablakok között. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére mozgatja. A képernyő szélén továbbhalad az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az aktuálisan fókuszban lévő alkalmazást a második munkaterületre mozgatod. A `Super + Shift + 1` visszaviszi. (A `Super + Shift + Alt + 2` pedig az aktuálisan fókuszban lévő alkalmazást a második munkaterületre mozgatja anélkül, hogy átváltana rá).

Ha több monitorod van, minden monitornak saját, 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` az aktuális monitor második munkaterületére visz, és minden monitor felső sávja a saját munkaterületeit mutatja, és azt, amelyiket éppen mutatja. A `Super + Tab` végiglépeget az aktuális monitor munkaterületein. A `Super + Shift + Ctrl + Arrows` az aktuális ablakot az abban az irányban lévő monitorra mozgatja, az általa mutatott munkaterületre, a `Super + Shift + Alt + Arrows` pedig az aktuális munkaterületet mozgatja át az abban az irányban lévő monitorra, ahol ugyanazt a számot veszi fel, ha szabad. Egy monitor megtartja a munkaterületeit, amikor kihúzod: egy másik képernyő munkaterületeihez csatlakoznak, az ott már meglévők után számozva, és visszatérnek régi számaik alá, amikor a monitor visszatér.

Ha lenyomva tartod a `Super` billentyűt, és egérrel egy ablakra kattintasz, át tudod rendezni, hol helyezkedik el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Egy ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zársz be (az összes ablakot pedig a `Ctrl + Alt + Delete` billentyűkombinációval).

Teljes képernyőre is válthatsz a `Super + F` billentyűkombinációval, vagy akár csak teljes szélességre (a felső sáv megtartásával) a `Super + Alt + F` billentyűkombinációval, vagy teljes képernyőre egy ablakon belül a `Super + Ctrl + F` billentyűkombinációval (jó a YouTube-hoz!).

### Dwindle és görgetős elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Egyetlen munkaterületen minden megnyitott ablakot mindig láthatóan tart, még akkor is, ha ehhez össze kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De azt is választhatod, hogy egy munkaterületet görgetős elrendezésűvé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` billentyűkombinációval alakítasz át erre az elrendezésre.

A `Super + L` újbóli megnyomása lebegővé alakítja a munkaterületet, ahol az ablakok szabadon átfedik egymást, és te magad helyezed el őket, egy harmadik megnyomás pedig visszavált dwindle-re. A `Super + Alt + L` a másik irányban halad végig rajtuk. Egy ablak, amely egyébként is lebeg — amelyet a `Super + T` billentyűkombinációval pattintottál ki, vagy egy olyan alkalmazás, amely mindig lebegve nyílik meg — lebegő marad, amikor a munkaterület visszavált csempézésre. A felső sáv megjelöli az aktuális munkaterületet az elrendezésével: négyzet a dwindle, kör a görgetős, háromszög a lebegő esetében. Erre a jelre kattintva szintén végiglépegethetsz az elrendezéseken, ahogy a kijelzőgombbal is azokon a laptopokon, amelyeken van ilyen.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A választás munkaterületenként érvényes, és megmarad. Így az 1. munkaterületet meghagyhatod dwindle elrendezésben böngészéshez, a 2.-t pedig görgetősben kódoláshoz, és újraindítás után is így térnek vissza.

Ha a görgetős elrendezést szeretnéd alapértelmezettként használni, ezt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

A lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te magad mozgatod és méretezed őket. Minden ablak címsort kap a témád színeiben, gombokkal a minimalizáláshoz, maximalizáláshoz és bezáráshoz. A `Super + M` billentyűkombináció szintén minimalizálja a fókuszban lévő ablakot. A minimalizált ablak a dockban várakozik; kattints az alkalmazására, hogy visszahozd. Kattints egy ablakra, hogy előtérbe hozd. Bármelyik élétől vagy sarkától átméretezheted. Duplán kattints egy címsorra, hogy maximalizáld az ablakot, miközben a felső sáv látható marad, és ismét, hogy visszakapd a régi méretét. A Chrome és más Chromium-alapú böngészők, a Disks és a Document Viewer kihagyják a címsort, és helyette a saját fejlécüket használják; a `Super + Alt + F` maximalizálja őket, a `Super + M` pedig minimalizálja őket.

Minden munkaterületnek van dockja, a rögzített alkalmazásaiddal, mindennel, ami fut, és az alkalmazások gombja mögött minden alkalmazás rácsával, amelyet a `Super + Alt + Space` és az Omarchy menüben az _Apps_ is megnyit. Kattints jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt, hogy eltávolítsd. Kattints egy alkalmazásra a megnyitásához, vagy hogy előtérbe hozd az ablakát; kattints ismét, hogy végiglépegess az ablakai között. A Files csak arról a munkaterületről hoz vissza ablakot, amelyen vagy, egyébként újat nyit, a Terminal és az Agent pedig mindig újat indít, bár egy minimalizált ablak előbb visszatér. A középső kattintás új ablakot nyit. Húzz egy ikont a dock mentén a mozgatásához; ha egy futó alkalmazást a többi közé húzol, ott marad. Kattints jobb gombbal, hogy egy alkalmazást a dockban tarts, kivedd onnan, vagy kilépj belőle. A dock kint marad, amíg egy munkaterület üres, és amint a munkaterületnek ablaka van, elrejtőzik, amíg a mutató el nem éri a szélét. Egy teljes képernyős ablak teljesen elrejti. Húzd az alkalmazások gombját a képernyő egy másik széle felé, hogy oda mozgasd a dockot. Kattints rá jobb gombbal a _Position_ lehetőségért, hogy szélt válassz, a _Layout_ lehetőségért, hogy beállítsd az alapértelmezett elrendezést, ahogy az _Appearance > Workspace Layout_ teszi, és a _Visibility_ lehetőségért, hogy a dock mindig bekapcsolva maradjon, az első alkalmazás elrejtse, vagy mindig rejtve maradjon. Az `omarchy dock visibility always` parancs terminálból állítja be ezt. A pozíció az _Appearance > Dock > Dock Position_ alatt is megtalálható, az `omarchy dock position left` parancs pedig terminálból állítja be. Az alkalmazások, amelyeket a dockban tartasz, halványak, amíg nem futnak. Hogy a dockot a lebegő munkaterületekre korlátozd, használd az _Appearance > Dock > Dock Only on Floating_ lehetőséget vagy az `omarchy dock tiling off` parancsot.

Az új munkaterületek, és azok, amelyeknek nem adtál saját elrendezést a `Super + L` billentyűkombinációval, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet visszaállít arra, míg az, amelyen ablakok vannak, megtartja a meglévő elrendezését. A dockba minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Válaszd ki az _Appearance > Workspace Layout_ alatt: Tiling, Scrolling vagy Floating. Az `omarchy hyprland workspace layout default scrolling` parancs terminálból állítja be.

### Ablakok csoportosítása

Az ablakok a `Super + G` billentyűkombinációval csoportosíthatók. Amint egy csoportban vagy, minden ablak, amelyet ennek aktív állapota alatt indítasz, a csoporthoz fog tartozni. E csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval mozoghatsz, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval közvetlenül a csoportosított ablakokhoz ugorhatsz sorrendben.

Egy ablakot a `Super + Alt + G` billentyűkombinációval mozgathatsz ki a csoportosításból, vagy a `Super + G` ismételt megnyomásával az egész csoportot szétbonthatod. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` billentyűkombinációval mozgathatod be a csoportba.

### Ablakok kipattintása

Egy ablakot a `Super + O` billentyűkombinációval kipattinthatsz a munkaterület-kiosztásából. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Nagyszerű videolejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy különleges, teljes méretű scratchpad munkaterület, amely ráfed arra a munkaterületre, amelyen éppen vagy. A rajta lévő dolgokhoz a `Super + S` billentyűkombinációval férsz hozzá, és ablakokat a `Super + Alt + S` billentyűkombinációval helyezel oda.

Jól működik vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake konzol

Végül van egy félmagasságú Quake konzol, amely legördül arra a munkaterületre, amelyen éppen vagy. A `Super + the key above Tab` billentyűkombinációval kapcsolhatod ki és be (amerikai kiosztásokon a grave), és a `Super + Shift + the key above Tab` billentyűkombinációval helyezhetsz oda ablakot.

Amikor először megnyílik, elindítja az alapértelmezett agented, vagy megkér, hogy válassz egyet, ha még nem választottál. Amíg a konzol egyetlen ablakot tartalmaz, középre igazított panelként gördül le, ahelyett, hogy átérné a képernyőt. Tegyél rá egy második alkalmazást, és visszavált teljes szélességre, hogy a kettőnek legyen helye egymás mellett.

Hogy egy ablakot levegyél akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valami olyasmivel, mint a `Super + Shift + 1`.

### Kell egy kis idő, amíg megszokod!

Kell egy kis idő, amíg megszokod, hogy így navigálj az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni a hagyományos, egérvezérelt asztali élményhez!
