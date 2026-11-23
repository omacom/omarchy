# Navigáció

Az Omarchyban minden a billentyűzeten keresztül történik — _MINDEN!_ Amikor a rendszer először elindul, szó szerint semmit sem tudsz csinálni pusztán az egérrel. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy Menu előhívásához, és innen szinte mindent meg tudsz tenni.

De az Omarchy menünek még csak nem is az a rendeltetése, hogy az idő nagy részében ez legyen a rendszer kezelésének fő módja. Ennél gyorsabbak is tudunk lenni! Az összes legfontosabb alkalmazás közvetlenül külön gyorsbillentyűkhöz van rendelve. A terminált a `Super + Return`, a böngészőt pedig a `Super + Shift + Return` billentyűkombinációval indítod. Próbáld ki az egyiket a másik után, és meglátod a Hyprland csempézési varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg ismét a `Super + J` billentyűkombinációt, hogy visszaállítsd őket az egymás melletti helyzetükbe. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt, miközben a böngészőben vagy, hogy megcseréld az ablakokat.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity figyelő elindításához. Ez lebegő ablakként jelenik meg. A `Super + T` billentyűkombinációval csempézheted (és ha ismét megnyomod, újra lebegővé teheted). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép négyes elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` billentyűkombinációval navigálsz az aktívvá tenni kívánt ablakok között. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére helyezi. Egy képernyő szélén átvisz az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az éppen fókuszban lévő alkalmazást a második munkaterületre helyezed. A `Super + Shift + 1` visszateszi. (A `Super + Shift + Alt + 2` pedig az éppen fókuszban lévő alkalmazást a második munkaterületre helyezi anélkül, hogy átváltana rá.)

Egynél több monitor esetén minden monitornak megvannak a saját 1-től 10-ig terjedő munkaterületei. A `Super + 2` az éppen használt monitor második munkaterületére visz, és minden monitor felső sávja a saját munkaterületeit mutatja, valamint azt, amelyiket éppen megjeleníti. A `Super + Tab` végiglépeget az éppen használt monitor munkaterületein. A `Super + Shift + Ctrl + Arrows` az éppen használt ablakot az adott irányban lévő monitorra helyezi, az ott éppen megjelenített munkaterületre, a `Super + Shift + Alt + Arrows` pedig az éppen használt munkaterületet helyezi át az adott irányban lévő monitorra, ahol ugyanazt a számot veszi fel, ha az szabad. A monitor megtartja a munkaterületeit, amikor kihúzod: egy másik képernyő munkaterületeihez csatlakoznak, az ott már meglévő munkaterületek után számozva, és visszakapják a régi számaikat, amikor a monitor visszatér.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, átrendezheted, hol helyezkedjen el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Egy ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zársz be (az összes ablakot pedig a `Ctrl + Alt + Delete` billentyűkombinációval).

A `Super + F` billentyűkombinációval teljes képernyőre is válthatsz, a `Super + Alt + F` billentyűkombinációval akár csak teljes szélességűre (a felső sávot megtartva), vagy a `Super + Ctrl + F` billentyűkombinációval egy ablakon belüli teljes képernyőre (jó a YouTube-hoz!).

### Dwindle vs scrolling elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Egyetlen munkaterületen megnyitott összes ablakodat folyamatosan láthatóan tartja, még ha ehhez össze is kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De választhatod azt is, hogy egy munkaterületet scrolling elrendezéssé alakítasz, ahol az ablakok egymás mellett sorakoznak, a képernyő látható szélén túl. Egyetlen munkaterületet a `Super + L` billentyűkombinációval alakíthatsz át erre az elrendezésre.

A `Super + L` ismételt megnyomásával a munkaterület lebegővé válik, ahol az ablakok szabadon átfedik egymást, és te magad helyezed el őket, egy harmadik megnyomással pedig visszatér a dwindle elrendezéshez. A `Super + Alt + L` fordított irányban halad végig rajtuk. Egy ablak, amely amúgy is lebeg — egy olyan, amelyet a `Super + T` billentyűkombinációval kiemeltél, vagy egy alkalmazás, amely mindig lebegve nyílik meg — lebegve marad, amikor a munkaterület visszatér a csempézéshez. A felső sáv az éppen használt munkaterületet az elrendezésével jelöli: egy négyzet a dwindle, egy kör a scrolling, és egy háromszög a lebegő elrendezést jelzi. Erre a jelre kattintva szintén végiglépegethetsz az elrendezéseken, és így tesz a kijelzőgomb is azokon a laptopokon, amelyeken van ilyen.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A választás munkaterületenként történik, és megmarad. Így az 1. munkaterületet dwindle elrendezésen tarthatod böngészéshez, a 2. munkaterületet pedig scrolling elrendezésen kódoláshoz, és újraindítás után is így térnek vissza.

Ha a scrolling elrendezést szeretnéd alapértelmezettként használni, ezt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

Egy lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te magad helyezed el és méretezed őket. Minden ablak a témád színeiben pompázó címsort kap, a minimalizáláshoz, maximalizáláshoz és bezáráshoz szükséges gombokkal. A `Super + M` a fókuszban lévő ablakot is minimalizálja. A minimalizált ablak a dockban várakozik; kattints az alkalmazására, hogy visszahozd. Kattints egy ablakra, hogy előtérbe hozd. Bármely széléről vagy sarkáról átméretezheted. Kattints duplán egy címsorra, hogy maximalizáld az ablakot, miközben a felső sáv látható marad, és ismét, hogy visszakapd a régi méretét. A Chrome és más Chromium-alapú böngészők, a Disks és a Document Viewer kihagyja a címsort, és helyette a saját fejlécét használja; a `Super + Alt + F` maximalizálja őket, a `Super + M` pedig minimalizálja őket.

Egy lebegő munkaterület dockot is mutat, a rögzített alkalmazásaiddal, minden futó alkalmazással, és az alkalmazások gombja mögött minden alkalmazás rácsával, amelyet a `Super + Alt + Space` és az Omarchy menüben az _Apps_ szintén megnyit. Kattints jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt az eltávolításához. Kattints egy alkalmazásra a megnyitásához, vagy ablakának előtérbe hozásához; kattints ismét, hogy végiglépegess az ablakain. A Files csak az éppen használt munkaterületről hoz vissza egy ablakot, egyébként újat nyit, a Terminal és az Agent pedig mindig újat indít, bár egy minimalizált ablak jön vissza először. A középső kattintás új ablakot nyit. Húzz egy ikont a dock mentén a mozgatásához; ha egy futó alkalmazást a többi közé húzol, ott is marad. Kattints jobb gombbal, hogy egy alkalmazást a dockban tarts, kivegyél onnan, vagy kilépj belőle. A dock kitér egy teljes képernyős ablak útjából. Kattints jobb gombbal az alkalmazások gombjára, hogy a dockot egy másik szélre helyezd, vagy elrejtsd, amíg a mutató el nem éri a szélét. A pozíció az _Appearance > Dock > Dock Position_ alatt is megtalálható, és az `omarchy dock position left` és az `omarchy dock autohide on` mindkettőt beállítja egy terminálból. A dockban tartott alkalmazások halványan jelennek meg, amíg nem futnak.

Az új munkaterületek, és azok, amelyeknek nem adtál saját elrendezést a `Super + L` billentyűkombinációval, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet visszaállít arra, míg az, amelyen ablakok vannak, megtartja a meglévő elrendezését. A dockba minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Az _Appearance > Workspace Layout_ alatt választhatod ki: Tiling, Scrolling vagy Floating. Az `omarchy hyprland workspace layout default scrolling` terminálból állítja be.

### Ablakok csoportosítása

Az ablakok a `Super + G` billentyűkombinációval csoportosíthatók. Ha egyszer egy csoportban vagy, minden ablak, amelyet eközben indítasz, a csoporthoz fog tartozni. Ezek között a csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval mozoghatsz, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval közvetlenül a csoportosított ablakokra léphetsz sorrendben.

Egy ablakot a `Super + Alt + G` billentyűkombinációval helyezhetsz ki a csoportosításból, vagy a `Super + G` ismételt megnyomásával az egész csoport felbontható. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` billentyűkombinációval helyezheted be a csoportba.

