# Navigáció

Az Omarchyban minden billentyűzettel történik — _MINDEN!_ Amikor a rendszer először elindul, szó szerint semmit sem tudsz csinálni csak az egérrel. De megnyomhatod a `Super + Space` billentyűket az Omarchy menü előhozásához, és innen szinte mindent meg tudsz csinálni.

De az Omarchy menünek a legtöbb esetben még csak nem is az a célja, hogy ez legyen a rendszer kezelésének fő módja. Ennél gyorsabbak is tudunk lenni! Az összes legfontosabb alkalmazás közvetlenül egyedi gyorsbillentyűkhöz van kötve. A terminált a `Super + Return`, a böngészőt pedig a `Super + Shift + Return` billentyűkkel indítod el. Próbáld ki őket egymás után, és működés közben fogod látni a Hyprland csempézésének varázsát:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűket, hogy egymás mellé helyett egymásra halmozd őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg újra a `Super + J` billentyűket, hogy visszaálljanak egymás mellé. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűket, miközben a böngészőben vagy, az ablakok felcseréléséhez.

Most próbáld ki a `Super + Shift + T` billentyűket az Activity monitor elindításához. Ez lebegő ablakként fog megjelenni. Csempézheted a `Super + T` használatával (és ha újra megnyomod, ismét lebegővé válik). Most nyomd meg a `Super + Shift + F` billentyűket a fájlkezelő megnyitásához. Egy szép négyes elrendezést kapsz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` billentyűkkel navigálsz az aktívvá tenni kívánt ablakok között. Ezzel átváltod a fókuszt, és a kurzort az új alkalmazás közepére mozgatod. Egy képernyő szélénél ez továbbvisz az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűket, az éppen fókuszban lévő alkalmazást a második munkaterületre mozgatod. A `Super + Shift + 1` visszahozza. (A `Super + Shift + Alt + 2` pedig az éppen fókuszban lévő alkalmazást a második munkaterületre mozgatja anélkül, hogy átváltanál rá.)

Több monitor esetén minden monitornak saját, 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` az éppen használt monitor második munkaterületére visz, és minden monitor felső sávja a saját munkaterületeit mutatja, és azt, amelyiket éppen mutatja. A `Super + Tab` végiglépeget az éppen használt monitor munkaterületein. A `Super + Shift + Ctrl + Arrows` az éppen használt ablakot az adott irányban lévő monitorra mozgatja, az ott mutatott munkaterületre, a `Super + Shift + Alt + Arrows` pedig az éppen használt munkaterületet mozgatja át az adott irányban lévő monitorra, ahol ugyanazt a számot kapja, ha az szabad. Egy monitor megtartja a munkaterületeit, amikor kihúzod: azok csatlakoznak egy másik képernyő munkaterületeihez, az ott már meglévők után számozva, és visszakapják a régi számaikat, amikor a monitor visszatér.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, át tudod rendezni, hol üljön. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Egy ablakot a `Super + W` vagy a `Super + Q` billentyűkkel zársz be (és az összes ablakot a `Ctrl + Alt + Delete` billentyűkkel).

Teljes képernyős módba is válthatsz a `Super + F` billentyűkkel, vagy akár csak teljes szélességűre (a felső sáv megtartásával) a `Super + Alt + F` billentyűkkel, vagy egy ablakon belül teljes képernyősre a `Super + Ctrl + F` billentyűkkel (jó a YouTube-hoz!).

### Dwindle vs scrolling elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Minden ablakot, amit megnyitsz, folyamatosan láthatóan tart egyetlen munkaterületen, még akkor is, ha ehhez össze kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De dönthetsz úgy is, hogy egy munkaterületet scrolling elrendezéssé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` segítségével alakítasz át erre az elrendezésre.

A `Super + L` ismételt megnyomása lebegővé teszi a munkaterületet, ahol az ablakok szabadon átfedik egymást, és te helyezed el őket, egy harmadik megnyomás pedig visszaviszi dwindle-be. A `Super + Alt + L` a másik irányban halad végig rajtuk. Egy ablak, amely eleve lebeg — egy olyan, amit a `Super + T` segítségével pattintottál ki, vagy egy alkalmazás, amely mindig lebegve nyílik meg — lebegő marad, amikor a munkaterület visszamegy csempézésre. A felső sáv a munkaterületet, amelyen vagy, az elrendezésével jelöli: négyzet a dwindle esetén, kör a scrolling esetén, és háromszög a lebegő esetén. Erre a jelre kattintva szintén végig tudsz lépegetni az elrendezésen.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A döntés munkaterületenként érvényes, és megmarad. Így megtarthatod az 1. munkaterületet dwindle-ben böngészésre, a 2. munkaterületet scrollingban kódolásra, és újraindítás után is így fognak visszatérni.

