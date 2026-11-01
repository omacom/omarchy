# Grafiskās lietotnes

## Faili

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, bet `Super + Shift + Alt + F` to atver direktorijā, kurā pašlaik atrodas tavs terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, bet, nospiežot `Space` uz jebkura faila, iegūsi ātru priekšskatījumu, neko neatverot.

Pieslēdz USB atmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc vienkārši parādās sānjoslā. Sarežģītākiem darbiem — diska formatēšanai, SMART veselības pārbaudei, nodalījumu izveidei — palaid _Disks_ no lietotņu palaidēja (`Super + Space`).

Veicot dubultklikšķi, tiek ievēroti saprātīgi noklusējumi: attēli atveras imv, video — mpv, PDF — Document Viewer, bet vienkāršs teksts — Neovim.

## Disktree

Kad disks ir pilns un tev nav ne jausmas, kas to apēd, palaid [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas parāda grafisku tavas mājas direktorijas koka karti. Lielāki bloki aizņem vairāk vietas; pārvietojies pa direktorijām ar tastatūru vai peli, atzīmē, kam jāiet, un pirms kaut ko dzēs, pārskati savu izvēli. Palaid `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu papildinājumu sinhronizācijai](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android. (https://obsidian.md/pricing).

Tu palaid Obsidian ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizāciju, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša pavisam vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai tu un vārdi.

Tu palaid Omawrite ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas ir lieliski piemērots apgriešanai, izmēru maiņai un citām vienkāršām manipulācijām. Tikai negaidi Photoshop alternatīvu. Bet tajā tomēr ir Magic Wand un slāņi!

Tu palaid Pinta caur lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu veidošanas lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, vienotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Tu palaid Aether caur lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi Apple AirDrop. Taču tā ir starpplatformu, tāpēc vari sūtīt failus uz Windows, macOS, Android, iOS un, protams, Linux, un saņemt no tām.

Kopīgošanas izvēlni vari atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Trigger > Share_. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esi nokopējis, kā teksta failu. Lieliski, lai tiktu pie saites vai fragmenta savā telefonā, nesūtot sev e-pastu.
- **File** atver failu atlasītāju, kurā vari izvēlēties vairākus uzreiz.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu kaut ko nosūtīt tev.

Tas pats darbojas arī no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Atstāj ceļu tukšu, un iegūsi atlasītāju.

Vari sūtīt arī tieši no failu pārvaldnieka: ar labo pogu noklikšķini uz jebkuras izvēles Nautilus un izvēlies _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas darbojas uzreiz pēc uzstādīšanas. Skati [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīga biroja pakete ar teksta apstrādi, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl daudz ko citu. Tā ir saderīga ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā atvērt tos Word dokumentus.

Tu palaid LibreOffice caur lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša pavisam vienkāršā prezentāciju lietotne. Tavs materiāls ir viens Markdown fails, kuram blakus atrodas tā attēli un video: raksti katru slaidu zem tiešā priekšskatījuma, sakārto slaidus, velkot tos vajadzīgajā secībā, pēc tam prezentē pilnekrānā vai eksportē uz PDF un PowerPoint. Tā pat pārņem tavu Omarchy tēmu.

Tu palaid Hype caur lietotņu palaidēju (`Super + Space`). Nospied `?` tajā, lai redzētu visus saīsnes taustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša pavisam vienkāršais veids, kā parakstīt PDF un tos aizpildīt. Novieto savu saglabāto parakstu, tekstu un šodienas datumu jebkur uz lapas, pēc tam saglabā parakstītu kopiju blakus oriģinālam. Skati [PDF aizpildīšana](27-filling-out-pdfs.md), lai uzzinātu, kā.

Tu palaid Signed caur lietotņu palaidēju (`Super + Space`) vai atver ar to PDF no failu pārvaldnieka.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša pavisam vienkāršais kalkulators, kas atveras peldošā logā.

Tu palaid Omacalc ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja tavai tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētās ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur kādu no lielajiem tehnoloģiju konglomerātiem.

Tu palaid Signal ar `Super + Shift + G`. Tā nav daļa no pamata instalācijas, tāpēc pirmo reizi, nospiežot šo kombināciju, Omarchy piedāvās to instalēt tavā vietā (tā ir arī Omarchy izvēlnē sadaļā _Install > Service_).

## mpv

[mpv](https://mpv.io/) ir vienkāršs, ātrs multivides atskaņotājs, kas atskaņos gandrīz jebko no jebkura avota. Lieliski piemērots video skatīšanai.

Tu palaid mpv caur lietotņu palaidēju (`Super + Space`) vai vienkārši veic dubultklikšķi uz video failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša pavisam vienkāršais video apgriezējs. Kad tev vajag tikai nogriezt klipa sākumu un beigas, tas pārspēj pilnvērtīga video redaktora palaišanu.

Tu palaid Omacut caur lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša pavisam vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlies kameru un mikrofonu, pēc tam nospied `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu ierakstu. Tas vienmēr ieraksta kameras augstākajā izšķirtspējā, ar tiešo mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Pārtrauc ierakstu, un tas uzreiz atveras iebūvētajā redaktorā. Veic dubultklikšķi uz klipa, lai to sadalītu, velc rokturus, lai apgrieztu katru daļu, un noņem daļas, kuras nevēlies. Pēc tam saglabā to kā MP4. Tavs oriģinālais ieraksts tiek saglabāts, līdz tu to izmet, tāpēc vienmēr vari atgriezties un sagriezt to citādi.

Tu palaid Monologue caur lietotņu palaidēju (`Super + Space`).
