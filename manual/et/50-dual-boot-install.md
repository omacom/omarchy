# Kahekordse käivitusega paigaldamine

Sa saad paigaldada Omarchy ühele partitsioonile Windowsi või muude paigalduste kõrvale.

Selle paigaldusmeetodiga kaasneb partitsioonile vaikimisi endiselt LUKS-krüptimine, nii et see ei erine tegelikult täisketta paigaldusest ja nõuab lihtsalt kettal vaba ruumi olemasolu.

## Ruumi tegemine Windowsis

Windowsi kõrvale paigaldamiseks kirjuta menüüs Start `disk management` ja vali suvand **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Leia sobiv partitsioon, tee sellel paremklõps ja vali **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Sisesta maht, mille võrra soovid köidet kahandada. Pane tähele, et see saab olema sinu tulevase Omarchy paigalduse suurus koos alglaadimispartitsiooniga.

 ![dual-boot-3](images/dual-boot-3.webp)

Kui oled valmis, peaksid nägema midagi sellist, kus 50GB suurune osa on see, kuhu me selles näites Omarchy paigaldame.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy paigaldamine

Omarchy paigaldusprotsess on tegelikult sama mis tavaliselt. Pärast ketta valimist antakse sulle suvand **Free space install**. Vali see suvand, et vältida kogu ketta tühjendamist.

 ![dual-boot-5](images/dual-boot-5.webp)

Veendu, et kõik näeb hea välja, ja oota nagu tavaliselt, kuni paigaldamine lõpeb. Siin saad samuti valida krüptimata paigaldamise (ei ole soovitatav), nagu täisketta paigalduse puhulgi.
 ![dual-boot-6](images/dual-boot-6.webp)

## Muude paigalduste lisamine alglaadurisse

Kui oled Omarchy paigaldamise lõpetanud, märkad, et nüüd on vaikimisi alglaaduriks Limine. Sellega saad Limine'ile lisada ka suvandeid oma muude paigalduste, näiteks Windowsi jaoks.

Muude operatsioonisüsteemide lisamiseks käivita `limine-scan` ja järgi juhiseid, et lisada soovitud kirjed oma Limine'i konfiguratsiooni. Alglaadimismenüü jääb vaikimisi peidetuks ja käivitab Omarchy ühe sekundi pärast. Windowsi või mõne muu kirje valimiseks vajuta Limine'i käivitumisel kohe suvalist klahvi; kui menüü ilmub, kasuta kirje valimiseks nooleklahve ja vajuta Enter. Kui Omarchy käivitub enne, kui jõuad klahvi vajutada, taaskäivita arvuti ja proovi uuesti.

## Bitlocker

Oluline on märkida, et see paigaldusmeetod ei ühildu Bitlockeriga, kuna see krüptib kogu ketta, mitte ainult partitsiooni. Kui näed veateadet, et Bitlocker on lubatud, käivita Windows, mine **Settings -> Privacy & Security -> Device encryption** ja lülita Bitlocker välja. Ketta dekrüptimine võib võtta aega.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windowsi uuesti paigaldamine

Kui see arvuti tarniti koos Windowsiga, on selle tootevõti salvestatud püsivarasse. Käivita selle väljatrükkimiseks `omarchy windows key`, et saaksid Windowsi uuesti aktiveerida, kui selle kunagi sellesse arvutisse uuesti paigaldad.
