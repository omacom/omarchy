# Suporta sa Mac

## Omarchy para sa Apple Silicon

Ang Omarchy para sa Apple Silicon ay isang opisyal na solusyon ng Omacom, unang inilabas kasama ng Omarchy 4.5. Nag-i-install ito katabi ng macOS, at pipili ka sa dalawa kapag nagsimula ang Mac mo.

May natanggap kang abiso tungkol sa Omarchy Mac? Pumunta sa [Galing sa Omarchy Mac](#coming-from-omarchy-mac).

Gumagana ito sa mga Mac na ito:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Hindi pa sinusuportahan ang M4 at mas bagong mga Mac. Sinusubukan ang suporta para sa M4 sa edge channel at susunod na ito. Sinusuri ng installer ang Mac mo bago may baguhin ito sa anuman.

Sa anumang Apple Silicon Mac, kabilang ang M4 at mas bago, maaari mong patakbuhin ang Omarchy sa isang virtual machine gamit ang [Try Omarchy](https://github.com/omacom/try-omarchy).

### Ano ang kailangan mo

- macOS 15 Sequoia o mas bago, at isang administrator account
- Libreng espasyo sa disk para sa Omarchy. Magmumungkahi ang installer ng laki at hahayaan kang baguhin ito.
- Isang backup ng Mac mo, kuryente, at koneksyon sa internet. Nagda-download ang pag-install ng ilang gigabyte.

### Pag-install

Mag-i-install ka mula sa macOS. I-install ang Omarchy Installer gamit ang [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

O i-download ang pinakabagong Omarchy Installer mula sa [pahina ng mga release](https://github.com/omacom/omarchy-mac-installer/releases) nito at buksan ito.

Sinusuri ng installer ang Mac mo, ipinapakita sa iyo ang plano, at gumagawa ng espasyo para sa Omarchy sa pamamagitan ng pagpapaliit sa partition ng macOS. Mananatili ang macOS sa disk at hindi kailangan ng USB drive. Kapag tapos na ang unang yugto, gagabayan ka nito sa pagtatapos ng setup sa macOS Recovery: i-shut down, pindutin nang matagal ang power button hanggang lumabas ang "Loading startup options", piliin ang Omarchy, at sundin ang mga hakbang.

Sa unang pag-boot, hihingi ang Omarchy ng password na nag-e-encrypt sa disk nito. Walang recovery key: kung makalimutan mo ang password, hindi na mababawi ang mga file mo sa Omarchy.

Para lumipat sa pagitan ng Omarchy at macOS sa ibang pagkakataon, i-shut down, pagkatapos ay pindutin nang matagal ang power button hanggang lumabas ang mga opsyon sa startup at pumili ng isa.

### Galing sa Omarchy Mac

Bahagi na ngayon ng Omarchy para sa Apple Silicon ang Omarchy Mac, at sinusuportahan ang bawat Mac na nagpatakbo nito. Patuloy na gumagana ang kasalukuyan mong install, at patuloy pa ring nag-a-update ang mga system package nito, ngunit hindi na ito makakatanggap ng mga update sa Omarchy. Walang deadline at walang in-place upgrade: magba-backup ka, aalisin mo ang lumang install, mag-i-install ka nang bago, at magre-restore ka. Nangyayari ang mga Hakbang 2 hanggang 5 sa macOS, kaya buksan ang pahinang ito sa telepono mo bago ka mag-restart.

1. **Mag-backup mula sa Omarchy, palayo sa Mac.** Buburahin ng pag-alis sa lumang install ito, at hindi mababasa ng macOS ang disk ng Omarchy. Kopyahin ang home folder mo sa isang external drive o ibang computer, kabilang ang mga SSH at GPG key, mga profile ng browser at hindi pa na-push na trabaho. I-save ang listahan ng package mo gamit ang `pacman -Qqe > ~/packages.txt`. I-back up din ang macOS, dahil parehong babaguhin ng pag-alis at pag-install ang laki ng disk nito.
2. **Simulan ang Mac mo sa macOS.** I-shut down, pindutin nang matagal ang power button hanggang lumabas ang mga opsyon sa startup, at piliin ang macOS.
3. **I-install ang Omarchy Installer** gaya ng ipinapakita sa [Pag-install](#installing).
4. **Alisin ang lumang install.** Buksan ang Omarchy Installer at piliin ang Installation > Remove Omarchy. Ipapakita nito kung ano ang buburahin nito at ibabalik ang espasyo sa macOS. Kung hindi nito makilala ang install mo, titigil ito nang hindi binabago ang disk. Humingi ng tulong sa [Discord](https://discord.gg/tXFUdasqhY) sa halip na manu-manong burahin ang mga partition, na maaaring magbura sa macOS.
5. **I-install ang Omarchy para sa Apple Silicon** gamit ang installer.
6. **I-restore ang mga file mo.** Ibalik ang mga setting mo nang paunti-unti sa halip na kopyahin ang lahat ng `~/.config` sa ibabaw ng mga bagong default, dahil maaaring i-override ng mga lumang setting ang mga ito.

### Mabuting malaman

- Sa mga M1 at M2 MacBook, gisingin mula sa sleep sa pamamagitan ng pagbukas ng takip o pagpindot sa power button.
- Mga tanong o problema: magtanong sa [Discord](https://discord.gg/tXFUdasqhY) namin.

Sinasaklaw ng [README ng installer](https://github.com/omacom/omarchy-mac-installer#readme) ang mga release channel, pag-update sa installer at pag-alis sa Omarchy.

## Mga Intel Mac

Sa isang simpleng pagsubok, nakamit namin ang 36% na pagtaas sa performance sa isang 2019 MacBook Pro sa pamamagitan lang ng pag-install ng Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Pag-install ng Omarchy sa Mac

Sinusuportahan lang ng Omarchy sa ngayon ang pagiging **tanging** OS na naka-install. Sa panahon ng pag-install, buburahin ang drive at hindi na mabu-boot ang MacOS.

Maaari mo pa rin itong i-restore sa ibang pagkakataon sa pamamagitan ng Internet Recovery kung gusto mo.

Para sa bahaging ito, ipagpapalagay naming nasuri mo na ang [Pagsisimula](02-getting-started.md) at handa na ang USB drive mo. Kung hindi pa, magpatuloy ka at gawin mo na iyon ngayon.

#### I-disable ang Secure Boot

Kinakailangang i-disable ang Secure Boot ng Apple upang ma-boot ang bootable USB, pati na rin ang OS. Para i-disable ito, gawin ang sumusunod:

1. I-off ang Mac mo
2. I-on ito at _agad_ na pindutin nang matagal ang Command-R hanggang makita mong lumabas ang loading screen
3. Piliin ang user mo at ilagay ang password mo kung hihilingin
4. Kapag nasa recovery screen na, piliin ang **Utilities > Startup Security Utility** mula sa menubar
5. Ilagay ang password mo kapag hihilinging mag-authenticate
6. Piliin ang "No Security" mula sa mga opsyon ng Secure Boot
7. Piliin ang "Allow booting from external or removable media" mula sa mga opsyon ng External Boot

#### Simulan ang Pag-install

1. Ipasok ang USB drive
2. I-restart ang Mac mo at _agad_ na pindutin nang matagal ang Option hanggang makakita ka ng screen ng mga boot device
3. Piliin ang kulay kahel na EFI Boot device
4. Magpatuloy sa [pag-install gaya ng normal](02-getting-started.md)

Awtomatikong nade-detect ng installer ang hardware ng Mac at inilalapat ang mga kailangang ayos: mga Broadcom Wi-Fi driver at firmware, ang SPI keyboard driver sa mga modelo ng MacBook na nangangailangan nito, at isang NVMe suspend fix para sa parehong mga modelong iyon.

### Mga Kilalang Limitasyon

Patuloy na nagtatrabaho ang mga miyembro ng komunidad sa mga solusyon sa mga hamong ito kaya kung problematiko ang mga ito para sa iyo, sumali sa #omarchy-on-other sa [Discord](https://discord.gg/tXFUdasqhY) namin at tingnan kung may mga napapanahong paraan para malutas ang mga ito.

#### Mga device na may T1 Chip

Ipinakilala ang Apple T1 chip noong huling bahagi ng 2016 at eksklusibong ginamit sa mga unang henerasyong modelo ng MacBook Pro na may Touch Bar.
- MacBook Pro 13-inch (2016, dalawang Thunderbolt 3 port) – Modelo: A1706
- MacBook Pro 13-inch (2016, apat na Thunderbolt 3 port) – Modelo: A1708
- MacBook Pro 15-inch (2016) – Modelo: A1707

#### Mga Kilalang Isyu

- Hindi gumagana ang Touch Bar
- Hindi gumagana ang tunog

#### Mga device na may T2 Chip

Ipinakilala ang Apple T2 Security Chip noong 2017. Itinigil ang T2 chip sa paglipat sa Apple silicon (mga M-series chip) simula noong 2020.

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

Sa mga modelong ito, awtomatikong sine-setup ng installer ang na-patch na `linux-t2` kernel, ang configuration ng audio ng T2, ang Broadcom Wi-Fi/Bluetooth firmware ng Apple, at ang kontrol ng fan sa pamamagitan ng `t2fanrd`. Gumagana ang Touch Bar sa built-in na Boot Camp-style na suporta ng kernel.

#### iMac Retina 5K (2017)

Walang T2 chip ang 2017 27-inch iMac, kaya sine-setup ito ng installer gaya ng ibang mga Intel Mac.

- iMac (Retina 5K, 27-inch, 2017) – Modelo: A1419

#### Mga Kilalang Isyu

- Hindi gumagana ang display sa native nitong 5120×2880: dalawang tile ang panel, at isa lang ang pinaiilaw ng stock driver
- Hindi gumagana ang tunog
- Walang epekto ang kontrol sa brightness
- Nai-hang ng sleep ang makina; power cycle lang ang makakabawi nito

Inaayos ng isang community patcher para sa modelong ito ang display, tunog at brightness: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
