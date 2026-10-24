# Pag-install ng Dual Boot

Maaari mong i-install ang Omarchy sa isang partisyon kasama ang Windows o iba pang mga pag-install.

Ang pamamaraang ito ng pag-install ay may kasamang encryption na LUKS para sa partisyon bilang default kaya epektibong walang pinagkaiba ito sa buong drive at nangangailangan lang ng libreng espasyo na available sa disk.

## Paggawa ng Espasyo sa Windows

Para mag-install kasama ang Windows, i-type ang `disk management` sa start menu at piliin ang opsyon para sa **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hanapin ang angkop na partisyon, i-right click, at piliin ang **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ilagay ang dami na gusto mong paliitin ang volume. Tandaan na ito ang magiging sukat ng hinaharap mong pag-install ng Omarchy kasama ang boot partition.

 ![dual-boot-3](images/dual-boot-3.webp)

Kapag tapos ka na, dapat mong makita ang isang bagay tulad nito kung saan ang seksyong 50GB ang pag-i-installan natin ng Omarchy sa halimbawang ito.

 ![dual-boot-4](images/dual-boot-4.webp)

## Pag-install ng Omarchy

Ang proseso ng pag-install para sa Omarchy ay epektibong pareho lang sa normal. Pagkatapos mong piliin ang disk mo, bibigyan ka ng opsyon na **Free space install**. Piliin ang opsyong iyon para maiwasang burahin ang buong disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Kumpirmahin na mukhang maayos ang lahat at hintaying matapos ang pag-install tulad ng normal. Dito mo rin maaaring piliing mag-install nang hindi naka-encrypt (hindi inirerekomenda) tulad ng sa isang pag-install sa buong drive.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pagdaragdag ng Ibang Pag-install sa Bootloader

Kapag natapos mo na ang pag-install ng Omarchy mo, mapapansin mong ang bootloader na Limine ang default na ngayon. Gamit ito, maaari ka ring magdagdag ng mga opsyon sa Limine para sa iba mong pag-install tulad ng Windows.

Para gawin iyon, patakbuhin ang `limine-scan` at sundin ang mga prompt para idagdag ang alinmang item na gusto mo sa limine config mo. Pagkatapos kapag nag-boot ka, makikita mo ang mga normal mong opsyon para sa Omarchy, pati na rin ang Windows Boot Manager o iba pa.

## Bitlocker

Mahalagang tandaan na ang pamamaraang ito ng pag-install ay hindi tugma sa Bitlocker dahil ine-encrypt nito ang buong drive, hindi lang ang partisyon. Kung makatagpo ka ng error na nagsasabing pinagana ang Bitlocker, mag-boot sa Windows, pumunta sa **Settings -> Privacy & Security -> Device encryption** at i-toggle off ang Bitlocker. Maaaring magtagal ang pag-decrypt sa drive.

 ![dual-boot-7](images/dual-boot-7.webp)
