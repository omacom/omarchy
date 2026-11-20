# Navigācija

Viss Omarchy notiek ar tastatūru — _VISU!_ Kad sistēma tikko startējusies, ar pašu peli vien jūs burtiski neko nespējat izdarīt. Taču varat nospiest `Super + Space`, lai atvērtu Omarchy izvēlni, un no šejienes varat izdarīt teju visu.

Bet Omarchy izvēlne pat nav paredzēta kā galvenais sistēmas lietošanas veids lielāko daļu laika. Mēs spējam vēl ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli palaižat ar `Super + Return`, bet pārlūku — ar `Super + Shift + Return`. Pamēģiniet vienu pēc otra, un redzēsiet Hyprland flīzēšanas burvību darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tad varat nospiest `Super + J`, lai sakārtotu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospiediet `Super + J` vēlreiz, lai atgrieztu tos blakus novietojumā. Tad, esot pārlūkā, pamēģiniet `Super + Shift + Arrow Right`, lai apmainītu logus vietām.

Tagad pamēģiniet `Super + Shift + T`, lai palaistu Activity monitoru. Tas parādīsies kā peldošs logs. Varat to noflīzēt ar `Super + T` (un nospiest to vēlreiz, lai atkal padarītu to peldošu). Tagad nospiediet `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Iegūsiet glītu četru logu izkārtojumu:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, kurus vēlaties aktivizēt, pārvietojaties ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Pie ekrāna malas tas turpinās uz monitoru tajā pusē.

Ja nospiežat `Super + Shift + 2`, pārvietosiet pašlaik fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` pārvieto to atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašlaik fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ja ir vairāk nekā viens monitors, katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` aizved uz tā monitora, kurā atrodaties, otro darbvietu, un katra monitora augšējā josla rāda savas darbvietas un to, kura tiek attēlota. `Super + Tab` cikliski pārslēdzas starp tā monitora darbvietām, kurā atrodaties. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā atrodaties, uz monitoru tajā virzienā, uz darbvietu, ko tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā atrodaties, uz monitoru tajā virzienā, kur tā iegūst tādu pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad to atvienojat: tās pievienojas cita ekrāna darbvietām, numurētas aiz tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turat nospiestu `Super` un ar peli noklikšķināt uz loga, varēsiet pārkārtot, kur tas atrodas. Ja turat `Super` un izmantojat peles labo pogu, varat brīvi mainīt loga izmēru.

Logu aizverat ar `Super + W` vai `Super + Q` (un visus logus aizverat ar `Ctrl + Alt + Delete`).

Varat arī pāriet pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (saglabājot augšējo joslu) ar `Super + Alt + F`, vai pilnekrāna režīmā loga iekšienē ar `Super + Ctrl + F` (ideāli piemērots YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas visu laiku saglabā visus logus, ko atverat vienā darbvietā, redzamus, pat ja tam tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet varat arī izvēlēties pārvērst darbvietu ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Vienu darbvietu šajā izkārtojumā pārvēršat ar `Super + L`.

`Super + L` nospiešana vēlreiz padara darbvietu peldošu, kur logi brīvi pārklājas un jūs tos izvietojat paši, un trešā nospiešana atgriež to uz dwindle. `Super + Alt + L` iziet tiem cauri pretējā virzienā. Logs, kas tāpat peldošs — tāds, ko izcēlāt ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša — paliek peldošs, kad darbvieta atgriežas flīzēšanā. Augšējā josla atzīmē darbvietu, kurā atrodaties, ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trijstūris peldošajam. Noklikšķināšana uz šīs atzīmes arī cikliski pārslēdz izkārtojumu, tāpat kā displeja taustiņš klēpjdatoros, kuriem tāds ir.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķi, un tā saglabājas. Tātad varat saglabāt 1. darbvietu uz dwindle pārlūkošanai un 2. darbvietu uz ritināšanas kodam, un pēc restartēšanas tās atgriezīsies tieši tādas.

Ja vēlaties izmantot ritināšanas izkārtojumu kā noklusējumu, varat to iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un jūs tos pārvietojat un maināt to izmēru paši. Katrs logs iegūst virsrakstjoslu jūsu motīva krāsās, ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. `Super + M` minimizē arī fokusēto logu. Minimizēts logs gaida dokā; noklikšķiniet uz tā lietotnes, lai to atgrieztu. Noklikšķiniet uz loga, lai izceltu to priekšplānā. Mainiet tā izmēru no jebkuras malas vai stūra. Veiciet dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, saglabājot augšējo joslu redzamu, un vēlreiz, lai iegūtu atpakaļ tā veco izmēru. Chrome un citi uz Chromium balstīti pārlūki, Disks un Document Viewer izlaiž virsrakstjoslu un tā vietā izmanto savu galveni; `Super + Alt + F` tos maksimizē, un `Super + M` tos minimizē.

Peldoša darbvieta rāda arī doku, ar jūsu piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, kuru atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar peles labo pogu noklikšķiniet uz lietotnes režģī vai nospiediet `Delete`, lai to atinstalētu. Noklikšķiniet uz lietotnes, lai to atvērtu vai izceltu tās logu priekšplānā; noklikšķiniet vēlreiz, lai cikliski pārslēgtos starp tās logiem. Files atgriež logu tikai no darbvietas, kurā atrodaties, un citādi atver jaunu, un Terminal un Agent vienmēr palaiž vēl vienu, lai gan minimizēts logs atgriežas pirmais. Klikšķis ar vidējo pogu atver jaunu logu. Velciet ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp pārējām, tā tur paliek. Ar peles labo pogu noklikšķiniet, lai paturētu lietotni dokā, izņemtu to no tā vai aizvērtu to. Doks atkāpjas no pilnekrāna loga ceļa. Ar peles labo pogu noklikšķiniet uz lietotņu pogas, lai pārvietotu doku uz citu malu vai liktu tam slēpties, līdz rādītājs sasniedz tā malu. Pozīcija atrodas arī sadaļā _Appearance > Dock > Dock Position_, un `omarchy dock position left` un `omarchy dock autohide on` iestata abus no termināļa. Lietotnes, ko paturat dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darbvietas un jebkura, kurai neesat piešķīris savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Noklusējuma maiņa atiestata uz to katru darbvietu bez logiem, savukārt tā, kurai ir logi, saglabā savu izkārtojumu. Logs, kas minimizēts dokā, joprojām skaitās kā logs darbvietā, kuru tas atstāja. Izvēlieties to sadaļā _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy hyprland workspace layout default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt, izmantojot `Super + G`. Tiklīdz esat grupā, katrs logs, ko palaižat, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem varat pārvietoties, izmantojot `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem secībā.

