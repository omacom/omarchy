# Mac atbalsts

## Omarchy Apple Silicon ierīcēm

Omarchy Apple Silicon ierīcēm ir oficiāls Omacom risinājums, kas pirmo reizi tika izlaists kopā ar Omarchy 4.5. Tas tiek instalēts līdzās macOS, un jūs izvēlaties starp abiem, kad jūsu Mac startējas.

Saņēmāt paziņojumu par Omarchy Mac? Dodieties uz [Pārnākšana no Omarchy Mac](#coming-from-omarchy-mac).

Tas darbojas šajos Mac datoros:

| Mac | Mikroshēmas |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 un jaunāki Mac datori vēl netiek atbalstīti. M4 atbalsts tiek testēts edge kanālā un būs nākamais. Instalētājs pārbauda jūsu Mac, pirms tas kaut ko maina.

Jebkurā Apple Silicon Mac datorā, tostarp M4 un jaunākos, jūs varat palaist Omarchy virtuālajā mašīnā ar [Try Omarchy](https://github.com/omacom/try-omarchy).

### Kas jums nepieciešams

- macOS 15 Sequoia vai jaunāka versija un administratora konts
- Brīva vieta diskā Omarchy vajadzībām. Instalētājs iesaka izmēru un ļauj jums to mainīt.
- Jūsu Mac dublējums, barošana un interneta savienojums. Instalēšana lejupielādē vairākus gigabaitus.

### Instalēšana

Jūs instalējat no macOS. Instalējiet Omarchy Installer ar [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Vai lejupielādējiet jaunāko Omarchy Installer no tā [izlaidumu lapas](https://github.com/omacom/omarchy-mac-installer/releases) un atveriet to.

Instalētājs pārbauda jūsu Mac, parāda jums plānu un atbrīvo vietu Omarchy, samazinot macOS nodalījumu. macOS paliek diskā, un USB disks nav nepieciešams. Kad pirmais posms ir paveikts, tas soli pa solim palīdz jums pabeigt iestatīšanu macOS Recovery režīmā: izslēdziet datoru, turiet nospiestu barošanas pogu, līdz parādās "Loading startup options", izvēlieties Omarchy un izpildiet darbības.

Pirmajā startēšanas reizē Omarchy prasa paroli, kas šifrē tā disku. Atkopšanas atslēgas nav: ja aizmirsīsiet paroli, jūsu Omarchy failus nevarēs atgūt.

Lai vēlāk pārslēgtos starp Omarchy un macOS, izslēdziet datoru, pēc tam turiet nospiestu barošanas pogu, līdz parādās startēšanas opcijas, un izvēlieties vienu no tām.

### Pārnākšana no Omarchy Mac

Omarchy Mac tagad ir daļa no Omarchy Apple Silicon ierīcēm, un tiek atbalstīts katrs Mac, kurā tas darbojās. Jūsu pašreizējā instalācija turpina darboties, un tās sistēmas pakotnes joprojām tiek atjauninātas, bet tā vairs nesaņem Omarchy atjauninājumus. Termiņa nav un jauninājuma uz vietas nav: jūs izveidojat dublējumu, noņemat veco instalāciju, instalējat no jauna un atjaunojat. 2.–5. darbība notiek macOS, tāpēc atveriet šo lapu savā tālrunī, pirms restartējat datoru.

1. **Izveidojiet dublējumu no Omarchy ārpus Mac.** Vecās instalācijas noņemšana to dzēš, un macOS nevar nolasīt Omarchy disku. Kopējiet savu mājas mapi uz ārēju disku vai citu datoru, tostarp SSH un GPG atslēgas, pārlūkprogrammu profilus un neiesūtīto darbu. Saglabājiet savu pakotņu sarakstu ar `pacman -Qqe > ~/packages.txt`. Dublējiet arī macOS, jo gan noņemšana, gan instalēšana maina tā diska izmēru.
2. **Startējiet savu Mac macOS režīmā.** Izslēdziet datoru, turiet nospiestu barošanas pogu, līdz parādās startēšanas opcijas, un izvēlieties macOS.
3. **Instalējiet Omarchy Installer**, kā parādīts sadaļā [Instalēšana](#installing).
4. **Noņemiet veco instalāciju.** Atveriet Omarchy Installer un izvēlieties Installation > Remove Omarchy. Tas parāda, ko tas dzēsīs, un atgriež vietu macOS. Ja tas neatpazīst jūsu instalāciju, tas apstājas, nemainot disku. Lūdziet palīdzību [Discord](https://discord.gg/tXFUdasqhY), nevis dzēsiet nodalījumus manuāli, kas var izdzēst macOS.
5. **Instalējiet Omarchy Apple Silicon ierīcēm** ar instalētāju.
6. **Atjaunojiet savus failus.** Atjaunojiet savus iestatījumus pa daļai, nevis kopējiet visu `~/.config` pāri jaunajiem noklusējumiem, jo vecie iestatījumi var tos pārrakstīt.

### Noderīgi zināt

- M1 un M2 MacBook datoros pamodiniet datoru no miega režīma, atverot vāku vai nospiežot barošanas pogu.
- Jautājumi vai problēmas: jautājiet mūsu [Discord](https://discord.gg/tXFUdasqhY).

[Instalētāja README](https://github.com/omacom/omarchy-mac-installer#readme) aptver izlaidumu kanālus, instalētāja atjaunināšanu un Omarchy noņemšanu.

## Intel Mac datori

Vienkāršā testā mums izdevās panākt 36% veiktspējas pieaugumu 2019. gada MacBook Pro, tikai instalējot Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy instalēšana Mac datorā

Omarchy pašlaik atbalsta tikai to, ka tā ir **vienīgā** instalētā OS. Instalēšanas laikā disks tiks notīrīts un MacOS vairs nebūs startējama.

Ja vēlaties, vēlāk to joprojām varat atjaunot, izmantojot Internet Recovery.

Šajā daļā mēs pieņemsim, ka jūs jau esat pārskatījuši [Darba sākšana](02-getting-started.md) un jūsu USB disks ir gatavs. Ja neesat, dodieties un izdariet to tagad.

#### Secure Boot atspējošana

Ir nepieciešams atspējot Apple Secure Boot, lai startētu startējamo USB, kā arī OS. Lai to atspējotu, veiciet tālāk norādītās darbības:

1. Izslēdziet savu Mac
2. Ieslēdziet to un _nekavējoties_ nospiediet un turiet nospiestu Command-R, līdz redzat ielādes ekrānu
3. Atlasiet savu lietotāju un ievadiet paroli, ja tiek prasīts
4. Kad esat atkopšanas ekrānā, izvēlnes joslā izvēlieties **Utilities > Startup Security Utility**
5. Ievadiet paroli, kad tiek prasīts autentificēties
6. Secure Boot opcijās izvēlieties "No Security"
7. External Boot opcijās izvēlieties "Allow booting from external or removable media"

#### Instalēšanas sākšana

1. Ievietojiet USB disku
2. Restartējiet savu Mac un _nekavējoties_ nospiediet un turiet nospiestu Option, līdz redzat startēšanas ierīču ekrānu
3. Atlasiet oranžo EFI Boot ierīci
4. Turpiniet ar [instalēšanu kā parasti](02-getting-started.md)

Instalētājs nosaka Mac aparatūru un automātiski piemēro nepieciešamos labojumus: Broadcom Wi-Fi draiverus un programmaparatūru, FaceTime HD kameras draiveri ierīcēs ar Broadcom 1570 (tā programmaparatūra tiek lejupielādēta no Apple, tiklīdz Mac ir tiešsaistē, jo instalētājs darbojas bezsaistē), SPI tastatūras draiveri MacBook modeļos, kuriem tas nepieciešams, un NVMe apturēšanas labojumu tiem pašiem modeļiem.

### Zināmie ierobežojumi

Kopienas dalībnieki pastāvīgi strādā pie šo problēmu risinājumiem, tāpēc, ja tās jums sagādā problēmas, pievienojieties #omarchy-on-other mūsu [Discord](https://discord.gg/tXFUdasqhY) un noskaidrojiet, vai ir kādas aktuālas metodes to novēršanai.

#### FaceTime HD kamera

Kameras draiveris uzkar ierīci, ja tas ir ielādēts, kad Mac pārziemo, tāpēc tas vispirms tiek atielādēts. To nevar atielādēt, kamēr lietotnei ir atvērta kamera, tāpēc pārziemošana tiek atcelta ar paziņojumu, kurā nosaukta lietotne: aizveriet to un pārziemojiet vēlreiz. Tas ietver automātisku pārziemošanu kritiska akumulatora līmeņa gadījumā un apturēšanu un pēc tam pārziemošanu, kas tiek atteikta, pirms tā aptur darbību. Parastu apturēšanu pats draiveris atsaka, kamēr kamera ir atvērta, bez paziņojuma.

Kameras programmaparatūra tiek lejupielādēta no Apple, tāpēc kamera darbojas tikai tad, kad Mac ir bijis tiešsaistē. Lejupielāde sākas startēšanas laikā un tiek mēģināta vēlreiz ik pēc 15 minūtēm, kamēr problēma ir tīkls; ja Apple fails ir mainījies, tā apstājas un gaida Omarchy atjauninājumu. Ja kamera neparādās, `journalctl -u facetimehd-firmware-fetcher` norāda, kāpēc, `sudo systemctl restart facetimehd-firmware-fetcher` mēģina vēlreiz, un pārstartēšana ielādē draiveri, ja lejupielāde ir pabeigta, bet kameras joprojām nav.

#### Ierīces ar T1 mikroshēmu

Apple T1 mikroshēma tika ieviesta 2016. gada beigās un tika izmantota tikai pirmās paaudzes MacBook Pro modeļos ar Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Zināmās problēmas

- Touch Bar nedarbojas
- Skaņa nedarbojas

#### Ierīces ar T2 mikroshēmu

Apple T2 Security Chip tika ieviesta 2017. gadā. T2 mikroshēmas ražošana tika pārtraukta līdz ar pāreju uz Apple silicon (M sērijas mikroshēmām), sākot no 2020. gada.

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

Šajos modeļos instalētājs automātiski iestata ielāpoto `linux-t2` kodolu, T2 audio konfigurāciju, Apple Broadcom Wi-Fi/Bluetooth programmaparatūru un ventilatoru vadību, izmantojot `t2fanrd`. Touch Bar darbojas ar kodolā iebūvēto Boot Camp stila atbalstu.

#### iMac Retina 5K (2017)

2017. gada 27 collu iMac nav T2 mikroshēmas, tāpēc instalētājs to iestata tāpat kā citus Intel Mac datorus.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Zināmās problēmas

- Displejs nedarbojas tā sākotnējā 5120×2880 izšķirtspējā: panelis sastāv no divām daļām, un standarta draiveris izgaismo tikai vienu
- Skaņa nedarbojas
- Spilgtuma vadībai nav efekta
- Miega režīms uzkar ierīci; to var atgūt tikai ar barošanas ciklu

Kopienas ielāpotājs šim modelim novērš displeja, skaņas un spilgtuma problēmas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
