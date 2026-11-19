# Primii pași

Omarchy se instalează folosind o imagine ISO. Poți alege între o instalare pe întregul disc, care preia întreaga unitate, sau o instalare în spațiul liber, care pune Omarchy în spațiul nealocat de pe o unitate — așa faci dual boot alături de Windows sau de alt sistem de operare (vezi [instalare dual boot](50-dual-boot-install.md) — reține că mai întâi va trebui să dezactivezi BitLocker în Windows). În ambele cazuri, instalarea folosește implicit criptarea completă, iar opțiunea pentru întregul disc va șterge unitatea selectată, așa că asigură-te că faci o copie de rezervă înainte să folosești una existentă!

Mai întâi [descarcă imaginea ISO Omarchy](https://omarchy.org/), pune-o pe un stick USB (folosește [Rufus](https://rufus.ie/) pe Windows, [balenaEtcher](https://etcher.balena.io/) pe Mac sau [caligula](https://github.com/ifd3f/caligula) pe Linux) și pornește de pe stick.

_Trebuie să dezactivezi Secure Boot și/sau TPM în BIOS. Trebuie să le dezactivezi ca să poți instala Omarchy. Sunt scheme de securitate Microsoft gândite pentru Windows și pentru distribuțiile Linux afiliate Microsoft._

Apoi răspunde la întrebările de configurare și confirmă-le astfel:

 ![install-config](images/install-config.webp)

Apoi selectează o unitate pentru instalare, relaxează-te și urmărește spectacolul instalării. Se poate termina în mai puțin de un minut pe cele mai rapide mașini moderne, dar nu ar trebui să dureze mai mult de 5 minute nici măcar pe un computer mai vechi.

 ![install-done](images/install-done.webp)

Acum ești gata de Omarchy!

### Folosește o tastatură cu fir sau de 2.4ghz!

Criptarea completă a discului nu îți va permite să introduci parola de la o tastatură Bluetooth la pornire. La fel cum nu poți folosi o tastatură Bluetooth ca să intri în BIOS pe un PC. Vei avea nevoie de o tastatură care fie folosește un dongle de 2.4ghz, fie un cablu (care oricum e mult mai bun pentru latență!). Personal, ador [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalarea pentru alt proprietar

Dacă pregătești o mașină pentru altcineva — un membru al familiei, un angajat nou, un cumpărător — nu ar trebui să răspunzi la întrebările personale în numele acelei persoane. Apasă `Ctrl + C` chiar pe primul ecran al programului de instalare (selectarea tastaturii), iar Omarchy îți va oferi să pregătești mașina pentru alt proprietar. Sistemul se instalează imediat, dar toată configurarea personală — dispunerea tastaturii, numele de utilizator, parola — este amânată până când mașina pornește pentru prima dată. Unitatea este în continuare criptată implicit, iar parola pe care noul proprietar o alege la acea primă pornire devine și parola de criptare. (O mașină pe care ai folosit-o deja poate fi predată și fără reinstalare — vezi [resetarea computerului](48-security.md).)

### Instalarări nesupravegheate

Imaginea ISO se poate instala și complet singură — fără tastatură, fără asistent — atunci când primește configurația pe o a doua unitate. Așa tratezi Omarchy ca imagine de bază pentru VM-uri și mașini dintr-un parc întreg. Vezi [instalarări nesupravegheate](51-unattended-installs.md).

### Instalarări fără criptare

Omarchy se instalează implicit cu criptare. Este alegerea sigură și responsabilă pentru orice computer care ar putea fi pierdut sau furat. Nu vrei ca oricine are acces la hardware-ul tău să poată ajunge la datele tale!

Dar în circumstanțe speciale, cum ar fi instalarările Omarchy la distanță pe computere protejate sau instalarările de unică folosință fără date sensibile, s-ar putea să vrei să instalezi fără criptare. Poți apăsa `Ctrl + C` la confirmarea formatării discului ca să treci la o instalare fără criptare.

### Limbă

Omarchy vorbește 50 de limbi — același set ca omarchy.org — iar limba implicită este engleza. Ca să o schimbi, deschide meniul Omarchy și mergi la _Configurare > Regiune > Limbă_ sau rulează `omarchy language <code>` într-un terminal (`omarchy language list` afișează codurile). Meniul, desktopul și notificările proprii ale Omarchy își schimbă limba imediat, iar fiecare aplicație pe care o deschizi după aceea face la fel. Aplicațiile care erau deja deschise se schimbă după ce le repornești.

Ca să păstrezi limba, dar să scrii datele, orele, numerele, banii, unitățile de măsură și dimensiunile hârtiei așa cum se face în altă regiune (de exemplu, engleză cu date europene și ceas în format de 24 de ore), alege o regiune la _Configurare > Regiune > Formate_, unde fiecare alegere afișează un exemplu, sau rulează `omarchy region <code>` (`omarchy region list` afișează codurile). _La fel ca limba_ revine la formatele proprii ale limbii. La fel ca schimbarea limbii, ajunge la aplicațiile pe care le deschizi după aceea.

### Ajutor dacă te blochezi

Dacă te blochezi, de obicei poți găsi pe cineva dispus să te ajute în canalul _#omarchy-help_ de pe [Discordul comunității](https://omarchy.org/discord).
