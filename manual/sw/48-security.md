# Usalama

Omarchy inachukulia usalama kwa uzito mkubwa sana. Hii inakusudiwa kuwa mfumo wa uendeshaji ambao unaweza kuutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza laptop hakuwezi kusababisha dharura ya usalama. Kwa hivyo hivi ndivyo tunavyofanya:

1. *Usimbaji fiche wa diski nzima ni wa lazima*: Hii ndiyo hatua muhimu zaidi ya kulinda usalama wa kimwili wa data yako. Ikiwa kompyuta yako imepotea au imeibwa, data imesimbwa fiche kabisa kwa kutumia LUKS ya kawaida (Linux Unified Key Setup).
2. *Firewall imewashwa kwa chaguo-msingi*: Trafiki yote inayoingia imezuiwa kwa chaguo-msingi isipokuwa port 53317 kwa [LocalSend](https://localsend.org/). Hata ssh imezimwa hadi utakapo iwasha kupitia _Setup > Security > SSHD_, ambayo hufungua port 22 (imepunguzwa kasi dhidi ya brute force) kama sehemu ya usanidi. Hata tunafunga ufikiaji wa Docker kwa kutumia usanidi wa [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia containers zako zisionekane kwa bahati mbaya kwa ulimwengu.
3. *Arch huwa na updates za hivi punde kila wakati*: Arch, distro ya msingi ambayo Omarchy imejengwa juu yake, ni rolling distribution. Hii inamaanisha kuwa udhaifu wowote wa usalama unaogunduliwa na kurekebishwa katika package yoyote unapatikana haraka kwa ajili ya kusakinishwa kwa kutumia `omarchy-update`. Kwa njia hiyo huwa unatumia matoleo ya hivi punde na salama zaidi ya kila kitu kila wakati.
4. *Omarchy inatunza packages na mirror yake yenyewe*: Omarchy inategemea tu packages kutoka kwenye repositories za Arch zenyewe za core/extra/multilib na Omarchy Package Repository yake yenyewe kwa chaguo-msingi. Unaweza kusakinisha software moja kwa moja kutoka AUR, lakini usakinishaji wa msingi haufanyi hivyo — ni usakinishaji machache tu wa hiari, kama vile browsers za wahusika wengine, ndio huchota kutoka AUR.
5. *Cloudflare inatulinda dhidi ya DDoS*: Miundombinu ya usambazaji ya Omarchy — ISOs, packages za Omarchy, mirror ya Arch — imelindwa nyuma ya ngao imara ya Cloudflare dhidi ya DDoS na imepangishwa kwenye CDN yao. Hii hutoa upatikanaji bora kabisa.

## Kubadilisha passwords zako

Una passwords mbili kwenye usakinishaji uliosimbwa fiche: ile inayofungua drive wakati wa kuwasha, na ile unayotumia kuingia na `sudo`. Setup huzifanya ziwe sawa. Zote mbili zinaweza kubadilishwa chini ya _Update > Password_ katika menu ya Omarchy — _Drive Encryption_ kwa ya kwanza, _User_ kwa ya pili. Kubadilisha password ya drive hukuomba ya sasa kwanza, kwa hivyo iweke karibu. Ikiwa mabadiliko yataingiliwa, endesha _Drive Encryption_ tena: itaomba password inayofungua drive sasa na kukamilisha mabadiliko.

## Kukabidhi machine ambayo tayari umeitumia

Ikiwa unakabidhi machine yako kwa mtu mwingine, si lazima uisakinishe upya. Endesha _Setup > Reset Computer_ katika menu ya Omarchy, andika `reset` ili kuthibitisha, na uwashe upya. Hatua hiyo hufuta kila akaunti ya mtumiaji na kila kitu kilicho katika `/home`, huondoa packages zote na mabadiliko yote ya mfumo uliyofanya tangu usakinishaji, na hufuta utambulisho wa machine — miunganisho ya network, host keys, na kila kitu. Kinachojitokeza baada ya kuwasha ni setup wizard ya kuwasha kwa mara ya kwanza, ikiwa tayari kwa mmiliki wake mpya kuingiza jina lake, password yake, na password ya usimbaji fiche.

Inafanya kazi kwa kurejesha baseline snapshot ambayo installer huichukua, kwa hivyo inapatikana tu kwenye machines zilizosakinishwa kutoka Omarchy ISO. Na kwenye drive isiyo na usimbaji fiche, reset ni ufutaji badala ya ufutaji salama, kwa hivyo ikiwa data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## sudo bila password

Wakati mwingine unataka `sudo` iaache kuomba, mara nyingi zaidi wakati AI agent inakufanyia kazi ndefu ya mfumo. _Setup > Security > Passwordless Sudo_ huuliza kwa muda gani uruhusu ufikiaji: **dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Ikoni nyekundu ya onyo huonekana kando ya viashiria vingine vya menu bar wakati ufikiaji unaendelea. Ibofye au endesha amri tena ili kuzima ufikiaji. Unaweza pia kupitisha idadi yako mwenyewe ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au utumie `omarchy-sudo-passwordless permanent`.

Ufikiaji wa muda humalizika kiotomatiki, ikiwa ni pamoja na mara tu baada ya kuendelea kutoka suspend iliyovuka tarehe ya mwisho. Kuwasha kompyuta upya huumaliza mapema. Ufikiaji wa kudumu hudumu baada ya kuwasha upya na hubaki umewashwa hadi utakapouzima.

Kusasisha au kuondoa settings package ya Omarchy humaliza ruhusa yoyote ya muda kabla ya usaidizi wake wa kumalizika kubadilika. Ikiwa amri itaripoti hitilafu ya uidhinishaji au usafishaji, itatue kabla ya kujaribu kuwasha ruhusa nyingine; hitilafu haimaanishi kuwa ufikiaji bila password umezimwa.

Kuwa macho kuhusu hili: ukiwa umewashwa, chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuulizwa. Hiyo ndiyo sababu nzima, na pia ndiyo hatari nzima.

## Funguo za Kusaini

Ufunguo wa umma wa saini zote za ISO na package ya repo ya Omarchy ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Package ya `omarchy/omarchy-keyring` pia ina ufunguo huu na itatumika kusambaza updates zozote zinazowezekana bila matatizo.

Unaweza kupata saini ya toleo lolote la ISO kwa kuongeza .sig kwenye URL. Kama https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
