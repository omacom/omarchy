# GUI-uri

## Fișiere

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o mulțime de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectează un stick USB sau un card SD și acesta este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complex — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic respectă valori implicite rezonabile: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, fișierele Markdown în Omawrite, iar textul simplu în editorul ales la _Setup > Default > Editor_.

## Disktree

Când unitatea se umple și nu ai nicio idee ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Acesta afișează o hartă arborescentă grafică a directorului tău principal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau cu mouse-ul, marchează ce trebuie să dispară și verifică-ți selecțiile înainte să ștergi ceva. Rulează `disktree --disk` pentru a scana întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și foarte extensibilă pentru luarea de notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru toate scopurile, inclusiv pentru utilizare personală, comercială și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Pentru a folosi sincronizarea temei, trebuie să selectezi tema `Omarchy` din setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația proprie Omarchy, extrem de simplă, pentru scris în Markdown. Fără seifuri, fără pluginuri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar nu te aștepta la o alternativă la Photoshop. Dar are totuși Magic Wand și straturi!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cel mai simplu mod de a-ți [crea propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, la fel ca AirDrop de la Apple. Este însă multiplatformă, așa că poți trimite fișiere către și dinspre Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau din _Trigger > Share_ în meniul Omarchy. Acesta îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent pentru a pune un link sau un fragment pe telefonul tău fără să-ți trimiți un e-mail.
- **File** deschide un selector de fișiere în care poți selecta mai multe deodată.
- **Folder** trimite un director întreg.
- **Receive** deschide LocalSend propriu-zis, astfel încât alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează și din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Omite calea și obții selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis implicit, cu excepția portului LocalSend, așa că acest lucru funcționează din prima pe o instalare proaspătă. Vezi [securitate](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, foi de calcul, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația proprie Omarchy, extrem de simplă, pentru prezentări. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile lui alături: scrie fiecare diapozitiv sub o previzualizare live, trage diapozitivele în ordinea dorită, apoi prezintă pe tot ecranul sau exportă în PDF și PowerPoint. Preia chiar și tema ta Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul lui pentru a vedea toate scurtăturile.

## Signed

[Signed](https://github.com/omacom/signed) este modul propriu Omarchy, extrem de simplu, de a semna PDF-uri și de a le completa. Pune semnătura ta salvată, text și data de astăzi oriunde pe o pagină, apoi salvează o copie semnată lângă original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu el din managerul de fișiere.

## Game Vibes

Game Vibes, în lansatorul de aplicații (`Super + Space`), este locul unde trăiesc micile jocuri Omarchy: Checkmate, un joc de șah 3D împotriva unui prieten sau a adversarului integrat; Cards, solitaire Klondike; și Neon Swarm, un shooter arcade. Fiecare este o singură pagină web care îți urmează tema. Alege unul cu săgețile și `Enter` și întoarce-te la listă cu `Esc` din ecranul de titlu al unui joc sau cu `Q` cât timp acesta este în pauză. Se deschide pe tot ecranul: `Super + F` îl transformă într-o fereastră, iar `Super + W` îl închide.

Și jocurile pe care le creezi cu un agent apar aici: alege _Make something cool → Game_ în panoul de agenți și descrie unul sau numește un joc deja existent în Game Vibes pentru a continua să lucrezi la el. Agentul îl copiază în `~/Games/vibes`, unde este al tău pentru a-l modifica, și îl deschide când a terminat. Poți face tu însuți această copie cu `omarchy games vibes copy <game>`. Un joc pe care îl partajează altcineva se instalează ca o temă: alege _Install > Gaming > Game Vibes_ și lipește adresa lui git sau rulează `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ îl scoate din nou, iar _Update > Game Vibes Games_ aduce versiuni noi. Jocurile încarcă three.js de pe web, așa că au nevoie de o conexiune pentru a porni.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul propriu Omarchy, extrem de simplu, care se deschide într-o fereastră flotantă.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune excelentă de comunicare pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tehnologice.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși această combinație, Omarchy îți va oferi să îl instaleze pentru tine (se află și la _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul propriu Omarchy, extrem de simplu, pentru imagini și playerul media: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie, iar tastele săgeți trec prin restul folderului ei, `N` și `P` fac același lucru pentru orice, iar `Ctrl + M` afișează întregul folder ca o grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și reia de unde ai rămas în orice conținut lung.

Apasă `F` pentru ecran complet, `E` pentru a edita o imagine în Omasnap sau a tăia un videoclip în Omacut, `Ctrl + P` pentru a imprima o imagine și `Delete` pentru a muta un fișier în Trash (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interiorul lui pentru a vedea toate scurtăturile.

Pornești Omaview ca _Media Viewer_ prin lansatorul de aplicații (`Super + Space`) sau pur și simplu faci dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul propriu Omarchy, extrem de simplu, pentru tăierea videoclipurilor. Când tot ce ai nevoie este să tai începutul și sfârșitul unui clip, bate pornirea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este înregistratorul propriu Omarchy, extrem de simplu, pentru camera web. Alege-ți camera și microfonul o singură dată, apoi apasă `Space` pentru a înregistra și din nou pentru a pune pauză și a relua aceeași înregistrare. Înregistrează întotdeauna la cea mai mare rezoluție a camerei tale, cu un indicator live al microfonului, astfel încât să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și aceasta se deschide imediat într-un editor integrat. Fă dublu clic pe un clip pentru a-l împărți, trage de mânere pentru a tăia fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea ta originală este păstrată până când o elimini, așa că te poți întoarce oricând și o poți tăia diferit.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
