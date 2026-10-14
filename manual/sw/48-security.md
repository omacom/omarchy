# Usalama

Omarchy huchukulia usalama kwa uzito mkubwa sana. Hii inakusudiwa kuwa mfumo wa uendeshaji ambao unaweza kutumia kufanya _Kazi Halisi_ katika _Ulimwengu Halisi_. Ambapo kupoteza kompyuta mpakato hakuwezi kusababisha dharura ya usalama. Kwa hivyo hivi ndivyo tunavyofanya:

1. *Usimbaji kamili wa diski ni lazima*: Hii ni hatua muhimu zaidi ya kulinda ulinzi wa kimwili wa data yako. Kama kompyuta yako imepotea au imeibiwa, data imesimbwa kikamilifu kwa kutumia LUKS ya kawaida (Linux Unified Key Setup).
2. *Ngome ya moto imewezeshwa kwa chaguomsingi*: Trafiki yote inayoingia imezuiwa kwa chaguomsingi isipokuwa porti 53317 kwa [LocalSend](https://localsend.org/). Hata ssh imezimwa hadi uiwashe kupitia _Sanidi > Usalama > SSHD_, ambayo hufungua porti 22 (kiwango kinachodhibitiwa dhidi ya majaribio ya nguvu) kama sehemu ya usanidi. Tunafunga hata ufikiaji wa Docker kwa kutumia usanidi wa [ufw-docker](https://github.com/chaifeng/ufw-docker) ili kuzuia makasha yako yasiwe wazi ulimwenguni kwa bahati mbaya.
3. *Arch daima ina masasisho ya hivi karibuni*: Arch, distro ya msingi ambayo Omarchy imejengwa juu yake, ni ugawaji unaotiririka (rolling). Hii inamaanisha kuwa udhaifu wowote wa usalama unaogunduliwa na kurekebishwa katika kifurushi chochote unapatikana haraka kwa kusakinisha kwa kutumia `omarchy-update`. Daima unaendesha matoleo ya hivi karibuni, salama zaidi ya kila kitu hivyo.
4. *Omarchy hutunza vifurushi vyake vyenyewe na kioo*: Omarchy hutegemea tu vifurushi kutoka repo za Arch zenyewe za core/extra/multilib na Hifadhi yake ya Vifurushi ya Omarchy kwa chaguomsingi. Unaweza kusakinisha programu moja kwa moja kutoka AUR, lakini usakinishaji wa msingi haufanyi — ni usakinishaji wachache tu wa hiari, kama vivinjari vya watu wengine, huvuta kutoka AUR.
5. *Cloudflare hutulinda na DDoS*: Miundombinu yote ya ugawaji wa Omarchy — ISO, vifurushi vya Omarchy, kioo cha Arch — imelindwa nyuma ya ngao kali ya DDoS ya Cloudflare na kupangishwa kwenye CDN yao. Hii hutoa upatikanaji bora.

## Kubadilisha nywila zako

Una nywila mbili kwenye usakinishaji uliosimbwa: ile inayofungua kiendeshaji wakati wa kuwasha, na ile unayoingia nayo na `sudo`. Usanidi huzifanya kuwa moja. Zote mbili zinaweza kubadilishwa chini ya _Sasisha > Nenosiri_ katika menyu ya Omarchy — _Usimbaji wa kiendeshaji_ kwa la kwanza, _Mtumiaji_ kwa la pili. Kubadilisha nenosiri la kiendeshaji huomba la sasa kwanza, kwa hivyo liweke karibu. Kama mabadiliko yamekatizwa, endesha _Usimbaji wa kiendeshaji_ tena: huomba nenosiri linalofungua kiendeshaji sasa na humaliza mabadiliko.

## Kukabidhi mashine ambayo tayari umeitumia

Kama unakabidhi mashine yako kwa mtu mwingine, huna haja ya kuisakinisha upya. Endesha _Sanidi > Reset Computer_ katika menyu ya Omarchy, chapa `reset` kuthibitisha, na uwashe upya. Hiyo hufuta kila akaunti ya mtumiaji na kila kitu katika `/home`, hutupa vifurushi vyote na mabadiliko ya mfumo uliyoyafanya tangu usakinishaji, na hufuta utambulisho wa mashine — miunganisho ya mtandao, funguo za mwenyeji, na yote. Kinachokuja ni mwongozaji wa usanidi kutoka kuwasha wa kwanza, tayari kwa mmiliki wake mpya kuweka jina lake mwenyewe, nenosiri, na nenosiri la usimbaji.

Hufanya kazi kwa kurejesha picha ya msingi ambayo kisakinishaji huchukua, kwa hivyo inapatikana tu kwenye mashine zilizosakinishwa kutoka ISO ya Omarchy. Na kwenye kiendeshaji bila usimbaji, kuweka upya ni kufuta badala ya kufuta salama, kwa hivyo kama data ilikuwa nyeti, fanya usakinishaji mpya badala yake.

## Sudo bila nenosiri

Wakati mwingine unataka `sudo` iache kuuliza, mara nyingi zaidi wakati ajenti wa AI anakufanyia kazi ndefu ya mfumo. _Sanidi > Usalama > Sudo bila nenosiri_ huuliza ni muda gani wa kuruhusu ufikiaji: **Dakika 15**, **Saa 1**, **Siku 1**, au **Kudumu**. Aikoni nyekundu ya onyo huonekana karibu na viashiria vingine vya upau wa menyu wakati ufikiaji umewashwa. Ibofye au endesha amri tena kuzima ufikiaji. Unaweza pia kupitisha idadi yako ya dakika (kutoka 1 hadi 1440) kwa `omarchy-sudo-passwordless 30`, au kutumia `omarchy-sudo-passwordless permanent`.

Ufikiaji wa muda huisha kiotomatiki, ikiwa ni pamoja na mara moja baada ya kuendelea kutoka kusitisha kulikopita tarehe ya mwisho. Kuwasha upya kompyuta huihitimisha mapema. Ufikiaji wa kudumu hubaki baada ya kuwasha upya na kubaki umewashwa hadi uizime.

Kusasisha au kuondoa kifurushi cha mipangilio cha Omarchy huisha ruzuku yoyote ya muda kabla ya usaidizi wake wa kuisha kubadilika. Kama amri inaripoti hitilafu ya idhini au usafishaji, itatue kabla ya kujaribu kuwezesha ruzuku nyingine; hitilafu haimaanishi ufikiaji bila nenosiri haufanyi kazi.

Kuwa wazi kuhusu hii: wakati imewashwa, chochote kinachoendeshwa kama mtumiaji wako kinaweza kufanya chochote kama root bila kuulizwa. Hiyo ndiyo sababu nzima, na pia ndiyo hatari nzima.

## Funguo za Kutia Sahihi

Ufunguo wa umma kwa sahihi zote za ISO na kifurushi cha repo ya Omarchy ni `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([thibitisha katika openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Kifurushi cha `omarchy/omarchy-keyring` pia kina hii na kitatumika kueneza masasisho yoyote yanayowezekana kwa urahisi.

Unaweza kupata sahihi ya toleo lolote la ISO kwa kuongeza .sig kwenye URL. Kama https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
