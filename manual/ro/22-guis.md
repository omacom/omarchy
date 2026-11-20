# GUI-uri

## Files

Files (Folio) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de multe clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îl previzualizează la dimensiune completă fără să-l deschizi.

Conectezi un stick USB sau un card SD și este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complex — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublu-clicul urmează setări implicite de bun-simț: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, fișierele Markdown în Omawrite, iar textul simplu în editorul ales la _Setup > Default > Editor_.

## Disktree

Când unitatea se umple și habar n-ai ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Afișează o hartă arborescentă grafică a directorului tău home. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau mouse-ul, marchează ce trebuie să dispară și verifică selecțiile înainte să ștergi ceva. Rulează `disktree --disk` ca să scanezi întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și foarte extensibilă pentru luarea de notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru toate scopurile, inclusiv pentru uz personal, comercial și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Ca să folosești sincronizarea temelor, trebuie să selectezi tema `Omarchy` din setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația proprie a Omarchy, extrem de simplă, pentru scris în Markdown. Fără vault-uri, fără plugin-uri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar să nu te aștepți la o alternativă la Photoshop. Dar tot are Magic Wand și straturi!

Pornești Pinta din lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cel mai simplu mod de a-ți [crea propria temă](43-making-your-own-theme.md).

Pornești Aether din lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea pe care rulează aplicația, ca AirDrop de la Apple. Totuși, este multiplatformă, așa că poți trimite fișiere către și dinspre Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau la _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent ca să pui un link sau un fragment pe telefon fără să-ți trimiți e-mail.
- **File** deschide un selector de fișiere în care poți selecta mai multe deodată.
- **Folder** trimite un director întreg.
- **Receive** deschide LocalSend propriu-zis, ca alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează și din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Omite calea și primești selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție în Files și partajeaz-o cu LocalSend.

Firewall-ul Omarchy este închis în mod implicit, cu excepția portului LocalSend, așa că acest lucru funcționează din prima pe o instalare nouă. Vezi [securitate](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, calcul tabelar, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice din lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația proprie a Omarchy, extrem de simplă, pentru prezentări. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile lângă el: scrii fiecare diapozitiv sub o previzualizare live, tragi diapozitivele în ordine, apoi prezinți pe tot ecranul sau exporți în PDF și PowerPoint. Îți preia chiar și tema Omarchy.

Pornești Hype din lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul ei ca să vezi fiecare scurtătură.

## Signed

[Signed](https://github.com/omacom/signed) este modalitatea proprie a Omarchy, extrem de simplă, de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată lângă original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed din lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu ea din managerul de fișiere.

## Game Vibes

Game Vibes, în lansatorul de aplicații (`Super + Space`), este locul unde trăiesc micile jocuri ale Omarchy: Checkmate, un joc de șah 3D împotriva unui prieten sau a adversarului integrat; Cards, solitaire Klondike; și Neon Swarm, un shooter arcade. Fiecare este o singură pagină web care urmează tema ta. Alege unul cu săgețile și `Enter` și întoarce-te la listă cu `Esc` din ecranul de titlu al unui joc sau cu `Q` cât timp este în pauză. Se deschide pe tot ecranul: `Super + F` îl transformă într-o fereastră, iar `Super + W` îl închide.

Jocurile pe care le faci cu un agent apar și ele aici: alege _Make something cool → Game_ în panoul de agenți și descrie unul sau numește un joc deja existent în Game Vibes ca să continui să lucrezi la el. Agentul îl copiază în `~/Games/vibes`, unde este al tău ca să-l modifici, și îl deschide când este gata. Poți face singur acea copie cu `omarchy games vibes copy <game>`. Un joc pe care îl partajează altcineva se instalează ca o temă: alege _Install > Gaming > Game Vibes_ și lipește adresa lui git sau rulează `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ scoate din nou unul, iar _Update > Game Vibes Games_ aduce versiuni noi. Jocurile încarcă three.js de pe web, așa că au nevoie de o conexiune ca să pornească.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul propriu al Omarchy, extrem de simplu, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta calculatorului, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune excelentă de comunicare pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși asta, Omarchy îți va oferi să ți-l instaleze (se află și la _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul de imagini și playerul media propriu al Omarchy, extrem de simplu: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie și tastele săgeată trec prin restul directorului ei, `N` și `P` fac asta pentru orice, iar `Ctrl + M` afișează întregul director ca o grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și reia de unde ai rămas în orice lucru lung.

Apasă `F` pentru ecran complet, `E` ca să editezi o imagine în Omasnap sau să tai un videoclip în Omacut, `Ctrl + P` ca să imprimi o imagine și `Delete` ca să muți un fișier în Coșul de gunoi (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interiorul ei ca să vezi fiecare scurtătură.

Pornești Omaview ca _Media Viewer_ din lansatorul de aplicații (`Super + Space`) sau pur și simplu faci dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul propriu al Omarchy, extrem de simplu, pentru tăierea videoclipurilor. Când tot ce ai nevoie este să tai începutul și sfârșitul unui clip, bate lansarea unui editor video complet.

Pornești Omacut din lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este înregistratorul webcam propriu al Omarchy, extrem de simplu. Alege-ți camera și microfonul o singură dată, apoi apasă `Space` ca să înregistrezi și din nou ca să pui pauză și să reiei aceeași înregistrare. Înregistrează întotdeauna la cea mai înaltă rezoluție a camerei tale, cu un indicator live al microfonului, ca să-ți poți verifica nivelurile înainte să începi.

Oprești înregistrarea și se deschide imediat într-un editor integrat. Fă dublu clic pe un clip ca să-l împarți, trage mânerele ca să tai fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea originală este păstrată până când renunți la ea, așa că poți oricând să te întorci și s-o tai altfel.

Pornești Monologue din lansatorul de aplicații (`Super + Space`).