### Ablakok kiemelése

Egy ablakot a `Super + O` billentyűkombinációval emelhetsz ki a munkaterületi kiosztásából. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Nagyszerű videolejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amely rárakódik arra a munkaterületre, amelyen éppen vagy. Az azon lévő tartalmakat a `Super + S` billentyűkombinációval érheted el, az ablakokat pedig a `Super + Alt + S` billentyűkombinációval helyezheted oda.

Jól működik olyan vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake-konzol

Végül van egy félmagasságú Quake-konzol, amely legördül arra a munkaterületre, amelyen éppen vagy. A `Super + Grave` billentyűkombinációval kapcsolhatod ki és be, egy ablakot pedig a `Super + Shift + Grave` billentyűkombinációval helyezhetsz oda.

Amikor először megnyílik, elindítja az alapértelmezett agentedet, vagy megkér, hogy válassz egyet, ha még nem választottál. Amíg a konzol egyetlen ablakot tartalmaz, középre igazított panelként gördül le, ahelyett, hogy a képernyő teljes szélességét elfoglalná. Tegyél rá egy második alkalmazást, és visszatér a teljes szélességhez, így a kettőnek lesz helye egymás mellett.

Ahhoz, hogy egy ablakot lemozgass akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valami olyasmivel, mint a `Super + Shift + 1`.

### Kell egy kis idő, amíg megszokod!

Kell egy kis idő, amíg megszokod, hogy így navigálsz az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni egy hagyományos, egérvezérelt asztali élményhez!
