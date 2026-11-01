# Masasisho

Omarchy na vifurushi vyako huwekwa vikiwa vya kisasa kupitia _Sasisha > Omarchy_ katika menyu ya Omarchy (`Super + Space`).

Omarchy yenyewe husakinishwa kama vifurushi vya kawaida vya pacman kutoka [Hifadhi ya Vifurushi ya Omarchy](https://github.com/omacom-io/omarchy-pkgs), kwa hivyo sasisho husakinisha [toleo jipya zaidi la Omarchy](https://github.com/omacom/omarchy/releases), huendesha uhamishaji wowote unaosubiri ili kuweka mfumo wako ukiendana na toleo jipya zaidi, na husasisha vifurushi vyote vya mfumo kutoka [Kioo cha Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) na [AUR](https://aur.archlinux.org/) (ikiwa umesakinisha vifurushi vyovyote vya AUR).

Matoleo mapya yanapotolewa, aikoni ya mshale wa duara itaonekana kulia kwa saa yako. Ibofye na mchakato wa kusasisha utaanza.

![update-available](images/update-available.webp)

### Njia nne

Omarchy husasishwa kupitia njia nne: stable, RC, edge, na dev. Usakinishaji mpya huanza kwenye njia ya stable, ambayo hufuata [matoleo rasmi](https://github.com/omacom/omarchy/releases/), pamoja na [kioo thabiti cha Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) ambacho kiko nyuma kwa mwezi mmoja dhidi ya toleo jipya zaidi, ili tuweze kugundua kutopatana kupya kokote kunakohitaji mabadiliko ya usanidi kabla hakujasababisha matatizo kwa watu.

Lakini kama ungependa kusaidia kugundua matatizo hayo yanayoweza kutokea, unaweza kutumia njia ya edge. Hiyo itaweka vifurushi vyako vya Omarchy vikifuata matoleo mapya zaidi ya uendelezaji, na itakuruhusu kusasisha hadi vifurushi vipya zaidi vya Arch mara tu vinapopatikana. Unapaswa kufanya hivi tu ikiwa una uzoefu na Linux, na unajua jinsi ya kurejesha mfumo wenye matatizo.

Kabla ya toleo lolote kubwa jipya, tutakuwa tunafanya uthibitishaji wa mwisho kwa kutumia njia ya RC. Kama una nia ya kusaidia katika ukamilishaji wa mwisho, njoo ujiunge nasi katika #omarchy-release-candidates kwenye Discord.

Mwishowe, kuna njia ya dev, ambayo huunganisha Omarchy moja kwa moja na nakala ya git ya msimbo asilia katika `~/omarchy`, ikiunganishwa na vifurushi vya edge. Unapaswa kutumia njia hii tu ikiwa wewe ni mtumiaji wa Linux mwenye uzoefu, unafanya kazi moja kwa moja kwenye Omarchy, na uko tayari kuvumilia kuharibika kwa mfumo.

Unaweza kubadilisha kati ya njia kwa kutumia _Sasisha > Njia_ kutoka menyu ya Omarchy (au `omarchy-channel-set` katika terminal).

### Kubadilisha kernel

Omarchy huwasha kernel yake yenyewe ya `linux-omarchy`, lakini unaweza kuweka nyingine zimesakinishwa kando yake, kama kernel ya kawaida ya Arch ya `linux` au toleo la majaribio unalolijaribu. Kunapokuwa na zaidi ya moja, _Sasisha > Kernel_ katika menyu ya Omarchy huziordhesha huku ikiwa na alama ya tiki kando ya ile inayowasha kwa chaguo-msingi. Chagua nyingine, ingiza nenosiri lako mara moja, nayo itawasha baada ya kuwasha upya kunakofuata. Kernel nyingine hubaki kwenye menyu ya kuwasha, kwa hivyo bado unaweza kuchagua moja mwenyewe ikiwa chaguo-msingi kipya kitakupa matatizo. Katika terminal, ni `omarchy-kernel` kuona chaguo-msingi la sasa, `omarchy-kernel list` kwa kile kilichosakinishwa, na `omarchy-kernel set <kernel>` kubadilisha.

### Masasisho ya firmware

Vifurushi vyako siyo pekee vinavyopitwa na wakati. Kompyuta mpakato nyingi na vifaa vya pembeni husafirisha firmware ya BIOS, SSD, na dock kupitia Linux Vendor Firmware Service, na _Sasisha > Firmware_ katika menyu ya Omarchy italeta na kusakinisha chochote ambacho maunzi yako yanasubiri. Husakinisha `fwupd` mara ya kwanza unapoiendesha. Firmware nyingi zinaweza kuandikwa tu wakati wa kuwasha upya, kwa hivyo usishangae ukiombwa kufanya hivyo.

### Onyo kuhusu masasisho ya moja kwa moja ya pacman/yay

Kama tayari unaifahamu Arch, unaweza kujaribiwa kuendesha tu `pacman -Syu` au `yay -Syu` mwenyewe, lakini ukifanya hivyo, utakosa snapshot, uhamishaji, na masasisho ya usanidi ambayo Omarchy huendesha pamoja na vifurushi vipya. Ndiyo maana Omarchy itasimamisha kweli uboreshaji wa moja kwa moja wa mfumo na kukuelekeza kwenye `omarchy update` badala yake. (Kama kweli unajua unachofanya, kilinzi kitakuambia jinsi ya kukipita kwa muamala mmoja.)

### Kurejesha masasisho mabaya

Kama utawahi kupata tatizo baada ya kufanya sasisho, unaweza kurudisha mfumo wako kwenye snapshot iliyochukuliwa kabla ya sasisho. Washa upya tu na uchague snapshot katika menyu ya upakiaji wa kuwasha kutoka kabla ya kuanza sasisho.

![bootloader](images/bootloader.webp)

Kama kwa namna fulani faili zako za usanidi zimeharibika, unaweza pia kusakinisha upya Omarchy kwa kutumia `omarchy reinstall` katika terminal. Hii itasakinisha upya vifurushi vyote chaguo-msingi vya Omarchy, itakuweka kwenye stable na kushusha toleo la vifurushi vyovyote ambavyo ni vipya kupita kiasi, na kuweka upya faili zote za usanidi. Kumbuka kwamba mabadiliko yako yote ya usanidi wa mtumiaji kwenye chaguo-msingi za Omarchy yatafutwa kwa kufanya hivi!
