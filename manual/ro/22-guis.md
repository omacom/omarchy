# GUIs

## Files

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o mulțime de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectează un stick USB sau un card SD și este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complicat — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic respectă reguli implicite rezonabile: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, Markdown în Omawrite, iar textul simplu în editorul ales la _Setup > Default > Editor_.

## Disktree

Când unitatea se umple și habar nu ai ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Afișează o hartă treemap grafică a directorului tău personal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau cu mouse-ul, marchează ce trebuie să dispară și verifică-ți selecțiile înainte să ștergi ceva. Rulează `disktree --disk` ca să scanezi întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și extrem de extensibilă pentru notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit în orice scop, inclusiv pentru uz personal, comercial și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Ca să folosești sincronizarea temei, trebuie să selectezi tema `Omarchy` în setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația de scriere Markdown extrem de simplă a Omarchy. Fără vault-uri, fără plugin-uri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument simplu de editare a imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar să nu te aștepți la o alternativă la Photoshop. Dar tot are Magic Wand și straturi!

Pornești Pinta din lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cel mai simplu mod de a-ți [crea propria temă](43-making-your-own-theme.md).

Pornești Aether din lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, ca AirDrop de la Apple. Totuși, este multiplatformă, așa că poți trimite fișiere către și de la Windows, macOS, Android, iOS și, bineînțeles, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau la _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent ca să trimiți un link sau un fragment de cod pe telefon fără să-ți trimiți un e-mail.
- **File** deschide un selector de fișiere în care poți selecta mai multe deodată.
- **Folder** trimite un director întreg.
- **Receive** deschide LocalSend propriu-zis, ca alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează și din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Omite calea și primești selectorul.

Poți trimite și direct din managerul de fișiere: dă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis implicit, cu excepția portului LocalSend, așa că asta funcționează din prima pe o instalare proaspătă. Vezi [securitatea](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, calcul tabelar, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice din lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația de prezentări extrem de simplă a Omarchy. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile lui alături: scrii fiecare diapozitiv sub o previzualizare live, tragi diapozitivele în ordine, apoi prezinți pe ecran complet sau exporți în PDF și PowerPoint. Ba chiar îți preia tema Omarchy.

Pornești Hype din lansatorul de aplicații (`Super + Space`). Apasă `?` în interior ca să vezi fiecare scurtătură.

## Signed

[Signed](https://github.com/omacom/signed) este modul extrem de simplu al Omarchy de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată lângă original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru cum se face.

Pornești Signed din lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu el din managerul de fișiere.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) este jocul de șah 3D propriu al Omarchy. Joacă cu un prieten pe același computer sau împotriva adversarului integrat, la trei niveluri, pe patru seturi sculptate care se mișcă fiecare în felul lui: nave orbitale, lemn și fildeș sculptate, creaturi din pădure și bomboane. Partidele nu au ceas și se salvează după fiecare mutare.

Pornești Checkmate din lansatorul de aplicații (`Super + Space`), unde este listat ca Chess. Apasă `?` în interior ca să vezi fiecare scurtătură.

## Cards

[Cards](https://github.com/omacom/cards) este jocul Klondike solitaire propriu al Omarchy. Trage trei cărți, fără limită la numărul de treceri, în patru serii de cărți: una desenată în culorile temei tale și trei cu un aspect propriu. Dă clic pe o carte și apoi pe locul unde merge, trage-o sau dă dublu clic ca să o trimiți în cel mai bun loc. Partidele se salvează după fiecare mutare.

Pornești Cards din lansatorul de aplicații (`Super + Space`). Dă clic pe numele lui sau apasă `?` ca să vezi fiecare scurtătură.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul extrem de simplu propriu al Omarchy, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune de comunicare excelentă pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși asta, Omarchy îți va oferi să îl instaleze pentru tine (este și la _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul de imagini și playerul media extrem de simplu propriu al Omarchy: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie și tastele săgeți trec prin restul folderului ei, `N` și `P` fac asta pentru orice, iar `Ctrl + M` afișează întregul folder ca o grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și reia de unde ai rămas la orice durează mai mult.

Apasă `F` pentru ecran complet, `E` ca să editezi o imagine în Omasnap sau să tai un videoclip în Omacut, `Ctrl + P` ca să imprimi o imagine și `Delete` ca să muți un fișier la Trash (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interior ca să vezi fiecare scurtătură.

Pornești Omaview ca _Media Viewer_ din lansatorul de aplicații (`Super + Space`) sau pur și simplu dai dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul de tăiere video extrem de simplu propriu al Omarchy. Când tot ce îți trebuie este să tai începutul și sfârșitul unui clip, bate pornirea unui editor video complet.

Pornești Omacut din lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este înregistratorul webcam extrem de simplu propriu al Omarchy. Alege-ți camera și microfonul o singură dată, apoi apasă `Space` ca să înregistrezi și din nou ca să pui pauză și să reiei aceeași înregistrare. Înregistrează întotdeauna la cea mai mare rezoluție a camerei tale, cu un indicator live pentru microfon, ca să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și se deschide imediat într-un editor integrat. Dă dublu clic pe un clip ca să îl împarți, trage mânerele ca să tai fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea ta originală este păstrată până o arunci, așa că poți oricând să revii și să o tai altfel.

Pornești Monologue din lansatorul de aplicații (`Super + Space`).