Ha a scrolling elrendezést szeretnéd alapértelmezettként használni, ezt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

Egy lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te mozgatod és méretezed őket. Minden ablak címsort kap a témád színeiben, minimalizáló, maximalizáló és bezáró gombokkal. A `Super + M` szintén minimalizálja a fókuszban lévő ablakot. Egy minimalizált ablak a dockban vár; kattints az alkalmazására, hogy visszahozd. Kattints egy ablakra, hogy előtérbe hozd. Bármelyik szélétől vagy sarkától átméretezheted. Kattints duplán egy címsorra, hogy maximalizáld az ablakot, miközben a felső sáv látható marad, és kattints duplán újra, hogy visszakapd a régi méretét.

Egy lebegő munkaterület dockot is mutat, a rögzített alkalmazásaiddal, mindennel, ami éppen fut, és minden alkalmazás rácsával az alkalmazások gombja mögött, amelyet a `Super + Alt + Space` és az Omarchy menü _Apps_ eleme is megnyit. Kattints jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt, hogy eltávolítsd. Kattints egy alkalmazásra, hogy megnyisd, vagy hogy előtérbe hozd az ablakát; kattints újra, hogy végiglépegess az ablakain. A középső kattintás új ablakot nyit. Húzz egy ikont a dock mentén, hogy áthelyezd; ha egy futó alkalmazást a többi közé húzol, az ott tartja. Kattints jobb gombbal, hogy egy alkalmazást a dockban tarts, kivedd onnan, vagy kilépj belőle. A dock félreáll egy teljes képernyős ablak útjából. Kattints jobb gombbal az alkalmazások gombjára, hogy a dockot egy másik élre helyezd, vagy hogy rejtve maradjon, amíg a mutató el nem éri az élét. A pozíció az _Appearance > Dock > Dock Position_ alatt is elérhető, és az `omarchy dock position left` és az `omarchy dock autohide on` egy terminálból mindkettőt beállítja. Azok az alkalmazások, amelyeket a dockban tartasz, elhalványulnak, amíg nem futnak.

Az új munkaterületek, és minden olyan, amelynek nem adtál saját elrendezést a `Super + L` segítségével, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet arra állít vissza, míg egy olyan, amelyen ablakok vannak, megtartja a meglévő elrendezését. Egy dockra minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Válaszd ki az _Appearance > Workspace Layout_ alatt: Tiling, Scrolling vagy Floating. Az `omarchy-hyprland-workspace-layout-default scrolling` egy terminálból állítja be.

### Ablakok csoportosítása

Ablakokat a `Super + G` segítségével lehet csoportosítani. Ha egyszer egy csoportban vagy, minden ablak, amelyet aközben indítasz, a csoporthoz fog tartozni. Ezek között a csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkkel tudsz mozogni, vagy a `Super + Alt + 1/2/3/4` billentyűkkel, hogy közvetlenül a csoportosított ablakokhoz ugorj sorrendben.

Egy ablakot a `Super + Alt + G` segítségével tudsz kivenni a csoportosításból, vagy a teljes csoportot szét tudod szedni a `Super + G` ismételt megnyomásával. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` segítségével tudod behelyezni a csoportba.

### Ablakok kipattintása

Egy ablakot a `Super + O` segítségével ki tudsz pattintani a munkaterület-kiosztásából. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Nagyszerű videolejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amely ráhelyeződik arra a munkaterületre, amelyen éppen vagy. Az ott lévőket a `Super + S` segítségével éred el, és ablakokat a `Super + Alt + S` segítségével helyezel oda.

Ez jól működik vezérlőknek vagy egy terminálnak, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake konzol

Végül van egy félmagasságú Quake konzol, amely leereszkedik bármelyik munkaterület fölé, amelyen éppen vagy. A `Super + Grave` billentyűvel tudod ki-be kapcsolni, és egy ablakot a `Super + Shift + Grave` segítségével tudsz oda helyezni.

Az alapértelmezett agenteddel nyílik meg, munkára készen. Amíg a konzol egyetlen ablakot tart, középre helyezett panelként ereszkedik le, ahelyett, hogy átfogná a képernyőt. Tegyél rá egy második alkalmazást, és visszaáll teljes szélességűre, így a kettőnek van helye egymás mellett ülni.

Ahhoz, hogy egy ablakot elvigyél akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valamivel, például a `Super + Shift + 1` billentyűkkel.

### Kell egy kis idő, amíg megszokod!

Eltart egy kis ideig, amíg megszokod, hogy így navigálsz az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni egy hagyományos, egérvezérelt asztali élményhez!
