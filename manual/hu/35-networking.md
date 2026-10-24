# Hálózatkezelés

Az Omarchyban a hálózatkezelést a NetworkManager végzi, és a [felső sáv](05-the-top-bar.md) hálózatikonjáról vagy a `Super + Ctrl + W` kombinációval vezérelheted.

Ez a panel Wi-Fi-hálózatokat keres, mutatja a jelerősséget, és csatlakozik. Az Ethernethez semmi sem kell — bedugod, és működik. Ha inkább a terminálban maradnál, az `nmtui` ugyanazokat a vezérlőket adja, és van egy `omarchy network` parancscsoport is.

## A Wi-Fi megosztása

Ahelyett, hogy hangosan felolvasnál egy hosszú jelszót, futtasd a _Beállítás > Hálózat > QR-kód_ pontot, amíg Wi-Fin vagy. Ez egy QR-kódot tesz a képernyőre, amelyet bármely telefon kamerája beolvashat a csatlakozáshoz. Egyike azoknak a dolgoknak, amelyeket többször fogsz használni, mint gondolnád, ha egyszer tudod, hogy ott van.

Ha tényleg magára a jelszóra van szükséged, az `omarchy network password <interface>` kiírja.

## DNS

Az Omarchy azt a DNS-t használja, amelyet a hálózatod DHCP-n keresztül ad. Ezt az egész gépre felülírhatod a _Beállítás > Hálózat > DNS_ alatt, ahol a Cloudflare és a Google egy kattintásra van. Válaszd az _Egyéni_ lehetőséget, ha a saját szervereidet akarod beírni.

Terminálból az `omarchy dns` kiírja a jelenlegi szolgáltatót, az `omarchy dns Cloudflare` pedig beállít egyet.

## A Wi-Fi-sáv rögzítése

Ha a routered a 2,4 GHz-et, az 5 GHz-et és a 6 GHz-et ugyanarra a hálózatnévre teszi, a laptopod néha a lassúhoz fog ragaszkodni. Az `omarchy network band` megmutatja, melyik sávon vagy, az `omarchy network band 5` pedig rögzíti. Használd az `auto` értéket, hogy újra ő válasszon.

Ez a sávot rögzíti egy konkrét hozzáférési pont helyett, így továbbra is normálisan vándorolsz a hozzáférési pontok között.

## Milyen gyors?

Az _Indító > Sebességteszt > Hálózati sebességteszt_ két tárcsával méri a tényleges le- és feltöltési sebességed. Terminálból ez `omarchy network speedtest down` vagy `up`. (Egy lemezsebességteszt is ott ül mellette abban a menüben, ha a másik szűk keresztmetszetet benchmarkolod.)

## A tűzfal

A tűzfal alapértelmezetten be van kapcsolva, és minden bejövő forgalmat blokkol, egy kivétellel: az 53317-es porttal, hogy a [LocalSend](22-guis.md) azonnal működjön.

Az SSH ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ ponttal, amely elindítja a démont, megnyitja a 22-es portot nyers erő elleni sebességkorlátozással, és engedélyez egy kulcsot. A Docker is le van zárva, így a konténerek nem tehetik ki magukat véletlenül a világnak. A teljes történetért lásd a [biztonságot](48-security.md).

## Tailscale

A [Tailscale](https://tailscale.com/) egy mesh VPN, amely egyszerűvé és biztonságossá teszi minden számítógéped és szervered elérését az interneten keresztül. Telepítsd a _Telepítés > Szolgáltatás > Tailscale_ ponttal.

Ez egy Tailscale panelt ad a sávba, amely csatlakozik a tailnethez és leválaszt róla, fiókot vált, és kilépési csomópontot választ — a saját gépeid és a Mullvad-régiók is megjelennek a listában. A gépeid között is böngész, és ott él a Taildrop: válassz ki egy gépet, és nyomd meg az `s` billentyűt fájlok küldéséhez, vagy a `c`, `n` és `d` billentyűt az IP-címe, neve vagy teljes DNS-neve másolásához. A terminálos megfelelője az `omarchy tailscale send <machine> [file...]`, és a neked küldött fájlok automatikusan a `~/Downloads` mappába érkeznek. A beérkezést jelző értesítés addig vár, amíg rá nem kattintasz a megnyitásához vagy el nem veted, így egy fájl, amely akkor érkezik, amikor nem vagy a gépnél, akkor is ott lesz válaszra, amikor visszaérsz.

A telepítése egy webalkalmazást is ad a Tailscale adminisztrációs konzolhoz.

## Amikor leáll a működése

Újraindítás előtt próbáld meg önmagában újraindítani a hibás részegységet. A _Frissítés > Hardver_ alatt van Wi-Fi, Bluetooth, Hang és Érintőpad, és ezek egyikének újratöltése a legtöbb „öt perce még működött" helyzetet megoldja. Lásd a [hibaelhárítást](45-troubleshooting.md).
