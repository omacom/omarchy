# Masasisho

Omarchy na vifurushi vyako huwekwa kisasa kupitia _Update > Omarchy_ kwenye menyu ya Omarchy (`Super + Space`).

Omarchy yenyewe husakinishwa kama vifurushi vya kawaida vya pacman kutoka [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), hivyo sasisho husakinisha [toleo jipya zaidi la Omarchy](https://github.com/omacom/omarchy/releases), huendesha uhamiaji wowote unaosubiri ili kupata mfumo wako usawazishwe na toleo jipya zaidi, na husasisha vifurushi vyote vya mfumo kutoka [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) na [AUR](https://aur.archlinux.org/) (ikiwa umesakinisha vifurushi vyovyote vya AUR).

Matoleo mapya yanapotolewa, aikoni ya mshale wa mviringo itaonekana kulia mwa saa yako. Ibofye na mchakato wa kusasisha utaanza.

![update-available](images/update-available.webp)

### Chaneli nne

Omarchy husasishwa kupitia chaneli nne: stable, RC, edge, na dev. Usakinishaji mpya huanzia kwenye chaneli ya stable, ambayo hufuata [matoleo rasmi](https://github.com/omacom/omarchy/releases/), pamoja na [Omarchy Arch mirror ya stable](https://github.com/omacom-io/omarchy-mirror) ambayo iko mwezi mmoja nyuma ya toleo jipya zaidi, ili tuweze kukamata upungufu wowote mpya wa uoanifu unaohitaji mabadiliko ya usanidi kabla haujasababisha matatizo kwa watu.

Lakini ikiwa ungependa kusaidia kuona matatizo hayo yanayoweza kutokea, unaweza kuendesha kwenye chaneli ya edge. Hiyo itaweka vifurushi vyako vya Omarchy vifuate miundo mipya zaidi ya uendelezaji, na inakuruhusu kusasisha hadi vifurushi vipya zaidi vya Arch mara tu vinapopatikana. Unapaswa kufanya hivi tu ikiwa una uzoefu na Linux, na unajua jinsi ya kurejesha mfumo wenye matatizo.

Kabla ya toleo lolote kubwa jipya, tutakuwa tunafanya uthibitishaji wa mwisho kwa kutumia chaneli ya RC. Ikiwa una nia ya kusaidia katika ung'arishaji wa mwisho, njoo utundike katika #omarchy-release-candidates kwenye Discord.

Hatimaye, kuna chaneli ya dev, ambayo huunganisha Omarchy moja kwa moja na git checkout ya msimbo wa chanzo katika `~/omarchy`, pamoja na vifurushi vya edge. Unapaswa kutumia chaneli hii tu ikiwa wewe ni mtumiaji mwenye uzoefu wa Linux, unafanya kazi moja kwa moja kwenye Omarchy, na uko tayari kuvumilia kuharibika.

Unaweza kubadilisha kati ya chaneli kwa kutumia _Update > Channel_ kutoka menyu ya Omarchy (au `omarchy-channel-set` kwenye terminal).

### Kubadilisha kernel

Omarchy huwasha kernel yake yenyewe ya `linux-omarchy`, lakini unaweza kuweka nyingine zikiwa zimesakinishwa kando yake, kama kernel ya kawaida ya Arch ya `linux` au muundo wa majaribio unaoujaribu. Kunapokuwa na zaidi ya moja, _Update > Kernel_ kwenye menyu ya Omarchy huorodhesha na alama ya tiki karibu na ile inayowasha kwa chaguo-msingi. Chagua nyingine, ingiza nenosiri lako mara moja, na itawasha baada ya kuwasha upya kunakofuata. Kernel zingine hubaki kwenye menyu ya kuwasha, hivyo bado unaweza kuchagua moja kwa mkono ikiwa chaguo-msingi jipya litakusumbua. Kwenye terminal, ni `omarchy-kernel` kuona chaguo-msingi la sasa, `omarchy-kernel list` kwa kile kilichosakinishwa, na `omarchy-kernel set <kernel>` kubadilisha.

### Masasisho ya firmware

Vifurushi vyako siyo kitu pekee kinachopitwa na wakati. Kompyuta ndogo nyingi na vifaa vya pembeni husafirisha firmware ya BIOS, SSD, na dock kupitia Linux Vendor Firmware Service, na _Update > Firmware_ kwenye menyu ya Omarchy itachukua na kusakinisha chochote kilicho na maunzi yako yanayosubiri. Husakinisha `fwupd` mara ya kwanza unapoiendesha. Firmware nyingi zinaweza kuandikwa tu wakati wa kuwasha upya, hivyo usishangae ukiombwa kufanya hivyo.

Unapohitaji kubadilisha mpangilio katika BIOS yenyewe, shikilia `Alt` kwenye menyu ya mfumo (`Super + Escape`) na _Reboot_ hugeuka kuwa _Reboot to BIOS_, ambayo huwasha upya moja kwa moja hadi kwenye usanidi wa firmware bila kulazimika kushika kitufe sahihi wakati wa kuwasha. Kutoka terminal, ni `omarchy system firmware`.

### Onyo kuhusu masasisho ya moja kwa moja ya pacman/yay

Ikiwa tayari unaifahamu Arch, unaweza kushawishika kuendesha tu `pacman -Syu` au `yay -Syu` mwenyewe, lakini ukifanya hivyo, utakosa snapshot, uhamiaji, na masasisho ya usanidi ambayo Omarchy huendesha pamoja na vifurushi vipya. Ndiyo maana Omarchy itasimamisha kweli uboreshaji wa moja kwa moja wa mfumo na kukuelekeza kwenye `omarchy update` badala yake. (Ikiwa kweli unajua unachofanya, mlinzi atakuambia jinsi ya kuikwepa kwa muamala mmoja.)

### Kurejesha masasisho mabaya

Ikiwa utawahi kupata tatizo baada ya kufanya sasisho, unaweza kurejesha mfumo wako kwenye snapshot iliyochukuliwa kabla ya sasisho. Washa upya tu na uchague snapshot kwenye menyu ya upakiaji wa kuwasha kutoka kabla ya kuanza sasisho.

![bootloader](images/bootloader.webp)

Ikiwa kwa namna fulani faili zako za usanidi zimeharibika, unaweza pia kufanya usakinishaji upya wa Omarchy kwa kutumia `omarchy reinstall` kwenye terminal. Hii itasakinisha upya vifurushi vyote vya chaguo-msingi vya Omarchy, itakuweka kwenye stable na kushusha vifurushi vyovyote vilivyo vipya mno, na kuweka upya faili zote za usanidi. Kumbuka kuwa mabadiliko yako yote ya usanidi wa mtumiaji kwa chaguo-msingi za Omarchy yatabatilishwa kwa kufanya hivi!
