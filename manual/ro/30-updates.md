# Actualizări

Omarchy și pachetele tale sunt menținute la zi prin _Actualizare > Omarchy_ din meniul Omarchy (`Super + Space`).

Omarchy însuși este instalat ca pachete pacman obișnuite din [Depozitul de pachete Omarchy](https://github.com/omacom-io/omarchy-pkgs), așa că o actualizare instalează [cea mai recentă versiune Omarchy](https://github.com/omacom/omarchy/releases), rulează orice migrări rămase în așteptare pentru a-ți aduce sistemul în sincron cu cea mai recentă versiune și actualizează toate pachetele de sistem din [Mirror-ul Arch Omarchy](https://github.com/omacom-io/omarchy-mirror) și [AUR](https://aur.archlinux.org/) (dacă ai instalat vreun pachet AUR).

Când apar versiuni noi, o pictogramă cu o săgeată circulară va apărea în dreapta ceasului tău. Dă clic pe ea și procesul de actualizare va porni.

![update-available](images/update-available.webp)

### Patru canale

Omarchy este actualizat pe patru canale: stable, RC, edge și dev. Instalările noi pornesc pe canalul stable, care urmărește [versiunile oficiale](https://github.com/omacom/omarchy/releases/), precum și [mirror-ul Arch stabil al Omarchy](https://github.com/omacom-io/omarchy-mirror), care rămâne cu o lună în urma celor mai recente, astfel încât să putem depista orice incompatibilități noi care necesită modificări de configurare înainte ca acestea să creeze probleme oamenilor.

Dar dacă vrei să ajuți la depistarea acestor probleme potențiale, poți rula pe canalul edge. Astfel, pachetele tale Omarchy vor urmări cele mai recente build-uri de dezvoltare și vei putea actualiza la cele mai recente pachete Arch de îndată ce acestea devin disponibile. Ar trebui să faci asta numai dacă ai experiență cu Linux și știi cum să recuperezi un sistem care are probleme.

Înainte de orice versiune majoră nouă, vom face validarea finală folosind canalul RC. Dacă te interesează să ajuți la ultimele finisaje, vino alături de noi în #omarchy-release-candidates pe Discord.

În cele din urmă, există canalul dev, care leagă Omarchy direct la un checkout git al codului sursă din `~/omarchy`, combinat cu pachetele edge. Ar trebui să folosești acest canal numai dacă ești un utilizator Linux experimentat, lucrezi direct la Omarchy și ești dispus să tolerezi defecțiuni.

Poți comuta între canale folosind _Actualizare > Canal_ din meniul Omarchy (sau `omarchy channel set <stable|rc|edge|dev>` în terminal, cu `omarchy channel current` pentru a vedea unde te afli).

### Schimbarea kernelului

Omarchy pornește cu propriul kernel `linux-omarchy`, dar poți păstra alte kerneluri instalate alături de el, precum kernelul `linux` standard al Arch sau un build experimental pe care îl testezi. Când există mai mult de unul, _Actualizare > Kernel_ din meniul Omarchy le listează, cu o bifă lângă cel care pornește implicit. Alege altul, introdu parola o singură dată, iar acesta va porni după următoarea repornire. Celelalte kerneluri rămân în meniul de pornire, așa că poți în continuare să alegi unul manual dacă noul kernel implicit îți creează probleme. În terminal, folosești `omarchy kernel` pentru a vedea kernelul implicit curent, `omarchy kernel list` pentru a vedea ce este instalat și `omarchy kernel set <kernel>` pentru a comuta.

### Actualizări de firmware

Pachetele tale nu sunt singurul lucru care rămâne în urmă. Multe laptopuri și periferice furnizează firmware pentru BIOS, SSD și dock prin Linux Vendor Firmware Service, iar _Actualizare > Firmware_ din meniul Omarchy va prelua și instala tot ce are hardware-ul tău în așteptare. Acesta instalează `fwupd` prima dată când îl rulezi. O mare parte din firmware poate fi scris numai în timpul unei reporniri, așa că nu te mira dacă ți se cere una.

Când trebuie să schimbi o setare chiar în BIOS, ține apăsat `Alt` în meniul de sistem (`Super + Escape`), iar _Repornire_ se transformă în _Repornire în BIOS_, care repornește direct în configurarea firmware-ului, fără să trebuiască să nimerești tasta potrivită la pornire. Din terminal, folosești `omarchy system firmware`.

### Avertisment privind actualizările directe cu pacman/yay

Dacă ești deja familiarizat cu Arch, ai putea fi tentat să rulezi pur și simplu `pacman -Syu` sau `yay -Syu` pe cont propriu, dar dacă faci asta, vei pierde instantaneul, migrările și actualizările de configurare pe care Omarchy le rulează împreună cu noile pachete. De aceea, Omarchy va opri de fapt o actualizare directă a sistemului și te va îndruma în schimb către `omarchy update`. (Dacă chiar știi ce faci, mecanismul de protecție îți va spune cum să îl ocolești pentru o singură tranzacție.)

### Revenirea după o actualizare nereușită

Dacă ai vreodată o problemă după ce ai făcut o actualizare, îți poți readuce sistemul la instantaneul realizat înainte de actualizare. Pur și simplu repornește și alege din meniul de încărcare la pornire instantaneul de dinainte să începi actualizarea.

![bootloader](images/bootloader.webp)

Dacă, cumva, fișierele tale de configurare au fost corupte, poți efectua și o reinstalare Omarchy folosind `omarchy reinstall` în terminal. Aceasta va reinstala toate pachetele Omarchy implicite, te va trece pe stable (edge pe Apple Silicon), va retrograda orice pachete care sunt prea noi și va reseta toate fișierele de configurare. Reține că, făcând asta, toate modificările tale de configurare a valorilor implicite Omarchy vor fi suprascrise!
