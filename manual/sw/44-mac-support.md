# Usaidizi wa Mac

## Omarchy kwa Apple Silicon

Omarchy kwa Apple Silicon ni suluhisho rasmi la Omacom, lililotolewa kwa mara ya kwanza na Omarchy 4.5. Husakinishwa kando ya macOS, na unachagua kati ya hizo mbili Mac yako inapoanza.

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

Mac za M4 na mpya zaidi bado haziauniwi. Usaidizi wa M4 unajaribiwa kwenye kituo cha edge na unakuja baadaye. Kisakinishi hukagua Mac yako kabla ya kubadilisha chochote.

Kwenye Mac yoyote ya Apple Silicon, ikiwemo M4 na mpya zaidi, unaweza kuendesha Omarchy katika mashine pepe kwa [Jaribu Omarchy](https://github.com/omacom/try-omarchy).

### Unachohitaji

- macOS 15 Sequoia au mpya zaidi, na akaunti ya msimamizi
- Nafasi tupu ya diski kwa ajili ya Omarchy. Kisakinishi kinapendekeza ukubwa na kinakuruhusu kuubadilisha.
- Hifadhi nakala ya Mac yako, umeme, na muunganiko wa intaneti. Usakinishaji hupakua gigabaiti kadhaa.

### Kusakinisha

Unasakinisha kutoka macOS. Sakinisha Omarchy Installer kwa [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Au pakua Omarchy Installer mpya zaidi kutoka [ukurasa wake wa matoleo](https://github.com/omacom/omarchy-mac-installer/releases) na uifungue.

Kisakinishi hukagua Mac yako, hukuonyesha mpango, na kutengeneza nafasi kwa ajili ya Omarchy kwa kupunguza kizigeu cha macOS. macOS hubaki kwenye diski na hakuna kiendeshi cha USB kinachohitajika. Hatua ya kwanza ikikamilika, hukuongoza kukamilisha usanidi katika macOS Recovery: zima, shikilia kitufe cha kuwasha hadi "Loading startup options" ionekane, chagua Omarchy, na ufuate hatua.

Kwanza kuwasha, Omarchy huomba nenosiri linalosimba diski yake kwa njia fiche. Hakuna ufunguo wa kurejesha: ukisahau nenosiri, faili zako za Omarchy haziwezi kurejeshwa.

Ili kubadilisha kati ya Omarchy na macOS baadaye, zima, kisha shikilia kitufe cha kuwasha hadi chaguo za kuanzisha zionekane na uchague moja.

### Kutoka Omarchy Mac

Omarchy Mac sasa ni sehemu ya Omarchy kwa Apple Silicon, na kila Mac iliyoiendesha inaauniwa. Usakinishaji wako wa sasa unaendelea kufanya kazi, na vifurushi vyake vya mfumo bado vinapata masasisho, lakini haupati tena masasisho ya Omarchy. Hakuna tarehe ya mwisho na hakuna uboreshaji wa mahali palepale: unahifadhi nakala, unaondoa usakinishaji wa zamani, unasakinisha upya, na unarejesha. Hatua za 2 hadi 5 hufanyika katika macOS, kwa hivyo fungua ukurasa huu kwenye simu yako kabla ya kuwasha upya.

1. **Hifadhi nakala kutoka Omarchy, nje ya Mac.** Kuondoa usakinishaji wa zamani huufuta, na macOS haiwezi kusoma diski ya Omarchy. Nakili folda yako ya nyumbani kwenye kiendeshi cha nje au kompyuta nyingine, ikiwemo funguo za SSH na GPG, wasifu wa kivinjari na kazi ambayo haijasukumwa. Hifadhi orodha yako ya vifurushi kwa `pacman -Qqe > ~/packages.txt`. Hifadhi nakala ya macOS pia, kwa kuwa kuondoa na kusakinisha vyote hubadilisha ukubwa wa diski yake.
2. **Anzisha Mac yako katika macOS.** Zima, shikilia kitufe cha kuwasha hadi chaguo za kuanzisha zionekane, na uchague macOS.
3. **Sakinisha Omarchy Installer** kama inavyoonyeshwa katika [Kusakinisha](#installing).
4. **Ondoa usakinishaji wa zamani.** Fungua Omarchy Installer na uchague Installation > Remove Omarchy. Huonyesha kitakachofuta na kurejesha nafasi kwa macOS. Kama haitambui usakinishaji wako, husimama bila kubadilisha diski. Omba usaidizi katika [Discord](https://discord.gg/tXFUdasqhY) badala ya kufuta vizigeu kwa mkono, jambo linaloweza kufuta macOS.
5. **Sakinisha Omarchy kwa Apple Silicon** kwa kisakinishi.
6. **Rejesha faili zako.** Rejesha mipangilio yako kipande kimoja kwa wakati badala ya kunakili `~/.config` yote juu ya chaguo-msingi mpya, kwa kuwa mipangilio ya zamani inaweza kuzibatilisha.

### Vizuri kufahamu

- Kwenye MacBook za M1 na M2, amka kutoka usingizini kwa kufungua kifuniko au kubonyeza kitufe cha kuwasha.
- Maswali au matatizo: uliza katika [Discord](https://discord.gg/tXFUdasqhY) yetu.

[README ya kisakinishi](https://github.com/omacom/omarchy-mac-installer#readme) inazungumzia vituo vya matoleo, kusasisha kisakinishi na kuondoa Omarchy.

## Mac za Intel

Katika jaribio rahisi, tuliweza kupata ongezeko la utendaji la 36% kwenye MacBook Pro ya 2019 kwa kusakinisha Omarchy tu.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Kusakinisha Omarchy kwenye Mac

Omarchy kwa sasa inaauni kuwa **pekee** OS iliyosakinishwa tu. Wakati wa usakinishaji, kiendeshi kitafutwa na MacOS haitaweza kuwashwa tena.

Bado unaweza kuirejesha baadaye kupitia Internet Recovery ukipenda.

Kwa ajili ya sehemu hii, tutachukulia kuwa tayari umekagua [Kuanza](02-getting-started.md) na kiendeshi chako cha USB kiko tayari. Kama bado, endelea na ufanye hivyo sasa.

#### Zima Secure Boot

Ni lazima kuzima Secure Boot ya Apple ili kuwasha USB inayoweza kuwashwa, pamoja na OS. Ili kuizima, fanya yafuatayo:

1. Zima Mac yako
2. Iwasha na _mara moja_ bonyeza na ushikilie Command-R hadi uone skrini ya kupakia ikionekana
3. Chagua mtumiaji wako na uweke nenosiri lako ukiombwa
4. Ukiwa katika skrini ya urejeshaji, chagua **Utilities > Startup Security Utility** kutoka kwenye upau wa menyu
5. Weka nenosiri lako ukiombwa kujithibitisha
6. Chagua "No Security" kutoka kwenye chaguo za Secure Boot
7. Chagua "Allow booting from external or removable media" kutoka kwenye chaguo za External Boot

#### Anza Usakinishaji

1. Ingiza kiendeshi cha USB
2. Washa upya Mac yako na _mara moja_ bonyeza na ushikilie Option hadi uone skrini ya vifaa vya kuwasha
3. Chagua kifaa cha rangi ya machungwa cha EFI Boot
4. Endelea na [usakinishaji kama kawaida](02-getting-started.md)

Kisakinishi hutambua maunzi ya Mac na kutumia marekebisho yanayohitajika kiotomatiki: viendeshi na programu dhibiti za Broadcom Wi-Fi, kiendeshi cha kibodi cha SPI kwenye miundo ya MacBook inayokihitaji, na marekebisho ya kusitisha ya NVMe kwa miundo hiyo hiyo.

### Vikwazo Vinavyojulikana

Wanachama wa jamii wanaendelea kufanyia kazi suluhisho za changamoto hizi kwa hivyo kama hizi zinakusumbua, jiunge na #omarchy-on-other katika [Discord](https://discord.gg/tXFUdasqhY) yetu na uone kama kuna mbinu zozote za kisasa za kuzitatua.

#### Vifaa vyenye Chipu ya T1

Chipu ya Apple T1 ilianzishwa mwishoni mwa 2016 na ilitumika pekee katika miundo ya kizazi cha kwanza ya MacBook Pro yenye Touch Bar.
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

Kwenye miundo hii, kisakinishi huweka kiotomatiki kerneli ya `linux-t2` iliyobandikwa, usanidi wa sauti wa T2, programu dhibiti ya Broadcom Wi-Fi/Bluetooth ya Apple, na udhibiti wa feni kupitia `t2fanrd`. Touch Bar huendeshwa kwenye usaidizi wa mtindo wa Boot Camp uliojengewa ndani ya kerneli.

#### iMac Retina 5K (2017)

iMac ya 2017 ya inchi 27 haina chipu ya T2, kwa hivyo kisakinishi huiweka kama Mac nyingine za Intel.

- iMac (Retina 5K, inchi 27, 2017) – Muundo: A1419

#### Masuala Yanayojulikana

- Onyesho haliendeshwi katika azimio lake asilia la 5120×2880: paneli ni vigae viwili, na kiendeshi cha kawaida huwasha kimoja tu
- Sauti haifanyi kazi
- Udhibiti wa mwangaza hauna athari yoyote
- Usingizi huikwamisha mashine; kuzima na kuwasha tu ndiko huirejesha

Kibandiko cha jamii kwa muundo huu hurekebisha onyesho, sauti na mwangaza: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
