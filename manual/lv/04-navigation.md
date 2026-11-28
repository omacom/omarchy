# Navigācija

Omarchy vidē viss notiek ar tastatūru — _VISU!_ Kad sistēma tikko startējusies, ar peli vien tu burtiski nevari izdarīt neko. Bet tu vari nospiest `Super + Space`, lai atvērtu Omarchy izvēlni, un no šejienes vari izdarīt teju visu.

Taču Omarchy izvēlne pat nav paredzēta kā galvenais sistēmas lietošanas veids lielāko daļu laika. Var ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli startē ar `Super + Return`, bet pārlūku ar `Super + Shift + Return`. Pamēģini vienu pēc otra, un redzēsi Hyprland flīzēšanas burvību darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pēc tam vari nospiest `Super + J`, lai sakrautu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospied `Super + J` vēlreiz, lai atgrieztu tos blakus novietojumā. Pēc tam pamēģini `Super + Shift + Arrow Right`, kamēr esi pārlūkā, lai apmainītu logus vietām.

Tagad pamēģini `Super + Shift + T`, lai startētu Activity monitor. Tas parādīsies kā peldošs logs. To vari ieflīzēt ar `Super + T` (un nospiest to vēlreiz, lai tas atkal kļūtu peldošs). Tagad nospied `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Tev būs glīts četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, kuru vēlies aktivizēt, pārvietojies ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Ekrāna malā tas turpinās uz monitoru tajā pusē.

Ja nospiedīsi `Super + Shift + 2`, pašreiz fokusēto lietotni pārvietosi uz otro darbvietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašreiz fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ar vairāk nekā vienu monitoru katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` dodas uz monitora, kurā esi, otro darbvietu, un katra monitora augšējā josla rāda tā darbvietas un to, kuru tas rāda. `Super + Tab` cikliski pārslēdzas starp darbvietām monitorā, kurā esi. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā esi, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, bet `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā esi, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad to atvieno: tās pievienojas cita ekrāna darbvietām, numurētas aiz tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turi nospiestu `Super` un ar peli noklikšķini uz loga, varēsi pārkārtot tā novietojumu. Ja turi `Super` un izmanto peles labo pogu, vari brīvi mainīt loga izmēru.

Logu aizver ar `Super + W` vai `Super + Q` (bet visus logus — ar `Ctrl + Alt + Delete`).

Vari arī pāriet pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (saglabājot augšējo joslu) ar `Super + Alt + F`, vai pilnekrāna režīmā loga iekšienē ar `Super + Ctrl + F` (lieliski YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas visu laiku tur visus logus, ko atver vienā darbvietā, redzamus, pat ja tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet vari arī izvēlēties darbvietu pārvērst ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Vienu darbvietu šajā izkārtojumā pārvērs ar `Super + L`.

Vēlreiz nospiežot `Super + L`, darbvieta kļūst peldoša, kur logi brīvi pārklājas un tu tos novieto pats, bet trešā nospiešana to atgriež dwindle izkārtojumā. `Super + Alt + L` tos iziet pretējā virzienā. Logs, kas tāpat peldošs — tāds, ko izcēli ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša — paliek peldošs, kad darbvieta atgriežas flīzēšanas režīmā. Augšējā josla darbvietu, kurā esi, apzīmē ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanas un trijstūris peldošajam. Noklikšķinot uz šīs zīmes, izkārtojums arī cikliski mainās, tāpat dara arī displeja taustiņš klēpjdatoros, kuriem tāds ir.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķi, un tā saglabājas. Tāpēc 1. darbvietu vari turēt dwindle režīmā pārlūkošanai, bet 2. darbvietu ritināšanas režīmā kodam, un pēc restartēšanas tās atgriezīsies tieši tādas.

Ja vēlies ritināšanas izkārtojumu izmantot kā noklusējumu, to vari iestatīt failā `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un tu tos pārvieto un maini to izmēru pats. Katrs logs iegūst virsrakstjoslu tavas tēmas krāsās ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. Arī fokusēto logu minimizē `Super + M`. Minimizēts logs gaida dokā; noklikšķini uz tā lietotnes, lai to atgrieztu. Noklikšķini uz loga, lai to izvirzītu priekšplānā. Maini tā izmēru no jebkuras malas vai stūra. Veic dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, vienlaikus turot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru. Chrome un citi uz Chromium balstīti pārlūki, Disks un Document Viewer izlaiž virsrakstjoslu un tā vietā izmanto savu galveni; `Super + Alt + F` tos maksimizē, bet `Super + M` tos minimizē.

