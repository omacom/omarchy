# Usalama

Omarchy inachukulia usalama kwa uzito wa hali ya juu sana. Huu unakusudiwa kuwa mfumo wa uendeshaji unaoweza kuutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza laptop hakuwezi kusababisha dharura ya usalama. Kwa hiyo hivi ndivyo tunavyofanya:

1. *Usimbaji fiche wa diski nzima umewashwa kama chaguo-msingi*: Huu ndio hatua muhimu zaidi ya kulinda usalama wa kimwili wa data yako. Ikiwa kompyuta yako imepotea au imeibwa, data imefanyiwa usimbaji fiche kikamilifu kwa kutumia LUKS (Linux Unified Key Setup) ya kawaida. Kisakinishaji kinakuruhusu kuchagua kutotumia kwenye mashine za kutupa (tazama [Kuanza](02-getting-started.md)); usakinishaji usio na usimbaji fiche hauna ulinzi huu wowote, na yeyote aliye na hifadhi anaweza kuisoma.
2. *Ngome imewashwa kama chaguo-msingi*: Trafiki yote inayoingia imezuiwa kama chaguo-msingi, isipokuwa chache: mlango 53317 kwa [LocalSend](https://localsend.org/); hoja za DNS kwenda kwenye kisuluhishi cha kompyuta yenyewe kilicho kwenye anwani ya daraja la Docker (172.17.0.1), zinazokubaliwa kutoka kwenye masafa ya anwani za faragha ambazo Docker huzipa kontena zake; na multicast DNS (mlango 5353), ambayo huruhusu vichapishi na vifaa vingine kwenye mtandao wako kupatana na pia hutangaza jina la kompyuta yako huko. Zaidi ya hizo, ngome huendeleza ruhusa za kawaida za UFW za ping, kupata anwani kutoka kwenye kipanga njia chako (DHCP), na ugunduzi wa UPnP. Hata ssh imezimwa hadi utakapoiwasha kupitia _Mipangilio > Usalama > SSHD_, ambayo hufungua mlango 22 (uliowekewa kikomo cha kasi dhidi ya brute force) kama sehemu ya usanidi. Tunalinda pia ufikiaji wa Docker kwa kutumia usanidi wa [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia kontena zako zisiwekwe wazi kwa ulimwengu kwa bahati mbaya.
3. *Arch huwa na masasisho ya hivi punde zaidi kila wakati*: Arch, distro ya msingi ambayo Omarchy imejengwa juu yake, ni usambazaji unaoendelea kusasishwa. Hii inamaanisha kuwa udhaifu wowote wa usalama unaogunduliwa na kurekebishwa katika kifurushi chochote unapatikana haraka kwa usakinishaji kwa kutumia `omarchy-update`. Kwa namna hiyo unatumia matoleo ya hivi punde zaidi na salama zaidi ya kila kitu kila wakati.
4. *Omarchy hudumisha vifurushi vyake na kioo chake*: Kama chaguo-msingi, Omarchy hutegemea tu vifurushi kutoka kwenye hazina za Arch zenyewe za core/extra/multilib na Hazina yake mwenyewe ya Vifurushi vya Omarchy. Unaweza kusakinisha programu moja kwa moja kutoka AUR, lakini usakinishaji wa msingi haufanyi hivyo — ni usakinishaji wa hiari michache tu, kama vivinjari vya wahusika wengine, ndio huchukua kutoka AUR.
5. *Cloudflare hutulinda dhidi ya DDoS*: Miundombinu ya usambazaji ya Omarchy — ISO, vifurushi vya Omarchy, kioo cha Arch — inalindwa nyuma ya ngao imara ya DDoS ya Cloudflare na kupangishwa kwenye CDN yao. Hii hutoa upatikanaji bora sana.

## Kubadilisha manenosiri yako

Una manenosiri mawili kwenye usakinishaji ulio na usimbaji fiche: lile linalofungua hifadhi wakati wa kuwasha, na lile unalotumia kuingia na `sudo`. Usanidi huziweka kuwa sawa. Yote mawili yanaweza kubadilishwa chini ya _Sasisho > Nenosiri_ katika menyu ya Omarchy — _Usimbaji Fiche wa Hifadhi_ kwa la kwanza, _Mtumiaji_ kwa la pili. Kubadilisha nenosiri la hifadhi huomba la sasa kwanza, kwa hiyo liweke karibu. Ikiwa mabadiliko yataingiliwa, endesha _Usimbaji Fiche wa Hifadhi_ tena: huomba nenosiri linalofungua hifadhi sasa na kukamilisha mabadiliko.

## Kukabidhi mashine ambayo tayari umeitumia

Ikiwa unakabidhi mashine yako kwa mtu mwingine, si lazima uisakinishe upya. Endesha _Ondoa > Weka Upya Kama Kiwandani_ katika menyu ya Omarchy, andika `reset` ili kuthibitisha, na uwashe upya. Hiyo hufuta kila akaunti ya mtumiaji na kila kitu kilicho katika `/home`, huondoa vifurushi vyote na mabadiliko ya mfumo uliyofanya tangu usakinishaji, na kufuta utambulisho wa mashine — miunganisho ya mtandao, funguo za mwenyeji, na kila kitu. Kinachojitokeza tena ni mchawi wa usanidi kutoka kuwasha kwa mara ya kwanza, tayari kwa mmiliki wake mpya kuingiza jina lake mwenyewe, nenosiri, na nenosiri la usimbaji fiche.

Inafanya kazi kwa kurejesha picha ya msingi ambayo kisakinishaji huchukua, kwa hiyo inapatikana tu kwenye mashine zilizosakinishwa kutoka ISO ya Omarchy. Na kwenye hifadhi isiyo na usimbaji fiche, kuweka upya ni ufutaji badala ya ufutaji salama, kwa hiyo ikiwa data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## Sudo isiyo na nenosiri

Wakati mwingine unataka `sudo` iache kuomba, mara nyingi zaidi wakati wakala wa AI anapokufanyia kazi ndefu ya mfumo. _Mipangilio > Usalama > Sudo Isiyo na Nenosiri_ huuliza kwa muda gani wa kuruhusu ufikiaji: **dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Ikoni nyekundu ya onyo huonekana kando ya viashiria vingine vya upau wa menyu wakati ufikiaji unatumika. Ibofye au endesha amri tena ili kuzima ufikiaji. Unaweza pia kupitisha idadi yako mwenyewe ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au tumia `omarchy-sudo-passwordless permanent`.

Ufikiaji wenye muda hupita muda wake kiotomatiki, ikiwa ni pamoja na mara tu baada ya kuendelea kutoka kwenye kusimamishwa kulikopita tarehe ya mwisho. Kuwasha upya kompyuta huumaliza mapema. Ufikiaji wa kudumu hudumu kupitia kuwasha upya na hubaki umewashwa hadi utakapoulemaza.

Kusasisha au kuondoa kifurushi cha mipangilio cha Omarchy humaliza ruhusa yoyote ya muda kabla ya usaidizi wake wa kupita muda kubadilika. Ikiwa amri itaripoti hitilafu ya uidhinishaji au usafishaji, itatue kabla ya kujaribu kuwasha ruhusa nyingine; hitilafu haimaanishi kuwa ufikiaji usio na nenosiri hauko hai.

Uwe macho wazi kuhusu hili: ukiwa umewashwa, chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuombwa. Hiyo ndiyo maana nzima, na hiyo pia ndiyo hatari nzima.

## Funguo za Kutia Saini

Funguo ya umma ya saini zote za ISO na vifurushi vya hazina ya Omarchy ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Kifurushi cha `omarchy/omarchy-keyring` kinayo pia na kitatumika kusambaza masasisho yoyote yanayowezekana bila matatizo.

Unaweza kupata saini ya toleo lolote la ISO kwa kuongeza `.sig` kwenye URL yake, kama `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
