# Suporta sa Mac

May built-in na suporta ang Omarchy para sa **Intel Macs**. May ilang kilalang limitasyon sa ngayon, pero hangga't alam mo ang mga ito at ayos lang sa iyo; mabibigyan mo ng bagong buhay ang mga luma mong Mac sa pamamagitan ng pag-load ng Omarchy.

Pakitandaan na hindi direktang sinusuportahan sa ngayon ang pag-install sa M-series Mac. Makakahanap ka ng karagdagang impormasyon tungkol sa estado nito sa #omarchy-on-other sa aming [Discord](https://discord.gg/tXFUdasqhY).

Sa isang simpleng pagsubok, nakamit namin ang 36% na pagtaas ng performance sa isang 2019 MacBook Pro sa pamamagitan lang ng pag-install ng Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Pag-install ng Omarchy sa Mac

Sinusuportahan lang ng Omarchy na ito ang **tanging** OS na naka-install sa ngayon. Sa panahon ng pag-install, buburahin ang drive at hindi na mabo-boot ang MacOS.

Maaari mo pa rin itong i-restore mamaya sa pamamagitan ng Internet Recovery kung gusto mo.

Para sa bahaging ito, ipagpapalagay naming nirepaso mo na ang [Pagsisimula](02-getting-started.md) at handa na ang iyong USB drive. Kung hindi pa, gawin mo na iyon ngayon.

#### I-disable ang Secure Boot

Kailangang i-disable ang Secure Boot ng Apple para ma-boot ang bootable USB, pati na rin ang OS. Para i-disable ito, gawin ang sumusunod:

1. I-off ang iyong Mac
2. I-on ito at _kaagad_ pindutin nang matagal ang Command-R hanggang makita mong lumabas ang loading screen
3. Piliin ang iyong user at ilagay ang iyong password kung hihingin
4. Kapag nasa recovery screen na, piliin ang **Utilities > Startup Security Utility** mula sa menubar
5. Ilagay ang iyong password kapag hiningi para mag-authenticate
6. Piliin ang "No Security" mula sa mga opsyon ng Secure Boot
7. Piliin ang "Allow booting from external or removable media" mula sa mga opsyon ng External Boot

#### Simulan ang Pag-install

1. Ipasok ang USB drive
2. I-restart ang iyong Mac at _kaagad_ pindutin nang matagal ang Option hanggang makita mo ang screen ng mga boot device
3. Piliin ang orange na EFI Boot device
4. Magpatuloy sa [pag-install gaya ng karaniwan](02-getting-started.md)

Nade-detect ng installer ang Mac hardware at awtomatikong ina-apply ang mga kailangang ayusin: Broadcom Wi-Fi drivers at firmware, ang SPI keyboard driver sa mga modelo ng MacBook na nangangailangan nito, at isang NVMe suspend fix para sa parehong mga modelong iyon.

### Mga Kilalang Limitasyon

Patuloy na gumagawa ang mga miyembro ng komunidad ng mga solusyon para sa mga hamong ito kaya kung problematiko ang mga ito para sa iyo, sumali sa #omarchy-on-other sa aming [Discord](https://discord.gg/tXFUdasqhY) at tingnan kung may mga napapanahong paraan para malutas ang mga ito.

#### Mga Device na may T1 Chip

Ipinakilala ang Apple T1 chip noong huling bahagi ng 2016 at eksklusibong ginamit sa mga first-generation na modelo ng MacBook Pro na may Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Mga Kilalang Isyu

- Hindi gumagana ang Touch Bar
- Hindi gumagana ang tunog

#### Mga Device na may T2 Chip

Ipinakilala ang Apple T2 Security Chip noong 2017. Itinigil ang T2 chip sa paglipat sa Apple silicon (M-series chips) simula noong 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Sa mga modelong ito, awtomatikong ise-set up ng installer ang patched na `linux-t2` kernel, ang T2 audio configuration, ang Broadcom Wi-Fi/Bluetooth firmware ng Apple, at fan control sa pamamagitan ng `t2fanrd`. Gumagana ang Touch Bar sa built-in na Boot Camp-style support ng kernel.

#### iMac Retina 5K (2017)

Walang T2 chip ang 2017 27-inch iMac, kaya ise-set up ito ng installer tulad ng ibang Intel Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Mga Kilalang Isyu

- Hindi tumatakbo ang display sa native nitong 5120×2880: dalawang tile ang panel, at isa lang ang pinapailaw ng stock driver
- Hindi gumagana ang tunog
- Walang epekto ang brightness control
- Nagha-hang ang makina kapag nag-sleep; power cycle lang ang makakapag-recover dito

Inaayos ng isang community patcher para sa modelong ito ang display, tunog at brightness: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
