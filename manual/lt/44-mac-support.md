# Mac palaikymas

## Omarchy for Apple Silicon

„Omarchy for Apple Silicon“ yra oficialus „Omacom“ sprendimas, pirmą kartą išleistas kartu su „Omarchy 4.5“. Ji įdiegiama šalia „macOS“, o paleidžiant „Mac“ pasirenkate vieną iš dviejų.

Gavote pranešimą apie „Omarchy Mac“? Eikite į [Perėjimas nuo „Omarchy Mac“](#coming-from-omarchy-mac).

Ji veikia šiuose „Mac“ kompiuteriuose:

| Mac | Lustai |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 ir naujesni „Mac“ kol kas nepalaikomi. M4 palaikymas testuojamas „edge“ kanale ir pasirodys kitas. Diegimo programa patikrina jūsų „Mac“ prieš ką nors keisdama.

Bet kuriame „Apple Silicon Mac“, įskaitant M4 ir naujesnius, galite paleisti „Omarchy“ virtualioje mašinoje su [„Try Omarchy“](https://github.com/omacom/try-omarchy).

### Ko jums reikia

- „macOS 15 Sequoia“ arba naujesnės versijos ir administratoriaus paskyros
- Laisvos vietos diske „Omarchy“. Diegimo programa pasiūlo dydį ir leidžia jį pakeisti.
- „Mac“ atsarginės kopijos, maitinimo ir interneto ryšio. Diegiant atsisiunčiami keli gigabaitai.

### Diegimas

Diegiate iš „macOS“. Įdiekite „Omarchy Installer“ su [„Homebrew“](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Arba atsisiųskite naujausią „Omarchy Installer“ iš jos [leidimų puslapio](https://github.com/omacom/omarchy-mac-installer/releases) ir atidarykite ją.

Diegimo programa patikrina jūsų „Mac“, parodo planą ir atlaisvina vietos „Omarchy“ sumažindama „macOS“ skaidinį. „macOS“ lieka diske ir USB atmintinės nereikia. Baigus pirmąjį etapą, ji paaiškina, kaip užbaigti sąranką „macOS Recovery“ aplinkoje: išjunkite, laikykite maitinimo mygtuką, kol pasirodys „Loading startup options“, pasirinkite „Omarchy“ ir atlikite veiksmus.

Paleidus pirmą kartą, „Omarchy“ paprašo slaptažodžio, kuris užšifruoja jos diską. Atkūrimo rakto nėra: jei pamiršite slaptažodį, jūsų „Omarchy“ failų atkurti nepavyks.

Norėdami vėliau perjungti tarp „Omarchy“ ir „macOS“, išjunkite, tada laikykite maitinimo mygtuką, kol pasirodys paleisties parinktys, ir pasirinkite vieną.

### Perėjimas nuo „Omarchy Mac“

„Omarchy Mac“ dabar yra „Omarchy for Apple Silicon“ dalis, ir kiekvienas „Mac“, kuriame ji veikė, yra palaikomas. Jūsų dabartinis diegimas veikia toliau, o jo sistemos paketai vis dar atnaujinami, tačiau „Omarchy“ naujinimų jis daugiau negaus. Termino nėra ir atnaujinimo vietoje nėra: sukuriate atsarginę kopiją, pašalinate senąjį diegimą, įdiegiate iš naujo ir atkuriate. 2–5 veiksmai atliekami „macOS“, todėl prieš paleisdami iš naujo atidarykite šį puslapį telefone.

1. **Sukurkite atsarginę kopiją iš „Omarchy“, ne „Mac“ kompiuteryje.** Pašalinus senąjį diegimą, jis ištrinamas, o „macOS“ negali nuskaityti „Omarchy“ disko. Nukopijuokite namų aplanką į išorinį diską arba kitą kompiuterį, įskaitant SSH ir GPG raktus, naršyklės profilius ir dar neperduotą darbą. Išsaugokite paketų sąrašą komanda `pacman -Qqe > ~/packages.txt`. Sukurkite ir „macOS“ atsarginę kopiją, nes tiek šalinant, tiek diegiant keičiamas jos disko dydis.
2. **Paleiskite „Mac“ su „macOS“.** Išjunkite, laikykite maitinimo mygtuką, kol pasirodys paleisties parinktys, ir pasirinkite „macOS“.
3. **Įdiekite „Omarchy Installer“**, kaip parodyta skyriuje [Diegimas](#installing).
4. **Pašalinkite senąjį diegimą.** Atidarykite „Omarchy Installer“ ir pasirinkite Installation > Remove Omarchy. Ji parodo, ką ištrins, ir grąžina vietą „macOS“. Jei ji neatpažįsta jūsų diegimo, sustoja nekeisdama disko. Prašykite pagalbos [„Discord“](https://discord.gg/tXFUdasqhY), užuot trynę skaidinius ranka, nes taip galite ištrinti „macOS“.
5. **Įdiekite „Omarchy for Apple Silicon“** naudodami diegimo programą.
6. **Atkurkite failus.** Grąžinkite nustatymus po vieną dalį, užuot kopijavę visą `~/.config` ant naujųjų numatytųjų nustatymų, nes seni nustatymai gali juos perrašyti.

### Verta žinoti

- M1 ir M2 „MacBook“ kompiuteriuose pažadinkite iš miego atidarydami dangtį arba paspausdami maitinimo mygtuką.
- Klausimai ar problemos: klauskite mūsų [„Discord“](https://discord.gg/tXFUdasqhY).

[Diegimo programos README](https://github.com/omacom/omarchy-mac-installer#readme) aprašo leidimų kanalus, diegimo programos atnaujinimą ir „Omarchy“ pašalinimą.

## „Intel Mac“ kompiuteriai

Atlikę paprastą testą, vien įdiegę „Omarchy“ 2019 m. „MacBook Pro“ sugebėjome pasiekti 36 % našumo prieaugį.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### „Omarchy“ diegimas „Mac“ kompiuteryje

Šiuo metu „Omarchy“ palaiko buvimą **vienintele** įdiegta OS. Diegimo metu diskas bus ištrintas, o „MacOS“ nebebus galima paleisti.

Jei norėsite, vėliau vis tiek galėsite ją atkurti per „Internet Recovery“.

Šioje dalyje laikysime, kad jau peržiūrėjote [Darbo pradžią](02-getting-started.md) ir jūsų USB atmintinė jau paruošta. Jei ne, eikite ir padarykite tai dabar.

#### Išjunkite „Secure Boot“

Norint paleisti paleidžiamąją USB atmintinę ir pačią OS, būtina išjungti „Apple Secure Boot“. Norėdami ją išjungti, atlikite šiuos veiksmus:

1. Išjunkite „Mac“
2. Įjunkite jį ir _nedelsdami_ paspauskite bei laikykite Command-R, kol pamatysite įkėlimo ekraną
3. Pasirinkite savo naudotoją ir, jei prašoma, įveskite slaptažodį
4. Atsidūrę atkūrimo ekrane, meniu juostoje pasirinkite **Utilities > Startup Security Utility**
5. Kai prašoma patvirtinti tapatybę, įveskite slaptažodį
6. „Secure Boot“ parinktyse pasirinkite "No Security"
7. „External Boot“ parinktyse pasirinkite "Allow booting from external or removable media"

#### Pradėkite diegimą

1. Įkiškite USB atmintinę
2. Paleiskite „Mac“ iš naujo ir _nedelsdami_ paspauskite bei laikykite Option, kol pamatysite paleisties įrenginių ekraną
3. Pasirinkite oranžinį „EFI Boot“ įrenginį
4. Tęskite [diegimą kaip įprasta](02-getting-started.md)

Diegimo programa aptinka „Mac“ aparatinę įrangą ir automatiškai pritaiko reikiamus pataisymus: „Broadcom“ Wi-Fi tvarkykles ir programinę aparatinę įrangą, SPI klaviatūros tvarkyklę tiems „MacBook“ modeliams, kuriems jos reikia, ir NVMe pristabdymo pataisymą tiems patiems modeliams.

### Žinomi apribojimai

Bendruomenės nariai nuolat ieško šių problemų sprendimų, todėl, jei jos jums kelia sunkumų, prisijunkite prie #omarchy-on-other mūsų [„Discord“](https://discord.gg/tXFUdasqhY) ir pažiūrėkite, ar nėra naujausių jų sprendimo būdų.

#### Įrenginiai su T1 lustu

„Apple T1“ lustas buvo pristatytas 2016 m. pabaigoje ir naudotas tik pirmosios kartos „MacBook Pro“ modeliuose su „Touch Bar“.
- MacBook Pro 13 colių (2016 m., du Thunderbolt 3 prievadai) – Modelis: A1706
- MacBook Pro 13 colių (2016 m., keturi Thunderbolt 3 prievadai) – Modelis: A1708
- MacBook Pro 15 colių (2016 m.) – Modelis: A1707

#### Žinomos problemos

- „Touch Bar“ neveikia
- Garsas neveikia

#### Įrenginiai su T2 lustu

„Apple T2 Security Chip“ buvo pristatytas 2017 m. T2 lusto gamyba nutraukta pereinant prie „Apple silicon“ (M serijos lustų) nuo 2020 m.

- iMac Pro (2017 m.) – Modelis: A1862
- MacBook Pro 13 colių (2018 m., keturi Thunderbolt 3 prievadai) – Modelis: A1989
- MacBook Pro 15 colių (2018 m.) – Modelis: A1990
- MacBook Air (Retina, 13 colių, 2018 m.) – Modelis: A1932
- Mac mini (2018 m.) – Modelis: A1998
- MacBook Pro 13 colių (2019 m., du Thunderbolt 3 prievadai) – Modelis: A2159
- MacBook Pro 13 colių (2019 m., keturi Thunderbolt 3 prievadai) – Modelis: A2178
- MacBook Pro 15 colių (2019 m.) – Modelis: A1990
- iMac (Retina 5K, 27 colių, 2020 m.) – Modelis: A2115 (iMac20,1 ir iMac20,2)
- MacBook Pro 13 colių (2020 m., du Thunderbolt 3 prievadai) – Modelis: A2265
- MacBook Pro 15 colių (2020 m.) – Modelis: A1990

Šiuose modeliuose diegimo programa automatiškai nustato pataisytą `linux-t2` branduolį, T2 garso konfigūraciją, „Apple Broadcom“ Wi-Fi / „Bluetooth“ programinę aparatinę įrangą ir ventiliatoriaus valdymą per `t2fanrd`. „Touch Bar“ veikia naudodama branduolyje įtaisytą „Boot Camp“ stiliaus palaikymą.

#### iMac Retina 5K (2017)

2017 m. 27 colių „iMac“ neturi T2 lusto, todėl diegimo programa jį nustato kaip kitus „Intel Mac“ kompiuterius.

- iMac (Retina 5K, 27 colių, 2017 m.) – Modelis: A1419

#### Žinomos problemos

- Ekranas neveikia savo natyviąja 5120×2880 raiška: skydelis sudarytas iš dviejų plytelių, o standartinė tvarkyklė apšviečia tik vieną
- Garsas neveikia
- Šviesumo valdiklis neturi jokio poveikio
- Miegas pakabina kompiuterį; jį atkuria tik maitinimo išjungimas ir įjungimas

Bendruomenės pataisymo programa šiam modeliui sutvarko ekraną, garsą ir šviesumą: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
