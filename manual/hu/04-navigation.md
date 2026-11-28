# Navigáció

Minden az Omarchyban billentyűzettel történik — _MINDEN!_ Amikor a rendszer először elindul, egérrel önmagában szó szerint semmit sem tudsz csinálni. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy menü előhívásához, és innen nagyjából mindent meg tudsz csinálni.

De az Omarchy menünek még csak nem is az a rendeltetése, hogy az idő nagy részében ez legyen a rendszer kezelésének fő módja. Ennél gyorsabbak is tudunk lenni! Az összes legfontosabb alkalmazás közvetlenül külön gyorsbillentyűkhöz van kötve. A terminált a `Super + Return` billentyűkombinációval, a böngészőt pedig a `Super + Shift + Return` billentyűkombinációval indítod el. Próbáld ki az egyiket a másik után, és látni fogod a Hyprland csempézésének varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg ismét a `Super + J` billentyűkombinációt, hogy visszakerüljenek egymás mellé. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt a böngészőben az ablakok felcseréléséhez.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity monitor elindításához. Ez lebegő ablakként jelenik meg, címsorral, amelynél fogva húzhatod, és gombokkal a minimalizáláshoz, maximalizáláshoz és bezáráshoz. Minden lebegő ablak kap egyet, bárhol is legyen. Csempézheted a `Super + T` billentyűkombinációval (és ha ismét megnyomod, újra lebegő lesz). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép négyes elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Azzal navigálsz az aktívvá tenni kívánt ablakhoz, hogy megnyomod a `Super + Arrow` billentyűkombinációt. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére viszi. A képernyő szélén továbbmegy az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az aktuális fókuszban lévő alkalmazást a második munkaterületre viszed. A `Super + Shift + 1` visszaviszi. (A `Super + Shift + Alt + 2` pedig az aktuális fókuszban lévő alkalmazást a második munkaterületre viszi anélkül, hogy átváltana rá).

Több monitor esetén minden monitornak saját, 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` annak a monitornak a második munkaterületére visz, amelyen vagy, és minden monitor felső sávja a saját munkaterületeit és az éppen megjelenítettet mutatja. A `Super + Tab` végigléptet annak a monitornak a munkaterületein, amelyen vagy. A `Super + Shift + Ctrl + Arrows` az aktuális ablakot abba az irányba lévő monitorra viszi, az ott éppen megjelenített munkaterületre, a `Super + Shift + Alt + Arrows` pedig az aktuális munkaterületet viszi át abba az irányba lévő monitorra, ahol ugyanazt a számot veszi fel, ha az szabad. A monitor megtartja a munkaterületeit, amikor kihúzod: azok egy másik képernyő munkaterületeihez csatlakoznak, az ott már meglévők után számozva, és amikor a monitor visszatér, a régi számaik alá mennek vissza.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, átrendezheted, hol helyezkedjen el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Az ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zárod be (és az összes ablakot a `Ctrl + Alt + Delete` billentyűkombinációval).

Teljes képernyőre is válthatsz a `Super + F` billentyűkombinációval, vagy akár csak teljes szélességre (a felső sávot megtartva) a `Super + Alt + F` billentyűkombinációval, vagy teljes képernyőre egy ablakon belül a `Super + Ctrl + F` billentyűkombinációval (jó a YouTube-hoz!).

### Dwindle vs görgetős elrendezés

Az Omarchy alapértelmezett elrendezése a dwindle. Ez egyetlen munkaterületen az összes megnyitott ablakot mindig láthatóan tartja, még ha össze is kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De azt is választhatod, hogy egy munkaterületet görgetős elrendezésűvé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` billentyűkombinációval alakítasz át erre az elrendezésre.

A `Super + L` ismételt megnyomása a munkaterületet lebegővé teszi, ahol az ablakok szabadon átfedik egymást, és te helyezed el őket, egy harmadik megnyomás pedig visszaállítja dwindle elrendezésre. A `Super + Alt + L` a másik irányban megy végig rajtuk. Egy amúgy is lebegő ablak — amelyet a `Super + T` billentyűkombinációval pattintottál ki, vagy egy olyan alkalmazás, amely mindig lebegve nyílik meg — lebegő marad, amikor a munkaterület visszavált csempézésre. A felső sáv az aktuális munkaterületet az elrendezésével jelöli: négyzet a dwindle, kör a görgetős, és háromszög a lebegő esetén. Erre a jelre kattintva is váltogatod az elrendezést, ahogy a kijelzőgomb is azokon a laptopokon, amelyeken van ilyen.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A választás munkaterületenként érvényes, és megmarad. Így az 1. munkaterületet dwindle elrendezésen tarthatod böngészéshez, a 2. munkaterületet pedig görgetősön kódoláshoz, és újraindítás után is így térnek vissza.

Ha a görgetős elrendezést szeretnéd alapértelmezettként használni, ezt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

