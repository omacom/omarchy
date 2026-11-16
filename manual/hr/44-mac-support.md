# Podrška za Mac

Omarchy ima ugrađenu podršku za **Intel Macove**. Trenutačno postoji nekoliko poznatih ograničenja, ali sve dok ste ih svjesni i slažete se s njima; možete udahnuti novi život svojim starim Macovima instaliranjem Omarchyja.

Imajte na umu da instalacija na Mac s M-serijom trenutačno nije izravno podržana. Više o stanju toga možete saznati u #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY).

U jednostavnom testu uspjeli smo postići 36% poboljšanja performansi na MacBooku Pro iz 2019. samo instaliranjem Omarchyja.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalacija Omarchyja na Mac

Omarchy trenutačno podržava samo da bude **jedini** instalirani OS. Tijekom instalacije pogon će biti obrisan i MacOS se više neće moći pokrenuti.

Kasnije ga i dalje možete vratiti putem Internet Recoveryja ako to želite.

Za potrebe ovog dijela pretpostavit ćemo da ste već pregledali [Početak rada](02-getting-started.md) i da vam je USB pogon spreman. Ako nije, učinite to sada.

#### Onemogućavanje Secure Boota

Potrebno je onemogućiti Appleov Secure Boot kako biste mogli pokrenuti USB za pokretanje, kao i OS. Da biste ga onemogućili, učinite sljedeće:

1. Isključite Mac
2. Uključite ga i _odmah_ pritisnite i držite Command-R dok se ne pojavi zaslon učitavanja
3. Odaberite svog korisnika i unesite lozinku ako se to od vas zatraži
4. Kad se nađete na zaslonu za oporavak, na traci izbornika odaberite **Utilities > Startup Security Utility**
5. Unesite lozinku kad se od vas zatraži autentifikacija
6. Odaberite "No Security" među opcijama za Secure Boot
7. Odaberite "Allow booting from external or removable media" među opcijama za External Boot

#### Pokretanje instalacije

1. Umetnite USB pogon
2. Ponovno pokrenite Mac i _odmah_ pritisnite i držite Option dok ne vidite zaslon s uređajima za pokretanje
3. Odaberite narančasti uređaj EFI Boot
4. Nastavite s [instalacijom kao i obično](02-getting-started.md)

Instalacijski program prepoznaje Mac hardver i automatski primjenjuje potrebne ispravke: upravljačke programe i firmver za Broadcom Wi-Fi, upravljački program za SPI tipkovnicu na modelima MacBooka kojima je potreban te ispravak za NVMe mirovanje za iste te modele.

### Poznata ograničenja

Članovi zajednice neprestano rade na rješenjima za ove izazove, pa ako vam oni predstavljaju problem, pridružite se #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) i provjerite postoje li ažurirane metode za njihovo rješavanje.

#### Uređaji s čipom T1

Appleov čip T1 predstavljen je krajem 2016. i korišten je isključivo u modelima MacBooka Pro prve generacije s Touch Barom.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Poznati problemi

- Touch Bar ne radi
- Zvuk ne radi

#### Uređaji s čipom T2

Appleov sigurnosni čip T2 predstavljen je 2017. Čip T2 ukinut je prelaskom na Apple silicon (čipove M-serije) počevši od 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Na ovim modelima instalacijski program automatski postavlja zakrpani kernel `linux-t2`, konfiguraciju zvuka za T2, Appleov firmver za Broadcom Wi-Fi/Bluetooth i upravljanje ventilatorom putem `t2fanrd`. Touch Bar radi na ugrađenoj podršci kernela u stilu Boot Campa.

#### iMac Retina 5K (2017)

27-inčni iMac iz 2017. nema čip T2, pa ga instalacijski program postavlja kao i ostale Intel Macove.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Poznati problemi

- Zaslon ne radi u svojoj izvornoj rezoluciji 5120×2880: panel se sastoji od dvije pločice, a standardni upravljački program aktivira samo jednu
- Zvuk ne radi
- Kontrola svjetline nema učinka
- Mirovanje blokira računalo; iz toga ga može izvući samo isključivanje i ponovno uključivanje

Program za zakrpe zajednice za ovaj model ispravlja zaslon, zvuk i svjetlinu: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
