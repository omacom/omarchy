# A felső sáv

A képernyőd tetején végigfutó csík az Omarchy sáv. Nem egy utólag felcsavarozott állapotsáv, hanem az Omarchy shell része, azé az egyetlen, hosszan futó Quickshell folyamaté, amely a menüt, az értesítéseket, az OSD felugrókat és a zárolási képernyőt is rajzolja. Ezért illeszkedik tökéletesen minden máshoz, és ezért nyílik meg egy panel azonnal, új alkalmazás indítása helyett.

Ez az egyetlen része az asztalnak, amely mindig a képernyőn van, így érdemes tudni, mit csinálnak azok a kis jelek.

## Mi van rajta alapértelmezés szerint

A sávnak három szakasza van. Bal oldalon ül az Omarchy logó (a menüindító) és a munkaterület-jelzők. Középen kapod az állapotjelzőket, az órát, az Elsewhen-t (egy világórát), az időjárást és egy Omarchy-frissítési jelvényt. Jobb oldalon: a rendszertálca, a billentyűzetkiosztás (ha egynél több van beállítva), az ágensek, a bluetooth, a hálózat, a hang, a kijelző és az energia.

Néhány ezek közül csak akkor jelenik meg, ha van mondanivalója. A billentyűzetkiosztás csak akkor jelenik meg, ha egynél több kiosztást állítottál be. A frissítési jelvény csak akkor jelenik meg, ha Omarchy-frissítés vár rád. Az ágensek ikonja pedig akkor jelenik meg először, amikor az Omarchy AI coding használatot talál a gépen (lásd [MI](17-ai.md)).

## Kattintgatás

Szinte minden widget csinál valamit bal, jobb és középső kattintásra, és több reagál a görgetésre is. Ezt szokták elszalasztani az emberek — a jobb és a középső gomb rejti a jó dolgok nagy részét.

| Widget | Bal | Jobb | Középső / görgetés |
| --- | --- | --- | --- |
| Menü | Omarchy menü | Új terminál | — |
| Munkaterületek | Az adott munkaterületre fókuszál ezen a monitoron | — | Görgetés: következő/előző munkaterület |
| Óra | Naptár felugró | A címkeformátum váltása | Középső: időzóna-választó |
| Időjárás | Előrejelzés felugró | Teljes időjárás értesítésként | Középső: frissítés |
| Hang | Hangpanel | Némítás | Középső: panel · görgetés: hangerő |
| Mikrofon | A mikrofon némítása | — | Középső: hangpanel · görgetés: bemeneti hangerő |
| Hálózat | Hálózatpanel | — | — |
| Bluetooth | Bluetooth panel | A rádió ki-/bekapcsolása | — |
| Kijelző | Kijelzőpanel | — | Görgetés: fényerő |
| Energia | Energiapanel | Az akkumulátorszázalék ki-/bekapcsolása | — |
| Média | Lejátszás/szünet | Borítókép felugró | Középső: következő · görgetés: előző/következő |
| Ágensek | Ágensek panel | Az ágensed indítása | Középső: következő előfizetés |
| Tálca | Lebegtetés a fiók felfedéséhez | Jobb kattintás a chevronra a kezeléshez | — |
| Omarchy-frissítés | A frissítés futtatása | — | — |

A táblázatban szereplő dolgok közül nem minden van alapból a sávodon. A médiawidget (MPRIS most szóló, görgetődő számmal és előadóval) és a mikrofonwidget is be van építve, de alapértelmezés szerint ki van kapcsolva — add hozzá őket, ha akarod, az alábbiak szerint.

## A panelek

Egy sávikonra kattintva panel nyílik, amely egy rendes felugró ablak csúszkákkal, listákkal és billentyűzetes navigációval, nem csak egy eszköztipp. Mindegyiknek van gyorsbillentyűje is, így sosem kell egy 16 képpontos jelet célba venned:

| Gyorsbillentyű | Panel |
| --- | --- |
| `Super + Ctrl + A` | Hang |
| `Super + Ctrl + N` | Hálózat |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Kijelző |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Naptár |
| `Super + Ctrl + Alt + E` | Világóra |
| `Super + Ctrl + 1-9` | Az n-edik panel ki-/bekapcsolása a jobb oldali szakaszban |

A panelek nem csak kijelzők. Itt tudod ténylegesen elvégezni a dolgot:

