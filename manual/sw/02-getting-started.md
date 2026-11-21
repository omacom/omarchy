# Kuanza

Omarchy husakinishwa kwa kutumia ISO. Unaweza kuchagua kati ya usakinishaji kwenye diski nzima, ambao huchukua hifadhi yote, au usakinishaji kwenye nafasi huru, ambao huweka Omarchy katika nafasi ambayo haijatengwa kwenye hifadhi — hivyo ndivyo unavyofanya dual boot pamoja na Windows au OS nyingine (tazama [usakinishaji wa dual-boot](50-dual-boot-install.md) — kumbuka kwamba utahitaji kuzima BitLocker katika Windows kwanza). Kwa vyovyote vile, usakinishaji huweka kwa chaguo-msingi usimbaji fiche kamili, na chaguo la diski nzima litafuta hifadhi iliyochaguliwa, kwa hivyo hakikisha umeweka nakala rudufu kabla ya kutumia iliyopo!

[Pakua ISO ya Omarchy](https://omarchy.org/) kwanza, iweke kwenye kijiti cha USB (tumia [Rufus](https://rufus.ie/) kwenye Windows, [balenaEtcher](https://etcher.balena.io/) kwenye Mac, au [caligula](https://github.com/ifd3f/caligula) kwenye Linux), na uwashe kutoka kwenye kijiti hicho.

_Lazima uzime Secure Boot na/au TPM katika BIOS. Lazima uzime hivi ili uweze kusakinisha Omarchy. Ni mipango ya usalama ya Microsoft iliyokusudiwa kwa Windows na usambazaji wa Linux unaohusiana na Microsoft._

Kisha jibu maswali ya usanidi, na uyathibitishe kama hivi:

 ![install-config](images/install-config.webp)

Kisha chagua hifadhi kwa ajili ya usakinishaji wako, na ukae utazame onyesho la usakinishaji. Inaweza kukamilika kwa chini ya dakika moja kwenye mashine za kisasa zenye kasi zaidi, lakini haipaswi kuchukua zaidi ya dakika 5 hata kwenye kompyuta ya zamani.

 ![install-done](images/install-done.webp)

Sasa uko tayari kwa Omarchy!

### Tumia kibodi yenye waya au ya 2.4ghz!

Usimbaji fiche wa diski nzima hautakuruhusu kuingiza nenosiri kutoka kwenye kibodi ya Bluetooth wakati wa kuwasha. Kama vile huwezi kutumia kibodi ya Bluetooth kuingia kwenye BIOS kwenye PC. Utahitaji kibodi ambayo ama hutumia dongle ya 2.4ghz au kebo (ambayo ni nzuri zaidi kwa latency hata hivyo!). Mimi binafsi napenda [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Kusakinisha kwa ajili ya mmiliki mwingine

Ikiwa unaandaa mashine kwa ajili ya mtu mwingine — mwanafamilia, mfanyakazi mpya, mnunuzi — hupaswi kujibu maswali ya binafsi kwa niaba yao. Bonyeza `Ctrl + C` kwenye skrini ya kwanza kabisa ya kisakinishi (uchaguzi wa kibodi), na Omarchy itajitolea kuandaa mashine kwa ajili ya mmiliki mwingine badala yake. Mfumo husakinishwa mara moja, lakini usanidi wote wa binafsi — mpangilio wa kibodi, jina la mtumiaji, nenosiri — huahirishwa hadi mashine iwashwe kwa mara ya kwanza. Hifadhi bado imesimbwa kwa chaguo-msingi, na nenosiri ambalo mmiliki mpya huchagua kwenye kuwasha huko kwa kwanza huwa nenosiri la usimbaji fiche pia. (Mashine ambayo tayari umekuwa ukiitumia inaweza kukabidhiwa bila kusakinisha upya pia — tazama [kuweka upya kompyuta](48-security.md).)

### Usakinishaji usiohitaji usimamizi

ISO pia inaweza kusakinisha kabisa yenyewe — bila kibodi, bila wizard — inapopewa usanidi wake kwenye hifadhi ya pili. Hiyo ndiyo njia ya kuchukulia Omarchy kama taswira ya msingi kwa VM na mashine za kundi. Tazama [usakinishaji usiohitaji usimamizi](51-unattended-installs.md).

### Usakinishaji bila usimbaji fiche

Omarchy husakinishwa ikiwa na usimbaji fiche kwa chaguo-msingi. Ni chaguo salama, lenye uwajibikaji kwa kompyuta yoyote ambayo inaweza kupotea au kuibiwa. Hutaki mtu yeyote mwenye ufikiaji wa vifaa vyako aweze kupata data yako!

Lakini katika mazingira maalum, kama usakinishaji wa mbali wa Omarchy kwenye kompyuta zilizolindwa au kwa usakinishaji wa kutupa bila data nyeti, unaweza kutaka kusakinisha bila usimbaji fiche. Unaweza kubonyeza `Ctrl + C` kwenye uthibitisho wa uumbizaji wa diski ili kubadili kwenda kwenye usakinishaji usio na usimbaji fiche.

### Lugha

Omarchy huzungumza lugha 50 — seti ile ile kama omarchy.org — na Kiingereza ndicho chaguo-msingi. Kubadili, fungua menyu ya Omarchy na uende kwenye _Usanidi > Eneo > Lugha_, au endesha `omarchy language <code>` katika terminali (`omarchy language list` huonyesha misimbo). Menyu, eneo-kazi, na arifa za Omarchy yenyewe hubadili lugha mara moja, na kila programu unayofungua baada ya hapo hufuata pia. Programu ambazo tayari zilikuwa zimefunguliwa hubadili mara unapoziwasha upya.

Ili kuweka lugha lakini kuandika tarehe, nyakati, nambari, pesa, vipimo na ukubwa wa karatasi jinsi eneo lingine linavyofanya (Kiingereza chenye tarehe za Ulaya na saa ya saa 24, kwa mfano), chagua eneo chini ya _Usanidi > Eneo > Miundo_, ambapo kila chaguo huonyesha sampuli, au endesha `omarchy region formats <code>` (`omarchy region formats list` huonyesha misimbo). _Sawa na lugha_ hurudi kwenye miundo ya lugha yenyewe. Kama kubadili lugha, hufikia programu unazofungua baada ya hapo.

### Usaidizi ikiwa umekwama

Ikiwa umekwama, kwa kawaida unaweza kupata mtu aliye tayari kusaidia katika chaneli ya _#omarchy-help_ kwenye [Discord ya jumuiya](https://omarchy.org/discord).
