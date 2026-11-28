# Primii pași

Omarchy se instalează folosind un ISO. Poți alege între o instalare pe întregul disc, care preia întregul disc, sau o instalare în spațiul liber, care pune Omarchy în spațiul nealocat de pe un disc — așa faci dual boot alături de Windows sau de alt sistem de operare (vezi [instalare dual-boot](50-dual-boot-install.md) — reține că mai întâi va trebui să dezactivezi BitLocker în Windows). În ambele cazuri, instalarea folosește implicit criptarea completă, iar opțiunea pentru întregul disc va șterge discul selectat, așa că asigură-te că faci o copie de rezervă înainte să folosești unul existent!

Pe un Mac cu Apple Silicon, instalezi direct din macOS, fără ISO sau stick USB. Vezi [Omarchy pentru Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Descarcă ISO-ul Omarchy](https://omarchy.org/) mai întâi, pune-l pe un stick USB (folosește [Rufus](https://rufus.ie/) pe Windows, [balenaEtcher](https://etcher.balena.io/) pe Mac sau [caligula](https://github.com/ifd3f/caligula) pe Linux) și pornește de pe stick.

_Trebuie să dezactivezi Secure Boot și/sau TPM în BIOS. Trebuie să le dezactivezi ca să poți instala Omarchy. Sunt scheme de securitate Microsoft gândite pentru Windows și pentru distribuțiile Linux afiliate Microsoft._

Apoi răspunde la întrebările de configurare și confirmă-le așa:

 ![install-config](images/install-config.webp)

Apoi selectează un disc pentru instalarea ta și relaxează-te și urmărește spectacolul instalării. Poate fi gata în mai puțin de un minut pe cele mai rapide mașini moderne, dar nu ar trebui să dureze mai mult de 5 minute nici pe un computer mai vechi.

 ![install-done](images/install-done.webp)

Acum ești gata de Omarchy!

### Folosește o tastatură cu fir sau de 2.4ghz!

Criptarea completă a discului nu îți va permite să introduci parola de la o tastatură Bluetooth la pornire. La fel cum nu poți folosi o tastatură Bluetooth ca să intri în BIOS pe un PC. Vei avea nevoie de o tastatură care fie folosește un dongle de 2.4ghz, fie un cablu (ceea ce este oricum mult mai bine pentru latență!). Personal, ador [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalarea pentru alt proprietar

Dacă pregătești o mașină pentru altcineva — un membru al familiei, un angajat nou, un cumpărător — nu ar trebui să răspunzi în locul lui la întrebările personale. Apasă `Ctrl + C` pe chiar primul ecran al programului de instalare (selectarea tastaturii), iar Omarchy îți va propune să pregătească mașina pentru alt proprietar. Sistemul se instalează imediat, dar toată configurarea personală — dispunerea tastaturii, numele de utilizator, parola — este amânată până când mașina pornește pentru prima dată. Discul este în continuare criptat implicit, iar parola pe care noul proprietar o alege la acea primă pornire devine și parola de criptare. (O mașină pe care ai folosit-o deja poate fi predată și fără reinstalare — vezi [resetarea computerului](48-security.md).)

### Instalări nesupravegheate

ISO-ul se poate instala și complet singur — fără tastatură, fără asistent — atunci când îi este furnizată configurația pe un al doilea disc. Așa tratezi Omarchy ca imagine de bază pentru VMs și pentru parcuri de mașini. Vezi [instalări nesupravegheate](51-unattended-installs.md).

### Instalări fără criptare

Omarchy se instalează implicit cu criptare. Este alegerea sigură și responsabilă pentru orice computer care ar putea fi pierdut sau furat. Nu vrei ca oricine are acces la hardware-ul tău să îți poată accesa datele!

Dar în circumstanțe speciale, cum ar fi instalările Omarchy la distanță pe computere protejate sau instalările efemere fără date sensibile, s-ar putea să vrei să instalezi fără criptare. Poți apăsa `Ctrl + C` la confirmarea formatării discului pentru a trece la o instalare fără criptare.

### Limba

Omarchy vorbește 50 de limbi — același set ca pe omarchy.org — iar engleza este limba implicită. Ca să o schimbi, deschide meniul Omarchy și mergi la _Setup > Region > Language_ sau rulează `omarchy language <code>` într-un terminal (`omarchy language list` afișează codurile). Meniul, desktopul și notificările proprii Omarchy își schimbă limba imediat, iar fiecare aplicație pe care o deschizi după aceea o urmează și ea. Aplicațiile care erau deja deschise se schimbă odată ce le repornești.

Ca să păstrezi limba, dar să scrii datele, orele, numerele, banii, unitățile și dimensiunile hârtiei așa cum o face altă regiune (engleză cu date europene și ceas de 24 de ore, să zicem), alege o regiune la _Setup > Region > Formats_, unde fiecare alegere arată un exemplu, sau rulează `omarchy region formats <code>` (`omarchy region formats list` afișează codurile). _Same as language_ te întoarce la formatele proprii ale limbii. Ca și schimbarea limbii, ajunge la aplicațiile pe care le deschizi după aceea.

### Ajutor dacă te-ai blocat

Dacă te-ai blocat, de obicei poți găsi pe cineva dispus să te ajute în canalul _#omarchy-help_ de pe [Discordul comunității](https://omarchy.org/discord).
