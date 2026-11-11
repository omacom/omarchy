# Hibaelhárítás

### Elrontottam a rendszeremet egy frissítéssel!

Először próbáld meg [visszaállítani a rendszeredet](47-system-snapshots.md) a legutóbbi frissítés előtti verzióra. Ha ez nem működik, használd az `omarchy-debug` parancsot, hogy megoszd a problémádat a #omarchy-help csatornán a Discordon. Ha pedig minden más kudarcot vall, az `omarchy-reinstall` paranccsal újratelepítheted az alapértelmezett konfigurációkat és csomagokat.

### Miért olyan nagyok egyes alkalmazások a kijelzőmön?

Az Omarchy 2x-es nagy felbontású kijelzőt feltételez, ezért a `GDK_SCALE` értékét 2-re állítja, amíg ki nem választasz egy méretezést a monitorpanelen. Ha 1x-es kijelződ van, és a GTK vagy X11 alkalmazások túlméretezve jelennek meg, válaszd az 1x-et neki a monitorpanelen, vagy add hozzá a `hl.env("GDK_SCALE", "1")` sort a `~/.config/hypr/monitors.lua` fájlhoz (majd indítsd újra minden túlméretezett alkalmazást). Lásd [a monitorokról szóló kézikönyvet](33-monitors.md).

A Spotify esetében a `Ctrl + Minus` billentyűkombinációval kicsinyítheted a felületet (a `Ctrl + Plus` kombinációval pedig nagyobbra állíthatod).

### Miért szűntek meg működni az összes Super billentyűkombinációm?

Néhány ASUS ROG és TUF laptopon az `Fn + Super` egy könnyen észrevétlen kombináció, amely egy firmware-szintű Windows-billentyű zárat kapcsol be és ki (játékhoz találták ki, hogy véletlenül se lépj ki egy játékból). Semmi nem jelzi a képernyőn, hogy ez megtörtént. Amíg a zár be van kapcsolva, a Super egyáltalán semmit nem küld — így minden Omarchy-kombináció, amely a Supert használja, egyszerűen leáll, és úgy tűnik, mintha a Hyprland romlott volna el.

Nyomd meg egyszer az `Fn + Super` kombinációt, mielőtt elkezdenél kutakodni a `~/.config/hypr/` könyvtárban, és ha ez nem hozza vissza a Supert, nyomd meg még egyszer, hogy ne hagyd bekapcsolva a zárat. Ez nem az Fn-lock, amely csak azt változtatja meg, mit csinál az F-billentyűsor.

### A Wi-Fi, a Bluetooth, a hang vagy az érintőpad egyszerűen leállt

Mielőtt újraindítanád a gépet, próbáld meg önmagában újraindítani a problémás alrendszert. Az Omarchy menüben az _Update > Hardware_ alatt megtalálod a Wi-Fi, Bluetooth, Audio és Trackpad lehetőségeket, és ezek egyikének újratöltése megoldja az „öt perce még működött” helyzetek többségét — egy Bluetooth-headsetet, amely nem akar újracsatlakozni, egy érintőpadot, amely felfüggesztés után meghalt, vagy a hangot, amely eltűnt, amikor kihúztál egy monitort.

### Miért nem szólnak a külső hangszóróim?

Valószínűleg azért, mert nincsenek beállítva elsődleges kimenetként. Kattints a sáv jobb oldalán lévő hangszóróikonra, és megnyílik a hangerő-felugró ablak, ahol kiválaszthatod a kimeneti eszközt (és alkalmazásonként is állíthatod a hangerőt).

### Furcsán szólnak a laptopom hangszórói

Néhány laptopon az Omarchy automatikusan alkalmaz egy hangszóró-hangolást, amely korrigálja a beépített hangszórók frekvenciaválaszát. Az `omarchy audio tuning status` megmondja, aktív-e ilyen a gépeden, az `omarchy audio tuning off` pedig kikapcsolja, ha inkább nyersen szeretnéd hallani a hangszórókat.

### Miért nem tudok bejelentkezni vagy sudo parancsot használni a jelszavammal?

Valószínűleg túl sokszor írtad be rosszul, és kizártad magad. Ha ez a zárolási képernyőn történik, nyomd meg a `CTRL + ALT + F2` kombinációt egy új TTY indításához, ahol rootként jelentkezhetsz be, majd futtasd a `faillock --reset --user [your-username]` parancsot. Ez visszaállítja a kizárást, és már mehetsz is tovább.

### Elfogadja a jelszavamat, de visszakerülök a bejelentkezési képernyőre

Egy hibás munkamenet-környezeti fájl megakadályozhatja az asztal elindulását akkor is, ha a jelszavad helyes. Ezt különösen érdemes ellenőrizni a `~/.config/uwsm/env.d/` szerkesztése után.

Nyomd meg a `Ctrl + Alt + F2` kombinációt, jelentkezz be a szokásos felhasználóneveddel és jelszavaddal, és nézd meg az aktuális rendszerindítás felhasználói naplóját:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Keress egy hibát, amely megnevezi az egyik környezeti fájlodat, például `bad substitution`, közvetlenül azelőtt az üzenet előtt, hogy az env kimeneti jel nem található. Mielőtt újra megpróbálnál bejelentkezni, mozgasd ki azt a fájlt az `env.d` könyvtárból. Ha például a hiba a `99-custom` fájlt nevezi meg:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

Az UWSM kihagy egy szintaktikai hibát tartalmazó fájlt, de egy végzetes hiba, amely csak a fájl futása közben jelentkezik, mint a `bad substitution`, továbbra is megakadályozhatja az asztal elindulását. A rendszer-pillanatkép visszaállítása nem javítja meg ezeket a fájlokat, mert a `/home` nem kerül visszaállításra.

Miután be tudsz jelentkezni, javítsd ki a mentett másolatot, mielőtt visszamozgatnád. Az `sh -n` a fájl futtatása nélkül elkapja a szintaktikai hibákat, de nem tud minden olyan hibát elkapni, amely a forrásként való betöltésekor lép fel. Tarts nyitva egy működő terminált a módosítások tesztelése közben.

### Miért nem jelennek meg az 1Password engedélyezési üzenetei az 1Password SSH Agent / CLI esetében?

Ennek 2 oka lehet:

Ahhoz, hogy a részletes jóváhagyási üzenet megjelenjen, a Settings > Advanced > Use Hardware Acceleration beállítást be kell kapcsolni. _Megjegyzés: Ehhez újraindítás szükséges, hogy működni kezdjen._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vagy ha a rendszerindítás óta nem indítottad el az 1Passwordot, az üzenet nem fog megjelenni.
