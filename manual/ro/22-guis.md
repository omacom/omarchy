# Interfețe grafice

## Fișiere

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce economisește multe clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea lui `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectează un stick USB sau un card SD și este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice mai implicat — formatarea unei unități, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic urmează valori implicite sensibile: imaginile se deschid în imv, video în mpv, PDF-urile în Document Viewer și textul simplu în Neovim.

## Disktree

Când unitatea se umple și habar nu ai ce o mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Arată o hartă grafică de tip treemap a directorului tău home. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau mouse-ul, marchează ce trebuie să plece și revizuiește-ți selecțiile înainte să elimini ceva. Rulează `disktree --disk` ca să scanezi întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și foarte extensibilă de luat notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru toate scopurile, inclusiv utilizare personală, comercială și non-profit.

Obsidian oferă și un [adaos comercial pentru sincronizare](https://obsidian.md/sync) cu aplicații mobile pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Ca să folosești sincronizarea temei, trebuie să selectezi tema `Omarchy` în setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația de scriere Markdown incredibil de simplă a Omarchy. Fără vault-uri, fără pluginuri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază de editare a imaginilor, excelent pentru decupare, redimensionare și alte manipulări de bază. Doar nu te aștepta la o alternativă Photoshop. Dar tot are bagheta magică și straturi!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă, coerentă. Este cel mai ușor mod de a-ți [face propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, precum AirDrop de la Apple. Este însă multiplatformă, așa că poți trimite fișiere către și de pe Windows, macOS, Android, iOS și, desigur, Linux.

Poți deschide meniul de partajare cu `Super + Ctrl + S` sau sub _Declanșator > Partajează_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite orice ai copiat ca fișier text. Excelent pentru a duce un link sau un fragment pe telefon fără să-ți trimiți e-mail.
- **Fișier** deschide un selector de fișiere unde poți selecta mai multe deodată.
- **Dosar** trimite un director întreg.
- **Primește** deschide LocalSend propriu-zis, astfel încât alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează și din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Lasă calea afară și primești selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis implicit, cu excepția portului LocalSend, așa că asta funcționează din start pe o instalare proaspătă. Vezi [securitatea](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet de birou complet, cu procesor de text, calcul tabelar, prezentări, aplicație de desen și altele. Este compatibil cu fișierele din Microsoft Office, așa că este o cale excelentă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația de prezentări incredibil de simplă a Omarchy. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile lui lângă el: scrie fiecare diapozitiv sub o previzualizare live, trage diapozitivele în ordine, apoi prezintă pe tot ecranul sau exportă în PDF și PowerPoint. Îți preia chiar și tema Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul lui ca să vezi toate scurtăturile.

## Signed

[Signed](https://github.com/omacom/signed) este metoda incredibil de simplă a Omarchy de a semna PDF-uri și de a le completa. Pune semnătura salvată, text și data de azi oriunde pe o pagină, apoi salvează o copie semnată lângă original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu el din managerul de fișiere.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul incredibil de simplu al Omarchy, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Ctrl + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesajelor criptate cap-la-cap și o opțiune de comunicare excelentă pentru oricine preferă să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși combinația, Omarchy se va oferi să-l instaleze pentru tine (se află și sub _Instalează > Serviciu_ în meniul Omarchy).

## mpv

[mpv](https://mpv.io/) este un player media simplu și rapid, care va reda aproape orice, din orice sursă. Excelent pentru vizionarea videoclipurilor.

Pornești mpv prin lansatorul de aplicații (`Super + Space`) sau fă pur și simplu dublu clic pe un videoclip în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este trimmer-ul video incredibil de simplu al Omarchy. Când tot ce-ți trebuie este să tai începutul și sfârșitul unui clip, bate pornirea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este înregistratorul webcam incredibil de simplu al Omarchy. Alege-ți camera și microfonul o dată, apoi apasă `Space` ca să înregistrezi și din nou ca să pui pauză și să reiei aceeași înregistrare. Înregistrează întotdeauna la cea mai înaltă rezoluție a camerei tale, cu un contor de microfon live, astfel încât să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și se deschide imediat într-un editor încorporat. Fă dublu clic pe un clip ca să-l desparți, trage mânerele ca să ajustezi fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea originală este păstrată până când renunți la ea, așa că te poți întoarce întotdeauna și o poți tăia altfel.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
