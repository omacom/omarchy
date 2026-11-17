# GUIs

## Faili

Faili (Nautilus) ndio kidhibiti faili cha picha. `Super + Shift + F` huifungua, na `Super + Shift + Alt + F` huifungua katika saraka ambayo terminali yako iko kwa sasa, jambo linalokuokoa kubofya mara nyingi. `Ctrl + L` hukuwezesha kuandika njia, na kubonyeza `Space` kwenye faili yoyote hukupa hakikisho la haraka bila kufungua chochote.

Chomeka kifaa cha USB au kadi ya SD na hupachikwa kiotomatiki, hivyo huonekana tu kwenye utepe. Kwa jambo lolote gumu zaidi — kuumbiza diski, kuangalia afya ya SMART, kuunda partitions — anzisha _Disks_ kutoka kwenye kianzisha programu (`Super + Space`).

Kubofya mara mbili hufuata chaguo-msingi zinazoeleweka: picha, video, na muziki hufunguka katika Omaview, PDF katika Document Viewer, Markdown katika Omawrite, na maandishi ya kawaida katika kihariri kilichochaguliwa chini ya _Setup > Default > Editor_.

## Disktree

Diski inapokuwa imejaa na huna wazo lolote kuhusu kinachoila, anzisha [Disktree](https://github.com/tobi/disktree) kutoka kwenye kianzisha programu (`Super + Space`). Huonyesha ramani ya picha ya umbo la mti ya saraka yako ya nyumbani. Vitalu vikubwa huchukua nafasi zaidi; tembea ndani ya saraka kwa kutumia kibodi au kipanya, weka alama kwenye vinavyopaswa kwenda, na pitia chaguo zako kabla ya kuondoa chochote. Tekeleza `disktree --disk` kuchanganua diski nzima.

## Obsidian

[Obsidian](https://obsidian.md/) ni programu ya kuandika madokezo isiyolipishwa na inayoweza kupanuliwa sana inayotumia faili rahisi za Markdown kwa kuhifadhi.

Obsidian ni bure kwa madhumuni yote, ikiwa ni pamoja na matumizi ya kibinafsi, ya kibiashara, na yasiyo ya faida.

Obsidian pia inatoa [nyongeza ya kibiashara ya kusawazisha](https://obsidian.md/sync) na programu za simu kwenye iOS na Android. (https://obsidian.md/pricing).

Unaanzisha Obsidian kwa `Super + Shift + O`. Ili kutumia usawazishaji wa mandhari, lazima uchague mandhari ya `Omarchy` chini ya mipangilio.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ni programu ya Omarchy yenyewe rahisi kabisa ya kuandika Markdown. Hakuna vaults, hakuna plugins, ni wewe tu na maneno.

Unaanzisha Omawrite kwa `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ni zana ya msingi ya kuhariri picha ambayo ni nzuri kwa kukata, kubadilisha ukubwa, na ujanja mwingine wa msingi. Usitarajie tu mbadala wa Photoshop. Lakini bado ina Magic Wand na layers!

Unaanzisha Pinta kupitia kianzisha programu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ni programu ya mandhari inayoweza kutoa rangi kutoka kwenye picha ya mandharinyuma na kuzigeuza kuwa mandhari kamili na yenye uwiano. Ndio njia rahisi zaidi ya [kutengeneza mandhari yako mwenyewe](43-making-your-own-theme.md).

Unaanzisha Aether kupitia kianzisha programu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) hukuwezesha kutuma faili kwa vifaa vingine vilivyo kwenye mtandao huohuo vinavyoendesha programu hiyo, kama AirDrop ya Apple. Ni ya majukwaa mengi, hata hivyo, hivyo unaweza kutuma faili kwenda na kutoka Windows, macOS, Android, iOS, na bila shaka Linux.

Unaweza kufungua menyu ya Share kwenye `Super + Ctrl + S` au chini ya _Trigger > Share_ katika menyu ya Omarchy. Hukupa chaguo nne:

- **Clipboard** hutuma chochote ulichonakili kama faili ya maandishi. Ni nzuri kwa kupeleka kiungo au kipande cha maandishi kwenye simu yako bila kujitumIa barua pepe.
- **File** hufungua kichagua faili ambapo unaweza kuchagua kadhaa mara moja.
- **Folder** hutuma saraka nzima.
- **Receive** hufungua LocalSend yenyewe ili kifaa kingine kiweze kukutumia kitu.

Jambo hilohilo hufanya kazi kutoka kwenye terminali kwa `omarchy share clipboard`, `omarchy share file [path]`, na `omarchy share folder [path]`. Acha njia na utapata kichaguzi.

Unaweza pia kutuma moja kwa moja kutoka kwenye kidhibiti faili: bofya kulia chaguo lolote katika Nautilus na uchague _Send via LocalSend_.

Firewall ya Omarchy imefungwa kwa chaguo-msingi isipokuwa kwa port ya LocalSend, hivyo hii hufanya kazi mara moja kwenye usakinishaji mpya. Tazama [usalama](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ni kifurushi kamili cha ofisi chenye kichakataji maneno, lahajedwali, mawasilisho, programu ya kuchora, na zaidi. Inaoana na faili kutoka Microsoft Office, hivyo hii ni njia nzuri ya kuweza kufungua nyaraka hizo za Word.

Unaanzisha LibreOffice kupitia kianzisha programu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ni programu ya Omarchy yenyewe rahisi kabisa ya mawasilisho. Wasilisho lako ni faili moja ya Markdown yenye picha na video zake kando yake: andika kila slaidi chini ya hakikisho la moja kwa moja, buruta slaidi katika mpangilio, kisha wasilisha kwa skrini nzima au hamisha hadi PDF na PowerPoint. Hata huchukua mandhari yako ya Omarchy.

Unaanzisha Hype kupitia kianzisha programu (`Super + Space`). Bonyeza `?` ndani yake kuona kila njia ya mkato.

## Signed

[Signed](https://github.com/omacom/signed) ni njia ya Omarchy yenyewe rahisi kabisa ya kusaini PDF na kuzijaza. Weka sahihi yako iliyohifadhiwa, maandishi, na tarehe ya leo popote kwenye ukurasa, kisha hifadhi nakala iliyosainiwa kando ya ile asilia. Tazama [Kujaza PDF](27-filling-out-pdfs.md) kwa jinsi ya kufanya.

Unaanzisha Signed kupitia kianzisha programu (`Super + Space`), au unafungua PDF nayo kutoka kwenye kidhibiti faili.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ni mchezo wa Omarchy wenyewe wa sataranji wa 3D. Cheza na rafiki kwenye kompyuta hiyohiyo au mpinzani aliyejengwa ndani katika viwango vitatu, kwenye seti nne zilizochongwa ambazo kila moja husogea kwa namna yake: vyombo vya angani, mbao na pembe za ndovu zilizochongwa, viumbe wa msituni, na pipi. Michezo haina saa na huhifadhiwa baada ya kila sogezo.

Unaanzisha Checkmate kupitia kianzisha programu (`Super + Space`), ambapo imeorodheshwa kama Chess. Bonyeza `?` ndani yake kuona kila njia ya mkato.

## Cards

[Cards](https://github.com/omacom/cards) ni Klondike solitaire ya Omarchy yenyewe. Chora tatu, bila kikomo cha kupita, katika mfululizo minne ya kadi: mmoja umechorwa kwa rangi za mandhari yako, na mitatu yenye mwonekano wake yenyewe. Bofya kadi kisha pale inapoenda, iburute, au ubofye mara mbili kuituma mahali bora zaidi. Michezo huhifadhiwa baada ya kila sogezo.

Unaanzisha Cards kupitia kianzisha programu (`Super + Space`). Bofya jina lake, au bonyeza `?`, kuona kila njia ya mkato.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ni kikokotoo cha Omarchy chenyewe rahisi kabisa, ambacho hufunguka katika dirisha linaloelea.

Unaanzisha Omacalc kwa `Super + Shift + Q` (au kitufe cha kikokotoo, ikiwa kibodi yako inacho).

## Signal

[Signal](https://signal.org/) ni mwanzilishi wa ujumbe uliosimbwa kwa E2E, na chaguo zuri la mawasiliano kwa yeyote ambaye angependelea kutopitia mojawapo ya makampuni makubwa ya teknolojia.

Unaanzisha Signal kwa `Super + Shift + G`. Sio sehemu ya usakinishaji wa msingi, hivyo mara ya kwanza unapobonyeza hiyo, Omarchy itakupa kuisakinisha kwa ajili yako (pia iko chini ya _Install > Service_ katika menyu ya Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) ni kitazama picha na kicheza media cha Omarchy chenyewe rahisi kabisa: dirisha moja kwa picha, video, na muziki wako. Fungua picha na vitufe vya mishale hupita kupitia zilizobaki katika folda yake, `N` na `P` hufanya hivyo kwa chochote, na `Ctrl + M` huonyesha folda nzima kama gridi. Huonyesha picha za HEIC, AVIF, na JPEG XL pia, na huendelea pale ulipoachia katika chochote kirefu.

Bonyeza `F` kwa skrini nzima, `E` kuhariri picha katika Omasnap au kupunguza video katika Omacut, `Ctrl + P` kuchapisha picha, na `Delete` kuhamisha faili hadi kwenye Trash (`Ctrl + Z` huirudisha). Bonyeza `?` ndani yake kuona kila njia ya mkato.

Unaanzisha Omaview kama _Media Viewer_ kupitia kianzisha programu (`Super + Space`), au bofya tu mara mbili picha, video, au wimbo katika kidhibiti faili.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ni kipunguza video cha Omarchy chenyewe rahisi kabisa. Unapohitaji tu kukata mwanzo na mwisho wa klipu, hushinda kuwasha kihariri kamili cha video.

Unaanzisha Omacut kupitia kianzisha programu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ni kinasa cha kamera ya wavuti cha Omarchy chenyewe rahisi kabisa. Chagua kamera na kipaza sauti chako mara moja, kisha bonyeza `Space` kurekodi, na tena kusitisha na kuendelea na rekodi hiyohiyo. Daima hurekodi kwa ubora wa juu zaidi wa kamera yako, kukiwa na kipima kipaza sauti cha moja kwa moja ili uweze kuangalia viwango vyako kabla ya kuanza.

Simamisha rekodi na hufunguka mara moja katika kihariri kilichojengwa ndani. Bofya mara mbili klipu kuigawa, buruta vishikio kupunguza kila kipande, na uondoe sehemu usizozitaka. Kisha uihifadhi kama MP4. Rekodi yako asilia huhifadhiwa hadi utakapoiondoa, hivyo unaweza kurudi kila wakati na kuikata kwa namna tofauti.

Unaanzisha Monologue kupitia kianzisha programu (`Super + Space`).