Peldoša darbvieta rāda arī doku ar tavām piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, ko atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar labo pogu noklikšķini uz lietotnes režģī vai nospied `Delete`, lai to atinstalētu. Noklikšķini uz lietotnes, lai to atvērtu vai izvirzītu tās logu priekšplānā; noklikšķini vēlreiz, lai cikliski pārslēgtos starp tās logiem. Files atgriež tikai logu no darbvietas, kurā esi, un citādi atver jaunu, bet Terminal un Agent vienmēr startē vēl vienu, lai gan minimizēts logs vispirms atgriežas. Klikšķis ar vidējo pogu atver jaunu logu. Velc ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp pārējām, tā tur paliek. Ar labo pogu noklikšķini, lai lietotni paturētu dokā, izņemtu to no tā vai aizvērtu to. Doks atkāpjas no pilnekrāna loga ceļa. Ar labo pogu noklikšķini uz lietotņu pogas, lai doku pārvietotu uz citu malu vai liktu tam paslēpties, līdz rādītājs sasniedz tā malu. Novietojums ir arī sadaļā _Appearance > Dock > Dock Position_, un `omarchy dock position left` un `omarchy dock autohide on` abus iestata no termināļa. Lietotnes, ko turi dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darbvietas un visas, kurām ar `Super + L` neesi piešķīris savu izkārtojumu, izmanto noklusējuma izkārtojumu. Mainot noklusējumu, katra darbvieta bez logiem tiek atiestatīta uz to, bet darbvieta ar logiem saglabā esošo izkārtojumu. Logs, kas minimizēts uz doku, joprojām skaitās logs darbvietā, ko tas atstāja. Izvēlies to sadaļā _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy hyprland workspace layout default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt ar `Super + G`. Kad esi grupā, katrs logs, ko startē, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem vari pārvietoties ar `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem pēc kārtas.

Logu vari pārvietot ārā no grupas ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, logus ārpus grupas vari pārvietot tajā ar `Super + Alt + Arrows`.

### Logu izcelšana

Logu vari izcelt no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas seko tev līdzi, uz kuru darbvietu vien dotos. Lieliski piemērots video atskaņotājiem un tamlīdzīgiem.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra scratchpad darbvieta, kas pārklāj darbvietu, kurā pašlaik esi. Tam, kas tajā atrodas, piekļūsti ar `Super + S`, bet logus tur novieto ar `Super + Alt + S`.

Tā labi der vadīklām vai terminālim, ar ko vēlies ātri mijiedarboties, neatstājot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pus augstuma Quake konsole, kas nolaižas pār darbvietu, kurā pašlaik esi. To pārslēdz ar `Super + the key above Tab` (ASV izkārtojumos tā ir grave), bet logu tur novieto ar `Super + Shift + the key above Tab`.

Pirmajā atvēršanas reizē tā startē tavu noklusējuma agent, vai lūdz izvēlēties vienu, ja vēl neesi to izvēlējies. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri visam ekrānam. Novieto tajā otru lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta blakus.

Lai logu pārvietotu prom no scratchpad vai konsoles, sūti to tieši uz citu darbvietu, piemēram, ar `Super + Shift + 1`.

### Pie tā jāpierod!

Pie tādas darbvirsmas navigācijas jāpierod kādu brīdi, bet, kad būsi pieradis, būs grūti atgriezties pie tradicionālas ar peli vadāmas darbvirsmas pieredzes!
