# Navigáció

Mindent az Omarchyban billentyűzettel csinálsz — MINDENT! Amikor a rendszer először elindul, szó szerint semmit sem tudsz csinálni pusztán az egérrel. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy Menu megjelenítéséhez, és innen szinte mindent megtehetsz.

De az Omarchy menünek még csak nem is az a rendeltetése, hogy a legtöbb esetben ez legyen a rendszer kezelésének fő módja. Tudunk ennél gyorsabbak lenni! Minden legfontosabb alkalmazás közvetlenül egyedi gyorsbillentyűkhöz van kötve. A terminált a `Super + Return`, a böngészőt pedig a `Super + Shift + Return` billentyűkombinációval indítod. Próbáld ki őket egymás után, és meglátod a Hyprland csempézésének varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyezés helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg újra a `Super + J` billentyűkombinációt, hogy visszaálljanak egymás melletti helyzetükbe. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt, miközben a böngészőben vagy, az ablakok felcseréléséhez.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity monitor elindításához. Ez lebegő ablakként fog megjelenni. A `Super + T` billentyűkombinációval csempézheted (és ugyanezt újra megnyomva ismét lebegővé teheted). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép, négyes felosztású elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` billentyűkombinációval navigálhatsz az aktiválni kívánt ablakok között. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére mozgatja. A képernyő szélén továbbhalad az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az éppen fókuszban lévő alkalmazást a második munkaterületre mozgatod. A `Super + Shift + 1` visszateszi. (A `Super + Shift + Alt + 2` pedig az éppen fókuszban lévő alkalmazást a második munkaterületre mozgatja anélkül, hogy átváltana rá).

Ha több monitorod van, minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` az aktuális monitor második munkaterületére visz, és minden monitor felső sávja a saját munkaterületeit és a éppen megjelenítettet mutatja. A `Super + Tab` az aktuális monitor munkaterületei között léptet körbe. A `Super + Shift + Ctrl + Arrows` az aktuális ablakot az adott irányban lévő monitorra mozgatja, az ott éppen megjelenített munkaterületre, a `Super + Shift + Alt + Arrows` pedig az aktuális munkaterületet mozgatja át az adott irányban lévő monitorra, ahol ugyanazt a számot veszi fel, ha az szabad. A monitor megtartja a munkaterületeit, amikor kihúzod: azok csatlakoznak egy másik képernyő munkaterületeihez, az annak már meglévő munkaterületei után számozva, és visszakerülnek a régi számaik alá, amikor a monitor visszatér.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, átrendezheted, hol helyezkedjen el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Egy ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zársz be (az összes ablakot pedig a `Ctrl + Alt + Delete` billentyűkombinációval).

Teljes képernyőre is válthatsz a `Super + F` billentyűkombinációval, vagy akár csak teljes szélességre (a felső sáv megtartásával) a `Super + Alt + F` billentyűkombinációval, illetve egy ablakon belül teljes képernyőre a `Super + Ctrl + F` billentyűkombinációval (YouTube-hoz kiváló!).

### Dwindle vs. scrolling elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Egyetlen munkaterületen minden megnyitott ablakot mindig láthatóan tart, még akkor is, ha ehhez össze kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De azt is választhatod, hogy egy munkaterületet scrolling elrendezésűvé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` billentyűkombinációval alakíthatsz át erre az elrendezésre.

A `Super + L` ismételt megnyomása a munkaterületet lebegővé alakítja, ahol az ablakok szabadon átfedik egymást, és te magad helyezed el őket, egy harmadik megnyomás pedig visszateszi dwindle elrendezésbe. A `Super + Alt + L` a másik irányban halad végig rajtuk. Egy ablak, amely amúgy is lebeg — egy olyan, amelyet a `Super + T` billentyűkombinációval pattintottál ki, vagy egy alkalmazás, amely mindig lebegve nyílik meg — lebegő marad, amikor a munkaterület visszatér a csempézéshez. A felső sáv a munkaterületeden annak elrendezésével jelöli meg: négyzettel a dwindle-t, körrel a scrollingot és háromszöggel a lebegőt. Erre a jelre kattintva szintén léptetheted az elrendezést, akárcsak a kijelzőbillentyűvel azokon a laptopokon, amelyeken van ilyen.

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

