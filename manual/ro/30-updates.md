# Actualizări

Omarchy și pachetele tale sunt menținute la zi prin _Actualizare > Omarchy_ din meniul Omarchy (`Super + Space`).

Omarchy însuși este instalat ca pachete pacman obișnuite din [Depozitul de Pachete Omarchy](https://github.com/omacom-io/omarchy-pkgs), așa că o actualizare instalează [cea mai recentă versiune Omarchy](https://github.com/omacom/omarchy/releases), rulează orice migrări aflate în așteptare pentru a-ți aduce sistemul în sincron cu cea mai recentă versiune și actualizează toate pachetele de sistem din [Oglinda Arch Omarchy](https://github.com/omacom-io/omarchy-mirror) și [AUR](https://aur.archlinux.org/) (dacă ai instalat vreun pachet AUR).

Când sunt lansate versiuni noi, în dreapta ceasului tău va apărea o pictogramă cu o săgeată circulară. Dă clic pe ea și procesul de actualizare va începe.

![update-available](images/update-available.webp)

### Patru canale

Omarchy este actualizat pe patru canale: stable, RC, edge și dev. Instalațiile noi încep pe canalul stable, care urmărește [versiunile oficiale](https://github.com/omacom/omarchy/releases/), precum și [oglinda Arch Omarchy stabilă](https://github.com/omacom-io/omarchy-mirror), care rulează cu o lună în urma celei mai recente, ca să putem depista orice incompatibilități noi care necesită modificări de configurare înainte ca acestea să le creeze probleme oamenilor.

Dar dacă vrei să ajuți la depistarea acestor probleme potențiale, poți rula pe canalul edge. Acesta îți va menține pachetele Omarchy pe cele mai recente versiuni de dezvoltare și îți permite să actualizezi la cele mai recente pachete Arch de îndată ce devin disponibile. Ar trebui să faci asta doar dacă ai experiență cu Linux și știi cum să recuperezi un sistem care are probleme.

Înainte de orice versiune majoră nouă, vom face validarea finală folosind canalul RC. Dacă ești interesat să ajuți la finisajele finale, vino pe #omarchy-release-candidates pe Discord.

În sfârșit, există canalul dev, care leagă Omarchy direct de o copie git a codului sursă din `~/omarchy`, combinată cu pachetele edge. Ar trebui să folosești acest canal doar dacă ești un utilizator Linux experimentat, lucrezi direct la Omarchy și ești dispus să tolerezi defecțiuni.

Poți comuta între canale folosind _Actualizare > Canal_ din meniul Omarchy (sau `omarchy-channel-set` în terminal).

### Schimbarea kernelurilor

Omarchy pornește propriul său kernel `linux-omarchy`, dar poți păstra și altele instalate alături de el, cum ar fi kernelul Arch standard `linux` sau o versiune experimentală pe care o testezi. Când există mai multe, _Actualizare > Kernel_ din meniul Omarchy le afișează cu o bifă lângă cel care pornește în mod implicit. Alege altul, introdu parola o dată și acesta va porni după următoarea repornire. Celelalte kerneluri rămân în meniul de pornire, așa că poți alege în continuare unul manual dacă noul kernel implicit îți creează probleme. În terminal, folosești `omarchy-kernel` pentru a vedea kernelul implicit curent, `omarchy-kernel list` pentru a vedea ce este instalat și `omarchy-kernel set <kernel>` pentru a schimba.

### Actualizări de firmware

Pachetele tale nu sunt singurul lucru care se învechește. Multe laptopuri și periferice distribuie firmware pentru BIOS, SSD și dock prin Linux Vendor Firmware Service, iar _Actualizare > Firmware_ din meniul Omarchy va prelua și instala tot ce are hardware-ul tău în așteptare. La prima rulare instalează `fwupd`. Mult firmware poate fi scris doar în timpul unei reporniri, așa că nu te mira dacă ți se cere una.

Când trebuie să schimbi o setare chiar în BIOS, ține apăsat `Alt` în meniul de sistem (`Super + Escape`), iar _Repornire_ se transformă în _Repornire în BIOS_, care repornește direct în configurarea firmware-ului, fără să trebuiască să prinzi tasta potrivită la pornire. Din terminal, comanda este `omarchy system firmware`.

### Avertisment privind actualizările directe cu pacman/yay

Dacă ești deja familiarizat cu Arch, ai putea fi tentat să rulezi pur și simplu `pacman -Syu` sau `yay -Syu` pe cont propriu, dar dacă faci asta, vei rata snapshot-ul, migrările și actualizările de configurare pe care Omarchy le rulează împreună cu pachetele noi. De aceea Omarchy va opri de fapt o actualizare directă a sistemului și te va îndruma în schimb către `omarchy update`. (Dacă chiar știi ce faci, protecția îți va spune cum să o ocolești pentru o singură tranzacție.)

### Revenirea după actualizări problematice

Dacă ai vreodată o problemă după ce ai făcut o actualizare, poți readuce sistemul la snapshot-ul realizat înainte de actualizare. Pur și simplu repornește și alege din meniul de încărcare la pornire snapshot-ul de dinainte să fi început actualizarea.

![bootloader](images/bootloader.webp)

Dacă, cumva, fișierele tale de configurare au fost corupte, poți efectua și o reinstalare Omarchy folosind `omarchy reinstall` în terminal. Aceasta va reinstala toate pachetele Omarchy implicite, te va trece pe stable și va retrograda orice pachete care sunt prea noi și va reseta toate fișierele de configurare. Reține că, dacă faci asta, toate modificările tale de utilizator aduse valorilor implicite Omarchy vor fi suprascrise!
