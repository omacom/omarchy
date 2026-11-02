# Suport pentru Mac

Omarchy are suport integrat pentru **Mac-uri Intel**. Există câteva limitări cunoscute în acest moment, dar atâta timp cât ești conștient de ele și ești de acord cu ele, poți insufla o viață nouă vechilor tale Mac-uri încărcând Omarchy.

Te rugăm să reții că instalarea pe un Mac cu serie M nu este acceptată direct în acest moment. Poți afla mai multe despre starea acestui lucru în #omarchy-on-other în [Discordul](https://discord.gg/tXFUdasqhY) nostru.

Într-un test simplu, am reușit să obținem câștiguri de performanță de 36% pe un MacBook Pro din 2019 doar instalând Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalarea Omarchy pe Mac

Omarchy acceptă în acest moment doar să fie **singurul** sistem de operare instalat. În timpul instalării, unitatea va fi ștearsă, iar MacOS nu va mai putea fi pornit.

Îl poți totuși restabili ulterior prin Internet Recovery dacă ai vrea.

Pentru această parte, vom presupune că ai parcurs deja [Noțiuni introductive](02-getting-started.md) și ai unitatea USB pregătită. Dacă nu, dă-i drumul și fă asta acum.

#### Dezactivarea Secure Boot

Este necesar să dezactivezi Secure Boot al Apple ca să pornești USB-ul bootabil, precum și sistemul de operare. Ca să îl dezactivezi, efectuează următoarele:

1. Oprește Mac-ul
2. Pornește-l și apasă _imediat_ și ține apăsat Command-R până când vezi ecranul de încărcare apărând
3. Selectează-ți utilizatorul și introdu parola dacă ți se cere
4. Odată ajuns în ecranul de recuperare, alege **Utilities > Startup Security Utility** din bara de meniu
5. Introdu parola când ți se cere să te autentifici
6. Alege „No Security” dintre opțiunile Secure Boot
7. Alege „Allow booting from external or removable media” dintre opțiunile External Boot

#### Pornirea instalării

1. Introdu unitatea USB
2. Repornește Mac-ul și apasă _imediat_ și ține apăsat Option până când vezi un ecran cu dispozitive de pornire
3. Selectează dispozitivul portocaliu EFI Boot
4. Continuă cu [instalarea ca de obicei](02-getting-started.md)

Programul de instalare detectează hardware-ul Mac și aplică automat corecțiile necesare: driverele și firmware-ul Wi-Fi Broadcom, driverul de tastatură SPI pe modelele MacBook care au nevoie de el și o corecție pentru suspendarea NVMe pentru aceleași modele.

### Limitări cunoscute

Membrii comunității lucrează constant la soluții pentru aceste provocări, așa că, dacă acestea sunt problematice pentru tine, alătură-te #omarchy-on-other în [Discordul](https://discord.gg/tXFUdasqhY) nostru și vezi dacă există metode actualizate pentru rezolvarea acestora.

#### Dispozitive cu cip T1

Cipul Apple T1 a fost introdus la sfârșitul anului 2016 și folosit exclusiv în modelele MacBook Pro de primă generație cu Touch Bar.
- MacBook Pro 13-inch (2016, două porturi Thunderbolt 3) – Model: A1706
- MacBook Pro 13-inch (2016, patru porturi Thunderbolt 3) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Probleme cunoscute

- Touch Bar este nefuncțional
- Sunetul nu funcționează

#### Dispozitive cu cip T2

Cipul de securitate Apple T2 a fost introdus în 2017. Cipul T2 a fost întrerupt odată cu tranziția la Apple silicon (cipurile din seria M) începând din 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, patru porturi Thunderbolt 3) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, două porturi Thunderbolt 3) – Model: A2159
- MacBook Pro 13-inch (2019, patru porturi Thunderbolt 3) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, două porturi Thunderbolt 3) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Pe aceste modele, programul de instalare configurează automat kernelul `linux-t2` corectat, configurația audio T2, firmware-ul Wi-Fi/Bluetooth Broadcom al Apple și controlul ventilatoarelor prin `t2fanrd`. Touch Bar rulează pe suportul integrat în stil Boot Camp al kernelului.
