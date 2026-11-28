# Usalama

Omarchy inachukulia usalama kwa uzito mkubwa sana. Hii imekusudiwa kuwa mfumo wa uendeshaji unaoweza kuutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza kompyuta mpakato hakuwezi kusababisha dharura ya usalama. Basi hiki ndicho tunachofanya:

1. *Usimbaji fiche wa diski nzima umewashwa kwa chaguo-msingi*: Hii ndiyo hatua muhimu zaidi ya kulinda data yako kimwili. Ikiwa kompyuta yako imepotea au imeibwa, data imesimbwa kwa fiche kikamilifu kwa kutumia LUKS ya kawaida (Linux Unified Key Setup). Kisakinishi hukuruhusu kuizima kwa mashine za kutupwa (tazama [Kuanza](02-getting-started.md)); usakinishaji usio na usimbaji fiche hauna ulinzi huu wowote, na mtu yeyote anayeshikilia diski anaweza kuisoma.
2. *Ngome imewashwa kwa chaguo-msingi*: Trafiki yote inayoingia imezuiwa kwa chaguo-msingi, isipokuwa chache: mlango 53317 kwa [LocalSend](https://localsend.org/); maswali ya DNS kwa kitatuzi cha kompyuta chenyewe katika anwani ya daraja ya Docker (172.17.0.1), yanayokubaliwa kutoka katika masafa ya anwani za faragha ambayo Docker huwapa kontena zake; na DNS ya multicast (mlango 5353), inayoruhusu vichapishi na vifaa vingine kwenye mtandao wako kupatana na pia hutangaza jina la kompyuta yako huko. Zaidi ya hayo, ngome huhifadhi vibali vya kawaida vya UFW kwa ping, kupata anwani kutoka kwa kipanga njia chako (DHCP), na ugunduzi wa UPnP. Hata ssh imezimwa hadi uiwashwe kupitia _Usanidi > Usalama > SSHD_, ambayo huidhinisha ufunguo wako wa SSH, huzima kuingia kwa nenosiri, na ndipo tu hufungua mlango 22 (wenye kikomo cha kasi dhidi ya mashambulizi ya kubahatisha). Tumezuia hata ufikiaji wa Docker kwa kutumia usanidi wa [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia kontena zako zisifichuliwe kwa ulimwengu kwa bahati mbaya.
3. *Arch kila wakati ina masasisho ya hivi punde*: Arch, distro msingi ambayo Omarchy imejengwa juu yake, ni usambazaji wa rolling. Hii inamaanisha kuwa udhaifu wowote wa usalama unaogunduliwa na kurekebishwa katika kifurushi chochote unapatikana haraka kwa usakinishaji kwa kutumia `omarchy-update`. Kwa njia hiyo kila wakati unaendesha matoleo ya hivi punde na salama zaidi ya kila kitu.
4. *Omarchy hutunza vifurushi vyake mwenyewe na seva yake ya nakala*: Omarchy hutegemea tu, kwa chaguo-msingi, vifurushi kutoka katika hazina za Arch zenyewe za core/extra/multilib (za Arch Linux ARM kwenye mashine za ARM, pamoja na Asahi ALARM kwenye Apple Silicon) na Hazina yake yenyewe ya Vifurushi ya Omarchy. Unaweza kusakinisha programu moja kwa moja kutoka AUR, lakini usakinishaji msingi haufanyi hivyo — ni usakinishaji michache tu ya hiari, kama vivinjari vya wahusika wengine, inayochota kutoka AUR.
5. *Cloudflare hutulinda dhidi ya DDoS*: Miundombinu ya usambazaji ya Omarchy — ISO, vifurushi vya Omarchy, seva nakala ya Arch — imelindwa nyuma ya ngao imara ya DDoS ya Cloudflare na kupangishwa kwenye CDN yao. Hii hutoa upatikanaji bora kabisa.

## Kubadilisha manenosiri yako

Una manenosiri mawili katika usakinishaji uliosimbwa kwa fiche: lile linalofungua diski wakati wa kuwasha, na lile unalotumia kuingia na `sudo`. Usanidi huzifanya ziwe sawa. _Sasisha > Nenosiri_ katika menyu ya Omarchy hubadilisha zote mbili mara moja, ili zibaki sawa: huuliza nenosiri la sasa la diski, kisha jipya, hubadilisha la diski na kisha huweka nenosiri lako la kuingia lifanane nalo. Bila usimbaji fiche wa diski hubadilisha nenosiri lako la kuingia tu. Ikiwa mabadiliko yamekatizwa, endesha _Sasisha > Nenosiri_ tena: huuliza nenosiri linalofungua diski sasa, humalizia mabadiliko, na huweka nenosiri lako la kuingia kuwa hilo. Ili kubadilisha nenosiri la diski nyingine iliyosimbwa kwa fiche, endesha `omarchy-drive-password` katika terminali.

## Kukabidhi mashine ambayo tayari umeitumia

Ikiwa unakabidhi mashine yako kwa mtu mwingine, si lazima uisakinishe upya. Endesha _Ondoa > Rudisha Kiwandani_ katika menyu ya Omarchy, andika `reset` kuthibitisha, ingiza nenosiri lako la usimbaji fiche wa diski ukiulizwa, na uwashe upya. Hiyo hufuta kila akaunti ya mtumiaji na kila kitu katika `/home`, huondoa vifurushi vyote na mabadiliko ya mfumo uliyofanya tangu usakinishaji, na hufuta utambulisho wa mashine — miunganisho ya mtandao, funguo za mwenyeji, na vyote. Kinachowaka baadaye ni mchawi wa usanidi kutoka kuwasha kwa kwanza, tayari kwa mmiliki wake mpya kuingiza jina lake mwenyewe, nenosiri, na nenosiri la usimbaji fiche.

Inafanya kazi kwa kurejesha picha msingi ambayo kisakinishi huchukua, kwa hivyo inapatikana tu kwenye mashine zilizosakinishwa kutoka ISO ya Omarchy. Na kwenye diski isiyo na usimbaji fiche, kuweka upya ni ufutaji badala ya ufutaji salama, kwa hivyo ikiwa data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## Sudo isiyo na nenosiri

Wakati mwingine unataka `sudo` iache kuuliza, mara nyingi zaidi wakati wakala wa AI anafanya kipindi kirefu cha kazi ya mfumo kwa ajili yako. _Usanidi > Usalama > Sudo Isiyo na Nenosiri_ huuliza kwa muda gani kuruhusu ufikiaji: **dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Ikoni nyekundu ya onyo huonekana kando ya viashiria vingine vya upau wa menyu wakati ufikiaji unafanya kazi. Ibofye au endesha amri tena ili kuzima ufikiaji. Unaweza pia kupitisha idadi yako mwenyewe ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au tumia `omarchy-sudo-passwordless permanent`.

Ufikiaji wa muda humalizika kiotomatiki, ikiwa ni pamoja na mara tu baada ya kuendelea kutoka kusimamishwa kulikopita tarehe ya mwisho. Kuwasha upya kompyuta huumaliza mapema. Ufikiaji wa kudumu hubaki baada ya kuwasha upya na hubaki umewashwa hadi uuzime.

Kusasisha au kuondoa kifurushi cha mipangilio cha Omarchy humaliza ruhusa yoyote ya muda kabla ya usaidizi wake wa kumalizika kubadilika. Ikiwa amri inaripoti hitilafu ya uidhinishaji au usafishaji, itatue kabla ya kujaribu kuwasha ruhusa nyingine; hitilafu haimaanishi kuwa ufikiaji usio na nenosiri haufanyi kazi.

Kuwa macho kuhusu hili: wakati imewashwa, chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuulizwa. Hiyo ndiyo maana nzima, na pia ndiyo hatari nzima.

## Funguo za Kutia Saini

Ufunguo wa umma wa saini zote za ISO na kifurushi cha hazina ya Omarchy ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Kifurushi cha `omarchy/omarchy-keyring` kinayo pia na kitatumika kusambaza masasisho yoyote yanayowezekana bila mshono.

Unaweza kupata saini ya toleo lolote la ISO kwa kuongeza `.sig` kwenye URL yake, kama `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
