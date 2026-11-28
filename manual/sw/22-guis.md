# GUIs

## Files

Files (Folio) ni kidhibiti cha faili cha picha. `Super + Shift + F` hukifungua, na `Super + Shift + Alt + F` hukifungua katika saraka ambayo terminal yako ipo kwa sasa, jambo linalokuokoa kubofya mara nyingi. `Ctrl + L` hukuwezesha kuandika njia, na kubofya `Space` kwenye faili yoyote huihakiki kwa ukubwa kamili bila kuifungua.

Chomeka kijiti cha USB au kadi ya SD na hupachikwa kiotomatiki, kwa hiyo huonekana tu kwenye utepe. Kwa jambo lolote gumu zaidi — kuumbiza diski, kuangalia afya ya SMART, kuunda vigawanyo — zindua _Disks_ kutoka kwenye kizindua programu (`Super + Space`).

Diski iliyosimbwa kwa njia fiche huomba nenosiri lake inapochomekwa. Ili moja ijifungue yenyewe, iongezee keyfile kwa `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` na uweke keyfile hiyo katika `~/.config/omarchy/drive-keys/<UUID>`, ikitajwa kwa UUID ambayo `lsblk -dno UUID /dev/sdX1` huchapisha kwa sehemu ya diski iliyosimbwa kwa njia fiche, na iwe inasomeka na wewe tu (`chmod 600`). Kama keyfile hiyo haipo au imekataliwa, unaombwa nenosiri kama kawaida.

Kubofya mara mbili kunafuata chaguo-msingi zenye mantiki: picha, video, na muziki hufunguka katika Omaview, PDF katika Document Viewer, Markdown katika Omawrite, na maandishi ya kawaida katika kihariri chako, Plain isipokuwa ukichagua kingine chini ya _Setup > Defaults > Editor_.

## Disktree

