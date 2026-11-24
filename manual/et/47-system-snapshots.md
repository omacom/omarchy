# Süsteemi hetktõmmised

Loome iga Omarchy värskenduse korral automaatselt hetktõmmised, aga kui soovid ise oma luua, saad kasutada käsku `omarchy-snapshot create`.

Hetktõmmise käivitamiseks ja taastamiseks vali see Limine alglaadurist. Alglaadimismenüü jääb vaikimisi peidetuks, nii et selle kuvamiseks vajuta Limine käivitumise hetkel suvalist klahvi.

Sellel ekraanil vali kuupäeva ja versiooni põhjal hetktõmmis, millesse soovid käivituda. Hetktõmmise tegemise ajal kehtinud Omarchy versiooni näed vasakus allnurgas.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kui oled sisse jõudnud, ilmub teade, mis annab sulle teada, et oled käivitatavas hetktõmmises, ja sellel klõpsates käivitub taastamisprotsess. Teise võimalusena saad kasutada käsku `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

See taastab sinu juurfailisüsteemi, kuid mitte sinu `/home`. Nii et see sobib katkise süsteemivärskenduse tagasipööramiseks, kuid mitte kadunud isiklike failide taastamiseks.

See tähendab ka seda, et sinu `~/.config` kataloog säilib muutmata kujul. Nii et kui pöördud tagasi teegi või rakenduse varasema versiooni juurde, mis salvestab konfiguratsioonifaile uues vormingus, pead selle käsitsi korda ajama.

Sama kehtib Omarchy enda arvestuse kohta selle üle, millised migratsioonid on juba käivitatud: see asub sinu kodukataloogis, nii et see jääb taastamise järel alles. Migratsioonid, mis käivitati pärast hetktõmmise tegemist, jäävad tehtuks märgituks, kuigi nende juurfailisüsteemis tehtud muudatused on tagasi pööratud, ja järgmine `omarchy update` ei käivita neid uuesti. Nii et kui värskendad pärast taastamist uuesti ja midagi, mille varasem värskendus oli seadistanud, on endiselt puudu, on see tõenäoline põhjus.

_Märkus: See funktsioon on saadaval ainult installatsioonides, mis kasutavad Limine alglaadurit, mis on alates Omarchy 2.0-st vaikeseade. See ei ole saadaval, kui kasutad GRUB-i või systemd-boot-i._
