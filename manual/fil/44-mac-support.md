# Suporta sa Mac

## Omarchy para sa Apple Silicon

Ang Omarchy para sa Apple Silicon ay isang opisyal na solusyon ng Omacom, unang inilabas kasama ng Omarchy 4.5. Ini-install ito katabi ng macOS, at pipili ka sa dalawa kapag nagsimula ang iyong Mac.

May natanggap kang abiso tungkol sa Omarchy Mac? Pumunta sa [Galing sa Omarchy Mac](#coming-from-omarchy-mac).

Gumagana ito sa mga Mac na ito:

| Mac | Mga Chip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Hindi pa sinusuportahan ang mga Mac na M4 at mas bago. Kasalukuyang sinusubok ang suporta para sa M4 sa edge channel at susunod na ito. Sinusuri ng installer ang iyong Mac bago ito may baguhin sa anuman.

Sa anumang Apple Silicon Mac, kasama ang M4 at mas bago, maaari mong patakbuhin ang Omarchy sa isang virtual machine gamit ang [Try Omarchy](https://github.com/omacom/try-omarchy).

### Ano ang kailangan mo

- macOS 15 Sequoia o mas bago, at isang administrator account
- Libreng espasyo sa disk para sa Omarchy. Magmumungkahi ang installer ng sukat at hahayaan kang baguhin ito.
- Isang backup ng iyong Mac, kuryente, at koneksyon sa internet. Nagda-download ang pag-install ng ilang gigabytes.

### Pag-install

Mag-i-install ka mula sa macOS. I-install ang Omarchy Installer gamit ang [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

O i-download ang pinakabagong Omarchy Installer mula sa [pahina ng mga release](https://github.com/omacom/omarchy-mac-installer/releases) nito at buksan ito.

Sinusuri ng installer ang iyong Mac, ipinapakita sa iyo ang plano, at gumagawa ng espasyo para sa Omarchy sa pamamagitan ng pagpapaliit sa partition ng macOS. Mananatili ang macOS sa disk at hindi kailangan ng USB drive. Kapag tapos na ang unang yugto, gagabayan ka nito sa pagtatapos ng setup sa macOS Recovery: i-shut down, pindutin nang matagal ang power button hanggang lumabas ang "Loading startup options", piliin ang Omarchy, at sundin ang mga hakbang.

Sa unang pag-boot, hihingi ang Omarchy ng password na nag-e-encrypt sa disk nito. Walang recovery key: kung makalimutan mo ang password, hindi na mababawi ang iyong mga file sa Omarchy.

Para lumipat sa pagitan ng Omarchy at macOS sa ibang pagkakataon, i-shut down, pagkatapos ay pindutin nang matagal ang power button hanggang lumabas ang mga opsyon sa startup at pumili ng isa.

### Galing sa Omarchy Mac

Bahagi na ngayon ang Omarchy Mac ng Omarchy para sa Apple Silicon, at sinusuportahan ang bawat Mac na nagpatakbo nito. Patuloy na gumagana ang kasalukuyan mong install, at patuloy pa ring nag-a-update ang mga system package nito, ngunit hindi na ito makakatanggap ng mga update ng Omarchy. Walang deadline at walang in-place upgrade: magba-backup ka, aalisin ang lumang install, mag-i-install nang bago, at magre-restore. Nangyayari ang mga Hakbang 2 hanggang 5 sa macOS, kaya buksan ang pahinang ito sa iyong telepono bago ka mag-restart.

1. **Mag-backup mula sa Omarchy, nang wala sa Mac.** Buburahin ng pag-alis sa lumang install ito, at hindi mababasa ng macOS ang disk ng Omarchy. Kopyahin ang iyong home folder sa isang external drive o ibang computer, kasama ang mga SSH at GPG key, mga profile ng browser at trabahong hindi pa naitutulak. I-save ang iyong listahan ng mga package gamit ang `pacman -Qqe > ~/packages.txt`. I-backup mo rin ang macOS, dahil parehong binabago ng pag-alis at pag-install ang sukat ng disk nito.
2. **Simulan ang iyong Mac sa macOS.** I-shut down, pindutin nang matagal ang power button hanggang lumabas ang mga opsyon sa startup, at piliin ang macOS.
3. **I-install ang Omarchy Installer** gaya ng ipinapakita sa [Pag-install](#installing).
4. **Alisin ang lumang install.** Buksan ang Omarchy Installer at piliin ang Installation > Remove Omarchy. Ipapakita nito kung ano ang buburahin nito at ibabalik ang espasyo sa macOS. Kung hindi nito makilala ang iyong install, hihinto ito nang hindi binabago ang disk. Humingi ng tulong sa [Discord](https://discord.gg/tXFUdasqhY) sa halip na burahin ang mga partition gamit ang kamay, na maaaring makabura sa macOS.
5. **I-install ang Omarchy para sa Apple Silicon** gamit ang installer.
6. **I-restore ang iyong mga file.** Ibalik ang iyong mga setting nang paunti-unti sa halip na kopyahin ang lahat ng `~/.config` sa ibabaw ng mga bagong default, dahil maaaring i-override ng mga lumang setting ang mga ito.

### Mabuting malaman

- Sa mga MacBook na M1 at M2, gisingin mula sa pagkakatulog sa pamamagitan ng pagbukas ng takip o pagpindot sa power button.
- Mga tanong o problema: magtanong sa aming [Discord](https://discord.gg/tXFUdasqhY).

Sinasaklaw ng [README ng installer](https://github.com/omacom/omarchy-mac-installer#readme) ang mga release channel, pag-update ng installer at pag-alis ng Omarchy.

## Mga Intel Mac

Sa isang simpleng pagsubok, nakamit namin ang 36% na pagtaas sa performance sa isang 2019 MacBook Pro sa pamamagitan lang ng pag-install ng Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Pag-install ng Omarchy sa Mac

Sinusuportahan lang ng Omarchy sa ngayon na maging **tanging** OS na naka-install. Sa panahon ng pag-install, buburahin ang drive at hindi na magiging bootable ang MacOS.

Maaari mo pa rin itong i-restore sa ibang pagkakataon sa pamamagitan ng Internet Recovery kung gusto mo.

Para sa bahaging ito, ipagpapalagay naming nasuri mo na ang [Pagsisimula](02-getting-started.md) at handa na ang iyong USB drive. Kung hindi pa, sige at gawin mo na iyon ngayon.

#### I-disable ang Secure Boot

Kinakailangang i-disable ang Secure Boot ng Apple para ma-boot ang bootable USB, pati na rin ang OS. Para i-disable ito, gawin ang sumusunod:

1. I-off ang iyong Mac
2. I-on ito at _agad_ na pindutin nang matagal ang Command-R hanggang makita mong lumabas ang loading screen
3. Piliin ang iyong user at ilagay ang iyong password kung hihilingin
4. Kapag nasa recovery screen na, piliin ang **Utilities > Startup Security Utility** mula sa menubar
5. Ilagay ang iyong password kapag hihilinging mag-authenticate
6. Piliin ang "No Security" mula sa mga opsyon ng Secure Boot
7. Piliin ang "Allow booting from external or removable media" mula sa mga opsyon ng External Boot

#### Simulan ang Pag-install

1. Ipasok ang USB drive
2. I-restart ang iyong Mac at _agad_ na pindutin nang matagal ang Option hanggang makakita ka ng screen ng mga boot device
3. Piliin ang kulay kahel na EFI Boot device
4. Magpatuloy sa [pag-install gaya ng karaniwan](02-getting-started.md)

Natutukoy ng installer ang hardware ng Mac at awtomatikong inilalapat ang mga kailangang ayos: mga driver at firmware ng Broadcom Wi-Fi, ang driver ng FaceTime HD camera sa mga makinang may Broadcom 1570 (dina-download ang firmware nito mula sa Apple kapag online na ang Mac, dahil gumagana offline ang installer), ang SPI keyboard driver sa mga modelo ng MacBook na nangangailangan nito, at isang NVMe suspend fix para sa parehong mga modelong iyon.

### Mga Kilalang Limitasyon

Patuloy na gumagawa ang mga miyembro ng komunidad ng mga solusyon sa mga hamong ito kaya kung problema ito para sa iyo, sumali sa #omarchy-on-other sa aming [Discord](https://discord.gg/tXFUdasqhY) at tingnan kung may mga napapanahong paraan para malutas ang mga ito.

#### FaceTime HD Camera

Nagha-hang ang driver ng camera sa makina kung naka-load ito kapag nag-hibernate ang Mac, kaya ina-unload muna ito. Hindi ito maaaring i-unload habang may app na nakabukas ang camera, kaya kinakansela ang hibernation nang may notification na pinapangalanan ang app: isara ito at mag-hibernate ulit. Kasama rito ang awtomatikong pag-hibernate sa kritikal na baterya, at ang suspend-then-hibernate, na tinatanggihan bago ito mag-suspend. Ang ordinaryong suspend ay tinatanggihan mismo ng driver habang bukas ang camera, nang walang notification.

Dina-download ang firmware ng camera mula sa Apple, kaya gumagana lang ang camera kapag nakapag-online na ang Mac. Nagsisimula ang pag-download sa pag-boot at inuulit bawat 15 minuto habang ang network ang problema; kung nagbago ang file ng Apple, titigil ito at maghihintay ng update ng Omarchy. Kung hindi lumabas ang camera, sinasabi ng `journalctl -u facetimehd-firmware-fetcher` kung bakit, sinusubukan ulit ng `sudo systemctl restart facetimehd-firmware-fetcher`, at ni-lo-load ng pag-reboot ang driver kung natapos na ang pag-download ngunit wala pa rin ang camera.

#### Mga Device na may T1 Chip

Ipinakilala ang Apple T1 chip noong huling bahagi ng 2016 at ginamit lang sa mga unang henerasyong modelo ng MacBook Pro na may Touch Bar.
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

Sa mga modelong ito, awtomatikong sine-setup ng installer ang na-patch na `linux-t2` kernel, ang configuration ng audio ng T2, ang Broadcom Wi-Fi/Bluetooth firmware ng Apple, at ang kontrol ng fan sa pamamagitan ng `t2fanrd`. Gumagana ang Touch Bar sa built-in na Boot Camp-style na suporta ng kernel.

#### iMac Retina 5K (2017)

Walang T2 chip ang 2017 27-inch iMac, kaya sine-setup ito ng installer gaya ng ibang mga Intel Mac.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Mga Kilalang Isyu

- Hindi tumatakbo ang display sa native nitong 5120×2880: dalawang tile ang panel, at isa lang ang pinaiilaw ng stock driver
- Hindi gumagana ang tunog
- Walang epekto ang kontrol sa brightness
- Nagha-hang ang makina sa pagtulog; tanging power cycle lang ang nakakabawi nito

Inaayos ng isang community patcher para sa modelong ito ang display, tunog at brightness: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
