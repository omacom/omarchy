# Hibaelhárítás

### Tönkretettem a rendszeremet egy frissítéssel!

Először próbáld meg [visszaállítani a rendszeredet](47-system-snapshots.md) a legutóbbi frissítésed előtti verzióra. Ha ez nem működik, használd az `omarchy-debug` parancsot, hogy megoszd a problémádat a Discordon a #omarchy-help csatornán. És ha minden kötél szakad, újratelepítheted az alapértelmezett konfigurációkat és csomagokat az `omarchy-reinstall` paranccsal.

### Miért olyan nagyok egyes appok a kijelzőmön?

Az Omarchy 2x nagy felbontású kijelzőt feltételez, amihez a `GDK_SCALE` értékét 2-re kell állítani a `~/.config/hypr/monitors.lua` fájlban. De ha 1x kijelződ van, átírhatod a `local omarchy_gdk_scale = 2` értéket 1-re (majd indítsd újra minden olyan appot, ami túl nagy). Lásd [a kézikönyvet a monitorokról](33-monitors.md).

Spotify esetén a `Ctrl + Minus` billentyűkombinációval kicsinyítheted a kezelőfelületet (a `Ctrl + Plus` billentyűkombinációval pedig nagyobbá teheted).

### Miért nem működnek hirtelen a Super billentyűs gyorsbillentyűim?

Egyes ASUS ROG és TUF laptopokon a `Fn + Super` egy könnyen észrevétlenül lenyomható billentyűkombináció, ami egy firmware-es Windows-billentyűzárat kapcsol be és ki (játékhoz találták ki, hogy véletlenül se lépj ki egy játékból). Semmi sem jelzi a képernyőn, hogy ez megtörtént. Amíg a zár be van kapcsolva, a Super egyáltalán nem küld semmit — így minden Omarchy-gyorsbillentyű, ami Supert használ, egyszerűen nem működik, és úgy tűnik, mintha a Hyprland romlott volna el.

Nyomd meg egyszer a `Fn + Super` billentyűkombinációt, mielőtt elkezdenél turkálni a `~/.config/hypr/` könyvtárban, és ha ettől nem tér vissza a Super, nyomd meg még egyszer, hogy ne hagyd bekapcsolva a zárat. Ez nem az Fn-zár, ami csak azt változtatja meg, hogyan működik az F-billentyűk sora.

### Nem működik a Wi-Fi-m, a Bluetoothom, a hangom vagy az érintőpadom

Mielőtt újraindítanád a gépet, próbáld meg önmagában újraindítani a problémás alrendszert. Az Omarchy menüben az _Update > Hardware_ alatt megtalálod a Wi-Fi, Bluetooth, Audio és Trackpad lehetőségeket, és ezek egyikének újratöltése megoldja a legtöbb „öt perce még működött” helyzetet — egy Bluetooth-headsetet, ami nem akar újracsatlakozni, egy érintőpadot, ami felfüggesztés után meghalt, vagy hangot, ami eltűnt, amikor kihúztál egy monitort.

### Miért nem szólnak a külső hangszóróim?

Valószínűleg azért, mert nincsenek beállítva elsődleges kimenetként. Kattints a hangszóró ikonra a sáv jobb oldalán, és megnyílik a hangerő-felugró ablak, ahol kiválaszthatod a kimeneti eszközt (és appkonként keverheted a hangerőt is).

### Furcsán szólnak a laptopom hangszórói

Egyes laptopokon az Omarchy automatikusan alkalmaz egy hangszóró-hangolást, ami korrigálja a beépített hangszórók frekvenciaválaszát. Az `omarchy audio tuning status` megmondja, aktív-e ilyen a gépeden, az `omarchy audio tuning off` pedig kikapcsolja, ha inkább nyersen szeretnéd hallani a hangszórókat.

### Miért nem tudok bejelentkezni vagy sudo-zni a jelszavammal?

Valószínűleg túl sokszor írtad be rosszul, és kizártad magad. Ha ez a zárolási képernyőn történik, nyomd meg a `CTRL + ALT + F2` billentyűkombinációt egy új TTY indításához, ahol bejelentkezhetsz root felhasználóként, majd futtasd a `faillock --reset --user [your-username]` parancsot. Ez visszaállítja a kizárást, és már mehetsz is tovább.

### Miért nem jelennek meg az 1Password engedélyezési felkérései az 1Password SSH Agent / CLI esetében?

Ennek 2 oka lehet:

Ahhoz, hogy a részletes jóváhagyási felkérés megjelenjen, a Settings > Advanced > Use Hardware Acceleration beállítást be kell kapcsolni. _Megjegyzés: Ennek működéséhez újraindítás szükséges._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vagy ha a rendszerindítás óta nem indítottad el az 1Passwordot, a felkérés nem fog megjelenni.