Varat pārvietot logu ārā no grupas ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, varat pārvietot logus no ārpuses grupā ar `Super + Alt + Arrows`.

### Logu izcelšana

Varat izcelt logu no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas jums seko, uz kuru darbvietu vien dodaties. Lieliski piemērots video atskaņotājiem un tamlīdzīgiem.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra scratchpad darbvieta, kas pārklāj darbvietu, kurā pašlaik atrodaties. Tajā esošajam varat piekļūt, izmantojot `Super + S`, un logus tur izvietojat, izmantojot `Super + Alt + S`.

Tā labi der vadīklām vai terminālim, ar ko vēlaties ātri mijiedarboties, neatstājot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pusaugstuma Quake konsole, kas nolaižas pāri darbvietai, kurā pašlaik atrodaties. Pārslēdziet to ar `Super + Grave` un izvietojiet logu tur, izmantojot `Super + Shift + Grave`.

Pirmo reizi, kad tā atveras, tā palaiž jūsu noklusējuma aģentu vai lūdz izvēlēties vienu, ja vēl neesat izvēlējies. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri visam ekrānam. Ievietojiet tajā otru lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta blakus.

Lai pārvietotu logu nost no scratchpad vai konsoles, nosūtiet to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā ir nedaudz jāpierod!

Ir vajadzīgs nedaudz laika, lai pierastu šādi pārvietoties pa darbvirsmu, bet, tiklīdz to izdarīsiet, būs grūti atgriezties pie tradicionālas ar peli vadītas darbvirsmas pieredzes!
