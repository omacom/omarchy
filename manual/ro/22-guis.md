# Interfețe grafice

## Fișiere

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o grămadă de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectezi un stick USB sau un card SD și este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice e mai complicat — formatarea unei unități, verificarea stării SMART, crearea partițiilor — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic respectă niște valori implicite rezonabile: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, Markdown în Omawrite, iar textul simplu în editorul ales la _Setup > Default > Editor_.

## Disktree

Când unitatea se umple și nu ai nicio idee ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Afișează o hartă arborescentă grafică a directorului tău principal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau mouse-ul, marchează ce trebuie să dispară și verifică-ți selecțiile înainte să ștergi ceva. Rulează `disktree --disk` ca să scanezi întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și extrem de extensibilă pentru luat notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru toate scopurile, inclusiv pentru utilizare personală, comercială și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Pentru a folosi sincronizarea temelor, trebuie să selectezi tema `Omarchy` din setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația de scriere Markdown incredibil de simplă a Omarchy. Fără vault-uri, fără plugin-uri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar nu te aștepta la o alternativă la Photoshop. Dar tot are Magic Wand și straturi!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cea mai simplă modalitate de a-ți [crea propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, ca AirDrop de la Apple. Totuși, este multiplatformă, așa că poți trimite fișiere către și de la Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau la _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent ca să duci un link sau un fragment pe telefon fără să-ți trimiți un e-mail.
- **File** deschide un selector de fișiere unde poți selecta mai multe deodată.
- **Folder** trimite un întreg director.
- **Receive** deschide LocalSend propriu-zis, ca alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Omite calea și obții selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis implicit, cu excepția portului LocalSend, așa că asta funcționează din prima pe o instalare proaspătă. Vezi [securitatea](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, foi de calcul, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația de prezentări incredibil de simplă a Omarchy. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile lui alături: scrii fiecare diapozitiv sub o previzualizare live, tragi diapozitivele în ordine, apoi prezinți pe tot ecranul sau exporți în PDF și PowerPoint. Îți preia chiar și tema Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul lui ca să vezi fiecare scurtătură.

## Signed

[Signed](https://github.com/omacom/signed) este metoda incredibil de simplă a Omarchy de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată alături de original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu el din managerul de fișiere.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) este jocul de șah 3D al Omarchy. Joacă cu un prieten pe același computer sau împotriva adversarului integrat, la trei niveluri, pe patru seturi sculptate care se mișcă fiecare în felul său: nave orbitale, lemn sculptat și fildeș, creaturi ale pădurii și bomboane. Partidele nu au ceas și se salvează după fiecare mutare.

Pornești Checkmate prin lansatorul de aplicații (`Super + Space`), unde este listat ca Chess. Apasă `?` în interiorul lui ca să vezi fiecare scurtătură.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul incredibil de simplu al Omarchy, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune excelentă de comunicare pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși asta, Omarchy îți va propune să-l instaleze pentru tine (se află și la _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul de imagini și playerul media incredibil de simplu al Omarchy: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie și tastele săgeată trec prin restul folderului ei, `N` și `P` fac asta pentru orice, iar `Ctrl + M` afișează întregul folder ca o grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și reia de unde ai rămas în orice este lung.

Apasă `F` pentru ecran complet, `E` ca să editezi o imagine în Omasnap sau să tai un videoclip în Omacut, `Ctrl + P` ca să tipărești o imagine și `Delete` ca să muți un fișier în Coș (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interiorul lui ca să vezi fiecare scurtătură.

Pornești Omaview ca _Media Viewer_ prin lansatorul de aplicații (`Super + Space`) sau pur și simplu faci dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul incredibil de simplu al Omarchy pentru tăierea videoclipurilor. Când tot ce ai nevoie este să tai începutul și sfârșitul unui clip, bate lansarea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este înregistratorul webcam incredibil de simplu al Omarchy. Alege-ți camera și microfonul o singură dată, apoi apasă `Space` ca să înregistrezi și din nou ca să pui pauză și să reiei aceeași înregistrare. Înregistrează întotdeauna la cea mai înaltă rezoluție a camerei tale, cu un indicator live al microfonului, ca să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și se deschide imediat într-un editor integrat. Fă dublu clic pe un clip ca să-l împarți, trage de mânere ca să tai fiecare bucată și elimină părțile pe care nu le vrei. Apoi salveaz-o ca fișier MP4. Înregistrarea originală este păstrată până când o arunci, așa că te poți întoarce oricând și o poți tăia altfel.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
