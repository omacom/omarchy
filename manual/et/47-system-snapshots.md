# Süsteemi hetktõmmised

Loome hetktõmmised automaatselt iga Omarchy uuendusega, aga kui soovid luua oma, saad kasutada käsku `omarchy-snapshot create`.

Kuidas sa hetktõmmise käivitad ja taastad, sõltub alglaadurist, millega sinu masin käivitub. Uued UEFI installid kasutavad systemd-boot; vanemad installid ja BIOS masinad kasutavad Limine'i. `omarchy-boot-backend` ütleb sulle, kumb sul on.

## systemd-boot korral

Vali Omarchy menüüs _System > Snapshots_ ja vali hetktõmmis, millelt soovid käivituda. Masin taaskäivitub sellelt ühe korra. Või hoia masina käivitumise ajal Space all, et näha alglaadimismenüüd, kus iga hetktõmmis on loetletud uusimast vanimani koos selle Omarchy versiooni ja kuupäevaga.

Hetktõmmis käivitub peal oleva ajutise kihiga, nii et saad seda tavapäraselt kasutada, aga kõik, mida muudad, on järgmisel taaskäivitusel kadunud. Et see alles hoida, tee see oma süsteemiks: klõpsa teavitust, mis ilmub sisselogimisel, vali _System > Snapshots > Restore This Snapshot_ või käivita `omarchy-snapshot restore`. Taastamine toimub masina taaskäivitumise ajal. Süsteem sellisena, nagu see enne oli, jääb alglaadimismenüüsse nimega _Before restore_ ja `omarchy-snapshot restore backup` paneb selle tagasi.

Terminalist:

- `omarchy-snapshot list` loetleb hetktõmmised, millelt saad käivituda;
- `omarchy-snapshot boot 12` taaskäivitub üks kord hetktõmmisesse 12;
- `omarchy-snapshot restore 12` teeb hetktõmmisest 12 järgmisel taaskäivitusel süsteemi ja `omarchy-snapshot restore --cancel` muudab enne seda taaskäivitust sinu meelt.

## Limine korral

Hetktõmmise käivitamiseks ja taastamiseks valid selle Limine alglaadurist. Alglaadimismenüü jääb vaikimisi peidetuks, nii et vajuta kohe Limine käivitumisel suvalist klahvi, et see esile tuua.

Sellelt ekraanilt vali kuupäeva ja versiooni põhjal hetktõmmis, millelt soovid käivituda. Omarchy versiooni hetktõmmise tegemise ajal näeb vasakus alanurgas.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kui oled sisse jõudnud, ilmub teavitus, mis annab sulle teada, et oled käivitatavas hetktõmmises, ja kui sellel klõpsad, alustab see taastamisprotsessi. Teise võimalusena saad kasutada käsku `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Mida taastamine hõlmab

Taastamine toob tagasi sinu juurfailisüsteemi, aga mitte sinu `/home`. Nii et see töötab katki läinud süsteemiuuenduse tagasipööramiseks, aga mitte kaotatud isiklike failide taastamiseks.

See tähendab ka seda, et sinu `~/.config` kataloog jääb selliseks, nagu see on. Nii et kui pöördud tagasi teegi või rakenduse varasema versiooni juurde, mis salvestab konfiguratsioonifaile uues vormingus, pead sellega käsitsi tegelema.

Sama kehtib Omarchy enda arvestuse kohta selle üle, millised migratsioonid on juba käivitatud: see elab sinu kodukataloogis, nii et see jääb taastamisest puutumata. Migratsioonid, mis käivitati pärast hetktõmmise tegemist, jäävad tehtuks märgituks, kuigi nende juurfailisüsteemis tehtud muudatused on tagasi pööratud, ja järgmine `omarchy update` ei käivita neid uuesti. Nii et kui uuendad pärast taastamist uuesti ja midagi, mille varasem uuendus oli seadistanud, on endiselt puudu, on see tõenäoline põhjus.
