# Kaksiklaadimise paigaldus

Sa saad Omarchy paigaldada ühele partitsioonile Windowsi või teiste paigalduste kõrvale.

Selle paigaldusmeetodiga tuleb partitsioonile vaikimisi ikka LUKS krüpteerimine, nii et see ei erine tegelikult täiskettast ja nõuab lihtsalt vaba ruumi kettal.

## Ruumi tegemine Windowsis

Windowsi kõrvale paigaldamiseks kirjuta Start-menüüsse `disk management` ja vali valik **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Leia sobiv partitsioon, tee paremklõps ja vali **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Sisesta kogus, mille võrra tahad mahtu kahandada. Pane tähele, et see on sinu tulevase Omarchy paigalduse suurus koos alglaadimispartitsiooniga.

 ![dual-boot-3](images/dual-boot-3.webp)

Kui oled lõpetanud, peaksid nägema midagi sellist, kus 50GB osa on see, kuhu me selles näites Omarchy paigaldame.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy paigaldamine

Omarchy paigaldusprotsess on tegelikult sama nagu tavaliselt. Pärast ketta valimist antakse sulle valik **Free space install**. Vali see valik, et vältida kogu ketta pühkimist.

 ![dual-boot-5](images/dual-boot-5.webp)

Kinnita, et kõik näeb hea välja, ja oota, kuni paigaldus tavapäraselt lõpeb. Siin saad soovi korral valida ka krüpteerimata paigalduse (ei ole soovitatav), täpselt nagu täisketta paigaldusel.
 ![dual-boot-6](images/dual-boot-6.webp)

## Teiste paigalduste lisamine alglaadurisse

Kui oled Omarchy paigalduse lõpetanud, märkad, et Limine alglaadur on nüüd vaikimisi. Sellega saad Liminesse lisada ka valikuid oma teiste paigalduste jaoks, nagu Windows.

Selleks käivita `limine-scan` ja järgi päringuid, et lisada oma limine seadistusse soovitud üksused. Siis näed alglaadimisel oma tavalisi Omarchy valikuid, samuti Windows Boot Managerit või muid.

## Bitlocker

Oluline on märkida, et see paigaldusmeetod ei ühildu Bitlockeriga, sest see krüpteerib kogu ketta, mitte ainult partitsiooni. Kui näed viga, et Bitlocker on lubatud, alglaadi Windowsisse, mine jaotisse **Settings -> Privacy & Security -> Device encryption** ja lülita Bitlocker välja. Ketta dekrüpteerimine võib veidi aega võtta.

 ![dual-boot-7](images/dual-boot-7.webp)
