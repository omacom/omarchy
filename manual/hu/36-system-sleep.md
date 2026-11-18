# A rendszer alvása

Az Omarchy alapértelmezés szerint engedélyezi a felfüggesztést és a hibernálást, de ha bármelyikkel gondod van a gépeden, kikapcsolhatod őket.

Az NVIDIA GB10 gépeken, például a DGX Spark és az ASUS Ascent GX10 esetében a felfüggesztés és a hibernálás ki van kapcsolva, ahogy az NVIDIA DGX OS rendszerében is, mert még nem bizonyosodott be, hogy az alvás működik ezen a hardveren. Ugyanez vonatkozik az ASUS Zenbook A16 (UX3607OA) modellre is, ahol a felfüggesztés még nem altatja el teljesen a chipet, és a gép éjszaka lefagyhat. A felfüggesztés kapcsolója és a hibernálás beállítása ott nem érvényes. Az alvás visszakapcsolásához töröld a `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` fájlt a `sudo rm` paranccsal; ezután a Felfüggesztés visszakerül a menübe, és a hibernálás a többi géphez hasonlóan beállítható. A `sudo omarchy apply hardware --install-user "$USER"` futtatása visszaállítja a fájlt.

### Energiaprofilok

Laptopon az Omarchy külön megjegyzi az energiaprofilodat a hálózatra csatlakoztatott és az akkumulátorról működő állapothoz, és a csatlakoztatáskor, illetve kihúzáskor vált a kettő között. Ez alapból azt jelenti, hogy AC mellett performance, akkumulátoron pedig balanced profil van érvényben.

A `omarchy powerprofiles list` paranccsal megnézheted, mit kínál a géped, és a `omarchy powerprofiles set autodetect power-saver` paranccsal beállíthatod a kívánt profilt ahhoz az állapothoz, amelyben éppen vagy. A másik állapot beállításához anélkül, hogy bármit kihúznál, nevezd meg közvetlenül: `omarchy powerprofiles set battery power-saver`. Bármit is választasz, azt kapod vissza, amikor legközelebb ugyanebben az állapotban leszel.

### A felfüggesztés ki- és bekapcsolása

A felfüggesztést a terminálból futtatott `omarchy toggle suspend` paranccsal kapcsolhatod ki és be. Ez csak megjeleníti/elrejti a lehetőséget a _Rendszer_ alatt (vagy a `Super + Esc` kombinációval), ezután pedig megnézheted, hogy megbízhatóan működik-e a rendszereden. Ha nem, ugyanazzal a paranccsal újra elrejtheted.

### A hibernálás ki- és bekapcsolása

A hibernálást a terminálból futtatott `omarchy hibernation setup` paranccsal állíthatod be. A hibernálás létrehoz egy /swap alkötetet a rendszerindító meghajtódon, a fizikai RAM méretével megegyező méretben, ezért gondoskodj róla, hogy bőven legyen szabad helyed. Egy 32GB-os gépen ehhez a kötethez mindig 32GB+ szabad helyre lesz szükséged. A hibernáláshoz az alapértelmezett Limine rendszerbetöltő is szükséges.

Beállítás után a hibernálás lehetőséget a _Rendszer_ alatt (vagy a `Super + Esc` kombinációval) fogod látni, ezután pedig megnézheted, hogy megbízhatóan működik-e a rendszereden. Ha nem, a `omarchy hibernation remove` futtatásával újra eltávolíthatod.
