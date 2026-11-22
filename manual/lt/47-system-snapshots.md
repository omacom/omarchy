# Sistemos momentinės kopijos

Mes automatiškai sukuriame momentines kopijas kiekvieną kartą atnaujinant Omarchy, bet jei norite susikurti savąją, galite naudoti `omarchy-snapshot create`.

Kad paleistumėte ir atkurtumėte momentinę kopiją, pasirinkite ją iš Limine paleidyklės. Paleisties meniu pagal numatytuosius nustatymus lieka paslėptas, todėl paspauskite bet kurį klavišą, kai tik paleidžiama Limine, kad jis atsirastų.

Tame ekrane pasirinkite momentinę kopiją, į kurią norite paleisti sistemą, pagal datą ir versiją. Kokia Omarchy versija buvo momentinės kopijos sukūrimo metu, galima pamatyti apatiniame kairiajame kampe.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kai pateksite į sistemą, iššoks pranešimas, pranešantis, kad esate paleidžiamoje momentinėje kopijoje, ir jei jį spustelėsite, bus pradėtas atkūrimo procesas. Kitas būdas – naudoti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Taip bus atkurta jūsų šakninė failų sistema, bet ne jūsų `/home`. Todėl tai veikia norint anuliuoti sugadintą sistemos naujinimą, bet ne norint atgauti prarastus asmeninius failus.

Tai taip pat reiškia, kad jūsų `~/.config` katalogas lieka toks, koks yra. Tad jei grįžtate prie ankstesnės bibliotekos ar programėlės versijos, kuri saugo konfigūracijos failus nauju formatu, turėsite tai susitvarkyti patys.

Tas pats galioja ir pačios Omarchy įrašui apie tai, kurios migracijos jau buvo paleistos: jis yra jūsų namų kataloge, todėl išlieka atstačius sistemą. Migracijos, paleistos po to, kai buvo sukurta momentinė kopija, lieka pažymėtos kaip atliktos, net nors jų padaryti šakninės failų sistemos pakeitimai buvo anuliuoti, ir kitas `omarchy update` jų vėl nepaleis. Tad jei atstačius sistemą vėl naujinsite ir vis dar trūks ko nors, ką ankstesnis naujinimas buvo nustatęs, štai greičiausia to priežastis.

_Pastaba: ši funkcija galima tik įrenginiuose, naudojančiuose Limine paleidyklę, kuri yra numatytoji nuo Omarchy 2.0. Ji negalima, jei naudojate GRUB arba systemd-boot._
