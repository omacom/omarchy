# Instalare în Dual Boot

Puteți instala Omarchy pe o singură partiție, alături de Windows sau de alte instalări.

Această metodă de instalare vine în continuare cu criptare LUKS pentru partiție în mod implicit, așa că, efectiv, nu este cu nimic diferită de instalarea pe întreg discul și necesită pur și simplu spațiu liber disponibil pe disc.

## Eliberarea spațiului pe Windows

Pentru a instala alături de Windows, tastați `disk management` în meniul Start și selectați opțiunea **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Găsiți partiția corespunzătoare, faceți clic dreapta și alegeți **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introduceți dimensiunea cu care doriți să micșorați volumul. Rețineți că aceasta va fi dimensiunea viitoarei instalări Omarchy, inclusiv partiția de boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Când ați terminat, ar trebui să vedeți ceva de genul acesta, unde secțiunea de 50GB este cea în care vom instala Omarchy în acest exemplu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalarea Omarchy

Procesul de instalare pentru Omarchy este, efectiv, același ca în mod normal. După ce selectați discul, vi se va oferi opțiunea **Free space install**. Selectați acea opțiune pentru a împiedica ștergerea întregului disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirmați că totul arată bine și așteptați finalizarea instalării ca în mod normal. Tot aici puteți alege să instalați fără criptare (nerecomandat), la fel ca la o instalare pe întreg discul.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adăugarea altor instalări în bootloader

Când terminați instalarea Omarchy, veți observa că bootloaderul Limine este acum cel implicit. Cu acesta, puteți adăuga și opțiuni în Limine pentru celelalte instalări ale dumneavoastră, cum ar fi Windows.

Pentru a adăuga alte sisteme de operare, rulați `limine-scan` și urmați instrucțiunile pentru a adăuga intrările dorite în configurația Limine. Meniul de boot rămâne ascuns în mod implicit și pornește Omarchy după o secundă. Pentru a alege Windows sau altă intrare, apăsați orice tastă imediat ce pornește Limine; când apare meniul, folosiți tastele săgeată pentru a selecta o intrare și apăsați Enter. Dacă Omarchy pornește înainte să apăsați o tastă, reporniți și încercați din nou.

## Bitlocker

Este important de reținut că această metodă de instalare nu este compatibilă cu Bitlocker, deoarece acesta criptează întregul disc, nu doar partiția. Dacă întâlniți o eroare care indică faptul că Bitlocker este activat, porniți în Windows, accesați **Settings -> Privacy & Security -> Device encryption** și dezactivați Bitlocker. Decriptarea discului poate dura ceva timp.

 ![dual-boot-7](images/dual-boot-7.webp)

## Reinstalarea Windows

Dacă acest computer a fost livrat cu Windows, cheia sa de produs este stocată în firmware. Rulați `omarchy windows key` pentru a o afișa, astfel încât să puteți activa Windows din nou dacă îl reinstalați vreodată pe această mașină.
