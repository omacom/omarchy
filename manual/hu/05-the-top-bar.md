# A felső sáv

A képernyőd tetején végigfutó csík az Omarchy sáv. Ez nem egy odacsavarozott állapotsáv, hanem az Omarchy shell része, annak az egyetlen hosszú futású Quickshell-folyamatnak a része, amely a menüt, az értesítéseket, az OSD-felugró ablakokat és a zárolási képernyőt is rajzolja. Ezért illeszkedik tökéletesen minden máshoz a témában, és ezért nyílik meg egy panel azonnal, ahelyett, hogy új appot indítana.

Ez az asztal egyetlen olyan része is, amely mindig a képernyőn van, ezért érdemes tudni, mit csinálnak azok a kis jelek mind.

## Mi van rajta alapértelmezetten

A sávnak három szakasza van. A bal oldalon ül az Omarchy logó (a menüindító) és a munkaterület-jelzők. Középen kapod meg az állapotjelzőket, az órát, az Elsewhen világórát, az időjárást és egy Omarchy-frissítési jelvényt. A jobb oldalon: a billentyűzetkiosztás (ha egynél több van beállítva), a rendszertálca, az agentek, a bluetooth, a hálózat, a hang, a kijelző és az energia.

Néhány közülük csak akkor jelenik meg, ha van mondanivalója. A billentyűzetkiosztás csak akkor jelenik meg, ha egynél több kiosztást állítottál be. A frissítési jelvény csak akkor jelenik meg, ha egy Omarchy-frissítés vár rád. Az agentek ikonja pedig akkor jelenik meg először, amikor az Omarchy AI-kódolási használatot talál a gépen (lásd az [AI-t](17-ai.md)).

## Kattintgatás

Szinte minden widget csinál valamit bal, jobb és középső kattintásra, és több reagál a görgetésre is. Ezt a részt szokták az emberek kihagyni — a jobb és a középső gombokban rejtőzik sok jó dolog.

| Widget | Bal | Jobb | Középső / görgetés |
| --- | --- | --- | --- |
| Menü | Omarchy menü | Új terminál | — |
| Munkaterületek | Fókusz arra a munkaterületre | — | Görgetés: következő/előző munkaterület |
| Óra | Naptár-felugró ablak | A címkeformátum váltása | Középső: időzóna-választó |
| Időjárás | Előrejelzés-felugró ablak | Teljes időjárás értesítésként | Középső: frissítés |
| Hang | Hangpanel | Némítás | Középső: panel · görgetés: hangerő |
| Mikrofon | A mikrofon némítása | — | Középső: hangpanel · görgetés: bemeneti hangerő |
| Hálózat | Hálózati panel | — | — |
| Bluetooth | Bluetooth-panel | A rádió be-/kikapcsolása | — |
| Kijelző | Kijelzőpanel | — | Görgetés: fényerő |
| Energia | Energiapanel | Az akku százalékának megjelenítése/elrejtése | — |
| Média | Lejátszás/szünet | Borítókép-felugró ablak | Középső: következő · görgetés: előző/következő |
| Agentek | Agentpanel | Az agented indítása | Középső: következő előfizetés |
| Tálca | Hoverrel a fiók előhozása | Jobb kattintás a chevronon a kezeléshez | — |
| Omarchy-frissítés | A frissítés futtatása | — | — |

Ebben a táblázatban nem minden van kint a sávodon a dobozból kivéve. A médiawidget (MPRIS now-playing, görgetődő szám- és előadócímmel) és a mikrofonwidget is beépített, de alapértelmezetten ki vannak kapcsolva — add hozzá őket, ha szeretnéd, az alábbiak szerint.

## A panelek

Egy sávikonra kattintva panel nyílik meg, amely rendes felugró ablak csúszkákkal, listákkal és billentyűzetes navigációval, nem pedig egy eszköztipp. Mindegyikhez tartozik billentyűparancs is, így soha nem kell egy 16 pixeles jelre céloznod:

| Billentyűparancs | Panel |
| --- | --- |
| `Super + Ctrl + A` | Hang |
| `Super + Ctrl + W` | Hálózat |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Kijelző |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Naptár |
| `Super + Ctrl + Alt + E` | Világóra |
| `Super + Ctrl + 1-9` | A jobb szakasz n-edik paneljének kapcsolása |

