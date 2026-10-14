# Usaidizi wa Mac

Omarchy ina usaidizi uliojengwa ndani kwa **Mac za Intel**. Kuna mapungufu machache yanajulikana kwa sasa, lakini mradi unayafahamu na unakubaliana nayo; unaweza kuingiza uhai mpya katika Mac zako za zamani kwa kupakia Omarchy.

Tafadhali kumbuka kuwa kusakinisha kwenye Mac ya mfululizo wa M hakusaidiwi moja kwa moja kwa sasa. Unaweza kujua zaidi kuhusu hali ya hii katika #omarchy-on-other katika [Discord](https://discord.gg/tXFUdasqhY) yetu.

Katika jaribio rahisi, tuliweza kufikia ongezeko la utendaji la 36% kwenye MacBook Pro ya 2019 kwa kusakinisha Omarchy tu.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Kusakinisha Omarchy kwenye Mac

Omarchy inasaidia tu kuwa ndicho OS **pekee** iliyosakinishwa kwa sasa. Wakati wa usakinishaji, kiendeshaji kitafutwa na MacOS haitawashika tena.

Bado unaweza kuirejesha baadaye kupitia Internet Recovery kama unataka.

Kwa ajili ya sehemu hii, tutadhani kuwa tayari umepitia [Kuanza](02-getting-started.md) na una kiendeshaji chako cha USB tayari. Kama huna endelea na ufanye hivyo sasa.

#### Zima Secure Boot

Ni muhimu kuzima Secure Boot ya Apple ili kuwasha USB inayoweza kuwashwa, pamoja na OS. Kuizima, fanya yafuatayo:

1. Zima Mac yako
2. Iwashe na _mara moja_ bonyeza na ushikilie Command-R hadi uone skrini ya kupakia inaonekana
3. Chagua mtumiaji wako na uweke nenosiri lako ukiombwa
4. Mara ukiwa katika skrini ya urejesho, chagua **Utilities > Startup Security Utility** kutoka upau wa menyu
5. Weka nenosiri lako unapoulizwa kuthibitisha
6. Chagua "No Security" kutoka chaguo za Secure Boot
7. Chagua "Allow booting from external or removable media" kutoka chaguo za External Boot

#### Anzisha Usakinishaji

1. Ingiza kiendeshaji cha USB
2. Anzisha upya Mac yako na _mara moja_ bonyeza na ushikilie Option hadi uone skrini ya vifaa vya kuwasha
3. Chagua kifaa cha EFI Boot cha rangi ya chungwa
4. Endelea na [kusakinisha kama kawaida](02-getting-started.md)

Kisakinishaji hugundua vifaa vya Mac na kutumia marekebisho yanayohitajika kiotomatiki: viendeshaji vya Wi-Fi vya Broadcom na firmware, kiendeshaji cha kibodi cha SPI kwenye mifano ya MacBook inayokihitaji, na marekebisho ya kusitisha ya NVMe kwa mifano hiyo hiyo.

### Mapungufu Yanayojulikana

Wanachama wa jumuiya daima wanafanya kazi kutafuta suluhisho kwa changamoto hizi kwa hivyo kama hizi ni tatizo kwako, jiunge na #omarchy-on-other katika [Discord](https://discord.gg/tXFUdasqhY) yetu na uone kama kuna mbinu zozote za hivi karibuni za kuzitatua.

#### Vifaa vyenye Chip ya T1

Chip ya Apple T1 ilitambulishwa mwishoni mwa 2016 na kutumika pekee katika mifano ya MacBook Pro ya kizazi cha kwanza yenye Touch Bar.
- MacBook Pro inchi 13 (2016, porti mbili za Thunderbolt 3) – Modeli: A1706
- MacBook Pro inchi 13 (2016, porti nne za Thunderbolt 3) – Modeli: A1708
- MacBook Pro inchi 15 (2016) – Modeli: A1707

#### Matatizo Yanayojulikana

- Touch Bar haifanyi kazi
- Sauti haifanyi kazi

#### Vifaa vyenye Chip ya T2

Chip ya Usalama ya Apple T2 ilitambulishwa mwaka 2017. Chip ya T2 ilikomeshwa na mpito kwenda Apple silicon (chip za mfululizo wa M) kuanzia 2020.

- iMac Pro (2017) – Modeli: A1862
- MacBook Pro inchi 13 (2018, porti nne za Thunderbolt 3) – Modeli: A1989
- MacBook Pro inchi 15 (2018) – Modeli: A1990
- MacBook Air (Retina, inchi 13, 2018) – Modeli: A1932
- Mac mini (2018) – Modeli: A1998
- MacBook Pro inchi 13 (2019, porti mbili za Thunderbolt 3) – Modeli: A2159
- MacBook Pro inchi 13 (2019, porti nne za Thunderbolt 3) – Modeli: A2178
- MacBook Pro inchi 15 (2019) – Modeli: A1990
- iMac (Retina 5K, inchi 27, 2020) – Modeli: A2115 (iMac20,1 na iMac20,2)
- MacBook Pro inchi 13 (2020, porti mbili za Thunderbolt 3) – Modeli: A2265
- MacBook Pro inchi 15 (2020) – Modeli: A1990

Kwenye mifano hii, kisakinishaji husanidi kiotomatiki kerneli ya `linux-t2` iliyorekebishwa, usanidi wa sauti wa T2, firmware ya Wi-Fi/Bluetooth ya Broadcom ya Apple, na udhibiti wa feni kupitia `t2fanrd`. Touch Bar huendesha kwenye usaidizi wa kiunzi uliojengwa ndani wa mtindo wa Boot Camp.
