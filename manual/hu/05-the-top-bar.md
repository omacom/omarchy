# A felső sáv

A képernyő tetején végigfutó sáv az Omarchy sáv. Nem egy rácsavarozott állapotsáv, hanem az Omarchy shell része, annak az egyetlen, hosszan futó Quickshell-folyamatnak a része, amely a menüt, az értesítéseket, az OSD felugró ablakokat és a zárolási képernyőt is rajzolja. Ezért illeszkedik tökéletesen minden máshoz, és ezért nyílik meg egy panel azonnal, új alkalmazás indítása helyett.

Ez az asztal egyetlen olyan része is, amely mindig a képernyőn van, ezért érdemes tudni, mit csinál az a sok kis jel.

## Mi van rajta alapértelmezetten

A sávnak három szakasza van. Bal oldalt ül az Omarchy logó (a menüindító) és a munkaterület-jelzők. Középen kapod az állapotjelzőket, az órát, az Elsewhen nevű világórát, az időjárást és egy Omarchy frissítési jelvényt. Jobb oldalt: a rendszertálca, a billentyűzetkiosztás (amikor egynél több kiosztás vagy beviteli mód van konfigurálva), az ágensek, a bluetooth, a hálózat, a hang, a kijelző és a tápellátás.

Ezek közül néhány csak akkor jelenik meg, amikor mondanivalója van. A billentyűzetkiosztás csak akkor jelenik meg, ha egynél több kiosztást vagy beviteli módot konfiguráltál. A frissítési jelvény csak akkor jelenik meg, amikor Omarchy frissítés vár rád.

## Kattintgatás

Szinte minden widget csinál valamit bal, jobb és középső kattintásra, és több reagál a görgetésre is. Ez az a rész, amely az embereknek kimarad — a jobb és középső gomb rejti a jó dolgok nagy részét.

| Widget | Bal | Jobb | Középső / görgetés |
| --- | --- | --- | --- |
| Menü | Omarchy menü | Új terminál | — |
| Munkaterületek | Fókusz az adott munkaterületre ezen a monitoron | — | Görgetés: következő/előző munkaterület |
| Óra | Naptár felugró ablak | A címkeformátum váltása | Középső: időzóna-választó |
| Világóra | Világóra panel | Frissítés | Középső: frissítés |
| Időjárás | Előrejelzés felugró ablak | Teljes időjárás értesítésként | Középső: frissítés |
| Hang | Hang panel | Némítás | Középső: panel · görgetés: hangerő |
| Mikrofon | A mikrofon némítása | — | Középső: hang panel · görgetés: bemeneti hangerő |
| Hálózat | Hálózat panel | — | — |
| Bluetooth | Bluetooth panel | A rádió be-/kikapcsolása | — |
| Kijelző | Kijelző panel | — | Görgetés: fényerő |
| Tápellátás | Tápellátás panel | Az akkumulátorszázalék be-/kikapcsolása | — |
| Média | Lejátszás/szünet | Borítókép felugró ablak | Középső: következő · görgetés: előző/következő |
| Ágensek | Ágensek panel | Az ágensed indítása | Középső: használat frissítése |
| Tálca | Vidd fölé az egeret a fiók felfedéséhez | Jobb kattintás a chevronon a kezeléshez | — |
| Omarchy frissítés | A frissítés futtatása | — | — |

Nem minden van abból a táblázatból alapból a sávodon. A média widget (MPRIS most játszott, görgetődő számmal és előadóval) és a mikrofon widget is be van építve, de alapértelmezetten ki van kapcsolva — add hozzá őket, ha akarod, az alábbiakban leírtak szerint.

## A panelek

Egy sávikonra kattintva panel nyílik meg, amely egy igazi felugró ablak csúszkákkal, listákkal és billentyűzetes navigációval, nem egy eszköztipp. Mindegyiknek van gyorsbillentyűje is, így sosem kell egy 16 pixeles jelre céloznod:

| Gyorsbillentyű | Panel |
| --- | --- |
| `Super + Ctrl + A` | Hang |
| `Super + Ctrl + N` | Hálózat |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Kijelző |
| `Super + Ctrl + P` | Tápellátás |
| `Super + Ctrl + Alt + D` | Naptár |
| `Super + Ctrl + Alt + E` | Világóra |
| `Super + Ctrl + X` | Ágensek |
| `Super + Ctrl + 1-9` | Az n-edik panel be-/kikapcsolása a jobb szakaszban |

A panelek nem kijelzők. Ott csinálod meg ténylegesen a dolgot:

