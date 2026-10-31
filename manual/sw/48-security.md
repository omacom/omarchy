# Usalama

Omarchy inachukulia usalama kwa uzito mkubwa sana. Hii inakusudiwa kuwa mfumo wa uendeshaji unaoweza kuutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza laptop hakuwezi kusababisha dharura ya usalama. Hivyo hivi ndivyo tunavyofanya:

1. *Usimbaji fiche wa diski nzima ni wa lazima*: Hii ndiyo hatua muhimu zaidi ya kulinda data yako kimwili. Iwapo kompyuta yako itapotea au kuibiwa, data imesimbwa fiche kabisa kwa kutumia LUKS (Linux Unified Key Setup) ya kawaida.
2. *Firewall imewashwa kwa chaguo-msingi*: Trafiki yote inayoingia imezuiwa kwa chaguo-msingi isipokuwa port 53317 kwa ajili ya [LocalSend](https://localsend.org/). Hata ssh imezimwa hadi utakapoiiwasha kupitia _Setup > Security > SSHD_, ambayo hufungua port 22 (iliyozuiwa kiwango dhidi ya mashambulizi ya brute force) kama sehemu ya usanidi. Hata tunazuia ufikiaji wa Docker kwa kutumia usanidi wa [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia containers zako zisionekane kwa ulimwengu kwa bahati mbaya.
3. *Arch huwa na masasisho ya hivi punde kila wakati*: Arch, distro ya msingi ambayo Omarchy imejengwa juu yake, ni rolling distribution. Hii ina maana kwamba udhaifu wowote wa usalama unaogunduliwa na kurekebishwa katika kifurushi chochote unapatikana haraka kwa usakinishaji kwa kutumia `omarchy-update`. Kwa njia hiyo huwa unatumia matoleo ya hivi punde na salama zaidi ya kila kitu kila wakati.
4. *Omarchy hutunza vifurushi na mirror yake yenyewe*: Omarchy hutegemea tu vifurushi kutoka kwenye repositories za Arch zenyewe za core/extra/multilib na Omarchy Package Repository yake yenyewe kwa chaguo-msingi. Unaweza kusakinisha programu moja kwa moja kutoka AUR, lakini usakinishaji wa msingi haufanyi hivyo — ni usakinishaji chache tu wa hiari, kama vile vivinjari vya wahusika wengine, ndio huchukua kutoka AUR.
5. *Cloudflare hutulinda dhidi ya DDoS*: Miundombinu ya usambazaji ya Omarchy — ISO, vifurushi vya Omarchy, mirror ya Arch — imelindwa nyuma ya ngao imara ya Cloudflare dhidi ya DDoS na kupangishwa kwenye CDN yao. Hii hutoa upatikanaji bora sana.

## Kubadilisha nywila zako

Una nywila mbili katika usakinishaji uliosimbwa fiche: ile inayofungua drive wakati wa kuwasha, na ile unayotumia kuingia na `sudo`. Setup huzifanya ziwe sawa. Zote mbili zinaweza kubadilishwa chini ya _Update > Password_ katika menyu ya Omarchy — _Drive Encryption_ kwa ya kwanza, _User_ kwa ya pili. Kubadilisha nywila ya drive hukuomba ile ya sasa kwanza, kwa hiyo iweke tayari karibu nawe. Ikiwa mabadiliko yataingiliwa, endesha _Drive Encryption_ tena: itakuomba nywila inayofungua drive sasa na kukamilisha mabadiliko.

## Kukabidhi mashine ambayo tayari umeitumia

Ikiwa unamkabidhi mtu mwingine mashine yako, si lazima uisakinishe upya. Endesha _Setup > Reset Computer_ katika menyu ya Omarchy, andika `reset` ili kuthibitisha, na uwashe upya. Hiyo hufuta kila akaunti ya mtumiaji na kila kitu kilicho katika `/home`, huondoa vifurushi vyote na mabadiliko ya mfumo uliyofanya tangu usakinishaji, na hufuta utambulisho wa mashine — miunganisho ya mtandao, host keys, na kila kitu. Kinachorejea ni setup wizard kutoka kuwasha kwa kwanza, tayari kwa mmiliki wake mpya kuingiza jina lake, nywila yake, na nywila yake ya usimbaji fiche.

Inafanya kazi kwa kurejesha baseline snapshot ambayo installer huichukua, kwa hiyo inapatikana tu kwenye mashine zilizosakinishwa kutoka Omarchy ISO. Na kwenye drive isiyo na usimbaji fiche, reset ni ufutaji badala ya ufutaji salama, kwa hiyo ikiwa data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## sudo isiyohitaji nywila

Wakati mwingine unataka `sudo` iaache kuomba, mara nyingi zaidi wakati AI agent inakufanyia kazi ndefu ya mfumo. _Setup > Security > Passwordless Sudo_ huuliza kwa muda gani uruhusu ufikiaji: **dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Ikoni nyekundu ya onyo huonekana kando ya viashiria vingine vya menu bar wakati ufikiaji unaendelea. Ibofye au endesha amri tena ili kuzima ufikiaji. Unaweza pia kupitisha idadi yako mwenyewe ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au kutumia `omarchy-sudo-passwordless permanent`.

Ufikiaji wa muda huisha kiotomatiki, ikiwa ni pamoja na mara tu baada ya kuendelea kutoka suspend iliyovuka tarehe ya mwisho. Kuwasha upya kompyuta huumaliza mapema. Ufikiaji wa kudumu hudumu baada ya kuwasha upya na hubaki umewashwa hadi utakapoizima.

Kusasisha au kuondoa kifurushi cha mipangilio cha Omarchy humaliza ruzuku yoyote ya muda kabla ya usaidizi wake wa kuisha kubadilika. Ikiwa amri itaripoti hitilafu ya idhini au usafishaji, isuluhishe kabla ya kujaribu kuwasha ruzuku nyingine; hitilafu haimaanishi kwamba ufikiaji usiohitaji nywila umezimwa.

Kuwa macho kuhusu hili: ukiwa umewashwa, chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuulizwa. Hiyo ndiyo sababu yote, na hiyo pia ndiyo hatari yote.

## Funguo za Kusaini

Funguo ya umma ya sahihi zote za ISO na kifurushi cha Omarchy repo ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Kifurushi cha `omarchy/omarchy-keyring` pia kina funguo hii na kitatumika kusambaza masasisho yoyote yanayowezekana bila matatizo.

Unaweza kupata sahihi ya toleo lolote la ISO kwa kuongeza `.sig` kwenye URL yake, kama `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