A panelek nem kiolvasók. Itt tudod tényleg elvégezni a dolgot:

- Az **Audio** panelen fő hangerőcsúszka, kimenetieszköz-választó és appenkénti keverő van, így lehalkíthatod azt az egyetlen böngészőfülön lévő dolgot anélkül, hogy minden máshoz hozzányúlnál.
- A **Hálózat** panel Wi-Fi-t keres, mutatja a jelerősséget, csatlakozik, és lehetővé teszi DNS-szolgáltató választását.
- A **Bluetooth** panel felsorolja az eszközeidet csatlakoztatás/leválasztás funkcióval és akkuszinttel.
- Az **Energia** panel mutatja az akkustatisztikákat, váltja a teljesítményprofilokat (külön választást jegyez meg akkura és AC-re), és néhány rendszerinfót kiír.
- A **Kijelző** panelen fényerőcsúszka, szövegméret, monitorméretezési előbeállítások vannak — és ha egynél több képernyőd van — monitoronkénti vezérlők. A mélyebb történetért lásd a [monitorokat](33-monitors.md).
- Az **Óra** egy hónapos rácsot nyit ISO-hétszámokkal és hónap léptetéssel.

Minden panel fogadja a billentyűzetet és az egeret is: a nyilak mozognak, a Return aktivál, a Tab a szomszédos panelre lép, az Escape pedig bezár.

A `Super + Ctrl + 1-9` a jobb szakaszban számolja a paneleket balról jobbra, kihagyva a tálcát, mivel annak nincs saját panelje. Így a szám megegyezik azzal az ikonnal, amelyre mutatnál.

### Tailscale és Dropbox

Két további widget csak akkor jelenik meg a sávon, ha a megfelelő szolgáltatást a **Telepítés → Szolgáltatás** pontból telepíted, és mindkettőről érdemes tudni, mert többet tesznek, mint hogy állapotot jelentenek.

A **Tailscale** panel csatlakoztatja és leválasztja a tailnetet, vált a fiókok között, és kiválaszt egy exit node-ot (a saját gépeid és a Mullvad-régiók egyaránt megjelennek ezen a listán). Böngészni is lehet vele a gépeid között — és ha egyet kiválasztasz, az `s` fájlokat küld neki Taildroppal, amely a leggyorsabb módja annak, hogy egy fájlt a telefonodra vagy egy másik laptopra mozgass. A `c` másolja a gép IP-jét, az `n` a nevét és a `d` a teljes DNS-nevét. Minden gépsoron van küldés gomb is, ha inkább kattintanál. Terminálból ugyanez: `omarchy tailscale send <machine> [file...]`.

A **Dropbox** panel kezeli a bejelentkezést, mutatja, mennyi tárhelyet használtál el, és felsorolja a nemrég szinkronizált fájlokat.

Bármelyik szolgáltatás eltávolítása leveszi a widgetjét a sávról.

## Jelzők

A középen lévő kis fürt az indicators widget. Ezek állapotjelek olyan módokhoz, amelyeket bekapcsoltál: ne zavarjanak, éjszakai fény, egy sorban álló [emlékeztető](09-reminders.md), aktív képernyőfelvétel, ébren maradás és [diktálás](11-text-extraction-dictation.md). Kigyulladnak, amikor a mód aktív, máskülönben félreesők maradnak — vigyd az egeret az óra bal oldalához (függőleges sávon fölé), hogy beless az inaktívakba. Egy jelzőre kattintás be- és kikapcsolja azt a módot. Egy további csak állapotot mutat: egy távoli munkamenet pirosan világít, amíg valaki gliffen keresztül csatlakozik ehhez a géphez.

Ha inkább mindig láthatóknak szeretnéd őket, állítsd az `alwaysShow` értékét `true`-ra a widgeten. És ha csak néhány érdekel közülük, sorold fel a kívántakat az `items` mezőben: `["Dnd", "Reminder", "NightLight"]`. Egynél több indicators widgeted is lehet, így a különböző szakaszok eltérő részhalmazokat mutathatnak.

