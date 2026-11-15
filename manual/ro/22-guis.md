# GUI-uri

## Files

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o grămadă de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectează un stick USB sau un card SD și se montează automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complicat — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublu-clicul urmează setări implicite sensibile: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, iar textul simplu în Neovim.

## Disktree

Când unitatea se umple și nu ai nicio idee ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Afișează o hartă arborescentă grafică a directorului tău personal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau mouse-ul, marchează ce trebuie să dispară și verifică selecțiile înainte să ștergi ceva. Rulează `disktree --disk` pentru a scana întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și foarte extensibilă pentru luarea de notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru toate scopurile, inclusiv pentru uz personal, comercial și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Pentru a folosi sincronizarea temei, trebuie să selectezi tema `Omarchy` în setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația proprie a Omarchy, extrem de simplă, pentru scris în Markdown. Fără vault-uri, fără plugin-uri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar să nu te aștepți la o alternativă la Photoshop. Dar tot are Magic Wand și layere!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cea mai ușoară cale să-ți [faci propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, ca AirDrop de la Apple. Totuși, este multiplatformă, așa că poți trimite fișiere către și de la Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau din _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent pentru a trimite un link sau un fragment pe telefon fără să-ți trimiți e-mail.
- **File** deschide un selector de fișiere în care poți selecta mai multe deodată.
- **Folder** trimite un întreg director.
- **Receive** deschide LocalSend propriu-zis, ca alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Lasă calea deoparte și primești selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis implicit, cu excepția portului LocalSend, așa că acest lucru funcționează din prima pe o instalare nouă. Vezi [securitate](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, foi de calcul, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația proprie a Omarchy, extrem de simplă, pentru prezentări. Deck-ul tău este un singur fișier Markdown, cu imaginile și videoclipurile lui alături: scrie fiecare slide sub o previzualizare live, trage slide-urile în ordine, apoi prezintă pe tot ecranul sau exportă în PDF și PowerPoint. Îți preia chiar și tema Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interior pentru a vedea toate scurtăturile.

## Signed

[Signed](https://github.com/omacom/signed) este modul propriu al Omarchy, extrem de simplu, de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată alături de original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschide un PDF cu el din managerul de fișiere.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul propriu al Omarchy, extrem de simplu, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune excelentă de comunicare pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși combinația aceea, Omarchy îți va propune să-l instaleze pentru tine (se află și în _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul de imagini și playerul media propriu al Omarchy, extrem de simplu: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie și tastele săgeată trec prin restul folderului ei, `N` și `P` fac asta pentru orice, iar `Ctrl + M` arată întregul folder ca grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și continuă de unde ai rămas în orice lucru lung.

Apasă `F` pentru ecran complet, `E` pentru a edita o imagine în Omasnap sau a tăia un videoclip în Omacut, `Ctrl + P` pentru a imprima o imagine și `Delete` pentru a muta un fișier în Trash (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interior pentru a vedea toate scurtăturile.

Pornești Omaview ca _Media Viewer_ prin lansatorul de aplicații (`Super + Space`) sau pur și simplu fă dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul propriu al Omarchy, extrem de simplu, pentru tăiat videoclipuri. Când tot ce ai nevoie este să tai începutul și sfârșitul unui clip, bate pornirea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este recorderul webcam propriu al Omarchy, extrem de simplu. Alege camera și microfonul o singură dată, apoi apasă `Space` pentru a înregistra și din nou pentru a pune pauză și a relua aceeași înregistrare. Înregistrează întotdeauna la cea mai mare rezoluție a camerei tale, cu un indicator live al microfonului, ca să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și se deschide imediat într-un editor integrat. Fă dublu clic pe un clip pentru a-l împărți, trage de mânere pentru a tăia fiecare bucată și elimină părțile pe care nu le vrei. Apoi salveaz-o ca MP4. Înregistrarea originală este păstrată până când o arunci, așa că poți oricând să revii și să o tai altfel.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
