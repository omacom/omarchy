# Suport pentru Mac

Omarchy are suport integrat pentru **Mac-uri Intel**. Există câteva limitări cunoscute în acest moment, dar cât timp le cunoști și ești de acord cu ele, poți da o nouă viață vechilor tale Mac-uri instalând Omarchy.

Reține că instalarea pe un Mac cu cip din seria M nu este acceptată direct în acest moment. Poți afla mai multe despre situația actuală în #omarchy-on-other de pe [Discord](https://discord.gg/tXFUdasqhY)-ul nostru.

Într-un test simplu, am reușit să obținem câștiguri de performanță de 36% pe un MacBook Pro din 2019 doar instalând Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalarea Omarchy pe Mac

Omarchy acceptă în prezent doar instalarea ca **singurul** sistem de operare instalat. În timpul instalării, unitatea va fi ștearsă, iar MacOS nu va mai putea fi pornit.

Poți totuși să îl restaurezi ulterior prin Internet Recovery, dacă vrei.

Pentru această parte, vom presupune că ai parcurs deja [Primii pași](02-getting-started.md) și că ai unitatea USB pregătită. Dacă nu, fă asta acum.

#### Dezactivarea Secure Boot

Este necesar să dezactivezi Secure Boot de la Apple pentru a porni de pe USB-ul bootabil, precum și pentru sistemul de operare. Pentru a-l dezactiva, fă următoarele:

1. Oprește Mac-ul
2. Pornește-l și apasă _imediat_ și ține apăsat Command-R până când vezi ecranul de încărcare
3. Selectează utilizatorul tău și introdu parola dacă ți se cere
4. Odată ajuns pe ecranul de recuperare, alege **Utilities > Startup Security Utility** din bara de meniu
5. Introdu parola când ți se cere să te autentifici
6. Alege "No Security" din opțiunile Secure Boot
7. Alege "Allow booting from external or removable media" din opțiunile External Boot

#### Pornirea instalării

1. Introdu unitatea USB
2. Repornește Mac-ul și apasă _imediat_ și ține apăsat Option până când vezi un ecran cu dispozitive de pornire
3. Selectează dispozitivul portocaliu EFI Boot
4. Continuă cu [instalarea ca de obicei](02-getting-started.md)

Programul de instalare detectează hardware-ul Mac și aplică automat corecțiile necesare: driverele și firmware-ul Broadcom Wi-Fi, driverul de tastatură SPI pe modelele MacBook care au nevoie de el și o corecție pentru suspendarea NVMe pentru aceleași modele.

### Limitări cunoscute

Membrii comunității lucrează constant la soluții pentru aceste provocări, așa că, dacă acestea sunt o problemă pentru tine, alătură-te canalului #omarchy-on-other de pe [Discord](https://discord.gg/tXFUdasqhY)-ul nostru și vezi dacă există metode actualizate pentru rezolvarea lor.

#### Dispozitive cu cip T1

Cipul Apple T1 a fost introdus la sfârșitul anului 2016 și a fost folosit exclusiv în modelele MacBook Pro de prima generație cu Touch Bar.
- MacBook Pro 13-inch (2016, două porturi Thunderbolt 3) – Model: A1706
- MacBook Pro 13-inch (2016, patru porturi Thunderbolt 3) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Probleme cunoscute

- Touch Bar nu funcționează
- Sunetul nu funcționează

#### Dispozitive cu cip T2

Cipul de securitate Apple T2 a fost introdus în 2017. Cipul T2 a fost scos din producție odată cu tranziția la Apple silicon (cipuri din seria M), începând din 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, patru porturi Thunderbolt 3) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, două porturi Thunderbolt 3) – Model: A2159
- MacBook Pro 13-inch (2019, patru porturi Thunderbolt 3) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 și iMac20,2)
- MacBook Pro 13-inch (2020, două porturi Thunderbolt 3) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Pe aceste modele, programul de instalare configurează automat kernelul `linux-t2` cu patch-uri, configurația audio T2, firmware-ul Broadcom Wi-Fi/Bluetooth de la Apple și controlul ventilatoarelor prin `t2fanrd`. Touch Bar funcționează pe baza suportului integrat în kernel, de tip Boot Camp.

#### iMac Retina 5K (2017)

Modelul iMac de 27 de inchi din 2017 nu are cip T2, așa că programul de instalare îl configurează la fel ca pe celelalte Mac-uri Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Probleme cunoscute

- Ecranul nu funcționează la rezoluția sa nativă de 5120×2880: panoul este format din două plăci, iar driverul standard o iluminează doar pe una
- Sunetul nu funcționează
- Controlul luminozității nu are niciun efect
- Repausul blochează dispozitivul; doar oprirea și repornirea îl readuce la normal

Un patcher creat de comunitate pentru acest model repară ecranul, sunetul și luminozitatea: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
