# Masasisho

Omarchy na vifurushi vyako huwekwa vikiwa vimesasishwa kupitia _Update > Omarchy_ katika menyu ya Omarchy (`Super + Space`).

Omarchy yenyewe husakinishwa kama vifurushi vya kawaida vya pacman kutoka [Hifadhi ya Vifurushi ya Omarchy](https://github.com/omacom-io/omarchy-pkgs), kwa hiyo sasisho husakinisha [toleo jipya zaidi la Omarchy](https://github.com/omacom/omarchy/releases), huendesha uhamishaji wowote unaosubiri ili mfumo wako uendane na toleo jipya zaidi, na husasisha vifurushi vyote vya mfumo kutoka [Kioo cha Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) na [AUR](https://aur.archlinux.org/) (ikiwa umesakinisha vifurushi vyovyote vya AUR).

Matoleo mapya yanapotolewa, aikoni ya mshale wa duara itaonekana upande wa kulia wa saa yako. Ibofye na mchakato wa kusasisha utaanza.

![update-available](images/update-available.webp)

### Vituo vinne

Omarchy husasishwa kupitia vituo vinne: stable, RC, edge, na dev. Usakinishaji mpya huanza kwenye kituo cha stable, ambacho hufuata [matoleo rasmi](https://github.com/omacom/omarchy/releases/), pamoja na [kioo thabiti cha Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) ambacho kiko nyuma kwa mwezi mmoja dhidi ya kilicho kipya zaidi, ili tuweze kugundua kutopatana kokote kupya kunakohitaji mabadiliko ya usanidi kabla hakujaleta matatizo kwa watu.

Lakini ikiwa ungependa kusaidia kugundua matatizo hayo yanayowezekana, unaweza kutumia kituo cha edge. Hilo litaweka vifurushi vyako vya Omarchy vikifuata matoleo mapya zaidi ya uendelezaji, na litakuruhusu kusasisha hadi vifurushi vipya zaidi vya Arch mara vinapopatikana. Unapaswa kufanya hivi tu ikiwa una uzoefu na Linux, na unajua jinsi ya kurejesha mfumo wenye matatizo.

Kabla ya toleo lolote kubwa jipya, tutakuwa tukifanya uthibitishaji wa mwisho kwa kutumia kituo cha RC. Ikiwa una nia ya kusaidia katika uboreshaji wa mwisho, njoo ujiunge nasi katika #omarchy-release-candidates kwenye Discord.

Mwishowe, kuna kituo cha dev, ambacho huunganisha Omarchy moja kwa moja na git checkout ya msimbo asilia katika `~/omarchy`, pamoja na vifurushi vya edge. Unapaswa kutumia kituo hiki tu ikiwa wewe ni mtumiaji mwenye uzoefu wa Linux, unafanya kazi moja kwa moja kwenye Omarchy, na uko tayari kuvumilia kuharibika kwa mambo.

Unaweza kubadilisha kati ya vituo kwa kutumia _Update > Channel_ kutoka menyu ya Omarchy (au `omarchy channel set <stable|rc|edge|dev>` kwenye terminal, ukitumia `omarchy channel current` kuona ulipo).

### Kubadilisha kernel

Omarchy huwasha kernel yake yenyewe ya `linux-omarchy`, lakini unaweza kuweka nyingine zimesakinishwa kando yake, kama kernel ya kawaida ya Arch ya `linux` au toleo la majaribio unalolijaribu. Kunapokuwa na zaidi ya moja, _Update > Kernel_ katika menyu ya Omarchy huziordhesha huku ikiwa na alama ya kuteua kando ya ile inayowasha kwa chaguo-msingi. Chagua nyingine, ingiza nenosiri lako mara moja, na itawasha baada ya kuwasha upya kunakofuata. Kernel nyingine hubaki kwenye menyu ya kuwasha, kwa hiyo bado unaweza kuchagua moja mwenyewe ikiwa chaguo-msingi jipya litakupa matatizo. Kwenye terminal, ni `omarchy kernel` kuona chaguo-msingi la sasa, `omarchy kernel list` kwa zilizosakinishwa, na `omarchy kernel set <kernel>` kubadilisha.

### Masasisho ya firmware

Vifurushi vyako siyo pekee vinavyopitwa na wakati. Kompyuta nyingi za mkononi na vifaa vya pembeni hutuma firmware ya BIOS, SSD, na dock kupitia Linux Vendor Firmware Service, na _Update > Firmware_ katika menyu ya Omarchy itachukua na kusakinisha chochote ambacho maunzi yako yanasubiri. Husakinisha `fwupd` mara ya kwanza unapoiendesha. Firmware nyingi zinaweza kuandikwa tu wakati wa kuwasha upya, kwa hiyo usishangae ukiombwa kufanya hivyo.

Unapohitaji kubadilisha mpangilio katika BIOS yenyewe, shikilia `Alt` katika menyu ya mfumo (`Super + Escape`) na _Reboot_ hubadilika kuwa _Reboot to BIOS_, ambayo huwasha upya moja kwa moja hadi kwenye usanidi wa firmware bila kulazimika kukamata kitufe sahihi wakati wa kuwasha. Kutoka kwenye terminal, ni `omarchy system firmware`.

### Onyo kuhusu masasisho ya moja kwa moja ya pacman/yay

Ikiwa tayari unaifahamu Arch, unaweza kujaribiwa kuendesha tu `pacman -Syu` au `yay -Syu` mwenyewe, lakini ukifanya hivyo, utakosa snapshot, uhamishaji, na masasisho ya usanidi ambayo Omarchy huendesha pamoja na vifurushi vipya. Ndiyo maana Omarchy itasimamisha kweli uboreshaji wa moja kwa moja wa mfumo na kukuelekeza kwenye `omarchy update` badala yake. (Ikiwa kweli unajua unachofanya, kilinzi kitakuambia jinsi ya kukipita kwa muamala mmoja.)

### Kurejesha masasisho mabaya

Ikiwa utapata tatizo baada ya kufanya sasisho, unaweza kurejesha mfumo wako kwenye snapshot iliyochukuliwa kabla ya sasisho. Washa upya tu na uchague snapshot katika menyu ya upakiaji wa kuwasha kutoka kabla ya kuanza sasisho.

![bootloader](images/bootloader.webp)

Ikiwa kwa namna fulani faili zako za usanidi zimeharibika, unaweza pia kufanya usakinishaji upya wa Omarchy kwa kutumia `omarchy reinstall` kwenye terminal. Hii itasakinisha upya vifurushi vyote vya chaguo-msingi vya Omarchy, itakuweka kwenye stable (edge kwenye Apple Silicon) na itashusha toleo la vifurushi vyovyote vilivyo vipya kupita kiasi, na itaweka upya faili zote za usanidi. Kumbuka kuwa mabadiliko yako yote ya usanidi wa mtumiaji kwenye chaguo-msingi za Omarchy yatafutwa kwa kufanya hivi!
