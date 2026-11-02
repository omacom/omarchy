# Instalare în dual boot

Poți instala Omarchy pe o singură partiție alături de Windows sau de alte instalări.

Această metodă de instalare vine în continuare cu criptare LUKS pentru partiție în mod implicit, așa că practic nu diferă cu nimic de instalarea pe întregul disc și necesită pur și simplu spațiu liber disponibil pe disc.

## Eliberarea spațiului pe Windows

Pentru a instala alături de Windows, tastează `disk management` în meniul Start și selectează opțiunea **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Găsește partiția corespunzătoare, fă clic dreapta și alege **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introdu cantitatea cu care vrei să micșorezi volumul. Reține că aceasta va fi dimensiunea viitoarei tale instalări Omarchy, inclusiv partiția de pornire.

 ![dual-boot-3](images/dual-boot-3.webp)

Când ai terminat, ar trebui să vezi ceva de genul acesta, unde secțiunea de 50GB este locul în care vom instala Omarchy în acest exemplu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalarea Omarchy

Procesul de instalare pentru Omarchy este practic același ca în mod normal. După ce îți selectezi discul, ți se va oferi opțiunea **Free space install**. Selectează acea opțiune pentru a împiedica ștergerea întregului disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirmă că totul arată bine și așteaptă să se termine instalarea ca în mod normal. Tot aici poți alege să instalezi fără criptare (nerecomandat), la fel ca la o instalare pe întregul disc.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adăugarea altor instalări la bootloader

Când îți termini instalarea Omarchy, vei observa că bootloaderul Limine este acum cel implicit. Cu acesta, poți adăuga și opțiuni la Limine pentru celelalte instalări ale tale, cum ar fi Windows.

Pentru a adăuga alte sisteme de operare, rulează `limine-scan` și urmează instrucțiunile pentru a adăuga intrările dorite în configurația ta Limine. Meniul de pornire rămâne ascuns în mod implicit și pornește Omarchy după o secundă. Pentru a alege Windows sau altă intrare, apasă orice tastă imediat ce pornește Limine; când apare meniul, folosește tastele săgeată pentru a selecta o intrare și apasă Enter. Dacă Omarchy pornește înainte să apuci să apeși o tastă, repornește și încearcă din nou. Dacă ai activat _Setup > Direct Boot_, firmware-ul sare complet peste Limine, așa că alege Limine din meniul de pornire BIOS sau rulează din nou _Setup > Direct Boot_ pentru a elimina intrarea.

## Bitlocker

Este important de reținut că această metodă de instalare nu este compatibilă cu Bitlocker, deoarece acesta criptează întregul disc, nu doar partiția. Dacă întâlnești o eroare care spune că Bitlocker este activat, pornește în Windows, mergi la **Settings -> Privacy & Security -> Device encryption** și dezactivează Bitlocker. Decriptarea discului poate dura ceva timp.

 ![dual-boot-7](images/dual-boot-7.webp)
