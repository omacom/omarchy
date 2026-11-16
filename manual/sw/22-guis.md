# GUIs

## Files

Files (Nautilus) ni kidhibiti faili cha kimchoro. `Super + Shift + F` huifungua, na `Super + Shift + Alt + F` huifungua katika saraka ambayo terminal yako iko, jambo linalokuokoa kubofya mara nyingi. `Ctrl + L` hukuruhusu kuandika njia, na kubonyeza `Space` kwenye faili yoyote hukupa hakikisho la haraka bila kufungua chochote.

Chomeka kifimbo cha USB au kadi ya SD na hupachikwa kiotomatiki, hivyo huonekana tu kwenye upau wa pembeni. Kwa chochote kinachohusisha kazi zaidi — kuumbiza diski, kuangalia afya ya SMART, kuunda partitions — zindua _Disks_ kutoka kwenye kizindua programu (`Super + Space`).

Kubofya mara mbili hufuata chaguomsingi zinazofaa: picha, video, na muziki hufunguka katika Omaview, PDF katika Document Viewer, Markdown katika Omawrite, na maandishi ya kawaida katika kihariri kilichochaguliwa chini ya _Setup > Default > Editor_.

## Disktree

Wakati diski inajaa na huna wazo lolote ni nini kinakula nafasi hiyo, zindua [Disktree](https://github.com/tobi/disktree) kutoka kwenye kizindua programu (`Super + Space`). Huonyesha treemap ya kimchoro ya saraka yako ya nyumbani. Vitalu vikubwa huchukua nafasi zaidi; tembea ndani ya saraka kwa kibodi au kipanya, weka alama kwenye vinavyopaswa kuondoka, na kagua chaguo zako kabla ya kuondoa chochote. Endesha `disktree --disk` kuchanganua diski nzima.

## Obsidian

[Obsidian](https://obsidian.md/) ni programu ya kuandika madokezo isiyolipishwa na inayoweza kupanuliwa sana inayotumia faili rahisi za Markdown kwa kuhifadhi.

Obsidian haina malipo kwa matumizi yote, ikiwa ni pamoja na matumizi ya kibinafsi, ya kibiashara, na yasiyo ya kutafuta faida.

Obsidian pia hutoa [nyongeza ya kibiashara ya kusawazisha](https://obsidian.md/sync) na programu za simu kwenye iOS na Android. (https://obsidian.md/pricing).

Unaanzisha Obsidian kwa `Super + Shift + O`. Ili kutumia usawazishaji wa mandhari, lazima uchague mandhari ya `Omarchy` chini ya mipangilio.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ni programu ya Omarchy yenyewe rahisi kabisa ya kuandika Markdown. Hakuna vaults, hakuna plugins, ni wewe tu na maneno.

Unaanzisha Omawrite kwa `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ni zana ya msingi ya kuhariri picha ambayo ni bora kwa kukata, kubadilisha ukubwa, na mbinu nyingine za msingi. Usitegemee tu kuwa mbadala wa Photoshop. Lakini bado ina Magic Wand na layers!

Unaanzisha Pinta kupitia kizindua programu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ni programu ya mandhari inayoweza kuchukua rangi kutoka kwenye picha ya mandharinyuma na kuzigeuza kuwa mandhari kamili, yenye uwiano. Ni njia rahisi zaidi ya [kutengeneza mandhari yako mwenyewe](43-making-your-own-theme.md).

Unaanzisha Aether kupitia kizindua programu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) hukuwezesha kutuma faili kwa vifaa vingine vilivyo kwenye mtandao mmoja vinavyoendesha programu hiyo, kama AirDrop ya Apple. Hata hivyo, inafanya kazi kwenye mifumo tofauti, hivyo unaweza kutuma faili kwenda na kutoka Windows, macOS, Android, iOS, na bila shaka Linux.

Unaweza kufungua menyu ya Share kwenye `Super + Ctrl + S` au chini ya _Trigger > Share_ katika menyu ya Omarchy. Inakupa chaguo nne:

- **Clipboard** hutuma chochote ulichonakili kama faili ya maandishi. Nzuri kwa kupeleka kiungo au kipande cha maandishi kwenye simu yako bila kujitumia barua pepe.
- **File** hufungua kichagua faili ambapo unaweza kuchagua kadhaa kwa mara moja.
- **Folder** hutuma saraka nzima.
- **Receive** hufungua LocalSend yenyewe ili kifaa kingine kiweze kukutumia kitu.

Vilevile unaweza kufanya hivyo kutoka kwenye terminal kwa `omarchy share clipboard`, `omarchy share file [path]`, na `omarchy share folder [path]`. Acha njia na utapata kichaguzi.

Unaweza pia kutuma moja kwa moja kutoka kwenye kidhibiti faili: bofya kulia uteuzi wowote katika Nautilus na uchague _Send via LocalSend_.

Firewall ya Omarchy imefungwa kwa chaguomsingi isipokuwa kwa port ya LocalSend, hivyo hii inafanya kazi mara moja kwenye usakinishaji mpya. Tazama [usalama](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ni kifurushi kamili cha ofisi chenye kichakata maneno, lahajedwali, mawasilisho, programu ya kuchora, na zaidi. Inaoana na faili kutoka Microsoft Office, hivyo hii ni njia bora ya kuweza kufungua hati hizo za Word.

Unaanzisha LibreOffice kupitia kizindua programu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ni programu ya Omarchy yenyewe rahisi kabisa ya mawasilisho. Deck yako ni faili moja ya Markdown yenye picha na video zake kando yake: andika kila slaidi chini ya hakikisho la moja kwa moja, buruta slaidi katika mpangilio, kisha wasilisha fullscreen au hamisha kwenda PDF na PowerPoint. Hata huchukua mandhari yako ya Omarchy.

Unaanzisha Hype kupitia kizindua programu (`Super + Space`). Bonyeza `?` ndani yake kuona kila njia ya mkato.

## Signed

[Signed](https://github.com/omacom/signed) ni njia ya Omarchy yenyewe rahisi kabisa ya kutia saini PDF na kuzijaza. Weka sahihi yako uliyohifadhi, maandishi, na tarehe ya leo popote kwenye ukurasa, kisha hifadhi nakala iliyotiwa saini kando ya asili. Tazama [Kujaza PDF](27-filling-out-pdfs.md) kuona jinsi ya kufanya hivyo.

Unaanzisha Signed kupitia kizindua programu (`Super + Space`), au fungua PDF nayo kutoka kwenye kidhibiti faili.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ni kikokotoo cha Omarchy chenyewe rahisi kabisa, kinachofunguka katika dirisha linaloelea.

Unaanzisha Omacalc kwa `Super + Shift + Q` (au kitufe cha kikokotoo, ikiwa kibodi yako inacho).

## Signal

[Signal](https://signal.org/) ni mwanzilishi wa ujumbe wenye usimbaji fiche wa E2E, na ni chaguo bora la mawasiliano kwa yeyote anayependelea kutopitia mojawapo ya makampuni makubwa ya teknolojia.

Unaanzisha Signal kwa `Super + Shift + G`. Si sehemu ya usakinishaji wa msingi, hivyo mara ya kwanza unapobonyeza hiyo, Omarchy itapendekeza kukisakinisha kwa ajili yako (pia kiko chini ya _Install > Service_ katika menyu ya Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) ni kitazamaji picha na kicheza media cha Omarchy chenyewe rahisi kabisa: dirisha moja kwa picha, video, na muziki wako. Fungua picha na vitufe vya mishale hupita kwenye zilizobaki katika folda yake, `N` na `P` hufanya hivyo kwa chochote, na `Ctrl + M` huonyesha folda nzima kama gridi. Pia huonyesha picha za HEIC, AVIF, na JPEG XL, na huendelea ulipoachia katika chochote kirefu.

Bonyeza `F` kwa fullscreen, `E` kuhariri picha katika Omasnap au kukata video katika Omacut, `Ctrl + P` kuchapisha picha, na `Delete` kuhamisha faili kwenda Trash (`Ctrl + Z` huirudisha). Bonyeza `?` ndani yake kuona kila njia ya mkato.

Unaanzisha Omaview kama _Media Viewer_ kupitia kizindua programu (`Super + Space`), au bofya mara mbili tu picha, video, au wimbo katika kidhibiti faili.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ni kikata video cha Omarchy chenyewe rahisi kabisa. Unapohitaji tu kukata mwanzo na mwisho wa klipu, kinashinda kuwasha kihariri kamili cha video.

Unaanzisha Omacut kupitia kizindua programu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ni kinasa kamera ya wavuti cha Omarchy chenyewe rahisi kabisa. Chagua kamera na maikrofoni yako mara moja, kisha bonyeza `Space` kurekodi, na tena kusitisha na kuendelea na rekodi hiyo hiyo. Daima hurekodi kwa ubora wa juu zaidi wa kamera yako, kikiwa na kipimo cha moja kwa moja cha maikrofoni ili uweze kuangalia viwango vyako kabla ya kuanza.

Sitisha rekodi na hufunguka mara moja katika kihariri kilichojengwa ndani. Bofya mara mbili klipu kuigawa, buruta vishikizo kukata kila kipande, na ondoa sehemu usizozitaka. Kisha ihifadhi kama MP4. Rekodi yako ya asili huhifadhiwa hadi utakapoiondoa, hivyo unaweza kurudi daima na kuikata tofauti.

Unaanzisha Monologue kupitia kizindua programu (`Super + Space`).
