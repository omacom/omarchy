# Autentificare hardware

### Autentificare cu amprentă

Multe laptopuri vin cu un senzor de amprentă pentru autentificare. Îl poți folosi cu Omarchy rulând _Setup > Security > Fingerprint_ în meniul Omarchy (`Super + Space`).

Se deschide o amprentă pe tot ecranul, care se umple pe măsură ce atingi senzorul. În spate, Omarchy va instala pachetul pentru amprentă, îți va înregistra amprenta, o va verifica și vei fi gata să îți folosești amprenta pentru a debloca din ecranul de blocare (pe care îl poți declanșa cu `Super + Ctrl + L`), pentru a intra în modul sudo și pentru a autoriza solicitările de sistem.

După ce ecranul de blocare a stins afișajul, senzorul intră în repaus pentru a economisi energie, așa că trezește ecranul cu orice tastă sau cu touchpadul înainte să îl atingi.

Când capacul laptopului este închis, solicitarea amprentei este sărită automat, așa că ajungi direct la solicitarea parolei în loc să aștepți un senzor la care nu poți ajunge. Dacă altfel trebuie să lucrezi pe o tastatură externă care nu are senzor, apasă pur și simplu `CTRL + C` când ți se cere amprenta în timpul `sudo`.

Poți elimina autentificarea cu amprentă din _Remove > Security > Fingerprint_ în meniul Omarchy.

### Autentificare Fido2

Dacă folosești un dispozitiv Fido2, îl poți configura pentru autentificarea `sudo` folosind _Setup > Security > Fido2_ în meniul Omarchy (`Super + Space`). Totuși, acoperă solicitările `sudo` și autorizările de sistem, nu deblocarea computerului.

Poți elimina autentificarea fido2 din _Remove > Security > Fido2_ în meniul Omarchy.
