# A felső sáv

A képernyőd tetején végigfutó csík az Omarchy sáv. Nem egy ráerőltetett állapotsáv, hanem az Omarchy shell része, annak az egyetlen, hosszú életű Quickshell folyamatnak a része, amely a menüt, az értesítéseket, az OSD felugró ablakokat és a zárolási képernyőt is rajzolja. Ezért illeszkedik tökéletesen minden máshoz témában, és ezért nyílik meg egy panel azonnal, új alkalmazás indítása helyett.

Ez egyben az asztal egyetlen olyan darabja is, amely mindig a képernyőn van, úgyhogy érdemes tudni, mit csinálnak azok a kis jelek.

## Mi van rajta alapból

A sávnak három szakasza van. Bal oldalt ül az Omarchy logó (a menüindító) és a munkaterület-jelzők. Középen kapod az állapotjelzőket, az órát, az Elsewhen-t (egy világórát), az időjárást és egy Omarchy-frissítési jelvényt. Jobb oldalt: a rendszertálca, a billentyűzetkiosztás (ha egynél több van beállítva), az ügynökök, a bluetooth, a hálózat, a hang, a kijelző és az energia.

Ezek közül néhány csak akkor jelenik meg, ha van mondanivalója. A billentyűzetkiosztás csak akkor jelenik meg, ha egynél több kiosztást állítottál be. A frissítési jelvény csak akkor jelenik meg, ha Omarchy-frissítés vár rád. Az ügynökök ikonja pedig akkor jelenik meg először, amikor az Omarchy AI kódolási használatot talál a gépen (lásd: [AI](17-ai.md)).

## Kattintgatás

Szinte minden widget csinál valamit bal, jobb és középső kattintásra, és több reagál a görgetésre is. Ezt szokták az emberek elszalasztani — a jobb és a középső gomb rejti a jó dolgok nagy részét.

| Widget | Bal | Jobb | Középső / görgetés |
| --- | --- | --- | --- |
| Menü | Omarchy menü | Új terminál | — |
| Munkaterületek | Az adott munkaterület fókuszba helyezése ezen a monitoron | — | Görgetés: következő/előző munkaterület |
| Óra | Naptár felugró ablak | A címkeformátum váltogatása | Középső: időzóna-választó |
| Időjárás | Előrejelzés felugró ablak | A teljes időjárás értesítésként | Középső: frissítés |
| Hang | Hangpanel | Némítás | Középső: panel · görgetés: hangerő |
| Mikrofon | A mikrofon némítása | — | Középső: hangpanel · görgetés: bemeneti hangerő |
| Hálózat | Hálózatpanel | — | — |
| Bluetooth | Bluetooth panel | A rádió be-/kikapcsolása | — |
| Kijelző | Kijelzőpanel | — | Görgetés: fényerő |
| Energia | Energiapanel | Az akkumulátorszázalék be-/kikapcsolása | — |
| Média | Lejátszás/szünet | Borítókép felugró ablak | Középső: következő · görgetés: előző/következő |
| Ügynökök | Ügynökök panel | Az ügynököd elindítása | Középső: következő előfizetés |
| Tálca | Fölévitel a fiók felfedéséhez | Jobb kattintás a chevronra a kezeléshez | — |
| Omarchy frissítés | A frissítés futtatása | — | — |

A táblázatban szereplő dolgok közül nem minden van ott a sávodon gyárilag. A médiawidget (MPRIS éppen játszott, görgetődő számmal és előadóval) és a mikrofonwidget is be van építve, de alapból ki van kapcsolva — add hozzá őket, ha akarod, az alábbiakban leírt módon.

## A panelek

Egy sávikonra kattintva panel nyílik meg, amely egy rendes felugró ablak csúszkákkal, listákkal és billentyűzetes navigációval, nem egy eszköztipp. Mindegyiknek van gyorsbillentyűje is, így sosem kell egy 16 képpontos jelre céloznod:

| Gyorsbillentyű | Panel |
| --- | --- |
| `Super + Ctrl + A` | Hang |
| `Super + Ctrl + N` | Hálózat |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Kijelző |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Naptár |
| `Super + Ctrl + Alt + E` | Világóra |
| `Super + Ctrl + 1-9` | A jobb szakasz n-edik paneljének be-/kikapcsolása |

A panelek nem kijelzők. Ott végzed el ténylegesen a dolgot:

