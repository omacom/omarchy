# Rendszer-pillanatképek

Minden Omarchy-frissítéskor automatikusan létrehozunk pillanatképeket, de ha sajátot szeretnél létrehozni, használhatod az `omarchy-snapshot create` parancsot.

Egy pillanatkép indításához és visszaállításához a Limine rendszerbetöltőből választod ki. (Ha jelenleg egyenesen az Omarchy dekódolási képernyőjére indulsz, először a BIOS-ból kell a Limine-t rendszerindítási lehetőségként kiválasztanod).

Arról a képernyőről válaszd ki azt a pillanatképet, amelybe be szeretnél indulni, a dátum és a verzió alapján. Az Omarchy verziója a pillanatkép időpontjában a bal alsó sarokban látható.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Amikor beérsz, egy értesítés ugrik fel, jelezve, hogy egy indítható pillanatképben vagy, és ha rákattintasz, elindítja a visszaállítási folyamatot. Alternatívaként használhatod az `omarchy-snapshot restore` parancsot.

 ![snapshots-restore](images/snapshots-restore.webp)

Ez visszaállítja a gyökér fájlrendszered, de a `/home` mappádat nem. Így működik egy tört rendszerfrissítés visszavonásához, de elveszett személyes fájlok visszaállításához nem.

Ez azt is jelenti, hogy a `~/.config` könyvtárad változatlanul megmarad. Így ha egy olyan könyvtár vagy alkalmazás korábbi verziójára állsz vissza, amely új formátumban tárol konfigurációs fájlokat, azt kézzel kell rendezned.

_Megjegyzés: Ez a funkció csak a Limine rendszerbetöltőt használó telepítéseken érhető el, amely az Omarchy 2.0 óta az alapértelmezett. Nem érhető el, ha GRUB-on vagy systemd-booton vagy._

### A rendszerindítási menü átugrása

Ha soha nem nyúlsz a rendszerindítási menühöz, és csak azt akarod, hogy a gép egyenesen a dekódolási képernyőre menjen, futtasd az Omarchy menü _Beállítás > Közvetlen indítás_ pontját. Ez egy EFI-bejegyzést ad hozzá, amely közvetlenül az Omarchyra mutat, így a firmware anélkül indítja, hogy megállna a Limine-nál.

A kompromisszum az a fejezet elején említett: bekapcsolt közvetlen indítással egy pillanatképhez jutáshoz először a BIOS rendszerindítási menüjéből kell a Limine-t kiválasztani. Futtasd újra a _Beállítás > Közvetlen indítás_ pontot a bejegyzés eltávolításához és a Limine-on keresztüli indításra való visszatéréshez. Egyes firmware-ek nem viselik jól az egyéni EFI-bejegyzéseket, így a beállítás nem fut le American Megatrends és Apple firmware-en.
