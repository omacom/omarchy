# Hibaelhárítás

### Egy frissítéssel tönkretettem a rendszerem!

Először próbáld meg [visszaállítani a rendszered](47-system-snapshots.md) a legutóbbi frissítésed előtti verzióra. Ha ez nem működik, az `omarchy-debug` segítségével oszd meg a problémádat a Discord #omarchy-help csatornáján. És ha mindez kudarcot vall, az `omarchy-reinstall` használatával újratelepítheted az alapértelmezett konfigurációkat és csomagokat.

### Miért olyan nagy néhány alkalmazás a kijelzőmön?

Az Omarchy 2x nagy felbontású kijelzőt feltételez, amihez a `GDK_SCALE` értékét 2-re kell állítani a `~/.config/hypr/monitors.lua` fájlban. De ha 1x kijelzőn vagy, a `local omarchy_gdk_scale = 2` értéket 1-re változtathatod (majd indíts újra minden túlméretes alkalmazást). Lásd [a monitorokról szóló kézikönyvet](33-monitors.md).

A Spotify esetében a `Ctrl + Minus` kombinációval zsugoríthatod a felületet (és a `Ctrl + Plus` kombinációval nagyobbá teheted).

### A Wi-Fim, Bluetoothom, hangom vagy érintőpadom egyszerűen leállt

Mielőtt újraindítasz, próbáld meg önmagában újraindítani a hibás alrendszert. Az Omarchy menü _Frissítés > Hardver_ pontjában van Wi-Fi, Bluetooth, Hang és Érintőpad, és ezek egyikének újratöltése az „öt perce még működött" helyzetek többségét megoldja — egy Bluetooth-headsetet, amely nem csatlakozik újra, egy érintőpadot, amely felfüggesztés után elhalt, hangot, amely eltűnt, amikor kihúztál egy monitort.

### Miért nem szólnak a külső hangszóróim?

Valószínűleg azért, mert nincsenek beállítva elsődleges kimenetként. Kattints a sáv jobb oldalán lévő hangszóróikonra, és megnyitja a hangerő-felugró ablakot, ahol kiválaszthatod a kimeneti eszközt (és alkalmazásonként keverheted a hangerőt is).

### A laptopom hangszórói furcsán szólnak

Néhány laptopon az Omarchy automatikusan alkalmaz egy hangszóró-hangolást, amely korrigálja a beépített hangszórók frekvenciaválaszát. Az `omarchy audio tuning status` megmondja, aktív-e egy a gépeden, az `omarchy audio tuning off` pedig kikapcsolja, ha inkább nyersen hallgatnád a hangszórókat.

### Miért nem tudok bejelentkezni vagy sudózni a jelszavammal?

Valószínűleg túl sokszor írtad be rosszul, és kizártad magad. Ha ez a zárolási képernyőn történik, a `CTRL + ALT + F2` kombinációval új TTY-t indíthatsz, ahol rootként jelentkezhetsz be, majd futtathatod a `faillock --reset --user [your-username]` parancsot. Ez visszaállítja a kizárást, és máris mehetsz.

### Miért nem jelennek meg az 1Password engedélyezési kéréseim az 1Password SSH Agenthez / CLI-hez?

Ez 2 okból történhet:

Ahhoz, hogy a gazdag jóváhagyási kérés megjelenjen, a Settings > Advanced > Use Hardware Acceleration beállításnak bekapcsolva kell lennie. _Megjegyzés: Ennek működésbe lépéséhez újraindítás szükséges._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vagy ha nem indítottad el az 1Passwordöt a gép bekapcsolása óta, a kérés nem jelenik meg.
