# Navigáció

Az Omarchyban minden billentyűzettel történik — _MINDEN!_ Amikor a rendszer először elindul, egérrel önmagában szó szerint semmit sem tudsz csinálni. De megnyomhatod a `Super + Space` billentyűkombinációt az Omarchy Menu megjelenítéséhez, és innen szinte mindent meg tudsz csinálni.

De az Omarchy menünek még csak nem is az a rendeltetése, hogy az idő nagy részében ez legyen a rendszer kezelésének fő módja. Ennél gyorsabbak is tudunk lenni! Az összes legfontosabb alkalmazás közvetlenül egyedi gyorsbillentyűkhöz van kötve. A terminált a `Super + Return` billentyűkombinációval, a böngészőt pedig a `Super + Shift + Return` billentyűkombinációval indítod. Próbáld meg egymás után megnyomni őket, és látni fogod a Hyprland csempézésének varázsát működés közben:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ezután megnyomhatod a `Super + J` billentyűkombinációt, hogy egymás mellé helyett egymásra rakja őket:

 ![navigation-stacked](images/navigation-stacked.webp)

Nyomd meg ismét a `Super + J` billentyűkombinációt, hogy visszakerüljenek egymás mellé. Ezután próbáld ki a `Super + Shift + Arrow Right` billentyűkombinációt a böngészőn, hogy felcseréld az ablakokat.

Most próbáld ki a `Super + Shift + T` billentyűkombinációt az Activity monitor elindításához. Az lebegő ablakként jelenik meg. Csempézheted a `Super + T` billentyűkombinációval (és ismét megnyomva újra lebegővé teheted). Most nyomd meg a `Super + Shift + F` billentyűkombinációt a fájlkezelő megnyitásához. Szép négyes elrendezésed lesz:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

A `Super + Arrow` billentyűkombinációval navigálhatsz az ablakok között, amelyek közül ki akarod választani az aktívat. Ez átváltja a fókuszt, és a kurzort az új alkalmazás közepére mozgatja. A képernyő szélén továbbhalad az azon az oldalon lévő monitorra.

Ha megnyomod a `Super + Shift + 2` billentyűkombinációt, az aktuálisan fókuszált alkalmazást a második munkaterületre mozgatod. A `Super + Shift + 1` visszateszi. (A `Super + Shift + Alt + 2` pedig az aktuálisan fókuszált alkalmazást a második munkaterületre mozgatja anélkül, hogy átváltana rá).

Több monitor esetén minden monitornak saját, 1-től 10-ig terjedő munkaterületei vannak. A `Super + 2` az éppen használt monitor második munkaterületére visz, és minden monitor felső sávja a saját munkaterületeit és az éppen megjelenítettet mutatja. A `Super + Tab` végigléptet az éppen használt monitor munkaterületein. A `Super + Shift + Ctrl + Arrows` az éppen használt ablakot abban az irányban lévő monitorra mozgatja, az ott éppen megjelenített munkaterületre, a `Super + Shift + Alt + Arrows` pedig az éppen használt munkaterületet mozgatja át abban az irányban lévő monitorra, ahol ugyanazt a számot veszi fel, ha az szabad. A monitor megtartja a munkaterületeit, amikor kihúzod: azok egy másik képernyő munkaterületeihez csatlakoznak, az ott már meglévők után számozva, és visszakerülnek a régi számaik alá, amikor a monitor visszatér.

Ha lenyomva tartod a `Super` billentyűt, és az egérrel egy ablakra kattintasz, átrendezheted, hol helyezkedik el. Ha lenyomva tartod a `Super` billentyűt, és az egér jobb gombját használod, szabadon átméretezheted az ablakot.

Ablakot a `Super + W` vagy a `Super + Q` billentyűkombinációval zársz be (az összes ablakot pedig a `Ctrl + Alt + Delete` billentyűkombinációval).

Teljes képernyőre is válthatsz a `Super + F` billentyűkombinációval, vagy akár csak teljes szélességre (a felső sáv megtartásával) a `Super + Alt + F` billentyűkombinációval, illetve teljes képernyőre egy ablakon belül a `Super + Ctrl + F` billentyűkombinációval (jó a YouTube-hoz!).

### Dwindle és görgetős elrendezés

Az Omarchy alapértelmezett elrendezését dwindle-nek hívják. Egyetlen munkaterületen az összes megnyitott ablakot mindenkor láthatóan tartja, még ha ehhez össze is kell zsugorítania őket.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

De azt is választhatod, hogy egy munkaterületet görgetős elrendezéssé alakítasz, ahol az ablakok egymás mellett sorakoznak, a kijelző látható szélén túl. Egyetlen munkaterületet a `Super + L` billentyűkombinációval alakítasz át erre az elrendezésre.

A `Super + L` ismételt megnyomása lebegővé teszi a munkaterületet, ahol az ablakok szabadon átfedik egymást, és te magad helyezed el őket, egy harmadik megnyomás pedig visszaviszi dwindle-re. A `Super + Alt + L` fordított irányban halad végig rajtuk. Az az ablak, amely amúgy is lebeg — amelyet a `Super + T` billentyűkombinációval ugrattál ki, vagy egy olyan alkalmazás, amely mindig lebegve nyílik meg — lebegő marad, amikor a munkaterület visszatér a csempézéshez. A felső sáv az éppen használt munkaterületet az elrendezésével jelöli: négyzettel a dwindle-t, körrel a görgetőset és háromszöggel a lebegőt. Erre a jelre kattintva szintén végigléptethetsz az elrendezéseken.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A választás munkaterületenként történik, és megmarad. Így az 1. munkaterületet dwindle-en tarthatod böngészéshez, a 2. munkaterületet pedig görgetősön kódhoz, és újraindítás után is így térnek vissza.

