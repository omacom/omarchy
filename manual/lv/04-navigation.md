# Navigācija

Omarchy viss notiek ar tastatūru — _VISU!_ Kad sistēma tikko startējusies, ar peli vien jūs burtiski nevarat izdarīt neko. Bet varat nospiest `Super + Space`, lai atvērtu Omarchy Menu, un no šejienes varat darīt gandrīz visu.

Bet Omarchy izvēlne pat nav paredzēta kā galvenais veids, kā lielāko daļu laika vadīt sistēmu. Mēs varam ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli palaižat ar `Super + Return`, bet pārlūku — ar `Super + Shift + Return`. Pamēģiniet vienu pēc otra, un redzēsiet Hyprland flīzēšanas maģiju darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pēc tam varat nospiest `Super + J`, lai sakrautu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospiediet `Super + J` vēlreiz, lai atgrieztu tos blakus pozīcijās. Pēc tam pamēģiniet `Super + Shift + Arrow Right`, kamēr esat pārlūkā, lai apmainītu logus vietām.

Tagad pamēģiniet `Super + Shift + T`, lai palaistu Activity monitor. Tas parādīsies kā peldošs logs. Varat to ieflīzēt ar `Super + T` (un nospiest to vēlreiz, lai atkal padarītu to peldošu). Tagad nospiediet `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Jums būs glīts četru daļu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, kuru vēlaties padarīt aktīvu, pārvietojaties ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Pie ekrāna malas tas turpinās uz monitoru tajā pusē.

Ja nospiedīsiet `Super + Shift + 2`, pārvietosiet pašlaik fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašlaik fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ja ir vairāk nekā viens monitors, katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` ved uz tā monitora otro darbvietu, kurā atrodaties, un katra monitora augšējā josla rāda savas darbvietas un to, kuru tas pašlaik rāda. `Super + Tab` cikliski pārslēdzas starp darbvietām monitorā, kurā atrodaties. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā atrodaties, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā atrodaties, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad to atvienojat: tās pievienojas citam ekrānam, numurētas pēc tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turēsiet nospiestu `Super` un ar peli noklikšķināsiet uz loga, varēsiet pārkārtot, kur tas atrodas. Ja turēsiet `Super` un izmantosiet peles labo pogu, varēsiet brīvi mainīt loga izmēru.

Logu aizverat ar `Super + W` vai `Super + Q` (un visus logus aizverat ar `Ctrl + Alt + Delete`).

