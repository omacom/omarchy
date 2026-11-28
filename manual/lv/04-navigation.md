# Navigācija

Viss Omarchy notiek ar tastatūru — _VISS!_ Kad sistēma pirmo reizi startējas, ar peli vien burtiski nevarat izdarīt neko. Bet varat nospiest `Super + Space`, lai atklātu Omarchy Menu, un no šejienes varat izdarīt gandrīz visu.

Bet Omarchy izvēlne lielākoties pat nav paredzēta kā galvenais sistēmas lietošanas veids. Mēs varam ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli palaižat ar `Super + Return` un pārlūku ar `Super + Shift + Return`. Pamēģiniet vienu pēc otra, un redzēsiet Hyprland flīzēšanas maģiju darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pēc tam varat nospiest `Super + J`, lai sakārtotu tos citu virs cita, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospiediet `Super + J` vēlreiz, lai atgrieztu tos blakus novietojumā. Pēc tam pamēģiniet `Super + Shift + Arrow Right`, kamēr esat pārlūkā, lai samainītu logus vietām.

Tagad pamēģiniet `Super + Shift + T`, lai palaistu Activity monitor. Tas parādīsies kā peldošs logs ar virsrakstjoslu, aiz kuras to vilkt, un pogām, lai to minimizētu, maksimizētu un aizvērtu. Katrs peldošs logs tādu iegūst, lai kur tas atrastos. Varat to noflīzēt ar `Super + T` (un nospiest to vēlreiz, lai padarītu to atkal peldošu). Tagad nospiediet `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Jums būs glīts četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, kuru vēlaties padarīt aktīvu, navigējat ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Pie ekrāna malas tas turpinās uz monitoru tajā pusē.

Ja nospiedīsiet `Super + Shift + 2`, pārvietosiet pašreiz fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašreiz fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ar vairāk nekā vienu monitoru katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` dodas uz tā monitora, kurā atrodaties, otro darbvietu, un katra monitora augšējā josla rāda savas darbvietas un to, kuru tas rāda. `Super + Tab` cikliski pārslēdzas cauri tā monitora, kurā atrodaties, darbvietām. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā atrodaties, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā atrodaties, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors patur savas darbvietas, kad to atvienojat: tās pievienojas cita ekrāna darbvietām, numurētas aiz tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turēsiet nospiestu `Super` un ar peli noklikšķināsiet uz loga, varēsiet pārkārtot, kur tas atrodas. Ja turēsiet `Super` un izmantosiet peles labo pogu, varēsiet brīvi mainīt loga izmēru.

Logu aizverat ar `Super + W` vai `Super + Q` (un visus logus aizverat ar `Ctrl + Alt + Delete`).