Egy lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te mozgatod és méretezed őket. Minden ablak a témád színeivel kap címsort, minimalizáló, maximalizáló és bezáró gombokkal. A `Super + M` billentyűkombinációval a fókuszban lévő ablakot is minimalizálhatod. A minimalizált ablak a dokkban várakozik; kattints az alkalmazására a visszahozásához. Kattints egy ablakra, hogy előtérbe hozd. Bármelyik szélétől vagy sarkától méretezd át. Kattints duplán egy címsorra az ablak maximalizálásához úgy, hogy a felső sáv látható maradjon, és ismét a régi méretének visszakapásához. A Chrome és más Chromium-alapú böngészők, a Disks és a Document Viewer kihagyja a címsort, és helyette a saját fejlécét használja; a `Super + Alt + F` maximalizálja őket, a `Super + M` pedig minimalizálja őket.

Minden munkaterületnek van dokkja, a rögzített alkalmazásaiddal, mindennel, ami fut, és minden alkalmazás rácsával az alkalmazások gomb mögött, amelyet a `Super + Alt + Space` billentyűkombináció és az Omarchy menüben az _Alkalmazások_ is megnyit. Kattints jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt az eltávolításához. Kattints egy alkalmazásra a megnyitásához, vagy az ablakának előtérbe hozásához; kattints ismét az ablakai közötti váltogatáshoz. A Files csak arról a munkaterületről hoz vissza ablakot, amelyen vagy, egyébként újat nyit, a Terminal és az Agent pedig mindig újat indít, bár a minimalizált ablak jön vissza először. A középső kattintás új ablakot nyit. Húzz egy ikont a dokk mentén a mozgatásához; ha egy futó alkalmazást a többi közé húzol, ott marad. Kattints jobb gombbal, hogy egy alkalmazást a dokkban tarts, kivegyél onnan, vagy kilépj belőle. A dokk kint marad, amíg egy munkaterület üres, és amint van ablak a munkaterületen, elrejtőzik, amíg a mutató el nem éri a szélét. Egy teljes képernyős ablak teljesen elrejti. Húzd az alkalmazások gombot a képernyő egy másik széle felé a dokk oda mozgatásához. Kattints rá jobb gombbal a _Pozíció_ lehetőségért egy szél kiválasztásához, és az _Elrendezés_ lehetőségért az alapértelmezett elrendezés beállításához, ahogy a _Megjelenés > Munkaterület elrendezése_ is teszi. A pozíció a _Megjelenés > Dock > Dock pozíciója_ alatt is megtalálható, és az `omarchy dock position left` terminálból állítja be. Azok az alkalmazások, amelyeket a dokkban tartasz, halványak, amíg nem futnak. Ha a dokkot csak lebegő munkaterületekre szeretnéd korlátozni, használd a _Megjelenés > Dock > Dock csak lebegő munkaterületeken_ lehetőséget vagy az `omarchy dock tiling off` parancsot.

Az új munkaterületek, és azok, amelyeknek nem adtál saját elrendezést a `Super + L` billentyűkombinációval, az alapértelmezett elrendezést használják. Az alapértelmezett módosítása minden ablak nélküli munkaterületet visszaállít erre, míg az, amelyiken ablakok vannak, megtartja a meglévő elrendezését. A dokkba minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Válaszd ki a _Megjelenés > Munkaterület elrendezése_ alatt: Csempézés, Görgetős vagy Lebegő. Az `omarchy hyprland workspace layout default scrolling` terminálból állítja be.

### Ablakok csoportosítása

Az ablakok a `Super + G` billentyűkombinációval csoportosíthatók. Amint egy csoportban vagy, minden ablak, amelyet amíg az aktív, elindítasz, a csoporthoz fog tartozni. Ezek között a csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval mozoghatsz, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval közvetlenül, sorrendben léphetsz a csoportosított ablakokra.

Egy ablakot a `Super + Alt + G` billentyűkombinációval vehetsz ki a csoportosításból, vagy a `Super + G` ismételt megnyomásával az egész csoportot szétbonthatod. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` billentyűkombinációval viheted be a csoportba.

### Ablakok kipattintása

Egy ablakot a `Super + O` billentyűkombinációval kipattinthatsz a munkaterület-kiosztásából. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Nagyszerű videolejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amely rárakódik arra a munkaterületre, amelyen éppen vagy. A rajta lévő dolgokat a `Super + S` billentyűkombinációval éred el, és ablakokat a `Super + Alt + S` billentyűkombinációval helyezel oda.

Jól működik vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake konzol

Végül van egy félmagasságú Quake konzol, amely legördül arra a munkaterületre, amelyen éppen vagy. A `Super + the key above Tab` billentyűkombinációval kapcsolhatod be és ki (az amerikai kiosztásokon a grave), és ablakot a `Super + Shift + the key above Tab` billentyűkombinációval helyezel oda.

Amikor először nyílik meg, elindítja az alapértelmezett agentedet, vagy megkér, hogy válassz egyet, ha még nem választottál. Amíg a konzol egyetlen ablakot tartalmaz, középre igazított panelként gördül le, nem pedig a képernyőt átfogva. Tégy rá egy második alkalmazást, és visszamegy teljes szélességre, így a kettőnek van helye egymás mellett.

Ha egy ablakot le szeretnél venni akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valamivel, mint a `Super + Shift + 1`.

### Kell egy kis megszokás!

Kell egy kis idő, amíg megszokod, hogy így navigálj az asztalodon, de ha egyszer megszokod, nehéz lesz visszamenni a hagyományos, egérvezérelt asztali élményhez!
