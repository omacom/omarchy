# Mac palaikymas

Omarchy turi įmontuotą palaikymą **Intel Macams**. Šiuo metu yra pora žinomų apribojimų, bet kol žinai juos ir tau jie tinka, gali įkvėpti naujos gyvybės savo seniems Macams įkeldamas Omarchy.

Atkreipk dėmesį, kad įdiegimas M serijos Mac šiuo metu tiesiogiai nepalaikomas. Daugiau apie šios būsenos padėtį sužinosi #omarchy-on-other mūsų [Discord](https://discord.gg/tXFUdasqhY).

Paprastame teste vien įdiegę Omarchy 2019 MacBook Pro pasiekėme 36% našumo prieaugį.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy įdiegimas Mac

Omarchy šiuo metu palaiko buvimą **vienintele** įdiegta OS. Įdiegimo metu diskas bus išvalytas ir MacOS nebebus galima įkrauti.

Jei norėsi, vėliau vis tiek galėsi ją atkurti per Internet Recovery.

Šioje dalyje laikysime, kad jau peržiūrėjai [Darbo pradžią](02-getting-started.md) ir turi paruoštą USB diską. Jei ne, padaryk tai dabar.

#### Secure Boot išjungimas

Būtina išjungti Apple Secure Boot, kad būtų galima įkrauti įkraunamą USB, taip pat ir OS. Kad jį išjungtum, atlik šiuos veiksmus:

1. Išjunk Mac
2. Įjunk jį ir _nedelsdamas_ paspausk ir laikyk Command-R, kol pamatysi atsirandantį įkėlimo ekraną
3. Pasirink savo vartotoją ir, jei prašoma, įvesk slaptažodį
4. Atkūrimo ekrane meniu juostoje pasirink **Utilities > Startup Security Utility**
5. Įvesk slaptažodį, kai būsi paragintas patvirtinti tapatybę
6. Iš Secure Boot parinkčių pasirink „No Security"
7. Iš External Boot parinkčių pasirink „Allow booting from external or removable media"

#### Įdiegimo pradžia

1. Įkišk USB diską
2. Perkrauk Mac ir _nedelsdamas_ paspausk ir laikyk Option, kol pamatysi įkrovos įrenginių ekraną
3. Pasirink oranžinį EFI Boot įrenginį
4. Tęsk [įdiegimą kaip įprastai](02-getting-started.md)

Įdiegyklė aptinka Mac aparatinę įrangą ir automatiškai pritaiko reikalingus pataisymus: Broadcom Wi-Fi tvarkykles ir mikroprograminę įrangą, SPI klaviatūros tvarkyklę MacBook modeliuose, kuriems jos reikia, ir NVMe pristabdymo pataisą tiems patiems modeliams.

### Žinomi apribojimai

Bendruomenės nariai nuolat dirba prie šių iššūkių sprendimų, todėl jei tau jie kelia problemų, prisijunk prie #omarchy-on-other mūsų [Discord](https://discord.gg/tXFUdasqhY) ir pažiūrėk, ar yra naujausių jų sprendimo metodų.

#### Įrenginiai su T1 lustu

Apple T1 lustas buvo pristatytas 2016 m. pabaigoje ir naudotas išskirtinai pirmos kartos MacBook Pro modeliuose su Touch Bar.
- MacBook Pro 13-inch (2016, du Thunderbolt 3 prievadai) – modelis: A1706
- MacBook Pro 13-inch (2016, keturi Thunderbolt 3 prievadai) – modelis: A1708
- MacBook Pro 15-inch (2016) – modelis: A1707

#### Žinomos problemos

- Touch Bar neveikia
- Garsas neveikia

#### Įrenginiai su T2 lustu

Apple T2 saugos lustas buvo pristatytas 2017 m. T2 lustas buvo nutrauktas pereinant prie Apple silicon (M serijos lustų) nuo 2020 m.

- iMac Pro (2017) – modelis: A1862
- MacBook Pro 13-inch (2018, keturi Thunderbolt 3 prievadai) – modelis: A1989
- MacBook Pro 15-inch (2018) – modelis: A1990
- MacBook Air (Retina, 13-inch, 2018) – modelis: A1932
- Mac mini (2018) – modelis: A1998
- MacBook Pro 13-inch (2019, du Thunderbolt 3 prievadai) – modelis: A2159
- MacBook Pro 13-inch (2019, keturi Thunderbolt 3 prievadai) – modelis: A2178
- MacBook Pro 15-inch (2019) – modelis: A1990
- iMac (Retina 5K, 27-inch, 2020) – modelis: A2115 (iMac20,1 ir iMac20,2)
- MacBook Pro 13-inch (2020, du Thunderbolt 3 prievadai) – modelis: A2265
- MacBook Pro 15-inch (2020) – modelis: A1990

Šiuose modeliuose įdiegyklė automatiškai nustato pataisytą `linux-t2` branduolį, T2 garso konfigūraciją, Apple Broadcom Wi-Fi/Bluetooth mikroprograminę įrangą ir ventiliatoriaus valdymą per `t2fanrd`. Touch Bar veikia branduolyje įmontuotame Boot Camp stiliaus palaikyme.
