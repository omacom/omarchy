# Rendszeralvás

Az Omarchy alapértelmezetten engedélyezi a felfüggesztést, a beállítása után pedig a hibernálást is, de ha bármelyikkel gondod van a gépeden, kikapcsolhatod őket.

NVIDIA GB10 gépeken, például a DGX Spark és az ASUS Ascent GX10 esetén a felfüggesztés és a hibernálás ki van kapcsolva, ahogy az NVIDIA DGX OS rendszerében is, mert az alvás még nem bizonyult működőképesnek azon a hardveren. A felfüggesztés kapcsolója és a hibernálás beállítása ott nem érvényes. Az alvás visszakapcsolásához töröld a `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` fájlt a `sudo rm` paranccsal; a Felfüggesztés ezután visszakerül a menübe, és a hibernálás a többi géphez hasonlóan beállítható. A `sudo omarchy apply hardware --install-user "$USER"` futtatása visszaállítja a fájlt.

### Energiaprofilok

Laptopon az Omarchy külön megjegyzi az energiaprofilodat hálózatra csatlakoztatott és akkumulátorról működő állapothoz, és vált a kettő között, ahogy csatlakoztatod és kihúzod. Alapból ez teljesítményt jelent AC mellett és kiegyensúlyozottat akkumulátoron.

Megnézheted, mit kínál a géped az `omarchy powerprofiles list` paranccsal, és beállíthatod a kívántat az aktuális állapotodhoz az `omarchy powerprofiles set autodetect power-saver` paranccsal. A másik állapot beállításához anélkül, hogy bármit kihúznál, nevezd meg közvetlenül: `omarchy powerprofiles set battery power-saver`. Bármit választasz, azt kapod vissza legközelebb, amikor abban az állapotban vagy.

### Felfüggesztés kapcsolása

A felfüggesztést a terminálból az `omarchy toggle suspend` futtatásával kapcsolhatod. Ez csak megjeleníti/elrejti a lehetőséget a _System_ alatt (vagy `Super + Esc`), és ezután megnézheted, megbízhatóan működik-e a rendszereden. Ha nem, ugyanazzal a paranccsal újra elrejtheted.

### Hibernálás kapcsolása

A hibernálást a terminálból az `omarchy hibernation setup` futtatásával állíthatod be (Apple Silicon Mac gépeken nem elérhető). A hibernálás létrehoz egy /swap alkötetet a rendszerindító meghajtódon a fizikai RAM méretével egyező méretben, ezért gondoskodj róla, hogy bőven legyen szabad helyed. Egy 32GB-os gépen ehhez a kötethez mindig 32GB+ szabad helyre lesz szükséged. A hibernáláshoz az alapértelmezett Limine bootloader is szükséges.

Ha be van állítva, a hibernálás lehetőséget a _System_ alatt (vagy `Super + Esc`) látod, és ezután megnézheted, megbízhatóan működik-e a rendszereden. Ha nem, az `omarchy hibernation remove` futtatásával újra eltávolíthatod.
