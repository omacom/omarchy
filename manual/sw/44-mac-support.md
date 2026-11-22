# Usaidizi wa Mac

## Omarchy kwa Apple Silicon

Omarchy kwa Apple Silicon ni suluhisho rasmi la Omacom, iliyotolewa kwa mara ya kwanza na Omarchy 4.5. Inasakinishwa kando ya macOS, na unachagua kati ya hizo mbili Mac yako inapoanza.

Umepokea arifa kuhusu Omarchy Mac? Nenda kwenye [Kutoka Omarchy Mac](#coming-from-omarchy-mac).

Inafanya kazi kwenye Mac hizi:

| Mac | Chipu |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Mac za M4 na mpya zaidi bado haziungwi mkono. Usaidizi wa M4 unajaribiwa kwenye chaneli ya edge na utakuja baadaye. Kisakinishi hukagua Mac yako kabla ya kubadilisha chochote.

Kwenye Mac yoyote ya Apple Silicon, ikijumuisha M4 na mpya zaidi, unaweza kuendesha Omarchy kwenye mashine pepe ukitumia [Try Omarchy](https://github.com/omacom/try-omarchy).

### Unachohitaji

- macOS 15 Sequoia au mpya zaidi, na akaunti ya msimamizi
- Nafasi tupu ya diski kwa ajili ya Omarchy. Kisakinishi hupendekeza ukubwa na hukuruhusu kuubadilisha.
- Nakala rudufu ya Mac yako, nishati, na muunganisho wa intaneti. Usakinishaji hupakua gigabaiti kadhaa.

### Kusakinisha

Unasakinisha kutoka macOS. Sakinisha Omarchy Installer ukitumia [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Au pakua Omarchy Installer mpya zaidi kutoka [ukurasa wake wa matoleo](https://github.com/omacom/omarchy-mac-installer/releases) na uifungue.

Kisakinishi hukagua Mac yako, hukuonyesha mpango, na hutengeneza nafasi kwa ajili ya Omarchy kwa kupunguza sehemu ya diski ya macOS. macOS hubaki kwenye diski na hakuna diski ya USB inayohitajika. Hatua ya kwanza ikikamilika, hukuongoza kukamilisha usanidi katika macOS Recovery: zima, shikilia kitufe cha kuwasha hadi "Loading startup options" ionekane, chagua Omarchy, na ufuate hatua.

Katika kuwasha kwa mara ya kwanza, Omarchy huomba nenosiri linalosimba diski yake kwa njia fiche. Hakuna ufunguo wa kurejesha: ukisahau nenosiri, faili zako za Omarchy haziwezi kurejeshwa.

Ili kubadilisha kati ya Omarchy na macOS baadaye, zima, kisha shikilia kitufe cha kuwasha hadi chaguo za kuanzisha zionekane na uchague moja.

### Kutoka Omarchy Mac

Omarchy Mac sasa ni sehemu ya Omarchy kwa Apple Silicon, na kila Mac iliyoiendesha inaungwa mkono. Usakinishaji wako wa sasa unaendelea kufanya kazi, na vifurushi vyake vya mfumo bado husasishwa, lakini haupati tena sasisho za Omarchy. Hakuna tarehe ya mwisho na hakuna uboreshaji wa mahali palepale: unatengeneza nakala rudufu, unaondoa usakinishaji wa zamani, unasakinisha upya, na unarejesha. Hatua 2 hadi 5 hufanyika katika macOS, kwa hiyo fungua ukurasa huu kwenye simu yako kabla ya kuanzisha upya.

1. **Tengeneza nakala rudufu kutoka Omarchy, nje ya Mac.** Kuondoa usakinishaji wa zamani huufuta, na macOS haiwezi kusoma diski ya Omarchy. Nakili folda yako ya nyumbani kwenye diski ya nje au kompyuta nyingine, ikijumuisha funguo za SSH na GPG, wasifu wa kivinjari na kazi ambayo haijasukumwa. Hifadhi orodha yako ya vifurushi ukitumia `pacman -Qqe > ~/packages.txt`. Tengeneza nakala rudufu ya macOS pia, kwa kuwa kuondoa na kusakinisha vyote hubadilisha ukubwa wa diski yake.
2. **Anzisha Mac yako katika macOS.** Zima, shikilia kitufe cha kuwasha hadi chaguo za kuanzisha zionekane, na uchague macOS.
3. **Sakinisha Omarchy Installer** kama inavyoonyeshwa katika [Kusakinisha](#installing).
4. **Ondoa usakinishaji wa zamani.** Fungua Omarchy Installer na uchague Installation > Remove Omarchy. Inaonyesha kitakachofutwa na hurudisha nafasi kwa macOS. Kama haitambui usakinishaji wako, husimama bila kubadilisha diski. Omba msaada katika [Discord](https://discord.gg/tXFUdasqhY) badala ya kufuta sehemu za diski kwa mkono, jambo linaloweza kufuta macOS.
5. **Sakinisha Omarchy kwa Apple Silicon** ukitumia kisakinishi.
6. **Rejesha faili zako.** Rudisha mipangilio yako kipande kimoja baada ya kingine badala ya kunakili `~/.config` yote juu ya chaguo-msingi mpya, kwa kuwa mipangilio ya zamani inaweza kuzibatilisha.

### Vizuri kujua

- Kwenye MacBook za M1 na M2, amka kutoka usingizini kwa kufungua kifuniko au kubonyeza kitufe cha kuwasha.
- Maswali au matatizo: uliza katika [Discord](https://discord.gg/tXFUdasqhY) yetu.

[README ya kisakinishi](https://github.com/omacom/omarchy-mac-installer#readme) inashughulikia chaneli za matoleo, kusasisha kisakinishi na kuondoa Omarchy.

## Mac za Intel

Katika jaribio rahisi, tuliweza kupata ongezeko la utendaji la 36% kwenye MacBook Pro ya 2019 kwa kusakinisha tu Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Kusakinisha Omarchy kwenye Mac

Omarchy kwa sasa inaunga mkono kuwa mfumo wa uendeshaji **pekee** uliosakinishwa. Wakati wa usakinishaji, diski itafutwa na MacOS haitaweza kuwashwa tena.

Bado unaweza kuirejesha baadaye kupitia Internet Recovery ukipenda.

Kwa ajili ya sehemu hii, tutachukulia kuwa tayari umepitia [Kuanza](02-getting-started.md) na diski yako ya USB iko tayari. Kama bado, endelea na ufanye hivyo sasa.

#### Zima Secure Boot

Ni muhimu kuzima Secure Boot ya Apple ili kuwasha USB inayoweza kuwashwa, pamoja na OS. Ili kuizima, fanya yafuatayo:

1. Zima Mac yako
2. Iwasha na _mara moja_ bonyeza na ushikilie Command-R hadi uone skrini ya upakiaji inaonekana
3. Chagua mtumiaji wako na uweke nenosiri lako ukiombwa
4. Ukiwa kwenye skrini ya urejeshaji, chagua **Utilities > Startup Security Utility** kutoka kwenye upau wa menyu
5. Weka nenosiri lako ukiombwa kujithibitisha
6. Chagua "No Security" kutoka kwenye chaguo za Secure Boot
7. Chagua "Allow booting from external or removable media" kutoka kwenye chaguo za External Boot

#### Anza Usakinishaji

1. Ingiza diski ya USB
2. Anzisha upya Mac yako na _mara moja_ bonyeza na ushikilie Option hadi uone skrini ya vifaa vya kuwasha
3. Chagua kifaa cha EFI Boot cha rangi ya machungwa
4. Endelea na [usakinishaji kama kawaida](02-getting-started.md)

Kisakinishi hugundua vifaa vya Mac na kutumia marekebisho yanayohitajika kiotomatiki: viendeshi na programu dhibiti za Broadcom Wi-Fi, kiendeshi cha kamera ya FaceTime HD kwenye mashine zenye Broadcom 1570 (programu dhibiti yake hupakuliwa kutoka Apple mara Mac inapokuwa mtandaoni, kwa kuwa kisakinishi hufanya kazi bila mtandao), kiendeshi cha kibodi cha SPI kwenye miundo ya MacBook inayokihitaji, na marekebisho ya kusitisha NVMe kwa miundo hiyo hiyo.

### Vikwazo Vinavyojulikana

Wanachama wa jamii wanaendelea kufanyia kazi suluhisho la changamoto hizi kwa hiyo kama hizi zinakusumbua, jiunge na #omarchy-on-other katika [Discord](https://discord.gg/tXFUdasqhY) yetu na uone kama kuna mbinu zozote za kisasa za kuzitatua.

#### FaceTime HD Camera

Kiendeshi cha kamera hukwamisha mashine kikipakiwa wakati Mac inapokuwa katika hibernation, kwa hiyo hupakuliwa kwanza. Hakiwezi kupakuliwa wakati programu ina kamera wazi, kwa hiyo hibernation hubatilishwa kwa arifa inayotaja programu: ifunge na uingie katika hibernation tena. Hiyo inajumuisha kuingia katika hibernation kiotomatiki betri ikiwa katika hali mbaya, na suspend-then-hibernate, ambayo hukataliwa kabla haijasitisha. Usitishaji wa kawaida hukataliwa na kiendeshi chenyewe wakati kamera iko wazi, bila arifa.

Programu dhibiti ya kamera hupakuliwa kutoka Apple, kwa hiyo kamera hufanya kazi tu mara Mac inapokuwa imekuwa mtandaoni. Upakuaji huanza wakati wa kuwasha na hujaribiwa tena kila dakika 15 wakati mtandao ndio tatizo; kama faili ya Apple imebadilika, husimama na hungoja sasisho la Omarchy. Kama kamera haionekani, `journalctl -u facetimehd-firmware-fetcher` hueleza kwa nini, `sudo systemctl restart facetimehd-firmware-fetcher` hujaribu tena, na kuwasha upya hupakia kiendeshi kama upakuaji umekamilika lakini kamera bado haipo.

#### Vifaa vyenye Chipu ya T1

Chipu ya Apple T1 ilianzishwa mwishoni mwa 2016 na ilitumiwa pekee katika miundo ya kizazi cha kwanza ya MacBook Pro yenye Touch Bar.
- MacBook Pro inchi 13 (2016, milango miwili ya Thunderbolt 3) – Muundo: A1706
- MacBook Pro inchi 13 (2016, milango minne ya Thunderbolt 3) – Muundo: A1708
- MacBook Pro inchi 15 (2016) – Muundo: A1707

#### Masuala Yanayojulikana

- Touch Bar haifanyi kazi
- Sauti haifanyi kazi

#### Vifaa vyenye Chipu ya T2

Chipu ya Usalama ya Apple T2 ilianzishwa mwaka 2017. Chipu ya T2 ilisitishwa na mpito kwenda Apple silicon (chipu za mfululizo wa M) kuanzia 2020.

- iMac Pro (2017) – Muundo: A1862
- MacBook Pro inchi 13 (2018, milango minne ya Thunderbolt 3) – Muundo: A1989
- MacBook Pro inchi 15 (2018) – Muundo: A1990
- MacBook Air (Retina, inchi 13, 2018) – Muundo: A1932
- Mac mini (2018) – Muundo: A1998
- MacBook Pro inchi 13 (2019, milango miwili ya Thunderbolt 3) – Muundo: A2159
- MacBook Pro inchi 13 (2019, milango minne ya Thunderbolt 3) – Muundo: A2178
- MacBook Pro inchi 15 (2019) – Muundo: A1990
- iMac (Retina 5K, inchi 27, 2020) – Muundo: A2115 (iMac20,1 na iMac20,2)
- MacBook Pro inchi 13 (2020, milango miwili ya Thunderbolt 3) – Muundo: A2265
- MacBook Pro inchi 15 (2020) – Muundo: A1990

Kwenye miundo hii, kisakinishi huweka kiotomatiki kerneli ya `linux-t2` iliyorekebishwa, usanidi wa sauti wa T2, programu dhibiti ya Broadcom Wi-Fi/Bluetooth ya Apple, na udhibiti wa feni kupitia `t2fanrd`. Touch Bar huendeshwa kwenye usaidizi wa mtindo wa Boot Camp uliojengwa ndani ya kerneli.

#### iMac Retina 5K (2017)

 iMac ya 2017 ya inchi 27 haina chipu ya T2, kwa hiyo kisakinishi huiweka kama Mac nyingine za Intel.

- iMac (Retina 5K, inchi 27, 2017) – Muundo: A1419

#### Masuala Yanayojulikana

- Onyesho haliendeshwi katika ubora wake asilia wa 5120×2880: paneli ni vigae viwili, na kiendeshi cha kawaida huwasha kimoja tu
- Sauti haifanyi kazi
- Kidhibiti cha mwangaza hakina athari
- Usingizi hukwamisha mashine; kuzima na kuwasha tu ndiko huirejesha

Kirekebishaji cha jamii kwa muundo huu hurekebisha onyesho, sauti na mwangaza: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
