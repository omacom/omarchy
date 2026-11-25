# Autentificare hardware

### Autentificare prin amprentă

Multe laptopuri vin cu un senzor de amprentă pentru autentificare. Îl poți folosi cu Omarchy rulând _Setup > Security > Fingerprint_ în meniul Omarchy (`Super + Space`).

Asta va instala pachetul pentru amprentă, îți va înregistra amprenta, o va verifica și vei fi gata să îți folosești amprenta pentru deblocarea de pe ecranul de blocare (pe care îl poți declanșa cu `Super + Ctrl + L`), pentru a intra în modul sudo și pentru a autoriza solicitările sistemului.

După ce ecranul de blocare a oprit afișajul, senzorul intră în repaus pentru a economisi energie, așa că trezește ecranul cu orice tastă sau cu touchpadul înainte să-l atingi.

Când capacul laptopului este închis, solicitarea amprentei este sărită automat, așa că ajungi direct la solicitarea parolei în loc să aștepți după un senzor la care nu poți ajunge. Dacă altfel trebuie să lucrezi pe o tastatură externă care nu are senzor, apasă pur și simplu `CTRL + C` atunci când ți se cere amprenta în timpul `sudo`.

Poți elimina autentificarea prin amprentă sub _Remove > Security > Fingerprint_ în meniul Omarchy.

### Autentificare Fido2

Dacă folosești un dispozitiv Fido2, îl poți configura pentru autentificarea `sudo` folosind _Setup > Security > Fido2_ în meniul Omarchy (`Super + Space`). Acoperă totuși `sudo` și solicitările de autorizare ale sistemului, nu deblocarea computerului tău.

Poți elimina autentificarea fido2 sub _Remove > Security > Fido2_ în meniul Omarchy.
