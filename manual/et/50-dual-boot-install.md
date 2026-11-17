# Kahekordse alglaadimisega paigaldus

Saad Omarchy paigaldada ühele partitsioonile Windowsi või muude paigalduste kõrvale.

See paigaldusmeetod sisaldab partitsiooni jaoks endiselt vaikimisi LUKS-krüptimist, nii et see ei erine tegelikult kogu ketta paigaldusest ja nõuab lihtsalt kettal vaba ruumi olemasolu.

## Ruumi tegemine Windowsis

Windowsi kõrvale paigaldamiseks sisesta käivitusmenüüsse `disk management` ja vali suvand **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Leia sobiv partitsioon, tee sellel paremklõps ja vali **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Sisesta maht, mille võrra soovid köidet kahandada. Pane tähele, et sellest saab sinu tulevase Omarchy paigalduse suurus koos alglaadimispartitsiooniga.

 ![dual-boot-3](images/dual-boot-3.webp)

Kui oled lõpetanud, peaksid nägema midagi sellist, kus 50GB suurune osa on koht, kuhu me selles näites Omarchy paigaldame.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy paigaldamine

Omarchy paigaldusprotsess on tegelikult sama mis tavaliselt. Pärast ketta valimist pakutakse sulle suvandit **Free space install**. Vali see suvand, et vältida kogu ketta tühjendamist.

 ![dual-boot-5](images/dual-boot-5.webp)

Kinnita, et kõik näeb hea välja, ja oota, kuni paigaldus lõpeb nagu tavaliselt. Siin saad samuti valida krüptimata paigalduse (ei ole soovitatav), täpselt nagu kogu ketta paigalduse korral.
 ![dual-boot-6](images/dual-boot-6.webp)

## Muude paigalduste lisamine alglaadurisse

Kui Omarchy paigalduse lõpetad, märkad, et Limine alglaadur on nüüd vaikevalik. Sellega saad Limine'isse lisada ka suvandeid oma muude paigalduste, näiteks Windowsi jaoks.

Muude operatsioonisüsteemide lisamiseks käivita `limine-scan` ja järgi juhiseid, et lisada soovitud kirjed oma Limine konfiguratsiooni. Alglaadimismenüü jääb vaikimisi peidetuks ja käivitab Omarchy ühe sekundi pärast. Windowsi või muu kirje valimiseks vajuta kohe Limine käivitumisel suvalist klahvi; kui menüü ilmub, kasuta kirje valimiseks nooleklahve ja vajuta Enter. Kui Omarchy käivitub enne, kui jõuad klahvi vajutada, taaskäivita seade ja proovi uuesti. Kui lülitasid sisse _Setup > Direct Boot_, jätab püsivara Limine täielikult vahele, nii et vali Limine oma BIOS-i alglaadimismenüüst või käivita kirje eemaldamiseks uuesti _Setup > Direct Boot_.

## Bitlocker

Oluline on märkida, et see paigaldusmeetod ei ühildu Bitlockeriga, kuna see krüptib kogu ketta, mitte ainult partitsiooni. Kui näed viga, mis ütleb, et Bitlocker on lubatud, käivita Windows, mine jaotisse **Settings -> Privacy & Security -> Device encryption** ja lülita Bitlocker välja. Ketta dekrüptimine võib võtta veidi aega.

 ![dual-boot-7](images/dual-boot-7.webp)
