# Hibaelhárítás

### Elrontottam a rendszeremet egy frissítéssel!

Először próbáld meg [visszaállítani a rendszeredet](47-system-snapshots.md) a legutóbbi frissítés előtti verzióra. Ha ez nem működik, használd az `omarchy-debug` parancsot, hogy megoszd a problémádat a #omarchy-help csatornán a Discordon. És ha minden kötél szakad, az `omarchy-reinstall` segítségével újratelepítheted az alapértelmezett konfigurációkat és csomagokat.

### Miért olyan nagyok egyes alkalmazások a kijelzőmön?

Az Omarchy 2x-es, nagy felbontású kijelzőből indul ki, ezért a `GDK_SCALE` értékét 2-re állítja, amíg ki nem választasz egy méretezést a monitorpanelen. Ha 1x-es kijelződ van, és a GTK- vagy X11-alkalmazások túlméretezetten jelennek meg, válaszd hozzá az 1x-et a monitorpanelen, vagy add hozzá a `hl.env("GDK_SCALE", "1")` sort a `~/.config/hypr/monitors.lua` fájlhoz (majd indíts újra minden túlméretezett alkalmazást). Lásd [a monitorokról szóló kézikönyvet](33-monitors.md).

Spotify esetén a `Ctrl + Minus` billentyűkombinációval kicsinyítheted a felületet (a `Ctrl + Plus` kombinációval pedig nagyobbra veheted).

### Miért nem működik többé egyetlen Super billentyűkombinációm sem?

Egyes ASUS ROG és TUF laptopokon az `Fn + Super` egy könnyen észrevétlenül lenyomható kombináció, amely egy firmware-szintű Windows-billentyűzárat kapcsol be vagy ki (játékhoz találták ki, hogy véletlenül se lépj ki a játékból). Semmi sem jelzi a képernyőn, hogy megtörtént. Amíg a zár be van kapcsolva, a Super egyáltalán nem küld jelet — így minden Omarchy-kombináció, amely Supert használ, egyszerűen leáll, és úgy tűnik, mintha a Hyprland romlott volna el.

Nyomd meg egyszer az `Fn + Super` kombinációt, mielőtt nekiállnál turkálni a `~/.config/hypr/` könyvtárban, és ha ez nem hozza vissza a Supert, nyomd meg újra, hogy ne hagyd bekapcsolva a zárat. Ez nem az Fn-lock, az csak azt változtatja meg, hogyan működik az F-billentyűk sora.

### Egyszer csak leállt a Wi-Fi, a Bluetooth, a hang vagy az érintőpad

Újraindítás előtt próbáld meg önmagában újraindítani a rakoncátlankodó alrendszert. Az Omarchy menü _Update > Hardware_ pontjában megtalálod a Wi-Fi, Bluetooth, Audio és Trackpad lehetőségeket, és ezek egyikének újratöltése megoldja az „öt perce még működött” helyzetek többségét — egy Bluetooth-headsetet, amely nem hajlandó újracsatlakozni, egy érintőpadot, amely elaludt felfüggesztés után, vagy hangot, amely eltűnt, amikor kihúztál egy monitort.

### Miért nem szólnak a külső hangszóróim?

Valószínűleg azért, mert nincsenek beállítva elsődleges kimenetként. Kattints a sáv jobb oldalán lévő hangszóróikonra, és megnyílik a hangerő-felugró, ahol kiválaszthatod a kimeneti eszközt (és alkalmazásonként is keverheted a hangerőket).

### Furcsán szólnak a laptopom hangszórói

Egyes laptopokon az Omarchy automatikusan alkalmaz egy hangszóró-hangolást, amely korrigálja a beépített hangszórók frekvenciaválaszát. Az `omarchy audio tuning status` megmondja, aktív-e ilyen a gépeden, az `omarchy audio tuning off` pedig kikapcsolja, ha inkább nyersen hallanád a hangszórókat.

### Miért nem tudok bejelentkezni vagy sudózni a jelszavammal?

Valószínűleg tízszer elgépelted, és kizártad magad. A kizárás két perc után magától feloldódik. Ha nem tudsz várni, és ez a zárolási képernyőn történik, nyomd meg a `CTRL + ALT + F2` kombinációt egy új TTY indításához, ahol rootként bejelentkezhetsz, majd futtasd a `faillock --reset --user [your-username]` parancsot. Ez visszaállítja a kizárást, és már mehetsz is tovább.

### A rendszer elfogadja a jelszavamat, de visszakerülök a bejelentkezési képernyőre

Egy hibás munkamenet-környezeti fájl megakadályozhatja, hogy az asztal elinduljon, még akkor is, ha a jelszavad helyes. Ezt különösen érdemes ellenőrizni a `~/.config/uwsm/env.d/` szerkesztése után.

Nyomd meg a `Ctrl + Alt + F2` kombinációt, jelentkezz be a szokásos felhasználóneveddel és jelszavaddal, és nézd meg az aktuális rendszerindítás felhasználói naplóját:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Keresd azt a hibát, amely megnevezi az egyik környezeti fájlodat, például a `bad substitution` hibát, közvetlenül azelőtt az üzenet előtt, hogy az env kimeneti jelölés nem található. Mielőtt újra megpróbálnál bejelentkezni, mozgasd ki azt a fájlt az `env.d` könyvtárból. Ha például a hiba a `99-custom` fájlt nevezi meg:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

Az UWSM kihagy egy szintaktikai hibát tartalmazó fájlt, de egy végzetes hiba, amely csak a fájl futtatása közben jelentkezik, mint a `bad substitution`, továbbra is megakadályozhatja az asztal indulását. A rendszerpillanatkép visszaállítása nem javítja ezeket a fájlokat, mert a `/home` nem kerül visszaállításra.

Ha már be tudsz jelentkezni, javítsd ki a mentett másolatot, mielőtt visszateszed. Az `sh -n` a fájl futtatása nélkül elkapja a szintaktikai hibákat, de nem tud minden olyan hibát elkapni, amely a fájl forrásként való betöltésekor lép fel. A módosítások tesztelése közben tarts nyitva egy működő terminált.

### Miért nem jelennek meg a 1Password engedélyezési kérései a 1Password SSH Agent / CLI használatakor?

Ennek 2 oka lehet:

Ahhoz, hogy a részletes jóváhagyási kérés megjelenjen, a Settings > Advanced > Use Hardware Acceleration beállítást be kell kapcsolni. _Megjegyzés: Ennek életbe lépéséhez újraindítás szükséges._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vagy ha a rendszer indítása óta nem indítottad el a 1Passwordot, a kérés nem fog megjelenni.
