# GUI-uri

## Files

Files (Nautilus) este managerul grafic de fișiere. `Super + Shift + F` îl deschide, iar `Super + Shift + Alt + F` îl deschide în directorul în care se află terminalul tău, ceea ce te scutește de o mulțime de clicuri. `Ctrl + L` îți permite să tastezi o cale, iar apăsarea tastei `Space` pe orice fișier îți oferă o previzualizare rapidă fără să deschizi nimic.

Conectează un stick USB sau un card SD și acesta este montat automat, așa că apare pur și simplu în bara laterală. Pentru orice lucru mai complicat — formatarea unui disc, verificarea stării SMART, crearea de partiții — lansează _Disks_ din lansatorul de aplicații (`Super + Space`).

Dublul clic urmează niște valori implicite rezonabile: imaginile se deschid în imv, videoclipurile în mpv, PDF-urile în Document Viewer, iar textul simplu în Neovim.

## Disktree

Când discul se umple și habar nu ai ce îl mănâncă, lansează [Disktree](https://github.com/tobi/disktree) din lansatorul de aplicații (`Super + Space`). Afișează o hartă treemap grafică a directorului tău personal. Blocurile mai mari ocupă mai mult spațiu; intră în directoare cu tastatura sau cu mouse-ul, marchează ce trebuie să dispară și verifică-ți selecțiile înainte să elimini ceva. Rulează `disktree --disk` pentru a scana întregul disc.

## Obsidian

[Obsidian](https://obsidian.md/) este o aplicație gratuită și extrem de extensibilă pentru luat notițe, care folosește fișiere Markdown simple pentru stocare.

Obsidian este gratuit pentru toate scopurile, inclusiv pentru uz personal, comercial și non-profit.

Obsidian oferă și un [supliment comercial pentru sincronizare](https://obsidian.md/sync) cu aplicațiile mobile de pe iOS și Android. (https://obsidian.md/pricing).

Pornești Obsidian cu `Super + Shift + O`. Pentru a folosi sincronizarea temei, trebuie să selectezi tema `Omarchy` din setări.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) este aplicația proprie a Omarchy, extrem de simplă, pentru scris în Markdown. Fără vault-uri, fără plugin-uri, doar tu și cuvintele.

Pornești Omawrite cu `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) este un instrument de bază pentru editarea imaginilor, grozav pentru decupare, redimensionare și alte manipulări de bază. Doar nu te aștepta la o alternativă la Photoshop. Dar tot are Magic Wand și straturi!

Pornești Pinta prin lansatorul de aplicații (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) este o aplicație de tematizare care poate extrage culori dintr-o imagine de fundal și le poate transforma într-o temă completă și coerentă. Este cel mai simplu mod de a-ți [face propria temă](43-making-your-own-theme.md).

Pornești Aether prin lansatorul de aplicații (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) îți permite să trimiți fișiere către alte dispozitive din aceeași rețea care rulează aplicația, la fel ca AirDrop de la Apple. Este însă multiplatformă, așa că poți trimite fișiere către și de pe Windows, macOS, Android, iOS și, bineînțeles, Linux.

Poți deschide meniul Share cu `Super + Ctrl + S` sau din _Trigger > Share_ în meniul Omarchy. Îți oferă patru opțiuni:

- **Clipboard** trimite tot ce ai copiat ca fișier text. Grozav pentru a pune un link sau un fragment pe telefon fără să-ți trimiți un e-mail.
- **File** deschide un selector de fișiere în care poți selecta mai multe deodată.
- **Folder** trimite un director întreg.
- **Receive** deschide LocalSend propriu-zis, ca alt dispozitiv să-ți poată trimite ceva.

Același lucru funcționează și din terminal cu `omarchy share clipboard`, `omarchy share file [path]` și `omarchy share folder [path]`. Omite calea și primești selectorul.

Poți trimite și direct din managerul de fișiere: fă clic dreapta pe orice selecție în Nautilus și alege _Send via LocalSend_.

Firewall-ul Omarchy este închis în mod implicit, cu excepția portului LocalSend, așa că acest lucru funcționează din prima pe o instalare proaspătă. Vezi [securitate](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) este un pachet office complet, cu procesor de text, foi de calcul, prezentări, aplicație de desen și multe altele. Este compatibil cu fișierele din Microsoft Office, așa că este o modalitate grozavă de a putea deschide acele documente Word.

Pornești LibreOffice prin lansatorul de aplicații (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) este aplicația proprie a Omarchy, extrem de simplă, pentru prezentări. Prezentarea ta este un singur fișier Markdown, cu imaginile și videoclipurile sale alături: scrie fiecare diapozitiv sub o previzualizare live, trage diapozitivele în ordine, apoi prezintă pe ecran complet sau exportă în PDF și PowerPoint. Îți preia chiar și tema Omarchy.

Pornești Hype prin lansatorul de aplicații (`Super + Space`). Apasă `?` în interiorul ei pentru a vedea fiecare scurtătură.

## Signed

[Signed](https://github.com/omacom/signed) este modalitatea proprie a Omarchy, extrem de simplă, de a semna PDF-uri și de a le completa. Pune semnătura ta salvată, text și data de astăzi oriunde pe o pagină, apoi salvează o copie semnată lângă original. Vezi [Completarea PDF-urilor](27-filling-out-pdfs.md) pentru a afla cum.

Pornești Signed prin lansatorul de aplicații (`Super + Space`) sau deschizi un PDF cu ea din managerul de fișiere.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) este calculatorul propriu al Omarchy, extrem de simplu, care se deschide într-o fereastră plutitoare.

Pornești Omacalc cu `Super + Shift + Q` (sau cu tasta de calculator, dacă tastatura ta are una).

## Signal

[Signal](https://signal.org/) este pionierul mesageriei criptate E2E și o opțiune grozavă de comunicare pentru oricine ar prefera să nu treacă printr-unul dintre marile conglomerate tech.

Pornești Signal cu `Super + Shift + G`. Nu face parte din instalarea de bază, așa că prima dată când apeși această combinație, Omarchy îți va propune să îl instaleze pentru tine (se află și sub _Install > Service_ în meniul Omarchy).

## mpv

[mpv](https://mpv.io/) este un player media simplu și rapid, care va reda aproape orice din orice sursă. Grozav pentru vizionarea videoclipurilor.

Pornești mpv prin lansatorul de aplicații (`Super + Space`) sau pur și simplu faci dublu clic pe un videoclip în managerul de fișiere.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) este instrumentul propriu al Omarchy, extrem de simplu, pentru tăierea videoclipurilor. Când tot ce ai nevoie este să tai începutul și sfârșitul unui clip, bate lansarea unui editor video complet.

Pornești Omacut prin lansatorul de aplicații (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) este aplicația proprie a Omarchy, extrem de simplă, pentru înregistrare cu camera web. Alege-ți camera și microfonul o singură dată, apoi apasă `Space` pentru a înregistra și din nou pentru a pune pauză și a relua aceeași înregistrare. Înregistrează întotdeauna la cea mai mare rezoluție a camerei tale, cu un indicator live al microfonului, ca să-ți poți verifica nivelurile înainte să începi.

Oprește înregistrarea și aceasta se deschide imediat într-un editor integrat. Fă dublu clic pe un clip pentru a-l împărți, trage de mânere pentru a tăia fiecare bucată și elimină părțile pe care nu le vrei. Apoi salvează-l ca MP4. Înregistrarea ta originală este păstrată până când o arunci, așa că poți oricând să revii și să o tai altfel.

Pornești Monologue prin lansatorul de aplicații (`Super + Space`).
