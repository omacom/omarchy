# Topeltkäivituse paigaldus

Omarchy saab paigaldada ühele partitsioonile Windowsi või teiste paigalduste kõrvale.

Selle paigaldusmeetodiga kaasneb partitsioonile vaikimisi ikkagi LUKS krüptimine, nii et sisuliselt ei erine see täisketta paigaldusest ja nõuab lihtsalt, et kettal oleks vaba ruumi.

## Ruumi tegemine Windowsis

Et paigaldada Windowsi kõrvale, kirjuta Start-menüüsse `disk management` ja vali suvand **Kõvaketta partitsioonide loomine ja vormindamine**.

 ![dual-boot-1](images/dual-boot-1.webp)

Leia sobiv partitsioon, tee sellel paremklõps ja vali **Kahanda köidet**.

![dual-boot-2](images/dual-boot-2.webp)

 Sisesta maht, mille võrra soovid köidet kahandada. Pane tähele, et sellest saab sinu tulevase Omarchy paigalduse suurus koos alglaadimispartitsiooniga.

 ![dual-boot-3](images/dual-boot-3.webp)

Kui oled valmis, peaksid nägema midagi sellist, kus 50GB suurune osa on selles näites koht, kuhu me Omarchy paigaldame.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy paigaldamine

Omarchy paigaldusprotsess on sisuliselt sama mis tavaliselt. Kui oled ketta valinud, pakutakse sulle suvandit **Paigaldus vabale ruumile**. Vali see suvand, et vältida kogu ketta tühjaks pühkimist.

 ![dual-boot-5](images/dual-boot-5.webp)

Veendu, et kõik näeb hea välja, ja oota nagu tavaliselt, kuni paigaldus lõpeb. Siin saad ka valida krüptimata paigalduse (ei ole soovitatav), täpselt nagu täisketta paigalduse puhul.
 ![dual-boot-6](images/dual-boot-6.webp)

## Teiste paigalduste lisamine alglaadurisse

Kui Omarchy paigalduse lõpetad, märkad, et nüüd on vaikimisi alglaaduriks Limine. Selle abil saad Limine'isse lisada ka suvandeid oma teiste paigalduste, näiteks Windowsi jaoks.

Teiste operatsioonisüsteemide lisamiseks käivita `limine-scan` ja järgi viipasid, et lisada soovitud kirjed oma Limine konfiguratsiooni. Alglaadimismenüü jääb vaikimisi peidetuks ja käivitab Omarchy ühe sekundi pärast. Windowsi või mõne muu kirje valimiseks vajuta Limine käivitumisel kohe suvalist klahvi; kui menüü ilmub, vali nooleklahvidega kirje ja vajuta Enter. Kui Omarchy käivitub enne, kui jõuad klahvi vajutada, tee taaskäivitus ja proovi uuesti.

## Bitlocker

Oluline on tähele panna, et see paigaldusmeetod ei ühildu Bitlockeriga, kuna see krüptib kogu ketta, mitte ainult partitsiooni. Kui näed veateadet, et Bitlocker on sisse lülitatud, käivita Windows, mine kohta **Sätted -> Privaatsus ja turve -> Seadme krüptimine** ja lülita Bitlocker välja. Ketta dekrüptimine võib võtta veidi aega.

 ![dual-boot-7](images/dual-boot-7.webp)
