# Mac palaikymas

Omarchy turi integruotą **Intel Macs** palaikymą. Šiuo metu yra keletas žinomų apribojimų, bet jei juos žinote ir jie jums tinka, įdiegę Omarchy galite įpūsti naujos gyvybės savo seniems Mac kompiuteriams.

Atkreipkite dėmesį, kad diegimas M serijos Mac kompiuteriuose šiuo metu tiesiogiai nepalaikomas. Daugiau apie tai galite sužinoti #omarchy-on-other kanale mūsų [Discord](https://discord.gg/tXFUdasqhY).

Atlikdami paprastą testą, vien įdiegę Omarchy 2019 m. MacBook Pro sugebėjome pasiekti 36% našumo padidėjimą.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy diegimas Mac kompiuteryje

Omarchy šiuo metu palaiko tik buvimą **vienintele** įdiegta OS. Diegimo metu diskas bus išvalytas, ir MacOS nebebus galima paleisti.

Vėliau, jei norėsite, vis tiek galėsite ją atkurti naudodami Internet Recovery.

Šioje dalyje laikysime, kad jau peržiūrėjote [Darbo pradžią](02-getting-started.md) ir paruošėte USB diską. Jei to dar nepadarėte, padarykite tai dabar.

#### Secure Boot išjungimas

Norint paleisti paleidžiamąjį USB diską ir pačią OS, būtina išjungti Apple Secure Boot. Norėdami jį išjungti, atlikite šiuos veiksmus:

1. Išjunkite Mac kompiuterį
2. Įjunkite jį ir _nedelsdami_ paspauskite bei laikykite Command-R, kol pamatysite įkėlimo ekraną
3. Pasirinkite savo naudotoją ir, jei būsite paprašyti, įveskite slaptažodį
4. Patekę į atkūrimo ekraną, meniu juostoje pasirinkite **Utilities > Startup Security Utility**
5. Kai būsite paprašyti, įveskite slaptažodį, kad patvirtintumėte tapatybę
6. Secure Boot parinktyse pasirinkite „No Security“
7. External Boot parinktyse pasirinkite „Allow booting from external or removable media“

#### Diegimo pradžia

1. Įkiškite USB diską
2. Paleiskite Mac iš naujo ir _nedelsdami_ paspauskite bei laikykite Option, kol pamatysite paleidimo įrenginių ekraną
3. Pasirinkite oranžinį EFI Boot įrenginį
4. Tęskite [diegimą kaip įprasta](02-getting-started.md)

Diegimo programa aptinka Mac aparatinę įrangą ir automatiškai pritaiko reikiamus pataisymus: Broadcom Wi-Fi tvarkykles ir programinę aparatinę įrangą, SPI klaviatūros tvarkyklę MacBook modeliuose, kuriems jos reikia, ir NVMe pristabdymo pataisymą tiems patiems modeliams.

### Žinomi apribojimai

Bendruomenės nariai nuolat dirba spręsdami šiuos iššūkius, todėl, jei tai jums kelia problemų, prisijunkite prie #omarchy-on-other mūsų [Discord](https://discord.gg/tXFUdasqhY) ir pažiūrėkite, ar nėra naujausių būdų jiems išspręsti.

#### Įrenginiai su T1 lustu

Apple T1 lustas buvo pristatytas 2016 m. pabaigoje ir naudotas tik pirmosios kartos MacBook Pro modeliuose su Touch Bar.
- MacBook Pro 13 colių (2016, du Thunderbolt 3 prievadai) – Model: A1706
- MacBook Pro 13 colių (2016, keturi Thunderbolt 3 prievadai) – Model: A1708
- MacBook Pro 15 colių (2016) – Model: A1707

#### Žinomos problemos

- Touch Bar neveikia
- Garsas neveikia

#### Įrenginiai su T2 lustu

Apple T2 Security Chip buvo pristatytas 2017 m. T2 lustas buvo nebenaudojamas nuo 2020 m. pradėjus pereiti prie Apple silicon (M serijos lustų).

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13 colių (2018, keturi Thunderbolt 3 prievadai) – Model: A1989
- MacBook Pro 15 colių (2018) – Model: A1990
- MacBook Air (Retina, 13 colių, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13 colių (2019, du Thunderbolt 3 prievadai) – Model: A2159
- MacBook Pro 13 colių (2019, keturi Thunderbolt 3 prievadai) – Model: A2178
- MacBook Pro 15 colių (2019) – Model: A1990
- iMac (Retina 5K, 27 colių, 2020) – Model: A2115 (iMac20,1 ir iMac20,2)
- MacBook Pro 13 colių (2020, du Thunderbolt 3 prievadai) – Model: A2265
- MacBook Pro 15 colių (2020) – Model: A1990

Šiuose modeliuose diegimo programa automatiškai nustato pataisytą `linux-t2` branduolį, T2 garso konfigūraciją, Apple Broadcom Wi-Fi/Bluetooth programinę aparatinę įrangą ir ventiliatorių valdymą naudojant `t2fanrd`. Touch Bar veikia naudodama branduolyje integruotą Boot Camp stiliaus palaikymą.

#### iMac Retina 5K (2017)

2017 m. 27 colių iMac neturi T2 lusto, todėl diegimo programa jį nustato kaip ir kitus Intel Mac kompiuterius.

- iMac (Retina 5K, 27 colių, 2017) – Model: A1419

#### Žinomos problemos

- Ekranas neveikia savo savaimine 5120×2880 raiška: skydelis sudarytas iš dviejų dalių, o standartinė tvarkyklė įjungia tik vieną
- Garsas neveikia
- Ryškumo valdiklis neveikia
- Miego režimas pakabina kompiuterį; jį atgaivinti galima tik išjungus ir vėl įjungus maitinimą

Bendruomenės sukurtas šio modelio pataisymas sutvarko ekraną, garsą ir ryškumą: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