- A **Hang** tartalmaz egy fő hangerőcsúszkát, egy kimeneti eszközválasztót és egy alkalmazásonkénti keverőt, így lehalkíthatod azt az egy böngészőlapot anélkül, hogy minden máshoz hozzányúlnál.
- A **Hálózat** Wi-Fi-t keres, mutatja a jelerősséget, csatlakozik, és lehetővé teszi DNS-szolgáltató választását.
- A **Bluetooth** kilistázza az eszközeidet csatlakozással/leválasztással és akkumulátorszintekkel.
- Az **Energia** akkumulátorstatisztikákat mutat, energia-profilokat vált (külön választást jegyez meg akkumulátorra és AC-re), és némi rendszerinformációt ír ki.
- A **Kijelző** tartalmaz egy fényerőcsúszkát, szövegméretet, monitor-méretezési előbeállításokat, és — ha egynél több képernyőd van — monitoronkénti vezérlőket. A mélyebb történetért lásd [monitorok](33-monitors.md).
- Az **Óra** egy havi rácsot nyit ISO hétszámokkal és hónap léptetéssel.
- A **Világóra** soronként egy várost tart, annak időjárásával és azzal, hogyan telik ott a nap. A keresés településeket is talál időzónák mellett, így Fort Lauderdale az Fort Lauderdale, és nem New York. Ha a felül lévő sor rossz várost nevez meg, kattints rá, és mondd meg, hol vagy; válassz valamit egy másik időzónában, és a rendszeróra is oda költözik, ami utazáskor jól jön. Lebegtesd az egeret egy város fölé, és kattints a személy gombra, hogy megmondd, ki lakik ott — egyszerű nevek, vagy `@` GitHub handle-ök, hogy az arcuk is megjelenjen.

Minden panel fogadja a billentyűzetet is az egér mellett: a nyilak mozognak, a Return aktivál, a Tab a szomszédos panelre lép, az Escape pedig bezár.

A `Super + Ctrl + 1-9` balról jobbra számolja a paneleket a jobb oldali szakaszban, kihagyva a tálcát, mivel annak nincs saját panelje. Így a szám ahhoz az ikonhoz tartozik, amelyre mutatnál.

### Tailscale és Dropbox

Két további widget csak akkor jelenik meg a sávon, ha telepíted a hozzá tartozó szolgáltatást az **Install → Service** menüből, és mindkettőt érdemes ismerni, mert nem csak állapotot jelentenek.

A **Tailscale** panel csatlakoztatja és leválasztja a tailnetet, vált a fiókok között, és kilépési csomópontot választ (a saját gépeid és a Mullvad régiók is megjelennek azon a listán). Tallózza a gépeidet is — és ha egy ki van választva, az `s` fájlokat küld rá Taildrop segítségével, ami a leggyorsabb módja annak, hogy fájlt juttass a telefonodra vagy egy másik laptopra. A `c` másolja a gép IP-címét, az `n` a nevét, a `d` pedig a teljes DNS-nevét. Minden gépsoron van egy küldés gomb is, ha inkább kattintanál. Ugyanez a terminálból: `omarchy tailscale send <machine> [file...]`.

A **Dropbox** panel kezeli a bejelentkezést, mutatja, mennyi tárhelyet használtál, és kilistázza a nemrég szinkronizált fájlokat.

Bármelyik szolgáltatás eltávolítása leveszi a widgetét is a sávról.

## Jelzők

A középen lévő kis csoport a jelzők widget. Ezek állapotjelek azokhoz a módokhoz, amelyeket bekapcsoltál: ne zavarjanak, éjszakai fény, egy sorban álló [emlékeztető](09-reminders.md), egy aktív képernyőfelvétel, ébren maradás, és [diktálás](11-text-extraction-dictation.md). Kigyulladnak, amikor a mód aktív, egyébként eltűnnek az útból — lebegtesd az egeret bárhol a sáv fölött, hogy meglesd az inaktívakat. Egy jelzőre kattintva ki-/bekapcsolod azt a módot. Még egy csak állapotot jelez: egy távoli munkamenet pirosan világít, amíg valaki csatlakozik ehhez a géphez gliff segítségével.

Ha inkább mindig láthatóak lennének, állítsd az `alwaysShow` értékét `true`-ra a widgeten. És ha csak néhányuk érdekel, sorold fel a kívántakat az `items` mezőben: `["Dnd", "Reminder", "NightLight"]`. Több jelzők widgeted is lehet, így a különböző szakaszok különböző részhalmazokat mutathatnak.

## A sáv átrendezése

