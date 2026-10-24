# Süsteemi hetktõmmised

Me loome hetktõmmiseid automaatselt iga Omarchy värskenduse korral, aga kui tahad oma luua, saad kasutada käsku `omarchy-snapshot create`.

Hetktõmmise alglaadimiseks ja taastamiseks valid selle Limine alglaadurist. (Kui alglaadid praegu otse Omarchy dekrüptimise kuvale, pead esmalt BIOS-i kaudu alglaadimisvalikuks valima Limine).

Sellelt kuvalt vali kuupäeva ja versiooni põhjal hetktõmmis, millesse alglaadida tahad. Omarchy versiooni hetktõmmise ajal näeb vasakus allnurgas.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kui sisse jõuad, ilmub teavitus, mis annab sulle teada, et oled alglaaditavas hetktõmmises, ja kui sellel klõpsad, algab taastamisprotsess. Teise võimalusena saad kasutada käsku `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

See taastab sinu juurfailisüsteemi, aga mitte `/home`. Nii et see töötab katkise süsteemivärskenduse tagasipööramiseks, aga mitte kaotatud isiklike failide taastamiseks.

See tähendab ka, et sinu `~/.config` kaust säilitatakse sellisena, nagu on. Nii et kui pöörad tagasi teegi või rakenduse varasemale versioonile, mis salvestab seadistusfailid uues vormingus, pead selle käsitsi korda ajama.

_Märkus: see funktsioon on saadaval ainult paigaldustes, mis kasutavad Limine alglaadurit, mis on vaikimisi alates Omarchy 2.0-st. See pole saadaval, kui oled GRUB-il või systemd-bootil._

### Alglaadimismenüü vahelejätmine

Kui sa alglaadimismenüüd kunagi ei puuduta ja tahad lihtsalt, et masin läheks otse dekrüptimise kuvale, käivita Omarchy menüüs _Seaded > Otsealglaadimine_. See lisab EFI kirje, mis osutab otse Omarchyle, nii et püsivara alglaadib selle Limines peatumata.

Kompromiss on see, mida ülal mainiti: kui otsealglaadimine on sees, tähendab hetktõmmiseni jõudmine esmalt Limine valimist BIOS-i alglaadimismenüüst. Käivita _Seaded > Otsealglaadimine_ uuesti, et kirje eemaldada ja minna tagasi Limine kaudu alglaadimisele. Mõni püsivara ei suhtu kohandatud EFI kirjetesse hästi, nii et seadistus keeldub töötamast American Megatrendsi ja Apple'i püsivaral.
