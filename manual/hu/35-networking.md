# Hálózat

Az Omarchyban a hálózatot a NetworkManager kezeli, te pedig a [felső sáv](05-the-top-bar.md) hálózati ikonjából vagy a `Super + Ctrl + N` billentyűkombinációval irányítod.

Ez a panel Wi-Fi-hálózatokat keres, mutatja a jelerősséget, és csatlakozik hozzájuk. Az Ethernethez semmi sem kell — csak dugd be, és működik. Ha inkább a terminálban maradnál, az `nmtui` ugyanazokat a vezérlőket adja, és van egy `omarchy network` parancscsoport is.

## A Wi-Fi megosztása

Ahelyett, hogy hangosan felolvasnál egy hosszú jelszót, futtasd a _Beállítás > Hálózat > QR-kód_ lehetőséget, miközben Wi-Fin vagy. Ez egy QR-kódot tesz a képernyőre, amelyet bármelyik telefon kamerája be tud olvasni a csatlakozáshoz. Egyike azoknak a dolgoknak, amelyeket többször fogsz használni, mint gondolnád, ha egyszer tudod, hogy ott van.

Ha tényleg magára a jelszóra van szükséged, az `omarchy network password <interface>` kiírja azt.

## DNS

Az Omarchy azt a DNS-t használja, amelyet a hálózatod DHCP-n keresztül ad. Ezt az egész gépre felülírhatod a _Beállítás > Hálózat > DNS_ alatt, ahol a Cloudflare és a Google egy kattintásra van. Válaszd az _Egyéni_ lehetőséget a saját szervereid beírásához.

A terminálból az `omarchy dns` kiírja az aktuális szolgáltatót, az `omarchy dns Cloudflare` pedig beállít egyet.

## A Wi-Fi-sáv rögzítése

Ha a routered a 2.4GHz-et, az 5GHz-et és a 6GHz-et ugyanazon a hálózatnéven adja, a laptopod néha a lassúhoz fog ragaszkodni. Az `omarchy network band` megmutatja, melyik sávon vagy, az `omarchy network band 5` pedig rögzíti azt. Használd az `auto` értéket, hogy újra ő választhasson.

Ez a sávot rögzíti, nem egy konkrét hozzáférési pontot, így továbbra is normálisan vándorolsz az AP-k között.

## Milyen gyors?

Az _Indító > Sebességteszt > Hálózati sebességteszt_ egy pár számlappal méri a tényleges fel- és letöltési sebességedet. A terminálból ez az `omarchy network speedtest down` vagy az `up`. (Mellette egy lemezsebesség-teszt is ott ül abban a menüben, ha a másik szűk keresztmetszetet méred.)

## A tűzfal

A tűzfal alapértelmezés szerint be van kapcsolva, és minden bejövő forgalmat blokkol, egy kivétellel: az 53317-es portot, hogy a [LocalSend](22-guis.md) azonnal működjön.

Az SSH ki van kapcsolva, amíg be nem kapcsolod a _Beállítás > Biztonság > SSHD_ alatt, amely elindítja a démont, megnyitja a 22-es portot a brute force elleni sebességkorlátozással, és engedélyez egy kulcsot. A Docker is le van zárva, így a konténerek nem tehetik ki magukat véletlenül a világnak. A teljes történethez lásd a [biztonság](48-security.md) részt.

## Tailscale

A [Tailscale](https://tailscale.com/) egy mesh VPN, amely egyszerűvé és biztonságossá teszi az összes számítógéped és szervered elérését az interneten keresztül. Telepítsd a _Telepítés > Szolgáltatás > Tailscale_ menüponttal.

Ez ad egy Tailscale panelt a sávban, amely csatlakozik a tailnethez és leválaszt arról, fiókot vált, és kilépési csomópontot választ — a saját gépeid és a Mullvad-régiók is megjelennek a listában. A gépeidet is böngészi, és itt lakik a Taildrop: válassz ki egy gépet, és nyomd meg az `s` billentyűt fájlok küldéséhez, vagy a `c`, `n` és `d` billentyűt az IP-címe, a neve vagy a teljes DNS-neve másolásához. A terminálos megfelelője az `omarchy tailscale send <machine> [file...]`, a neked küldött fájlok pedig automatikusan a `~/Downloads` mappába kerülnek. Az érkezést bejelentő értesítés megvárja, amíg rákattintasz a megnyitásához vagy elveted, így egy fájl, amely akkor érkezik, amikor távol vagy a géptől, még mindig ott van, hogy válaszolj rá, amikor visszajössz.

A telepítése egy webalkalmazást is hozzáad a Tailscale adminisztrációs konzolhoz.

## Amikor nem működik tovább

Újraindítás előtt próbáld meg önmagában újraindítani a hibás részt. A _Frissítés > Hardver_ alatt ott van a Wi-Fi, a Bluetooth, a Hang és az Érintőpad, és ezek egyikének újratöltése megoldja a legtöbb „öt perce még működött” helyzetet. Lásd a [hibaelhárítás](45-troubleshooting.md) részt.
