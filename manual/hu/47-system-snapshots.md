# Rendszerpillanatképek

Minden Omarchy frissítéskor automatikusan létrehozunk pillanatképeket, de ha sajátot szeretnél készíteni, használhatod az `omarchy-snapshot create` parancsot.

Pillanatkép indításához és visszaállításához a Limine rendszerbetöltőből kell kiválasztanod. A rendszerindító menü alapértelmezés szerint rejtve marad, ezért nyomj meg bármilyen billentyűt, amint a Limine elindul, hogy megjelenjen.

Ezen a képernyőn a dátum és a verzió alapján válaszd ki azt a pillanatképet, amelyet el szeretnél indítani. A pillanatkép készítésekor használt Omarchy verziója a bal alsó sarokban látható.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Amikor bejutottál, egy értesítés jelenik meg, amely tájékoztat arról, hogy indítható pillanatképben vagy, és ha rákattintasz, elindul a visszaállítási folyamat. Alternatívaként használhatod az `omarchy-snapshot restore` parancsot.

 ![snapshots-restore](images/snapshots-restore.webp)

Ez visszaállítja a gyökér fájlrendszeredet, de a `/home` könyvtáradat nem. Tehát működik egy hibás rendszerfrissítés visszaállítására, de elveszett személyes fájlok helyreállítására nem.

Ez azt is jelenti, hogy a `~/.config` könyvtárad változatlan marad. Tehát ha visszaállsz egy olyan könyvtár vagy alkalmazás korábbi verziójára, amely új formátumban tárolja a konfigurációs fájljait, ezt manuálisan kell majd rendezned.

Ugyanez vonatkozik az Omarchy saját nyilvántartására arról, hogy mely migrációk futottak már le: ez a saját könyvtáradban él, így túléli a visszaállítást. Azok a migrációk, amelyek a pillanatkép készítése után futottak, továbbra is végrehajtottként maradnak megjelölve, annak ellenére, hogy a gyökér fájlrendszeren végrehajtott módosításaikat visszavontuk, és a következő `omarchy update` nem futtatja őket újra. Tehát ha egy visszaállítás után újra frissítesz, és valami, amit egy korábbi frissítés beállított, továbbra is hiányzik, valószínűleg ez az oka.

_Megjegyzés: Ez a funkció csak olyan telepítéseken érhető el, amelyek a Limine rendszerbetöltőt használják, amely az Omarchy 2.0 óta az alapértelmezett. Nem érhető el, ha GRUB vagy systemd-boot rendszerbetöltőt használsz._
