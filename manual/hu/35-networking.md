# Hálózat

A hálózatkezelést az Omarchyban a NetworkManager végzi, és a [felső sávon](05-the-top-bar.md) lévő hálózat ikonról, vagy a `Super + Ctrl + N` billentyűkombinációval vezérelheted.

Ez a panel Wi-Fi-hálózatokat keres, mutatja a jelerősséget, és csatlakozik. Az Ethernethez semmi sem kell — bedugod, és működik. Ha inkább a terminálban maradnál, az `nmtui` ugyanazokat a vezérlőket adja, és van egy `omarchy network` parancscsoport is.

## A Wi-Fi megosztása

Ahelyett, hogy hangosan felolvasnál egy hosszú jelszót, futtasd a _Setup > Network > QR Code_ lehetőséget, miközben Wi-Fin vagy. Ez egy QR-kódot tesz a képernyőre, amelyet bármelyik telefon kamerája beolvashat a csatlakozáshoz. Ez egyike azoknak a dolgoknak, amelyeket többször fogsz használni, mint gondolnád, ha egyszer tudod, hogy ott van.

Ha magára a jelszóra van szükséged, az `omarchy network password <interface>` kiírja azt.

## DNS

Az Omarchy azt a DNS-t használja, amelyet a hálózatod DHCP-n keresztül ad. Ezt felülírhatod az egész gépre a _Setup > Network > DNS_ alatt, ahol a Cloudflare és a Google egy kattintásra van. Válaszd a _Custom_ lehetőséget a saját szervereid beírásához.

A terminálból az `omarchy dns` kiírja az aktuális szolgáltatót, az `omarchy dns Cloudflare` pedig beállít egyet.

## A Wi-Fi-sáv rögzítése

Ha a routered a 2.4GHz, 5GHz és 6GHz sávokat ugyanazon a hálózati néven adja, a laptopod néha a lassúhoz fog ragaszkodni. Az `omarchy network band` megmutatja, melyik sávon vagy, az `omarchy network band 5` pedig rögzíti azt. Használd az `auto` értéket, hogy újra ő választhasson.

Ez a sávot rögzíti, nem egy adott hozzáférési pontot, így az AP-k között továbbra is normálisan barangolhatsz.

## Milyen gyors?

A _Trigger > Speed Test > Network Speed Test_ a tényleges fel- és letöltési sebességedet méri egy pár számlappal. A terminálból ez az `omarchy network speedtest down` vagy `up`. Az Omarchy saját szolgáltatásával szemben mér, és csak a saját tesztátviteleit számolja. Más letöltések versenyezhetnek a sávszélességért, de nem adódnak hozzá a sebességteszt eredményéhez. (Mellette abban a menüben ott van egy lemezsebesség-teszt is, ha a másik szűk keresztmetszetet méred.)

## A tűzfal

A tűzfal alapértelmezetten be van kapcsolva, és minden bejövő forgalmat blokkol, egy kivétellel: az 53317-es porttal, így a [LocalSend](22-guis.md) azonnal működik.

Az SSH ki van kapcsolva, amíg be nem kapcsolod a _Setup > Security > SSHD_ lehetőséggel, amely elindítja a démont, sebességkorlátozással megnyitja a 22-es portot a brute force ellen, és engedélyez egy kulcsot. A Docker is le van zárva, így a konténerek nem tehetik ki magukat véletlenül a világnak. Lásd a [biztonság](48-security.md) oldalt a teljes történetért.

## Tailscale

A [Tailscale](https://tailscale.com/) egy mesh VPN, amely egyszerűvé és biztonságossá teszi az összes számítógéped és szervered elérését az interneten keresztül. Telepítsd az _Install > Service > Tailscale_ lehetőséggel.

Ez egy Tailscale panelt ad a sávra, amely csatlakoztatja és leválasztja a tailnetet, fiókot vált, és kilépési csomópontot választ — a saját gépeid és a Mullvad régiók is megjelennek a listában. A gépeidet is böngészi, és itt él a Taildrop: válassz ki egy gépet, és nyomd meg az `s` billentyűt fájlok küldéséhez, vagy a `c`, `n` és `d` billentyűket az IP-címének, nevének vagy teljes DNS-nevének másolásához. A terminálos megfelelője az `omarchy tailscale send <machine> [file...]`, és a neked küldött fájlok automatikusan a `~/Downloads` mappába érkeznek. Az érkezést bejelentő értesítés addig vár, amíg rá nem kattintasz a megnyitásához vagy el nem veted, így egy fájl, amely akkor érkezik, amikor távol vagy a géptől, még mindig ott van, hogy válaszolj rá, amikor visszatérsz.

A telepítés egy webalkalmazást is hozzáad a Tailscale adminisztrációs konzolhoz.

## Amikor nem működik tovább

Újraindítás előtt próbáld meg önmagában újraindítani a hibás részt. Az _Update > Hardware_ alatt ott van a Wi-Fi, Bluetooth, Audio és Trackpad, és ezek egyikének újratöltése tisztázza a legtöbb „öt perce még működött” helyzetet. Lásd a [hibaelhárítás](45-troubleshooting.md) oldalt.
