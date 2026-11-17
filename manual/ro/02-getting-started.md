# Primii pași

Omarchy se instalează folosind un ISO. Poți alege între o instalare pe întregul disc, care preia întregul disc, sau o instalare în spațiul liber, care pune Omarchy în spațiul nealocat de pe un disc — așa faci dual boot alături de Windows sau de alt sistem de operare (vezi [instalarea dual-boot](50-dual-boot-install.md) — reține că mai întâi va trebui să dezactivezi BitLocker în Windows). În ambele cazuri, instalarea este implicit cu criptare completă, iar opțiunea pentru întregul disc va șterge discul selectat, așa că asigură-te că faci un backup înainte să folosești unul existent!

[Descarcă ISO-ul Omarchy](https://omarchy.org/) mai întâi, pune-l pe un stick USB (folosește [Rufus](https://rufus.ie/) pe Windows, [balenaEtcher](https://etcher.balena.io/) pe Mac sau [caligula](https://github.com/ifd3f/caligula) pe Linux) și pornește de pe stick.

_Trebuie să dezactivezi Secure Boot și/sau TPM în BIOS. Trebuie să le dezactivezi ca să poți instala Omarchy. Sunt scheme de securitate Microsoft gândite pentru Windows și pentru distribuțiile Linux afiliate Microsoft._

Apoi răspunde la întrebările de configurare și confirmă-le astfel:

 ![install-config](images/install-config.webp)

Apoi selectează un disc pentru instalare și stai relaxat și urmărește spectacolul instalării. Se poate termina în mai puțin de un minut pe cele mai rapide mașini moderne, dar nu ar trebui să dureze mai mult de 5 minute nici pe un computer mai vechi.

 ![install-done](images/install-done.webp)

Acum ești gata de Omarchy!

### Folosește o tastatură cu fir sau de 2.4ghz!

Criptarea întregului disc nu-ți va permite să introduci parola de la o tastatură Bluetooth la pornire. La fel cum nu poți folosi o tastatură Bluetooth ca să intri în BIOS pe un PC. Vei avea nevoie de o tastatură care folosește fie un dongle de 2.4ghz, fie un cablu (ceea ce e oricum mult mai bine pentru latență!). Mie personal îmi place la nebunie [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalarea pentru alt proprietar

Dacă pregătești o mașină pentru altcineva — un membru al familiei, un angajat nou, un cumpărător — nu ar trebui să răspunzi în locul lui la întrebările personale. Apasă `Ctrl + C` pe cel mai primul ecran al programului de instalare (cel pentru selectarea tastaturii), iar Omarchy îți va oferi să pregătească mașina pentru alt proprietar. Sistemul se instalează imediat, dar toată configurarea personală — dispunerea tastaturii, numele de utilizator, parola — este amânată până când mașina pornește pentru prima dată. Discul rămâne criptat implicit, iar parola pe care noul proprietar o alege la acea primă pornire devine și parola de criptare. (O mașină pe care ai folosit-o deja poate fi predată și fără reinstalare — vezi [resetarea computerului](48-security.md).)

### Instalări nesupravegheate

ISO-ul se poate instala și complet singur — fără tastatură, fără asistent — atunci când primește configurația de pe un al doilea disc. Așa tratezi Omarchy ca imagine de bază pentru VM-uri și mașini dintr-un parc informatic. Vezi [instalările nesupravegheate](51-unattended-installs.md).

### Instalări fără criptare

Omarchy se instalează implicit cu criptare. Este alegerea sigură și responsabilă pentru orice computer care ar putea fi pierdut sau furat. Nu vrei ca oricine are acces la hardware-ul tău să-ți poată accesa datele!

Dar în circumstanțe speciale, cum ar fi instalările Omarchy la distanță pe computere protejate sau instalațiile de unică folosință fără date sensibile, s-ar putea să vrei să instalezi fără criptare. Poți apăsa `Ctrl + C` la confirmarea formatării discului pentru a trece la o instalare fără criptare.

### Limbă

Omarchy vorbește 50 de limbi — același set ca omarchy.org — iar engleza este limba implicită. Pentru a o schimba, deschide meniul Omarchy și mergi la _Configurare > Limbă_ sau rulează `omarchy language <code>` într-un terminal (`omarchy language list` îți arată codurile). Meniul, desktopul și notificările proprii ale Omarchy își schimbă limba imediat, iar fiecare aplicație pe care o deschizi după aceea face la fel. Aplicațiile care erau deja deschise se schimbă după ce le repornești.

### Ajutor dacă te blochezi

Dacă te blochezi, poți găsi de obicei pe cineva dispus să te ajute pe canalul _#omarchy-help_ de pe [Discordul comunității](https://omarchy.org/discord).