Ha a görgetős elrendezést szeretnéd alapértelmezettként használni, azt a `~/.config/hypr/looknfeel.lua` fájlban állíthatod be:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebegő munkaterületek

A lebegő munkaterület úgy működik, mint egy hagyományos asztal: az ablakok átfedik egymást, és te magad mozgatod és méretezed őket. Minden ablak címsort kap a témád színeiben, a minimalizáláshoz, maximalizáláshoz és bezáráshoz szükséges gombokkal. A `Super + M` a fókuszált ablakot is minimalizálja. A minimalizált ablak a dokkban várakozik; kattints az alkalmazására, hogy visszahozd. Kattints egy ablakra, hogy előtérbe hozd. Méretezd át bármelyik széléről vagy sarkáról. Kattints duplán egy címsorra, hogy maximalizáld az ablakot, miközben a felső sáv látható marad, és ismét, hogy visszakapd a régi méretét.

A lebegő munkaterület dokkot is mutat, a rögzített alkalmazásaiddal, mindennel, ami fut, és minden alkalmazás rácsával az alkalmazások gomb mögött, amelyet a `Super + Alt + Space` és az Omarchy menüben az _Apps_ is megnyit. Kattints jobb gombbal egy alkalmazásra a rácson, vagy nyomd meg a `Delete` billentyűt az eltávolításához. Kattints egy alkalmazásra a megnyitásához, vagy az ablakának előtérbe hozásához; kattints ismét, hogy végigléptess az ablakain. A középső kattintás új ablakot nyit. Húzz egy ikont a dokk mentén a mozgatásához; egy futó alkalmazás behúzása a többi közé ott tartja azt. Kattints jobb gombbal egy alkalmazás dokkban tartásához, onnan való kivételéhez vagy kiléptetéséhez. A dokk félreáll egy teljes képernyős ablak útjából. Kattints jobb gombbal az alkalmazások gombra, hogy a dokkot egy másik szélre mozgassa, vagy elrejtse, amíg a mutató el nem éri a szélét. A pozíció az _Appearance > Dock > Dock Position_ alatt is megtalálható, és az `omarchy dock position left` és az `omarchy dock autohide on` mindkettőt beállítja terminálból. A dokkban tartott alkalmazások halványak, amíg nem futnak.

Az új munkaterületek, és minden olyan, amelynek nem adtál saját elrendezést a `Super + L` billentyűkombinációval, az alapértelmezett elrendezést használják. Az alapértelmezett megváltoztatása minden ablak nélküli munkaterületet visszaállít arra, míg az, amelyen ablakok vannak, megtartja a meglévő elrendezését. A dokkba minimalizált ablak továbbra is ablaknak számít azon a munkaterületen, amelyet elhagyott. Válaszd ki az _Appearance > Workspace Layout_ alatt: Tiling, Scrolling vagy Floating. Az `omarchy-hyprland-workspace-layout-default scrolling` terminálból állítja be.

### Ablakok csoportosítása

Az ablakok a `Super + G` billentyűkombinációval csoportosíthatók. Ha már csoportban vagy, minden ablak, amelyet aközben indítasz, amíg az aktív, a csoporthoz fog tartozni. A csoportosított ablakok között a `Super + Ctrl + Arrow Left/Right` billentyűkombinációval mozoghatsz, vagy a `Super + Alt + 1/2/3/4` billentyűkombinációval közvetlenül a sorrendben lévő csoportosított ablakra ugorhatsz.

Egy ablakot a `Super + Alt + G` billentyűkombinációval mozgathatsz ki a csoportosításból, vagy a `Super + G` ismételt megnyomásával az egész csoportot szétbonthatod. Végül a csoporton kívüli ablakokat a `Super + Alt + Arrows` billentyűkombinációval mozgathatod be a csoportba.

### Ablakok kiugratása

A `Super + O` billentyűkombinációval kiugrathatsz egy ablakot a munkaterületi kiosztásából. Ez lebegő ablakként rögzíti, amely követ téged, bármelyik munkaterületre is mész. Nagyszerű videolejátszókhoz és hasonlókhoz.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad munkaterület

Van egy speciális, teljes méretű scratchpad munkaterület, amely rárakódik arra a munkaterületre, amelyen éppen vagy. A rajta lévő dolgokat a `Super + S` billentyűkombinációval éred el, és ablakokat a `Super + Alt + S` billentyűkombinációval helyezel oda.

Jól működik vezérlőkhöz vagy egy terminálhoz, amellyel gyorsan szeretnél interakcióba lépni anélkül, hogy elhagynád az aktuális munkaterületet.

### Quake-konzol

Végül van egy félmagasságú Quake-konzol, amely legördül arra a munkaterületre, amelyen éppen vagy. A `Super + Grave` billentyűkombinációval kapcsolhatod be és ki, és a `Super + Shift + Grave` billentyűkombinációval helyezhetsz oda egy ablakot.

Az alapértelmezett agenteddel nyílik meg, indulásra készen. Amíg a konzol egyetlen ablakot tartalmaz, középre igazított panelként gördül le, ahelyett, hogy átérné a képernyőt. Tegyél rá egy második alkalmazást, és visszavált teljes szélességre, hogy a kettőnek legyen helye egymás mellett ülni.

Ahhoz, hogy egy ablakot lemozgass akár a scratchpadről, akár a konzolról, küldd közvetlenül egy másik munkaterületre valami olyasmivel, mint a `Super + Shift + 1`.

### Meg kell szokni!

Kell egy kis idő, amíg megszokod, hogy így navigálj az asztalodon, de ha egyszer megszokod, nehéz lesz visszatérni a hagyományos, egérvezérelt asztali élményhez!
