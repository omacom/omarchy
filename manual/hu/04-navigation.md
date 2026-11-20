# Navigáció

Az Omarchyban minden a billentyűzettel történik — _MINDEN!_ Amikor a rendszer először elindul, egérrel szó szerint semmit sem tudsz csinálni. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy Menu előhívásához, és innen szinte mindent meg tudsz tenni.

De az Omarchy menu még csak nem is arra való, hogy az idő nagy részében ez legyen a rendszer használatának fő módja. Ennél gyorsabbak is lehetünk! Az összes legfontosabb alkalmazás közvetlenül külön gyorsbillentyűkhöz van kötve. A terminált a `Super + Return` és a böngészőt a `Super + Shift + Return` billentyűkombinációval indítod. Próbáld ki az egyiket a másik után, és meglátod a Hyprland csempézésének varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Aztán megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg újra a `Super + J` billentyűkombinációt, hogy visszakerüljenek az egymás melletti helyzetükbe. Aztán próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt a böngészőben az ablakok felcseréléséhez.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity monitor elindításához. Az lebegő ablakként fog megjelenni. Csempézheted a `Super + T` segítségével (és nyomd meg újra, hogy ismét lebegő legyen). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép négyes elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` segítségével navigálsz az ablakok között, amelyiket aktívvá akarod tenni. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére viszi. A képernyő szélén továbbmegy az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az aktuálisan fókuszban lévő alkalmazást a második munkaterületre viszed. A `Super + Shift + 1` visszaviszi. (A `Super + Shift + Alt + 2` pedig az aktuálisan fókuszban lévő alkalmazást a második munkaterületre viszi anélkül, hogy átváltana rá).

Több monitor esetén minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` az aktuális monitor második munkaterületére megy, és minden monitor felső sávja a saját munkaterületeit mutatja, és azt, amelyiket éppen mutatja. A `Super + Tab` végigléptet az aktuális monitor munkaterületein. A `Super + Shift + Ctrl + Arrows` az aktuális ablakot az adott irányban lévő monitorra viszi, az ott éppen mutatott munkaterületre, a `Super + Shift + Alt + Arrows` pedig az aktuális munkaterületet viszi át az adott irányban lévő monitorra, ahol ugyanazt a számot kapja, ha szabad. A monitor megtartja a munkaterületeit, amikor kihúzod: azok egy másik képernyő munkaterületeihez csatlakoznak, az ott már meglévők után számozva, és visszakerülnek a régi számaik alá, amikor a monitor visszatér.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, átrendezheted, hol helyezkedjen el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Egy ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zársz be (az összes ablakot pedig a `Ctrl + Alt + Delete` billentyűkombinációval).

Teljes képernyőre is válthatsz a `Super + F` billentyűkombinációval, vagy akár csak teljes szélességre (a felső sáv megtartásával) a `Super + Alt + F` billentyűkombinációval, vagy teljes képernyőre egy ablakon belül a `Super + Ctrl + F` billentyűkombinációval (jó a YouTube-hoz!).

### Dwindle kontra scrolling elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Egyetlen munkaterületen megnyitott összes ablakodat mindig láthatóan tartja, még akkor is, ha ehhez össze kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De azt is választhatod, hogy egy munkaterületet scrolling elrendezésűvé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` segítségével alakítasz át erre az elrendezésre.

A `Super + L` újbóli megnyomása lebegővé teszi a munkaterületet, ahol az ablakok szabadon átfedik egymást, és te magad helyezed el őket, egy harmadik megnyomás pedig visszaviszi dwindle elrendezésbe. A `Super + Alt + L` a másik irányban megy végig rajtuk. Az az ablak, amelyik amúgy is lebeg — amelyet a `Super + T` segítségével pattintottál ki, vagy egy alkalmazás, amelyik mindig lebegve nyílik meg — lebegve marad, amikor a munkaterület visszavált csempézésre. A felső sáv az aktuális munkaterületet az elrendezésével jelöli: négyzet a dwindle, kör a scrolling, és háromszög a lebegő esetén. Arra a jelre kattintva is végigléptethetsz az elrendezéseken.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A választás munkaterületenként történik, és megmarad. Így az 1-es munkaterületet dwindle elrendezésen tarthatod böngészéshez, a 2-es munkaterületet pedig scrolling elrendezésen kódoláshoz, és újraindítás után is így térnek vissza.

Ha a scrolling elrendezést akarod alapértelmezettként használni, azt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

A lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te magad mozgatod és méretezed őket. Minden ablak címsort kap a témád színeiben, a minimalizáláshoz, maximalizáláshoz és bezáráshoz szükséges gombokkal. A `Super + M` is minimalizálja a fókuszban lévő ablakot. A minimalizált ablak a dockban várakozik; kattints az alkalmazására, hogy visszahozd. Kattints egy ablakra, hogy előtérbe hozd. Bármelyik széléről vagy sarkáról átméretezheted. Kattints duplán egy címsorra az ablak maximalizálásához, miközben a felső sáv látható marad, és kattints duplán újra, hogy visszakapd a régi méretét. A Chrome és más Chromium-alapú böngészők, a Disks és a Document Viewer kihagyják a címsort, és helyette a saját fejlécüket használják; a `Super + Alt + F` maximalizálja őket, a `Super + M` pedig minimalizálja őket.

A lebegő munkaterület dockot is mutat, a rögzített alkalmazásaiddal, mindennel, ami éppen fut, és minden alkalmazás rácsával az alkalmazások gombja mögött, amelyet a `Super + Alt + Space` és az Omarchy menüben az _Apps_ is megnyit. Kattints jobb gombbal egy alkalmazásra a rácsban, vagy nyomd meg a `Delete` billentyűt az eltávolításához. Kattints egy alkalmazásra a megnyitásához, vagy az ablakának előtérbe hozásához; kattints újra az ablakai közötti végigléptetéshez. A Files csak az aktuális munkaterületről hoz vissza egy ablakot, egyébként újat nyit, a Terminal és az Agent pedig mindig újat indít, bár egy minimalizált ablak előbb visszajön. A középső kattintás új ablakot nyit. Húzz egy ikont a dock mentén a mozgatásához; ha egy futó alkalmazást a többiek közé húzol, ott marad. Kattints jobb gombbal egy alkalmazás dockban tartásához, onnan való kivételéhez vagy kiléptetéséhez. A dock kitér egy teljes képernyős ablak útjából. Kattints jobb gombbal az alkalmazások gombjára, hogy a dockot egy másik szélre vidd, vagy elrejtsd, amíg a mutató el nem éri a szélét. A pozíció az _Appearance > Dock > Dock Position_ alatt is megtalálható, és az `omarchy dock position left` és az `omarchy dock autohide on` mindkettőt beállítja terminálból. A dockban tartott alkalmazások halványak, amíg nem futnak.

Az új munkaterületek, és azok, amelyeknek nem adtál saját elrendezést a `Super + L` segítségével, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet arra állít vissza, míg az, amelyiken ablakok vannak, megtartja a meglévő elrendezését. A dockba minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Az _Appearance > Workspace Layout_ alatt választhatod ki: Tiling, Scrolling vagy Floating. Az `omarchy-hyprland-workspace-layout-default scrolling` terminálból állítja be.

### Ablakok csoportosítása

Az ablakok a `Super + G` segítségével csoportosíthatók. Ha már egy csoportban vagy, minden ablak, amelyet annak aktív állapota alatt indítasz, a csoporthoz fog tartozni. A csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval mozoghatsz, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval közvetlenül, sorrendben léphetsz a csoportosított ablakokra.

Egy ablakot a `Super + Alt + G` segítségével vihetsz ki a csoportosításból, vagy a `Super + G` újbóli megnyomásával az egész csoportot szétbonthatod. Végül a csoporton kívül lévő ablakokat a `Super + Alt + Arrows` segítségével viheted be a csoportba.

### Ablakok kipattintása

Egy ablakot a `Super + O` segítségével pattinthatsz ki a munkaterületi helyéről. Ez lebegő ablakként rögzíti, amelyik követ téged bármelyik munkaterületre, ahová mész. Nagyszerű videolejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amelyik az aktuális munkaterületed fölé rétegződik. A rajta lévő dolgokat a `Super + S` segítségével éred el, és a `Super + Alt + S` segítségével helyezel oda ablakokat.

Jól működik vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan akarsz dolgozni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake konzol

Végül van egy félmagasságú Quake konzol, amelyik az aktuális munkaterületed fölé ereszkedik le. A `Super + Grave` segítségével kapcsolhatod be és ki, és a `Super + Shift + Grave` segítségével helyezhetsz oda egy ablakot.

Az alapértelmezett agenteddel nyílik meg, indulásra készen. Amíg a konzol egyetlen ablakot tart, középre igazított panelként ereszkedik le, ahelyett, hogy átérné a képernyőt. Tegyél rá egy második alkalmazást, és visszamegy teljes szélességre, így a kettőnek van helye egymás mellett.

Ha egy ablakot le akarsz vinni akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valamivel, mint a `Super + Shift + 1`.

### Kell egy kis megszokás!

Kell egy kis idő, amíg megszokod, hogy így navigálj az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni egy hagyományos, egérvezérelt asztali élményhez!
