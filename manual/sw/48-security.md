# Usalama

Omarchy inachukulia usalama kwa uzito mkubwa sana. Hii imekusudiwa kuwa mfumo wa uendeshaji ambao unaweza kuutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza kompyuta ndogo hakuwezi kusababisha dharura ya kiusalama. Kwa hiyo hivi ndivyo tunavyofanya:

1. *Usimbaji fiche wa diski nzima umewashwa kwa chaguo-msingi*: Hii ndiyo hatua muhimu zaidi ya kulinda usalama wa kimwili wa data yako. Iwapo kompyuta yako imepotea au imeibiwa, data imesimbwa kwa fiche kikamilifu kwa kutumia LUKS (Linux Unified Key Setup) ya kawaida. Kisakinishi hukuruhusu kuchagua kutotumia kwa mashine za kutupa (tazama [Kuanza](02-getting-started.md)); usakinishaji usio na usimbaji fiche hauna ulinzi huu wowote, na mtu yeyote aliye na hifadhi anaweza kuisoma.
2. *Ngome imewashwa kwa chaguo-msingi*: Trafiki yote inayoingia imezuiwa kwa chaguo-msingi, isipokuwa chache tu: mlango 53317 kwa [LocalSend](https://localsend.org/); maswali ya DNS kwa kitatuzi cha kompyuta yenyewe kilicho katika anwani ya daraja la Docker (172.17.0.1), yanayokubaliwa kutoka katika safu za anwani za faragha ambazo Docker huwapa kontena zake; na DNS ya multicast (mlango 5353), ambayo huruhusu vichapishi na vifaa vingine vilivyo kwenye mtandao wako kupatana, na pia hutangaza jina la kompyuta yako huko. Zaidi ya hizo, ngome huhifadhi vibali vya kawaida vya UFW vya ping, vya kupata anwani kutoka kwa kipanga njia chako (DHCP), na vya ugunduzi wa UPnP. Hata ssh imezimwa hadi utakapo iwasha kupitia _Mipangilio > Usalama > SSHD_, ambayo huidhinisha ufunguo wako wa SSH, huzima kuingia kwa nenosiri, na ndipo tu hufungua mlango 22 (uliowekewa kikomo cha kasi dhidi ya mashambulizi ya kubahatisha). Hata tunafunga ufikiaji wa Docker kwa kutumia mipangilio ya [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia kontena zako zisiwekwe wazi kwa ulimwengu kwa bahati mbaya.
3. *Arch huwa na masasisho ya hivi karibuni zaidi kila wakati*: Arch, distro ya msingi ambayo Omarchy imejengwa juu yake, ni usambazaji unaoendelea kusasishwa. Hii inamaanisha kuwa udhaifu wowote wa kiusalama unaogunduliwa na kurekebishwa katika kifurushi chochote unapatikana haraka kwa usakinishaji kwa kutumia `omarchy-update`. Kwa njia hiyo huwa unaendesha matoleo ya hivi karibuni zaidi na salama zaidi ya kila kitu kila wakati.
4. *Omarchy hutunza vifurushi vyake yenyewe na kioo chake yenyewe*: Kwa chaguo-msingi, Omarchy hutegemea tu vifurushi kutoka katika hazina za Arch zenyewe za core/extra/multilib (za Arch Linux ARM kwenye mashine za ARM, pamoja na Asahi ALARM kwenye Apple Silicon) na Hazina yake yenyewe ya Vifurushi ya Omarchy. Unaweza kusakinisha programu moja kwa moja kutoka AUR, lakini usakinishaji wa msingi haufanyi hivyo — ni usakinishaji michache tu ya hiari, kama vivinjari vya wahusika wengine, ndiyo huchukua kutoka AUR.
5. *Cloudflare hutulinda dhidi ya DDoS*: Miundombinu ya usambazaji ya Omarchy — ISO, vifurushi vya Omarchy, kioo cha Arch — imelindwa nyuma ya ngao imara ya Cloudflare dhidi ya DDoS na imepangishwa kwenye CDN yao. Hii hutoa upatikanaji bora kabisa.

## Kubadilisha manenosiri yako

Una manenosiri mawili kwenye usakinishaji uliosimbwa kwa fiche: lile linalofungua hifadhi wakati wa kuwasha, na lile unalotumia kuingia na `sudo`. Usakinishaji wa awali huyafanya yafanane. Yote mawili yanaweza kubadilishwa chini ya _Sasisha > Nenosiri_ katika menyu ya Omarchy — _Usimbaji Fiche wa Hifadhi_ kwa la kwanza, _Mtumiaji_ kwa la pili. Kubadilisha nenosiri la hifadhi huomba la sasa kwanza, kwa hiyo liweke karibu. Ikiwa mabadiliko yamekatizwa, endesha _Usimbaji Fiche wa Hifadhi_ tena: huomba nenosiri linalofungua hifadhi sasa na humalizia mabadiliko.

## Kukabidhi mashine ambayo tayari umeitumia

Ikiwa unamkabidhi mtu mwingine mashine yako, si lazima uisakinishe upya. Endesha _Ondoa > Weka Upya Kiwandani_ katika menyu ya Omarchy, andika `reset` ili kuthibitisha, ingiza nenosiri lako la usimbaji fiche wa hifadhi ukiombwa, na uwashe upya. Hiyo hufuta kila akaunti ya mtumiaji na kila kitu kilicho katika `/home`, hutupa vifurushi vyote na mabadiliko yote ya mfumo uliyofanya tangu usakinishaji, na hufuta utambulisho wa mashine — miunganisho ya mtandao, funguo za mwenyeji, na kila kitu. Kinachowaka baadaye ni mchawi wa usakinishaji wa kuwasha kwa mara ya kwanza, ukiwa tayari kwa mmiliki wake mpya kuingiza jina lake mwenyewe, nenosiri lake, na nenosiri lake la usimbaji fiche.

Inafanya kazi kwa kurejesha picha ya msingi ambayo kisakinishi huchukua, kwa hiyo inapatikana tu kwenye mashine zilizosakinishwa kutoka ISO ya Omarchy. Na kwenye hifadhi isiyo na usimbaji fiche, kuweka upya ni ufutaji badala ya ufutaji salama, kwa hiyo ikiwa data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## Sudo isiyo na nenosiri

Wakati mwingine unataka `sudo` iache kuomba, mara nyingi zaidi wakati wakala wa AI anafanya sehemu ndefu ya kazi ya mfumo kwa ajili yako. _Mipangilio > Usalama > Sudo Isiyo na Nenosiri_ huuliza kwa muda gani wa kuruhusu ufikiaji: **dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Aikoni nyekundu ya onyo huonekana kando ya viashiria vingine vya upau wa menyu wakati ufikiaji unaendelea. Ibofye au endesha amri tena ili kuzima ufikiaji. Unaweza pia kupitisha idadi yako mwenyewe ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au utumie `omarchy-sudo-passwordless permanent`.

Ufikiaji wenye muda huisha wenyewe kiotomatiki, ikiwa ni pamoja na mara tu baada ya kuendelea kutoka katika kusitishwa kulikopita tarehe ya mwisho. Kuwasha upya kompyuta huumaliza mapema. Ufikiaji wa kudumu hunusurika kuwashwa upya na hubaki umewashwa hadi utakapo uzima.

Kusasisha au kuondoa kifurushi cha mipangilio cha Omarchy humaliza ruhusa yoyote ya muda kabla ya usaidizi wake wa kuisha muda kubadilika. Ikiwa amri inaripoti hitilafu ya uidhinishaji au ya usafishaji, itatue kabla ya kujaribu kuwasha ruhusa nyingine; hitilafu haimaanishi kuwa ufikiaji usio na nenosiri haufanyi kazi.

Kuwa macho kuhusu hili: ukiwa umewashwa, kitu chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuombwa. Hiyo ndiyo maana yake yote, na hiyo pia ndiyo hatari yake yote.

## Funguo za Kusaini

Ufunguo wa umma wa saini zote za ISO na kifurushi cha hazina ya Omarchy ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Kifurushi cha `omarchy/omarchy-keyring` pia kina ufunguo huu na kitatumika kusambaza masasisho yoyote yanayoweza kutokea bila matatizo.

Unaweza kupata saini ya toleo lolote la ISO kwa kuongeza `.sig` kwenye URL yake, kama `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
