# Pag-install ng Dual Boot

Maaari mong i-install ang Omarchy sa iisang partition kasabay ng Windows o iba pang mga installation.

Ang pamamaraang ito ng pag-install ay may LUKS encryption pa rin para sa partition bilang default kaya sa praktikal ay walang pinagkaiba ito sa full drive at nangangailangan lamang ng bakanteng espasyo na available sa disk.

## Paglikha ng Espasyo sa Windows

Para mag-install kasabay ng Windows, i-type ang `disk management` sa start menu at piliin ang opsyon para sa **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Hanapin ang naaangkop na partition, i-right click, at piliin ang **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ilagay ang halagang gusto mong ipaliit sa volume. Tandaan na ito ang magiging laki ng iyong magiging install ng Omarchy kasama ang boot partition.

 ![dual-boot-3](images/dual-boot-3.webp)

Kapag tapos ka na, dapat ay makakita ka ng ganito kung saan ang 50GB na seksyon ang pag-iinstallan natin ng Omarchy sa halimbawang ito.

 ![dual-boot-4](images/dual-boot-4.webp)

## Pag-install ng Omarchy

Ang proseso ng pag-install para sa Omarchy ay halos kapareho ng normal. Pagkatapos mong piliin ang iyong disk, bibigyan ka ng opsyon na **Free space install**. Piliin ang opsyong iyon para maiwasang mabura ang buong disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Kumpirmahin na maayos ang lahat at hintaying matapos ang install gaya ng normal. Dito mo rin maaaring piliing mag-install nang hindi naka-encrypt (hindi inirerekomenda) tulad ng sa isang full-drive install.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pagdaragdag ng Iba Pang Install sa Bootloader

Kapag natapos mo ang install ng Omarchy, mapapansin mong ang Limine bootloader na ang default ngayon. Gamit ito, maaari ka ring magdagdag ng mga opsyon sa Limine para sa iba mo pang install gaya ng Windows.

Para magdagdag ng iba pang operating system, patakbuhin ang `limine-scan` at sundin ang mga prompt para idagdag ang mga entry na gusto mo sa iyong Limine config. Nananatiling nakatago ang boot menu bilang default at sinisimulan ang Omarchy pagkatapos ng isang segundo. Para piliin ang Windows o iba pang entry, pindutin ang anumang key sa sandaling magsimula ang Limine; kapag lumitaw ang menu, gamitin ang mga arrow key para pumili ng entry at pindutin ang Enter. Kung magsimula ang Omarchy bago ka makapindot ng key, i-restart at subukan ulit. Kung binuksan mo ang _Setup > Direct Boot_, nilalaktawan ng firmware ang Limine nang tuluyan, kaya piliin ang Limine mula sa BIOS boot menu mo o patakbuhin ulit ang _Setup > Direct Boot_ para alisin ang entry.

## Bitlocker

Mahalagang tandaan na hindi compatible ang pamamaraang ito ng pag-install sa Bitlocker dahil ine-encrypt nito ang buong drive, hindi lang ang partition. Kung makakita ka ng error na nagsasabing naka-enable ang Bitlocker, mag-boot sa Windows, pumunta sa **Settings -> Privacy & Security -> Device encryption** at i-toggle off ang Bitlocker. Maaaring tumagal nang ilang panahon ang pag-decrypt sa drive.

 ![dual-boot-7](images/dual-boot-7.webp)
