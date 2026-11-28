# Mac palaikymas

## Omarchy, skirta Apple Silicon

Omarchy, skirta Apple Silicon, yra oficialus Omacom sprendimas, pirmą kartą išleistas kartu su Omarchy 4.5. Ji įdiegiama šalia macOS, o paleidžiant Mac pasirenkate vieną iš dviejų.

Gavote pranešimą apie Omarchy Mac? Eikite į [Pereinantiems nuo Omarchy Mac](#coming-from-omarchy-mac).

Ji veikia šiuose Mac kompiuteriuose:

| Mac | Lustai |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 ir naujesni Mac kol kas nepalaikomi. M4 palaikymas testuojamas edge kanale ir pasirodys kitas. Diegimo programa patikrina jūsų Mac prieš ką nors keisdama.

Bet kuriame Apple Silicon Mac, įskaitant M4 ir naujesnius, Omarchy galite paleisti virtualioje mašinoje su [Try Omarchy](https://github.com/omacom/try-omarchy).

### Ko jums reikia

- macOS 15 Sequoia arba naujesnės versijos ir administratoriaus paskyros
- Laisvos vietos diske Omarchy. Diegimo programa pasiūlo dydį ir leidžia jį pakeisti.
- Mac atsarginės kopijos, maitinimo ir interneto ryšio. Diegiant atsisiunčiami keli gigabaitai.

### Diegimas

Diegiate iš macOS. Įdiekite Omarchy Installer su [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Arba atsisiųskite naujausią Omarchy Installer iš jos [leidimų puslapio](https://github.com/omacom/omarchy-mac-installer/releases) ir atidarykite ją.

Diegimo programa patikrina jūsų Mac, parodo planą ir padaro vietos Omarchy sumažindama macOS skaidinį. macOS lieka diske ir USB atmintinės nereikia. Baigus pirmą etapą, ji padeda užbaigti sąranką macOS Recovery aplinkoje: išjunkite, laikykite nuspaudę maitinimo mygtuką, kol pasirodys „Loading startup options“, pasirinkite Omarchy ir vykdykite nurodymus.

Pirmą kartą paleidus Omarchy paprašys slaptažodžio, kuriuo šifruojamas jos diskas. Atkūrimo rakto nėra: jei slaptažodį pamiršite, jūsų Omarchy failų atkurti nepavyks.

Norėdami vėliau perjungti tarp Omarchy ir macOS, išjunkite kompiuterį, tada laikykite nuspaudę maitinimo mygtuką, kol pasirodys paleisties parinktys, ir pasirinkite vieną iš jų.

### Pereinantiems nuo Omarchy Mac

Omarchy Mac dabar yra Omarchy, skirtos Apple Silicon, dalis, ir palaikomas kiekvienas Mac, kuriame ji veikė. Jūsų dabartinis diegimas toliau veikia, o jo sistemos paketai vis dar atnaujinami, tačiau Omarchy atnaujinimų jis daugiau nebegaus. Nėra jokio termino ir nėra atnaujinimo vietoje: pasidarote atsarginę kopiją, pašalinate seną diegimą, įdiegiate iš naujo ir atkuriate. 2–5 veiksmai atliekami macOS, todėl prieš paleisdami iš naujo atsidarykite šį puslapį telefone.

1. **Pasidarykite atsarginę kopiją iš Omarchy, ne Mac kompiuteryje.** Pašalinus seną diegimą jis ištrinamas, o macOS negali nuskaityti Omarchy disko. Nukopijuokite savo namų aplanką į išorinį diską arba kitą kompiuterį, įskaitant SSH ir GPG raktus, naršyklės profilius ir neįkeltą darbą. Išsaugokite paketų sąrašą komanda `pacman -Qqe > ~/packages.txt`. Pasidarykite ir macOS atsarginę kopiją, nes tiek šalinant, tiek diegiant keičiamas jos disko dydis.
2. **Paleiskite Mac iš macOS.** Išjunkite, laikykite nuspaudę maitinimo mygtuką, kol pasirodys paleisties parinktys, ir pasirinkite macOS.
3. **Įdiekite Omarchy Installer** kaip parodyta skyriuje [Diegimas](#installing).
4. **Pašalinkite seną diegimą.** Atidarykite Omarchy Installer ir pasirinkite Installation > Remove Omarchy. Ji parodo, ką ištrins, ir grąžina vietą macOS. Jei ji neatpažįsta jūsų diegimo, sustoja nekeisdama disko. Pagalbos prašykite [Discord](https://discord.gg/tXFUdasqhY), o ne trinkite skaidinius rankomis – taip galima ištrinti macOS.
5. **Įdiekite Omarchy, skirtą Apple Silicon** su diegimo programa.
6. **Atkurkite failus.** Grąžinkite nustatymus po vieną dalį, o ne kopijuokite visą `~/.config` ant naujų numatytųjų nustatymų, nes seni nustatymai gali juos perrašyti.

### Verta žinoti

- M1 ir M2 MacBook kompiuteriuose iš miego režimo pažadinkite atidarydami dangtį arba paspausdami maitinimo mygtuką.
- Klausimai ar problemos: klauskite mūsų [Discord](https://discord.gg/tXFUdasqhY).

[Diegimo programos README](https://github.com/omacom/omarchy-mac-installer#readme) aprašomi leidimų kanalai, diegimo programos atnaujinimas ir Omarchy šalinimas.

## Intel Mac

Atlikę paprastą testą vien įdiegę Omarchy 2019 m. MacBook Pro pasiekėme 36% didesnį našumą.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy diegimas Mac kompiuteryje

Šiuo metu Omarchy palaikoma tik kaip **vienintelė** įdiegta OS. Diegiant diskas bus išvalytas, o MacOS daugiau nebebus paleidžiama.

Jei norėsite, vėliau ją vis tiek galėsite atkurti per Internet Recovery.

Šioje dalyje laikysime, kad jau perskaitėte [Darbo pradžia](02-getting-started.md) ir turite paruoštą USB atmintinę. Jei ne, padarykite tai dabar.

#### Secure Boot išjungimas

Norint paleisti įkraunamą USB atmintinę ir pačią OS, būtina išjungti Apple Secure Boot. Norėdami ją išjungti, atlikite šiuos veiksmus:

1. Išjunkite Mac
2. Įjunkite jį ir _nedelsdami_ nuspauskite bei laikykite Command-R, kol pamatysite įkrovos ekraną
3. Pasirinkite savo naudotoją ir, jei prašoma, įveskite slaptažodį
4. Atsidūrę atkūrimo ekrane meniu juostoje pasirinkite **Utilities > Startup Security Utility**
5. Kai prašoma patvirtinti tapatybę, įveskite slaptažodį
6. Secure Boot parinktyse pasirinkite „No Security“
7. External Boot parinktyse pasirinkite „Allow booting from external or removable media“

#### Diegimo pradžia

1. Įkiškite USB atmintinę
2. Paleiskite Mac iš naujo ir _nedelsdami_ nuspauskite bei laikykite Option, kol pamatysite įkrovos įrenginių ekraną
3. Pasirinkite oranžinį EFI Boot įrenginį
4. Tęskite [įprastą diegimą](02-getting-started.md)

Diegimo programa aptinka Mac aparatinę įrangą ir automatiškai pritaiko reikiamus pataisymus: Broadcom Wi-Fi tvarkykles ir programinę aparatinę įrangą, FaceTime HD kameros tvarkyklę kompiuteriuose su Broadcom 1570 (jos programinė aparatinė įranga atsisiunčiama iš Apple, kai Mac prisijungia prie interneto, nes diegimo programa veikia neprisijungusi), SPI klaviatūros tvarkyklę jos reikalinguose MacBook modeliuose ir NVMe pristabdymo pataisymą tiems patiems modeliams.

### Žinomi apribojimai

Bendruomenės nariai nuolat ieško šių iššūkių sprendimų, tad jei jie jums kelia problemų, prisijunkite prie #omarchy-on-other mūsų [Discord](https://discord.gg/tXFUdasqhY) ir pažiūrėkite, ar nėra naujausių jų sprendimo būdų.

#### FaceTime HD kamera

Kameros tvarkyklė pakabina kompiuterį, jei ji įkelta Mac pereinant į užmigdymo režimą, todėl pirmiausia ji iškeliama. Jos negalima iškelti, kol programa laiko atidarytą kamerą, todėl užmigdymas atšaukiamas pranešimu, kuriame įvardijama programa: uždarykite ją ir užmigdykite dar kartą. Tai galioja ir automatiškai užmigdant dėl kritiškai išsekusios baterijos, ir pristabdymui su paskesniu užmigdymu, kurio atsisakoma dar prieš pristabdant. Įprasto pristabdymo atsisako pati tvarkyklė, kol kamera atidaryta, be pranešimo.

Kameros programinė aparatinė įranga atsisiunčiama iš Apple, todėl kamera veikia tik Mac pabuvus internete. Atsisiuntimas prasideda paleidžiant ir kartojamas kas 15 minučių, kol problema yra tinklas; jei Apple failas pasikeitė, jis sustoja ir laukia Omarchy atnaujinimo. Jei kamera nepasirodo, `journalctl -u facetimehd-firmware-fetcher` pasako kodėl, `sudo systemctl restart facetimehd-firmware-fetcher` bando dar kartą, o perkrovimas įkelia tvarkyklę, jei atsisiuntimas baigėsi, bet kameros vis dar nėra.

#### Įrenginiai su T1 lustu

Apple T1 lustas pristatytas 2016 m. pabaigoje ir naudotas tik pirmos kartos MacBook Pro modeliuose su Touch Bar.
- MacBook Pro, 13 colių (2016, du Thunderbolt 3 prievadai) – Modelis: A1706
- MacBook Pro, 13 colių (2016, keturi Thunderbolt 3 prievadai) – Modelis: A1708
- MacBook Pro, 15 colių (2016) – Modelis: A1707

#### Žinomos problemos

- Touch Bar neveikia
- Garsas neveikia

#### Įrenginiai su T2 lustu

Apple T2 Security Chip pristatytas 2017 m. T2 lustas buvo nutrauktas prasidėjus perėjimui prie Apple silicon (M serijos lustų) 2020 m.

- iMac Pro (2017) – Modelis: A1862
- MacBook Pro, 13 colių (2018, keturi Thunderbolt 3 prievadai) – Modelis: A1989
- MacBook Pro, 15 colių (2018) – Modelis: A1990
- MacBook Air (Retina, 13 colių, 2018) – Modelis: A1932
- Mac mini (2018) – Modelis: A1998
- MacBook Pro, 13 colių (2019, du Thunderbolt 3 prievadai) – Modelis: A2159
- MacBook Pro, 13 colių (2019, keturi Thunderbolt 3 prievadai) – Modelis: A2178
- MacBook Pro, 15 colių (2019) – Modelis: A1990
- iMac (Retina 5K, 27 colių, 2020) – Modelis: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro, 13 colių (2020, du Thunderbolt 3 prievadai) – Modelis: A2265
- MacBook Pro, 15 colių (2020) – Modelis: A1990

Šiuose modeliuose diegimo programa automatiškai nustato pataisytą `linux-t2` branduolį, T2 garso konfigūraciją, Apple Broadcom Wi-Fi/Bluetooth programinę aparatinę įrangą ir ventiliatoriaus valdymą per `t2fanrd`. Touch Bar veikia naudodamas branduolyje įtaisytą Boot Camp stiliaus palaikymą.

#### iMac Retina 5K (2017)

2017 m. 27 colių iMac neturi T2 lusto, todėl diegimo programa jį nustato kaip kitus Intel Mac.

- iMac (Retina 5K, 27 colių, 2017) – Modelis: A1419

#### Žinomos problemos

- Ekranas neveikia savo tikrąja 5120×2880 raiška: skydelis sudarytas iš dviejų plytelių, o standartinė tvarkyklė apšviečia tik vieną
- Garsas neveikia
- Ryškumo valdiklis neturi jokio poveikio
- Miego režimas pakabina kompiuterį; jį atgaivina tik maitinimo išjungimas ir įjungimas

Bendruomenės pataisymų programa šiam modeliui sutvarko ekraną, garsą ir ryškumą: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