A sáv magát konfigurálja. Nem kell konfigurációs fájlt nyitnod ahhoz, hogy áthelyezd a dolgokat.

Fogj meg egy üres foltot a sávon a közép körül, és húzd egy másik képernyőszél felé, és a sáv oda költözik — bal, jobb, fent vagy lent egyaránt működik, és minden widget alkalmazkodik (a függőleges sávok kompakt, csak ikonos formára váltanak vissza). A kattintva tartás ugyanezt a húzást indítja. Dupla bal kattintás ugyanazon az üres helyen végiglépteti a sáv hátterét átlátszóról üvegesre, majd átlátszatlanra. És húzz bármely widgetet az átrendezéséhez, vagy dobj át egy másik szakaszba; a többi widget szétcsúszik, hogy helyet csináljon ott, ahová érkezni fog.

A sáv közepe egy doboz: ami benne van, egy csoportként középen marad, és a két oldalán lévő widgetek a széleiről lógnak le. Amíg egy widgetet húzol, a doboz körvonalként jelenik meg, vagy egy vonalként a sávon át, amikor üres, és bele is ejtheted, mellé is. Amikor egy ejtés a dobozba érkezne, a doboz megnő, hogy befogadja a widgetet.

Egy widget, amelyet szeretnél kéznél tartani, de nem mindig szem előtt, mehet a tálca fiókjába: húzd a tálcára, és a fiók kinyílik, hogy befogadja. Ott ül az alkalmazásikonok után, megjelenik, valahányszor a fiók megjelenik, és nyitva tartja a fiókját, amíg a panelje fent van. Húzd vissza a sávra, hogy visszategyed.

Ha inkább menüből választanál, az **Appearance → Menu Bar** tartalmazza a pozíciót, a **Bar Background** pedig kiválasztja, hogyan rajzolódjon a sáv: **Opaque Bar**, **Glassy Bar** (átlátszó, a mögötte lévő elmosva), vagy **Clear Bar**.

Ugyanezeknek parancsaik is vannak, ami egy [dotfiles](31-dotfiles.md) felálláshoz kell:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Egy widget teljes hozzáadásához vagy eltávolításához használd a plugin parancsokat. Az `omarchy plugin list` kiír minden widgetet, amelyet a shell ismer, az azonosítójával együtt, és aztán:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## A sáv elrejtése

A `Super + Shift + Space` ki-/bekapcsolja a sávot a shell leölése nélkül — a panelek és a gyorsbillentyűk továbbra is működnek, csak visszakapod a képpontokat. A menüben is ott van az **Appearance → Menu Bar → Hide Bar** alatt.

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

Minden widget egy bejegyzés az öt elrendezési tömb egyikében, és a beállításai soron belül, azon a bejegyzésen ülnek — nincs külön beállításfájl, és nincs `config` alobjektum. Az óra `format`, `formatAlt` (amire a jobb kattintás léptet), és `verticalFormat` értéke mind ott él, közvetlenül a `{ "id": "omarchy.clock" }` bejegyzésen.

A `center` a doboz a sáv közepén: minden, ami benne van, egy csoportként a képernyő közepére kerül. A `centerBegin` és a `centerEnd` a doboz két oldaláról lóg le, így marad az óra holtpontosan középen, miközben az időjárás és a frissítési jelvény jön-megy. Tegyél egynél több widgetet a `center`-be, és együtt kerülnek középre; hagyd üresen, és a `centerBegin` és a `centerEnd` a sáv közepén találkozik.

Egy szabály, amelyet érdemes megjegyezni: **ha egyszer megvan a saját `shell.json` fájlod, az a mérvadó**. Amíg semmit nem szabtál testre, a shell az Omarchy alapértelmezett fájlját olvassa. Abban a pillanatban, hogy elhúzol egy widgetet, futtatod az `omarchy bar` parancsot, vagy magad szerkeszted a fájlt, a tiéd lesz — nincs mély összefésülés, így a jövőbeli Omarchy kiadások új alapértelmezett widgetjei nem jelennek meg automatikusan a sávodon. Az `omarchy bar defaults` visszaállítja a szállított elrendezést, amikor tiszta lappal akarsz indulni.

Ugyanez a fájl tartalmazza a tétlenségi időzítéseidet is a legfelső szinten, a `bar` kulcson kívül: `idle.screensaver` és `idle.lock`, mindkettő másodpercben mérve azóta, hogy tétlenné váltál. Így az alapértelmezett képernyővédő 150 másodpercnél kapcsol be, a zárolás pedig 300-nál.