- Az **Audio** panelen van egy fő hangerő-csúszka, egy kimeneti eszközválasztó és egy alkalmazásonkénti keverő, így letekerheted azt az egy böngészőfület anélkül, hogy minden máshoz hozzányúlnál.
- A **Network** Wi-Fi-t keres, mutatja a jelerősséget, csatlakozik, és lehetővé teszi, hogy DNS-szolgáltatót válassz.
- A **Bluetooth** felsorolja az eszközeidet csatlakozással/leválasztással és akkumulátorszinttel.
- A **Power** akkumulátorstatisztikákat mutat, energiaprofilokat vált (külön választást jegyez meg akkumulátorra és AC-re), és némi rendszerinfót is kiír.
- A **Display** fényerő-csúszkát, szövegméretet, monitorméretezési előbeállításokat hordoz, és — ha egynél több képernyőd van — monitoronkénti vezérlőket. A mélyebb történetért lásd: [monitorok](33-monitors.md).
- A **Clock** egy hónaprácsot nyit ISO hétszámokkal és hónapléptetéssel.
- A **World clock** városonként egy sort tart, annak időjárásával és azzal, hogyan alakul ott a nap. A keresés városokat is talál, nem csak időzónákat, így Fort Lauderdale Fort Lauderdale, és nem New York. Ha a felül lévő sor rossz várost nevez meg, kattints rá, és mondd meg, hol vagy; válassz valamit egy másik időzónán, és a rendszeróra is oda ugrik, ami utazáskor jól jön. Vigyél egy város fölé, és kattints a személy gombra, hogy megmondd, ki lakik ott — sima nevek, vagy `@` GitHub-azonosítók, hogy az arcuk is jöjjön velük.

Minden panel fogadja a billentyűzetet is az egér mellett: a nyilak mozognak, a Return aktivál, a Tab a szomszédos panelre lép, az Escape pedig bezár.

A `Super + Ctrl + 1-9` a jobb szakasz paneljeit számolja balról jobbra, kihagyva a tálcát, mivel annak nincs saját panelje. Így a szám ahhoz az ikonhoz illik, amelyre mutatnál.

### Tailscale és Dropbox

Két további widget csak akkor jelenik meg a sávon, ha telepíted a hozzá tartozó szolgáltatást az **Install → Service** alól, és mindkettőt érdemes ismerni, mert többet tesznek az állapotjelentésnél.

A **Tailscale** panel csatlakoztat a tailnethez és leválaszt róla, fiókok között vált, és kilépési csomópontot választ (a saját gépeid és a Mullvad régiók is megjelennek azon a listán). Böngészi is a gépeidet — és ha egy ki van választva, az `s` fájlokat küld rá Taildrop segítségével, ami a leggyorsabb módja annak, hogy egy fájlt a telefonodra vagy egy másik laptopra juttass. A `c` a gép IP-jét másolja, az `n` a nevét, a `d` pedig a teljes DNS-nevét. Minden gépsoron van küldés gomb is, ha inkább kattintanál. Ugyanez a terminálból: `omarchy tailscale send <machine> [file...]`.

A **Dropbox** panel kezeli a bejelentkezést, mutatja, mennyi tárhelyet használtál, és felsorolja a nemrég szinkronizált fájlokat.

Bármelyik szolgáltatás eltávolítása leveszi a widgetjét is a sávról.

## Jelzők

A középen lévő kis csoport a jelzők widget. Ezek állapotjelek a bekapcsolt módjaidhoz: ne zavarjanak, éjszakai fény, egy sorban álló [emlékeztető](09-reminders.md), egy aktív képernyőfelvétel, ébren maradás és [diktálás](11-text-extraction-dictation.md). Kivilágosodnak, amikor a mód aktív, egyébként félreállnak — vigyél épp melléjük, oda, ahol az inaktívak ülnének, hogy rájuk less. Egy jelzőre kattintva átkapcsolod az adott módot. Még egy van, amely csak állapot: egy távoli munkamenet pirosan világít, miközben valaki gliff segítségével csatlakozik ehhez a géphez.

Ha inkább azt szeretnéd, hogy mindig láthatók legyenek, állítsd az `alwaysShow` értékét `true`-ra a widgeten. Ha pedig csak néhányuk érdekel, sorold fel a kívántakat az `items` alatt: `["Dnd", "Reminder", "NightLight"]`. Egynél több jelzőwidgeted is lehet, így különböző szakaszok különböző részhalmazokat mutathatnak.

## A sáv átrendezése

A sáv magától konfigurálódik. Nem kell konfigurációs fájlt nyitnod ahhoz, hogy dolgokat mozgass.