- A **Hang** panelben van egy fő hangerőcsúszka, egy kimeneti eszközválasztó és egy alkalmazásonkénti keverő, így lehalkíthatod azt az egy böngészőlapot anélkül, hogy minden máshoz hozzányúlnál.
- A **Hálózat** Wi-Fi hálózatokat keres, mutatja a jelerősséget, csatlakozik, és lehetővé teszi DNS-szolgáltató választását.
- A **Bluetooth** felsorolja az eszközeidet csatlakozással/leválasztással és akkumulátorszinttel.
- A **Tápellátás** akkumulátorstatisztikákat mutat, energiagazdálkodási profilokat vált (külön választást jegyez meg akkumulátorra és AC-re), és kiír némi rendszerinformációt.
- A **Kijelző** panelben van fényerőcsúszka, szövegméret, monitor méretezési előbeállítások, és — amikor egynél több képernyőd van — monitoronkénti vezérlők. Lásd a [monitorok](33-monitors.md) oldalt a mélyebb történetért.
- Az **Óra** egy havi rácsot nyit meg ISO hétszámokkal és hónap léptetéssel.
- A **Világóra** városonként egy sort tart, annak időjárásával és azzal, hogyan áll a napja. A keresés településeket is talál időzónák mellett, így Fort Lauderdale Fort Lauderdale, és nem New York. Ha a felül lévő sor rossz várost nevez meg, kattints rá, és mondd meg, hol vagy; válassz valahol egy másik időzónában, és a rendszeróra is oda ugrik, ami utazáskor hasznos. Vidd az egeret egy város fölé, és kattints a személy gombra, hogy megmondd, ki lakik ott — egyszerű nevek, vagy `@` GitHub azonosítók, hogy az arcuk is jöjjön velük.

Minden panel fogadja a billentyűzetet is az egér mellett: a nyilak mozognak, a Return aktivál, a Tab a szomszédos panelre lép, az Escape pedig bezár.

A `Super + Ctrl + 1-9` a jobb szakaszban balról jobbra számolja a paneleket, kihagyva a tálcát, mivel annak nincs saját panelje. Így a szám ahhoz az ikonhoz illik, amelyre mutatnál.

### Tailscale és Dropbox

Két további widget csak akkor jelenik meg a sávon, miután telepítetted a hozzá tartozó szolgáltatást a **Telepítés → Szolgáltatás** menüpontból, és mindkettőt érdemes ismerni, mert többet tesznek annál, mint hogy állapotot jelentenek.

A **Tailscale** panel csatlakoztat és leválaszt a tailnetről, fiókok között vált, és kilépési csomópontot választ (a saját gépeid és a Mullvad régiók is megjelennek azon a listán). Böngészi a gépeidet is — és ha egy ki van választva, az `s` fájlokat küld rá Taildrop segítségével, ami a leggyorsabb módja egy fájl telefonodra vagy másik laptopodra juttatásának. A `c` a gép IP-címét másolja, az `n` a nevét, a `d` pedig a teljes DNS-nevét. Minden gépsoron van küldés gomb is, ha inkább kattintanál. Ugyanez a terminálból: `omarchy tailscale send <machine> [file...]`.

A **Dropbox** panel kezeli a bejelentkezést, mutatja, mennyi tárhelyet használtál, és felsorolja a nemrég szinkronizált fájlokat.

Bármelyik szolgáltatás eltávolítása leveszi a widgetjét is a sávról.

## Jelzők

A középen lévő kis csoport a jelzők widget. Ezek állapotjelek a bekapcsolt módjaidhoz: ne zavarjanak, éjszakai fény, sorba állított [emlékeztető](09-reminders.md), aktív képernyőfelvétel és ébren maradás, plusz figyelmeztetések, amíg a jelszó nélküli sudo be van kapcsolva, vagy valaki távoli munkamenethez csatlakozik. Kigyulladnak, amikor a mód aktív, egyébként félreállnak — vidd az egeret közvetlenül melléjük, oda, ahol az inaktívak ülnének, hogy leskelődj utánuk. Egy jelzőre kattintva be-/kikapcsolod azt a módot. Egy további csak állapotot jelez: egy távoli munkamenet pirosan világít, amíg valaki gliff segítségével ehhez a géphez csatlakozik.

Ha inkább mindig láthatók legyenek, állítsd az `alwaysShow` értéket `true`-ra a widgeten. És ha csak néhány érdekel közülük, sorold fel a kívántakat az `items` mezőben: `["Dnd", "Reminder", "NightLight"]`. Több jelző widgeted is lehet, így különböző szakaszok különböző részhalmazokat mutathatnak.

## A sáv átrendezése

