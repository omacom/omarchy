# Grafiskais interfeiss (GUI)

## Files

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, bet `Super + Shift + Alt + F` to atver tajā direktorijā, kurā atrodas jūsu terminālis, un tas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, bet, nospiežot `Space` uz jebkura faila, iegūstat ātru priekšskatījumu, neko neatverot.

Pievienojiet USB zibatmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc vienkārši parādās sānjoslā. Kam sarežģītākam — diska formatēšanai, SMART veselības pārbaudei, nodalījumu veidošanai — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Ar dubultklikšķi viss atveras pēc sakarīgiem noklusējumiem: attēli atveras imv, video — mpv, PDF faili — Document Viewer, bet vienkāršs teksts — Neovim.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas rāda jūsu mājas direktorijas grafisku koka karti (treemap). Lielākie bloki aizņem vairāk vietas; ar tastatūru vai peli ieejiet direktorijās, atzīmējiet, kam jāiet prom, un pirms jebkā noņemšanas pārskatiet savu izvēli. Palaidiet `disktree --disk`, lai skenētu veselu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem mērķiem, ieskaitot personīgu, komerciālu un bezpeļņas lietošanu.

Obsidian piedāvā arī [komerciālu papildinājumu sinhronizācijai](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android vidē. (https://obsidian.md/pricing).

Obsidian palaižat ar `Super + Shift + O`. Lai izmantotu tēmas sinhronizāciju, iestatījumos ir jāizvēlas tēma `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša gaužām vienkāršā Markdown rakstīšanas lietotne. Ne glabātuves (vault), ne spraudņu, tikai jūs un vārdi.

Omawrite palaižat ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas lieliski der apgriešanai, izmēra maiņai un citām pamata manipulācijām. Tikai negaidiet alternatīvu Photoshop. Bet tam joprojām ir burvju nūjiņa un slāņi!

Pinta palaižat no lietotņu palaidēja (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir motīvu veidošanas lietotne, kas spēj izvilkt krāsas no fona attēla un pārvērst tās pilnīgā, saskaņotā tēmā. Tas ir vieglākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaižat no lietotņu palaidēja (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kur darbojas šī lietotne, līdzīgi kā Apple AirDrop. Taču tā ir starpplatformu, tāpēc varat sūtīt failus uz Windows, macOS, Android, iOS un, protams, Linux un saņemt no tiem.

Koplietošanas izvēlni var atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Palaist > Koplietot_. Tas sniedz četras iespējas:

- **Starpliktuve** nosūta visu jūsu nokopēto kā teksta failu. Lieliski, lai saiti vai fragmentu nogādātu tālrunī, nesūtot sev e-pastu.
- **Fails** atver failu atlasītāju, kurā var izvēlēties vairākus uzreiz.
- **Mape** nosūta veselu direktoriju.
- **Saņemt** atver pašu LocalSend, lai cita ierīce varētu jums kaut ko nosūtīt.

To pašu var izdarīt arī no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un iegūsiet atlasītāju.

Varat sūtīt arī tieši no failu pārvaldnieka: Nautilus vidē ar labo peles pogu noklikšķiniet uz jebkuras atlases un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas svaigā instalācijā darbojas uzreiz. Skatiet sadaļu [drošība](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīga biroja pakotne ar tekstprocesoru, izklājlapām, prezentācijām, zīmēšanas lietotni un daudz ko citu. Tā ir savietojama ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā spēt atvērt tos Word dokumentus.

LibreOffice palaižat no lietotņu palaidēja (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša gaužām vienkāršā prezentāciju lietotne. Jūsu prezentācija ir viens Markdown fails, kuram blakus atrodas tā attēli un video: katru slaidu rakstiet zem tieša priekšskatījuma, slaidus ar vilkšanu sakārtojiet secībā un pēc tam prezentējiet pilnekrānā vai eksportējiet uz PDF un PowerPoint. Tas pat pārņem jūsu Omarchy tēmu.

Hype palaižat no lietotņu palaidēja (`Super + Space`). Tajā nospiediet `?`, lai redzētu katru saīsni.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša gaužām vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Saglabāto parakstu, tekstu un šodienas datumu lieciet jebkurā lapas vietā un pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. To, kā to izdarīt, skatiet sadaļā [PDF failu aizpildīšana](27-filling-out-pdfs.md).

Signed palaižat no lietotņu palaidēja (`Super + Space`) vai atverat ar to PDF failu no failu pārvaldnieka.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša gaužām vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaižat ar `Super + Ctrl + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir pilnībā šifrētas (E2E) ziņojumapmaiņas aizsācējs un lieliska saziņas iespēja ikvienam, kurš labprātāk neizmantotu kādu no lielo tehnoloģiju konglomerātiem.

Signal palaižat ar `Super + Shift + G`. Tas nav daļa no pamata instalācijas, tāpēc pirmoreiz to nospiežot, Omarchy piedāvās to jūsu vietā instalēt (tas atrodas arī Omarchy izvēlnē sadaļā _Instalēt > Service_).

## mpv

[mpv](https://mpv.io/) ir vienkāršs, ātrs multivides atskaņotājs, kas atskaņos gandrīz jebko no jebkura avota. Lieliski piemērots video skatīšanai.

mpv palaižat no lietotņu palaidēja (`Super + Space`) vai vienkārši veicat dubultklikšķi uz video failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša gaužām vienkāršais video apgriezējs. Kad viss, kas jums nepieciešams, ir nogriezt klipa sākumu un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaižat no lietotņu palaidēja (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša gaužām vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu ierakstu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā un ar tiešu mikrofona mērītāju, lai pirms sākšanas varat pārbaudīt savus līmeņus.

Apturat ierakstu, un tas uzreiz atveras iebūvētā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru gabalu, un noņemiet tās daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Monologue palaižat no lietotņu palaidēja (`Super + Space`).