Fogj meg egy üres foltot a sávon a közép körül, és húzd egy másik képernyőszél felé, és a sáv oda mozdul — bal, jobb, fent vagy lent egyaránt működik, és minden widget alkalmazkodik (a függőleges sávok kompakt, csak ikonos formákra váltanak vissza). A kattintva tartás ugyanezt a húzást indítja. Dupla bal kattintás ugyanarra az üres helyre végiglépteti a sáv hátterét átlátszóról üvegesre átlátszatlanra. És húzz bármely widgetet az átrendezéséhez, vagy dobj át egy másik szakaszba; a többi widget szétcsúszik, hogy helyet csináljon ott, ahová érkezik.

A sáv közepe egy doboz: ami benne van, az egy csoportként középen marad, a két oldalán lévő widgetek pedig a széleihez tapadnak. Amikor egy widgetet húzol, a doboz körvonalként jelenik meg, vagy egy vonalként a sávon át, amikor üres, és beleejtheted vagy mellé ejtheted. Amikor egy ejtés a dobozba érkezne, a doboz megnő, hogy befogadja a widgetet.

Egy widget, amelyet kéznél akarsz tartani, de nem mindig szem előtt, mehet a tálca fiókjába: húzd a tálcára, és a fiók kinyílik, hogy befogadja. Ott ül az alkalmazásikonok után, megjelenik, amikor a fiók megjelenik, és nyitva tartja a fiókját, amíg a panelje fent van. Húzd vissza a sávra, hogy visszatedd.

Ha inkább menüből választanál, az **Appearance → Menu Bar** alatt van a pozíció, a **Bar Background** pedig azt választja ki, hogyan rajzolódjon a sáv: **Opaque Bar**, **Glassy Bar** (átlátszó, a mögötte lévő elmosásával) vagy **Clear Bar**.

Ugyanezeknek parancsaik is vannak, ami az, amit egy [dotfiles](31-dotfiles.md) beállításhoz akarsz:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Egy widget teljes hozzáadásához vagy eltávolításához használd a pluginparancsokat. Az `omarchy plugin list` kiír minden widgetet, amelyet a shell ismer, az azonosítójával együtt, ezután:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## A sáv elrejtése

A `Super + Shift + Space` ki- és visszakapcsolja a sávot a shell leállítása nélkül — a panelek és a gyorsbillentyűk tovább működnek, csak visszakapod a képpontokat. A menüben is ott van az **Appearance → Menu Bar → Hide Bar** alatt.

## A konfigurációs fájl

Mindez a `~/.config/omarchy/shell.json` fájlban tárolódik, a `bar` kulcs alatt. Íme egy rövidített változat:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Minden widget egy bejegyzés az öt elrendezési tömb egyikében, és a beállításai soron belül, azon a bejegyzésen ülnek — nincs külön beállításfájl, és nincs `config` alobjektum. Az óra `format`, `formatAlt` (amire a jobb kattintás váltogat) és `verticalFormat` értéke mind ott él a `{ "id": "omarchy.clock" }` bejegyzésen.

A `center` a doboz a sáv közepén: minden, ami benne van, egy csoportként középre kerül a képernyőn. A `centerBegin` és a `centerEnd` a doboz két oldalához tapad, így marad az óra halálpontosan középen, miközben az időjárás és a frissítési jelvény jön-megy. Tegyél egynél több widgetet a `center` alá, és együtt kerülnek középre; hagyd üresen, és a `centerBegin` és a `centerEnd` a sáv közepén találkozik.

Egy szabály, amelyet érdemes megjegyezni: **ha egyszer megvan a saját `shell.json` fájlod, az a mérvadó**. Amíg semmit sem szabtál testre, a shell az Omarchy alapértelmezett fájlját olvassa. Abban a pillanatban, amikor elhúzol egy widgetet, futtatod az `omarchy bar` parancsot, vagy magad szerkeszted a fájlt, a tiéd — nincs mély összefésülés, így a jövőbeli Omarchy-kiadások új alapértelmezett widgetjei nem jelennek meg automatikusan a sávodon. Az `omarchy bar defaults` visszaállítja a gyári elrendezést, amikor tiszta lapot akarsz.

Ugyanez a fájl tartja az üresjárati időzítéseidet is a legfelső szinten, a `bar` kulcson kívül: az `idle.screensaver` és az `idle.lock`, mindkettő másodpercben azóta, hogy tétlenné váltál. Így az alapértelmezett képernyővédő 150 másodpercnél lép be, a zárolás pedig 300-nál.
