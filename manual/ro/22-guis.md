# Interfețe grafice

## Files

Files (Folio) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o mulțime de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îl previzualizează la dimensiune completă fără să-l deschidă.

Conectezi un stick USB sau un card SD și este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complicat — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic urmează setări implicite sensibile: imaginile, videoclipurile și muzica se deschid în Omaview, PDF-urile în Document Viewer, fișierele Markdown în Omawrite, iar textul simplu în editorul tău, Plain, dacă nu alegi altul la _Setup > Defaults > Editor_.

## Disktree

Când unitatea se umple și nu ai nicio idee ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Afișează o hartă arborescentă grafică a directorului tău personal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau mouse-ul, marchează ce trebuie să dispară și verifică selecțiile înainte să ștergi ceva. Rulează `disktree --disk` ca să scanezi întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și foarte extensibilă pentru luarea de notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru orice scop, inclusiv pentru uz personal, comercial și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile de pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Pentru a folosi sincronizarea temelor, trebuie să selectezi tema `Omarchy` din setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația de scriere Markdown extrem de simplă, proprie Omarchy. Fără vaulturi, fără pluginuri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar să nu te aștepți la o alternativă la Photoshop. Dar tot are Magic Wand și straturi!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cel mai simplu mod de a-ți [crea propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, ca AirDrop de la Apple. Totuși, este multiplatformă, așa că poți trimite fișiere către și de la Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul Share pe `Super + Ctrl + S` sau la _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Excelent pentru a duce un link sau un fragment pe telefon fără să-ți trimiți un e-mail.
- **File** deschide un selector de fișiere unde poți selecta mai multe deodată.
- **Folder** trimite un director întreg.
- **Receive** deschide LocalSend propriu-zis, astfel încât alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Omite calea și primești selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție din Files și partajeaz-o cu LocalSend.

Firewall-ul Omarchy este închis în mod implicit, cu excepția portului LocalSend, așa că acest lucru funcționează din start pe o instalare proaspătă. Vezi [securitate](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, foi de calcul, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate excelentă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația de prezentări extrem de simplă, proprie Omarchy. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile sale alături: scrii fiecare diapozitiv sub o previzualizare în timp real, tragi diapozitivele în ordine, apoi prezinți pe ecran complet sau exporți în PDF și PowerPoint. Preia chiar și tema ta Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul ei ca să vezi fiecare scurtătură.

## Signed

[Signed](https://github.com/omacom/signed) este modul extrem de simplu, propriu Omarchy, de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată alături de original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu el din managerul de fișiere.

## Game Vibes

Game Vibes, în lansatorul de aplicații (`Super + Space`), este locul unde trăiesc micile jocuri Omarchy: Checkmate, un joc de șah 3D împotriva unui prieten sau a adversarului integrat; Cards, un solitaire Klondike; Death Wish, un platformer precis la nivel de pixel, cu zece camere pline de țepi și fierăstraie; și Neon Swarm, un shooter arcade. Fiecare este o singură pagină web care urmează tema ta. Alege unul cu săgețile și `Enter` și întoarce-te la listă cu `Esc` de pe ecranul de titlu al unui joc sau cu `Q` cât timp este în pauză. Se deschide pe ecran complet: `Super + F` îl transformă într-o fereastră, iar `Super + W` îl închide.

Aici apar și jocurile pe care le faci cu un agent: alege _Make something cool → Game_ în panoul de agenți și descrie unul sau numește un joc deja existent în Game Vibes ca să continui să lucrezi la el. Agentul îl copiază în `~/Games/vibes`, unde este al tău ca să-l modifici, și îl deschide când este gata. Poți face acea copie chiar tu cu `omarchy games vibes copy <game>`. Un joc partajat de altcineva se instalează ca o temă: alege _Install > Gaming > Game Vibes_ și lipește adresa sa git sau rulează `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ elimină unul, iar _Update > Game Vibes Games_ aduce versiuni noi. Jocurile încarcă three.js de pe web, așa că au nevoie de o conexiune ca să pornească.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul extrem de simplu, propriu Omarchy, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune de comunicare excelentă pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși asta, Omarchy se va oferi să-l instaleze pentru tine (se află și la _Install > Service_ în meniul Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) este vizualizatorul de imagini și playerul media extrem de simplu, propriu Omarchy: o singură fereastră pentru fotografiile, videoclipurile și muzica ta. Deschide o fotografie și tastele săgeată trec prin restul folderului ei, `N` și `P` fac asta pentru orice, iar `Ctrl + M` arată întregul folder ca o grilă. Afișează și fotografii HEIC, AVIF și JPEG XL și reia de unde ai rămas în orice conținut lung.

Apasă `F` pentru ecran complet, `E` pentru a edita o imagine în Omasnap sau a tăia un videoclip în Omacut, `Ctrl + P` pentru a imprima o imagine și `Delete` pentru a muta un fișier în Trash (`Ctrl + Z` îl aduce înapoi). Apasă `?` în interiorul lui ca să vezi fiecare scurtătură.

Pornești Omaview ca _Media Viewer_ prin lansatorul de aplicații (`Super + Space`) sau doar faci dublu clic pe o imagine, un videoclip sau o melodie în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul de tăiere video extrem de simplu, propriu Omarchy. Când tot ce ai nevoie este să tai începutul și sfârșitul unui clip, bate pornirea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este recorderul webcam extrem de simplu, propriu Omarchy. Alege-ți camera și microfonul o singură dată, apoi apasă `Space` ca să înregistrezi și din nou ca să pui pauză și să reiei aceeași înregistrare. Înregistrează întotdeauna la cea mai mare rezoluție a camerei tale, cu un indicator de microfon în timp real, astfel încât să-ți poți verifica nivelurile înainte să începi.

Oprești înregistrarea și se deschide imediat într-un editor integrat. Fă dublu clic pe un clip ca să-l împarți, trage de mânere ca să tai fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea originală este păstrată până când o elimini, așa că poți oricând să revii și să o tai altfel.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
