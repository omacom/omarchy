# Mac atbalsts

Omarchy ir iebūvēts atbalsts **Intel Mac** datoriem. Pašlaik ir pāris zināmi ierobežojumi, bet, kamēr tu tos apzinies un ar tiem samierinies; tu vari iedvest jaunu dzīvību savos vecajos Mac datoros, uzstādot Omarchy.

Lūdzu, ņem vērā, ka uzstādīšana M sērijas Mac datoros pašlaik netiek tieši atbalstīta. Vairāk par šī jautājuma stāvokli vari uzzināt kanālā #omarchy-on-other mūsu [Discord](https://discord.gg/tXFUdasqhY).

Vienkāršā testā mums izdevās panākt 36% veiktspējas pieaugumu 2019. gada MacBook Pro, tikai vien uzstādot Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy uzstādīšana Mac datorā

Omarchy pašlaik atbalsta tikai situāciju, kad tā ir **vienīgā** uzstādītā OS. Uzstādīšanas laikā disks tiks izdzēsts, un MacOS vairs nebūs palaižams.

Vēlāk to joprojām varēsi atjaunot, izmantojot Internet Recovery, ja vēlēsies.

Šajā daļā pieņemsim, ka tu jau esi izlasījis [Darba sākšana](02-getting-started.md) un tavs USB disks ir gatavs. Ja neesi, ej un izdari to tagad.

#### Secure Boot atspējošana

Lai palaistu palaižamo USB disku, kā arī OS, ir nepieciešams atspējot Apple Secure Boot. Lai to atspējotu, veic šādas darbības:

1. Izslēdz savu Mac datoru
2. Ieslēdz to un _nekavējoties_ nospied un turi Command-R, līdz parādās ielādes ekrāns
3. Izvēlies savu lietotāju un ievadi paroli, ja tiek prasīts
4. Kad esi atkopšanas ekrānā, izvēļņu joslā izvēlies **Utilities > Startup Security Utility**
5. Ievadi paroli, kad tiek prasīts autentificēties
6. Secure Boot opcijās izvēlies "No Security"
7. External Boot opcijās izvēlies "Allow booting from external or removable media"

#### Uzstādīšanas sākšana

1. Ievieto USB disku
2. Restartē savu Mac datoru un _nekavējoties_ nospied un turi Option, līdz parādās palaišanas ierīču ekrāns
3. Izvēlies oranžo EFI Boot ierīci
4. Turpini ar [uzstādīšanu kā parasti](02-getting-started.md)

Uzstādītājs nosaka Mac aparatūru un automātiski piemēro nepieciešamos labojumus: Broadcom Wi-Fi draiverus un programmaparatūru, SPI tastatūras draiveri MacBook modeļiem, kuriem tas nepieciešams, un NVMe apturēšanas labojumu tiem pašiem modeļiem.

### Zināmie ierobežojumi

Kopienas dalībnieki pastāvīgi strādā pie šo problēmu risinājumiem, tāpēc, ja tās tev traucē, pievienojies #omarchy-on-other mūsu [Discord](https://discord.gg/tXFUdasqhY) un noskaidro, vai ir kādas aktuālas to risināšanas metodes.

#### Ierīces ar T1 mikroshēmu

Apple T1 mikroshēma tika prezentēta 2016. gada beigās un tika izmantota tikai pirmās paaudzes MacBook Pro modeļos ar Touch Bar.
- MacBook Pro 13 collu (2016, divas Thunderbolt 3 pieslēgvietas) – Modelis: A1706
- MacBook Pro 13 collu (2016, četras Thunderbolt 3 pieslēgvietas) – Modelis: A1708
- MacBook Pro 15 collu (2016) – Modelis: A1707

#### Zināmās problēmas

- Touch Bar nedarbojas
- Skaņa nedarbojas

#### Ierīces ar T2 mikroshēmu

Apple T2 Security Chip tika prezentēta 2017. gadā. T2 mikroshēmas ražošana tika pārtraukta līdz ar pāreju uz Apple silicon (M sērijas mikroshēmām), sākot no 2020. gada.

- iMac Pro (2017) – Modelis: A1862
- MacBook Pro 13 collu (2018, četras Thunderbolt 3 pieslēgvietas) – Modelis: A1989
- MacBook Pro 15 collu (2018) – Modelis: A1990
- MacBook Air (Retina, 13 collu, 2018) – Modelis: A1932
- Mac mini (2018) – Modelis: A1998
- MacBook Pro 13 collu (2019, divas Thunderbolt 3 pieslēgvietas) – Modelis: A2159
- MacBook Pro 13 collu (2019, četras Thunderbolt 3 pieslēgvietas) – Modelis: A2178
- MacBook Pro 15 collu (2019) – Modelis: A1990
- iMac (Retina 5K, 27 collu, 2020) – Modelis: A2115 (iMac20,1 un iMac20,2)
- MacBook Pro 13 collu (2020, divas Thunderbolt 3 pieslēgvietas) – Modelis: A2265
- MacBook Pro 15 collu (2020) – Modelis: A1990

Šajos modeļos uzstādītājs automātiski iestata ielāpoto `linux-t2` kodolu, T2 audio konfigurāciju, Apple Broadcom Wi-Fi/Bluetooth programmaparatūru un ventilatora vadību, izmantojot `t2fanrd`. Touch Bar darbojas ar kodolā iebūvēto Boot Camp stila atbalstu.

#### iMac Retina 5K (2017)

2017. gada 27 collu iMac nav T2 mikroshēmas, tāpēc uzstādītājs to iestata tāpat kā citus Intel Mac datorus.

- iMac (Retina 5K, 27 collu, 2017) – Modelis: A1419

#### Zināmās problēmas

- Displejs nedarbojas tā sākotnējā 5120×2880 izšķirtspējā: panelis sastāv no divām daļām, un standarta draiveris izgaismo tikai vienu
- Skaņa nedarbojas
- Spilgtuma vadībai nav nekādas ietekmes
- Miega režīms uzkar datoru; to var atjaunot, tikai izslēdzot un no jauna ieslēdzot barošanu

Kopienas ielāpotājs šim modelim novērš displeja, skaņas un spilgtuma problēmas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
