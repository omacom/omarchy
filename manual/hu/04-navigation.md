# Navigáció

Az Omarchyban minden a billentyűzeten keresztül történik — _MINDEN!_ Amikor a rendszer először elindul, szó szerint semmit sem tudsz csinálni egyedül az egérrel. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy Menu megjelenítéséhez, és innen szinte mindent meg tudsz tenni.

De az Omarchy menünek a legtöbb esetben még csak nem is az a rendeltetése, hogy a rendszer fő kezelési módja legyen. Ennél gyorsabbak is tudunk lenni! Minden legfontosabb alkalmazás közvetlenül külön gyorsbillentyűhöz van kötve. A terminált a `Super + Return`, a böngészőt pedig a `Super + Shift + Return` billentyűkombinációval indítod. Próbáld ki egyiket a másik után, és látni fogod a Hyprland csempézésének varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg ismét a `Super + J` billentyűkombinációt, hogy visszatérjenek az egymás melletti helyzetükbe. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt a böngészőben az ablakok felcseréléséhez.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity monitor elindításához. Ez lebegő ablakként jelenik meg. Csempézheted a `Super + T` használatával (és ennek ismételt megnyomásával újra lebegővé teheted). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép négyes elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` billentyűkombinációval navigálsz az aktívvá tenni kívánt ablakok között. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére mozgatja. A képernyő szélén átmegy az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az aktuálisan fókuszban lévő alkalmazást a második munkaterületre mozgatod. A `Super + Shift + 1` visszahozza. (A `Super + Shift + Alt + 2` pedig az aktuálisan fókuszban lévő alkalmazást a második munkaterületre mozgatja anélkül, hogy átváltana rá).

Több monitor esetén minden monitornak saját, 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` az aktuális monitor második munkaterületére visz, és minden monitor felső sávja a saját munkaterületeit mutatja, és azt, amelyiket éppen mutatja. A `Super + Tab` végigléptet az aktuális monitor munkaterületein. A `Super + Shift + Ctrl + Arrows` az aktuális ablakot az adott irányban lévő monitorra mozgatja, az ott éppen mutatott munkaterületre, a `Super + Shift + Alt + Arrows` pedig az aktuális munkaterületet mozgatja át az adott irányban lévő monitorra, ahol ugyanazt a számot veszi fel, ha az szabad. A monitor kihúzáskor is megtartja a munkaterületeit: azok egy másik képernyőéhez csatlakoznak, az ott már meglévők után számozva, és a monitor visszatérésekor visszakapják a régi számaikat.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, átrendezheted, hol helyezkedjen el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Az ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zárhatod be (és az összes ablakot a `Ctrl + Alt + Delete` billentyűkombinációval).

Teljes képernyőre is válthatsz a `Super + F` billentyűkombinációval, vagy akár csak teljes szélességre (a felső sáv megtartásával) a `Super + Alt + F` billentyűkombinációval, vagy teljes képernyőre egy ablakon belül a `Super + Ctrl + F` billentyűkombinációval (YouTube-hoz jó!).

### Dwindle vs. görgetős elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Az egy munkaterületen megnyitott összes ablakot mindig láthatóan tartja, még akkor is, ha ehhez össze kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De azt is választhatod, hogy egy munkaterületet görgetős elrendezéssé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` billentyűkombinációval alakíthatsz át erre az elrendezésre.

A `Super + L` ismételt megnyomása lebegővé teszi a munkaterületet, ahol az ablakok szabadon átfedik egymást, és te helyezed el őket, egy harmadik megnyomás pedig visszaállítja dwindle-re. A `Super + Alt + L` a másik irányban megy végig rajtuk. Az az ablak, amely amúgy is lebeg — amelyet a `Super + T` billentyűkombinációval ugrasztottál ki, vagy egy alkalmazás, amely mindig lebegve nyílik meg — lebegve marad, amikor a munkaterület visszatér a csempézéshez. A felső sáv az aktuális munkaterületet az elrendezésével jelöli: négyzet a dwindle-hez, kör a görgetőshöz és háromszög a lebegőhöz. Erre a jelre kattintva szintén váltogathatod az elrendezést.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A választás munkaterületenként érvényes, és megmarad. Így az 1. munkaterületet dwindle-en tarthatod böngészéshez, a 2. munkaterületet görgetősön kódoláshoz, és újraindítás után is így térnek vissza.

Ha a görgetős elrendezést szeretnéd alapértelmezettként használni, ezt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

A lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te mozgatod és méretezed őket. Minden ablak címsort kap a témád színeiben, minimalizáló, maximalizáló és bezáró gombokkal. A `Super + M` szintén minimalizálja a fókuszban lévő ablakot. A minimalizált ablak a dokkban várakozik; kattints az alkalmazására a visszahozásához. Kattints egy ablakra, hogy előtérbe hozd. Bármelyik széléről vagy sarkáról átméretezheted. Dupla kattintás a címsoron maximalizálja az ablakot úgy, hogy a felső sáv látható marad, újabb dupla kattintással pedig visszakapja a régi méretét. A Chrome és a többi Chromium-alapú böngésző, a Disks és a Document Viewer kihagyja a címsort, és helyette a saját fejlécét használja; a `Super + Alt + F` maximalizálja őket, a `Super + M` pedig minimalizálja őket.

A lebegő munkaterület egy dokkot is megjelenít a rögzített alkalmazásaiddal, minden futó alkalmazással, valamint az alkalmazások gombja mögött minden alkalmazás rácsával, amelyet a `Super + Alt + Space` és az Omarchy menüben az _Apps_ is megnyit. Kattints jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt az eltávolításához. Kattints egy alkalmazásra a megnyitásához, vagy ablakának előtérbe hozásához; kattints újra az ablakai közötti váltáshoz. A középső kattintás új ablakot nyit. Húzz egy ikont a dokk mentén az áthelyezéséhez; ha egy futó alkalmazást a többi közé húzol, ott marad. Kattints jobb gombbal egy alkalmazás dokkban tartásához, onnan való kivételéhez vagy bezárásához. A dokk kitér a teljes képernyős ablak útjából. Kattints jobb gombbal az alkalmazások gombjára, hogy a dokkot másik szélére helyezd, vagy elrejtsd, amíg a mutató el nem éri a szélét. A pozíció az _Appearance > Dock > Dock Position_ alatt is megtalálható, és az `omarchy dock position left` és az `omarchy dock autohide on` mindkettőt beállítja terminálból. A dokkban tartott alkalmazások halványan jelennek meg, amíg nem futnak.

Az új munkaterületek, és azok, amelyeknek nem adtál saját elrendezést a `Super + L` billentyűkombinációval, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet erre állít át, míg az, amelyiken ablakok vannak, megtartja a jelenlegi elrendezését. A dokkra minimalizált ablak továbbra is az elhagyott munkaterületen lévő ablaknak számít. Az _Appearance > Workspace Layout_ alatt választhatod ki: Tiling, Scrolling vagy Floating. Az `omarchy-hyprland-workspace-layout-default scrolling` terminálból állítja be.

### Ablakok csoportosítása

Az ablakokat a `Super + G` billentyűkombinációval csoportosíthatod. Miután csoportba kerültél, minden ablak, amelyet ennek aktív állapota közben indítasz, a csoporthoz fog tartozni. Ezek között a csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval mozoghatsz, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval közvetlenül a csoportosított ablakokhoz ugorhatsz sorrendben.

Egy ablakot a `Super + Alt + G` billentyűkombinációval mozgathatsz ki a csoportosításból, vagy a `Super + G` ismételt megnyomásával az egész csoportot feloszlathatod. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` billentyűkombinációval mozgathatod be a csoportba.

### Ablakok kiugrasztása

A `Super + O` billentyűkombinációval kiugraszthatsz egy ablakot a munkaterületi helyéről. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Remek videólejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amely ráfed arra a munkaterületre, amelyiken éppen vagy. A rajta lévő tartalmat a `Super + S` billentyűkombinációval éred el, az ablakokat pedig a `Super + Alt + S` billentyűkombinációval helyezed oda.

Jól működik vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake-konzol

Végül van egy félmagasságú Quake-konzol, amely legördül arra a munkaterületre, amelyiken éppen vagy. A `Super + Grave` billentyűkombinációval kapcsolhatod ki és be, és a `Super + Shift + Grave` billentyűkombinációval helyezhetsz oda ablakot.

Az alapértelmezett agenteddel készen állva nyílik meg. Amíg a konzol egyetlen ablakot tart, középre igazított panelként gördül le ahelyett, hogy átérné a képernyőt. Tegyél rá egy második alkalmazást, és visszatér a teljes szélességre, így a kettőnek van helye egymás mellett elhelyezkedni.

Ha egy ablakot le szeretnél mozgatni akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valami olyasmivel, mint a `Super + Shift + 1`.

### Kell egy kis megszokás!

Kell egy kis idő, amíg megszokod, hogy így navigálj az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni a hagyományos, egérvezérelt asztali élményhez!
