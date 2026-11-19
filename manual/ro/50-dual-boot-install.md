# Instalare Dual Boot

Poți instala Omarchy pe o singură partiție alături de Windows sau alte instalări.

Această metodă de instalare vine în continuare cu criptare LUKS pentru partiție în mod implicit, așa că, practic, nu este cu nimic diferită de instalarea pe întregul disc și necesită pur și simplu spațiu liber disponibil pe disc.

## Eliberarea spațiului pe Windows

Pentru a instala alături de Windows, tastează `disk management` în meniul de pornire și selectează opțiunea **Creare și formatare partiții hard disk**.

 ![dual-boot-1](images/dual-boot-1.webp)

Găsește partiția corespunzătoare, dă clic dreapta pe ea și alege **Micșorare volum**.

![dual-boot-2](images/dual-boot-2.webp)

 Introdu cantitatea cu care vrei să micșorezi volumul. Reține că aceasta va fi dimensiunea viitoarei tale instalări Omarchy, inclusiv partiția de boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Când ai terminat, ar trebui să vezi ceva de genul acesta, unde secțiunea de 50GB este locul în care vom instala Omarchy în acest exemplu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalarea Omarchy

Procesul de instalare pentru Omarchy este, practic, la fel ca cel normal. După ce îți selectezi discul, ți se va oferi opțiunea **Instalare pe spațiul liber**. Selectează acea opțiune pentru a împiedica ștergerea întregului disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirmă că totul arată bine și așteaptă să se termine instalarea ca de obicei. Tot aici poți alege să instalezi necriptat (nerecomandat), la fel ca la o instalare pe întregul disc.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adăugarea altor instalări în bootloader

Când termini instalarea Omarchy, vei observa că bootloaderul Limine este acum cel implicit. Cu acesta, poți adăuga și opțiuni în Limine pentru celelalte instalări ale tale, cum ar fi Windows.

Pentru a adăuga alte sisteme de operare, rulează `limine-scan` și urmează instrucțiunile pentru a adăuga intrările dorite în configurația Limine. Meniul de boot rămâne ascuns în mod implicit și pornește Omarchy după o secundă. Pentru a alege Windows sau altă intrare, apasă orice tastă imediat ce pornește Limine; când apare meniul, folosește tastele săgeți pentru a selecta o intrare și apasă Enter. Dacă Omarchy pornește înainte să apesi o tastă, repornește și încearcă din nou.

## Bitlocker

Este important de reținut că această metodă de instalare nu este compatibilă cu Bitlocker, deoarece acesta criptează întregul disc, nu doar partiția. Dacă întâlnești o eroare care spune că Bitlocker este activat, pornește în Windows, mergi la **Setări -> Confidențialitate și securitate -> Criptarea dispozitivului** și dezactivează Bitlocker. Decriptarea discului poate dura ceva timp.

 ![dual-boot-7](images/dual-boot-7.webp)
