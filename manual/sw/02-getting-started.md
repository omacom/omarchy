# Kuanza

Omarchy husakinishwa kwa kutumia ISO. Unaweza kuchagua kati ya usakinishaji wa diski nzima, unaotwaa kiendeshi chote, au usakinishaji wa nafasi tupu, unaoweka Omarchy katika nafasi ambayo haijatengewa kwenye kiendeshi — hivyo ndivyo unavyowasha pacha pamoja na Windows au OS nyingine (tazama [usakinishaji wa kuwasha pacha](50-dual-boot-install.md) — kumbuka kwamba utahitaji kuzima BitLocker katika Windows kwanza). Kwa vyovyote vile, usakinishaji kwa chaguo-msingi hutumia usimbaji fiche kamili, na chaguo la diski nzima litafuta kiendeshi kilichochaguliwa, kwa hivyo hakikisha umechukua nakala rudufu kabla ya kutumia kilichopo!

[Pakua ISO ya Omarchy](https://omarchy.org/) kwanza, iweke kwenye kijiti cha USB (tumia [Rufus](https://rufus.ie/) kwenye Windows, [balenaEtcher](https://etcher.balena.io/) kwenye Mac, au [caligula](https://github.com/ifd3f/caligula) kwenye Linux), kisha uwashe kutoka kwenye kijiti hicho.

_Lazima uzime Secure Boot na/au TPM katika BIOS. Lazima uzime hivi ili uweze kusakinisha Omarchy. Ni mipango ya usalama ya Microsoft iliyokusudiwa kwa Windows na usambazaji wa Linux unaoshirikiana na Microsoft._

Kisha jibu maswali ya usanidi, na uyathibitishe kama hivi:

 ![install-config](images/install-config.webp)

Kisha chagua kiendeshi cha usakinishaji wako, kisha keti na uangalie onyesho la usakinishaji. Linaweza kukamilika kwa chini ya dakika moja kwenye mashine za kisasa zenye kasi zaidi, lakini halipaswi kuchukua zaidi ya dakika 5 hata kwenye kompyuta ya zamani.

 ![install-done](images/install-done.webp)

Sasa uko tayari kutumia Omarchy!

### Tumia kibodi yenye waya au ya 2.4ghz!

Usimbaji fiche wa diski nzima hautakuruhusu kuingiza nenosiri kutoka kwenye kibodi ya Bluetooth wakati wa kuwasha. Kama vile huwezi kutumia kibodi ya Bluetooth kuingia BIOS kwenye PC. Utahitaji kibodi inayotumia dongle ya 2.4ghz au kebo (ambayo ni nzuri zaidi kwa ucheleweshaji wa mawimbi hata hivyo!). Mimi binafsi napenda [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) sana!

### Kusakinisha kwa mmiliki mwingine

Ikiwa unaandaa mashine kwa ajili ya mtu mwingine — mwanafamilia, mfanyakazi mpya, mnunuzi — hupaswi kujibu maswali ya kibinafsi kwa niaba yao. Bonyeza `Ctrl + C` kwenye skrini ya kwanza kabisa ya kisakinishi (uchaguzi wa kibodi), na Omarchy itajitolea kuandaa mashine kwa mmiliki mwingine badala yake. Mfumo husakinishwa mara moja, lakini usanidi wote wa kibinafsi — mpangilio wa kibodi, jina la mtumiaji, nenosiri — huahirishwa hadi mashine itakapowashwa kwa mara ya kwanza. Kiendeshi bado kimesimbwa kwa fiche kwa chaguo-msingi, na nenosiri ambalo mmiliki mpya huchagua kwenye uwasaji huo wa kwanza huwa nenosiri la usimbaji fiche pia. (Mashine ambayo tayari umekuwa ukiitumia inaweza kukabidhiwa bila kusakinisha upya pia — tazama [kuweka upya kompyuta](48-security.md).)

### Usakinishaji usiohitaji msimamizi

ISO pia inaweza kusakinisha yenyewe kabisa — bila kibodi, bila mchawi wa usanidi — inapopewa usanidi wake kwenye kiendeshi cha pili. Hiyo ndiyo njia ya kuchukulia Omarchy kama taswira ya msingi kwa VM na mashine za kundi kubwa. Tazama [usakinishaji usiohitaji msimamizi](51-unattended-installs.md).

### Usakinishaji bila usimbaji fiche

Omarchy husakinishwa na usimbaji fiche kwa chaguo-msingi. Ni chaguo salama na la kuwajibika kwa kompyuta yoyote ambayo inaweza kupotea au kuibiwa. Hutaki mtu yeyote mwenye ufikiaji wa maunzi yako aweze kupata data yako!

Lakini katika mazingira maalum, kama usakinishaji wa mbali wa Omarchy kwenye kompyuta zilizolindwa au kwa usakinishaji wa kutupa bila data nyeti, unaweza kutaka kusakinisha bila usimbaji fiche. Unaweza kubonyeza `Ctrl + C` kwenye uthibitisho wa uumbizaji wa diski ili kubadili kwenda kwenye usakinishaji usio na usimbaji fiche.

### Lugha

Omarchy huzungumza lugha 50 — seti ile ile kama omarchy.org — na Kiingereza ndicho chaguo-msingi. Ili kubadilisha, fungua menyu ya Omarchy na uende _Setup > Region > Language_, au endesha `omarchy language <code>` kwenye terminali (`omarchy language list` huonyesha misimbo). Menyu, eneo-kazi, na arifa za Omarchy yenyewe hubadilisha lugha mara moja, na kila programu unayofungua baada ya hapo hufuata pia. Programu ambazo tayari zilikuwa wazi hubadilika mara tu unapoziwasha upya.

Ili kubakisha lugha lakini kuandika tarehe, saa, nambari, pesa, vipimo na ukubwa wa karatasi kama eneo jingine lifanyavyo (Kiingereza chenye tarehe za Ulaya na saa ya masaa 24, kwa mfano), chagua eneo chini ya _Setup > Region > Formats_, ambapo kila chaguo huonyesha sampuli, au endesha `omarchy region <code>` (`omarchy region list` huonyesha misimbo). _Same as language_ hurudi kwenye miundo ya lugha yenyewe. Kama kubadilisha lugha, hufikia programu unazofungua baada ya hapo.

### Msaada ukikwama

Ukikwama, kwa kawaida unaweza kupata mtu aliye tayari kusaidia katika chaneli ya _#omarchy-help_ kwenye [Discord ya jamii](https://omarchy.org/discord).
