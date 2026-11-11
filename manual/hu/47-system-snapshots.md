# Rendszer-pillanatképek

Minden Omarchy-frissítéskor automatikusan létrehozunk pillanatképeket, de ha sajátot szeretnél készíteni, használhatod az `omarchy-snapshot create` parancsot.

Pillanatkép indításához és visszaállításához a Limine boot loaderből kell kiválasztanod. (Ha jelenleg közvetlenül az Omarchy visszafejtési képernyőjére bootolsz, először a BIOS-on keresztül kell kiválasztanod a Limine-t bootolási lehetőségként).

Ezen a képernyőn a dátum és a verzió alapján válaszd ki azt a pillanatképet, amelyikbe bootolni szeretnél. Az Omarchy pillanatkép készítésekor aktuális verziója a bal alsó sarokban látható.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Amikor beérsz, megjelenik egy értesítés, amely tájékoztat arról, hogy bootolható pillanatképben vagy, és ha rákattintasz, elindul a visszaállítási folyamat. Alternatívaként használhatod az `omarchy-snapshot restore` parancsot is.

 ![snapshots-restore](images/snapshots-restore.webp)

Ez visszaállítja a root fájlrendszeredet, de a `/home` könyvtáradat nem. Tehát egy elromlott rendszerfrissítés visszavonására alkalmas, elveszett személyes fájlok visszaállítására viszont nem.

Ez azt is jelenti, hogy a `~/.config` könyvtárad változatlan marad. Tehát ha egy olyan könyvtár vagy alkalmazás korábbi verziójára állsz vissza, amely új formátumban tárolja a konfigurációs fájlokat, azt kézzel kell majd rendbe tenned.

Ugyanez vonatkozik az Omarchy saját nyilvántartására is arról, hogy mely migrációk futottak már le: ez a home könyvtáradban található, így túléli a visszaállítást. Azok a migrációk, amelyek a pillanatkép készítése után futottak le, továbbra is késznek jelöltek maradnak, hiába lettek visszavonva a root fájlrendszeren végrehajtott változtatásaik, és a következő `omarchy update` nem fogja őket újra lefuttatni. Tehát ha egy visszaállítás után újra frissítesz, és valami, amit egy korábbi frissítés beállított, továbbra is hiányzik, valószínűleg ez az oka.

_Megjegyzés: Ez a funkció csak azokon a telepítéseken érhető el, amelyek a Limine boot loadert használják, amely az Omarchy 2.0 óta az alapértelmezett. Nem érhető el, ha GRUB-ot vagy systemd-bootot használsz._

### A boot menü kihagyása

Ha soha nem nyúlsz a boot menühöz, és csak azt szeretnéd, hogy a gép egyenesen a visszafejtési képernyőre menjen, futtasd a _Setup > Direct Boot_ lehetőséget az Omarchy menüben. Ez hozzáad egy EFI bejegyzést, amely közvetlenül az Omarchyra mutat, így a firmware anélkül bootolja, hogy megállna a Limine-nél.

A kompromisszum az, amit felül említettünk: ha a közvetlen bootolás be van kapcsolva, egy pillanatkép eléréséhez először a BIOS boot menüjéből kell kiválasztanod a Limine-t. Futtasd újra a _Setup > Direct Boot_ lehetőséget a bejegyzés eltávolításához és a Limine-n keresztüli bootoláshoz való visszatéréshez. Egyes firmware-ek nem viselik jól az egyéni EFI bejegyzéseket, ezért a beállítás nem hajlandó futni American Megatrends és Apple firmware-en.