A sáv magát konfigurálja. Nem kell konfigurációs fájlt megnyitnod ahhoz, hogy áthelyezd a dolgokat.

Fogj meg egy üres foltot a sávon a közép környékén, és húzd egy másik képernyőél felé, és a sáv oda költözik — bal, jobb, fent vagy lent egyaránt működik, és minden widget alkalmazkodik (a függőleges sávok kompakt, csak ikonból álló formákra váltanak vissza). A kattintva tartás ugyanezt a húzást indítja. Dupla bal kattintás ugyanazon az üres helyen váltja a sáv hátterét átlátszóról üvegesre, majd átlátszatlanra. És húzz bármely widgetet az átrendezéséhez, vagy dobj át egy másik szakaszba; a többi widget szétcsúszik, hogy helyet csináljon ott, ahol landolni fog.

A sáv közepe egy doboz: ami benne van, egy csoportként középen marad, és a két oldalán lévő widgetek a széleihez lógnak. Amíg egy widgetet húzol, a doboz körvonalként jelenik meg, vagy egy vonalként a sávon át, amikor üres, és bele vagy mellé ejtheted. Amikor egy ejtés a dobozba landolna, a doboz megnő, hogy befogadja a widgetet.

Egy widget, amelyet szeretnél kéznél tartani, de nem mindig szem előtt, mehet a tálca fiókjába: húzd a tálcára, és a fiók kinyílik, hogy befogadja. Ott ül az alkalmazásikonok után, megjelenik, amikor a fiók megjelenik, és nyitva tartja a fiókját, amíg a panelje fent van. Húzd vissza a sávra, hogy visszategyed.

Ha inkább menüből választanál, a **Megjelenés → Menüsáv** menüpontban van a pozíció, a **Sáv háttere** pedig azt választja ki, hogyan rajzolódjon a sáv: **Átlátszatlan sáv**, **Üveges sáv** (átlátszó, mögötte lévő tartalom elmosva), vagy **Átlátszó sáv**.

Ugyanezeknek vannak parancsaik, ami az, amit egy [dotfiles](31-dotfiles.md) beállításhoz akarsz:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Egy widget teljes hozzáadásához vagy eltávolításához használd a plugin parancsokat. Az `omarchy plugin list` kiír minden widgetet, amelyet a shell ismer, az azonosítójával együtt, és utána:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## A sáv elrejtése

A `Super + Shift + Space` kikapcsolja és visszakapcsolja a sávot a shell leölése nélkül — a panelek és gyorsbillentyűk tovább működnek, csak visszakapod a pixeleket. A menüben is ott van a **Megjelenés → Menüsáv → Sáv elrejtése** alatt.

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

Minden widget egy bejegyzés az öt elrendezési tömb egyikében, és a beállításai soron belül, azon a bejegyzésen ülnek — nincs külön beállításfájl és nincs `config` alobjektum. Az óra `format`, `formatAlt` (amire a jobb kattintás vált) és `verticalFormat` értékei mind ott élnek a `{ "id": "omarchy.clock" }` bejegyzésen.

A `center` a doboz a sáv közepén: minden, ami benne van, egy csoportként a képernyő közepére kerül. A `centerBegin` és a `centerEnd` a doboz két oldalához lóg, így marad az óra hajszálpontosan középen, miközben az időjárás és a frissítési jelvény jön és megy. Tégy egynél több widgetet a `center` mezőbe, és együtt kerülnek középre; hagyd üresen, és a `centerBegin` és a `centerEnd` a sáv közepén találkozik.

Egy szabály, amelyet érdemes magadévá tenni: **ha egyszer megvan a saját `shell.json` fájlod, az a mérvadó**. Amíg semmit nem szabtál testre, a shell az Omarchy alapértelmezett fájlját olvassa. Abban a pillanatban, amikor elhúzol egy widgetet, futtatod az `omarchy bar` parancsot, vagy magad szerkeszted a fájlt, a tiéd lesz — nincs mély összefésülés, így a jövőbeli Omarchy kiadások új alapértelmezett widgetjei nem jelennek meg automatikusan a sávodon. Az `omarchy bar defaults` bármikor visszaállítja a szállított elrendezést, amikor tiszta lappal akarsz indulni.

Ugyanez a fájl tartja az üresjárati időzítéseidet is a legfelső szinten, a `bar` kulcson kívül: az `idle.screensaver` és az `idle.lock`, mindkettő másodpercekben azóta, hogy üresjáratba mentél. Így az alapértelmezett képernyővédő 150 másodpercnél kapcsol be, a zárolás pedig 300-nál.
