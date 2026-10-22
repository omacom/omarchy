# Instalare cu pornire duală

Poți instala Omarchy pe o singură partiție alături de Windows sau de alte instalări.

Această metodă de instalare vine în continuare cu criptare LUKS pentru partiție implicit, așa că, în mod efectiv, nu este diferită de unitatea completă și necesită pur și simplu spațiu liber disponibil pe disc.

## Crearea spațiului pe Windows

Ca să instalezi alături de Windows, tastează `disk management` în meniul Start și selectează opțiunea **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Găsește partiția potrivită, fă clic dreapta și alege **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introdu cantitatea cu care ai vrea să micșorezi volumul. Reține că aceasta va fi dimensiunea viitoarei tale instalări Omarchy, incluzând partiția de pornire.

 ![dual-boot-3](images/dual-boot-3.webp)

Când ai terminat, ar trebui să vezi ceva de genul acesta, unde secțiunea de 50GB este locul în care vom instala Omarchy în acest exemplu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalarea Omarchy

Procesul de instalare pentru Omarchy este, în mod efectiv, același ca de obicei. După ce îți selectezi discul, ți se va oferi opțiunea **Free space install**. Selectează acea opțiune ca să împiedici ștergerea întregului disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirmă că totul arată bine și așteaptă ca instalarea să se termine ca de obicei. Aici ai putea alege și să instalezi necriptat (nerecomandat), la fel ca la o instalare pe unitate completă.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adăugarea altor instalări în încărcătorul de pornire

Când termini instalarea Omarchy, vei observa că încărcătorul de pornire Limine este acum implicitul. Cu acesta, poți adăuga și opțiuni la Limine pentru celelalte instalări ale tale, precum Windows.

Ca să faci asta, rulează `limine-scan` și urmează solicitările ca să adaugi la configurația ta limine elementele pe care le vrei. Apoi, când pornești, vei vedea opțiunile tale normale pentru Omarchy, precum și Windows Boot Manager sau altele.

## Bitlocker

Este important de reținut că această metodă de instalare nu este compatibilă cu Bitlocker, deoarece criptează întreaga unitate, nu doar partiția. Dacă întâmpini o eroare care afirmă că Bitlocker este activat, pornește în Windows, mergi la **Settings -> Privacy & Security -> Device encryption** și dezactivează Bitlocker. Decriptarea unității poate dura ceva timp.

 ![dual-boot-7](images/dual-boot-7.webp)
