# Usaidizi wa Mac

Omarchy ina usaidizi uliojengewa ndani kwa **Intel Macs**. Kuna mapungufu machache yanayojulikana kwa sasa, lakini mradi tu unayafahamu na uko sawa nayo; unaweza kuipa uhai mpya Mac zako za zamani kwa kupakia Omarchy.

Tafadhali kumbuka kuwa kusakinisha kwenye Mac ya mfululizo wa M hakusaidiwi moja kwa moja kwa sasa. Unaweza kujua zaidi kuhusu hali ya hili katika #omarchy-on-other katika [Discord](https://discord.gg/tXFUdasqhY) yetu.

Katika jaribio rahisi, tuliweza kupata ongezeko la utendaji la 36% kwenye MacBook Pro ya 2019 kwa kusakinisha tu Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Kusakinisha Omarchy kwenye Mac

Omarchy inasaidia tu kuwa **pekee** OS iliyosakinishwa kwa sasa. Wakati wa usakinishaji, diski itafutwa na MacOS haitaweza kuwashwa tena.

Bado unaweza kuirejesha baadaye kupitia Internet Recovery ukipenda.

Kwa ajili ya sehemu hii, tutachukulia kuwa tayari umepitia [Kuanza](02-getting-started.md) na diski yako ya USB iko tayari. Kama bado, endelea na ufanye hivyo sasa.

#### Zima Secure Boot

Inahitajika kuzima Secure Boot ya Apple ili kuwasha USB inayoweza kuwashwa, pamoja na OS. Ili kuizima, fanya yafuatayo:

1. Zima Mac yako
2. Iwashe na _mara moja_ bonyeza na ushikilie Command-R hadi uone skrini ya kupakia ikitokea
3. Chagua mtumiaji wako na uweke nenosiri lako ukiombwa
4. Ukiwa kwenye skrini ya uokoaji, chagua **Utilities > Startup Security Utility** kutoka kwenye menubar
5. Weka nenosiri lako unapoombwa kujithibitisha
6. Chagua "No Security" kutoka kwenye chaguo za Secure Boot
7. Chagua "Allow booting from external or removable media" kutoka kwenye chaguo za External Boot

#### Anza Usakinishaji

1. Ingiza diski ya USB
2. Anzisha upya Mac yako na _mara moja_ bonyeza na ushikilie Option hadi uone skrini ya vifaa vya kuwasha
3. Chagua kifaa cha rangi ya machungwa cha EFI Boot
4. Endelea na [sakinisha kama kawaida](02-getting-started.md)

Kisakinishi hugundua vifaa vya Mac na kutumia marekebisho yanayohitajika kiotomatiki: viendeshaji na firmware ya Broadcom Wi-Fi, kiendeshaji cha kibodi cha SPI kwenye modeli za MacBook zinazokihitaji, na marekebisho ya kusimamisha kwa NVMe kwa modeli hizo hizo.

### Mapungufu Yanayojulikana

Wanachama wa jumuiya wanafanya kazi kila mara kutafuta suluhisho za changamoto hizi, kwa hivyo kama hizi ni tatizo kwako, jiunge na #omarchy-on-other katika [Discord](https://discord.gg/tXFUdasqhY) yetu na uone kama kuna mbinu zozote za kisasa za kuzitatua.

#### Vifaa vyenye Chip ya T1

Chip ya Apple T1 ilianzishwa mwishoni mwa 2016 na kutumika pekee katika modeli za kizazi cha kwanza za MacBook Pro zenye Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Masuala Yanayojulikana

- Touch Bar haifanyi kazi
- Sauti haifanyi kazi

#### Vifaa vyenye Chip ya T2

Chip ya Usalama ya Apple T2 ilianzishwa mwaka 2017. Chip ya T2 ilisitishwa pamoja na mpito kwenda Apple silicon (chip za mfululizo wa M) kuanzia mwaka 2020.

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

Kwenye modeli hizi, kisakinishi huweka kiotomatiki kernel ya `linux-t2` iliyorekebishwa, usanidi wa sauti wa T2, firmware ya Apple ya Broadcom Wi-Fi/Bluetooth, na udhibiti wa feni kupitia `t2fanrd`. Touch Bar hufanya kazi kwa usaidizi uliojengewa ndani wa kernel wa mtindo wa Boot Camp.

#### iMac Retina 5K (2017)

IMac ya inchi 27 ya 2017 haina chip ya T2, kwa hivyo kisakinishi huiweka kama Mac nyingine za Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Masuala Yanayojulikana

- Skrini haifanyi kazi katika mwonekano wake asilia wa 5120×2880: paneli ni vigae viwili, na kiendeshaji cha kawaida huwasha kimoja tu
- Sauti haifanyi kazi
- Kidhibiti cha mwangaza hakina athari
- Kulala huigandisha mashine; ni kuzima na kuwasha upya tu ndiko kunakoiokoa

Kipachika cha jumuiya kwa modeli hii hurekebisha skrini, sauti na mwangaza: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
