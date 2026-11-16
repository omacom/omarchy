# Interfețe grafice

## Fișiere

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o mulțime de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectează un stick USB sau un card SD și este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complicat — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic urmează setările implicite sensibile: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, Markdown în Omawrite, iar textul simplu în editorul ales la _Setup > Default > Editor_.

## Disktree

Când unitatea se umple și habar nu ai ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Îți arată o hartă arborescentă grafică a directorului tău personal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau mouse-ul, marchează ce trebuie să dispară și verifică selecțiile înainte să ștergi ceva. Rulează `disktree --disk` pentru a scana întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație de luare de notițe gratuită și extrem de extensibilă, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuită în toate scopurile, inclusiv pentru uz personal, comercial și non-profit.

Obsidian oferă, de asemenea, un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Pentru a folosi sincronizarea temei, trebuie să selectezi tema `Omarchy` din setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația proprie Omarchy, extrem de simplă, pentru scris în Markdown. Fără vault-uri, fără plugin-uri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar nu te aștepta la o alternativă la Photoshop. Dar are totuși Baghetă magică și straturi!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cea mai simplă cale să [îți creezi propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere altor dispozitive din aceeași rețea care rulează aplicația, la fel ca AirDrop de la Apple. Totuși, este multiplatformă, așa că poți trimite fișiere către și dinspre Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau la _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent pentru a trimite un link sau un fragment pe telefon fără să-ți trimiți un e-mail.
- **File** deschide un selector de fișiere în care poți selecta mai multe deodată.
- **Folder** trimite un întreg director.
- **Receive** deschide LocalSend propriu-zis, astfel încât un alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Lasă calea afară și primești selectorul.

Poți, de asemenea, trimite direct din managerul de fișiere: fă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis implicit, cu excepția portului LocalSend, așa că acest lucru funcționează din prima la o instalare proaspătă. Vezi [securitate](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet de birou complet, cu procesor de text, foi de calcul, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația proprie Omarchy, extrem de simplă, pentru prezentări. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile lui alături: scrie fiecare diapozitiv sub o previzualizare live, trage diapozitivele în ordinea dorită, apoi prezintă pe tot ecranul sau exportă în PDF și PowerPoint. Preia chiar și tema ta Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul ei pentru a vedea toate scurtăturile.

## Signed

[Signed](https://github.com/omacom/signed) este modul propriu Omarchy, extrem de simplu, de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată lângă original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu ea din managerul de fișiere.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) este jocul de șah 3D propriu Omarchy. Joacă cu un prieten pe același computer sau împotriva adversarului integrat, la trei niveluri, pe patru seturi sculptate care se mișcă fiecare în felul lui: nave orbitale, lemn și fildeș sculptate, creaturi din pădure și bomboane. Jocurile nu au ceas și se salvează după fiecare mutare.

Pornești Checkmate prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul lui pentru a vedea toate scurtăturile.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul propriu Omarchy, extrem de simplu, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune excelentă de comunicare pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși asta, Omarchy se va oferi să ți-l instaleze (se află și la _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul de imagini și playerul media propriu Omarchy, extrem de simplu: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie și tastele săgeți trec prin restul folderului ei, `N` și `P` fac asta pentru orice, iar `Ctrl + M` arată întregul folder sub formă de grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și continuă de unde ai rămas în orice lucru lung.

Apasă `F` pentru ecran complet, `E` pentru a edita o imagine în Omasnap sau a tăia un videoclip în Omacut, `Ctrl + P` pentru a imprima o imagine și `Delete` pentru a muta un fișier în Coș (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interiorul ei pentru a vedea toate scurtăturile.

Pornești Omaview ca _Media Viewer_ prin lansatorul de aplicații (`Super + Space`) sau pur și simplu faci dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul propriu Omarchy, extrem de simplu, pentru tăierea videoclipurilor. Când nu îți trebuie decât să tai începutul și sfârșitul unui clip, bate pornirea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este înregistratorul webcam propriu Omarchy, extrem de simplu. Alege-ți camera și microfonul o dată, apoi apasă `Space` pentru a înregistra și din nou pentru a pune pauză și a relua aceeași înregistrare. Înregistrează întotdeauna la cea mai mare rezoluție a camerei tale, cu un indicator de nivel al microfonului în timp real, ca să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și se deschide imediat într-un editor integrat. Fă dublu clic pe un clip pentru a-l împărți, trage de margini pentru a tăia fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea originală este păstrată până o arunci, așa că poți oricând să revii și să o tai altfel.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
