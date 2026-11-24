# A rendszer alvó állapota

Az Omarchy alapértelmezetten engedélyezi a felfüggesztést, a hibernálást pedig amint beállítod, de ha bármelyikkel gondod van a gépeden, kikapcsolhatod őket.

Az NVIDIA GB10-es gépeken, például a DGX Spark és az ASUS Ascent GX10 esetében a felfüggesztés és a hibernálás ki van kapcsolva, akárcsak az NVIDIA DGX OS rendszerében, mert ezen a hardveren még nem bizonyult működőképesnek az alvás. Ugyanez vonatkozik az ASUS Zenbook A16 (UX3607OA) modellre is, ahol a felfüggesztés még nem altatja el teljesen a chipet, és éjszakára lefagyhat. Ott a felfüggesztés kapcsolója és a hibernálás beállítása nem érvényes. Az alvás visszakapcsolásához töröld a `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` fájlt a `sudo rm` paranccsal; a Felfüggesztés ezután visszakerül a menübe, a hibernálás pedig a többi géphez hasonlóan beállítható. A `sudo omarchy apply hardware --install-user "$USER"` parancs futtatása visszateszi a fájlt.

### Energiaprofilok

Laptopon az Omarchy külön megjegyzi az energiaprofilodat a hálózati tápról és az akkumulátorról történő működéshez, és a csatlakoztatáskor, illetve a kihúzáskor vált a kettő között. Ez alapból azt jelenti, hogy hálózati tápon performance, akkumulátoron pedig balanced profilt használ.

A `omarchy powerprofiles list` paranccsal megnézheted, mit kínál a géped, az `omarchy powerprofiles set autodetect power-saver` paranccsal pedig beállíthatod a kívántat ahhoz az állapothoz, amelyben éppen vagy. Ha a másik állapotot akarod beállítani anélkül, hogy bármit is kihúznál, nevezd meg közvetlenül: `omarchy powerprofiles set battery power-saver`. Amit választasz, azt kapod vissza legközelebb is, amikor abban az állapotban leszel.

### A felfüggesztés be- és kikapcsolása

A felfüggesztést a terminálból futtatott `omarchy toggle suspend` paranccsal kapcsolhatod ki és be. Ez csak megjeleníti/elrejti a lehetőséget a _Rendszer_ alatt (vagy `Super + Esc`), ezután pedig megnézheted, következetesen működik-e a rendszereden. Ha nem, ugyanezzel a paranccsal ismét elrejtheted.

### A hibernálás be- és kikapcsolása

A hibernálást a terminálból futtatott `omarchy hibernation setup` paranccsal állíthatod be (Apple Silicon Mac gépeken nem érhető el). A hibernálás egy /swap al-kötetet hoz létre a rendszerindító meghajtódon, amelynek mérete megegyezik a fizikai RAM méretével, ezért gondoskodj róla, hogy bőven legyen szabad helyed. Egy 32GB-os gépen ehhez a kötethez mindig 32GB+ szabad helyre lesz szükséged. A hibernáláshoz az alapértelmezett Limine rendszerbetöltőre is szükség van.

Ha be van állítva, a hibernálás lehetőségét a _Rendszer_ alatt (vagy `Super + Esc`) látod majd, ezután pedig megnézheted, következetesen működik-e a rendszereden. Ha nem, a `omarchy hibernation remove` parancs futtatásával ismét eltávolíthatod.
