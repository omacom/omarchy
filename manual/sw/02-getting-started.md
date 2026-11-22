# Kuanza

Omarchy husakinishwa kwa kutumia ISO. Unaweza kuchagua kati ya usakinishaji wa diski nzima, ambao huchukua kiendeshi kizima, au usakinishaji wa nafasi tupu, ambao huweka Omarchy katika nafasi ambayo haijatengwa kwenye kiendeshi — hivyo ndivyo unavyowasha sambamba na Windows au OS nyingine (tazama [usakinishaji wa kuwasha sambamba](50-dual-boot-install.md) — kumbuka kuwa utahitaji kuzima BitLocker kwenye Windows kwanza). Kwa vyovyote vile, usakinishaji huwa na usimbaji fiche kamili kwa chaguo-msingi, na chaguo la diski nzima litafuta kiendeshi kilichochaguliwa, kwa hivyo hakikisha umehifadhi nakala kabla ya kutumia kilichopo!

Kwenye Apple Silicon Mac, husakinisha kutoka macOS badala yake, bila ISO wala kijiti cha USB. Tazama [Omarchy for Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Pakua Omarchy ISO](https://omarchy.org/) kwanza, iweke kwenye kijiti cha USB (tumia [Rufus](https://rufus.ie/) kwenye Windows, [balenaEtcher](https://etcher.balena.io/) kwenye Mac, au [caligula](https://github.com/ifd3f/caligula) kwenye Linux), na uwashe kutoka kwenye kijiti hicho.

_Lazima uzime Secure Boot na/au TPM kwenye BIOS. Lazima uzime hivi ili uweze kusakinisha Omarchy. Ni mipango ya usalama ya Microsoft iliyokusudiwa kwa Windows na usambazaji wa Linux unaoshirikiana na Microsoft._

Kisha jibu maswali ya usanidi, na uyathibitishe kama hivi:

 ![install-config](images/install-config.webp)

Kisha chagua kiendeshi kwa ajili ya usakinishaji wako, na ukae utazame onyesho la usakinishaji likiendelea. Inaweza kukamilika chini ya dakika moja kwenye mashine za kisasa zenye kasi zaidi, lakini haipaswi kuchukua zaidi ya dakika 5 hata kwenye kompyuta ya zamani.

 ![install-done](images/install-done.webp)

Sasa uko tayari kwa Omarchy!

### Tumia kibodi ya waya au ya 2.4ghz!

Usimbaji fiche wa diski nzima hautakuruhusu kuingiza nenosiri kutoka kwenye kibodi ya Bluetooth wakati wa kuwasha. Kama vile huwezi kutumia kibodi ya Bluetooth kuingia kwenye BIOS kwenye PC. Utahitaji kibodi ambayo ama hutumia dongle ya 2.4ghz au kebo (ambayo ni bora zaidi kwa ucheleweshaji hata hivyo!). Mimi binafsi ninaipenda sana [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Kusakinisha kwa ajili ya mmiliki mwingine

Ikiwa unaandaa mashine kwa ajili ya mtu mwingine — mwanafamilia, mfanyakazi mpya, mnunuzi — hupaswi kujibu maswali ya kibinafsi kwa niaba yao. Bonyeza `Ctrl + C` kwenye skrini ya kwanza kabisa ya kisakinishi (uchaguzi wa kibodi), na Omarchy itajitolea kuandaa mashine kwa ajili ya mmiliki mwingine badala yake. Mfumo husakinishwa mara moja, lakini usanidi wote wa kibinafsi — mpangilio wa kibodi, jina la mtumiaji, nenosiri — huahirishwa hadi mashine iwashwe kwa mara ya kwanza. Kiendeshi bado kimesimbwa kwa fiche kwa chaguo-msingi, na nenosiri ambalo mmiliki mpya huchagua kwenye uanzishaji huo wa kwanza huwa nenosiri la usimbaji fiche pia. (Mashine ambayo tayari umekuwa ukiitumia inaweza kukabidhiwa bila kusakinisha upya pia — tazama [kuweka upya kompyuta](48-security.md).)

### Usakinishaji usiohitaji usimamizi

ISO pia inaweza kusakinisha kabisa yenyewe — bila kibodi, bila mchawi — inapopewa usanidi wake kwenye kiendeshi cha pili. Hiyo ndiyo njia ya kuchukulia Omarchy kama taswira msingi kwa VM na mashine za kundi. Tazama [usakinishaji usiohitaji usimamizi](51-unattended-installs.md).

### Usakinishaji bila usimbaji fiche

Omarchy husakinishwa ikiwa na usimbaji fiche kwa chaguo-msingi. Ni chaguo salama, la kuwajibika kwa kompyuta yoyote ambayo inaweza kupotea au kuibiwa. Hutaki mtu yeyote mwenye ufikiaji wa maunzi yako aweze kupata data yako!

Lakini katika mazingira maalum, kama usakinishaji wa mbali wa Omarchy kwenye kompyuta zilizolindwa au kwa usakinishaji wa kutupwa baada ya matumizi usio na data nyeti, unaweza kutaka kusakinisha bila usimbaji fiche. Unaweza kubonyeza `Ctrl + C` kwenye uthibitisho wa uumbizaji wa diski ili kubadili kwenda kwenye usakinishaji usio na usimbaji fiche.

### Lugha

Omarchy huzungumza lugha 50 — seti ile ile kama omarchy.org — na Kiingereza ndicho chaguo-msingi. Ili kubadili, fungua menyu ya Omarchy na uende kwenye _Setup > Region > Language_, au endesha `omarchy language <code>` kwenye terminali (`omarchy language list` huonyesha misimbo). Menyu, eneo-kazi, na arifa za Omarchy yenyewe hubadilisha lugha mara moja, na kila programu unayofungua baada ya hapo hufuata pia. Programu ambazo tayari zilikuwa zimefunguliwa hubadilika mara tu unapoziwasha upya.

Ili kuhifadhi lugha lakini kuandika tarehe, nyakati, namba, pesa, vipimo na ukubwa wa karatasi jinsi eneo lingine linavyofanya (Kiingereza chenye tarehe za Ulaya na saa ya masaa 24, tuseme), chagua eneo chini ya _Setup > Region > Formats_, ambapo kila chaguo huonyesha sampuli, au endesha `omarchy region formats <code>` (`omarchy region formats list` huonyesha misimbo). _Same as language_ hurudi kwenye miundo ya lugha yenyewe. Kama ubadilishaji wa lugha, hufikia programu unazofungua baada ya hapo.

### Msaada ukikwama

Ukiwa umekwama, kwa kawaida unaweza kupata mtu aliye tayari kusaidia katika kituo cha _#omarchy-help_ kwenye [Discord ya jamii](https://omarchy.org/discord).
