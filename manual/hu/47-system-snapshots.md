# Rendszer-pillanatképek

Automatikusan készítünk pillanatképeket minden Omarchy-frissítésnél, de ha sajátot szeretnél készíteni, használhatod az `omarchy-snapshot create` parancsot.

Hogy hogyan bootolsz be egy pillanatképbe és hogyan állítod vissza, az attól függ, milyen boot loaderrel indul a géped. Az új UEFI telepítések systemd-bootot használnak; a régebbi telepítések és a BIOS-os gépek Limine-t. Az `omarchy-boot-backend` megmondja, neked melyik van.

## systemd-boot esetén

Válaszd a _System > Snapshots_ pontot az Omarchy menüben, és válaszd ki a pillanatképet, amelyikbe bootolni szeretnél. A gép egyszer újraindul bele. Vagy tartsd lenyomva a Space billentyűt a gép indulása közben, hogy lásd a boot menüt, ahol minden pillanatkép a legújabbtól kezdve szerepel, az Omarchy verziójával és dátumával együtt.

Egy pillanatkép ideiglenes réteggel a tetején indul, így normálisan használhatod, de minden változtatásod elvész a következő újraindításkor. Ha meg akarod tartani, tedd a rendszereddé: kattints a bejelentkezéskor megjelenő értesítésre, válaszd a _System > Snapshots > Restore This Snapshot_ pontot, vagy futtasd az `omarchy-snapshot restore` parancsot. A visszaállítás a gép újraindulása közben történik. A korábbi állapotú rendszer _Before restore_ néven a boot menüben marad, és az `omarchy-snapshot restore backup` állítja vissza.

Terminálból:

- az `omarchy-snapshot list` felsorolja a bootolható pillanatképeket;
- az `omarchy-snapshot boot 12` egyszer újraindít a 12-es pillanatképbe;
- az `omarchy-snapshot restore 12` a következő újraindításkor a 12-es pillanatképet teszi a rendszerré, az `omarchy-snapshot restore --cancel` pedig meggondolhatod magad az újraindítás előtt.

## Limine esetén

Pillanatkép bootolásához és visszaállításához azt a Limine boot loaderből kell kiválasztanod. A boot menü alapértelmezetten rejtve marad, ezért nyomj meg egy billentyűt, amint a Limine elindul, hogy előhozd.

Ezen a képernyőn a dátum és a verzió alapján válaszd ki a pillanatképet, amelyikbe bootolni szeretnél. A pillanatkép készítésekor használt Omarchy verziója a bal alsó sarokban látható.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Amikor beérkezel, felugrik egy értesítés, amely jelzi, hogy bootolható pillanatképben vagy, és ha rákattintasz, elindítja a visszaállítási folyamatot. Alternatívaként használhatod az `omarchy-snapshot restore` parancsot.

 ![snapshots-restore](images/snapshots-restore.webp)

## Mire terjed ki a visszaállítás

A visszaállítás a gyökér fájlrendszert hozza vissza, de a `/home` könyvtárat nem. Így jól működik egy elromlott rendszerfrissítés visszavonására, de elveszett személyes fájlok helyreállítására nem.

Ez azt is jelenti, hogy a `~/.config` könyvtárad változatlan marad. Ha tehát egy könyvtár vagy alkalmazás korábbi verziójára állsz vissza, amely új formátumban tárolja a konfigurációs fájlokat, azt kézzel kell rendbe tenned.

Ugyanez vonatkozik az Omarchy saját nyilvántartására arról, mely migrációk futottak már le: az a home könyvtáradban él, így túléli a visszaállítást. A pillanatkép készítése után lefutott migrációk továbbra is késznek jelölve maradnak, hiába vonták vissza a gyökér fájlrendszeren végzett módosításaikat, és a következő `omarchy update` nem futtatja őket újra. Ha tehát egy visszaállítás után újra frissítesz, és valami, amit egy korábbi frissítés állított be, továbbra is hiányzik, valószínűleg ez az oka.