Wakati diski inajaa na huna wazo kabisa ni nini kinachoila, zindua [Disktree](https://github.com/tobi/disktree) kutoka kwenye kizindua programu (`Super + Space`). Huonyesha treemap ya picha ya saraka yako ya nyumbani. Vitalu vikubwa huchukua nafasi zaidi; tembea ndani ya saraka kwa kibodi au kipanya, weka alama kwenye vinavyopaswa kuondoka, na hakiki chaguo zako kabla ya kuondoa chochote. Tekeleza `disktree --disk` kuchanganua diski nzima.

## Obsidian

[Obsidian](https://obsidian.md/) ni programu ya kuchukua madokezo isiyolipishwa na inayoweza kupanuliwa sana inayotumia faili rahisi za Markdown kwa hifadhi.

Obsidian ni bure kwa madhumuni yote, ikiwa ni pamoja na matumizi ya kibinafsi, ya kibiashara, na yasiyo ya faida.

Obsidian pia hutoa [nyongeza ya kibiashara ya kusawazisha](https://obsidian.md/sync) na programu za simu kwenye iOS na Android. (https://obsidian.md/pricing).

Unaianzisha Obsidian kwa `Super + Shift + O`. Ili kutumia usawazishaji wa mandhari, lazima uchague mandhari ya `Omarchy` chini ya mipangilio.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ni programu ya Omarchy yenyewe rahisi kabisa ya kuandika Markdown. Hakuna vault, hakuna plugin, ni wewe na maneno tu.

Unaianzisha Omawrite kwa `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ni zana ya msingi ya kuhariri picha iliyo bora kwa kukata, kubadilisha ukubwa, na uhariri mwingine wa kawaida. Usitarajie tu mbadala wa Photoshop. Lakini bado ina Magic Wand na tabaka!

Unaianzisha Pinta kupitia kizindua programu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ni programu ya mandhari inayoweza kutoa rangi kutoka kwenye picha ya mandharinyuma na kuzigeuza kuwa mandhari kamili na yenye uwiano. Ni njia rahisi zaidi ya [kutengeneza mandhari yako mwenyewe](43-making-your-own-theme.md).

Unaianzisha Aether kupitia kizindua programu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) hukuwezesha kutuma faili kwa vifaa vingine vilivyo kwenye mtandao mmoja vinavyotumia programu hiyo, kama AirDrop ya Apple. Hata hivyo inafanya kazi kwenye majukwaa mbalimbali, kwa hiyo unaweza kutuma faili kwenda na kutoka Windows, macOS, Android, iOS, na bila shaka Linux.

Unaweza kufungua menyu ya Share kwa `Super + Ctrl + S` au chini ya _Trigger > Share_ katika menyu ya Omarchy. Inakupa chaguo nne:

- **Clipboard** hutuma chochote ulichonakili kama faili ya maandishi. Bora kwa kuweka kiungo au kipande cha maandishi kwenye simu yako bila kujitumie barua pepe.
- **File** hufungua kichagua faili ambapo unaweza kuchagua kadhaa kwa wakati mmoja.
- **Folder** hutuma saraka nzima.
- **Receive** hufungua LocalSend yenyewe ili kifaa kingine kiweze kukutumia kitu.

Jambo hilo hilo hufanya kazi kutoka kwenye terminal kwa `omarchy share clipboard`, `omarchy share file [path]`, na `omarchy share folder [path]`. Acha njia na utapata kichaguzi.

Unaweza pia kutuma moja kwa moja kutoka kwenye kidhibiti cha faili: bofya kulia chaguo lolote katika Files na ukishiriki na LocalSend.

Firewall ya Omarchy imefungwa kwa chaguo-msingi isipokuwa port ya LocalSend, kwa hiyo hii hufanya kazi moja kwa moja kwenye usakinishaji mpya. Tazama [usalama](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ni kifurushi kamili cha ofisi chenye kichakata maneno, lahajedwali, mawasilisho, programu ya kuchora, na zaidi. Inaoana na faili kutoka Microsoft Office, kwa hiyo hii ni njia bora ya kuweza kufungua nyaraka hizo za Word.

Unaianzisha LibreOffice kupitia kizindua programu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ni programu ya Omarchy yenyewe rahisi kabisa ya mawasilisho. Deck yako ni faili moja ya Markdown ikiwa na picha na video zake kando yake: andika kila slaidi chini ya hakiki ya moja kwa moja, buruta slaidi katika mpangilio, kisha wasilisha kwa skrini nzima au hamisha hadi PDF na PowerPoint. Hata huchukua mandhari yako ya Omarchy.

Unaianzisha Hype kupitia kizindua programu (`Super + Space`). Bofya `?` ndani yake kuona kila njia ya mkato.

## Signed

[Signed](https://github.com/omacom/signed) ni njia ya Omarchy yenyewe rahisi kabisa ya kutia saini PDF na kuzijaza. Weka saini yako iliyohifadhiwa, maandishi, na tarehe ya leo popote kwenye ukurasa, kisha hifadhi nakala iliyotiwa saini kando ya asili. Tazama [Kujaza PDF](27-filling-out-pdfs.md) kwa jinsi ya kufanya.

Unaianzisha Signed kupitia kizindua programu (`Super + Space`), au fungua PDF nayo kutoka kwenye kidhibiti cha faili.

## Game Vibes

Game Vibes, katika kizindua programu (`Super + Space`), ndipo michezo midogo ya Omarchy inapoishi: Checkmate, mchezo wa chesi wa 3D dhidi ya rafiki au mpinzani aliyejengwa ndani; Cards, solitaire ya Klondike; Death Wish, mchezo wa majukwaa sahihi kwa pikseli wenye vyumba kumi vilivyojaa miiba na misumeno; na Neon Swarm, mchezo wa arcade wa upigaji risasi. Kila moja ni ukurasa mmoja wa wavuti unaofuata mandhari yako. Chagua moja kwa mishale na `Enter`, na urudi kwenye orodha kwa `Esc` kutoka kwenye skrini ya kichwa ya mchezo au `Q` wakati umesitishwa. Hufunguka kwa skrini nzima: `Super + F` huifanya kuwa dirisha, na `Super + W` huifunga.

Michezo unayoitengeneza na agent pia huonekana hapa: chagua _Make something cool → Game_ katika paneli ya agents na ueleze moja, au taja mchezo ambao tayari upo katika Game Vibes ili kuendelea kuufanyia kazi. Agent hunakili katika `~/Games/vibes`, ambapo ni yako kubadilisha, na huifungua inapomaliza. Unaweza kutengeneza nakala hiyo mwenyewe kwa `omarchy games vibes copy <game>`. Mchezo anaoshiriki mtu mwingine husakinika kama mandhari: chagua _Install > Gaming > Game Vibes_ na ubandike anwani yake ya git, au tekeleza `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ huondoa moja tena, na _Update > Game Vibes Games_ huleta matoleo mapya. Michezo hupakia three.js kutoka kwenye wavuti, kwa hiyo inahitaji muunganisho ili kuanza.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ni kikokotoo cha Omarchy chenyewe rahisi kabisa, kinachofunguka katika dirisha linaloelea.

Unaianzisha Omacalc kwa `Super + Shift + Q` (au kitufe cha kikokotoo, kama kibodi yako ina kimoja).

## Signal

[Signal](https://signal.org/) ni mwanzilishi wa ujumbe uliosimbwa kwa njia fiche wa E2E, na chaguo bora la mawasiliano kwa mtu yeyote anayependelea kutoipitia moja ya makampuni makubwa ya teknolojia.

Unaianzisha Signal kwa `Super + Shift + G`. Si sehemu ya usakinishaji wa msingi, kwa hiyo mara ya kwanza unapobofya hiyo, Omarchy itajitolea kukusakinishia (pia ipo chini ya _Install > Service_ katika menyu ya Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) ni kitazama picha na kicheza media cha Omarchy chenyewe rahisi kabisa: dirisha moja kwa picha, video, na muziki wako. Fungua picha na vitufe vya mishale hupita kwenye saraka yake iliyobaki, `N` na `P` hufanya hivyo kwa chochote, na `Ctrl + M` huonyesha saraka nzima kama gridi. Huonyesha picha za HEIC, AVIF, na JPEG XL pia, na huendelea ulipoishia katika kitu chochote kirefu.

Bofya `F` kwa skrini nzima, `E` kuhariri picha katika Omasnap au kukata video katika Omacut, `Ctrl + P` kuchapisha picha, na `Delete` kuhamisha faili kwenda kwenye Trash (`Ctrl + Z` huirudisha). Bofya `?` ndani yake kuona kila njia ya mkato.

Unaianzisha Omaview kama _Media Viewer_ kupitia kizindua programu (`Super + Space`), au bofya mara mbili tu picha, video, au wimbo katika kidhibiti cha faili.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ni kikata video cha Omarchy chenyewe rahisi kabisa. Wakati unachohitaji ni kukata mwanzo na mwisho wa klipu, kinashinda kuwasha kihariri kamili cha video.

Unaianzisha Omacut kupitia kizindua programu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ni kinasa cha webcam cha Omarchy chenyewe rahisi kabisa. Chagua kamera na maikrofoni yako mara moja, kisha bofya `Space` kurekodi, na tena kusitisha na kuendelea na rekodi hiyo hiyo. Daima hurekodi kwa ubora wa juu zaidi wa kamera yako, ikiwa na mita ya maikrofoni ya moja kwa moja ili uweze kuangalia viwango vyako kabla ya kuanza.

Simamisha rekodi na hufunguka mara moja katika kihariri kilichojengwa ndani. Bofya mara mbili klipu kuigawanya, buruta vishikio kukata kila kipande, na uondoe sehemu usizozitaka. Kisha ihifadhi kama MP4. Rekodi yako ya asili huhifadhiwa hadi utakapoiondoa, kwa hiyo unaweza kurudi daima na kuikata tofauti.

Unaianzisha Monologue kupitia kizindua programu (`Super + Space`).
