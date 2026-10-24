# Navigācija

Viss Omarchy notiek ar tastatūru — _VISS!_ Kad sistēma tikko startējusi, ar peli vien tu tiešām nevari izdarīt pilnīgi neko. Taču tu vari nospiest `Super + Space`, lai atvērtu Omarchy Menu, un no šejienes tu vari darīt gandrīz visu.

Taču Omarchy menu lielākoties pat nav paredzēta kā galvenais veids, kā darboties ar sistēmu. Mēs varam būt ātrāki! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli tu startē ar `Super + Return`, bet pārlūku — ar `Super + Shift + Return`. Pamēģini vienu pēc otra, un redzēsi Hyprland mozaīkošanas burvību darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tad vari nospiest `Super + J`, lai novietotu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospied `Super + J` vēlreiz, lai atgrieztu tos pozīcijās blakus. Pēc tam, esot pārlūkā, pamēģini `Super + Shift + Arrow Right`, lai samainītu logus vietām.

Tagad pamēģini `Super + Ctrl + T`, lai startētu Activity monitoru. Tas parādīsies kā peldošs logs. To vari iemozaīkot ar `Super + T` (un nospiest to vēlreiz, lai atkal padarītu to peldošu). Tagad nospied `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Tev būs kārtīgs četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, lai izvēlētos, kuram būt aktīvam, tu navigē ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru.

Ja nospiedīsi `Super + Shift + 2`, tu pārvietosi pašreiz fokusēto lietotni uz otro darba vietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašreiz fokusēto lietotni uz otro darba vietu, nepārslēdzoties uz to).

Ja turēsi nospiestu `Super` un ar peli noklikšķināsi uz loga, varēsi mainīt, kur tas atrodas. Ja turēsi `Super` un izmantosi peles labo pogu, vari brīvi mainīt loga izmēru.

Logu aizver ar `Super + W` vai `Super + Q` (un visus logus aizver ar `Ctrl + Alt + Delete`).

Tu vari arī pāriet pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (saglabājot augšējo joslu) ar `Super + Alt + F`, vai pilnekrānā loga ietvaros ar `Super + Ctrl + F` (lieliski YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc dwindle. Tas visu laiku uztur visus logus, ko atver vienā darba vietā, redzamus, pat ja tos nākas samazināt.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Taču vari arī izvēlēties pārvērst darba vietu ritināšanas izkārtojumā, kur logi ir sakārtoti blakus, aiz displeja redzamās malas. Atsevišķu darba vietu šajā izkārtojumā pārslēdz ar `Super + L`.

Nospiežot `Super + L` vēlreiz, darba vieta kļūst peldoša, kur logi brīvi pārklājas un tu tos novieto pats, bet trešā nospiešana to atgriež dwindle. `Super + Alt + L` tiem iziet cauri otrā virzienā. Logs, kas tāpat jau peld — tāds, kuru izcēli ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša, — paliek peldošs, kad darba vieta atgriežas mozaīkošanā. Augšējā josla darba vietu, kurā atrodies, apzīmē ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trīsstūris peldošajam. Noklikšķinot uz šīs zīmes, arī tiek cikliski mainīts izkārtojums.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle attiecas uz katru darba vietu atsevišķi, un tā saglabājas. Tāpēc vari darba vietu 1 paturēt dwindle pārlūkošanai un darba vietu 2 ritināšanā kodam, un pēc restartēšanas tās atgriezīsies tieši tādas pašas.

Ja vēlies ritināšanas izkārtojumu izmantot kā noklusējumu, to vari iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darba vietas

Peldoša darba vieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un tu pats tos pārvieto un maini to izmērus. Katram logam ir virsrakstjosla tavas tēmas krāsās, ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. `Super + M` arī minimizē fokusēto logu. Minimizēts logs gaida dokā; noklikšķini uz tā lietotnes, lai to atgādātu atpakaļ. Noklikšķini uz loga, lai izceltu to priekšplānā. Maini tā izmēru no jebkuras malas vai stūra. Veic dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, vienlaikus saglabājot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru.

Peldoša darba vieta rāda arī doku ar tavām piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, ko atver arī `Super + Alt + Space` un _Apps_ Omarchy menu. Ar labo pogu noklikšķini uz lietotnes režģī vai nospied `Delete`, lai to atinstalētu. Noklikšķini uz lietotnes, lai to atvērtu vai izceltu tās logu priekšplānā; noklikšķini vēlreiz, lai cikli pārslēgtos cauri tās logiem. Klikšķis ar vidējo pogu atver jaunu logu. Velc ikonu gar doku, lai to pārvietotu; ievelkot darboties spējušu lietotni starp pārējām, tā tur paliks. Ar labo pogu vari lietotni paturēt dokā, izņemt to no doka vai aizvērt. Doks netraucē pilnekrāna logam. Ar labo pogu noklikšķini uz lietotņu pogas, lai pārvietotu doku uz citu malu vai liktu tam slēpties, līdz rādītājs sasniedz tā malu. Pozīcija atrodas arī _Trigger > Appearance > Dock > Dock Position_, un `omarchy dock position left` un `omarchy dock autohide on` abus iestata no termināļa. Lietotnes, ko turi dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darba vietas un jebkura, kurai neesi piešķīris savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Mainot noklusējumu, visas darba vietas bez logiem tiek atiestatītas uz to, bet darba vieta ar logiem saglabā to izkārtojumu, kas tai ir. Logs, kas minimizēts dokā, joprojām skaitās kā logs darba vietā, kuru tas pameta. Izvēlies to sadaļā _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy-hyprland-workspace-layout-default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt ar `Super + G`. Kad esi grupā, katrs logs, ko startē, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem vari pārvietoties ar `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupēto logu pēc kārtas.

Logu no grupējuma vari izņemt ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, logus ārpus grupas vari pārvietot tajā iekšā ar `Super + Alt + Arrows`.

### Logu izcelšana

Logu vari izcelt ārā no tā darba vietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas tev sekos uz jebkuru darba vietu, uz kuru dosies. Lieliski video atskaņotājiem un līdzīgām lietām.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darba vieta

Visbeidzot, ir īpaša scratchpad darba vieta, kas nolažas pāri tai darba vietai, kurā pašlaik atrodies, gluži kā Quake konsole. Pārslēdz to ar `Super + Grave` vai `Super + S`, un novieto tur logu ar `Super + Shift + Grave` vai `Super + Alt + S`.

Tā īpaši labi der terminālim, kurā darbojas aģents, vai vadīklām, ar kurām vēlies ātri mijiedarboties, nepametot pašreizējo darba vietu. Lai pārvietotu logu prom no scratchpad, nosūti to tieši uz citu darba vietu ar kaut ko tādu kā `Super + Shift + 1`.

Kamēr scratchpad ir viens logs, tas nolažas kā centrēts panelis, nevis stiepjas pāri visam ekrānam. Noliec tur otru lietotni, un tas atgriežas pilnā platumā, lai abām būtu vieta sēdēt blakus.

### Pie tā vajag pierast!

Vajag nedaudz laika, lai pierastu šādi navigēt savā darbvirsmā, bet, kad pieradīsi, būs grūti atgriezties pie tradicionālas, ar peli vadītas darbvirsmas pieredzes!
