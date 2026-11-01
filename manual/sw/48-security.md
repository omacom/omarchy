# Usalama

Omarchy inachukulia usalama kwa uzito mkubwa sana. Hii imekusudiwa kuwa mfumo wa uendeshaji ambao unaweza kuutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza kompyuta mpakato hakuwezi kusababisha dharura ya kiusalama. Kwa hivyo hivi ndivyo tunavyofanya:

1. *Usimbaji fiche wa diski nzima umewashwa kwa chaguo-msingi*: Hii ni hatua muhimu zaidi ya kulinda usalama wa kimwili wa data yako. Ikiwa kompyuta yako imepotea au imeibwa, data imesimbwa kwa fiche kikamilifu kwa kutumia LUKS ya kawaida (Linux Unified Key Setup). Kisakinishi kinakuruhusu kujiondoa kwa mashine za kutupwa (tazama [Kuanza](02-getting-started.md)); usakinishaji usio na usimbaji fiche hauna ulinzi huu wowote, na mtu yeyote aliye na kiendeshi anaweza kuisoma.
2. *Kingo ya mtandao imewashwa kwa chaguo-msingi*: Trafiki yote inayoingia imezuiwa kwa chaguo-msingi, isipokuwa chache: mlango 53317 kwa ajili ya [LocalSend](https://localsend.org/); maswali ya DNS kwenda kwenye kisuluhishi cha kompyuta yenyewe katika anwani ya daraja la Docker (172.17.0.1), yanayokubaliwa kutoka kwenye safu za anwani za faragha ambazo Docker huwapa vyombo vyake; na DNS ya multicast (mlango 5353), ambayo inaruhusu vichapishi na vifaa vingine kwenye mtandao wako kupatana na pia kutangaza jina la kompyuta yako hapo. Zaidi ya hayo, kingo ya mtandao huhifadhi ruhusa za kawaida za UFW kwa ping, kupata anwani kutoka kwa kipanga njia chako (DHCP), na ugunduzi wa UPnP. Hata ssh imezimwa hadi utakapoiwasha kupitia _Setup > Security > SSHD_, ambayo hufungua mlango 22 (imepunguzwa kasi dhidi ya mashambulizi ya nguvu) kama sehemu ya usanidi. Hata tunafunga ufikiaji wa Docker kwa kutumia usanidi wa [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia vyombo vyako visifichuliwe kwa ulimwengu kwa bahati mbaya.
3. *Arch huwa na masasisho ya hivi punde kila wakati*: Arch, distro ya msingi ambayo Omarchy imejengwa juu yake, ni usambazaji unaoendelea. Hii inamaanisha kuwa udhaifu wowote wa kiusalama unaogunduliwa na kurekebishwa katika kifurushi chochote unapatikana haraka kwa usakinishaji kwa kutumia `omarchy-update`. Kwa njia hiyo huwa unaendesha matoleo ya hivi punde, salama zaidi ya kila kitu kila wakati.
4. *Omarchy hudumisha vifurushi na kioo chake chenyewe*: Omarchy hutegemea tu vifurushi kutoka kwenye hazina za Arch zenyewe za core/extra/multilib na Hazina yake yenyewe ya Vifurushi ya Omarchy kwa chaguo-msingi. Unaweza kusakinisha programu moja kwa moja kutoka AUR, lakini usakinishaji wa msingi haufanyi hivyo — ni usakinishaji machache tu wa hiari, kama vivinjari vya wahusika wengine, ndio huchukua kutoka AUR.
5. *Cloudflare hutulinda dhidi ya DDoS*: Miundombinu ya usambazaji ya Omarchy — ISO, vifurushi vya Omarchy, kioo cha Arch — inalindwa nyuma ya ngao imara ya DDoS ya Cloudflare na inapangishwa kwenye CDN yao. Hii hutoa upatikanaji bora wa hali ya juu.

## Kubadilisha nywila zako

Una nywila mbili kwenye usakinishaji uliosimbwa kwa fiche: ile inayofungua kiendeshi wakati wa kuwasha, na ile unayotumia kuingia na `sudo`. Usanidi huziweka ziwe sawa. Zote mbili zinaweza kubadilishwa chini ya _Update > Password_ katika menyu ya Omarchy — _Drive Encryption_ kwa ya kwanza, _User_ kwa ya pili. Kubadilisha nywila ya kiendeshi huomba ya sasa kwanza, kwa hivyo iweke karibu. Ikiwa mabadiliko yataingiliwa, endesha _Drive Encryption_ tena: inaomba nywila inayofungua kiendeshi sasa na kumalizia mabadiliko.

## Kukabidhi mashine ambayo tayari umeitumia

Ikiwa unakabidhi mashine yako kwa mtu mwingine, sio lazima uisakinishe tena. Endesha _Setup > Reset Computer_ katika menyu ya Omarchy, andika `reset` kuthibitisha, na uwashe upya. Hiyo hufuta kila akaunti ya mtumiaji na kila kitu kilicho katika `/home`, hutupa vifurushi vyote na mabadiliko ya mfumo uliyofanya tangu usakinishaji, na hufuta utambulisho wa mashine — miunganisho ya mtandao, funguo za mpangishi, na vyote. Kinachorejea ni mchawi wa usanidi kutoka kwenye uanzishaji wa kwanza, tayari kwa mmiliki wake mpya kuingiza jina lake mwenyewe, nywila, na nywila ya usimbaji fiche.

Inafanya kazi kwa kurejesha taswira ya msingi ambayo kisakinishi huchukua, kwa hivyo inapatikana tu kwenye mashine zilizosakinishwa kutoka kwenye ISO ya Omarchy. Na kwenye kiendeshi kisicho na usimbaji fiche, urejeshaji ni ufutaji badala ya ufutaji salama, kwa hivyo ikiwa data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## sudo isiyo na nywila

Wakati mwingine unataka `sudo` iache kuomba, mara nyingi zaidi wakati wakala wa AI anafanya kazi ndefu ya mfumo kwa ajili yako. _Setup > Security > Passwordless Sudo_ huuliza ni kwa muda gani wa kuruhusu ufikiaji: **dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Ikoni nyekundu ya onyo huonekana kando ya viashiria vingine vya upau wa menyu wakati ufikiaji unaendelea. Bofya au endesha amri tena ili kuzima ufikiaji. Unaweza pia kupitisha idadi yako mwenyewe ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au tumia `omarchy-sudo-passwordless permanent`.

Ufikiaji wa muda huisha kiotomatiki, ikiwa ni pamoja na mara tu baada ya kuendelea kutoka kwenye kusimamishwa kulikopita tarehe ya mwisho. Kuwasha kompyuta upya huumaliza mapema. Ufikiaji wa kudumu hudumu kupitia kuwasha upya na hubaki umewashwa hadi utakapouzima.

Kusasisha au kuondoa kifurushi cha mipangilio cha Omarchy humaliza ruzuku yoyote ya muda kabla ya usaidizi wake wa kuisha kubadilika. Ikiwa amri inaripoti hitilafu ya idhini au usafishaji, isuluhishe kabla ya kujaribu kuwezesha ruzuku nyingine; hitilafu haimaanishi kuwa ufikiaji usio na nywila haufanyi kazi.

Kuwa mwangalifu kuhusu hili: wakati umewashwa, chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuulizwa. Hiyo ndiyo sababu nzima, na pia ndio hatari nzima.

## Funguo za Kutia Sahihi

Ufunguo wa umma kwa sahihi zote za ISO na kifurushi cha hazina ya Omarchy ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Kifurushi cha `omarchy/omarchy-keyring` kina hii pia na kitatumika kusambaza masasisho yoyote yanayowezekana bila mshono.

Unaweza kupata sahihi kwa toleo lolote la ISO kwa kuongeza `.sig` kwenye URL yake, kama `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
