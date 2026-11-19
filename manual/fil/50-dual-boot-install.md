# Pag-install ng Dual Boot

Maaari mong i-install ang Omarchy sa isang partition kasama ng Windows o ng iba pang mga installation.

May kasama pa ring LUKS encryption ang paraang ito ng pag-install para sa partition bilang default kaya halos wala itong pinagkaiba sa full drive at kailangan lang ng bakanteng puwang na available sa disk.

## Paglalaan ng Puwang sa Windows

Para mag-install kasama ng Windows, i-type ang `disk management` sa start menu at piliin ang opsyon para sa **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hanapin ang angkop na partition, i-right click, at piliin ang **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ilagay ang halagang gusto mong ipaliit sa volume. Tandaan na ito ang magiging laki ng iyong magiging Omarchy install kasama na ang boot partition.

 ![dual-boot-3](images/dual-boot-3.webp)

Kapag tapos ka na, dapat ay makakita ka ng ganito kung saan ang 50GB na bahagi ang pag-iinstallan namin ng Omarchy sa halimbawang ito.

 ![dual-boot-4](images/dual-boot-4.webp)

## Pag-install ng Omarchy

Halos kapareho lang ng normal ang proseso ng pag-install ng Omarchy. Pagkatapos mong piliin ang iyong disk, bibigyan ka ng opsyong **Free space install**. Piliin ang opsyong iyon para hindi mabura ang buong disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Kumpirmahing mukhang ayos ang lahat at hintaying matapos ang pag-install gaya ng normal. Dito mo rin maaaring piliing mag-install nang walang encryption (hindi inirerekomenda) gaya ng sa full-drive install.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pagdaragdag ng Iba Pang mga Install sa Bootloader

Kapag natapos mo ang iyong Omarchy install, mapapansin mong ang Limine bootloader na ang default ngayon. Gamit ito, maaari ka ring magdagdag ng mga opsyon sa Limine para sa iba mo pang mga install tulad ng Windows.

Para magdagdag ng iba pang mga operating system, patakbuhin ang `limine-scan` at sundin ang mga prompt para idagdag ang mga entry na gusto mo sa iyong Limine config. Nananatiling nakatago ang boot menu bilang default at sinisimulan ang Omarchy pagkalipas ng isang segundo. Para pumili ng Windows o ng iba pang entry, pindutin ang anumang key sa sandaling magsimula ang Limine; kapag lumitaw ang menu, gamitin ang mga arrow key para pumili ng entry at pindutin ang Enter. Kung magsimula ang Omarchy bago ka makapindot ng key, i-restart at subukang muli.

## Bitlocker

Mahalagang tandaan na hindi tugma ang paraang ito ng pag-install sa Bitlocker dahil ine-encrypt nito ang buong drive, hindi lang ang partition. Kung makatagpo ka ng error na nagsasabing naka-enable ang Bitlocker, mag-boot sa Windows, pumunta sa **Settings -> Privacy & Security -> Device encryption** at i-toggle off ang Bitlocker. Maaaring magtagal ang pag-decrypt ng drive.

 ![dual-boot-7](images/dual-boot-7.webp)
