# Suporta para sa Mac

Ang Omarchy ay may built-in na suporta para sa mga **Intel Mac**. May ilang kilalang limitasyon sa ngayon, pero basta't alam mo ang mga ito at ayos lang sa iyo; maaari kang magbigay ng bagong buhay sa iyong mga lumang Mac sa pamamagitan ng pag-load ng Omarchy.

Pakitandaan na ang pag-install sa isang Mac na M-series ay hindi direktang sinusuportahan sa kasalukuyan. Makakahanap ka ng higit pang impormasyon tungkol sa estado nito sa #omarchy-on-other sa aming [Discord](https://discord.gg/tXFUdasqhY).

Sa isang simpleng pagsubok, nakamit namin ang 36% na pagtaas ng performance sa isang 2019 MacBook Pro sa pamamagitan lamang ng pag-install ng Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Pag-install ng Omarchy sa Mac

Sinusuportahan lang ng Omarchy ang pagiging **tanging** OS na naka-install sa ngayon. Sa panahon ng pag-install, buburahin ang drive at hindi na maaaring i-boot ang MacOS.

Maaari mo pa rin itong ibalik sa ibang pagkakataon sa pamamagitan ng Internet Recovery kung gusto mo.

Para sa kapakanan ng bahaging ito, ipagpapalagay namin na nirepaso mo na ang [Pagsisimula](02-getting-started.md) at handa na ang iyong USB drive. Kung hindi mo pa nagagawa, gawin mo iyon ngayon.

#### I-disable ang Secure Boot

Kailangang i-disable ang Secure Boot ng Apple upang ma-boot ang bootable USB, pati na rin ang OS. Para i-disable ito, gawin ang mga sumusunod:

1. Patayin ang Mac mo
2. Buksan ito at _agad_ na pindutin at hawakan ang Command-R hanggang sa makita mong lumabas ang loading screen
3. Piliin ang user mo at ilagay ang password mo kung i-prompt
4. Kapag nasa recovery screen na, piliin ang **Utilities > Startup Security Utility** mula sa menubar
5. Ilagay ang password mo kapag na-prompt na mag-authenticate
6. Piliin ang "No Security" mula sa mga opsyon ng Secure Boot
7. Piliin ang "Allow booting from external or removable media" mula sa mga opsyon ng External Boot

#### Simulan ang Pag-install

1. Ipasok ang USB drive
2. I-restart ang Mac mo at _agad_ na pindutin at hawakan ang Option hanggang sa makita mo ang isang screen ng mga boot device
3. Piliin ang kahel na device na EFI Boot
4. Magpatuloy sa [pag-install tulad ng normal](02-getting-started.md)

Natutukoy ng installer ang hardware ng Mac at awtomatikong inilalapat ang mga kinakailangang pag-aayos: ang mga driver ng Broadcom Wi-Fi at firmware, ang driver ng SPI keyboard sa mga modelo ng MacBook na nangangailangan nito, at isang pag-aayos para sa NVMe suspend para sa parehong mga modelong iyon.

### Mga Kilalang Limitasyon

Ang mga kasapi ng komunidad ay patuloy na nagtatrabaho sa mga solusyon sa mga hamong ito kaya kung problema sa iyo ang mga ito, sumali sa #omarchy-on-other sa aming [Discord](https://discord.gg/tXFUdasqhY) at tingnan kung may anumang napapanahong paraan para malutas ang mga ito.

#### Mga Device na may T1 Chip

Ang Apple T1 chip ay ipinakilala noong huling bahagi ng 2016 at ginamit nang eksklusibo sa mga unang henerasyong modelo ng MacBook Pro na may Touch Bar.
- MacBook Pro 13-inch (2016, dalawang Thunderbolt 3 port) – Modelo: A1706
- MacBook Pro 13-inch (2016, apat na Thunderbolt 3 port) – Modelo: A1708
- MacBook Pro 15-inch (2016) – Modelo: A1707

#### Mga Kilalang Isyu

- Hindi gumagana ang Touch Bar
- Hindi gumagana ang tunog

#### Mga Device na may T2 Chip

Ang Apple T2 Security Chip ay ipinakilala noong 2017. Ang T2 chip ay itinigil sa paglipat sa Apple silicon (mga chip na M-series) simula noong 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro 13-inch (2018, apat na Thunderbolt 3 port) – Modelo: A1989
- MacBook Pro 15-inch (2018) – Modelo: A1990
- MacBook Air (Retina, 13-inch, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro 13-inch (2019, dalawang Thunderbolt 3 port) – Modelo: A2159
- MacBook Pro 13-inch (2019, apat na Thunderbolt 3 port) – Modelo: A2178
- MacBook Pro 15-inch (2019) – Modelo: A1990
- iMac (Retina 5K, 27-inch, 2020) – Modelo: A2115 (iMac20,1 at iMac20,2)
- MacBook Pro 13-inch (2020, dalawang Thunderbolt 3 port) – Modelo: A2265
- MacBook Pro 15-inch (2020) – Modelo: A1990

Sa mga modelong ito, awtomatikong sine-setup ng installer ang naka-patch na kernel na `linux-t2`, ang konpigurasyon ng audio ng T2, ang firmware ng Broadcom Wi-Fi/Bluetooth ng Apple, at ang kontrol ng fan sa pamamagitan ng `t2fanrd`. Ang Touch Bar ay tumatakbo sa built-in na suporta na estilo ng Boot Camp ng kernel.