Egy lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te magad mozgatod és méretezed őket. Minden ablak a témád színeiben pompázó címsort kap, minimalizálásra, maximalizálásra és bezárásra szolgáló gombokkal. A `Super + M` szintén minimalizálja a fókuszban lévő ablakot. Egy minimalizált ablak a dokkban várakozik; kattints az alkalmazására a visszahozásához. Kattints egy ablakra, hogy előtérbe hozd. Bármely széléről vagy sarkáról átméretezheted. Duplán kattints egy címsorra az ablak maximalizálásához, miközben a felső sáv látható marad, és ismét a régi méretének visszaszerzéséhez. A Chrome és más Chromium-alapú böngészők, a Disks és a Document Viewer kihagyják a címsort, és helyette a saját fejlécüket használják; a `Super + Alt + F` maximalizálja őket, a `Super + M` pedig minimalizálja őket.

Egy lebegő munkaterület dokkot is mutat, a rögzített alkalmazásaiddal, mindennel, ami éppen fut, és minden alkalmazás rácsával az alkalmazások gombja mögött, amelyet a `Super + Alt + Space` és az Omarchy menüben az _Apps_ is megnyit. Kattints a jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt az eltávolításához. Kattints egy alkalmazásra a megnyitásához, vagy ablakának előtérbe hozásához; kattints ismét az ablakai közötti léptetéshez. A Files csak az aktuális munkaterületről hoz vissza egy ablakot, egyébként újat nyit, a Terminal és az Agent pedig mindig egy másikat indít, bár egy minimalizált ablak tér vissza először. A középső kattintás új ablakot nyit. Húzz egy ikont a dokk mentén a mozgatásához; egy futó alkalmazás behúzása a többi közé ott tartja azt. Kattints a jobb gombbal egy alkalmazás dokkban tartásához, onnan való kivételéhez vagy kiléptetéséhez. A dokk kitér egy teljes képernyős ablak útjából. Kattints a jobb gombbal az alkalmazások gombjára a dokk másik szélre mozgatásához, vagy ahhoz, hogy rejtve maradjon, amíg a mutató el nem éri a szélét. A pozíció az _Appearance > Dock > Dock Position_ alatt is megtalálható, és az `omarchy dock position left` és az `omarchy dock autohide on` mindkettőt beállítja egy terminálból. A dokkban tartott alkalmazások halványak, amíg nem futnak.

Az új munkaterületek, és minden olyan, amelynek nem adtál saját elrendezést a `Super + L` billentyűkombinációval, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet visszaállít arra, míg egy olyan, amelyen ablakok vannak, megtartja a meglévő elrendezését. Egy dokkba minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Az _Appearance > Workspace Layout_ alatt választhatod ki: Tiling, Scrolling vagy Floating. Az `omarchy hyprland workspace layout default scrolling` egy terminálból állítja be.

### Ablakok csoportosítása

Az ablakok a `Super + G` billentyűkombinációval csoportosíthatók. Ha egyszer egy csoportban vagy, minden ablak, amelyet ennek aktív állapota közben indítasz, a csoporthoz fog tartozni. Ezek között a csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval mozoghatsz, hogy közvetlenül, sorrendben a csoportosított ablakokra lépj.

Egy ablakot a `Super + Alt + G` billentyűkombinációval mozgathatsz ki a csoportosításból, vagy a `Super + G` ismételt megnyomásával az egész csoportot szétbonthatod. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` billentyűkombinációval mozgathatod be a csoportba.

### Ablakok kipattintása

Egy ablakot a `Super + O` billentyűkombinációval kipattinthatsz a munkaterület-kiosztásából. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Videolejátszókhoz és hasonlókhoz kiváló.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amely rárakódik bármelyik munkaterületre, amelyen éppen vagy. Az azon lévő dolgokat a `Super + S` billentyűkombinációval érheted el, és a `Super + Alt + S` billentyűkombinációval helyezhetsz oda ablakokat.

Jól működik vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake-konzol

Végül van egy félmagasságú Quake-konzol, amely legördül bármelyik munkaterület fölé, amelyen éppen vagy. A `Super + the key above Tab` billentyűkombinációval kapcsolhatod be és ki (az amerikai kiosztásokon grave), és a `Super + Shift + the key above Tab` billentyűkombinációval helyezhetsz oda egy ablakot.

Amikor először nyílik meg, elindítja az alapértelmezett agentedet, vagy megkér, hogy válassz egyet, ha még nem választottál. Amíg a konzol egyetlen ablakot tartalmaz, középre igazított panelként gördül le, ahelyett hogy átérné a képernyőt. Tegyél rá egy második alkalmazást, és visszaáll teljes szélességre, így a kettőnek van helye egymás mellett elhelyezkedni.

Egy ablaknak akár a scratchpadről, akár a konzolról való elmozgatásához küldd közvetlenül egy másik munkaterületre valami olyasmivel, mint a `Super + Shift + 1`.

### Kell egy kis megszokás!

Kell egy kis idő, amíg megszokod, hogy így navigálj az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni egy hagyományos, egérvezérelt asztali élményhez!