Varat arī doties pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (paturot augšējo joslu) ar `Super + Alt + F` vai pilnekrāna režīmā loga iekšienē ar `Super + Ctrl + F` (labs YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas visu laiku paturo visus logus, ko atverat vienā darbvietā, redzamus, pat ja tam tie ir jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet varat arī izvēlēties pārvērst darbvietu ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Vienu darbvietu šajā izkārtojumā pārvēršat ar `Super + L`.

Vēlreiz nospiežot `Super + L`, darbvieta kļūst peldoša, kur logi brīvi pārklājas un jūs tos novietojat paši, un trešā nospiešana to atgriež pie dwindle. `Super + Alt + L` iet cauri tiem pretējā virzienā. Logs, kas tik un tā ir peldošs — tāds, ko izņēmāt ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša —, paliek peldošs, kad darbvieta atgriežas pie flīzēšanas. Augšējā josla darbvietu, kurā atrodaties, atzīmē ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trīsstūris peldošajam. Arī noklikšķināšana uz šīs atzīmes cikliski maina izkārtojumu, un tāpat dara displeja taustiņš klēpjdatoros, kuriem tāds ir.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir atsevišķa katrai darbvietai, un tā saglabājas. Tā varat paturēt 1. darbvietu ar dwindle pārlūkošanai un 2. darbvietu ar ritināšanu kodam, un tās atgriezīsies tādas pēc restartēšanas.

Ja vēlaties ritināšanas izkārtojumu izmantot kā noklusējumu, varat to iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un jūs tos pārvietojat un maināt to izmēru paši. Katrs logs iegūst virsrakstjoslu jūsu tēmas krāsās ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. Arī `Super + M` minimizē fokusēto logu. Minimizēts logs gaida dokā; noklikšķiniet uz tā lietotnes, lai to atgrieztu. Noklikšķiniet uz loga, lai izvirzītu to priekšā. Mainiet tā izmēru no jebkuras malas vai stūra. Divreiz noklikšķiniet uz virsrakstjoslas, lai maksimizētu logu, paturot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru. Chrome un citi Chromium bāzētie pārlūki, Disks un Document Viewer izlaiž virsrakstjoslu un tās vietā izmanto savu galveni; `Super + Alt + F` tos maksimizē, un `Super + M` tos minimizē.

Katrai darbvietai ir doks ar jūsu piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, ko atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar peles labo pogu noklikšķiniet uz lietotnes režģī vai nospiediet `Delete`, lai to atinstalētu. Noklikšķiniet uz lietotnes, lai to atvērtu vai izvirzītu tās logu priekšā; noklikšķiniet vēlreiz, lai cikliski pārslēgtos cauri tās logiem. Files atgriež tikai logu no darbvietas, kurā atrodaties, un citādi atver jaunu, un Terminal un Agent vienmēr palaiž vēl vienu, lai gan minimizēts logs atgriežas pirmais. Ar vidējo klikšķi atver jaunu logu. Velciet ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp pārējām, tā tur paliek. Ar peles labo pogu noklikšķiniet, lai paturētu lietotni dokā, izņemtu to ārā vai aizvērtu to. Doks paliek ārā, kamēr darbvieta ir tukša, un, tiklīdz darbvietā ir logs, tas slēpjas, līdz rādītājs sasniedz tā malu. Pilnekrāna logs to paslēpj pavisam. Velciet lietotņu pogu uz citu ekrāna malu, lai pārvietotu doku tur. Ar peles labo pogu noklikšķiniet uz tās _Position_, lai izvēlētos malu, un _Layout_, lai iestatītu noklusējuma izkārtojumu, kā to dara _Appearance > Workspace Layout_. Pozīcija ir arī zem _Appearance > Dock > Dock Position_, un `omarchy dock position left` to iestata no termināļa. Lietotnes, ko paturat dokā, ir izbalējušas, kamēr tās nedarbojas. Lai doku paturētu tikai peldošajām darbvietām, izmantojiet _Appearance > Dock > Dock Only on Floating_ vai `omarchy dock tiling off`.

Jaunas darbvietas un jebkura, kurai neesat piešķīruši savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Noklusējuma maiņa atiestata uz to katru darbvietu bez logiem, kamēr tāda ar logiem patur izkārtojumu, kāds tai ir. Logs, kas minimizēts dokā, joprojām skaitās logs darbvietā, ko tas pameta. Izvēlieties to zem _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy hyprland workspace layout default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt ar `Super + G`. Tiklīdz esat grupā, katrs logs, ko palaižat, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem varat pārvietoties ar `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem pēc kārtas.

Logu no grupējuma varat izņemt ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, logus ārpus grupas varat ievilkt tajā ar `Super + Alt + Arrows`.

### Logu izņemšana

Logu varat izņemt no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas jums seko, uz kuru darbvietu vien dodaties. Lieliski video atskaņotājiem un tamlīdzīgiem!

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra scratchpad darbvieta, kas pārklāj jebkuru darbvietu, kurā pašlaik atrodaties. Tam, kas ir tajā, piekļūstat ar `Super + S`, un logus tur novietojat ar `Super + Alt + S`.

Tā labi darbojas vadīklām vai terminālim, ar ko vēlaties ātri mijiedarboties, nepametot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pusaugstuma Quake konsole, kas nolaižas pāri jebkurai darbvietai, kurā pašlaik atrodaties. Pārslēdziet to ar `Super + the key above Tab` (grave uz US izkārtojumiem) un novietojiet tur logu ar `Super + Shift + the key above Tab`.

Pirmo reizi atveroties, tā palaiž jūsu noklusējuma agent vai lūdz jums izvēlēties vienu, ja vēl neesat tādu izvēlējies. Kamēr konsolē ir viens vienīgs logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri ekrānam. Ielieciet tajā otru lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta sēdēt blakus.

Lai logu pārvietotu nost no scratchpad vai konsoles, sūtiet to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā jāpierod!

Paies nedaudz laika, kamēr pieradīsiet navigēt savu darbvirsmu šādi, bet, kad pieradīsiet, būs grūti atgriezties pie tradicionālas ar peli vadītas darbvirsmas pieredzes!
