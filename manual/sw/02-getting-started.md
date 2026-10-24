# Kuanza

Omarchy husakinishwa kwa kutumia ISO. Unaweza kuchagua kati ya usakinishaji wa diski kamili, ambao huchukua hifadhi nzima, au usakinishaji wa nafasi iliyokuwa wazi, ambao huweka Omarchy katika nafasi ambayo haijagawiwa kwenye hifadhi — hivyo ndivyo unavyowasha mara mbili pamoja na Windows au OS nyingine (tazama [usakinishaji wa kuwasha mara mbili](50-dual-boot-install.md) — kumbuka kwamba utahitaji kuzima BitLocker katika Windows kwanza). Vyovyote vile, usakinishaji huwa na usimbaji fiche kamili kwa chaguo-msingi, na chaguo la diski kamili litafuta hifadhi iliyochaguliwa, kwa hiyo hakikisha unachukua nakala rudufu kabla ya kutumia iliyopo!

[Pakua ISO ya Omarchy](https://omarchy.org/) kwanza, iweke kwenye kifimbo cha USB (tumia [balenaEtcher](https://etcher.balena.io/) kwenye Mac/Windows au [caligula](https://github.com/ifd3f/caligula) kwenye Linux), na anza kuwasha kutoka kwenye kifimbo.

_Lazima uzime Secure Boot na/au TPM katika BIOS. Lazima uzime hivi ili uweze kusakinisha Omarchy. Ni mipango ya usalama ya Microsoft iliyokusudiwa kwa ajili ya Windows na usambazaji wa Linux unaoshirikiana na Microsoft._

Kisha jibu maswali ya usanidi, na uyathibitishe kama hivi:

 ![install-config](images/install-config.webp)

Kisha chagua hifadhi kwa ajili ya usakinishaji wako, na ukae utulie na uangalie onyesho la usakinishaji likiendelea. Linaweza kukamilika kwa chini ya dakika moja kwenye mashine za kisasa zenye kasi zaidi, lakini halipaswi kuchukua zaidi ya dakika 5 hata kwenye kompyuta ya zamani.

 ![install-done](images/install-done.webp)

Sasa uko tayari kwa Omarchy!

### Tumia kibodi yenye waya au ya 2.4ghz!

Usimbaji fiche wa diski kamili hautakuruhusu kuingiza nenosiri kutoka kwenye kibodi ya Bluetooth wakati wa kuanza. Kama tu huwezi kutumia kibodi ya Bluetooth kuingia BIOS kwenye PC. Utahitaji kibodi ambayo ama hutumia dongle ya 2.4ghz au kebo (ambayo ni bora zaidi kwa ucheleweshaji hata hivyo!). Mimi binafsi naipenda sana [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Kusakinisha kwa ajili ya mmiliki mwingine

Ikiwa unatayarisha mashine kwa ajili ya mtu mwingine — mwanafamilia, mfanyakazi mpya, mnunuzi — hupaswi kujibu maswali ya kibinafsi kwa niaba yao. Bonyeza `Ctrl + C` kwenye skrini ya kwanza kabisa ya kisakinishi (uteuzi wa kibodi), na Omarchy itaomba kutayarisha mashine kwa ajili ya mmiliki mwingine badala yake. Mfumo husakinishwa mara moja, lakini maandalizi yote ya kibinafsi — mpangilio wa kibodi, jina la mtumiaji, nenosiri — huahirishwa hadi mashine itakapowashwa kwa mara ya kwanza. Hifadhi bado imesimbwa kwa njia fiche kwa chaguo-msingi, na nenosiri ambalo mmiliki mpya hulichagua kwenye uwasishaji huo wa kwanza pia huwa nenosiri la usimbaji fiche. (Mashine ambayo tayari umekuwa ukiitumia inaweza pia kukabidhiwa bila kusakinisha upya — tazama [kuweka upya kompyuta](48-security.md).)

### Usakinishaji usiosimamiwa

ISO inaweza pia kujisakinisha kabisa yenyewe — bila kibodi, bila mwongozo wa usakinishaji — inapopewa usanidi wake kwenye hifadhi ya pili. Hiyo ndiyo njia ya kuchukulia Omarchy kama picha ya msingi kwa ajili ya VM na mashine za kundi. Tazama [usakinishaji usiosimamiwa](51-unattended-installs.md).

### Usakinishaji bila usimbaji fiche

Omarchy husakinishwa na usimbaji fiche kwa chaguo-msingi. Ni chaguo salama na la kuwajibika kwa kompyuta yoyote ambayo inaweza kupotea au kuibiwa. Hutaki mtu yeyote mwenye ufikiaji wa maunzi yako aweze kupata data yako!

Lakini katika mazingira maalumu, kama vile usakinishaji wa Omarchy wa mbali kwenye kompyuta zilizolindwa au kwa usakinishaji wa kutupa mara moja bila data nyeti, unaweza kutaka kusakinisha bila usimbaji fiche. Unaweza kubonyeza `Ctrl + C` kwenye uthibitisho wa uumbizaji wa diski ili kubadili hadi usakinishaji usio na usimbaji fiche.

### Lugha

Omarchy huzungumza lugha 50 — seti ileile kama omarchy.org — na Kiingereza ndicho chaguo-msingi. Ili kubadili, fungua menyu ya Omarchy na uende _Setup > Language_, au endesha `omarchy language <code>` katika terminal (`omarchy language list` huonyesha misimbo). Menyu, eneo-kazi, na arifa za Omarchy yenyewe hubadilisha lugha mara moja, na kila programu unayoifungua baada ya hapo pia hufuata. Programu ambazo tayari zilikuwa zimefunguliwa hubadilika mara unapoziwashia upya.

### Usaidizi ikiwa umekwama

Ikiwa utakwama, kwa kawaida unaweza kupata mtu aliye tayari kusaidia katika kituo cha _#omarchy-help_ kwenye [Discord ya jumuiya](https://omarchy.org/discord).
