# Süsteemi hetktõmmised

Loome iga Omarchy uuenduse korral automaatselt hetktõmmised, aga kui tahad ise ühe luua, saad kasutada käsku `omarchy-snapshot create`.

Hetktõmmise käivitamiseks ja taastamiseks vali see Limine'i alglaadurist. (Kui käivitad praegu otse Omarchy dekrüpteerimisekraanile, pead esmalt valima BIOS-i kaudu alglaadimisvalikuks Limine'i).

Vali sellelt ekraanilt kuupäeva ja versiooni põhjal hetktõmmis, millega soovid käivitada. Hetktõmmise tegemise ajal kasutusel olnud Omarchy versiooni näed vasakus allnurgas.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kui oled sisse jõudnud, ilmub teade, mis annab teada, et oled käivitatavas hetktõmmises, ja kui sellel klõpsad, algab taastamisprotsess. Teise võimalusena saad kasutada käsku `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

See taastab sinu juurfailisüsteemi, aga mitte sinu `/home` kataloogi. Nii sobib see rikkis süsteemiuuenduse tagasipööramiseks, aga mitte kaotatud isiklike failide taastamiseks.

See tähendab ka seda, et sinu `~/.config` kataloog jääb selliseks, nagu see on. Nii et kui pöördud tagasi teegi või rakenduse varasema versiooni juurde, mis salvestab seadistusfaile uues vormingus, pead selle käsitsi korda ajama.

Sama kehtib Omarchy enda arvestuse kohta selle üle, millised migratsioonid on juba käivitatud: see asub sinu kodukataloogis, nii et see jääb taastamise järel alles. Pärast hetktõmmise tegemist käivitatud migratsioonid jäävad tehtuks märgituks, kuigi nende juurfailisüsteemis tehtud muudatused on tagasi pööratud, ja järgmine `omarchy update` ei käivita neid uuesti. Nii et kui uuendad pärast taastamist uuesti ja midagi, mille varasem uuendus oli seadistanud, on endiselt puudu, on see tõenäoline põhjus.

_Märkus: See funktsioon on saadaval ainult paigaldustes, mis kasutavad Limine'i alglaadurit, mis on olnud vaikevalik alates Omarchy 2.0-st. See ei ole saadaval, kui kasutad GRUB-i või systemd-booti._

### Alglaadimismenüü vahelejätmine

Kui sa ei puuduta kunagi alglaadimismenüüd ja tahad lihtsalt, et masin läheks otse dekrüpteerimisekraanile, käivita Omarchy menüüs _Setup > Direct Boot_. See lisab EFI kirje, mis osutab otse Omarchy'le, nii et püsivara käivitab selle Limine'i juures peatumata.

Kompromiss on sama, mida mainiti alguses: kui otsene käivitamine on sees, tähendab hetktõmmiseni jõudmine seda, et pead esmalt valima BIOS-i alglaadimismenüüst Limine'i. Kirje eemaldamiseks ja Limine'i kaudu käivitamise juurde naasmiseks käivita _Setup > Direct Boot_ uuesti. Mõni püsivara ei suhtu kohandatud EFI kirjetesse hästi, nii et seadistus keeldub töötamast American Megatrendsi ja Apple'i püsivaral.
