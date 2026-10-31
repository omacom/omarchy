# Hibaelhárítás

### Frissítéssel tönkretettem a rendszeremet!

Először próbáld meg [visszaállítani a rendszert](47-system-snapshots.md) a legutóbbi frissítésed előtti verzióra. Ha ez nem működik, használd az `omarchy-debug` parancsot, hogy megoszd a problémádat a Discordon a #omarchy-help csatornán. És ha minden kötél szakad, az `omarchy-reinstall` paranccsal újratelepítheted az alapértelmezett konfigurációkat és csomagokat.

### Miért olyan nagyok egyes alkalmazások a kijelzőmön?

Az Omarchy 2x nagy felbontású kijelzőt feltételez, ezért a `GDK_SCALE` értékét 2-re állítja, amíg nem választasz méretezést a monitor panelen. Ha 1x kijelződ van, és a GTK vagy X11 alkalmazások túlméretezetten jelennek meg, válaszd hozzá az 1x beállítást a monitor panelen, vagy add hozzá a `hl.env("GDK_SCALE", "1")` sort a `~/.config/hypr/monitors.lua` fájlhoz (majd indítsd újra minden túlméretezett alkalmazást). Lásd [a monitorokról szóló kézikönyvet](33-monitors.md).

A Spotify esetén a `Ctrl + Minus` kombinációval kicsinyítheted a felületet (a `Ctrl + Plus` kombinációval pedig nagyíthatod).

### Miért nem működnek többé a Super billentyűkombinációim?

Egyes ASUS ROG és TUF laptopokon az `Fn + Super` egy könnyen észrevétlenül lenyomható kombináció, amely egy firmware-szintű Windows-billentyű zárolást kapcsol be és ki (játékhoz találták ki, hogy véletlenül se lépj ki egy játékból). Semmi nem jelzi a képernyőn, hogy megtörtént. Amíg a zárolás aktív, a Super egyáltalán nem küld jelet — így minden Omarchy-kombináció, amely Supert használ, egyszerűen működésképtelenné válik, és úgy tűnik, mintha a Hyprland romlott volna el.

Nyomd le egyszer az `Fn + Super` kombinációt, mielőtt elkezdenél turkálni a `~/.config/hypr/` mappában, és ha ez nem hozza vissza a Supert, nyomd le újra, hogy ne hagyd bekapcsolva a zárolást. Ez nem az Fn-lock, az csak azt változtatja meg, hogyan működik az F-billentyűk sora.

### Egyszer csak leállt a Wi-Fi, a Bluetooth, a hang vagy az érintőpad

Újraindítás előtt próbáld meg önmagában újraindítani a problémás alrendszert. Az Omarchy menü _Update > Hardware_ pontjában megtalálod a Wi-Fi, Bluetooth, Audio és Trackpad lehetőségeket, és ezek egyikének újratöltése megoldja az „öt perce még működött" helyzetek többségét — egy Bluetooth-headsetet, amely nem hajlandó újracsatlakozni, egy felfüggesztés után meghalt érintőpadot, vagy a hangot, amely eltűnt, amikor kihúztál egy monitort.

### Miért nem szólnak a külső hangszóróim?

Valószínűleg azért, mert nincsenek beállítva elsődleges kimenetként. Kattints a hangszóró ikonra a sáv jobb oldalán, és megnyílik a hangerő felugró ablak, ahol kiválaszthatod a kimeneti eszközt (és alkalmazásonként is keverheted a hangerőt).

### Furcsán szólnak a laptopom hangszórói

Egyes laptopokon az Omarchy automatikusan alkalmaz egy hangszóró-hangolást, amely korrigálja a beépített hangszórók frekvenciaátvitelét. Az `omarchy audio tuning status` megmondja, aktív-e ilyen a gépeden, az `omarchy audio tuning off` pedig kikapcsolja, ha inkább nyersen szeretnéd hallani a hangszórókat.

### Miért nem tudok bejelentkezni vagy sudózni a jelszavammal?

Valószínűleg túl sokszor írtad be rosszul, és kizártad magad. Ha ez a zárolási képernyőn történik, nyomd le a `CTRL + ALT + F2` kombinációt egy új TTY indításához, ahol rootként bejelentkezhetsz, majd futtasd a `faillock --reset --user [your-username]` parancsot. Ez visszaállítja a kizárást, és már mehetsz is.

### Miért nem jelennek meg az 1Password engedélyezési kérései az 1Password SSH Agent / CLI számára?

Ennek 2 oka lehet:

Ahhoz, hogy a részletes jóváhagyási kérés megjelenjen, a Settings > Advanced > Use Hardware Acceleration beállítást be kell kapcsolni. _Megjegyzés: Ahhoz, hogy ez működni kezdjen, újraindítás szükséges._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vagy ha a rendszerindítás óta nem indítottad el az 1Password alkalmazást, a kérés nem fog megjelenni.
