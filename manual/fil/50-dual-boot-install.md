# Pag-install ng Dual Boot

Maaari mong i-install ang Omarchy sa iisang partition kasama ng Windows o ng iba pang mga installation.

Ang paraang ito ng pag-install ay may kasama pa ring LUKS encryption para sa partition bilang default kaya epektibong walang pinagkaiba sa full drive at nangangailangan lamang ng bakanteng espasyo na available sa disk.

## Paglaan ng Espasyo sa Windows

Upang mag-install kasama ng Windows, i-type ang `disk management` sa start menu at piliin ang opsyon para sa **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hanapin ang naaangkop na partition, mag-right click, at piliin ang **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ilagay ang halaga kung gaano mo gustong paliitin ang volume. Tandaan na ito ang magiging laki ng iyong magiging Omarchy install kasama ang boot partition.

 ![dual-boot-3](images/dual-boot-3.webp)

Kapag tapos ka na, dapat ay makakita ka ng katulad nito kung saan ang 50GB na seksyon ang pag-i-install-an natin ng Omarchy sa halimbawang ito.

 ![dual-boot-4](images/dual-boot-4.webp)

## Pag-install ng Omarchy

Ang proseso ng pag-install ng Omarchy ay epektibong kapareho ng normal. Pagkatapos mong piliin ang iyong disk, bibigyan ka ng opsyon na **Free space install**. Piliin ang opsyong iyon upang maiwasang mabura ang buong disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Kumpirmahin na maayos ang lahat at hintaying matapos ang pag-install gaya ng normal. Dito mo rin maaaring piliing mag-install nang walang encryption (hindi inirerekomenda) gaya ng sa full-drive install.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pagdaragdag ng Iba Pang Install sa Bootloader

Kapag natapos mo ang iyong Omarchy install, mapapansin mong ang Limine bootloader na ang default ngayon. Sa pamamagitan nito, maaari ka ring magdagdag ng mga opsyon sa Limine para sa iba mo pang install gaya ng Windows.

Upang magdagdag ng iba pang operating system, patakbuhin ang `limine-scan` at sundin ang mga prompt upang idagdag ang mga entry na gusto mo sa iyong Limine config. Nananatiling nakatago ang boot menu bilang default at sinisimulan ang Omarchy pagkatapos ng isang segundo. Upang piliin ang Windows o iba pang entry, pindutin ang anumang key sa sandaling magsimula ang Limine; kapag lumitaw ang menu, gamitin ang mga arrow key upang pumili ng entry at pindutin ang Enter. Kung magsimula ang Omarchy bago ka makapindot ng key, mag-restart at subukang muli.

## Bitlocker

Mahalagang tandaan na ang paraang ito ng pag-install ay hindi compatible sa Bitlocker dahil ine-encrypt nito ang buong drive, hindi lamang ang partition. Kung makatagpo ka ng error na nagsasabing naka-enable ang Bitlocker, mag-boot sa Windows, pumunta sa **Settings -> Privacy & Security -> Device encryption** at i-toggle off ang Bitlocker. Maaaring tumagal nang ilang panahon ang pag-decrypt ng drive.

 ![dual-boot-7](images/dual-boot-7.webp)

## Muling Pag-install ng Windows

Kung ang computer na ito ay dumating na may Windows, ang product key nito ay nakaimbak sa firmware. Patakbuhin ang `omarchy windows key` upang i-print ito, upang maaari mong i-activate muli ang Windows kung sakaling i-reinstall mo ito sa machine na ito.
