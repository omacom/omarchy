# Mac atbalsts

Omarchy ir iebūvēts atbalsts **Intel Mac** datoriem. Šobrīd ir pāris zināmu ierobežojumu, bet, kamēr par tiem zināt un piekrītat, varat iedot saviem vecajiem Mac jaunu elpu, ielādējot Omarchy.

Ņemiet vērā, ka instalēšana M sērijas Mac šobrīd tieši netiek atbalstīta. Vairāk par tā stāvokli varat uzzināt kanālā #omarchy-on-other mūsu [Discord](https://discord.gg/tXFUdasqhY).

Vienkāršā testā 2019. gada MacBook Pro mums izdevās panākt 36% veiktspējas pieaugumu, vienkārši instalējot Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy instalēšana Mac datorā

Omarchy šobrīd atbalsta tikai to, ka tā ir **vienīgā** instalētā OS. Instalēšanas laikā disks tiks notīrīts, un MacOS vairs nebūs sāknējama.

Vēlāk to joprojām varat atjaunot ar Internet Recovery, ja vēlaties.

Šajā daļā pieņemsim, ka jau esat izlasījis [Darba sākšanu](02-getting-started.md) un jūsu USB disks ir gatavs. Ja neesat, dariet to tagad.

#### Secure Boot atspējošana

Lai sāknētu sāknējamo USB, kā arī OS, ir jāatspējo Apple Secure Boot. Lai to atspējotu, rīkojieties šādi:

1. Izslēdziet savu Mac
2. Ieslēdziet to un _nekavējoties_ nospiediet un turiet Command-R, līdz redzat ielādes ekrānu
3. Atlasiet savu lietotāju un, ja prasa, ievadiet paroli
4. Kad esat atkopšanas ekrānā, izvēlņu joslā izvēlieties **Utilities > Startup Security Utility**
5. Kad prasa autentificēties, ievadiet paroli
6. No Secure Boot opcijām izvēlieties “No Security”
7. No External Boot opcijām izvēlieties “Allow booting from external or removable media”

#### Instalēšanas sākšana

1. Ievietojiet USB disku
2. Restartējiet savu Mac un _nekavējoties_ nospiediet un turiet Option, līdz redzat sāknēšanas ierīču ekrānu
3. Atlasiet oranžo EFI Boot ierīci
4. Turpiniet ar [ierasto instalēšanu](02-getting-started.md)

Instalētājs atpazīst Mac aparatūru un automātiski lieto vajadzīgos labojumus: Broadcom Wi-Fi draiverus un aparātprogrammatūru, SPI tastatūras draiveri MacBook modeļos, kam tas vajadzīgs, un NVMe apturēšanas labojumu tiem pašiem modeļiem.

### Zināmie ierobežojumi

Kopienas locekļi pastāvīgi strādā pie šo izaicinājumu risinājumiem, tāpēc, ja tie jums sagādā problēmas, pievienojieties kanālam #omarchy-on-other mūsu [Discord](https://discord.gg/tXFUdasqhY) un pārbaudiet, vai ir kādas aktuālas to risināšanas metodes.

#### Ierīces ar T1 mikroshēmu

Apple T1 mikroshēma tika ieviesta 2016. gada beigās un lietota tikai pirmās paaudzes MacBook Pro modeļos ar Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Zināmās problēmas

- Touch Bar nedarbojas
- Skaņa nedarbojas

#### Ierīces ar T2 mikroshēmu

Apple T2 drošības mikroshēma tika ieviesta 2017. gadā. T2 mikroshēma tika pārtraukta, pārejot uz Apple silicon (M sērijas mikroshēmām), sākot no 2020. gada.

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

Šajos modeļos instalētājs automātiski iestata laboto `linux-t2` kodolu, T2 audio konfigurāciju, Apple Broadcom Wi-Fi/Bluetooth aparātprogrammatūru un ventilatora vadību ar `t2fanrd`. Touch Bar darbojas uz kodolā iebūvētā Boot Camp stila atbalsta.