Varat arī pāriet pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (saglabājot augšējo joslu) ar `Super + Alt + F`, vai pilnekrāna režīmā loga iekšienē ar `Super + Ctrl + F` (noder YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas vienmēr tur visus logus, ko atverat vienā darbvietā, redzamus, pat ja tam tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet varat arī izvēlēties pārvērst darbvietu ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Vienu darbvietu šajā izkārtojumā pārvēršat ar `Super + L`.

Vēlreiz nospiežot `Super + L`, darbvieta kļūst peldoša, kur logi brīvi pārklājas un jūs tos novietojat paši, un trešā nospiešana to atgriež dwindle. `Super + Alt + L` iet caur tiem pretējā virzienā. Logs, kas tāpat ir peldošs — tāds, ko izcēlāt ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša — paliek peldošs, kad darbvieta atgriežas flīzēšanā. Augšējā josla atzīmē darbvietu, kurā atrodaties, ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trijstūris peldošajam. Noklikšķinot uz šīs atzīmes, izkārtojums arī cikliski mainās.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķi, un tā saglabājas. Tā varat turēt 1. darbvietu dwindle pārlūkošanai un 2. darbvietu ritināšanā kodam, un tās tā atgriezīsies pēc restartēšanas.

Ja vēlaties izmantot ritināšanas izkārtojumu kā noklusējumu, varat to iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un jūs tos pārvietojat un maināt to izmēru paši. Katrs logs iegūst virsraksta joslu jūsu motīva krāsās ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. `Super + M` arī minimizē fokusēto logu. Minimizēts logs gaida dokā; noklikšķiniet uz tā lietotnes, lai to atgrieztu. Noklikšķiniet uz loga, lai to izvirzītu priekšplānā. Mainiet tā izmēru no jebkuras malas vai stūra. Veiciet dubultklikšķi uz virsraksta joslas, lai maksimizētu logu, saglabājot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru. Chrome un citi uz Chromium balstīti pārlūki, Disks un Document Viewer izlaiž virsraksta joslu un tā vietā izmanto savu galveni; `Super + Alt + F` tos maksimizē, un `Super + M` tos minimizē.

Peldoša darbvieta rāda arī doku ar jūsu piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, ko atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar labo pogu noklikšķiniet uz lietotnes režģī vai nospiediet `Delete`, lai to atinstalētu. Noklikšķiniet uz lietotnes, lai to atvērtu vai izvirzītu tās logu priekšplānā; noklikšķiniet vēlreiz, lai cikliski pārslēgtos starp tās logiem. Files atgriež tikai logu no darbvietas, kurā atrodaties, un citādi atver jaunu, un Terminal un Agent vienmēr palaiž vēl vienu, lai gan minimizēts logs atgriežas vispirms. Klikšķis ar vidējo pogu atver jaunu logu. Velciet ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp citām, tā tur paliek. Ar labo pogu noklikšķiniet, lai paturētu lietotni dokā, izņemtu to vai izietu no tās. Doks atkāpjas pilnekrāna loga priekšā. Ar labo pogu noklikšķiniet uz lietotņu pogas, lai pārvietotu doku uz citu malu vai liktu tam slēpties, līdz rādītājs sasniedz tā malu. Pozīcija ir arī zem _Appearance > Dock > Dock Position_, un `omarchy dock position left` un `omarchy dock autohide on` abas iestata no termināļa. Lietotnes, ko paturat dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darbvietas un visas, kurām neesat piešķīruši savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Mainot noklusējumu, katra darbvieta bez logiem tiek atiestatīta uz to, bet tā, kurā ir logi, saglabā izkārtojumu, kas tai ir. Logs, kas minimizēts dokā, joprojām skaitās kā logs darbvietā, ko tas pameta. Izvēlieties to zem _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy-hyprland-workspace-layout-default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt ar `Super + G`. Kad esat grupā, katrs logs, ko palaidīsiet, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem varat pārvietoties ar `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem pēc kārtas.

Logu varat izvirzīt ārā no grupas ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, logus ārpus grupas varat pārvietot tajā ar `Super + Alt + Arrows`.

### Logu izcelšana

Logu varat izcelt no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas seko jums uz jebkuru darbvietu, uz kuru dodaties. Lieliski video atskaņotājiem un līdzīgiem.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Piezīmju darbvieta

Ir īpaša pilna izmēra piezīmju darbvieta, kas pārklāj jebkuru darbvietu, kurā pašlaik atrodaties. Tam, kas tajā atrodas, piekļūstat ar `Super + S`, un logus tur novietojat ar `Super + Alt + S`.

Tā labi noder vadīklām vai terminālim, ar ko vēlaties ātri mijiedarboties, nepametot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pusaugstuma Quake konsole, kas nolaižas pār jebkuru darbvietu, kurā pašlaik atrodaties. Pārslēdziet to ar `Super + Grave`, un novietojiet tur logu ar `Super + Shift + Grave`.

Tā atveras ar jūsu noklusējuma agent gatavu darbam. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri visam ekrānam. Novietojiet tajā otru lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta blakus.

Lai pārvietotu logu nost no piezīmju darbvietas vai konsoles, nosūtiet to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā ir jāpierod!

Vajag nedaudz laika, lai pierastu šādi pārvietoties pa darbvirsmu, bet, kad būsiet pieraduši, būs grūti atgriezties pie tradicionālas ar peli vadītas darbvirsmas pieredzes!
