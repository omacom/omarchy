# Primii pași

Omarchy se instalează folosind un ISO. Poți alege între o instalare pe întregul disc, care preia întreaga unitate, sau o instalare în spațiul liber, care pune Omarchy în spațiul nealocat de pe o unitate — așa faci dual boot alături de Windows sau de alt sistem de operare (vezi [instalare dual-boot](50-dual-boot-install.md) — reține că mai întâi va trebui să dezactivezi BitLocker în Windows). Oricum ar fi, instalarea folosește implicit criptarea completă, iar opțiunea pe întregul disc va șterge unitatea selectată, așa că asigură-te că faci un backup înainte să folosești una existentă!

Mai întâi [Descarcă ISO-ul Omarchy](https://omarchy.org/), pune-l pe un stick USB (folosește [Rufus](https://rufus.ie/) pe Windows, [balenaEtcher](https://etcher.balena.io/) pe Mac sau [caligula](https://github.com/ifd3f/caligula) pe Linux) și pornește de pe stick.

_Trebuie să dezactivezi Secure Boot și/sau TPM în BIOS. Trebuie să le dezactivezi ca să poți instala Omarchy. Sunt scheme de securitate Microsoft gândite pentru Windows și pentru distribuțiile Linux afiliate Microsoft._

Apoi răspunde la întrebările de configurare și confirmă-le astfel:

 ![install-config](images/install-config.webp)

Apoi selectează o unitate pentru instalare și relaxează-te și urmărește spectacolul instalării. Se poate termina în mai puțin de un minut pe cele mai rapide mașini moderne, dar nu ar trebui să dureze mai mult de 5 minute nici măcar pe un computer mai vechi.

 ![install-done](images/install-done.webp)

Acum ești gata de Omarchy!

### Folosește o tastatură cu fir sau de 2.4ghz!

Criptarea completă a discului nu îți va permite să introduci parola de la o tastatură Bluetooth la pornire. La fel cum nu poți folosi o tastatură Bluetooth ca să intri în BIOS pe un PC. Vei avea nevoie de o tastatură care folosește fie un dongle de 2.4ghz, fie un cablu (ceea ce e oricum mult mai bine pentru latență!). Personal, ador [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalare pentru alt proprietar

Dacă pregătești o mașină pentru altcineva — un membru al familiei, un angajat nou, un cumpărător — nu ar trebui să răspunzi la întrebările personale în numele lor. Apasă `Ctrl + C` pe chiar primul ecran al programului de instalare (selectarea tastaturii), iar Omarchy îți va propune să pregătești mașina pentru alt proprietar. Sistemul se instalează imediat, dar toată configurarea personală — aspectul tastaturii, numele de utilizator, parola — este amânată până când mașina pornește pentru prima dată. Unitatea este în continuare criptată implicit, iar parola pe care noul proprietar o alege la acea primă pornire devine și parola de criptare. (O mașină pe care ai folosit-o deja poate fi predată și fără reinstalare — vezi [resetarea computerului](48-security.md).)

### Instalări nesupravegheate

ISO-ul se poate instala și complet singur — fără tastatură, fără asistent — atunci când i se furnizează configurația pe o a doua unitate. Așa tratezi Omarchy ca imagine de bază pentru VM-uri și mașini dintr-un parc. Vezi [instalări nesupravegheate](51-unattended-installs.md).

### Instalări fără criptare

Omarchy se instalează implicit cu criptare. Este alegerea sigură și responsabilă pentru orice computer care poate fi pierdut sau furat. Nu vrei ca oricine are acces la hardware-ul tău să-ți poată accesa datele!

Dar în circumstanțe speciale, cum ar fi instalările Omarchy la distanță pe computere protejate sau instalările de unică folosință fără date sensibile, s-ar putea să vrei să instalezi fără criptare. Poți apăsa `Ctrl + C` la confirmarea formatării discului pentru a trece la o instalare fără criptare.

### Limbă

Omarchy vorbește 50 de limbi — același set ca pe omarchy.org — iar limba implicită este engleza. Pentru a schimba, deschide meniul Omarchy și mergi la _Configurare > Regiune > Limbă_ sau rulează `omarchy language <code>` într-un terminal (`omarchy language list` arată codurile). Meniul, desktopul și notificările proprii ale Omarchy își schimbă limba imediat, iar fiecare aplicație pe care o deschizi după aceea face la fel. Aplicațiile care erau deja deschise se schimbă după ce le repornești.

Pentru a păstra limba, dar a scrie datele, orele, numerele, banii, unitățile și dimensiunile hârtiei așa cum o face altă regiune (engleză cu date europene și ceas de 24 de ore, de exemplu), alege o regiune la _Configurare > Regiune > Formate_, unde fiecare alegere arată un exemplu, sau rulează `omarchy region formats <code>` (`omarchy region formats list` arată codurile). _La fel ca limba_ revine la formatele proprii ale limbii. La fel ca schimbarea limbii, ajunge la aplicațiile pe care le deschizi după aceea.

### Ajutor dacă te blochezi

Dacă te blochezi, de obicei poți găsi pe cineva dispus să te ajute în canalul _#omarchy-help_ de pe [Discordul comunității](https://omarchy.org/discord).