## A sáv átrendezése

A sáv magától konfigurálódik. Nem kell konfigurációs fájlt nyitnod a dolgok elmozdításához.

Fogj meg egy üres foltot a sávon a középpont körül, és húzd egy másik képernyőél felé, és a sáv odamegy — bal, jobb, fent vagy lent mind működik, és minden widget alkalmazkodik (a függőleges sávok kompakt, csak ikonokat mutató formákra térnek vissza). Ugyanazt a húzást egy kattintás és tartás is elindítja. Kattints duplán ugyanazon az üres helyen, hogy a sáv hátterét átlátszóról üvegesre és átlátszatlanra ciklikusan váltsd. És bármelyik widgetet húzhatod az átrendezéséhez vagy egy másik szakaszba dobásához.

Egy widget, amelyet kéznél tartanál, de nem szeretnél mindig szem előtt tudni, mehet a tálca fiókjába is: húzd rá a tálcára, és a fiók kinyílik, hogy átvegye. Ott ül az appikonok után, megjelenik, valahányszor a fiók megjelenik, és nyitva tartja a fiókot, amíg a panelje nyitva van. Húzd vissza a sávra, hogy visszatedd.

Ha inkább menüből választanál, a **Trigger → Appearance → Menu Bar** pontban ott a pozíció, a **Bar Background** pedig azt választja ki, hogyan rajzolódjon a sáv: **Opaque Bar**, **Glassy Bar** (átlátszó, a mögötte lévő elmosásával) vagy **Clear Bar**.

Ugyanezekhez parancsok is tartoznak, amelyeket egy [dotfiles](31-dotfiles.md) beállításhoz szeretnél:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Egy widget teljes hozzáadásához vagy eltávolításához használd a pluginparancsokat. Az `omarchy plugin list` minden widgetet kiír, amelyet a shell ismer, az azonosítójával együtt, majd:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## A sáv elrejtése

A `Super + Shift + Space` ki- és bekapcsolja a sávot a shell leállítása nélkül — a panelek és a billentyűparancsok tovább működnek, csak visszakapod a pixeleket. A menüben is ott van a **Trigger → Appearance → Menu Bar → Hide Bar** alatt.

## A konfigurációs fájl

Mindez a `~/.config/omarchy/shell.json` fájlban tárolódik, a `bar` kulcs alatt. Íme egy kurtított változat:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Minden widget egyetlen bejegyzés a három layout-tömb egyikében, és a beállításai soron belül, azon a bejegyzésen ülnek — nincs külön beállításfájl és nincs `config` alobjektum. Az óra `format`, `formatAlt` (amire a jobb kattintás ciklusban vált) és `verticalFormat` értékei mind ott élnek a `{ "id": "omarchy.clock" }` bejegyzésen.

A `centerAnchor` nevezi meg azt az egyetlen középső widgetet, amely a képernyő pontos közepére rögzül, a többi pedig körülötte. Így marad az óra halottan középen, még akkor is, amikor az időjárás és a frissítési jelvény jön és megy. Állítsd üres stringre, és a középső lista ehelyett csak csoportként középeződik.

Egy érdemes beidegzendő szabály: **ha egyszer megvan a saját `shell.json` fájlod, az a mérvadó**. Amíg semmit sem szabtál testre, a shell az Omarchy alapértelmezett fájlját olvassa. Abban a pillanatban, amikor egy widgetet húzol, az `omarchy bar` parancsot futtatod, vagy magad szerkeszted a fájlt, a tiéd lesz — nincs mély egyesítés, így a jövőbeli Omarchy-kiadások új alapértelmezett widgetei nem jelennek meg automatikusan a sávodon. Az `omarchy bar defaults` bármikor visszaállítja a szállított kiosztást, amikor tiszta lapot szeretnél.

Ugyanez a fájl a `bar` kulcson kívül, legfelső szinten az üresjárati időzítéseidet is tárolja: `idle.screensaver` és `idle.lock`, mindkettő másodpercben attól számítva, hogy mikor mentél üresjáratba. Így az alapértelmezett képernyővédő 150 másodpercnél kapcsol be, a zárolás pedig 300-nál.
