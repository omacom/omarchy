# Rendszeralvás

Az Omarchy alapértelmezetten engedélyezi a felfüggesztést és a hibernálást, de ha bármelyikkel problémád van a gépeden, kikapcsolhatod őket.

### Energiaprofilok

Laptopon az Omarchy külön megjegyzi az energiaprofilod a hálózati tápláláshoz és az akkumulátoros működéshez, és a kettő között vált, ahogy bedugod és kihúzod. Alapból ez teljesítményt jelent hálózatról, és kiegyensúlyozott módot akkumulátorról.

Az `omarchy powerprofiles list` paranccsal megnézheted, mit kínál a géped, és az `omarchy powerprofiles set autodetect power-saver` paranccsal beállíthatod azt, amelyiket az éppen aktuális állapotodhoz akarod. Ha a másik állapotot akarod beállítani anélkül, hogy bármit kihúznál, nevezd meg közvetlenül: `omarchy powerprofiles set battery power-saver`. Amit kiválasztasz, azt kapod vissza legközelebb is, amikor abban az állapotban vagy.

### Felfüggesztés kapcsolása

A felfüggesztést az `omarchy toggle suspend` terminálparancs futtatásával kapcsolod. Ez csak megmutatja/elrejti a lehetőséget a _Rendszer_ alatt (vagy `Super + Esc`), és így megnézheted, következetesen működik-e a rendszereden. Ha nem, ugyanazzal a paranccsal újra elrejtheted.

### Hibernálás kapcsolása

A hibernálást az `omarchy hibernation setup` terminálparancs futtatásával állítod be. A hibernálás egy /swap alkötetet hoz létre a rendszerindító meghajtódon a fizikai RAM-kiosztásod méretében, úgyhogy győződj meg róla, hogy bőven van szabad helyed. Egy 32 GB-os gépen ehhez a kötethez mindig több mint 32 GB szabad helyre lesz szükséged. A hibernáláshoz az alapértelmezett Limine rendszerbetöltő is szükséges.

Ha be van állítva, a hibernálás lehetőségét a _Rendszer_ alatt (vagy `Super + Esc`) látod, és így megnézheted, következetesen működik-e a rendszereden. Ha nem, az `omarchy hibernation remove` futtatásával újra eltávolíthatod.
